#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import math
import rospy
from geometry_msgs.msg import PoseStamped
from tf.transformations import euler_from_quaternion

class NavGoalCapture:
    def __init__(self, point_name):
        self.point_name = point_name
        rospy.init_node('capture_nav_goal', anonymous=True)
        rospy.Subscriber('/move_base_simple/goal', PoseStamped, self.goal_callback)
        print('=' * 60)
        print('等待你在 RViz 中点击 2D Nav Goal ...')
        print('当前要记录的点名:', self.point_name)
        print('=' * 60)

    def goal_callback(self, msg):
        x = msg.pose.position.x
        y = msg.pose.position.y

        qx = msg.pose.orientation.x
        qy = msg.pose.orientation.y
        qz = msg.pose.orientation.z
        qw = msg.pose.orientation.w

        _, _, yaw = euler_from_quaternion([qx, qy, qz, qw])

        print('\n已捕获导航点：')
        print(f'{self.point_name}:')
        print(f'  x: {x:.6f}')
        print(f'  y: {y:.6f}')
        print(f'  yaw: {yaw:.6f}')
        print('\n请把这段结果保存下来，然后继续记录下一个点。')
        rospy.signal_shutdown('goal captured')

if __name__ == '__main__':
    if len(sys.argv) != 2:
        print('用法: rosrun restaurant_robot_navigation capture_nav_goal.py 点名')
        print('示例: rosrun restaurant_robot_navigation capture_nav_goal.py entrance')
        sys.exit(1)

    point_name = sys.argv[1]
    NavGoalCapture(point_name)
    rospy.spin()
