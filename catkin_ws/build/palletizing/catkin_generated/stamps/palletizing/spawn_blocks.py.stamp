#!/usr/bin/env python3
# coding=utf-8
"""码垛机器人系统 - 安全健壮的方块自动生成器。

该脚本读取 config/palletizing_params.yaml 中的 spawner 配置，
在指定的桌子上自动生成所需数量的红色和绿色方块，并按照指定的间距排布。
通过等待 Gazebo 服务、使用 ROS Service API 以及加入重试机制，确保 100% 成功生成。
"""

import os
import rospy
import rospkg
import math
from gazebo_msgs.srv import SpawnModel
from geometry_msgs.msg import Pose, Point, Quaternion


def main():
    rospy.init_node("block_spawner", anonymous=True)
    rospack = rospkg.RosPack()
    pkg_path = rospack.get_path("palletizing")

    # 获取全局参数
    spawner_config = rospy.get_param("/spawner", {})
    zones_config = rospy.get_param("/zones", {})
    
    spacing = spawner_config.get("spacing", 0.15)
    drop_height = spawner_config.get("drop_height", 2.0)
    spawner_zones = spawner_config.get("zones", {})

    models = {
        "red": os.path.join(pkg_path, "models", "red_block.model"),
        "green": os.path.join(pkg_path, "models", "green_block.model")
    }

    # 等待 Gazebo 服务就绪，防止 Gazebo 还没完全启动就尝试生成导致全部失败
    rospy.loginfo("[BlockSpawner] 正在等待 Gazebo 生成模型服务 (/gazebo/spawn_urdf_model) 就绪...")
    try:
        rospy.wait_for_service('/gazebo/spawn_urdf_model', timeout=30.0)
        spawn_model_client = rospy.ServiceProxy('/gazebo/spawn_urdf_model', SpawnModel)
        rospy.loginfo("[BlockSpawner] Gazebo 生成服务已就绪，开始生成方块...")
    except rospy.ROSException as e:
        rospy.logerr(f"[BlockSpawner] 等待 Gazebo 服务超时或失败: {e}，积木生成已取消！")
        return

    total_spawned = 0
    for zone_id, counts in spawner_zones.items():
        if zone_id not in zones_config:
            rospy.logwarn(f"[BlockSpawner] 区域 {zone_id} 未定义在 /zones 中，跳过。")
            continue

        place_cfg = zones_config[zone_id].get("placement", {})
        start_x = place_cfg.get("start_x", 0.0)
        start_y = place_cfg.get("start_y", 0.0)
        
        red_count = counts.get("red", 0)
        green_count = counts.get("green", 0)
        
        if red_count == 0 and green_count == 0:
            continue

        rospy.loginfo(f"[BlockSpawner] 正在区域 {zone_id} 生成 {red_count} 个红方块，{green_count} 个绿方块")

        # 依次生成
        blocks = ["red"] * red_count + ["green"] * green_count
        n_total = len(blocks)
        
        # 获取观测位姿以进行居中计算
        obs_cfg = zones_config[zone_id].get("observation_point", {})
        obs_x = obs_cfg.get("x", 0.0)
        obs_y = obs_cfg.get("y", 0.0)
        obs_yaw = obs_cfg.get("yaw", 0.0)

        # 判断桌子走向 (根据 yaw 判定是南北向还是东西向)
        # 如果机器人面向南北 (yaw ~ 1.57 or -1.57), 则方块应在 X 轴上居中
        # 如果机器人面向东西 (yaw ~ 0 or 3.14), 则方块应在 Y 轴上居中
        is_north_south = abs(math.sin(obs_yaw)) > 0.7

        for i, color in enumerate(blocks):
            model_name = f"{color}_block_{zone_id}_{i}"
            model_file = models[color]
            
            # 计算偏移量，使得 N 个方块整体相对于 obs 居中
            offset = (i - (n_total - 1) / 2.0) * spacing
            
            if is_north_south:
                # 机器人面朝南北，横向轴是 X
                spawn_x = obs_x + offset
                spawn_y = start_y  # 纵向位置由 placement 定义
            else:
                # 机器人面朝东西，横向轴是 Y
                spawn_x = start_x
                spawn_y = obs_y + offset

            # 读取模型 XML 文件内容
            try:
                with open(model_file, "r", encoding="utf-8") as f:
                    model_xml = f.read()
            except Exception as e:
                rospy.logerr(f"[BlockSpawner] 无法读取模型文件 {model_file}: {e}，跳过生成 {model_name}")
                continue

            # 构建初始位姿 Pose
            pose = Pose()
            pose.position.x = spawn_x
            pose.position.y = spawn_y
            pose.position.z = drop_height
            pose.orientation.w = 1.0  # 默认无旋转朝向

            # 重试机制生成实体
            spawn_success = False
            max_attempts = 3
            for attempt in range(max_attempts):
                try:
                    resp = spawn_model_client(
                        model_name=model_name,
                        model_xml=model_xml,
                        robot_namespace="",
                        initial_pose=pose,
                        reference_frame="world"
                    )
                    if resp.success:
                        rospy.loginfo(f"[BlockSpawner] 成功生成实体: {model_name}")
                        spawn_success = True
                        break
                    else:
                        rospy.logwarn(f"[BlockSpawner] 第 {attempt+1} 次生成 {model_name} 失败: {resp.status_message}。准备重试...")
                except rospy.ServiceException as e:
                    rospy.logerr(f"[BlockSpawner] 第 {attempt+1} 次生成 {model_name} 发生服务异常: {e}。准备重试...")
                rospy.sleep(1.0)

            if spawn_success:
                total_spawned += 1
            else:
                rospy.logerr(f"[BlockSpawner] 实体 {model_name} 经历 {max_attempts} 次尝试后生成失败！")
            
            rospy.sleep(0.5)  # 稍微错开生成时间，以防物理引擎由于生成过快发生抖动或卡顿

    rospy.loginfo(f"[BlockSpawner] 自动生成完毕，共成功生成 {total_spawned} 个方块。")


if __name__ == "__main__":
    try:
        main()
    except rospy.ROSInterruptException:
        pass
