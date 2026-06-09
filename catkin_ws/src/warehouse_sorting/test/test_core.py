import unittest

from warehouse_sorting.core import (
    CARGO_COLORED,
    CARGO_NATURAL,
    Cargo,
    PalletZone,
    Task,
    TaskQueue,
    cycle_items,
    parse_task_command,
)


class CoreModelTest(unittest.TestCase):
    def test_task_progress_and_counts(self):
        task = Task(task_id="TASK-001", total_items=2)
        task.start()
        task.record_success(CARGO_NATURAL)
        self.assertEqual(task.completed_items, 1)
        self.assertAlmostEqual(task.progress(), 0.5)
        task.record_success(CARGO_COLORED)
        task.complete()
        status = task.to_status_dict()
        self.assertEqual(status["sorted_natural"], 1)
        self.assertEqual(status["sorted_colored"], 1)
        self.assertEqual(status["status"], "COMPLETED")

    def test_task_queue_fifo(self):
        queue = TaskQueue()
        first = Task(task_id="A", total_items=1)
        second = Task(task_id="B", total_items=1)
        queue.enqueue(first)
        queue.enqueue(second)
        self.assertEqual(queue.dequeue().task_id, "A")
        queue.archive_current()
        self.assertEqual(queue.dequeue().task_id, "B")

    def test_pallet_zone_layers(self):
        zone = PalletZone(
            zone_id="zone_b",
            origin={"x": 1.0, "y": 2.0, "z": 0.05},
            rows=2,
            cols=2,
            layers=2,
            spacing_x=0.1,
            spacing_y=0.2,
            layer_height=0.3,
        )
        for _ in range(4):
            index, _pose = zone.preview_next_pose()
            zone.mark_occupied(index)
        index, pose = zone.preview_next_pose()
        self.assertEqual(index, 4)
        self.assertAlmostEqual(pose["z"], 0.35)

    def test_parse_command_plain_and_json(self):
        self.assertEqual(parse_task_command("pause")["command"], "pause")
        parsed = parse_task_command('{"command":"start","total_items":4}')
        self.assertEqual(parsed["command"], "start")
        self.assertEqual(parsed["total_items"], 4)

    def test_cycle_items_extends_batch(self):
        items = [Cargo(cargo_id="one", cargo_type=CARGO_NATURAL)]
        cycled = cycle_items(items, 3)
        self.assertEqual(len(cycled), 3)
        self.assertEqual(cycled[2].cargo_type, CARGO_NATURAL)


if __name__ == "__main__":
    unittest.main()
