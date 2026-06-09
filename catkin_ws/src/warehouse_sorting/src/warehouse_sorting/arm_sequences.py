from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Dict, Iterable, List, Optional


@dataclass
class JointStep:
    lift: float
    gripper: float
    duration: float
    label: str = ""


class TabletopArmPlanner:
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        self.config = config or {}
        workspace = self.config.get("workspace", {})
        gripper = self.config.get("gripper", {})
        lift = self.config.get("lift", {})
        timing = self.config.get("timing", {})

        self.min_x = float(workspace.get("min_x", -0.35))
        self.max_x = float(workspace.get("max_x", 1.60))
        self.min_y = float(workspace.get("min_y", -0.85))
        self.max_y = float(workspace.get("max_y", 0.85))
        self.min_z = float(workspace.get("min_z", 0.00))
        self.max_z = float(workspace.get("max_z", 0.95))

        self.open_width = float(gripper.get("open_width", 0.16))
        self.close_width = float(gripper.get("close_width", 0.032))
        self.place_open_width = float(gripper.get("place_open_width", 0.15))

        self.home_lift = float(lift.get("home", 0.0))
        self.carry_lift = float(lift.get("carry", 0.50))
        self.pregrasp_offset = float(lift.get("pregrasp_offset", 0.08))
        self.pick_lift_offset = float(lift.get("pick_offset", 0.0))
        self.place_lift_offset = float(lift.get("place_offset", 0.03))
        self.retreat_offset = float(lift.get("retreat_offset", 0.03))

        self.step_duration = float(timing.get("step_duration", 0.6))
        self.grip_duration = float(timing.get("grip_duration", 1.0))

    def validate_pose(self, pose: Dict[str, float], action: str) -> None:
        x = float(pose.get("x", 0.0))
        y = float(pose.get("y", 0.0))
        z = float(pose.get("z", 0.0))
        errors = []
        if not self.min_x <= x <= self.max_x:
            errors.append("x %.3f outside [%.3f, %.3f]" % (x, self.min_x, self.max_x))
        if not self.min_y <= y <= self.max_y:
            errors.append("y %.3f outside [%.3f, %.3f]" % (y, self.min_y, self.max_y))
        if not self.min_z <= z <= self.max_z:
            errors.append("z %.3f outside [%.3f, %.3f]" % (z, self.min_z, self.max_z))
        if errors:
            raise ValueError("%s target is not in tabletop workspace: %s" % (action, "; ".join(errors)))

    def plan(self, action: str, pose: Dict[str, float]) -> List[JointStep]:
        action = (action or "").strip().lower()
        self.validate_pose(pose, action)
        if action == "pick":
            return self._pick_plan(pose)
        if action == "place":
            return self._place_plan(pose)
        if action == "home":
            return [JointStep(self.home_lift, self.open_width, self.step_duration, "home")]
        raise ValueError("unsupported tabletop arm action %s" % action)

    def _pick_plan(self, pose: Dict[str, float]) -> List[JointStep]:
        z = float(pose.get("z", 0.0))
        grasp_lift = self._clamp_lift(z + self.pick_lift_offset)
        pregrasp_lift = self._clamp_lift(z + self.pregrasp_offset)
        carry_lift = self._clamp_lift(max(self.carry_lift, grasp_lift + self.retreat_offset))
        return [
            JointStep(pregrasp_lift, self.open_width, self.step_duration, "pregrasp"),
            JointStep(grasp_lift, self.open_width, self.step_duration, "lower"),
            JointStep(grasp_lift, self.close_width, self.grip_duration, "close"),
            JointStep(carry_lift, self.close_width, self.step_duration, "carry"),
        ]

    def _place_plan(self, pose: Dict[str, float]) -> List[JointStep]:
        z = float(pose.get("z", 0.0))
        place_lift = self._clamp_lift(z + self.place_lift_offset)
        carry_lift = self._clamp_lift(max(self.carry_lift, place_lift + self.retreat_offset))
        return [
            JointStep(carry_lift, self.close_width, self.step_duration, "approach"),
            JointStep(place_lift, self.close_width, self.step_duration, "lower"),
            JointStep(place_lift, self.place_open_width, self.grip_duration, "release"),
            JointStep(carry_lift, self.place_open_width, self.step_duration, "retreat"),
        ]

    def _clamp_lift(self, value: float) -> float:
        return max(self.min_z, min(self.max_z, float(value)))


def sequence_to_dicts(steps: Iterable[JointStep]) -> List[Dict[str, Any]]:
    return [
        {
            "lift": step.lift,
            "gripper": step.gripper,
            "duration": step.duration,
            "label": step.label,
        }
        for step in steps
    ]
