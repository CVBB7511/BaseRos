#!/usr/bin/python3

import os
import json
import shutil
import signal
import subprocess
import math
import threading
from datetime import datetime, timezone
from pathlib import Path

import rospy
import tf
from geometry_msgs.msg import Twist
from mapping.srv import CalibrateTable, CalibrateTableResponse, Halt, HaltResponse, MapFile, MapFileResponse, OperationLog, OperationLogResponse, Start, StartResponse
from std_srvs.srv import Trigger, TriggerResponse
from palletizing.srv import MarkZone, StartTask


class FrontendControlServer:
    def __init__(self):
        self.root_dir = Path(rospy.get_param("~root_dir", "/home/yubowen/BaseRos")).resolve()
        self.workspace_dir = Path(rospy.get_param("~workspace_dir", str(self.root_dir / "catkin_ws"))).resolve()
        self.default_map_dir = Path(rospy.get_param("~default_map_dir", str(self.root_dir / "real_maps"))).resolve()
        self.operation_log_file = Path(rospy.get_param(
            "~operation_log_file",
            str(self.root_dir / "logs" / "frontend_operations.log"),
        )).resolve()
        self.operation_log_file.parent.mkdir(parents=True, exist_ok=True)
        self.operation_log_file.touch(exist_ok=True)
        self.operation_log_lock = threading.Lock()
        self.mapping_process = None
        self.execute_process = None
        self.tf_listener = tf.TransformListener()

        self.start_service = rospy.Service("/frontend/start_mapping", Start, self.start_mapping)
        self.stop_service = rospy.Service("/frontend/stop_mapping", Halt, self.stop_mapping)
        self.save_service = rospy.Service("/frontend/save_map", MapFile, self.save_map)
        self.import_service = rospy.Service("/frontend/import_map", MapFile, self.import_map)
        self.calibrate_service = rospy.Service("/frontend/calibrate_table", CalibrateTable, self.calibrate_table)
        self.palletizing_service = rospy.Service("/frontend/start_palletizing", Trigger, self.start_palletizing)
        self.stop_palletizing_service = rospy.Service("/frontend/stop_palletizing", Trigger, self.stop_palletizing)
        self.operation_log_service = rospy.Service(
            "/frontend/operation_logs", OperationLog, self.manage_operation_logs)
        self.status_service = rospy.Service("/frontend/status", Trigger, self.status)
        rospy.loginfo("Frontend control services are ready. Operation log: %s", self.operation_log_file)

    def start_mapping(self, req):
        launch_args = "start_gazebo:=false start_robot:=false" if req.sim else ""
        launch_file = "palletizing_mapping.launch" if req.sim else "palletizing_mapping_real.launch"
        command = [
            "bash",
            "-lc",
            (
                f"cd '{self.workspace_dir}' && "
                "source /opt/ros/noetic/setup.bash && "
                "source devel/setup.bash && "
                f"roslaunch gazebosim_demo {launch_file} {launch_args}"
            ),
        ]
        try:
            self._stop_mapping_process()
            self._stop_execute_process()
            self.mapping_process = subprocess.Popen(command, preexec_fn=os.setsid)
            mode = "仿真" if req.sim else "真机"
            return StartResponse(True, f"已重新启动{mode}建图与 RViz，未保存的旧建图进度已舍弃")
        except Exception as exc:
            rospy.logerr("Failed to start mapping: %s", exc)
            return StartResponse(False, f"启动建图失败: {exc}")

    def stop_mapping(self, req):
        self._stop_mapping_process()
        self._publish_stop()
        return HaltResponse(True, "建图流程已停止")

    def save_map(self, req):
        try:
            target_dir = self._resolve_directory(req.directory, create=True)
            name = self._safe_name(req.name or "real_map")
            target_prefix = target_dir / name
            command = [
                "bash",
                "-lc",
                (
                    "source /opt/ros/noetic/setup.bash && "
                    f"source '{self.workspace_dir}/devel/setup.bash' && "
                    f"rosrun map_server map_saver -f '{target_prefix}'"
                ),
            ]
            result = subprocess.run(command, cwd=str(self.workspace_dir), text=True, capture_output=True, timeout=30)
            if result.returncode != 0:
                message = (result.stderr or result.stdout or "map_saver failed").strip()
                return MapFileResponse(False, "", f"保存地图失败: {message}")

            yaml_path = target_prefix.with_suffix(".yaml")
            pgm_path = target_prefix.with_suffix(".pgm")
            self._normalize_yaml_image(yaml_path, pgm_path)
            self._stop_mapping_process()
            self._publish_stop()
            return MapFileResponse(True, str(yaml_path), f"地图已保存到 {yaml_path}，建图 RViz 已关闭")
        except Exception as exc:
            rospy.logerr("Failed to save map: %s", exc)
            return MapFileResponse(False, "", f"保存地图失败: {exc}")

    def import_map(self, req):
        try:
            source_dir = self._resolve_directory(req.directory, create=False)
            name = self._safe_name(req.name or "real_map")
            source_yaml = source_dir / f"{name}.yaml"
            source_pgm = source_dir / f"{name}.pgm"
            if not source_yaml.is_file() or not source_pgm.is_file():
                return MapFileResponse(False, "", f"未找到 {source_yaml} 和 {source_pgm}")

            target_dir = self.default_map_dir
            target_dir.mkdir(parents=True, exist_ok=True)
            target_yaml = target_dir / f"{name}.yaml"
            target_pgm = target_dir / f"{name}.pgm"
            if source_yaml.resolve() != target_yaml.resolve():
                shutil.copy2(source_yaml, target_yaml)
            if source_pgm.resolve() != target_pgm.resolve():
                shutil.copy2(source_pgm, target_pgm)
            self._normalize_yaml_image(target_yaml, target_pgm)
            started = self._start_execute(target_yaml, req.sim)
            message = f"地图已导入到 {target_yaml}"
            if started:
                message += "，已启动执行系统与 RViz；请在 RViz 中使用 2D Pose Estimate"
            return MapFileResponse(True, str(target_yaml), message)
        except Exception as exc:
            rospy.logerr("Failed to import map: %s", exc)
            return MapFileResponse(False, "", f"导入地图失败: {exc}")

    def start_palletizing(self, _req):
        try:
            rospy.wait_for_service("/palletizing/start", timeout=5.0)
            start = rospy.ServiceProxy("/palletizing/start", StartTask)
            resp = start()
            return TriggerResponse(resp.success, resp.message)
        except Exception as exc:
            rospy.logerr("Failed to start palletizing: %s", exc)
            return TriggerResponse(False, f"启动码垛失败: {exc}")

    def stop_palletizing(self, _req):
        try:
            rospy.wait_for_service("/palletizing/stop", timeout=5.0)
            stop = rospy.ServiceProxy("/palletizing/stop", Trigger)
            resp = stop()
            return TriggerResponse(resp.success, resp.message)
        except Exception as exc:
            rospy.logerr("Failed to stop palletizing: %s", exc)
            return TriggerResponse(False, f"终止码垛失败: {exc}")

    def manage_operation_logs(self, req):
        """Append, list, import, or clear project-persistent frontend logs."""
        try:
            action = req.action.strip().lower()
            with self.operation_log_lock:
                if action == "append":
                    entry = self._validated_log_entry({
                        "id": req.id,
                        "timestamp": req.timestamp,
                        "level": req.level,
                        "message": req.text,
                    })
                    with self.operation_log_file.open("a", encoding="utf-8") as stream:
                        stream.write(json.dumps(entry, ensure_ascii=False) + "\n")
                    return OperationLogResponse(True, "日志已保存")

                if action == "list":
                    entries = self._read_operation_logs()
                    return OperationLogResponse(
                        True, json.dumps(entries, ensure_ascii=False))

                if action == "import":
                    existing = self._read_operation_logs()
                    if existing:
                        return OperationLogResponse(True, "项目日志已有记录，未重复导入")
                    imported = json.loads(req.text or "[]")
                    if not isinstance(imported, list):
                        raise ValueError("导入日志必须是 JSON 数组")
                    entries = [self._validated_log_entry(item) for item in imported]
                    with self.operation_log_file.open("w", encoding="utf-8") as stream:
                        for entry in entries:
                            stream.write(json.dumps(entry, ensure_ascii=False) + "\n")
                    return OperationLogResponse(True, f"已导入 {len(entries)} 条日志")

                if action == "clear":
                    self.operation_log_file.write_text("", encoding="utf-8")
                    return OperationLogResponse(True, "执行日志已清空")

            return OperationLogResponse(False, f"不支持的日志操作: {req.action}")
        except Exception as exc:
            rospy.logerr("Failed to manage frontend operation logs: %s", exc)
            return OperationLogResponse(False, f"日志操作失败: {exc}")

    def _validated_log_entry(self, raw):
        if not isinstance(raw, dict):
            raise ValueError("日志条目格式无效")
        level = str(raw.get("level", "")).strip().lower()
        if level not in ("success", "error"):
            raise ValueError("日志级别必须是 success 或 error")
        message = str(raw.get("message", "")).strip()
        if not message:
            raise ValueError("日志内容不能为空")
        timestamp = str(raw.get("timestamp", "")).strip()
        if not timestamp:
            timestamp = datetime.now(timezone.utc).isoformat()
        entry_id = str(raw.get("id", "")).strip()
        if not entry_id:
            entry_id = timestamp
        return {
            "id": entry_id,
            "timestamp": timestamp,
            "level": level,
            "message": message,
        }

    def _read_operation_logs(self):
        entries = []
        with self.operation_log_file.open("r", encoding="utf-8") as stream:
            for line_number, line in enumerate(stream, 1):
                line = line.strip()
                if not line:
                    continue
                try:
                    entries.append(self._validated_log_entry(json.loads(line)))
                except Exception as exc:
                    rospy.logwarn("Skipping malformed operation log line %d: %s", line_number, exc)
        return entries

    def calibrate_table(self, req):
        try:
            zone_name = req.zone_name.strip().lower()
            if zone_name not in ("source", "dest"):
                return CalibrateTableResponse(False, "标定区域必须是 source 或 dest")

            length = req.length if req.length > 0 else 1.0
            width = req.width if req.width > 0 else 0.5
            height = req.height if req.height > 0 else 0.765
            distance = req.distance if req.distance > 0 else width / 2.0 + 0.70

            pose = self._get_robot_pose()
            if pose is None:
                return CalibrateTableResponse(False, "无法获取机器人位姿，请确认已完成 2D Pose Estimate 且 TF 正常")

            robot_x, robot_y, robot_yaw = pose
            table_x = robot_x + distance * math.cos(robot_yaw)
            table_y = robot_y + distance * math.sin(robot_yaw)
            table_yaw = self._normalize_angle(robot_yaw + math.pi)

            rospy.wait_for_service("/palletizing/mark_zone", timeout=5.0)
            mark = rospy.ServiceProxy("/palletizing/mark_zone", MarkZone)
            resp = mark(
                zone_name=zone_name,
                x=table_x,
                y=table_y,
                z=height,
                yaw=table_yaw,
                length=length,
                width=width,
            )
            if not resp.success:
                return CalibrateTableResponse(False, "标定保存失败，请检查 palletizing_executor 是否运行")

            label = "取货桌" if zone_name == "source" else "码垛桌"
            message = (
                f"{label}标定已保存: center=({table_x:.3f}, {table_y:.3f}, {height:.3f}), "
                f"yaw={table_yaw:.3f}, size={length:.2f}x{width:.2f}m"
            )
            return CalibrateTableResponse(True, message)
        except Exception as exc:
            rospy.logerr("Failed to calibrate table: %s", exc)
            return CalibrateTableResponse(False, f"标定失败: {exc}")

    def status(self, _req):
        running = self.mapping_process is not None and self.mapping_process.poll() is None
        execute_running = self.execute_process is not None and self.execute_process.poll() is None
        return TriggerResponse(True, f"mapping: {'running' if running else 'stopped'}, execute: {'running' if execute_running else 'stopped'}")

    def _start_execute(self, map_file, sim):
        self._stop_mapping_process()
        self._stop_execute_process()
        launch_file = "palletizing_execute.launch" if sim else "palletizing_execute_real.launch"
        launch_args = "start_gazebo:=false start_robot:=false" if sim else ""
        command = [
            "bash",
            "-lc",
            (
                f"cd '{self.workspace_dir}' && "
                "source /opt/ros/noetic/setup.bash && "
                "source devel/setup.bash && "
                f"roslaunch gazebosim_demo {launch_file} map_file:='{map_file}' {launch_args}"
            ),
        ]
        self.execute_process = subprocess.Popen(command, preexec_fn=os.setsid)
        return True

    def _stop_mapping_process(self):
        if not self.mapping_process or self.mapping_process.poll() is not None:
            return
        self._terminate_process(self.mapping_process)
        self.mapping_process = None

    def _stop_execute_process(self):
        if not self.execute_process or self.execute_process.poll() is not None:
            return
        self._terminate_process(self.execute_process)
        self.execute_process = None

    def _terminate_process(self, process):
        pgid = os.getpgid(process.pid)
        os.killpg(pgid, signal.SIGINT)
        try:
            process.wait(timeout=10)
            return
        except subprocess.TimeoutExpired:
            rospy.logwarn("Process did not exit after SIGINT; escalating to SIGTERM.")
        os.killpg(pgid, signal.SIGTERM)
        try:
            process.wait(timeout=5)
            return
        except subprocess.TimeoutExpired:
            rospy.logwarn("Process did not exit after SIGTERM; escalating to SIGKILL.")
        os.killpg(pgid, signal.SIGKILL)
        try:
            process.wait(timeout=3)
        except subprocess.TimeoutExpired:
            rospy.logwarn("Process still did not exit after SIGKILL; continuing cleanup.")

    def _publish_stop(self):
        publisher = rospy.Publisher("/cmd_vel", Twist, queue_size=1)
        rospy.sleep(0.2)
        publisher.publish(Twist())

    def _get_robot_pose(self):
        for child_frame in ("/base_link", "/base_footprint"):
            try:
                self.tf_listener.waitForTransform("/map", child_frame, rospy.Time(0), rospy.Duration(3.0))
                trans, rot = self.tf_listener.lookupTransform("/map", child_frame, rospy.Time(0))
                yaw = math.atan2(
                    2.0 * (rot[3] * rot[2] + rot[0] * rot[1]),
                    1.0 - 2.0 * (rot[1] ** 2 + rot[2] ** 2),
                )
                return trans[0], trans[1], yaw
            except (tf.LookupException, tf.ConnectivityException, tf.ExtrapolationException, tf.Exception):
                continue
        return None

    def _normalize_angle(self, yaw):
        return math.atan2(math.sin(yaw), math.cos(yaw))

    def _resolve_directory(self, directory, create):
        raw = (directory or str(self.default_map_dir)).strip()
        path = Path(os.path.expanduser(raw))
        if not path.is_absolute():
            path = self.root_dir / path
        path = path.resolve()
        if create:
            path.mkdir(parents=True, exist_ok=True)
        elif not path.is_dir():
            raise FileNotFoundError(path)
        return path

    def _safe_name(self, name):
        clean = Path(name.strip()).name
        if clean.endswith(".yaml") or clean.endswith(".pgm"):
            clean = Path(clean).stem
        if not clean:
            raise ValueError("地图名称不能为空")
        return clean

    def _normalize_yaml_image(self, yaml_path, pgm_path):
        if not yaml_path.is_file():
            return
        lines = yaml_path.read_text(encoding="utf-8").splitlines()
        updated = [f"image: {pgm_path.resolve()}" if line.startswith("image:") else line for line in lines]
        yaml_path.write_text("\n".join(updated) + "\n", encoding="utf-8")


if __name__ == "__main__":
    rospy.init_node("frontend_control_server")
    FrontendControlServer()
    rospy.spin()
