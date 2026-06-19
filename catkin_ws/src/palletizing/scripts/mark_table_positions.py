#!/usr/bin/env python3
"""
引导式桌面标定工具 — 在真机或仿真中标定取货桌和码垛桌的位置。

使用方法:
  交互模式（推荐）:
    rosrun palletizing mark_table_positions.py

  命令行直接模式:
    rosrun palletizing mark_table_positions.py --zone source --x 1.0 --y 0.5 --yaw 0.0

工作流:
  1. 将机器人推到桌子前方, 正对桌面中心
  2. 运行此脚本, 选择标定取货桌或码垛桌
  3. 脚本读取机器人当前位姿, 询问桌面尺寸
  4. 自动计算桌面中心坐标, 调用 /palletizing/mark_zone 保存
"""

import sys
import math
import argparse
import os
import rospkg
import tf
import rospy
from palletizing.srv import MarkZone, MarkZoneResponse


def default_zones_file():
    try:
        pkg_path = rospkg.RosPack().get_path('palletizing')
        project_root = os.path.abspath(os.path.join(pkg_path, '..', '..', '..'))
        return os.path.join(project_root, 'zones.yaml')
    except Exception:
        return os.path.join(os.path.expanduser('~'), 'waterjet', 'zones.yaml')


def normalize_angle(yaw):
    """Normalize yaw to [-pi, pi]."""
    return math.atan2(math.sin(yaw), math.cos(yaw))


def get_robot_pose(tf_listener):
    """Get current robot pose in /map frame. Returns (x, y, yaw) or None."""
    try:
        tf_listener.waitForTransform('/map', '/base_link', rospy.Time(0),
                                     rospy.Duration(3.0))
        (trans, rot) = tf_listener.lookupTransform('/map', '/base_link', rospy.Time(0))
        yaw = math.atan2(2.0 * (rot[3] * rot[2] + rot[0] * rot[1]),
                         1.0 - 2.0 * (rot[1]**2 + rot[2]**2))
        return trans[0], trans[1], yaw
    except (tf.LookupException, tf.ConnectivityException,
            tf.ExtrapolationException, tf.Exception) as e:
        rospy.logerr("TF lookup failed: %s", e)
        return None


def call_mark_zone(zone_name, x, y, z, yaw, length, width):
    """Call /palletizing/mark_zone service."""
    rospy.wait_for_service('/palletizing/mark_zone', timeout=5.0)
    try:
        mark = rospy.ServiceProxy('/palletizing/mark_zone', MarkZone)
        resp = mark(zone_name=zone_name, x=x, y=y, z=z,
                    yaw=yaw, length=length, width=width)
        return resp.success
    except rospy.ServiceException as e:
        rospy.logerr("Service call failed: %s", e)
        return False


def interactive_mode():
    """Interactive guided table marking."""
    rospy.init_node('mark_table_positions', anonymous=True)
    tf_listener = tf.TransformListener()

    print("=" * 60)
    print("  桌面标定工具 — 引导式标定")
    print("=" * 60)
    print()
    print("请将机器人推到桌子正前方，让机器人正对桌面中心。")
    print("确保机器人已在 /map 中正确定位（AMCL 已收敛）。")
    print()

    # Choose zone
    while True:
        choice = input("标定哪个区域? [s]ource=取货桌 / [d]est=码垛桌 (s/d): ").strip().lower()
        if choice in ('s', 'source'):
            zone_name = 'source'
            break
        elif choice in ('d', 'dest'):
            zone_name = 'dest'
            break
        else:
            print("  请输入 s 或 d")

    # Get robot pose
    print()
    print("正在读取机器人当前位姿...")
    rospy.sleep(0.5)  # let TF settle
    pose = get_robot_pose(tf_listener)
    if pose is None:
        print("ERROR: 无法获取机器人位姿。请确认 AMCL 已定位、TF 树正常。")
        sys.exit(1)

    robot_x, robot_y, robot_yaw = pose
    print(f"  机器人位姿: x={robot_x:.3f}, y={robot_y:.3f}, yaw={math.degrees(robot_yaw):.1f}°")

    # Table dimensions
    print()
    print("桌面尺寸 (默认值适用于标准桌子):")
    try:
        length_str = input("  桌面长边长度 (m) [1.0]: ").strip()
        length = float(length_str) if length_str else 1.0
        width_str = input("  桌面短边/深度 (m) [0.5]: ").strip()
        width = float(width_str) if width_str else 0.5
        height_str = input("  桌面离地高度 (m) [0.75]: ").strip()
        table_z = float(height_str) if height_str else 0.75
    except ValueError:
        print("ERROR: 输入格式错误")
        sys.exit(1)

    # Distance from robot to table center
    print()
    print("机器人到桌面中心的距离:")
    print("  (机器人当前位置 + 此距离 × 机器人朝向 = 桌面中心)")
    half_depth = width / 2.0
    default_dist = half_depth + 0.70  # approach_offset
    try:
        dist_str = input(f"  距离 (m) [默认={default_dist:.2f}]: ").strip()
        distance = float(dist_str) if dist_str else default_dist
    except ValueError:
        print("ERROR: 输入格式错误")
        sys.exit(1)

    # Compute table center
    table_x = robot_x + distance * math.cos(robot_yaw)
    table_y = robot_y + distance * math.sin(robot_yaw)
    # Table faces the robot: table_yaw = robot_yaw + pi
    table_yaw = normalize_angle(robot_yaw + math.pi)

    print()
    print("--- 计算结果 ---")
    print(f"  桌面中心:  x={table_x:.3f}, y={table_y:.3f}, z={table_z:.3f}")
    print(f"  桌面朝向:  {math.degrees(table_yaw):.1f}° (长边方向)")
    print(f"  桌面尺寸:  长={length:.2f}m, 宽(深)={width:.2f}m")
    print(f"  机器人接近朝向: {math.degrees(normalize_angle(table_yaw + math.pi)):.1f}°")
    print()

    confirm = input("确认保存? [Y/n]: ").strip().lower()
    if confirm and confirm != 'y':
        print("已取消。")
        sys.exit(0)

    # Call service
    ok = call_mark_zone(zone_name, table_x, table_y, table_z,
                        table_yaw, length, width)
    if ok:
        print(f"✓ 已保存到 {default_zones_file()} (zone='{zone_name}')")
        print(f"  下次启动 palletizing_executor 时会自动加载。")
    else:
        print("ERROR: 保存失败，请检查 palletizing_executor 是否在运行。")
        sys.exit(1)


def direct_mode(args):
    """Direct command-line mode without interactive prompts."""
    rospy.init_node('mark_table_positions', anonymous=True)

    if args.x is None or args.y is None:
        # Use current robot position
        tf_listener = tf.TransformListener()
        rospy.sleep(0.5)
        pose = get_robot_pose(tf_listener)
        if pose is None:
            print("ERROR: 无法获取机器人位姿。")
            sys.exit(1)
        table_x, table_y, robot_yaw = pose
        table_yaw = args.yaw if args.yaw is not None else normalize_angle(robot_yaw + math.pi)
    else:
        table_x = args.x
        table_y = args.y
        table_yaw = args.yaw if args.yaw is not None else 0.0

    table_z = args.z if args.z is not None else 0.75
    length = args.length if args.length is not None else 1.0
    width = args.width if args.width is not None else 0.5

    print(f"Zone: {args.zone}")
    print(f"  Center: ({table_x:.3f}, {table_y:.3f}, {table_z:.3f})")
    print(f"  Yaw: {math.degrees(table_yaw):.1f}°")
    print(f"  Size: {length:.2f} × {width:.2f} m")

    ok = call_mark_zone(args.zone, table_x, table_y, table_z,
                        table_yaw, length, width)
    if ok:
        print(f"✓ Saved to {default_zones_file()}")
    else:
        print("ERROR: Save failed. Is palletizing_executor running?")
        sys.exit(1)


def main():
    parser = argparse.ArgumentParser(
        description='桌面标定工具 — 标定取货桌 / 码垛桌位置')
    parser.add_argument('--zone', type=str, choices=['source', 'dest'],
                        help='标定区域: source=取货桌, dest=码垛桌')
    parser.add_argument('--x', type=float, default=None,
                        help='桌面中心 X (map 坐标). 不指定则使用当前机器人位置')
    parser.add_argument('--y', type=float, default=None,
                        help='桌面中心 Y (map 坐标)')
    parser.add_argument('--z', type=float, default=None,
                        help='桌面表面高度 (m), 默认 0.75')
    parser.add_argument('--yaw', type=float, default=None,
                        help='桌面朝向 (rad). 默认: 机器人朝向 + pi')
    parser.add_argument('--length', type=float, default=None,
                        help='桌面长边 (m), 默认 1.0')
    parser.add_argument('--width', type=float, default=None,
                        help='桌面短边/深度 (m), 默认 0.5')
    args = parser.parse_args()

    if args.zone is not None:
        direct_mode(args)
    else:
        interactive_mode()


if __name__ == '__main__':
    main()
