#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import rospy
import random
import math
from gazebo_msgs.srv import SpawnModel
from gazebo_msgs.msg import ModelStates
from geometry_msgs.msg import Pose

class BoxManager:
    def __init__(self):
        rospy.init_node('box_spawner_manager', anonymous=True)
        
        # A 台子的中心坐标
        self.table_x = 2.0
        self.table_y = 1.5
        self.table_z = 0.75
        
        self.box_count = 0
        self.current_box_name = ""
        self.box_on_table = False
        
        # 备选颜色库
        # 'Gazebo/Red', 'Gazebo/Blue', 'Gazebo/Green', 'Gazebo/Yellow', 'Gazebo/Purple'
        self.colors = ['Gazebo/Red', 'Gazebo/Green']

        # 等待 Gazebo 的生成服务启动
        rospy.loginfo("等待 Gazebo 生成服务...")
        rospy.wait_for_service('/gazebo/spawn_sdf_model')
        self.spawn_service = rospy.ServiceProxy('/gazebo/spawn_sdf_model', SpawnModel)
        
        # 订阅上帝视角，实时监控箱子位置
        self.sub = rospy.Subscriber('/gazebo/model_states', ModelStates, self.states_cb)
        rospy.loginfo("箱子生成器已就绪！")

    def states_cb(self, msg):
        """实时监控当前箱子的位置"""
        if not self.box_on_table or not self.current_box_name:
            return
            
        if self.current_box_name in msg.name:
            # 找到当前箱子在数组中的索引
            idx = msg.name.index(self.current_box_name)
            pose = msg.pose[idx]
            
            # 计算箱子距离 A 台子中心的水平距离
            dist = math.hypot(pose.position.x - self.table_x, pose.position.y - self.table_y)
            
            # 如果箱子离开台子中心超过 0.3 米 (说明被抓走或掉落)
            if dist > 0.3 or pose.position.z < 0.2:
                rospy.loginfo(f"检测到 {self.current_box_name} 已离开台子！准备生成新箱子...")
                self.box_on_table = False

    def spawn_new_box(self):
        """在台子上生成一个新箱子"""
        self.box_count += 1
        self.current_box_name = f"cargo_box_{self.box_count}"
        selected_color = random.choice(self.colors)
        
        # 动态拼接箱子的 SDF XML 字符串
        sdf_xml = f"""<?xml version="1.0" ?>
        <sdf version="1.6">
          <model name="{self.current_box_name}">
            <link name="link">
              <inertial>
                <mass>0.1</mass>
                <inertia><ixx>0.0001</ixx><ixy>0</ixy><ixz>0</ixz><iyy>0.0001</iyy><iyz>0</iyz><izz>0.0001</izz></inertia>
              </inertial>
              <collision name="collision">
                <geometry><box><size>0.1 0.1 0.1</size></box></geometry>
                <surface>
                  <friction><ode><mu>1.0</mu><mu2>1.0</mu2></ode></friction>
                </surface>
              </collision>
              <visual name="visual">
                <geometry><box><size>0.1 0.1 0.1</size></box></geometry>
                <material><script><uri>file://media/materials/scripts/gazebo.material</uri><name>{selected_color}</name></script></material>
              </visual>
            </link>
          </model>
        </sdf>"""

        target_pose = Pose()
        
        # 箱子中心坐标
        rand_x = self.table_x + random.uniform(-0.1, 0.1)
        rand_y = self.table_y - 0.2 + random.uniform(0, 0.1)
        
        target_pose.position.x = rand_x
        target_pose.position.y = rand_y
        target_pose.position.z = self.table_z + 0.05 # 略高于桌面，自然掉落

        # ★ 2. 随机生成水平旋转角 (Yaw: 0 到 2π)
        # rand_yaw = random.uniform(0, 2 * math.pi)
        rand_yaw = 0.0 # 不旋转
        
        # ★ 3. 将 Yaw (欧拉角) 手动转换为 四元数 (Quaternion)
        # 绕 Z 轴旋转的四元数公式: qw = cos(yaw/2), qz = sin(yaw/2), qx=0, qy=0
        target_pose.orientation.x = 0.0
        target_pose.orientation.y = 0.0
        target_pose.orientation.z = math.sin(rand_yaw / 2.0)
        target_pose.orientation.w = math.cos(rand_yaw / 2.0)

        try:
            # 调用服务生成模型
            self.spawn_service(
                model_name=self.current_box_name, 
                model_xml=sdf_xml, 
                robot_namespace="/", 
                initial_pose=target_pose, 
                reference_frame="world"
            )
            rospy.loginfo(f"成功生成: {self.current_box_name} (颜色: {selected_color}, 偏航角: {math.degrees(rand_yaw):.1f}度)")
            self.box_on_table = True
        except Exception as e:
            rospy.logerr(f"生成箱子失败: {e}")

    def run(self):
        rate = rospy.Rate(5) # 每秒检查 5 次
        while not rospy.is_shutdown():
            if not self.box_on_table:
                self.spawn_new_box()
                # 生成后强制休眠 2 秒，等待物理引擎结算（让箱子稳稳掉在桌面上）
                rospy.sleep(2.0)
            rate.sleep()

if __name__ == '__main__':
    try:
        manager = BoxManager()
        manager.run()
    except rospy.ROSInterruptException:
        pass