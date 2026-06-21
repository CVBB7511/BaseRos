# 机器人 `run` 方法行为说明

本文结合以下代码说明机器人任务的执行顺序：

- `palletizing_executor.py`：完整的检测、抓取、运输、放置循环。
- `../src/palletizing_detection/object_detection.py`：执行器继承的点云检测公共实现，负责采样、融合、提前完成、超时和重试。

## 最重要的结论：动作如何开始

`palletizing_executor.py` 的 `run()` 在服务回调创建的后台线程中**串行执行**，不是由一个总时间表定时触发。大部分后续动作只有在前一个函数返回后才会开始，但“函数返回”不总等于真实硬件动作已经完成。检测步骤则同步调用 `object_detection.py` 中的 `detect_with_retry()`，该函数返回前，`run()` 不会开始抓取。

可以把动作分成三类：

1. **有完成反馈的严格衔接**：导航等待 `move_base` 结果；抓取等待 `/wpb_home/grab_result`；放置等待 `/wpb_home/place_result`；检测等待足够样本或超时。下一步在这些完成条件满足后才开始。
2. **按计算时长执行的开环动作**：后退根据“距离 ÷ 速度”计算持续时间，定时发布速度，没有里程计闭环完成判断。
3. **只发布命令、没有完成确认的动作**：机械臂升降/夹爪命令重复发布若干次，发布结束后流程就继续，不等待关节到位。因此它与下一动作是“固定发布时间后衔接”，不是“机械臂实际到位后衔接”。

`rospy.Timer(rospy.Duration(1.0), ...)`（`palletizing_executor.py:220`）只负责每秒发布统计信息，**不驱动 `run` 的动作顺序**。

## `palletizing_executor.py` 的 `run()`

入口位于 `palletizing_executor.py:814`。调用 `/palletizing/start` 后，服务回调在 `palletizing_executor.py:362-370` 将状态设为 `STARTING`，并启动后台线程执行 `run()`。

### 总体顺序

```text
启动服务
  → 固定等待 0.5 s
  → 发布机械臂检测姿态
  → 等待导航到取货桌结束
  → [循环]
      发布机械臂检测姿态
      → 等待检测成功/失败
      → 选择物体并转换坐标
      → 等待抓取成功/失败
      → 发布持物抬臂命令
      → 定时开环后退至估计安全距离
      → 等待导航到放货桌结束
      → 停车并固定等待底盘稳定
      → 等待放置成功/超时
      → 更新堆叠格
      → 发布抬臂命令
      → 定时开环后退至估计安全距离
      → 发布收臂命令
      → 等待导航回取货桌结束
      → 回到循环开头
  → 没有可检测物体或发生终止错误时设为 DONE
```

### 每一步的开始条件

| 动作 | 代码位置 | 下一动作何时开始 | 性质 |
|---|---:|---|---|
| 启动缓冲 | `817` | 固定等待 `0.5 s` 后 | 定时等待 |
| 设置检测姿态 | `824`、`832`，实现 `586-594` | 命令重复发布 `arm_publish_count` 次后；默认约 `3 × 0.10 s`，不检查关节到位 | 定时发布、无完成反馈 |
| 导航到取货桌 | `825`、`929`，实现 `674-705` | `move_base.wait_for_result()` 返回成功/失败，或达到 `nav_timeout`；结果返回后另等 `nav_release_delay` 并停车 | 严格依赖导航结果，带超时 |
| 检测 | `834` | 检测融合成功，或所有检测尝试失败后 | 严格依赖检测结果，内部带采样/超时 |
| 坐标变换、排序 | `838-866` | 同步计算结束后 | 串行计算 |
| 抓取语音提示 | `867`，实现 `794-801` | 发布一次语音消息后立即继续，不等待播报结束 | 异步发布、无完成反馈 |
| 抓取 | `868`，实现 `715-739` | 收到抓取结果 `done` 或 `failed`；最长等待默认 `90 s` | 严格依赖反馈，带超时 |
| 持物抬臂 | `876` | 机械臂命令重复发布完毕后，不检查到位 | 定时发布、无完成反馈 |
| 离开取货桌 | `877-879`，实现 `624-646` | 按计算出的后退距离和速度定时运行结束后 | 开环定时运动 |
| 导航到放货桌 | `881` | 导航完成/失败/超时后 | 严格依赖导航结果 |
| 放置前稳定底盘 | `893`，实现 `553-559` | 重复发停车命令后，再固定等待 `robot_settle_time`，默认 `0.40 s` | 定时等待 |
| 放置 | `906`，实现 `741-771` | 收到有效的 `place_result=done`，或达到 `place_timeout`，默认 `120 s` | 严格依赖反馈，带超时 |
| 放置后的抬臂 | `923` | 命令重复发布完毕后，不检查到位 | 定时发布、无完成反馈 |
| 离开放货桌 | `924-926` | 开环后退定时结束后 | 开环定时运动 |
| 收臂 | `927` | 命令重复发布完毕后，不检查到位 | 定时发布、无完成反馈 |
| 返回取货桌 | `929` | 导航完成/失败/超时后才进入下一轮检测 | 严格依赖导航结果 |

任务结束语音（`935-936`）同样只发布消息，不等待语音播放完成；统计消息的发布也不阻塞动作流程。

放置结果还有一层旧消息保护：`palletizing_executor.py:354-360` 只接受放置命令发布至少 `0.5 s` 后到达的 `done`。这不是让放置固定执行 `0.5 s`，而是避免上一次动作残留的 `done` 使本次放置被误判为瞬间完成。

### 检测动作内部的等待

`detect_with_retry()` 在 `object_detection.py:307-316`：

- 每次检测前先停车，并固定稳定 `detect_retry_settle`，默认 `0.15 s`。
- 发布 `object_detect start` 后，以 `detect_poll_period`（默认 `0.10 s`）轮询样本。
- 样本满足稳定融合条件时可以提前成功；否则单次最多等待 `detect_timeout`，默认 `2.0 s`。
- `detect_retry_count` 的代码默认值是 `1`，其含义是**总尝试次数为 1**，不是“首次加重试一次”。

因此检测后的抓取严格依赖一次成功的稳定检测，不是固定若干秒后无条件抓取。

### 失败分支

- 首次无法到达取货桌：立即设为 `DONE` 并退出。
- 检测不到物体或没有可排序物体：认为任务完成，退出循环。
- TF 变换失败或抓取失败：计为失败，然后 `continue`，在当前位置重新进入下一轮检测。
- 无法到达放货桌、放置坐标变换失败或放置失败：计为失败并终止循环。
- 无法返回取货桌：终止循环。

注意：抓取失败后直接重新检测，代码没有先执行专门的复位、后退或重新导航动作（`859-874`）。

## `object_detection.py` 的检测行为

`ObjectDetectionMixin` 不是独立运行的 ROS 节点，也没有自己的 `run()`。`PalletizingExecutor` 继承它，并在主循环的 `palletizing_executor.py:834` 同步调用 `detect_with_retry()`。

### 单次检测 `detect_objects()`

入口位于 `object_detection.py:245-305`，执行顺序如下：

```text
状态改为 DETECTING，并清空上一次结果和样本
  → 发布 object_detect start
  → 接收 /wpb_home/objects_3d 消息并保存非空样本
  → 每隔 detect_poll_period 检查一次
      ├─ 达到最少样本且融合结果稳定：可提前成功
      ├─ 达到目标样本数：融合并判断成功/失败
      └─ 达到 detect_timeout：用已有样本做最后一次融合
  → 退出前发布 object_detect stop
  → 成功时保存 latest_objects，失败时返回 False
```

检测消息回调位于 `object_detection.py:58-64`。只有当前状态为 `DETECTING` 的消息会被接受；空物体消息可以更新 `latest_objects`，但不会加入融合样本。

关键参数定义于 `object_detection.py:20-35`：

| 参数 | 默认值 | 行为 |
|---|---:|---|
| `detect_timeout` | `2.0 s` | 单次检测最长等待时间。 |
| `detect_poll_period` | `0.10 s` | 主线程检查样本和超时条件的轮询周期，不是传感器采样周期。 |
| `detect_min_samples` | `2` | 允许尝试提前融合的最少非空样本数。 |
| `detect_fusion_samples` | `4` | 正常情况下希望收集的目标样本数。实际目标是它与 `detect_min_samples` 中的较大值。 |
| `detect_fusion_min_hits` | `2` | 一个融合轨迹至少被多少个样本命中，才视为稳定物体。 |
| `detect_early_finish` | `true` | 达到最少样本并形成完整稳定结果时，是否提前结束。 |
| `detect_fusion_merge_xy` | `0.08 m` | 不同帧中的目标在 XY 平面小于该距离时，可以归入同一轨迹。 |

提前完成条件位于 `object_detection.py:258-274`：样本数达到 `detect_min_samples` 后进行融合；只有稳定融合物体数不少于各帧观测到的最大物体数时才提前成功。因此不是等待固定 `2 s` 后才检测完成。

超时处理位于 `object_detection.py:276-290`：即使到达 `detect_timeout`，仍会融合已经收到的样本；若能形成至少一个稳定物体仍返回成功，否则返回失败。

### 多帧融合 `_fuse_object_samples()`

融合实现位于 `object_detection.py:151-243`：

- 按 XY 距离把不同帧中的检测归并为轨迹，阈值为 `detect_fusion_merge_xy`。
- 只保留命中次数不小于 `detect_fusion_min_hits` 的稳定轨迹。
- 位置和尺寸使用中位数，概率使用平均值，物体类型使用多数票。
- `10cm_cube`/`hard_cube` 统一为 `hard_cube`，`15cm_cube`/`soft_cube` 统一为 `soft_cube`。
- 成功融合后更新 `latest_objects`，并由 `_publish_fused_markers()` 发布 RViz 包围框和文字标签。

### 重试 `detect_with_retry()`

入口位于 `object_detection.py:307-316`：

1. 每次尝试前调用执行器提供的 `_wait_robot_settled(detect_retry_settle)`，先重复发布零速度，再固定等待；`detect_retry_settle` 默认 `0.15 s`。
2. 同步执行一次 `detect_objects()`。
3. 成功时发布融合标记、调用成功钩子并立即返回 `True`。
4. 失败时才开始下一次尝试；所有尝试失败后返回 `False`。

`detect_retry_count` 默认值为 `1`，代码把它直接作为**总尝试次数**，不是“首次检测后再额外重试一次”。检测失败返回主 `run()` 后，执行器把“没有检测到物体”视为任务完成并退出循环（`palletizing_executor.py:834-836`）。

从时序上说，检测既有固定的停车稳定等待和轮询周期，也有严格的结果依赖：抓取必须等 `detect_with_retry()` 返回成功后才会开始；检测可能因稳定样本提前结束，也可能一直等到单次超时。

## 偏移量及其修改位置

以下行号对应当前代码。大多数值由私有 ROS 参数 `~参数名` 读取，推荐在 launch 文件或启动命令中覆盖，而不是直接修改 Python 默认值。

### 导航停靠偏移

| 参数/偏移 | 默认值 | 定义或修改位置 | 参与计算的位置 | 含义 |
|---|---:|---|---|---|
| `approach_offset` | `0.70 m` | `palletizing_executor.py:145` | `656-658` | 机器人与取货桌近边缘之间的额外停靠距离。中心到导航点距离为 `桌面半深 + approach_offset`。 |
| `place_approach_offset` | `0.70 m` | `palletizing_executor.py:146` | `650-658` | 机器人与放货桌近边缘之间的额外停靠距离。 |
| `table_half_depth` | `0.25 m` | executor `147` | executor `652/656` | 仅当对应的 `table_width <= 0.01` 时使用的半深度兜底值。正常默认桌宽为 `0.5 m`，因此实际半深也是 `0.25 m`。 |

导航点公式为：

```text
distance = table_width / 2 + approach_offset
nav_x = table_x - distance × cos(approach_yaw)
nav_y = table_y - distance × sin(approach_yaw)
```

放货桌使用同一公式，但偏移参数换成 `place_approach_offset`。

### 放置区域与放置点偏移

| 参数/偏移 | 默认值 | 定义或修改位置 | 参与计算的位置 | 含义 |
|---|---:|---|---|---|
| `zone_separation_y` | `0.45 m` | `palletizing_executor.py:120`；launch `palletizing.launch:40` | `328-333` | 硬/软物体区域中心间距；硬区为 `+间距/2`，软区为 `-间距/2`。实际沿桌面的横向单位向量偏移，不一定是地图坐标系的 Y 轴。 |
| `spacing_x` | `0.20 m` | executor `118`；launch `38` | `64、68-69` | 同一堆叠网格相邻列的横向间距。 |
| `spacing_y` | `0.17 m` | executor `119`；launch `39` | `65-69` | 同一堆叠网格相邻行的深度间距。 |
| `place_depth_retreat` | `0.06 m` | executor `121`；launch `41` | `65-69` | 从网格深度坐标中减去，使放置点向机器人/桌边方向回收，避免放得过深。 |
| `place_stack_clearance` | `0.0 m` | executor `128` | `890-892` | 所有物体放置中心 Z 在“堆顶 + 半个物体高度”基础上的统一额外抬高量。 |
| `soft_place_offset` | `0.005 m` | executor `127`；launch `36` | `890-892` | 仅软物体额外增加的 Z 高度，当前为 `5 mm`。 |

`SimpleGridStacking.get_place_pose()` 的平面偏移公式位于 `palletizing_executor.py:60-69`。如果目标是调整落点，优先修改上述 ROS 参数；直接改变这里的正负号会改变偏移方向。

### 抓取点和点云显示偏移

| 参数/偏移 | 默认值 | 定义或修改位置 | 参与计算的位置 | 含义 |
|---|---:|---|---|---|
| 物体半尺寸修正 | 由物体高度决定 | 高度参数在 executor `123-126` | executor `803-812` | 检测给出的 `objects.x` 被视为物体远侧边缘，抓取中心使用 `grab_x = edge_x - object_height/2`；抓取 Z 使用固定桌高 `grab_table_height + object_height/2`。 |
| `PRISM_Z_OFFSET` | `0.03 m` | executor `93`；检测模块兜底值在 `object_detection.py:101` | `object_detection.py:101、114` | 把点云棱柱输出的 Z 下移 `3 cm` 来绘制融合框。当前简化 executor 的实际抓取 Z 使用固定桌高，所以该常量不直接修改 `run()` 的抓取高度。 |

### 离桌后退相关偏移

| 参数/偏移 | 默认值 | 定义或修改位置 | 参与计算的位置 | 含义 |
|---|---:|---|---|---|
| `arm_reach_distance` | `0.50 m` | executor `139` | `624-637` | 机械臂向前伸出的估计距离。 |
| `arm_exit_margin` | `0.10 m` | executor `140` | `627` | 离开桌边所需的额外安全余量；要求桌边净空为两者之和，默认 `0.60 m`。 |
| `min_table_exit_back_distance` | `0.02 m` | executor `141` | `637-642` | 计算出的后退量不超过该阈值时不再后退。 |
| `back_distance` | `0.50 m` | executor `138` | `596-604、632-635` | 无法通过 TF 计算桌边净空时使用的兜底后退距离。 |

后退距离计算位于 `palletizing_executor.py:614-646`：

```text
当前桌边净空 = 机器人到桌中心的朝向投影 - 桌宽 / 2
要求净空 = arm_reach_distance + arm_exit_margin
后退距离 = 要求净空 - 当前桌边净空
```

执行后退时没有用里程计判断是否真的走够距离，而是在 `palletizing_executor.py:596-612` 使用 `duration = distance / abs(back_speed)`，每隔 `back_period` 发布速度。因此 `back_speed` 和 `back_period` 虽不是几何偏移量，也会影响实际后退误差。

## 修改参数时的两个注意点

1. ROS 参数会覆盖 Python 中的默认值。当前 `palletizing.launch:36-41` 明确设置了部分放置偏移；这些值的优先级高于 Python 默认值。`approach_offset` 和 `place_approach_offset` 当前未在该 launch 中配置，因而使用 Python 默认值，除非从其他启动层或命令行传入。
2. `palletizing_executor.py` 会从 `zones_file` 加载已标定的桌中心、桌宽和朝向（初始化代码 `165-166`）。这些桌面参数会参与偏移公式，所以只改 `approach_offset` 而忽略已保存桌宽，最终停靠点也可能和预期不同。
