#!/usr/bin/env python3
import os
import shutil
import subprocess

import rospy
import rospkg
from geometry_msgs.msg import PoseWithCovarianceStamped

from se_map.srv import ClearMap, ClearMapResponse
from se_map.srv import SaveMap, SaveMapResponse
from se_map.srv import SetInitialPose, SetInitialPoseResponse


class MapManager:
    def __init__(self):
        package_dir = rospkg.RosPack().get_path('se_map')
        self.map_dir = rospy.get_param('~map_dir', os.path.join(package_dir, 'maps'))
        self.default_map_name = rospy.get_param('~default_map_name', 'saved_map')
        self.initial_pose_repeat = int(rospy.get_param('~initial_pose_repeat', 5))
        self.initial_pose_interval = float(rospy.get_param('~initial_pose_interval', 0.1))
        self.covariance = float(rospy.get_param('~initial_pose_covariance', 0.12))

        os.makedirs(self.map_dir, exist_ok=True)

        self.initial_pose_pub = rospy.Publisher(
            '/initialpose',
            PoseWithCovarianceStamped,
            queue_size=1,
            latch=True,
        )

        rospy.Service('/se_map/save_map', SaveMap, self.handle_save_map)
        rospy.Service('/se_map/clear_map', ClearMap, self.handle_clear_map)
        rospy.Service('/se_map/set_initial_pose', SetInitialPose, self.handle_set_initial_pose)
        rospy.loginfo('[se_map] map_manager ready. map_dir=%s', self.map_dir)

    def _safe_map_name(self, name):
        name = name.strip() if name else self.default_map_name
        name = os.path.basename(name)
        if name.endswith('.yaml') or name.endswith('.pgm'):
            name = os.path.splitext(name)[0]
        if not name:
            name = self.default_map_name
        return name

    def handle_save_map(self, req):
        map_name = self._safe_map_name(req.name)
        target = os.path.join(self.map_dir, map_name)
        command = ['rosrun', 'map_server', 'map_saver', '-f', target]
        rospy.loginfo('[se_map] saving map: %s', ' '.join(command))
        try:
            completed = subprocess.run(
                command,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                check=False,
            )
        except OSError as exc:
            return SaveMapResponse(False, target, 'failed to execute map_saver: {}'.format(exc))

        if completed.returncode != 0:
            message = completed.stderr.strip() or completed.stdout.strip() or 'map_saver failed'
            rospy.logerr('[se_map] save map failed: %s', message)
            return SaveMapResponse(False, target, message)

        yaml_path = target + '.yaml'
        rospy.loginfo('[se_map] map saved: %s', yaml_path)
        return SaveMapResponse(True, yaml_path, 'map saved')

    def handle_clear_map(self, req):
        if not req.confirm:
            return ClearMapResponse(False, 'confirm must be true')
        if not os.path.isdir(self.map_dir):
            os.makedirs(self.map_dir, exist_ok=True)
            return ClearMapResponse(True, 'map directory created')

        removed = 0
        for filename in os.listdir(self.map_dir):
            path = os.path.join(self.map_dir, filename)
            if filename == '.gitkeep':
                continue
            try:
                if os.path.isdir(path):
                    shutil.rmtree(path)
                else:
                    os.unlink(path)
                removed += 1
            except OSError as exc:
                rospy.logerr('[se_map] failed to remove %s: %s', path, exc)
                return ClearMapResponse(False, 'failed to remove {}: {}'.format(path, exc))

        return ClearMapResponse(True, 'removed {} map files'.format(removed))

    def handle_set_initial_pose(self, req):
        self.publish_initial_pose(req.pose)
        return SetInitialPoseResponse(True, 'initial pose published')

    def publish_initial_pose(self, pose):
        msg = PoseWithCovarianceStamped()
        msg.header.frame_id = 'map'
        msg.pose.pose = pose
        msg.pose.covariance = [0.0] * 36
        msg.pose.covariance[0] = self.covariance
        msg.pose.covariance[7] = self.covariance
        msg.pose.covariance[35] = self.covariance

        for _ in range(max(1, self.initial_pose_repeat)):
            msg.header.stamp = rospy.Time.now()
            self.initial_pose_pub.publish(msg)
            rospy.sleep(self.initial_pose_interval)


if __name__ == '__main__':
    rospy.init_node('se_map_manager')
    MapManager()
    rospy.spin()
