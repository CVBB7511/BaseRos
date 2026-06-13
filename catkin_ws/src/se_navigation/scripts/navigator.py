#!/usr/bin/env python3
import actionlib
import rospy
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from nav_msgs.msg import Path

from se_navigation.msg import NavigateAction, NavigateFeedback, NavigateResult


class Navigator:
    def __init__(self):
        self.move_base_name = rospy.get_param('~move_base_action', 'move_base')

        self.path = []
        self.current_index = 0
        self.done = False
        self.move_base_state = None

        self.path_sub = rospy.Subscriber(
            '/move_base/GlobalPlanner/plan',
            Path,
            self.handle_global_plan,
            queue_size=1,
        )

        self.move_base = actionlib.SimpleActionClient(self.move_base_name, MoveBaseAction)
        self.server = actionlib.SimpleActionServer(
            '/se_navigation/navigate',
            NavigateAction,
            execute_cb=self.execute,
            auto_start=False,
        )
        self.server.start()
        rospy.loginfo('[se_navigation] navigator ready. move_base_action=%s', self.move_base_name)

    def handle_global_plan(self, msg):
        self.path = [
            (
                pose_stamped.pose.position.x,
                pose_stamped.pose.position.y,
            )
            for pose_stamped in msg.poses
        ]
        self.current_index = 0

    def execute(self, goal):
        self._reset_state()
        self.server.publish_feedback(NavigateFeedback(percentage=0, state='waiting_for_move_base'))

        if not self.move_base.wait_for_server(rospy.Duration(10.0)):
            self.server.set_aborted(NavigateResult(False, 'error', 'move_base action server unavailable'))
            return

        move_goal = MoveBaseGoal()
        move_goal.target_pose.header.frame_id = 'map'
        move_goal.target_pose.header.stamp = rospy.Time.now()
        move_goal.target_pose.pose = goal.goal

        self.move_base.send_goal(
            move_goal,
            done_cb=self._done_cb,
            active_cb=self._active_cb,
            feedback_cb=self._feedback_cb,
        )

        rate = rospy.Rate(5)
        while not rospy.is_shutdown():
            if self.server.is_preempt_requested():
                self.move_base.cancel_goal()
                self.server.set_preempted(NavigateResult(False, 'cancel', 'navigation canceled'))
                return

            if self.done:
                self._finish_from_move_base()
                return

            rate.sleep()

    def _reset_state(self):
        self.path = []
        self.current_index = 0
        self.done = False
        self.move_base_state = None

    def _active_cb(self):
        self.server.publish_feedback(NavigateFeedback(percentage=0, state='planning'))

    def _feedback_cb(self, move_feedback):
        if not self.path:
            self.server.publish_feedback(NavigateFeedback(percentage=0, state='planning'))
            return

        robot_x = move_feedback.base_position.pose.position.x
        robot_y = move_feedback.base_position.pose.position.y

        nearest = self.current_index
        nearest_dist = None
        for index in range(self.current_index, len(self.path)):
            px, py = self.path[index]
            dist = (robot_x - px) ** 2 + (robot_y - py) ** 2
            if nearest_dist is None or dist < nearest_dist:
                nearest_dist = dist
                nearest = index

        self.current_index = nearest
        percentage = int(100.0 * (self.current_index + 1) / max(1, len(self.path)))
        percentage = max(0, min(99, percentage))
        self.server.publish_feedback(NavigateFeedback(percentage=percentage, state='normal'))

    def _done_cb(self, state, _result):
        self.move_base_state = state
        self.done = True

    def _finish_from_move_base(self):
        if self.move_base_state == actionlib.GoalStatus.SUCCEEDED:
            self.server.publish_feedback(NavigateFeedback(percentage=100, state='reached'))
            self.server.set_succeeded(NavigateResult(True, 'success', 'navigation reached goal'))
        elif self.move_base_state == actionlib.GoalStatus.PREEMPTED:
            self.server.set_preempted(NavigateResult(False, 'cancel', 'navigation preempted'))
        else:
            text = self._goal_status_text(self.move_base_state)
            self.server.set_aborted(NavigateResult(False, 'fail', 'move_base finished with {}'.format(text)))

    @staticmethod
    def _goal_status_text(state):
        names = {
            actionlib.GoalStatus.PENDING: 'PENDING',
            actionlib.GoalStatus.ACTIVE: 'ACTIVE',
            actionlib.GoalStatus.PREEMPTED: 'PREEMPTED',
            actionlib.GoalStatus.SUCCEEDED: 'SUCCEEDED',
            actionlib.GoalStatus.ABORTED: 'ABORTED',
            actionlib.GoalStatus.REJECTED: 'REJECTED',
            actionlib.GoalStatus.PREEMPTING: 'PREEMPTING',
            actionlib.GoalStatus.RECALLING: 'RECALLING',
            actionlib.GoalStatus.RECALLED: 'RECALLED',
            actionlib.GoalStatus.LOST: 'LOST',
        }
        return names.get(state, str(state))


if __name__ == '__main__':
    rospy.init_node('se_navigation_navigator')
    Navigator()
    rospy.spin()
