#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import rospy
import subprocess
import os
import sys
import json
import time
import threading
import random
import actionlib
import math
import cv2
import numpy as np
from cv_bridge import CvBridge
from sensor_msgs.msg import Image
from std_srvs.srv import Trigger, TriggerResponse
from std_msgs.msg import String
from move_base_msgs.msg import MoveBaseAction, MoveBaseGoal
from sensor_msgs.msg import JointState
from geometry_msgs.msg import Twist
from monday9.msg import Coord
import tf
import tf.transformations as tft

# 将 ros_database 目录加入 Python 搜索路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'ros_database'))
from db_manager import DatabaseManager

class SystemManager:
    def __init__(self):
        # ⚠️ 请确保该路径在你的机器上是正确的
        self.data_dir = os.path.expanduser("~/catkin_ws/src/monday9/maps")
        self.current_map_process = None  
        self.amcl_process = None         # 新增：管理 AMCL 进程
        self.rviz_process = None         # 新增：管理 RViz 进程
        os.makedirs(self.data_dir, exist_ok=True)
        
        # 1. 初始化各类存储文件
        self.files = {
            "pallet": os.path.join(self.data_dir, "pallets.json"),
            "platform": os.path.join(self.data_dir, "platforms.json"),
            "color": os.path.join(self.data_dir, "colors.json"),
            "allocation": os.path.join(self.data_dir, "allocations.json") # 格式: {"托盘名": "颜色"}
        }
        
        for key, path in self.files.items():
            if not os.path.exists(path):
                with open(path, 'w', encoding='utf-8') as f:
                    # 分配关系用字典{}，其他用列表[]
                    json.dump({} if key == "allocation" else [], f)

        # ================= 初始化 MoveBase 客户端 =================
        self.move_base_client = actionlib.SimpleActionClient('move_base', MoveBaseAction)
        rospy.loginfo("等待 move_base action_server 启动...")
        # 暂不强制阻塞等待，允许后台慢慢连接
        # self.move_base_client.wait_for_server() 

        # ================= 注册所有服务 =================
        # 地图管理
        rospy.Service('/save_map', Trigger, self.save_map)
        rospy.Service('/list_maps', Trigger, self.list_maps)
        rospy.Service('/load_map', Trigger, self.load_map)
        rospy.Service('/stop_map_server', Trigger, self.stop_map_server)
        rospy.Service('/delete_map', Trigger, self.delete_map)
        
        # 托盘管理
        rospy.Service('/get_pallets', Trigger, self.get_pallets)
        rospy.Service('/add_pallet', Trigger, self.add_pallet)
        rospy.Service('/delete_pallet', Trigger, self.delete_pallet)
        rospy.Service('/update_pallet', Trigger, self.update_pallet)
        
        # 平台管理
        rospy.Service('/get_platforms', Trigger, self.get_platforms)
        rospy.Service('/add_platform', Trigger, self.add_platform)
        rospy.Service('/delete_platform', Trigger, self.delete_platform)
        rospy.Service('/update_platform', Trigger, self.update_platform)
        
        # 颜色与分配管理
        rospy.Service('/get_colors', Trigger, self.get_colors)
        rospy.Service('/add_color', Trigger, self.add_color)
        rospy.Service('/delete_color', Trigger, self.delete_color)
        rospy.Service('/get_allocations', Trigger, self.get_allocations)
        rospy.Service('/add_allocation', Trigger, self.add_allocation)
        rospy.Service('/delete_allocation', Trigger, self.delete_allocation)

        # ================= 数据库查询服务 =================
        rospy.Service('/get_task_statistics', Trigger, self.get_task_statistics)
        rospy.Service('/get_exceptions', Trigger, self.get_exceptions)
        rospy.Service('/resolve_exception', Trigger, self.resolve_exception)

        # ================= 任务状态机控制 =================
        self.task_thread = None
        self.task_running = False
        self.progress_pub = rospy.Publisher('/task_progress', String, queue_size=10)
        
        rospy.Service('/start_task', Trigger, self.start_task)
        rospy.Service('/stop_task', Trigger, self.stop_task)
        
        rospy.loginfo("💾 全栈系统管理服务已启动 (基于真实 ROS Action 状态机)")

        # ================= WPB Home 抓取动作通信接口 =================
        self.grab_pub = rospy.Publisher('/wpb_home/behaviors', String, queue_size=10)
        self.grab_result = None
        rospy.Subscriber('/wpb_home/grab_result', String, self.grab_result_cb)

        # ================= WPB Home 头部云台控制接口 =================
        self.head_pub = rospy.Publisher('/wpb_home/head_step', JointState, queue_size=1)
        # 上面我们已经有了 self.grab_pub 和 self.grab_result 等

        # ================= 视觉图像接口 =================
        self.bridge = CvBridge()
        self.current_cv_image = None
        # ⚠️ 请根据你的真实机器人摄像头话题修改此处 (常见如 /camera/rgb/image_raw 或 /kinect2/qhd/image_color)
        rospy.Subscriber('/kinect2/qhd/image_color_rect', Image, self.image_callback)
    
        # ================= 机械臂底层控制器 =================
        self.mani_pub = rospy.Publisher('/wpb_home/mani_ctrl', JointState, queue_size=10)
        self.cmd_vel_pub = rospy.Publisher('/cmd_vel', Twist, queue_size=1)
        self.tf_listener = tf.TransformListener()

        # ================= 3D 物体检测 =================
        self.objects_3d = None
        rospy.Subscriber('/wpb_home/objects_3d', Coord, self._objects_3d_cb)

        # ================= 码垛参数 =================
        self.BOX_SIZE = 0.1           # 箱体边长 (m)
        self.ARM_REACH = 0.70         # 基座中心到夹爪中心的前向距离 (m) = Kinect偏移0.145 + grab常量0.55

        # ================= 数据库初始化 =================
        self.db = DatabaseManager()  # 新增
        self.current_task_id = None  # 新增：当前任务ID
        self.current_cargo_record_id = None  # 新增：当前货物记录ID

    def _get_global_frame(self):
        """返回 map 帧 (如有AMCL) 否则回退 odom，保证与目标坐标在同一参考系"""
        try:
            self.tf_listener.waitForTransform("map", "base_footprint",
                rospy.Time(0), rospy.Duration(1.0))
            return "map"
        except Exception:
            return "odom"

    def _objects_3d_cb(self, msg):
        """接收 3D 物体检测结果 (base_footprint 坐标系)"""
        self.objects_3d = msg

    def _get_closest_object(self, timeout=2.0, max_z=99.0):
        """获取最近检测到的物体 (base_footprint 帧), 返回 (x,y,z) 或 None
        max_z: 忽略高于此高度的物体 (滤除夹爪中箱子)"""
        start = rospy.Time.now()
        while self.task_running and (rospy.Time.now() - start).to_sec() < timeout:
            if self.objects_3d is not None and len(self.objects_3d.x) > 0:
                for i in range(len(self.objects_3d.x)):
                    if self.objects_3d.z[i] <= max_z:
                        x, y, z = self.objects_3d.x[i], self.objects_3d.y[i], self.objects_3d.z[i]
                        rospy.loginfo("[视觉] 检测到物体 #%d: (%.3f, %.3f, %.3f)" % (i, x, y, z))
                        return (x, y, z)
                rospy.loginfo("[视觉] %d个物体均被max_z=%.2f滤除" % (len(self.objects_3d.x), max_z))
            rospy.sleep(0.1)
        return None

    def align_lateral_to_object(self, max_z=99.0):
        """视觉闭环: 在停靠点横向对准下方箱子 (仅左右, 不动前后)"""
        obj = self._get_closest_object(timeout=2.0, max_z=max_z)
        if obj is None:
            rospy.logwarn("align_lateral: 未检测到托盘箱子, 跳过")
            return

        _, oy, _ = obj
        if abs(oy) > 0.4:
            rospy.logwarn("align_lateral: 横向误差过大 lat=%.2f, 跳过" % oy)
            return

        Kp = 0.3
        tol_y = 0.008
        settle = 0
        rate = rospy.Rate(30)
        vel_msg = Twist()
        start_t = rospy.Time.now()

        while self.task_running and (rospy.Time.now() - start_t).to_sec() < 5.0:
            obj = self._get_closest_object(timeout=0.3, max_z=max_z)
            if obj is None:
                settle = 0
                rate.sleep()
                continue
            _, oy, _ = obj

            if abs(oy) < tol_y:
                settle += 1
                if settle >= 3:
                    break
            else:
                settle = 0

            vy = oy * Kp
            max_spd = 0.04 if abs(oy) < 0.04 else 0.06
            if vy >  max_spd: vy =  max_spd
            if vy < -max_spd: vy = -max_spd

            vel_msg.linear.y = vy
            self.cmd_vel_pub.publish(vel_msg)
            rate.sleep()

        vel_msg.linear.y = 0.0
        self.cmd_vel_pub.publish(vel_msg)

    def measure_forward_to_object(self, max_z=99.0):
        """在停靠点测量到下方箱子的前向距离 (夹爪悬伸需到达), 返回 (need_fwd, obj_x) 或 (0,0)"""
        obj = self._get_closest_object(timeout=2.0, max_z=max_z)
        if obj is None:
            rospy.logwarn("measure_fwd: 未检测到托盘箱子")
            return 0.0, 0.0
        ox = obj[0]
        need = ox - self.ARM_REACH
        rospy.loginfo("[视觉] 下方箱子在 %.3fm, 需前进 %.3fm (ARM_REACH=%.2f)" % (ox, need, self.ARM_REACH))
        if need < -0.2:
            rospy.logwarn("measure_fwd: 已在箱子前方? need=%.2f < -0.2, 跳过" % need)
            return 0.0, ox
        if need > 0.6:
            rospy.logwarn("measure_fwd: 箱子太远 need=%.2f > 0.6, 跳过" % need)
            return 0.0, ox
        return need, ox
    
    # ================= 🎨 颜色管理 =================
    def get_colors(self, req):
        try:
            with open(self.files["color"], 'r', encoding='utf-8') as f: 
                return TriggerResponse(True, f.read())
        except Exception as e: 
            return TriggerResponse(False, str(e))

    def add_color(self, req):
        try:
            new_color = rospy.get_param('/new_color_data', '')
            if not new_color: return TriggerResponse(False, "无效的颜色")
            with open(self.files["color"], 'r', encoding='utf-8') as f: colors = json.load(f)
            if new_color not in colors:
                colors.append(new_color)
                with open(self.files["color"], 'w', encoding='utf-8') as f: json.dump(colors, f, ensure_ascii=False)
            return TriggerResponse(True, "颜色添加成功")
        except Exception as e: return TriggerResponse(False, str(e))

    # ================= 🔗 分配管理 =================
    def get_allocations(self, req):
        try:
            with open(self.files["allocation"], 'r', encoding='utf-8') as f: return TriggerResponse(True, f.read())
        except Exception as e: return TriggerResponse(False, str(e))

    def add_allocation(self, req):
        try:
            alloc_str = rospy.get_param('/new_allocation_data', '')
            alloc_data = json.loads(alloc_str)
            with open(self.files["allocation"], 'r', encoding='utf-8') as f: allocs = json.load(f)
            allocs[alloc_data['pallet']] = alloc_data['color']
            with open(self.files["allocation"], 'w', encoding='utf-8') as f: json.dump(allocs, f, indent=4, ensure_ascii=False)
            
            # 更新数据库码垛位的货物类型 新增 begin
            cargo_type_id = self.db.get_cargo_type_id(alloc_data['color'])
            if cargo_type_id:
                self.db.update_pallet_slot_cargo_type(alloc_data['pallet'], cargo_type_id)
                rospy.loginfo(f"[数据库] 码垛位货物类型已更新: {alloc_data['pallet']} -> {alloc_data['color']}")
            # end

            rospy.loginfo(f"🔗 分配更新: {alloc_data['pallet']} -> {alloc_data['color']}")
            return TriggerResponse(True, "分配成功！")
        except Exception as e: return TriggerResponse(False, str(e))

    # ================= 📦 资产管理 =================
    def get_pallets(self, req):
        try:
            with open(self.files["pallet"], 'r', encoding='utf-8') as f: return TriggerResponse(True, f.read())
        except Exception as e: return TriggerResponse(False, str(e))

    def add_pallet(self, req):
        try:
            data = json.loads(rospy.get_param('/new_pallet_data', ''))
            with open(self.files["pallet"], 'r', encoding='utf-8') as f: items = json.load(f)
            items.append(data)
            with open(self.files["pallet"], 'w', encoding='utf-8') as f: json.dump(items, f, indent=4, ensure_ascii=False)

            # 同步到数据库码垛位表 新增 begin
            # 注意：这里需要知道该托盘对应的货物类型
            # 暂时使用默认货物类型，后续通过分配关系更新
            try:
                self.db.add_pallet_slot(
                    slot_id=data['name'],
                    cargo_type_name="待分配",  # 临时类型，后续通过分配更新
                    position={'x': data['x'], 'y': data['y'], 'z': data['z']},
                    max_layer=data.get('max_layer', 3),  # 默认3层
                    layer_offsets={'x': 0, 'y': 0, 'z': self.BOX_SIZE}
                )
                rospy.loginfo(f"[数据库] 码垛位已添加: {data['name']}")
            except Exception as db_e:
                rospy.logwarn(f"[数据库] 添加码垛位失败: {db_e}")
            # end

            return TriggerResponse(True, "托盘添加成功")
        except Exception as e: return TriggerResponse(False, str(e))

    def get_platforms(self, req):
        try:
            with open(self.files["platform"], 'r', encoding='utf-8') as f: return TriggerResponse(True, f.read())
        except Exception as e: return TriggerResponse(False, str(e))

    def add_platform(self, req):
        try:
            data = json.loads(rospy.get_param('/new_platform_data', ''))
            with open(self.files["platform"], 'r', encoding='utf-8') as f: items = json.load(f)
            items.append(data)
            with open(self.files["platform"], 'w', encoding='utf-8') as f: json.dump(items, f, indent=4, ensure_ascii=False)
            return TriggerResponse(True, "平台添加成功")
        except Exception as e: return TriggerResponse(False, str(e))

    # ================= 📦 删除与更新 =================

    def delete_pallet(self, req):
        try:
            name = rospy.get_param('/delete_pallet_name', '')
            with open(self.files["pallet"], 'r', encoding='utf-8') as f: items = json.load(f)
            items = [i for i in items if i.get('name') != name]
            with open(self.files["pallet"], 'w', encoding='utf-8') as f: json.dump(items, f, indent=4, ensure_ascii=False)
            return TriggerResponse(True, "托盘已删除")
        except Exception as e: return TriggerResponse(False, str(e))

    def update_pallet(self, req):
        try:
            data = json.loads(rospy.get_param('/update_pallet_data', ''))
            name = data.get('name', '')
            with open(self.files["pallet"], 'r', encoding='utf-8') as f: items = json.load(f)
            for i, item in enumerate(items):
                if item.get('name') == name:
                    items[i] = data
                    break
            with open(self.files["pallet"], 'w', encoding='utf-8') as f: json.dump(items, f, indent=4, ensure_ascii=False)
            return TriggerResponse(True, "托盘已更新")
        except Exception as e: return TriggerResponse(False, str(e))

    def delete_platform(self, req):
        try:
            name = rospy.get_param('/delete_platform_name', '')
            with open(self.files["platform"], 'r', encoding='utf-8') as f: items = json.load(f)
            items = [i for i in items if i.get('name') != name]
            with open(self.files["platform"], 'w', encoding='utf-8') as f: json.dump(items, f, indent=4, ensure_ascii=False)
            return TriggerResponse(True, "平台已删除")
        except Exception as e: return TriggerResponse(False, str(e))

    def update_platform(self, req):
        try:
            data = json.loads(rospy.get_param('/update_platform_data', ''))
            name = data.get('name', '')
            with open(self.files["platform"], 'r', encoding='utf-8') as f: items = json.load(f)
            for i, item in enumerate(items):
                if item.get('name') == name:
                    items[i] = data
                    break
            with open(self.files["platform"], 'w', encoding='utf-8') as f: json.dump(items, f, indent=4, ensure_ascii=False)
            return TriggerResponse(True, "平台已更新")
        except Exception as e: return TriggerResponse(False, str(e))

    def delete_color(self, req):
        try:
            name = rospy.get_param('/delete_color_name', '')
            with open(self.files["color"], 'r', encoding='utf-8') as f: colors = json.load(f)
            colors = [c for c in colors if c != name]
            with open(self.files["color"], 'w', encoding='utf-8') as f: json.dump(colors, f, ensure_ascii=False)
            return TriggerResponse(True, "颜色已删除")
        except Exception as e: return TriggerResponse(False, str(e))

    def delete_allocation(self, req):
        try:
            pallet = rospy.get_param('/delete_allocation_pallet', '')
            with open(self.files["allocation"], 'r', encoding='utf-8') as f: allocs = json.load(f)
            if pallet in allocs:
                del allocs[pallet]
                with open(self.files["allocation"], 'w', encoding='utf-8') as f: json.dump(allocs, f, indent=4, ensure_ascii=False)
            return TriggerResponse(True, "分配已删除")
        except Exception as e: return TriggerResponse(False, str(e))

    # ================= 🗺️ 地图管理 =================
    def stop_map_server(self, req):
        try:
            os.system("killall map_server 2>/dev/null")
            if self.current_map_process: 
                self.current_map_process.terminate()
                self.current_map_process = None
            return TriggerResponse(True, "已清理")
        except Exception as e: return TriggerResponse(False, str(e))

    def save_map(self, req):
        try:
            name = rospy.get_param('/current_map_name', 'my_map')
            path = os.path.join(self.data_dir, name)
            res = subprocess.run(["rosrun", "map_server", "map_saver", "-f", path], capture_output=True, text=True, timeout=30)
            return TriggerResponse(True, "地图已保存") if res.returncode == 0 else TriggerResponse(False, res.stderr)
        except Exception as e: return TriggerResponse(False, str(e))

    def list_maps(self, req):
        try:
            files = [f.replace('.yaml', '') for f in os.listdir(self.data_dir) if f.endswith('.yaml')]
            return TriggerResponse(True, ",".join(sorted(files)) if files else "NONE")
        except Exception as e: return TriggerResponse(False, str(e))

    def delete_map(self, req):
        try:
            name = rospy.get_param('/delete_map_name', '')
            if not name: return TriggerResponse(False, "未指定地图名称")
            yaml_path = os.path.join(self.data_dir, name + ".yaml")
            pgm_path = os.path.join(self.data_dir, name + ".pgm")
            deleted = []
            if os.path.exists(yaml_path):
                os.remove(yaml_path)
                deleted.append(name + '.yaml')
            if os.path.exists(pgm_path):
                os.remove(pgm_path)
                deleted.append(name + '.pgm')
            if not deleted:
                return TriggerResponse(False, "未找到地图文件")
            return TriggerResponse(True, "已删除: " + ', '.join(deleted))
        except Exception as e: return TriggerResponse(False, str(e))

    def load_map(self, req):
        try:
            name = rospy.get_param('/current_map_name', '')
            path = os.path.join(self.data_dir, name + ".yaml")
            if not os.path.exists(path): return TriggerResponse(False, "未找到文件")
            self.stop_map_server(None)
            self.current_map_process = subprocess.Popen(["rosrun", "map_server", "map_server", path])
            self.amcl_process = subprocess.Popen(["roslaunch", "monday9", "amcl_omni.launch"])
            rviz_cfg = os.path.expanduser("~/catkin_ws/src/monday9/rviz/grab.rviz")
            self.rviz_process = subprocess.Popen([
                "rosrun", "rviz", "rviz", 
                "-d", rviz_cfg, 
                "__name:=grab_rviz"  # 关键：修改节点名，避免与建图的 rviz 冲突
            ])
            return TriggerResponse(True, "加载成功")
        except Exception as e: return TriggerResponse(False, str(e))

    # ================= 颜色识别 =================
    def image_callback(self, msg):
        """实时获取摄像头画面并转为 OpenCV 格式"""
        try:
            # 将 ROS 图像消息转换为 BGR 格式的 OpenCV 图像
            self.current_cv_image = self.bridge.imgmsg_to_cv2(msg, "bgr8")
        except Exception as e:
            rospy.logwarn(f"图像转换失败: {e}")

    def detect_real_color(self, valid_colors):
        """
        基于 OpenCV 的真实颜色识别 (带有调试保存功能 + 适配中文颜色)
        """
        if self.current_cv_image is None:
            rospy.logwarn("❌ 未接收到任何图像数据！请检查摄像头话题是否正常发布。")
            return None

        # 1. 裁剪中心区域
        h, w, _ = self.current_cv_image.shape
        roi = self.current_cv_image[h//3 : 2*h//3, w//3 : 2*w//3]
        
        # 📸 调试截图功能保留，方便你排查视野问题
        debug_path = os.path.expanduser("~/catkin_ws/src/monday9/debug_roi.jpg")
        cv2.imwrite(debug_path, roi)
        rospy.loginfo(f"📸 已将当前分析的图像视野保存至: {debug_path}")

        # 2. 转换到 HSV
        hsv_image = cv2.cvtColor(roi, cv2.COLOR_BGR2HSV)

        # 3. 颜色阈值 (⚠️ 这里修改为前端实际使用的中文键名)
        color_ranges = {
            "红色": [
                (np.array([0, 100, 100]), np.array([10, 255, 255])),
                (np.array([160, 100, 100]), np.array([179, 255, 255]))
            ],
            "绿色": [(np.array([35, 100, 100]), np.array([85, 255, 255]))],
            "蓝色": [(np.array([100, 100, 100]), np.array([124, 255, 255]))],
            "黄色": [(np.array([15, 100, 100]), np.array([34, 255, 255]))]
        }

        best_color = None
        max_pixels = 0

        rospy.loginfo(f"🔍 系统传入的候选颜色列表为: {valid_colors}")

        # 4. 遍历检测
        for color_name in valid_colors:
            # 中文去前后空格即可，不需要 lower()
            safe_color_name = str(color_name).strip()
            
            if safe_color_name not in color_ranges:
                rospy.logwarn(f"⚠️ 颜色字典中没有预设 '{safe_color_name}' 的 HSV 阈值，已跳过。")
                continue

            mask = np.zeros(hsv_image.shape[:2], dtype=np.uint8)
            for (lower, upper) in color_ranges[safe_color_name]:
                temp_mask = cv2.inRange(hsv_image, lower, upper)
                mask = cv2.bitwise_or(mask, temp_mask)

            pixel_count = cv2.countNonZero(mask)
            rospy.loginfo(f"📊 颜色 [{safe_color_name}] 匹配到的像素数量: {pixel_count}")
            
            if pixel_count > max_pixels:
                max_pixels = pixel_count
                best_color = safe_color_name

        # 5. 判定结果
        if max_pixels < 500: 
            rospy.logwarn(f"❌ 识别失败：最大颜色像素数 ({max_pixels}) 太少，低于 500。可能是没截取到物体或色差太大。")
            return None
            
        rospy.loginfo(f"✅ 成功识别到颜色: {best_color} (匹配像素: {max_pixels})")
        
        # 货物类型记录 新增begin
        if best_color:
            type_id = self.db.get_cargo_type_id(best_color)
            if type_id is None:
                # 新颜色作为新货物类型添加
                self.db.add_cargo_type(best_color, 
                                    default_length=self.BOX_SIZE,
                                    default_width=self.BOX_SIZE,
                                    default_height=self.BOX_SIZE)
                rospy.loginfo(f"[数据库] 新增货物类型: {best_color}")
        
        return best_color
    
    # ================= 🚀 任务控制与真实状态机 =================
    def get_asset_info(self, asset_type, name):
        """根据名称获取平台或托盘的所有信息 (x, y, z, l, w)"""
        try:
            with open(self.files[asset_type], 'r', encoding='utf-8') as f:
                items = json.load(f)
                for item in items:
                    if item['name'] == name:
                        return (float(item['x']), float(item['y']), float(item.get('z', 0.375)),
                                float(item['l']), float(item['w']))
        except Exception:
            pass
        return None, None, None, None, None

    def create_nav_goal(self, x, y, yaw=0.0):
        """创建 MoveBase 目标点，支持二维朝向(Yaw)"""
        goal = MoveBaseGoal()
        goal.target_pose.header.frame_id = "map"
        goal.target_pose.header.stamp = rospy.Time.now()
        goal.target_pose.pose.position.x = x
        goal.target_pose.pose.position.y = y
        
        # 将 Yaw 角转换为四元数
        goal.target_pose.pose.orientation.z = math.sin(yaw / 2.0)
        goal.target_pose.pose.orientation.w = math.cos(yaw / 2.0)
        return goal

    def compute_place_pose(self, pal_name, layer, pos_in_layer, pattern):
        """
        计算码垛目标坐标 (紧密排列，居中摆放)
        pattern: {'l': rows, 'w': cols} 每层垛型
        layer: 第几层 (1-indexed)
        pos_in_layer: 层内第几个 (1-indexed, row-major)
        返回: (target_x, target_y, target_z) 箱体中心的世界坐标
        """
        pal_x, pal_y, pal_z, pal_l, pal_w = self.get_asset_info("pallet", pal_name)

        w = pattern['w']  # 列数 (x方向)
        l = pattern['l']  # 行数 (y方向)

        col = (pos_in_layer - 1) % w
        row = (pos_in_layer - 1) // w

        # 紧密排列，网格居中于托盘
        target_x = pal_x + self.BOX_SIZE * (col + 0.5 - w / 2.0)
        target_y = pal_y + self.BOX_SIZE * (row + 0.5 - l / 2.0)
        # 托盘顶面 + 本层偏移 + 箱体半高 (托盘 z 存的是模型中心，高度 = z*2)
        target_z = pal_z * 2.0 + (layer - 1) * self.BOX_SIZE + self.BOX_SIZE / 2.0

        return target_x, target_y, target_z

    def move_relative(self, dx_robot, dy_robot, speed=0.12, timeout=15.0):
        """闭环相对位移: 用 TF odom 帧做 P 控制 (不用 map, AMCL 更新会跳变)
        dx_robot: 前进距离 (m), 正=前
        dy_robot: 横向距离 (m), 正=右"""
        if abs(dx_robot) < 0.005 and abs(dy_robot) < 0.005:
            return

        # odom 帧: 秒级无漂移，不会被 AMCL 跳变干扰
        gframe = "odom"

        # 获取起始位姿
        try:
            self.tf_listener.waitForTransform(gframe, "base_footprint",
                rospy.Time(0), rospy.Duration(2.0))
            (t0, r0) = self.tf_listener.lookupTransform(gframe, "base_footprint",
                rospy.Time(0))
        except Exception:
            rospy.logwarn("move_relative: 无法获取 %s 位姿, 跳过" % gframe)
            return

        sx, sy = t0[0], t0[1]
        _, _, syaw = tft.euler_from_quaternion(r0)

        # 目标世界坐标 = 起始 + 局部位移转到世界
        tx = sx + dx_robot * math.cos(syaw) - dy_robot * math.sin(syaw)
        ty = sy + dx_robot * math.sin(syaw) + dy_robot * math.cos(syaw)

        tol_xy = 0.01          # 1cm 容差
        settle_needed = 3      # 连续 3 次达标才停
        settle_count = 0
        rate = rospy.Rate(30)
        vel_msg = Twist()
        start_t = rospy.Time.now()

        while self.task_running and (rospy.Time.now() - start_t).to_sec() < timeout:
            try:
                (t, r) = self.tf_listener.lookupTransform(gframe, "base_footprint",
                    rospy.Time(0))
            except Exception:
                settle_count = 0
                rate.sleep()
                continue

            cx, cy = t[0], t[1]
            _, _, cyaw = tft.euler_from_quaternion(r)

            # 世界误差 → 机器人坐标系
            ex_w = tx - cx
            ey_w = ty - cy
            ex_r =  ex_w * math.cos(cyaw) + ey_w * math.sin(cyaw)
            ey_r = -ex_w * math.sin(cyaw) + ey_w * math.cos(cyaw)
            dist = math.hypot(ex_r, ey_r)

            if abs(ex_r) < tol_xy and abs(ey_r) < tol_xy:
                settle_count += 1
                if settle_count >= settle_needed:
                    break
            else:
                settle_count = 0

            # 分段 Kp: 远快近稳
            Kp = 0.3 if dist < 0.03 else 0.6
            vx = ex_r * Kp
            vy = ey_r * Kp
            if vx >  speed: vx =  speed
            if vx < -speed: vx = -speed
            if vy >  speed: vy =  speed
            if vy < -speed: vy = -speed
            # 死区补偿: 克服静摩擦
            if vx > 0 and vx < 0.012: vx = 0.012
            if vx < 0 and vx > -0.012: vx = -0.012
            if vy > 0 and vy < 0.012: vy = 0.012
            if vy < 0 and vy > -0.012: vy = -0.012

            vel_msg.linear.x = vx
            vel_msg.linear.y = vy
            self.cmd_vel_pub.publish(vel_msg)
            rate.sleep()

        vel_msg.linear.x = 0.0
        vel_msg.linear.y = 0.0
        self.cmd_vel_pub.publish(vel_msg)

    def rotate_to_yaw(self, target_yaw, speed=0.3, timeout=8.0):
        """闭环旋转到目标 yaw 角 (P控制, odom帧避免AMCL跳变), 不移动位置"""
        gframe = "odom"
        try:
            self.tf_listener.waitForTransform(gframe, "base_footprint",
                rospy.Time(0), rospy.Duration(2.0))
            (t, r) = self.tf_listener.lookupTransform(gframe, "base_footprint",
                rospy.Time(0))
            _, _, cyaw = tft.euler_from_quaternion(r)
        except Exception:
            return

        # 归一化角度差到 [-π, π]
        err = target_yaw - cyaw
        err = math.atan2(math.sin(err), math.cos(err))

        if abs(err) < 0.03:
            return

        Kp = 1.2
        rate = rospy.Rate(30)
        vel_msg = Twist()
        start_t = rospy.Time.now()

        while self.task_running and (rospy.Time.now() - start_t).to_sec() < timeout:
            try:
                (t, r) = self.tf_listener.lookupTransform(gframe, "base_footprint",
                    rospy.Time(0))
                _, _, cyaw = tft.euler_from_quaternion(r)
            except Exception:
                rate.sleep()
                continue

            err = target_yaw - cyaw
            err = math.atan2(math.sin(err), math.cos(err))
            if abs(err) < 0.03:
                break

            vw = err * Kp
            if vw >  speed: vw =  speed
            if vw < -speed: vw = -speed
            vel_msg.angular.z = vw
            self.cmd_vel_pub.publish(vel_msg)
            rate.sleep()

        vel_msg.angular.z = 0.0
        self.cmd_vel_pub.publish(vel_msg)

    def start_task(self, req):
        if self.task_running:
            return TriggerResponse(False, "已有任务正在运行，请先停止")
        
        task_str = rospy.get_param('/new_task_data', '')
        if not task_str: return TriggerResponse(False, "无法获取任务参数")
            
        try:
            task_data = json.loads(task_str)

            # 创建数据库任务记录 新增begin
            self.current_task_id = self.db.create_task(
                total_count=task_data.get('total', 0),
                parameters={'platform': task_data.get('platform'), 'pattern': task_data.get('pattern')}
            )
            self.db.start_task(self.current_task_id)
            # end

            self.task_running = True
            self.task_thread = threading.Thread(target=self.fsm_execution_loop, args=(task_data,))
            self.task_thread.start()
            #添加任务ID
            return TriggerResponse(True, f"状态机任务已启动 (任务ID: {self.current_task_id})")
        except Exception as e:
            return TriggerResponse(False, f"解析失败: {str(e)}")

    def stop_task(self, req):
        if not self.task_running:
            return TriggerResponse(False, "当前无运行中的任务")
        self.task_running = False 
        self.move_base_client.cancel_all_goals()

        # 更新任务状态 新增begin
        if self.current_task_id:
            self.db.update_task_progress(self.current_task_id, status="已取消")
        # end

        return TriggerResponse(True, "已发送急停和取消导航指令")

    def publish_progress(self, status, percent, log=""):
        msg = json.dumps({"status": status, "percent": percent, "log": log}, ensure_ascii=False)
        self.progress_pub.publish(msg)

    def grab_result_cb(self, msg):
        """接收 WPB Home 抓取动作的结果回调"""
        rospy.loginfo(f"[GrabResultCB] 收到抓取结果: {msg.data}")
        self.grab_result = msg.data

    def fsm_execution_loop(self, task_data):
        """核心：基于状态机的真实执行循环"""
        platform = task_data.get('platform', '')
        total = task_data.get('total', 0)
        pattern = task_data.get('pattern', {'l': 1, 'w': 1})
        max_per_layer = max(1, pattern['l'] * pattern['w'])
        
        try:
            with open(self.files["allocation"], 'r', encoding='utf-8') as f: allocs = json.load(f)
            with open(self.files["color"], 'r', encoding='utf-8') as f: colors = json.load(f)
        except Exception:
            allocs, colors = {}, []
            
        plat_x, plat_y, plat_z, plat_l, plat_w = self.get_asset_info("platform", platform)
        if plat_x is None:
            self.publish_progress("错误", 0, f"❌ 找不到取货平台【{platform}】的坐标")
            self.task_running = False
            return

        # ================= 安全停靠距离配置 =================
        # 这是机器人底盘中心，距离平台或托盘【边缘】的安全距离。
        # 等于 = 机器人半径(如0.3m) + 安全间隙(如0.35m)。
        # 如果还是会蹭到托盘，请将这个值改大（例如 0.8）。
        safe_distance = 0.7
        
        # 假设机器人统一从 X轴负方向(左侧) 靠近资产
        # 平台停靠点坐标：平台中心 X 减去 一半长度 再减去 安全距离
        nav_plat_x = plat_x
        nav_plat_y = plat_y - (plat_w / 2.0) - safe_distance
        nav_plat_yaw = 1.57 # 朝向正Y轴 (面向平台)

        current_state = "NAV_TO_PLATFORM"
        current_item_index = 1
        target_pallet = None
        detected_color = None
        pallet_counts = {}

        self.publish_progress("初始化", 5, "🚀 真实动作状态机启动...")

        while self.task_running and current_item_index <= total:
            percent = int((current_item_index - 1) / total * 100)
            
            # ----------------------------------------------------
            # 状态 1: 导航到平台安全点
            # ----------------------------------------------------
            if current_state == "NAV_TO_PLATFORM":
                self.publish_progress("导航至平台", percent, f"🤖 任务 {current_item_index}/{total}: 前往平台【{platform}】安全停靠点...")
                goal = self.create_nav_goal(nav_plat_x, nav_plat_y, nav_plat_yaw)
                self.move_base_client.send_goal(goal)
                
                finished = False
                while not finished and self.task_running:
                    finished = self.move_base_client.wait_for_result(rospy.Duration(1.0))
                
                if not self.task_running: break
                
                state = self.move_base_client.get_state()
                if state == actionlib.GoalStatus.SUCCEEDED:
                    current_state = "DETECT_AND_PICK"
                else:
                    self.publish_progress("导航失败", percent, "❌ 无法到达平台停靠点，准备重试...")
                    time.sleep(2)

            # ----------------------------------------------------
            # 状态 2: 视觉识别与真实抓取 (调用 wpb_home_behaviors)
            # ----------------------------------------------------
            elif current_state == "DETECT_AND_PICK":
                self.publish_progress("视觉抓取", percent + 2, "📷 正在启动 WPB_Home 视觉点云识别与机械臂抓取...")
                
                # 1. 重置结果标志位，准备接收新结果
                self.grab_result = None 
                
                # 2. 发布抓取启动指令 (复刻了 C++ 里的行为)
                msg = String()
                msg.data = "grab start"
                self.grab_pub.publish(msg)
                
                self.publish_progress("抓取进行中", percent + 3, "⚙️ 机器人正在扫描 3D 点云寻找物体，请等待...")
                
                # 3. 阻塞等待抓取结果 (带有超时和急停退出机制)
                wait_time = 0
                max_wait_seconds = 120 # 抓取动作比较耗时，给 120 秒超时
                grab_success = False
                detected_color = None
                
                while self.task_running and wait_time < max_wait_seconds:
                    if self.grab_result is not None:
                        if "object up" in self.grab_result and detected_color is None:
                            self.publish_progress("视觉识别", percent + 3, "🔍 趁物体在半空中且未后退，进行颜色抓拍...")
                            detected_color = self.detect_real_color(colors)

                            # 识别失败异常记录 新增begin
                            if detected_color is None and self.current_task_id:
                                self.db.log_exception(
                                    exception_name="识别失败",
                                    exception_message=f"视觉识别未检测到目标货物颜色，候选颜色: {colors}",
                                    task_id=self.current_task_id,
                                    record_id=self.current_cargo_record_id
                                )
                                rospy.logwarn("[异常记录] 识别失败已写入数据库")
                            # end

                        # 假设节点返回 "done" 表示动作完成
                        if "done" in self.grab_result:
                            grab_success = True
                            break
                    time.sleep(0.5) 
                    wait_time += 0.5
                
                # 检查是否因为用户点击"停止任务"而中断了 while 循环
                if not self.task_running: break
                
                # 4. 根据抓取结果决定状态机的下一步
                if grab_success:
                    self.publish_progress("抓取成功", percent + 4, "✅ 真实机械臂抓取完成！")
                    # 此处可添加异常记录：定位偏差过大异常记录
                    # 记录货物处理 新增begin
                    dimensions = {'length': self.BOX_SIZE, 'width': self.BOX_SIZE, 'height': self.BOX_SIZE}
                    position = None  # 可以从视觉获取
        
                    self.current_cargo_record_id = self.db.add_cargo_record(
                        task_id=self.current_task_id,
                        type_name=detected_color if detected_color else "未知",
                        final_status="待码垛",
                        actual_dimensions=dimensions,
                        position=position,
                        retry_count=0
                    )
                    # end

                    # self.publish_progress("视觉识别", percent + 4, "🔍 正在调用摄像头识别货物颜色...")
                    # time.sleep(1.0) # 等待机械臂平稳后获取清晰图像
                    
                    # 📷 调用我们刚才写的真实颜色识别函数
                    # detected_color = self.detect_real_color(colors)
                    
                    if detected_color is None:
                        self.publish_progress("半空抓拍失败", percent + 4, "正在执行补救识别...")
                        rospy.logwarn("⚠️ 错过了半空抓拍时机，正在执行补救识别...")
                        time.sleep(1.0)
                        detected_color = self.detect_real_color(colors)

                    if detected_color is None:
                        # 降级方案：如果识别失败，使用随机颜色保证流程不卡死，或者你可以改成抛弃货物
                        rospy.logwarn("真实颜色识别失败，降级为随机分配")
                        detected_color = random.choice(colors) if colors else None
                    
                    # 去 allocs 字典里寻找匹配这个颜色的托盘
                    target_pallet = None
                    for p, c in allocs.items():
                        if c == detected_color:
                            target_pallet = p
                            break
                            
                    if target_pallet:
                        current_state = "NAV_TO_PALLET" # 找到了对应的托盘，进入下一个状态
                    else:
                        self.publish_progress("异常", percent + 4, f"⚠️ 抓到了货物(识别颜色为 {detected_color})，但未分配托盘。丢弃！")
                        # (此处可以发送指令让机械臂松开物体抛弃)
                        current_item_index += 1
                        current_state = "NAV_TO_PLATFORM" # 回去抓下一个
                        
                else:

                    # 抓取失败时也要记录货物处理 新增 begin
                    dimensions = {'length': self.BOX_SIZE, 'width': self.BOX_SIZE, 'height': self.BOX_SIZE}
                    self.current_cargo_record_id = self.db.add_cargo_record(
                        task_id=self.current_task_id,
                        type_name="未知",  # 未识别成功
                        final_status="抓取失败",
                        actual_dimensions=dimensions,
                        position=None,
                        retry_count=pallet_counts.get(target_pallet, 0) if target_pallet else 0
                    )
                    # end

                    if wait_time >= max_wait_seconds:
                        # 抓取超时/失败异常记录 新增begin
                        self.db.log_exception(
                            exception_name="抓取失败",
                            exception_message=f"抓取超时({max_wait_seconds}s)，可能前方无物体或点云解析失败",
                            task_id=self.current_task_id,
                            record_id=self.current_cargo_record_id
                        )
                        self.publish_progress("抓取失败", percent + 4, "❌ 抓取超时！可能前方没有物体，或点云解析失败。")
                    else:
                        self.db.log_exception(
                            exception_name="抓取失败",
                            exception_message=f"底层返回失败: {self.grab_result}",
                            task_id=self.current_task_id,
                            record_id=self.current_cargo_record_id
                        )
                        self.publish_progress("抓取失败", percent + 4, f"❌ 底层返回失败: {self.grab_result}")
                    rospy.logwarn("[异常记录] 抓取失败已写入数据库") 
                    # end
                    
                    # 抓取失败的话，复位，尝试重新抓下一个
                    time.sleep(2)
                    current_item_index += 1
                    current_state = "NAV_TO_PLATFORM"

            # ----------------------------------------------------
            # 状态 3: 导航到目标托盘安全点
            # ----------------------------------------------------
            elif current_state == "NAV_TO_PALLET":
                pal_x, pal_y, pal_z, pal_l, pal_w = self.get_asset_info("pallet", target_pallet)
                if pal_x is None:
                    self.publish_progress("错误", percent, f"❌ 系统中找不到托盘【{target_pallet}】的坐标")
                    current_state = "DONE"
                    break

                # 避障核心：托盘往往因为太矮而不存在于代价地图中
                # 托盘停靠点：同理，位于托盘左侧边缘外，避免直接踩上去
                nav_pal_x = pal_x + (pal_w / 2.0) + safe_distance
                nav_pal_y = pal_y
                # nav_pal_x = pal_x
                # nav_pal_y = pal_y + (pal_w / 2.0) + safe_distance
                nav_pal_yaw = -1.57 # 朝向负Y轴 (面向托盘)

                self.publish_progress("导航至托盘", percent + 5, f"🎯 识别为【{detected_color}】 -> 运往托盘停靠点【{target_pallet}】...")
                goal = self.create_nav_goal(nav_pal_x, nav_pal_y, nav_pal_yaw)
                self.move_base_client.send_goal(goal)
                
                finished = False
                while not finished and self.task_running:
                    finished = self.move_base_client.wait_for_result(rospy.Duration(1.0))
                
                if not self.task_running: break
                
                if self.move_base_client.get_state() == actionlib.GoalStatus.SUCCEEDED:
                    current_state = "PLACE"
                else:
                    self.publish_progress("导航失败", percent, "❌ 无法到达目标托盘，准备重试...")
                    time.sleep(2)

            # ----------------------------------------------------
            # 状态 4: 码垛放置 (TF闭环定位，紧密排列，逐层堆叠)
            # ----------------------------------------------------
            elif current_state == "PLACE":
                pal_x, pal_y, pal_z, pal_l, pal_w = self.get_asset_info("pallet", target_pallet)
                if pal_x is None:
                    self.publish_progress("错误", percent, f"❌ 找不到托盘【{target_pallet}】的坐标")
                    current_state = "DONE"
                    break

                pallet_counts[target_pallet] = pallet_counts.get(target_pallet, 0) + 1
                curr_c = pallet_counts[target_pallet]
                layer = ((curr_c - 1) // max_per_layer) + 1
                pos_in_layer = ((curr_c - 1) % max_per_layer) + 1

                # 计算箱体目标世界坐标 (紧密排列，网格居中)
                target_x, target_y, target_z = self.compute_place_pose(
                    target_pallet, layer, pos_in_layer, pattern)

                # 位移用纯几何常量计算 — pal_y 项相互抵消, 不依赖 TF/AMCL 定位
                w = pattern['w']
                l = pattern['l']
                col = (pos_in_layer - 1) % w
                row = (pos_in_layer - 1) // w
                robot_forward = (pal_w / 2.0 + safe_distance) \
                    - (self.BOX_SIZE * (row + 0.5 - l / 2.0) + self.ARM_REACH)
                robot_lateral = self.BOX_SIZE * (col + 0.5 - w / 2.0)

                self.publish_progress("码垛放置", percent + 5,
                    f"🏗️ 第{layer}层 第{pos_in_layer}个 "
                    f"→ 托盘【{target_pallet}】({target_x:.2f},{target_y:.2f},z={target_z:.2f}) "
                    f"前移{robot_forward:.2f}m 横移{robot_lateral:.2f}m")

                # --- 步骤 A: 先抬升到目标层高 ---
                mani_msg = JointState()
                mani_msg.name = ['lift']
                mani_msg.position = [target_z]
                self.mani_pub.publish(mani_msg)
                rospy.sleep(1.5)

                if layer == 1 and pallet_counts[target_pallet] == 1:
                    # 托盘上第一个箱子: 纯几何位移
                    self.move_relative(robot_forward, robot_lateral)
                    actual_fwd = robot_forward
                else:
                    # 已有箱子做参照: 视觉横向对准 + 视觉/几何前进
                    self.objects_3d = None
                    rospy.sleep(0.3)
                    below_z = target_z - self.BOX_SIZE * 0.6
                    # 横向对准已有箱子 (仅单列时有效, 多列用几何)
                    if w == 1:
                        self.publish_progress("横向对准", percent + 6, "↔ 对准已有箱子...")
                        self.align_lateral_to_object(max_z=below_z)
                    # 几何横向偏移 (到目标列)
                    if abs(robot_lateral) > 0.005:
                        self.move_relative(0, robot_lateral, speed=0.05)
                    # 前进: 第二层+ 用视觉测量, 第一层用几何
                    if layer > 1:
                        need_fwd, _ = self.measure_forward_to_object(max_z=below_z)
                        if need_fwd <= 0:
                            need_fwd = robot_forward
                    else:
                        need_fwd = robot_forward
                    self.publish_progress("前进放置", percent + 7,
                        "🚶 前进 %.3fm..." % need_fwd)
                    self.move_relative(need_fwd, 0)
                    actual_fwd = need_fwd
                    # 前进后二次横向复核 (前进过程可能有偏航/轮滑漂移)
                    if w == 1 and self.task_running:
                        rospy.sleep(0.3)
                        self.align_lateral_to_object(max_z=below_z)
                if not self.task_running:
                    break

                # --- 微降: 让箱子贴紧下方表面，消除掉落间隙防止旋转 ---
                place_z = max(0.15, target_z - 0.05)
                mani_msg.name = ['lift']
                mani_msg.position = [place_z]
                self.mani_pub.publish(mani_msg)
                rospy.sleep(0.8)

                # --- 释放箱子 ---
                mani_msg.name = ['gripper']
                mani_msg.position = [0.16]
                self.mani_pub.publish(mani_msg)
                self.publish_progress("释放箱子", percent + 8,
                    f"📦 松开夹爪 (第{layer}层 {pos_in_layer}/{max_per_layer})")
                rospy.sleep(2.5)
                if not self.task_running:
                    break

                # --- 退回停靠点 (用实际前进量) ---
                self.move_relative(-actual_fwd, -robot_lateral)
                if not self.task_running:
                    break

                # 不主动收回机械臂 — 交由抓取服务器在下一轮 grab start 时自行控制

                self.publish_progress("放置完成", percent + 10,
                    f"✅ 第{layer}层第{pos_in_layer}个箱子已就位")

                # 更新货物记录状态 新增begin
                if self.current_cargo_record_id:
                    self.db.update_cargo_record_status(self.current_cargo_record_id, "已码垛")
        
                # 更新任务进度
                if self.current_task_id:
                    self.db.update_task_progress(self.current_task_id, completed_count=current_item_index)
        
                # 更新码垛位状态
                self.db.update_pallet_slot_state(target_pallet, self.current_task_id, layer)
                # end

                current_item_index += 1
                if current_item_index > total:
                    current_state = "DONE"
                else:
                    current_state = "NAV_TO_PLATFORM"

        # ----------------------------------------------------
        # 状态: 结束或中断
        # ----------------------------------------------------
        if self.task_running and current_state == "DONE":
            self.publish_progress("任务完成", 100, f"🎉 任务完美结束！共计处理 {total} 个货物。")
        else:
            self.move_base_client.cancel_all_goals()
            self.publish_progress("已终止", 0, "🛑 任务已停止运行。已发送底层导航取消指令。")
            
        self.task_running = False

    # 添加新方法：任务统计查询服务
    def get_task_statistics(self, req):
        """获取任务统计信息"""
        import json
        stats = self.db.get_task_statistics()
        cargo_stats = self.db.get_cargo_statistics()
        exception_stats = self.db.get_exception_statistics()
        
        result = {
            'task': stats,
            'cargo': cargo_stats,
            'exception': exception_stats
        }
        return TriggerResponse(True, json.dumps(result, ensure_ascii=False))
    
    # 添加新方法：获取未处理异常
    def get_exceptions(self, req):
        import json
        exceptions = self.db.get_unresolved_exceptions()
        return TriggerResponse(True, json.dumps(exceptions, ensure_ascii=False, default=str))
    
    # 添加新方法：标记异常已处理
    def resolve_exception(self, req):
        try:
            log_id = int(rospy.get_param('/resolve_exception_id', 0))
            self.db.resolve_exception(log_id)
            return TriggerResponse(True, "异常已标记处理")
        except Exception as e:
            return TriggerResponse(False, str(e))
        
if __name__ == '__main__':
    rospy.init_node('system_manager_service')
    manager = SystemManager()
    rospy.spin()