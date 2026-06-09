from __future__ import annotations

import json
import time
from dataclasses import dataclass, field
from typing import Any, Dict, Iterable, List, Optional, Tuple


TASK_PENDING = "PENDING"
TASK_RUNNING = "RUNNING"
TASK_PAUSED = "PAUSED"
TASK_COMPLETED = "COMPLETED"
TASK_ERROR = "ERROR"

CARGO_NATURAL = "natural"
CARGO_COLORED = "colored"


def now() -> float:
    return time.time()


def make_pose_dict(
    x: float = 0.0,
    y: float = 0.0,
    z: float = 0.0,
    qx: float = 0.0,
    qy: float = 0.0,
    qz: float = 0.0,
    qw: float = 1.0,
) -> Dict[str, float]:
    return {"x": x, "y": y, "z": z, "qx": qx, "qy": qy, "qz": qz, "qw": qw}


def normalize_cargo_type(value: str) -> str:
    label = (value or "").strip().lower()
    natural_aliases = {"natural", "plain", "raw", "paper", "box_natural", "ben_se"}
    colored_aliases = {"colored", "colour", "color", "colorful", "box_colored", "cai_se"}
    if label in natural_aliases:
        return CARGO_NATURAL
    if label in colored_aliases:
        return CARGO_COLORED
    return label or CARGO_NATURAL


@dataclass
class Cargo:
    cargo_id: str
    cargo_type: str
    pose: Dict[str, float] = field(default_factory=make_pose_dict)
    size: Dict[str, float] = field(default_factory=lambda: {"x": 0.12, "y": 0.12, "z": 0.10})
    confidence: float = 1.0
    bbox: Dict[str, int] = field(
        default_factory=lambda: {"x": 0, "y": 0, "width": 0, "height": 0}
    )

    def __post_init__(self) -> None:
        self.cargo_type = normalize_cargo_type(self.cargo_type)

    @property
    def volume(self) -> float:
        return float(self.size.get("x", 0.0) * self.size.get("y", 0.0) * self.size.get("z", 0.0))

    def destination_zone(self, mapping: Dict[str, str]) -> str:
        return mapping.get(self.cargo_type, mapping.get("default", "zone_b"))


@dataclass
class Task:
    task_id: str
    total_items: int
    status: str = TASK_PENDING
    completed_items: int = 0
    failed_items: int = 0
    sorted_counts: Dict[str, int] = field(
        default_factory=lambda: {CARGO_NATURAL: 0, CARGO_COLORED: 0}
    )
    start_time: Optional[float] = None
    end_time: Optional[float] = None
    error_log: List[str] = field(default_factory=list)

    def start(self) -> None:
        self.status = TASK_RUNNING
        self.start_time = self.start_time or now()
        self.end_time = None

    def pause(self) -> None:
        if self.status == TASK_RUNNING:
            self.status = TASK_PAUSED

    def resume(self) -> None:
        if self.status == TASK_PAUSED:
            self.status = TASK_RUNNING

    def complete(self) -> None:
        self.status = TASK_COMPLETED
        self.end_time = now()

    def fail(self, message: str) -> None:
        self.status = TASK_ERROR
        self.end_time = now()
        self.log_error(message)

    def log_error(self, message: str) -> None:
        if message:
            self.error_log.append(message)

    def record_success(self, cargo_type: str) -> None:
        cargo_type = normalize_cargo_type(cargo_type)
        self.completed_items += 1
        self.sorted_counts[cargo_type] = self.sorted_counts.get(cargo_type, 0) + 1

    def record_failure(self, message: str) -> None:
        self.failed_items += 1
        self.log_error(message)

    def progress(self) -> float:
        if self.total_items <= 0:
            return 1.0
        return min(1.0, float(self.completed_items) / float(self.total_items))

    def duration(self) -> float:
        if not self.start_time:
            return 0.0
        return (self.end_time or now()) - self.start_time

    def last_error(self) -> str:
        return self.error_log[-1] if self.error_log else ""

    def to_status_dict(self, queue_size: int = 0, current_step: str = "") -> Dict[str, Any]:
        return {
            "task_id": self.task_id,
            "status": self.status,
            "total_items": self.total_items,
            "completed_items": self.completed_items,
            "failed_items": self.failed_items,
            "sorted_natural": self.sorted_counts.get(CARGO_NATURAL, 0),
            "sorted_colored": self.sorted_counts.get(CARGO_COLORED, 0),
            "progress": self.progress(),
            "queue_size": queue_size,
            "current_step": current_step,
            "last_error": self.last_error(),
        }


class TaskQueue:
    def __init__(self) -> None:
        self._queue: List[Task] = []
        self.current_task: Optional[Task] = None
        self.completed_tasks: List[Task] = []

    def enqueue(self, task: Task) -> None:
        self._queue.append(task)

    def dequeue(self) -> Optional[Task]:
        if not self._queue:
            self.current_task = None
            return None
        self.current_task = self._queue.pop(0)
        return self.current_task

    def archive_current(self) -> None:
        if self.current_task:
            self.completed_tasks.append(self.current_task)
            self.current_task = None

    def has_next(self) -> bool:
        return bool(self._queue)

    def queue_size(self) -> int:
        return len(self._queue)


@dataclass
class PalletZone:
    zone_id: str
    origin: Dict[str, float]
    rows: int = 2
    cols: int = 2
    layers: int = 2
    spacing_x: float = 0.16
    spacing_y: float = 0.16
    layer_height: float = 0.12
    occupied: List[bool] = field(default_factory=list)

    def __post_init__(self) -> None:
        capacity = self.capacity
        if not self.occupied:
            self.occupied = [False] * capacity
        if len(self.occupied) != capacity:
            raise ValueError("occupied size must match pallet capacity")

    @property
    def capacity(self) -> int:
        return int(self.rows * self.cols * self.layers)

    def occupied_count(self) -> int:
        return sum(1 for item in self.occupied if item)

    def preview_next_pose(self) -> Tuple[int, Dict[str, float]]:
        try:
            index = self.occupied.index(False)
        except ValueError as exc:
            raise RuntimeError(f"pallet zone {self.zone_id} is full") from exc
        return index, self.pose_for_index(index)

    def mark_occupied(self, index: int) -> None:
        if index < 0 or index >= self.capacity:
            raise IndexError("pallet index out of range")
        self.occupied[index] = True

    def pose_for_index(self, index: int) -> Dict[str, float]:
        per_layer = self.rows * self.cols
        layer = index // per_layer
        offset = index % per_layer
        row = offset // self.cols
        col = offset % self.cols
        return make_pose_dict(
            x=float(self.origin.get("x", 0.0)) + col * self.spacing_x,
            y=float(self.origin.get("y", 0.0)) + row * self.spacing_y,
            z=float(self.origin.get("z", 0.0)) + layer * self.layer_height,
            qx=float(self.origin.get("qx", 0.0)),
            qy=float(self.origin.get("qy", 0.0)),
            qz=float(self.origin.get("qz", 0.0)),
            qw=float(self.origin.get("qw", 1.0)),
        )


def build_pallet_zones(config: Dict[str, Dict[str, Any]]) -> Dict[str, PalletZone]:
    zones: Dict[str, PalletZone] = {}
    for zone_id, spec in config.items():
        zones[zone_id] = PalletZone(
            zone_id=zone_id,
            origin=dict(spec.get("origin", {})),
            rows=int(spec.get("rows", 2)),
            cols=int(spec.get("cols", 2)),
            layers=int(spec.get("layers", 2)),
            spacing_x=float(spec.get("spacing_x", 0.16)),
            spacing_y=float(spec.get("spacing_y", 0.16)),
            layer_height=float(spec.get("layer_height", 0.12)),
        )
    return zones


def parse_task_command(data: str) -> Dict[str, Any]:
    text = (data or "").strip()
    if not text:
        return {"command": ""}
    try:
        parsed = json.loads(text)
    except ValueError:
        return {"command": text.lower()}
    if isinstance(parsed, str):
        return {"command": parsed.lower()}
    if not isinstance(parsed, dict):
        return {"command": ""}
    command = str(parsed.get("command", parsed.get("cmd", ""))).lower()
    parsed["command"] = command
    return parsed


def cycle_items(items: Iterable[Cargo], limit: int) -> List[Cargo]:
    source = list(items)
    if limit <= 0 or not source:
        return []
    output: List[Cargo] = []
    index = 0
    while len(output) < limit:
        original = source[index % len(source)]
        output.append(
            Cargo(
                cargo_id=f"{original.cargo_id}-{len(output) + 1:03d}",
                cargo_type=original.cargo_type,
                pose=dict(original.pose),
                size=dict(original.size),
                confidence=original.confidence,
                bbox=dict(original.bbox),
            )
        )
        index += 1
    return output
