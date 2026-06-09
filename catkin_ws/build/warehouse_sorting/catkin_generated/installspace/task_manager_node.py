#!/usr/bin/env python3

import threading

import rospy
from std_msgs.msg import String

from warehouse_sorting.core import (
    CARGO_COLORED,
    CARGO_NATURAL,
    TASK_COMPLETED,
    TASK_ERROR,
    TASK_PAUSED,
    TASK_PENDING,
    TASK_RUNNING,
    Cargo,
    Task,
    TaskQueue,
    build_pallet_zones,
    make_pose_dict,
    parse_task_command,
)
from warehouse_sorting.ros_conversions import (
    cargo_to_msg,
    msg_to_cargo,
    pose_dict_to_msg,
    status_dict_to_msg,
)
from warehouse_sorting_msgs.msg import TaskStatus
from warehouse_sorting_msgs.srv import ArmCommand, ScanRequest


class TaskManagerNode:
    def __init__(self):
        self.queue = TaskQueue()
        self.current_step = "idle"
        self.last_status_snapshot = None
        self.paused = False
        self.stop_requested = False
        self.worker = None

        self.max_retries = int(rospy.get_param("~max_retries", 3))
        self.default_total_items = int(rospy.get_param("~default_total_items", 4))
        self.dry_run_navigation = bool(rospy.get_param("~dry_run_navigation", True))
        self.source_zone_id = str(rospy.get_param("~source_zone_id", "source_a"))
        self.destinations = rospy.get_param(
            "/warehouse_sorting/destinations",
            {CARGO_NATURAL: "zone_b", CARGO_COLORED: "zone_c", "default": "zone_b"},
        )
        self.pallet_zones = build_pallet_zones(
            rospy.get_param("/warehouse_sorting/pallet_zones", self._default_pallet_config())
        )
        self.navigation_goals = rospy.get_param("/warehouse_sorting/navigation_goals", {})

        self.status_pub = rospy.Publisher("/task/status", TaskStatus, queue_size=10, latch=True)
        rospy.Subscriber("/task/command", String, self.handle_command, queue_size=10)
        rospy.Timer(rospy.Duration(1.0), lambda _event: self.publish_status())
        self.publish_status()
        rospy.loginfo("task_manager ready, dry_run_navigation=%s", self.dry_run_navigation)

    def handle_command(self, msg):
        command = parse_task_command(msg.data)
        name = command.get("command", "")
        if name == "start":
            self.start_task(command)
        elif name == "pause":
            self.pause_task()
        elif name == "resume":
            self.resume_task()
        elif name in ("stop", "cancel"):
            self.stop_task()
        elif name == "emergency_stop":
            self.emergency_stop()
        else:
            rospy.logwarn("unknown task command: %s", msg.data)

    def start_task(self, command):
        if self.worker and self.worker.is_alive():
            rospy.logwarn("task already running")
            return
        total_items = int(command.get("total_items", self.default_total_items))
        task_id = str(command.get("task_id", "TASK-%d" % int(rospy.Time.now().to_sec())))
        self.queue.enqueue(Task(task_id=task_id, total_items=total_items))
        self.paused = False
        self.stop_requested = False
        self.worker = threading.Thread(target=self._run_queue)
        self.worker.daemon = True
        self.worker.start()

    def pause_task(self):
        self.paused = True
        if self.queue.current_task:
            self.queue.current_task.pause()
        self.current_step = "paused"
        self.publish_status()

    def resume_task(self):
        self.paused = False
        if self.queue.current_task:
            self.queue.current_task.resume()
        self.current_step = "running"
        self.publish_status()

    def stop_task(self):
        self.stop_requested = True
        if self.queue.current_task:
            self.queue.current_task.complete()
        self.current_step = "stopping"
        self.publish_status()

    def emergency_stop(self):
        self.stop_requested = True
        self._call_arm("/arm/emergency_stop", None, make_pose_dict(), "emergency_stop")
        if self.queue.current_task:
            self.queue.current_task.fail("operator requested emergency stop")
        self.current_step = "emergency_stop"
        self.publish_status()

    def _run_queue(self):
        while self.queue.has_next() and not rospy.is_shutdown():
            task = self.queue.dequeue()
            if not task:
                return
            task.start()
            self.current_step = "scanning"
            self.publish_status()
            try:
                self._run_task(task)
                if task.status not in (TASK_ERROR, TASK_COMPLETED):
                    task.complete()
            except Exception as exc:
                rospy.logerr("task failed: %s", exc)
                task.fail(str(exc))
            finally:
                self.publish_status()
                if task:
                    self.last_status_snapshot = task.to_status_dict(
                        self.queue.queue_size(), "idle"
                    )
                self.queue.archive_current()
                self.current_step = "idle"
                self.publish_status()

    def _run_task(self, task):
        for item_number in range(task.total_items):
            if self.stop_requested or rospy.is_shutdown():
                task.complete()
                return
            self._wait_if_paused(task)
            if not self._handle_next_cargo(task, item_number):
                if task.failed_items + task.completed_items >= task.total_items:
                    break
            self.publish_status()
        if task.failed_items and not task.completed_items:
            task.fail("all cargo actions failed")

    def _handle_next_cargo(self, task, item_number):
        cargo = None
        last_error = ""
        for attempt in range(1, self.max_retries + 1):
            self._wait_if_paused(task)
            self.current_step = "moving to source for item %d attempt %d" % (
                item_number + 1,
                attempt,
            )
            self.publish_status()
            if not self._navigate(self.source_zone_id):
                last_error = "navigation failed for %s attempt %d" % (
                    self.source_zone_id,
                    attempt,
                )
                task.log_error(last_error)
                continue

            self._wait_if_paused(task)
            self.current_step = "scanning source for item %d attempt %d" % (
                item_number + 1,
                attempt,
            )
            self.publish_status()
            detections = self._scan()
            if not detections:
                last_error = "no cargo detected at source attempt %d" % attempt
                task.log_error(last_error)
                continue

            cargo = self._select_detection(detections, item_number)
            self.current_step = "picking %s attempt %d" % (cargo.cargo_id, attempt)
            self.publish_status()
            if self._call_arm("/arm/execute_pick", cargo, cargo.pose, "pick"):
                break
            last_error = "pick failed for %s attempt %d" % (cargo.cargo_id, attempt)
            task.log_error(last_error)
            cargo = None

        if cargo is None:
            task.record_failure("max pick retries exceeded for item %d; last error: %s" % (item_number + 1, last_error))
            return False

        zone_id = cargo.destination_zone(self.destinations)
        zone = self.pallet_zones.get(zone_id)
        if zone is None:
            task.record_failure("unknown destination zone %s" % zone_id)
            return False

        for attempt in range(1, self.max_retries + 1):
            self._wait_if_paused(task)
            self.current_step = "moving to %s for %s attempt %d" % (
                zone_id,
                cargo.cargo_id,
                attempt,
            )
            self.publish_status()
            if not self._navigate(zone_id):
                last_error = "navigation failed for %s attempt %d" % (zone_id, attempt)
                task.log_error(last_error)
                continue

            try:
                pallet_index, target_pose = zone.preview_next_pose()
            except RuntimeError as exc:
                task.record_failure(str(exc))
                return False

            self.current_step = "placing %s at %s[%d]" % (cargo.cargo_id, zone_id, pallet_index)
            self.publish_status()
            if self._call_arm("/arm/execute_place", cargo, target_pose, "place"):
                zone.mark_occupied(pallet_index)
                task.record_success(cargo.cargo_type)
                return True
            last_error = "place failed for %s attempt %d" % (cargo.cargo_id, attempt)
            task.log_error(last_error)

        task.record_failure("max place retries exceeded for %s; last error: %s" % (cargo.cargo_id, last_error))
        return False

    @staticmethod
    def _select_detection(detections, item_number):
        original = detections[item_number % len(detections)]
        return Cargo(
            cargo_id="%s-run-%03d" % (original.cargo_id, item_number + 1),
            cargo_type=original.cargo_type,
            pose=dict(original.pose),
            size=dict(original.size),
            confidence=original.confidence,
            bbox=dict(original.bbox),
        )

    def _wait_if_paused(self, task):
        while self.paused and not self.stop_requested and not rospy.is_shutdown():
            task.pause()
            self.publish_status()
            rospy.sleep(0.2)
        if task.status == TASK_PAUSED:
            task.resume()

    def _scan(self):
        rospy.wait_for_service("/vision/scan_request", timeout=5.0)
        service = rospy.ServiceProxy("/vision/scan_request", ScanRequest)
        response = service(True)
        if not response.success:
            raise RuntimeError(response.message)
        return [msg_to_cargo(item) for item in response.detections.objects]

    def _call_arm(self, service_name, cargo, target_pose, action):
        rospy.wait_for_service(service_name, timeout=5.0)
        service = rospy.ServiceProxy(service_name, ArmCommand)
        cargo_msg = cargo_to_msg(cargo) if cargo else cargo_to_msg(self._empty_cargo())
        response = service(cargo_msg, pose_dict_to_msg(target_pose), action)
        if not response.success:
            rospy.logwarn("%s failed: %s", service_name, response.message)
        return bool(response.success)

    def _navigate(self, zone_id):
        if self.dry_run_navigation:
            rospy.sleep(0.1)
            return True
        try:
            import actionlib
            from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
        except ImportError as exc:
            rospy.logwarn("move_base unavailable: %s", exc)
            return False

        goal_spec = self.navigation_goals.get(zone_id)
        if not goal_spec:
            rospy.logwarn("missing navigation goal for %s", zone_id)
            return False
        client = actionlib.SimpleActionClient("move_base", MoveBaseAction)
        if not client.wait_for_server(rospy.Duration(5.0)):
            rospy.logwarn("move_base action server unavailable")
            return False
        goal = MoveBaseGoal()
        goal.target_pose.header.frame_id = goal_spec.get("frame_id", "map")
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.pose = pose_dict_to_msg(goal_spec)
        client.send_goal(goal)
        finished = client.wait_for_result(rospy.Duration(float(goal_spec.get("timeout", 30.0))))
        if not finished:
            client.cancel_goal()
            return False
        return client.get_state() == 3

    def publish_status(self):
        task = self.queue.current_task
        if task:
            status = task.to_status_dict(self.queue.queue_size(), self.current_step)
        elif self.last_status_snapshot:
            status = dict(self.last_status_snapshot)
            status["queue_size"] = self.queue.queue_size()
            status["current_step"] = self.current_step
        else:
            status = {
                "task_id": "",
                "status": TASK_PENDING,
                "total_items": 0,
                "completed_items": 0,
                "failed_items": 0,
                "sorted_natural": 0,
                "sorted_colored": 0,
                "progress": 0.0,
                "queue_size": self.queue.queue_size(),
                "current_step": self.current_step,
                "last_error": "",
            }
        msg = status_dict_to_msg(status)
        msg.header.stamp = rospy.Time.now()
        self.status_pub.publish(msg)

    @staticmethod
    def _default_pallet_config():
        return {
            "zone_b": {
                "origin": {"x": 1.20, "y": 0.50, "z": 0.05},
                "rows": 2,
                "cols": 2,
                "layers": 2,
            },
            "zone_c": {
                "origin": {"x": 1.20, "y": -0.50, "z": 0.05},
                "rows": 2,
                "cols": 2,
                "layers": 2,
            },
        }

    @staticmethod
    def _empty_cargo():
        from warehouse_sorting.core import Cargo

        return Cargo(cargo_id="", cargo_type=CARGO_NATURAL)


if __name__ == "__main__":
    rospy.init_node("task_manager")
    TaskManagerNode()
    rospy.spin()
