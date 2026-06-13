# se_map

`se_map` 是课程项目的建图与地图文件管理包。

## 职责

- 启动手动建图流程：仿真/实机底盘、`slam_gmapping`、键盘控制、地图管理服务。
- 保存当前 `/map` 到 `se_map/maps`。
- 清理 `se_map/maps` 下的地图文件。
- 发布 `/initialpose`，供 AMCL 初始化位姿。

## 服务

- `/se_map/save_map` (`se_map/SaveMap`)
- `/se_map/clear_map` (`se_map/ClearMap`)
- `/se_map/set_initial_pose` (`se_map/SetInitialPose`)

## 启动

```bash
roslaunch se_map manual_mapping.launch sim:=true
```

保存地图：

```bash
rosservice call /se_map/save_map "name: 'saved_map'"
```
