"""Shared multi-frame object-detection pipeline for palletizing nodes."""

import math
import time

import rospy
from std_msgs.msg import String
from wpb_home_behaviors.msg import Coord


class ObjectDetectionMixin:
    """Provide sampling, fusion, timeout, and retry behavior to a ROS node.

    The host class must provide ``behavior_pub``, ``state``,
    ``_get_object_height()``, and ``_wait_robot_settled()``.
    """

    def _init_object_detection(self):
        self.detect_timeout = rospy.get_param('~detect_timeout', 2.0)
        self.detect_poll_period = rospy.get_param('~detect_poll_period', 0.10)
        self.detect_min_samples = rospy.get_param('~detect_min_samples', 2)
        self.detect_fusion_samples = rospy.get_param('~detect_fusion_samples', 4)
        self.detect_fusion_min_hits = rospy.get_param(
            '~detect_fusion_min_hits', 2)
        self.detect_fusion_merge_xy = rospy.get_param(
            '~detect_fusion_merge_xy', 0.08)
        self.detect_retry_count = rospy.get_param('~detect_retry_count', 1)
        self.detect_retry_settle = rospy.get_param(
            '~detect_retry_settle', 0.15)
        self.latest_objects = None
        self.detected_object_samples = []

    @staticmethod
    def _median(values):
        values = sorted(values)
        if not values:
            return 0.0
        mid = len(values) // 2
        if len(values) % 2:
            return values[mid]
        return 0.5 * (values[mid - 1] + values[mid])

    @staticmethod
    def _object_raw_type(objects, idx, default='hard_cube'):
        types = getattr(objects, 'type', [])
        if idx < len(types) and types[idx]:
            return types[idx]
        return default

    def _objects_callback(self, msg):
        if self.state != 'DETECTING':
            return
        self.latest_objects = msg
        self._on_detection_message(msg)
        if len(msg.name) > 0:
            self.detected_object_samples.append(msg)

    def _on_detection_message(self, _msg):
        """Optional host hook for statistics or debug output."""

    def _on_detection_success(self, _attempt, _attempts):
        """Optional host hook after a fused detection succeeds."""

    def _fuse_object_samples(self, samples, min_hits=None):
        if min_hits is None:
            min_hits = max(1, int(self.detect_fusion_min_hits))
        tracks = []
        merge_xy = max(0.01, float(self.detect_fusion_merge_xy))

        for sample in samples:
            for i in range(len(sample.name)):
                if i >= len(sample.x) or i >= len(sample.y) or i >= len(sample.z):
                    continue
                x = sample.x[i]
                y = sample.y[i]
                z = sample.z[i]
                best = None
                best_dist = None
                for track in tracks:
                    tx = self._median(track['x'])
                    ty = self._median(track['y'])
                    dist = math.hypot(x - tx, y - ty)
                    if dist <= merge_xy and (best_dist is None or dist < best_dist):
                        best = track
                        best_dist = dist
                if best is None:
                    best = {
                        'name': [],
                        'type': [],
                        'x': [],
                        'y': [],
                        'z': [],
                        'probability': [],
                        'size_x': [],
                        'size_y': [],
                        'size_z': [],
                    }
                    tracks.append(best)

                best['name'].append(
                    sample.name[i] if i < len(sample.name) else '')
                best['type'].append(self._object_raw_type(sample, i))
                best['x'].append(x)
                best['y'].append(y)
                best['z'].append(z)
                if i < len(sample.probability):
                    best['probability'].append(sample.probability[i])
                for field in ('size_x', 'size_y', 'size_z'):
                    values = getattr(sample, field, [])
                    if i < len(values):
                        best[field].append(values[i])

        stable_tracks = [
            track for track in tracks if len(track['x']) >= min_hits]
        if not stable_tracks:
            return None

        stable_tracks.sort(key=lambda track: (
            -len(track['x']),
            abs(self._median(track['y'])),
            self._median(track['x']),
        ))

        fused = Coord()
        for idx, track in enumerate(stable_tracks):
            type_votes = {}
            for raw_type in track['type']:
                norm_type = 'hard_cube'
                if raw_type in ('15cm_cube', 'soft_cube'):
                    norm_type = 'soft_cube'
                elif raw_type not in ('10cm_cube', 'hard_cube'):
                    norm_type = raw_type
                type_votes[norm_type] = type_votes.get(norm_type, 0) + 1
            obj_type = (
                max(type_votes, key=type_votes.get)
                if type_votes else 'hard_cube')
            fused.name.append('obj_%d' % idx)
            fused.type.append(obj_type)
            fused.x.append(self._median(track['x']))
            fused.y.append(self._median(track['y']))
            fused.z.append(self._median(track['z']))
            fused.probability.append(
                sum(track['probability']) / len(track['probability'])
                if track['probability'] else float(len(track['x'])))
            fused.size_x.append(
                self._median(track['size_x']) if track['size_x'] else 0.0)
            fused.size_y.append(
                self._median(track['size_y']) if track['size_y'] else 0.0)
            default_size_z = self._get_object_height(obj_type)
            fused.size_z.append(
                self._median(track['size_z'])
                if track['size_z'] else default_size_z)

        rospy.loginfo("Fused %d samples into %d stable objects",
                      len(samples), len(fused.name))
        return fused

    def detect_objects(self, timeout=None):
        if timeout is None:
            timeout = self.detect_timeout
        self.state = 'DETECTING'
        self.latest_objects = None
        self.detected_object_samples = []
        msg = String(data='object_detect start')
        self.behavior_pub.publish(msg)
        start = time.time()
        min_samples = max(1, int(self.detect_min_samples))
        target_samples = max(min_samples, int(self.detect_fusion_samples))

        while len(self.detected_object_samples) < target_samples:
            if time.time() - start > timeout:
                fused = self._fuse_object_samples(
                    self.detected_object_samples)
                msg.data = 'object_detect stop'
                self.behavior_pub.publish(msg)
                if fused is not None and len(fused.name) > 0:
                    self.latest_objects = fused
                    rospy.loginfo("Detected %d stable objects after timeout",
                                  len(self.latest_objects.name))
                    return True
                rospy.logwarn(
                    "Object detection timed out: got %d/%d non-empty samples",
                    len(self.detected_object_samples), min_samples)
                return False
            rospy.sleep(self.detect_poll_period)

        msg.data = 'object_detect stop'
        self.behavior_pub.publish(msg)
        fused = self._fuse_object_samples(self.detected_object_samples)
        if fused is None or len(fused.name) == 0:
            rospy.logwarn(
                "Object detection rejected unstable samples: got %d samples",
                len(self.detected_object_samples))
            return False
        self.latest_objects = fused
        rospy.loginfo("Detected %d stable objects", len(self.latest_objects.name))
        return True

    def detect_with_retry(self):
        attempts = max(1, int(self.detect_retry_count))
        for attempt in range(attempts):
            self._wait_robot_settled(self.detect_retry_settle)
            if self.detect_objects():
                self._on_detection_success(attempt + 1, attempts)
                return True
            rospy.logwarn("Detect attempt %d/%d failed", attempt + 1, attempts)
        return False
