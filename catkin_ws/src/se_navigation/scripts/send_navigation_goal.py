#!/usr/bin/env python3
import argparse
import math

import actionlib
import rospy
from geometry_msgs.msg import Pose
from tf.transformations import quaternion_from_euler

from se_navigation.msg import NavigateAction, NavigateGoal


def pose_from_xyyaw(x, y, yaw):
    pose = Pose()
    pose.position.x = x
    pose.position.y = y
    pose.position.z = 0.0
    q = quaternion_from_euler(0.0, 0.0, yaw)
    pose.orientation.x = q[0]
    pose.orientation.y = q[1]
    pose.orientation.z = q[2]
    pose.orientation.w = q[3]
    return pose


def main():
    parser = argparse.ArgumentParser(description='Send a se_navigation Navigate action goal.')
    parser.add_argument('--goal-x', type=float, required=True)
    parser.add_argument('--goal-y', type=float, required=True)
    parser.add_argument('--goal-yaw', type=float, default=0.0)
    parser.add_argument('--timeout', type=float, default=120.0)
    args = parser.parse_args(rospy.myargv()[1:])

    rospy.init_node('se_navigation_goal_client')
    client = actionlib.SimpleActionClient('/se_navigation/navigate', NavigateAction)
    if not client.wait_for_server(rospy.Duration(30.0)):
        raise RuntimeError('timed out waiting for /se_navigation/navigate')

    goal = NavigateGoal()
    goal.goal = pose_from_xyyaw(args.goal_x, args.goal_y, args.goal_yaw)

    rospy.loginfo('[se_navigation] sending goal: goal=(%.2f, %.2f, %.2f)',
                  args.goal_x, args.goal_y, args.goal_yaw)
    client.send_goal(goal)
    finished = client.wait_for_result(rospy.Duration(args.timeout))
    if not finished:
        client.cancel_goal()
        raise RuntimeError('navigation timed out after {} seconds'.format(args.timeout))

    result = client.get_result()
    rospy.loginfo('[se_navigation] result: success=%s result=%s message=%s',
                  result.success, result.result, result.message)
    if not result.success:
        raise RuntimeError(result.message)


if __name__ == '__main__':
    main()
