import unittest

import cv2
import numpy as np

from warehouse_sorting.vision_algorithms import ColorDepthDetector


def hsv_to_bgr(h, s, v):
    hsv = np.array([[[h, s, v]]], dtype=np.uint8)
    return tuple(int(value) for value in cv2.cvtColor(hsv, cv2.COLOR_HSV2BGR)[0, 0])


class ColorDepthDetectorTest(unittest.TestCase):
    def test_detects_colored_box_with_depth(self):
        image = np.zeros((240, 320, 3), dtype=np.uint8)
        image[:] = (30, 30, 30)
        cv2.rectangle(image, (120, 80), (200, 160), (255, 0, 0), -1)
        depth = np.zeros((240, 320), dtype=np.uint16)
        depth[80:161, 120:201] = 650

        detector = ColorDepthDetector(
            {
                "colored": {
                    "hsv_lower": [90, 60, 50],
                    "hsv_upper": [135, 255, 255],
                    "min_area": 1000,
                    "size": {"x": 0.12, "y": 0.12, "z": 0.10},
                }
            },
            {"depth_window": 5, "min_depth": 0.1, "max_depth": 1.5},
        )

        cargos, debug = detector.detect(
            image,
            depth,
            camera_matrix=[500.0, 0.0, 160.0, 0.0, 500.0, 120.0, 0.0, 0.0, 1.0],
        )

        self.assertEqual(len(cargos), 1)
        self.assertEqual(cargos[0].cargo_type, "colored")
        self.assertAlmostEqual(cargos[0].pose["z"], 0.65, places=2)
        self.assertEqual(cargos[0].bbox["width"], 81)
        self.assertEqual(debug[0].accepted, 1)

    def test_detects_natural_and_colored_boxes(self):
        image = np.zeros((480, 640, 3), dtype=np.uint8)
        image[:] = (35, 35, 35)
        cv2.rectangle(image, (170, 160), (270, 260), hsv_to_bgr(22, 110, 180), -1)
        cv2.rectangle(image, (360, 160), (460, 260), hsv_to_bgr(110, 210, 220), -1)
        depth = np.zeros((480, 640), dtype=np.uint16)
        depth[160:261, 170:271] = 650
        depth[160:261, 360:461] = 650

        specs = {
            "natural": {
                "hsv_lower": [10, 20, 60],
                "hsv_upper": [35, 180, 230],
                "min_area": 1200,
            },
            "colored": {
                "hsv_lower": [90, 60, 50],
                "hsv_upper": [135, 255, 255],
                "min_area": 1200,
            },
        }
        detector = ColorDepthDetector(
            specs,
            {
                "roi": {"x": 0.10, "y": 0.15, "width": 0.80, "height": 0.70},
                "depth_window": 7,
                "min_depth": 0.2,
                "max_depth": 1.5,
            },
        )

        cargos, debug = detector.detect(
            image,
            depth,
            camera_matrix=[525.0, 0.0, 320.0, 0.0, 525.0, 240.0, 0.0, 0.0, 1.0],
        )

        self.assertEqual({cargo.cargo_type for cargo in cargos}, {"natural", "colored"})
        self.assertEqual(sum(item.accepted for item in debug), 2)
        self.assertTrue(all(abs(cargo.pose["z"] - 0.65) < 0.01 for cargo in cargos))

    def test_roi_rejects_outside_object(self):
        image = np.zeros((240, 320, 3), dtype=np.uint8)
        cv2.rectangle(image, (10, 80), (80, 160), (255, 0, 0), -1)
        detector = ColorDepthDetector(
            {
                "colored": {
                    "hsv_lower": [90, 60, 50],
                    "hsv_upper": [135, 255, 255],
                    "min_area": 1000,
                }
            },
            {"roi": {"x": 0.4, "y": 0.0, "width": 0.6, "height": 1.0}},
        )

        cargos, debug = detector.detect(image)

        self.assertEqual(cargos, [])
        self.assertEqual(debug[0].accepted, 0)


if __name__ == "__main__":
    unittest.main()
