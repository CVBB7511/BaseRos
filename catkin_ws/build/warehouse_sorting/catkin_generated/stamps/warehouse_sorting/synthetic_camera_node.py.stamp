#!/usr/bin/env python3

import rospy
from sensor_msgs.msg import CameraInfo, Image


def hsv_to_bgr(h, s, v):
    import cv2
    import numpy as np

    hsv = np.array([[[h, s, v]]], dtype=np.uint8)
    return tuple(int(value) for value in cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)[0, 0])


class SyntheticCameraNode:
    def __init__(self):
        self.frame_id = rospy.get_param("~frame_id", "synthetic_camera")
        self.width = int(rospy.get_param("~width", 640))
        self.height = int(rospy.get_param("~height", 480))
        self.depth_mm = int(rospy.get_param("~depth_mm", 650))
        self.publish_rate = float(rospy.get_param("~publish_rate", 5.0))

        self.rgb_pub = rospy.Publisher("/camera/rgb/image_raw", Image, queue_size=2)
        self.depth_pub = rospy.Publisher("/camera/depth/image_raw", Image, queue_size=2)
        self.info_pub = rospy.Publisher("/camera/rgb/camera_info", CameraInfo, queue_size=2)
        rospy.loginfo("synthetic_camera ready %dx%d depth=%dmm", self.width, self.height, self.depth_mm)

    def spin(self):
        rate = rospy.Rate(self.publish_rate)
        while not rospy.is_shutdown():
            stamp = rospy.Time.now()
            image, depth = self._make_scene()
            self.rgb_pub.publish(self._image_msg(image, "bgr8", stamp))
            self.depth_pub.publish(self._image_msg(depth, "16UC1", stamp))
            self.info_pub.publish(self._camera_info(stamp))
            rate.sleep()

    def _make_scene(self):
        import cv2
        import numpy as np

        image = np.zeros((self.height, self.width, 3), dtype=np.uint8)
        image[:] = (35, 35, 35)
        depth = np.zeros((self.height, self.width), dtype=np.uint16)

        natural_bgr = hsv_to_bgr(22, 110, 180)
        colored_bgr = hsv_to_bgr(110, 210, 220)
        natural_box = (170, 160, 270, 260)
        colored_box = (360, 160, 460, 260)
        cv2.rectangle(image, natural_box[:2], natural_box[2:], natural_bgr, -1)
        cv2.rectangle(image, colored_box[:2], colored_box[2:], colored_bgr, -1)
        depth[natural_box[1] : natural_box[3] + 1, natural_box[0] : natural_box[2] + 1] = self.depth_mm
        depth[colored_box[1] : colored_box[3] + 1, colored_box[0] : colored_box[2] + 1] = self.depth_mm
        return image, depth

    def _image_msg(self, array, encoding, stamp):
        msg = Image()
        msg.header.stamp = stamp
        msg.header.frame_id = self.frame_id
        msg.height = int(array.shape[0])
        msg.width = int(array.shape[1])
        msg.encoding = encoding
        msg.is_bigendian = False
        if encoding == "bgr8":
            msg.step = msg.width * 3
        elif encoding == "16UC1":
            msg.step = msg.width * 2
        else:
            raise ValueError("unsupported encoding %s" % encoding)
        msg.data = array.tobytes()
        return msg

    def _camera_info(self, stamp):
        msg = CameraInfo()
        msg.header.stamp = stamp
        msg.header.frame_id = self.frame_id
        msg.width = self.width
        msg.height = self.height
        fx = fy = 525.0
        cx = self.width / 2.0
        cy = self.height / 2.0
        msg.K = [fx, 0.0, cx, 0.0, fy, cy, 0.0, 0.0, 1.0]
        msg.P = [fx, 0.0, cx, 0.0, 0.0, fy, cy, 0.0, 0.0, 0.0, 1.0, 0.0]
        return msg


if __name__ == "__main__":
    rospy.init_node("synthetic_camera")
    SyntheticCameraNode().spin()
