#!/usr/bin/env python3
"""Keyboard teleop node for omnidirectional robot — incremental speed control.

Press once to nudge speed, Space to stop.

W  → forward  (+0.25 to linear.x)
S  → backward (-0.25 to linear.x)
A  → left     (+0.25 to linear.y)
D  → right    (-0.25 to linear.y)
Q  → CCW      (+0.25 to angular.z)
E  → CW       (-0.25 to angular.z)
Space → emergency stop (all zero)
"""

import rospy
import sys
import threading
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

    step = rospy.get_param('~step', 0.25)
    max_linear = rospy.get_param('~max_linear', 2.0)
    max_angular = rospy.get_param('~max_angular', 3.0)

    pub = rospy.Publisher('cmd_vel', Twist, queue_size=10)
    rate = rospy.Rate(10)

    lock = threading.Lock()
    exit_flag = False

    # Current speed state — starts at zero
    lin_x = 0.0
    lin_y = 0.0
    ang_z = 0.0

    # Detect terminal mode
    have_raw = (_getch() is not None)
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

    # Main loop: publish current speed at steady 10 Hz
    while not rospy.is_shutdown() and not exit_flag:
        with lock:
            twist = Twist()
            twist.linear.x = lin_x
            twist.linear.y = lin_y
            twist.angular.z = ang_z
        pub.publish(twist)
        rate.sleep()

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
