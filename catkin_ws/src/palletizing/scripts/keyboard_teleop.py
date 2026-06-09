#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
键盘遥控节点 (Keyboard Teleop Node)
用于在实机（无手柄、无仿真包）环境下控制机器人移动和建图。

按键说明:
  w : 前进
  s : 后退
  a : 左平移
  d : 右平移
  q : 左转 (原地旋转)
  e : 右转 (原地旋转)
  空格键 : 紧急停止

退出请按 Ctrl+C。
"""

import rospy
from geometry_msgs.msg import Twist
import sys
import select
import termios
import tty

msg = """
=========================================
      实机键盘遥控节点 (Keyboard Teleop)
=========================================
使用如下按键控制机器人移动:

    q (左转)    w (前进)    e (右转)
    a (左移)    s (后退)    d (右移)

    空格键 : 紧急停止

按 Ctrl+C 退出程序
=========================================
"""

def getKey():
    tty.setraw(sys.stdin.fileno())
    rlist, _, _ = select.select([sys.stdin], [], [], 0.1)
    if rlist:
        key = sys.stdin.read(1)
    else:
        key = ''
    termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
    return key

if __name__=="__main__":
    settings = termios.tcgetattr(sys.stdin)
    rospy.init_node('keyboard_teleop')
    pub = rospy.Publisher('/cmd_vel', Twist, queue_size=5)

    # 实机安全速度限制 (m/s 和 rad/s)
    speed = 0.2
    turn = 0.3

    x = 0
    y = 0
    th = 0
    status = 0

    try:
        print(msg)
        while not rospy.is_shutdown():
            key = getKey()
            
            # 持续按键判定
            if key == 'w':
                x = speed; y = 0; th = 0
            elif key == 's':
                x = -speed; y = 0; th = 0
            elif key == 'a':
                x = 0; y = speed; th = 0
            elif key == 'd':
                x = 0; y = -speed; th = 0
            elif key == 'q':
                x = 0; y = 0; th = turn
            elif key == 'e':
                x = 0; y = 0; th = -turn
            elif key == ' ' or key == 'x':
                x = 0; y = 0; th = 0
            elif key == '\x03': # Ctrl+C
                break
            else:
                x = 0; y = 0; th = 0 # 松开停止

            twist = Twist()
            twist.linear.x = x
            twist.linear.y = y
            twist.linear.z = 0
            twist.angular.x = 0
            twist.angular.y = 0
            twist.angular.z = th
            pub.publish(twist)

    except Exception as e:
        print(e)
    finally:
        twist = Twist()
        twist.linear.x = 0; twist.linear.y = 0; twist.linear.z = 0
        twist.angular.x = 0; twist.angular.y = 0; twist.angular.z = 0
        pub.publish(twist)
        termios.tcsetattr(sys.stdin, termios.TCSADRAIN, settings)
