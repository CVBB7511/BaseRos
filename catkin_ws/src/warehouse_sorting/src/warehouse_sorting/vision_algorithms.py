from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

from warehouse_sorting.core import Cargo, make_pose_dict


@dataclass
class ColorDepthDebug:
    cargo_type: str
    mask_pixels: int
    contours: int
    accepted: int
    rejected: List[str]


class ColorDepthDetector:
    """HSV segmentation plus local depth lookup for simple tabletop cargo.

    The detector intentionally has no ROS dependency. The ROS node owns message
    conversion; this class owns the tunable visual logic so it can be tested with
    synthetic images before the next real-machine run.
    """

    def __init__(self, cargo_specs: Dict[str, Dict[str, Any]], options: Optional[Dict[str, Any]] = None):
        self.cargo_specs = cargo_specs or {}
        self.options = options or {}
        self.default_depth = float(self.options.get("default_depth", 0.45))
        self.depth_window = int(self.options.get("depth_window", 7))
        if self.depth_window < 1:
            self.depth_window = 1
        if self.depth_window % 2 == 0:
            self.depth_window += 1
        self.min_depth = float(self.options.get("min_depth", 0.10))
        self.max_depth = float(self.options.get("max_depth", 1.50))
        self.morph_kernel = int(self.options.get("morph_kernel", 5))
        self.min_extent = int(self.options.get("min_extent", 12))
        self.max_results_per_type = int(self.options.get("max_results_per_type", 3))
        self.roi = self.options.get("roi", {})

    def detect(self, bgr_image, depth_image=None, camera_matrix: Optional[Sequence[float]] = None):
        cv2, np = _load_cv()
        hsv = cv2.cvtColor(bgr_image, cv2.COLOR_BGR2HSV)
        roi_bounds = self._roi_bounds(bgr_image.shape[1], bgr_image.shape[0])
        cargos: List[Cargo] = []
        debug: List[ColorDepthDebug] = []

        for cargo_type, spec in self.cargo_specs.items():
            mask = self._mask_for_spec(hsv, spec)
            mask = self._apply_roi(mask, roi_bounds)
            mask = self._clean_mask(mask)
            contours, _hierarchy = cv2.findContours(mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            accepted_for_type: List[Tuple[float, Cargo]] = []
            rejected: List[str] = []

            for contour in contours:
                area = float(cv2.contourArea(contour))
                min_area = float(spec.get("min_area", 1200.0))
                if area < min_area:
                    rejected.append("area %.1f < %.1f" % (area, min_area))
                    continue
                x, y, width, height = cv2.boundingRect(contour)
                if width < self.min_extent or height < self.min_extent:
                    rejected.append("extent %dx%d < %d" % (width, height, self.min_extent))
                    continue
                cx = int(x + width / 2)
                cy = int(y + height / 2)
                pose = self.pixel_to_pose(cx, cy, depth_image, camera_matrix)
                confidence = min(1.0, area / max(min_area * 3.0, 1.0))
                cargo = Cargo(
                    cargo_id="%s-%03d" % (cargo_type, len(accepted_for_type) + 1),
                    cargo_type=cargo_type,
                    pose=pose,
                    size=spec.get("size", {"x": 0.12, "y": 0.12, "z": 0.10}),
                    confidence=confidence,
                    bbox={"x": x, "y": y, "width": width, "height": height},
                )
                accepted_for_type.append((area, cargo))

            accepted_for_type.sort(key=lambda item: item[0], reverse=True)
            selected = [cargo for _area, cargo in accepted_for_type[: self.max_results_per_type]]
            cargos.extend(selected)
            debug.append(
                ColorDepthDebug(
                    cargo_type=cargo_type,
                    mask_pixels=int(np.count_nonzero(mask)),
                    contours=len(contours),
                    accepted=len(selected),
                    rejected=rejected[:5],
                )
            )

        cargos.sort(key=lambda cargo: cargo.confidence, reverse=True)
        return cargos, debug

    def pixel_to_pose(self, u: int, v: int, depth_image=None, camera_matrix: Optional[Sequence[float]] = None):
        z = self._depth_at(depth_image, u, v)
        if camera_matrix:
            fx = float(camera_matrix[0]) or 1.0
            fy = float(camera_matrix[4]) or 1.0
            cx = float(camera_matrix[2])
            cy = float(camera_matrix[5])
            x = (float(u) - cx) * z / fx
            y = (float(v) - cy) * z / fy
        else:
            x = (float(u) - 320.0) * 0.001
            y = (float(v) - 240.0) * 0.001
        return make_pose_dict(x=x, y=y, z=z)

    def _depth_at(self, depth_image, u: int, v: int) -> float:
        if depth_image is None:
            return self.default_depth
        _cv2, np = _load_cv()
        height, width = depth_image.shape[:2]
        radius = self.depth_window // 2
        x0 = max(0, u - radius)
        x1 = min(width, u + radius + 1)
        y0 = max(0, v - radius)
        y1 = min(height, v + radius + 1)
        window = np.asarray(depth_image[y0:y1, x0:x1], dtype=np.float32)
        if window.size == 0:
            return self.default_depth
        values = window[np.isfinite(window)]
        values = values[values > 0.0]
        if values.size == 0:
            return self.default_depth
        if float(np.nanmax(values)) > 10.0:
            values = values / 1000.0
        values = values[(values >= self.min_depth) & (values <= self.max_depth)]
        if values.size == 0:
            return self.default_depth
        return float(np.median(values))

    def _mask_for_spec(self, hsv_image, spec: Dict[str, Any]):
        cv2, np = _load_cv()
        lower = np.array(spec.get("hsv_lower", [0, 0, 0]), dtype=np.uint8)
        upper = np.array(spec.get("hsv_upper", [179, 255, 255]), dtype=np.uint8)
        if int(lower[0]) <= int(upper[0]):
            return cv2.inRange(hsv_image, lower, upper)
        # Hue can wrap around 179 -> 0 for red-like targets.
        low_a = np.array([lower[0], lower[1], lower[2]], dtype=np.uint8)
        high_a = np.array([179, upper[1], upper[2]], dtype=np.uint8)
        low_b = np.array([0, lower[1], lower[2]], dtype=np.uint8)
        high_b = np.array([upper[0], upper[1], upper[2]], dtype=np.uint8)
        return cv2.bitwise_or(cv2.inRange(hsv_image, low_a, high_a), cv2.inRange(hsv_image, low_b, high_b))

    def _clean_mask(self, mask):
        if self.morph_kernel <= 1:
            return mask
        cv2, np = _load_cv()
        kernel = np.ones((self.morph_kernel, self.morph_kernel), dtype=np.uint8)
        opened = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel)
        return cv2.morphologyEx(opened, cv2.MORPH_CLOSE, kernel)

    def _roi_bounds(self, width: int, height: int) -> Tuple[int, int, int, int]:
        if not self.roi:
            return 0, 0, width, height
        x = float(self.roi.get("x", 0.0))
        y = float(self.roi.get("y", 0.0))
        w = float(self.roi.get("width", width))
        h = float(self.roi.get("height", height))
        if 0.0 <= x <= 1.0 and 0.0 < w <= 1.0:
            x *= width
            w *= width
        if 0.0 <= y <= 1.0 and 0.0 < h <= 1.0:
            y *= height
            h *= height
        x0 = max(0, min(width, int(round(x))))
        y0 = max(0, min(height, int(round(y))))
        x1 = max(x0, min(width, int(round(x + w))))
        y1 = max(y0, min(height, int(round(y + h))))
        return x0, y0, x1, y1

    def _apply_roi(self, mask, bounds: Tuple[int, int, int, int]):
        x0, y0, x1, y1 = bounds
        if x0 == 0 and y0 == 0 and x1 == mask.shape[1] and y1 == mask.shape[0]:
            return mask
        _cv2, np = _load_cv()
        roi_mask = np.zeros_like(mask)
        roi_mask[y0:y1, x0:x1] = mask[y0:y1, x0:x1]
        return roi_mask


def _load_cv():
    import cv2
    import numpy as np

    return cv2, np
