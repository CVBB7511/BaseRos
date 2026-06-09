#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
码垛系统 - 图形化操作前端 (Python Tkinter)

功能:
1. 任务下发 (动态读取区域和货物类型)
2. 状态监控与紧急停机/恢复控制
3. 键盘遥控底盘
4. 摄像头画面监控 (可随意开关以节省资源)
"""

import os
# ━━━ WSLg BadLength 修复 ━━━
# 必须在 tkinter/PIL 之前设置，强制使用软件渲染路径，
# 绕过 WSLg Xwayland 的 RENDER 扩展缓冲区限制 (RenderAddGlyphs BadLength)
os.environ.setdefault('LIBGL_ALWAYS_SOFTWARE', '1')

import sys
import io
import time
import threading
import tkinter as tk
from tkinter import ttk, messagebox
from PIL import Image as PILImage, ImageTk

import rospy
from std_msgs.msg import String
from geometry_msgs.msg import Twist
from sensor_msgs.msg import Image, CompressedImage
try:
    from cv_bridge import CvBridge
    import cv2
    HAS_CV = True
except ImportError:
    HAS_CV = False

# --- 样式常量 (羊皮纸风格) ---
BG_COLOR = "#f4f1ea"        # 羊皮纸底色
CARD_BG = "#ffffff"         # 卡片底色
TEXT_COLOR = "#3e3a35"      # 墨色文字
ACCENT_COLOR = "#6c7a89"    # 点缀灰蓝色
RED_BTN = "#d9534f"
GREEN_BTN = "#5cb85c"

# 使用 Tk 内置逻辑字体名，不指定具体字体族，
# 避免触发 CJK 大字形集的一次性预加载导致 X 协议溢出
FONT_MAIN = ("Helvetica", 10)
FONT_TITLE = ("Helvetica", 12, "bold")
FONT_STATUS = ("Helvetica", 11, "bold")

class PalletizingGUI:
    def __init__(self, root: tk.Tk):
        self.root = root
        self.root.title("码垛控制终端 (Sim & Real)")
        self.root.geometry("1000x700")
        self.root.configure(bg=BG_COLOR)
        self.root.protocol("WM_DELETE_WINDOW", self.on_close)

        # ROS 变量
        self.task_pub = rospy.Publisher('/palletizing/task_manager_node/add_task', String, queue_size=10)
        self.state_pub = rospy.Publisher('/palletizing/task_manager_node/set_state', String, queue_size=10)
        self.cmd_pub = rospy.Publisher('/cmd_vel', Twist, queue_size=5)
        
        self.image_sub = None
        self.cv_bridge = CvBridge() if HAS_CV else None
        self.last_frame_time = 0.0
        
        self.teleop_enabled = False
        self.pressed_keys = set()
        
        # 预设参数（硬编码以获得友好的中文显示）
        self.speed = 0.2
        self.turn = 0.3
        
        # 选项显示名 -> 实际后台值的映射
        self.zone_map = {"A区": "A", "B区": "B", "C区": "C"}
        self.cargo_map = {"红色方块": "red_block", "绿色方块": "green_block"}
        
        self.zones_display = list(self.zone_map.keys())
        self.cargo_display = list(self.cargo_map.keys())
        
        # kinect2 话题说明:
        #   仿真 (Gazebo): 只发布 image_color_rect 及其 /compressed 子话题
        #   实机 (kinect2_bridge): 通过 image_transport 自动发布 /compressed 子话题
        # 仅保留系统实际需要的话题，避免误订阅 HD 等高分辨率话题导致 bridge 资源耗尽
        self.camera_topics = [
            "/kinect2/qhd/image_color_rect/compressed", # 推荐：低带宽 JPEG (~1MB/s)
            "/kinect2/qhd/image_color_rect",            # 本地 GUI 原始图
            "/kinect2/qhd/image_color/compressed",      # 实机备选 (无需标定)
        ]

        # 构建界面
        self._build_ui()

        # 订阅状态
        rospy.Subscriber('/palletizing/task_manager_node/task_status', String, self._status_cb, queue_size=1)
        
        # 开启键盘事件轮询
        self._teleop_loop()

    def _load_params(self):
        # 已经改用硬编码，废弃从参数服务器动态读取
        pass

    def _build_ui(self):
        # 使用 grid 划分左右两半
        self.root.columnconfigure(0, weight=1)
        self.root.columnconfigure(1, weight=1)
        self.root.rowconfigure(0, weight=1)

        # 左侧面板 (控制)
        left_frame = tk.Frame(self.root, bg=BG_COLOR)
        left_frame.grid(row=0, column=0, sticky="nsew", padx=10, pady=10)
        
        # 右侧面板 (视觉)
        right_frame = tk.Frame(self.root, bg=BG_COLOR)
        right_frame.grid(row=0, column=1, sticky="nsew", padx=10, pady=10)

        self._build_status_card(left_frame)
        self._build_command_card(left_frame)
        self._build_teleop_card(left_frame)
        self._build_camera_card(right_frame)

    def _build_status_card(self, parent):
        card = tk.Frame(parent, bg=CARD_BG, relief="groove", bd=2)
        card.pack(fill="x", pady=5)
        
        tk.Label(card, text="系统状态监控", font=FONT_TITLE, bg=CARD_BG, fg=TEXT_COLOR).pack(pady=5)
        
        self.lbl_state = tk.Label(card, text="等待连接...", font=FONT_STATUS, bg=CARD_BG, fg=ACCENT_COLOR)
        self.lbl_state.pack(pady=2)
        
        self.lbl_task = tk.Label(card, text="--", font=FONT_MAIN, bg=CARD_BG, fg=TEXT_COLOR)
        self.lbl_task.pack(pady=2)
        
        btn_frame = tk.Frame(card, bg=CARD_BG)
        btn_frame.pack(pady=10)
        
        btn_estop = tk.Button(btn_frame, text="紧急停机", font=FONT_TITLE, bg=RED_BTN, fg="white", 
                              command=lambda: self.state_pub.publish("EMERGENCY_STOP"))
        btn_estop.pack(side="left", padx=20)
        
        btn_idle = tk.Button(btn_frame, text="复位", font=FONT_TITLE, bg=GREEN_BTN, fg="white", 
                             command=lambda: self.state_pub.publish("IDLE"))
        btn_idle.pack(side="right", padx=20)

    def _build_command_card(self, parent):
        card = tk.Frame(parent, bg=CARD_BG, relief="groove", bd=2)
        card.pack(fill="x", pady=5)
        
        tk.Label(card, text="下发自动码垛任务", font=FONT_TITLE, bg=CARD_BG, fg=TEXT_COLOR).pack(pady=5)
        
        grid_f = tk.Frame(card, bg=CARD_BG)
        grid_f.pack(pady=5)
        
        tk.Label(grid_f, text="源区域:", bg=CARD_BG).grid(row=0, column=0, padx=5, pady=5)
        self.cb_src = ttk.Combobox(grid_f, values=self.zones_display, state="readonly", width=10)
        self.cb_src.grid(row=0, column=1, padx=5, pady=5)
        self.cb_src.current(0) # 默认 A区
        
        tk.Label(grid_f, text="货物类型:", bg=CARD_BG).grid(row=0, column=2, padx=5, pady=5)
        self.cb_cargo = ttk.Combobox(grid_f, values=self.cargo_display, state="readonly", width=12)
        self.cb_cargo.grid(row=0, column=3, padx=5, pady=5)
        self.cb_cargo.current(0) # 默认 红色方块
        
        tk.Label(grid_f, text="目标区域:", bg=CARD_BG).grid(row=0, column=4, padx=5, pady=5)
        self.cb_dst = ttk.Combobox(grid_f, values=self.zones_display, state="readonly", width=10)
        self.cb_dst.grid(row=0, column=5, padx=5, pady=5)
        self.cb_dst.current(1) # 默认 B区
        
        btn = tk.Button(card, text="发送任务", font=FONT_MAIN, bg=ACCENT_COLOR, fg="white", command=self._send_task)
        btn.pack(pady=10)

    def _build_teleop_card(self, parent):
        card = tk.Frame(parent, bg=CARD_BG, relief="groove", bd=2)
        card.pack(fill="x", pady=5)
        
        hdr = tk.Frame(card, bg=CARD_BG)
        hdr.pack(fill="x", pady=5, padx=10)
        tk.Label(hdr, text="键盘遥控底盘", font=FONT_TITLE, bg=CARD_BG, fg=TEXT_COLOR).pack(side="left")
        
        self.btn_teleop = tk.Button(hdr, text="开启遥控", bg=ACCENT_COLOR, fg="white", command=self._toggle_teleop)
        self.btn_teleop.pack(side="right")
        
        inst = """[ W ] 前进     [ S ] 后退
[ A ] 左移     [ D ] 右移
[ Q ] 左转     [ E ] 右转
[ 空格 ] 立即停车"""
        
        self.lbl_teleop = tk.Label(card, text=inst, font=("Consolas", 11), bg="#eeeeee", fg="#555555", justify="left")
        self.lbl_teleop.pack(pady=10, padx=20, fill="x")

        # 绑定全局按键事件 (只有 teleop_enabled 时生效)
        self.root.bind("<KeyPress>", self._on_key_press)
        self.root.bind("<KeyRelease>", self._on_key_release)

    def _build_camera_card(self, parent):
        card = tk.Frame(parent, bg=CARD_BG, relief="groove", bd=2)
        card.pack(fill="both", expand=True, pady=5)
        
        hdr = tk.Frame(card, bg=CARD_BG)
        hdr.pack(fill="x", pady=5, padx=10)
        
        tk.Label(hdr, text="视觉监控", font=FONT_TITLE, bg=CARD_BG, fg=TEXT_COLOR).pack(side="left")
        
        self.cb_topic = ttk.Combobox(hdr, values=self.camera_topics, state="readonly", width=25)
        self.cb_topic.pack(side="left", padx=10)
        self.cb_topic.current(0)
        
        self.btn_cam = tk.Button(hdr, text="打开画面", bg=ACCENT_COLOR, fg="white", command=self._toggle_camera)
        self.btn_cam.pack(side="right")
        
        self.lbl_image = tk.Label(card, text="画面已关闭以节省算力", bg="#333333", fg="white")
        self.lbl_image.pack(fill="both", expand=True, padx=5, pady=5)

    # --- 逻辑处理 ---

    def _send_task(self):
        src_disp = self.cb_src.get()
        cargo_disp = self.cb_cargo.get()
        dst_disp = self.cb_dst.get()
        if not src_disp or not dst_disp or not cargo_disp:
            messagebox.showwarning("警告", "请完整选择源、目标和货物类型！")
            return
            
        src = self.zone_map.get(src_disp, "A")
        cargo = self.cargo_map.get(cargo_disp, "red_block")
        dst = self.zone_map.get(dst_disp, "B")
        
        cmd_str = f"{src},{cargo},{dst}"
        self.task_pub.publish(cmd_str)
        rospy.loginfo(f"前端发送任务: {cmd_str}")

    def _status_cb(self, msg: String):
        # 格式: STATE|cargo|src->tgt|msg
        parts = msg.data.split("|")
        if len(parts) >= 1:
            state = parts[0]
            if state == "EMERGENCY_STOP":
                self.lbl_state.config(text="[STOP] " + state, fg=RED_BTN)
            elif state == "IDLE":
                self.lbl_state.config(text="[OK] " + state, fg=GREEN_BTN)
            elif state == "ERROR":
                self.lbl_state.config(text="[ERR] " + state, fg=RED_BTN)
            else:
                self.lbl_state.config(text="[...] " + state, fg=ACCENT_COLOR)
                
            if len(parts) >= 4:
                task_desc = f"{parts[1]} ({parts[2]})"
                msg_desc = parts[3] if len(parts)>3 else ""
                self.lbl_task.config(text=f"{task_desc}\n{msg_desc}")
            else:
                self.lbl_task.config(text=msg.data)

    def _toggle_teleop(self):
        self.teleop_enabled = not self.teleop_enabled
        if self.teleop_enabled:
            self.btn_teleop.config(text="关闭遥控", bg=RED_BTN)
            self.lbl_teleop.config(bg="#d9edf7", fg="#31708f") # 激活颜色
            self.pressed_keys.clear()
        else:
            self.btn_teleop.config(text="开启遥控", bg=ACCENT_COLOR)
            self.lbl_teleop.config(bg="#eeeeee", fg="#555555")
            # 立即发零速
            self.cmd_pub.publish(Twist())
            
    def _on_key_press(self, event):
        if not self.teleop_enabled: return
        key = event.keysym.lower()
        if key in ['w', 'a', 's', 'd', 'q', 'e', 'space']:
            self.pressed_keys.add(key)

    def _on_key_release(self, event):
        if not self.teleop_enabled: return
        key = event.keysym.lower()
        if key in self.pressed_keys:
            self.pressed_keys.remove(key)

    def _teleop_loop(self):
        """10Hz 频率根据当前按下的键发布速度"""
        if self.teleop_enabled:
            x, y, th = 0.0, 0.0, 0.0
            if 'w' in self.pressed_keys: x = self.speed
            if 's' in self.pressed_keys: x = -self.speed
            if 'a' in self.pressed_keys: y = self.speed
            if 'd' in self.pressed_keys: y = -self.speed
            if 'q' in self.pressed_keys: th = self.turn
            if 'e' in self.pressed_keys: th = -self.turn
            if 'space' in self.pressed_keys: 
                x, y, th = 0.0, 0.0, 0.0
                
            t = Twist()
            t.linear.x, t.linear.y, t.angular.z = x, y, th
            self.cmd_pub.publish(t)
            
        self.root.after(100, self._teleop_loop)

    def _toggle_camera(self):
        if self.image_sub is None:
            # 打开
            topic = self.cb_topic.get()
            is_compressed = topic.endswith("/compressed")
            if is_compressed:
                # 压缩图像：无需 cv_bridge，直接用 PIL 解码 JPEG，带宽友好
                self.image_sub = rospy.Subscriber(
                    topic, CompressedImage, self._compressed_image_cb, queue_size=1
                )
            else:
                # 原始图像：需要 cv_bridge
                if not HAS_CV:
                    messagebox.showerror("缺少依赖", "原始图像话题需要 cv_bridge，\n建议改用 /compressed 话题！")
                    return
                self.image_sub = rospy.Subscriber(
                    topic, Image, self._image_cb, queue_size=1
                )
            self.btn_cam.config(text="关闭画面", bg=RED_BTN)
            self.lbl_image.config(text="正在等待图像数据...", image="")
        else:
            # 关闭
            self.image_sub.unregister()
            self.image_sub = None
            self.btn_cam.config(text="打开画面", bg=ACCENT_COLOR)
            self.lbl_image.config(image="", text="画面已关闭以节省算力")
            
    def _compressed_image_cb(self, msg: CompressedImage):
        """接收 CompressedImage（JPEG），无需 cv_bridge，带宽极低，适合无线分布式 ROS。"""
        if self.image_sub is None:
            return
        now = time.time()
        if now - self.last_frame_time < 0.2:  # 限制最高 5 FPS
            return
        self.last_frame_time = now
        try:
            # JPEG 字节流直接交给 PIL 解码，无需 cv_bridge
            img = PILImage.open(io.BytesIO(bytes(msg.data)))
            img = img.convert("RGB")
            # 缩放
            max_w = self.lbl_image.winfo_width()
            if max_w > 10 and img.width > max_w:
                ratio = max_w / img.width
                img = img.resize((max_w, int(img.height * ratio)), PILImage.LANCZOS)
            imgtk = ImageTk.PhotoImage(image=img)
            self.root.after(0, self._update_image_label, imgtk)
        except Exception as e:
            err_msg = f"压缩图像解码错误: {e}"
            rospy.logerr(err_msg)
            self.root.after(0, lambda: self.lbl_image.config(text=err_msg, image=""))

    def _image_cb(self, msg: Image):
        """接收原始 Image（仅有线/局域网场景使用，带宽高）。"""
        if self.image_sub is None: return
        
        now = time.time()
        if now - self.last_frame_time < 0.2:  # 限制最高 5 FPS
            return
        self.last_frame_time = now
        
        if not HAS_CV:
            self.root.after(0, lambda: self.lbl_image.config(
                text="缺少 cv_bridge，请改用 /compressed 话题", image=""))
            return
        try:
            cv_img = self.cv_bridge.imgmsg_to_cv2(msg, desired_encoding="passthrough")
            enc = msg.encoding.lower()
            if enc in ("bgr8", "bgra8", "8uc3"):
                cv_img = cv2.cvtColor(cv_img, cv2.COLOR_BGR2RGB)
            elif enc in ("mono8", "8uc1"):
                cv_img = cv2.cvtColor(cv_img, cv2.COLOR_GRAY2RGB)
            elif enc not in ("rgb8", "rgba8"):
                cv_img = cv2.cvtColor(cv_img, cv2.COLOR_BGR2RGB)
            h, w = cv_img.shape[:2]
            max_w = self.lbl_image.winfo_width()
            if max_w > 10 and w > max_w:
                ratio = max_w / w
                cv_img = cv2.resize(cv_img, (max_w, int(h * ratio)))
            img = PILImage.fromarray(cv_img)
            imgtk = ImageTk.PhotoImage(image=img)
            self.root.after(0, self._update_image_label, imgtk)
        except Exception as e:
            err_msg = f"图像转换错误: {e}"
            rospy.logerr(err_msg)
            self.root.after(0, lambda: self.lbl_image.config(text=err_msg, image=""))


    def _update_image_label(self, imgtk):
        if self.image_sub is not None:
            self.lbl_image.imgtk = imgtk
            self.lbl_image.config(image=imgtk, text="")

    def on_close(self):
        self.cmd_pub.publish(Twist()) # 安全停车
        rospy.signal_shutdown("GUI closed")
        self.root.destroy()

if __name__ == '__main__':
    rospy.init_node('palletizing_gui_frontend', anonymous=True, disable_signals=True)
    root = tk.Tk()
    app = PalletizingGUI(root)
    root.mainloop()
