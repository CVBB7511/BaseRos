import unittest

from warehouse_sorting.arm_sequences import TabletopArmPlanner


class TabletopArmPlannerTest(unittest.TestCase):
    def test_pick_sequence_keeps_object_on_tabletop_path(self):
        planner = TabletopArmPlanner(
            {
                "workspace": {
                    "min_x": 0.2,
                    "max_x": 1.0,
                    "min_y": -0.4,
                    "max_y": 0.4,
                    "min_z": 0.0,
                    "max_z": 0.8,
                },
                "lift": {"carry": 0.5, "pregrasp_offset": 0.08, "retreat_offset": 0.03},
            }
        )

        steps = planner.plan("pick", {"x": 0.45, "y": 0.10, "z": 0.05})

        self.assertEqual([step.label for step in steps], ["pregrasp", "lower", "close", "carry"])
        self.assertAlmostEqual(steps[1].lift, 0.05)
        self.assertAlmostEqual(steps[-1].lift, 0.5)
        self.assertLess(steps[-1].gripper, steps[0].gripper)

    def test_rejects_target_outside_tabletop_workspace(self):
        planner = TabletopArmPlanner({"workspace": {"min_x": 0.2, "max_x": 0.8}})

        with self.assertRaisesRegex(ValueError, "outside"):
            planner.plan("place", {"x": 1.2, "y": 0.0, "z": 0.05})


if __name__ == "__main__":
    unittest.main()
