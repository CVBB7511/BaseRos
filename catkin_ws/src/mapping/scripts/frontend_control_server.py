#!/usr/bin/python3

import os
import json
import shutil
import signal
import subprocess
import math
import tempfile
import threading
import time
from datetime import datetime, timezone
from pathlib import Path

import rospy
import rosnode
import rosservice
import tf
import yaml
from gazebo_msgs.srv import GetModelState
from geometry_msgs.msg import Twist
from mapping.srv import CalibrateTable, CalibrateTableResponse, Environment, EnvironmentResponse, Halt, HaltResponse, MapFile, MapFileResponse, OperationLog, OperationLogResponse, RobotParameters, RobotParametersResponse, Start, StartResponse
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
        self.robot_config_file = Path(rospy.get_param(
            "~robot_config_file",
            str(self.workspace_dir / "src/wpb_home/wpb_home_bringup/config/wpb_home.yaml"),
        )).resolve()
        self.robot_defaults_file = Path(rospy.get_param(
            "~robot_defaults_file",
            str(self.workspace_dir / "src/wpb_home/wpb_home_bringup/config/wpb_home.defaults.yaml"),
        )).resolve()
        self.robot_config_lock = threading.Lock()
        self.simulation_model_name = rospy.get_param("~simulation_model_name", "wpb_home_mani")
        self.max_calibration_tf_age = rospy.get_param("~max_calibration_tf_age", 2.0)
        self.last_calibration_poses = {}
        self.mapping_process = None
        self.execute_process = None
        self.environment_process = None
        self.environment_mode = ""
        self.external_simulation = False
        self.process_lock = threading.RLock()
        self.tf_listener = tf.TransformListener()

        self.environment_service = rospy.Service(
            "/frontend/environment", Environment, self.manage_environment)
        self.robot_parameters_service = rospy.Service(
            "/frontend/robot_parameters", RobotParameters, self.manage_robot_parameters)
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
        rospy.on_shutdown(self.shutdown)
        rospy.loginfo("Frontend control services are ready. Operation log: %s", self.operation_log_file)

    def manage_environment(self, req):
        action = (req.action or "status").strip().lower()
        mode = (req.mode or self.environment_mode).strip().lower()
        try:
            with self.process_lock:
                if action == "status":
                    return self._environment_response()
                if action == "start":
                    if mode not in ("sim", "real"):
                        return EnvironmentResponse(False, "运行模式必须为 sim 或 real", "", "error")
                    return self._start_environment(mode)
                if action == "stop":
                    self._stop_workloads()
                    self._publish_stop()
                    self._stop_simulation()
                    previous_mode = self.environment_mode
                    self.environment_mode = ""
                    label = "仿真" if previous_mode == "sim" else "实机"
                    return EnvironmentResponse(True, f"{label}环境已停用", "", "stopped")
                return EnvironmentResponse(False, f"不支持的环境操作: {req.action}", mode, "error")
        except Exception as exc:
            rospy.logerr("Failed to manage environment: %s", exc)
            return EnvironmentResponse(False, f"运行环境操作失败: {exc}", mode, "error")

    def manage_robot_parameters(self, req):
        action = (req.action or "get").strip().lower()
        try:
            with self.robot_config_lock:
                if action == "get":
                    values = self._read_robot_parameters(self.robot_config_file)
                    return self._robot_parameters_response(True, "参数读取成功", values)
                if action not in ("save", "restore"):
                    return self._robot_parameters_response(False, f"不支持的参数操作: {req.action}")
                if self.environment_mode or self._workloads_running():
                    return self._robot_parameters_response(
                        False,
                        "请先停用仿真或断开实机，再修改机器人参数",
                    )
                if action == "restore":
                    values = self._read_robot_parameters(self.robot_defaults_file)
                    message = "已恢复默认配置，下一次启用实机或启动任务时生效"
                else:
                    values = {
                        "kinect_height": req.kinect_height,
                        "kinect_pitch": req.kinect_pitch,
                        "camera_x": req.camera_x,
                        "camera_y": req.camera_y,
                        "camera_z": req.camera_z,
                        "grab_y_offset": req.grab_y_offset,
                        "grab_lift_offset": req.grab_lift_offset,
                        "grab_forward_offset": req.grab_forward_offset,
                        "grab_gripper_value": req.grab_gripper_value,
                        "grab_hand_up_wait": req.grab_hand_up_wait,
                    }
                    self._validate_robot_parameters(values)
                    message = "机器人参数已保存，下一次启用实机或启动任务时生效"
                self._write_robot_parameters(values)
                return self._robot_parameters_response(True, message, values)
        except Exception as exc:
            rospy.logerr("Failed to manage robot parameters: %s", exc)
            return self._robot_parameters_response(False, f"机器人参数操作失败: {exc}")

    def _start_environment(self, mode):
        if mode == "sim":
            if self.environment_mode == "sim" and self._simulation_running():
                return EnvironmentResponse(True, "仿真环境已启用，正在复用现有 Gazebo", "sim", "running")

            self._stop_workloads()
            if self.environment_mode == "real":
                self._publish_stop()

            if self._gazebo_node_running() or self._gazebo_process_running():
                if not self._simulation_nodes_running():
                    rospy.logwarn("Incomplete Gazebo instance detected; cleaning it before restart.")
                    self._cleanup_gazebo_processes()
                    if self._gazebo_node_running():
                        return EnvironmentResponse(
                            False,
                            "旧 Gazebo 未能自动关闭，请执行 killall gzserver gzclient 后重试",
                            "sim",
                            "error",
                        )
                else:
                    self.environment_process = None
                    self.external_simulation = True
                    self.environment_mode = "sim"
                    return EnvironmentResponse(True, "检测到已运行的 Gazebo，已连接且不会重复启动", "sim", "running")

            command = [
                "bash",
                "-lc",
                (
                    f"cd '{self.workspace_dir}' && "
                    "export GAZEBO_MODEL_DATABASE_URI='' && "
                    f"export IGN_FUEL_CONFIG_PATH='{self.workspace_dir}/src/gazebosim_demo/config/ign_fuel_offline.yaml' && "
                    f"export GZ_FUEL_CONFIG_PATH='{self.workspace_dir}/src/gazebosim_demo/config/ign_fuel_offline.yaml' && "
                    "source /opt/ros/noetic/setup.bash && "
                    "source devel/setup.bash && "
                    "roslaunch gazebosim_demo palletizing_sim_world.launch"
                ),
            ]
            self.environment_process = subprocess.Popen(command, preexec_fn=os.setsid)
            self.external_simulation = False
            if not self._wait_for_gazebo(timeout=20.0):
                self._stop_simulation()
                return EnvironmentResponse(False, "Gazebo 启动超时，请查看 Frontend Control Services 终端", "sim", "error")
            self.environment_mode = "sim"
            return EnvironmentResponse(True, "仿真环境已启用，Gazebo 将在建图和码垛期间保持运行", "sim", "running")

        self._stop_workloads()
        self._publish_stop()
        self._stop_simulation()
        required_devices = (Path("/dev/ftdi"), Path("/dev/rplidar"))
        missing = [str(device) for device in required_devices if not device.exists()]
        if missing:
            self.environment_mode = ""
            return EnvironmentResponse(
                False,
                f"实机连接失败，未找到设备: {', '.join(missing)}",
                "real",
                "error",
            )
        self.environment_mode = "real"
        return EnvironmentResponse(True, "实机设备检查通过，可开始建图或导入地图", "real", "running")

    def _environment_response(self):
        if self.environment_mode == "sim" and not self._simulation_running():
            self.environment_mode = ""
            return EnvironmentResponse(False, "Gazebo 未运行", "sim", "stopped")
        if self.environment_mode:
            return EnvironmentResponse(True, "运行环境已启用", self.environment_mode, "running")
        return EnvironmentResponse(True, "尚未启用运行环境", "", "stopped")

    def start_mapping(self, req):
        environment_error = self._validate_environment(req.sim)
        if environment_error:
            return StartResponse(False, environment_error)
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
            environment_error = self._validate_environment(req.sim)
            if environment_error:
                return MapFileResponse(False, "", environment_error)
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
            height = req.height if req.height > 0 else 0.75
            distance = req.distance if req.distance > 0 else width / 2.0 + 0.70

            pose_source = "Gazebo" if self.environment_mode == "sim" else "AMCL/TF"
            pose = self._get_gazebo_robot_pose() if self.environment_mode == "sim" else self._get_robot_pose()
            if pose is None:
                if self.environment_mode == "sim":
                    return CalibrateTableResponse(False, "无法获取 Gazebo 机器人位姿，请确认仿真机器人已经生成")
                return CalibrateTableResponse(False, "无法获取机器人位姿，请确认已完成 2D Pose Estimate 且 TF 正常")

            robot_x, robot_y, robot_yaw = pose
            other_zone = "dest" if zone_name == "source" else "source"
            other_pose = self.last_calibration_poses.get(other_zone)
            if other_pose is not None:
                position_delta = math.hypot(robot_x - other_pose[0], robot_y - other_pose[1])
                yaw_delta = abs(self._normalize_angle(robot_yaw - other_pose[2]))
                if position_delta < 0.05 and yaw_delta < math.radians(5.0):
                    return CalibrateTableResponse(
                        False,
                        "当前机器人位姿与另一张桌的标定位姿相同，请确认机器人已移动或转向且定位已更新",
                    )
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
            self.last_calibration_poses[zone_name] = pose

            label = "取货桌" if zone_name == "source" else "码垛桌"
            message = (
                f"{label}标定已保存（位姿来源: {pose_source}）: "
                f"robot=({robot_x:.3f}, {robot_y:.3f}, {robot_yaw:.3f}), "
                f"center=({table_x:.3f}, {table_y:.3f}, {height:.3f}), "
                f"yaw={table_yaw:.3f}, size={length:.2f}x{width:.2f}m"
            )
            return CalibrateTableResponse(True, message)
        except Exception as exc:
            rospy.logerr("Failed to calibrate table: %s", exc)
            return CalibrateTableResponse(False, f"标定失败: {exc}")

    def status(self, _req):
        running = self.mapping_process is not None and self.mapping_process.poll() is None
        execute_running = self.execute_process is not None and self.execute_process.poll() is None
        environment = self.environment_mode or "none"
        return TriggerResponse(True, f"environment: {environment}, mapping: {'running' if running else 'stopped'}, execute: {'running' if execute_running else 'stopped'}")

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

    def _validate_environment(self, sim):
        requested_mode = "sim" if sim else "real"
        if not self.environment_mode:
            return "请先在前端启用仿真或连接实机"
        if self.environment_mode != requested_mode:
            label = "仿真" if requested_mode == "sim" else "实机"
            return f"当前运行环境与操作模式不一致，请先启用{label}"
        if sim and not self._simulation_running():
            self.environment_mode = ""
            return "Gazebo 已停止，请重新启用仿真"
        return ""

    def _stop_workloads(self):
        self._stop_mapping_process()
        self._stop_execute_process()

    def _workloads_running(self):
        mapping_running = self.mapping_process is not None and self.mapping_process.poll() is None
        execute_running = self.execute_process is not None and self.execute_process.poll() is None
        return mapping_running or execute_running

    def _gazebo_node_running(self):
        try:
            return rosnode.rosnode_ping("/gazebo", max_count=1, verbose=False)
        except Exception:
            return False

    def _gazebo_process_running(self):
        return subprocess.run(
            ["pgrep", "-x", "gzserver"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=False,
        ).returncode == 0

    def _simulation_nodes_running(self):
        try:
            return (
                rosnode.rosnode_ping("/gazebo", max_count=1, verbose=False)
                and rosnode.rosnode_ping("/wpb_home_sim", max_count=1, verbose=False)
            )
        except Exception:
            return False

    def _simulation_ready(self):
        try:
            return (
                self._simulation_nodes_running()
                and "/wpb_home/controller_manager/list_controllers" in rosservice.get_service_list()
            )
        except Exception:
            return False

    def _simulation_running(self):
        if self.environment_process is not None and self.environment_process.poll() is not None:
            return False
        return (self.environment_process is not None or self.external_simulation) and self._simulation_nodes_running()

    def _wait_for_gazebo(self, timeout):
        deadline = time.monotonic() + timeout
        while not rospy.is_shutdown() and time.monotonic() < deadline:
            if self.environment_process is not None and self.environment_process.poll() is not None:
                return False
            if self._simulation_ready():
                return True
            time.sleep(0.5)
        return False

    def _stop_simulation(self):
        should_cleanup = (
            self.environment_process is not None
            or self.external_simulation
            or self._gazebo_node_running()
            or self._gazebo_process_running()
        )
        if self.environment_process is not None and self.environment_process.poll() is None:
            self._terminate_process(self.environment_process)
        self.environment_process = None
        self.external_simulation = False
        if should_cleanup:
            self._cleanup_gazebo_processes()

    def _cleanup_gazebo_processes(self):
        try:
            nodes = set(rosnode.get_node_names())
            managed_nodes = [
                name for name in (
                    "/gazebo",
                    "/gazebo_gui",
                    "/wpb_home_sim",
                    "/gazebo_wpb_home_state_publisher",
                    "/wpb_home/controller_spawner",
                    "/spawn_urdf",
                ) if name in nodes
            ]
            if managed_nodes:
                rosnode.kill_nodes(managed_nodes)
        except Exception as exc:
            rospy.logwarn("Failed to stop all Gazebo ROS nodes cleanly: %s", exc)

        subprocess.run(
            ["pkill", "-TERM", "-f", "[r]oslaunch gazebosim_demo palletizing_sim_world.launch"],
            check=False,
        )
        for process_name in ("gzclient", "gzserver"):
            subprocess.run(["pkill", "-TERM", "-x", process_name], check=False)
        time.sleep(1.0)
        for process_name in ("gzclient", "gzserver"):
            subprocess.run(["pkill", "-KILL", "-x", process_name], check=False)
        deadline = time.monotonic() + 3.0
        while time.monotonic() < deadline and (
            self._gazebo_node_running() or self._gazebo_process_running()
        ):
            time.sleep(0.2)

    def _read_robot_parameters(self, path):
        if not path.is_file():
            raise FileNotFoundError(path)
        with path.open("r", encoding="utf-8") as stream:
            data = yaml.safe_load(stream) or {}
        try:
            values = {
                "kinect_height": float(data["zeros"]["kinect_height"]),
                "kinect_pitch": float(data["zeros"]["kinect_pitch"]),
                "camera_x": float(data["camera_mount"]["x"]),
                "camera_y": float(data["camera_mount"]["y"]),
                "camera_z": float(data["camera_mount"]["z"]),
                "grab_y_offset": float(data["grab"]["grab_y_offset"]),
                "grab_lift_offset": float(data["grab"]["grab_lift_offset"]),
                "grab_forward_offset": float(data["grab"]["grab_forward_offset"]),
                "grab_gripper_value": float(data["grab"]["grab_gripper_value"]),
                "grab_hand_up_wait": float(data["grab"]["grab_hand_up_wait"]),
            }
        except (KeyError, TypeError, ValueError) as exc:
            raise ValueError(f"配置文件字段缺失或格式错误: {path}") from exc
        self._validate_robot_parameters(values)
        return values

    def _validate_robot_parameters(self, values):
        limits = {
            "kinect_height": (0.0, 1.7),
            "kinect_pitch": (-1.57, 1.57),
            "camera_x": (-2.0, 2.0),
            "camera_y": (-2.0, 2.0),
            "camera_z": (-2.0, 2.0),
            "grab_y_offset": (-1.0, 1.0),
            "grab_lift_offset": (-1.0, 1.0),
            "grab_forward_offset": (-1.0, 1.0),
            "grab_gripper_value": (0.0, 0.2),
            "grab_hand_up_wait": (0.0, 60.0),
        }
        for name, (minimum, maximum) in limits.items():
            value = float(values[name])
            if not math.isfinite(value) or value < minimum or value > maximum:
                raise ValueError(f"{name} 必须在 {minimum} 到 {maximum} 之间")

    def _write_robot_parameters(self, values):
        self._validate_robot_parameters(values)
        data = {}
        if self.robot_config_file.is_file():
            with self.robot_config_file.open("r", encoding="utf-8") as stream:
                data = yaml.safe_load(stream) or {}
            shutil.copy2(self.robot_config_file, self.robot_config_file.with_suffix(".yaml.bak"))
        data.setdefault("zeros", {})
        data.setdefault("camera_mount", {})
        data.setdefault("grab", {})
        data["zeros"].update({
            "kinect_height": values["kinect_height"],
            "kinect_pitch": values["kinect_pitch"],
        })
        data["camera_mount"].update({
            "x": values["camera_x"],
            "y": values["camera_y"],
            "z": values["camera_z"],
        })
        data["grab"].update({
            "grab_y_offset": values["grab_y_offset"],
            "grab_lift_offset": values["grab_lift_offset"],
            "grab_forward_offset": values["grab_forward_offset"],
            "grab_gripper_value": values["grab_gripper_value"],
            "grab_hand_up_wait": values["grab_hand_up_wait"],
        })
        fd, temporary_name = tempfile.mkstemp(
            prefix=f".{self.robot_config_file.name}.",
            dir=str(self.robot_config_file.parent),
            text=True,
        )
        try:
            with os.fdopen(fd, "w", encoding="utf-8") as stream:
                yaml.safe_dump(data, stream, allow_unicode=True, sort_keys=False)
                stream.flush()
                os.fsync(stream.fileno())
            os.replace(temporary_name, self.robot_config_file)
        finally:
            if os.path.exists(temporary_name):
                os.unlink(temporary_name)

    def _robot_parameters_response(self, success, message, values=None):
        values = values or {name: 0.0 for name in (
            "kinect_height", "kinect_pitch", "camera_x", "camera_y", "camera_z",
            "grab_y_offset", "grab_lift_offset", "grab_forward_offset",
            "grab_gripper_value", "grab_hand_up_wait",
        )}
        return RobotParametersResponse(success=success, message=message, **values)

    def shutdown(self):
        with self.process_lock:
            self._stop_workloads()
            self._stop_simulation()

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
        time.sleep(0.2)
        publisher.publish(Twist())

    def _get_robot_pose(self):
        for child_frame in ("/base_link", "/base_footprint"):
            try:
                self.tf_listener.waitForTransform("/map", child_frame, rospy.Time(0), rospy.Duration(3.0))
                latest_time = self.tf_listener.getLatestCommonTime("/map", child_frame)
                transform_age = (rospy.Time.now() - latest_time).to_sec()
                if transform_age > self.max_calibration_tf_age:
                    rospy.logwarn(
                        "Ignoring stale calibration TF map -> %s (age %.2fs)",
                        child_frame,
                        transform_age,
                    )
                    continue
                trans, rot = self.tf_listener.lookupTransform("/map", child_frame, rospy.Time(0))
                yaw = math.atan2(
                    2.0 * (rot[3] * rot[2] + rot[0] * rot[1]),
                    1.0 - 2.0 * (rot[1] ** 2 + rot[2] ** 2),
                )
                return trans[0], trans[1], yaw
            except (tf.LookupException, tf.ConnectivityException, tf.ExtrapolationException, tf.Exception):
                continue
        return None

    def _get_gazebo_robot_pose(self):
        try:
            rospy.wait_for_service("/gazebo/get_model_state", timeout=3.0)
            get_model_state = rospy.ServiceProxy("/gazebo/get_model_state", GetModelState)
            state = get_model_state(self.simulation_model_name, "world")
            if not state.success:
                rospy.logwarn(
                    "Failed to get Gazebo model state for %s: %s",
                    self.simulation_model_name,
                    state.status_message,
                )
                return None
            orientation = state.pose.orientation
            yaw = math.atan2(
                2.0 * (orientation.w * orientation.z + orientation.x * orientation.y),
                1.0 - 2.0 * (orientation.y ** 2 + orientation.z ** 2),
            )
            return state.pose.position.x, state.pose.position.y, yaw
        except (rospy.ROSException, rospy.ServiceException) as exc:
            rospy.logwarn("Failed to read Gazebo robot pose: %s", exc)
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
