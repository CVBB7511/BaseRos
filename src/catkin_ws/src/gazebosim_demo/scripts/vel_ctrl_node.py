#!/usr/bin/env python3
"""Keyboard teleop node for omnidirectional robot — incremental speed control.

Press once to nudge speed, Space to stop.

W  → forward  (+step to linear.x)
S  → backward (-step to linear.x)
A  → left     (+step to linear.y)
D  → right    (-step to linear.y)
Q  → CCW      (+step to angular.z)
E  → CW       (-step to angular.z)
Space → emergency stop (all zero)
"""

import rospy
import sys
import threading
import time
from geometry_msgs.msg import Twist


# ---------------------------------------------------------------------------
# Cross‑platform single‑key reader
# ---------------------------------------------------------------------------

def _getch():
    """Read a single character from stdin without waiting for Enter."""
    try:
        import termios
        import tty
        fd = sys.stdin.fileno()
        old = termios.tcgetattr(fd)
        try:
            tty.setraw(fd)
            ch = sys.stdin.read(1)
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, old)
        return ch
    except (ImportError, termios.error, OSError):
        return None


def read_key():
    """Read a single keypress. Returns lowercase char or 'space'."""
    ch = _getch()
    if ch is not None:
        if ch == '\x03':          # Ctrl-C
            raise KeyboardInterrupt
        if ch == ' ':
            return 'space'
        if ch in ('\n', '\r'):
            return None
        if len(ch) == 1 and ord(ch) < 32:
            return None
        return ch.lower()
    # Fallback: input() with Enter
    try:
        line = input()
    except (EOFError, OSError):
        return None
    if not line or line.strip() == '':
        return 'space'
    return line.strip()[0].lower()


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def clamp(val, limit):
    return max(-limit, min(limit, val))


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    rospy.init_node('vel_ctrl_node')

    step = rospy.get_param('~step', 0.05)
    max_linear = rospy.get_param('~max_linear', 0.5)
    max_angular = rospy.get_param('~max_angular', 1.0)
    cmd_vel_topic = rospy.get_param('~cmd_vel_topic', '/cmd_vel')

    pub = rospy.Publisher(cmd_vel_topic, Twist, queue_size=10)
    publish_period = 0.1

    lock = threading.Lock()
    exit_flag = False

    # Current speed state — starts at zero
    lin_x = 0.0
    lin_y = 0.0
    ang_z = 0.0

    # Detect terminal mode without reading/consuming a real key.
    have_raw = sys.stdin.isatty()
    sep = "=" * 60
    if have_raw:
        rospy.loginfo(sep)
        rospy.loginfo("KEYBOARD TELEOP — single-key mode (no Enter needed)")
        rospy.loginfo(sep)
    else:
        rospy.loginfo(sep)
        rospy.loginfo("KEYBOARD TELEOP — input() mode (press Enter after key)")
        rospy.loginfo(sep)

    rospy.loginfo("Controls (+/-%.2f per press):", step)
    rospy.loginfo("  W / S   : forward + / -         (linear.x)")
    rospy.loginfo("  A / D   : left + / right +      (linear.y)")
    rospy.loginfo("  Q / E   : CCW + / CW +          (angular.z)")
    rospy.loginfo("  Space   : EMERGENCY STOP (all → 0)")
    rospy.loginfo("  Ctrl-C  : quit")
    rospy.loginfo("Publishing Twist to %s", cmd_vel_topic)
    rospy.loginfo(sep)

    def key_reader():
        """Background thread: reads keys and nudges speed state."""
        nonlocal lin_x, lin_y, ang_z, exit_flag
        while not exit_flag and not rospy.is_shutdown():
            try:
                key = read_key()
            except KeyboardInterrupt:
                exit_flag = True
                break
            if key is None:
                continue

            with lock:
                if key == 'w':
                    lin_x = clamp(lin_x + step, max_linear)
                elif key == 's':
                    lin_x = clamp(lin_x - step, max_linear)
                elif key == 'a':
                    lin_y = clamp(lin_y + step, max_linear)
                elif key == 'd':
                    lin_y = clamp(lin_y - step, max_linear)
                elif key == 'q':
                    ang_z = clamp(ang_z + step, max_angular)
                elif key == 'e':
                    ang_z = clamp(ang_z - step, max_angular)
                elif key == 'space':
                    lin_x = 0.0
                    lin_y = 0.0
                    ang_z = 0.0
                else:
                    continue  # unknown key — ignore

            # Log outside lock to keep it short
            if key == 'space':
                rospy.loginfo(">>> STOP (all 0) <<<")
            else:
                rospy.loginfo("[%s] lin.x=%+.2f  lin.y=%+.2f  ang.z=%+.2f",
                              key.upper(), lin_x, lin_y, ang_z)

    reader_thread = threading.Thread(target=key_reader, daemon=True)
    reader_thread.start()

    # Main loop: publish current speed at steady 10 Hz.
    # Use wall-clock sleep instead of rospy.Rate so teleop keeps publishing
    # when /use_sim_time is true but Gazebo /clock is paused or not ready.
    last_conn_warn = 0.0
    while not rospy.is_shutdown() and not exit_flag:
        with lock:
            twist = Twist()
            twist.linear.x = lin_x
            twist.linear.y = lin_y
            twist.angular.z = ang_z
        pub.publish(twist)
        if pub.get_num_connections() == 0 and time.time() - last_conn_warn > 2.0:
            rospy.logwarn("No subscribers on %s. Is Gazebo robot spawned and wpb_home_mani plugin loaded?",
                          cmd_vel_topic)
            last_conn_warn = time.time()
        time.sleep(publish_period)

    # Final stop
    pub.publish(Twist())
    rospy.loginfo("Keyboard teleop stopped")


if __name__ == '__main__':
    try:
        main()
    except rospy.ROSInterruptException:
        pass
    except KeyboardInterrupt:
        rospy.loginfo("Keyboard teleop stopped by user")
