#!/usr/bin/env python3
import rospy
import subprocess
import os
from std_srvs.srv import Trigger, TriggerResponse

class MappingController:
    def __init__(self):
        self.gmapping_process = None
        self.map_name = ""
        
        # 启动服务
        rospy.Service('/start_gmapping', Trigger, self.start_gmapping)
        rospy.Service('/stop_gmapping', Trigger, self.stop_gmapping)
        
        rospy.loginfo("🗺️ 建图控制服务已启动")
    
    def start_gmapping(self, req):
        if self.gmapping_process is not None:
            return TriggerResponse(False, "Gmapping 已在运行")
        
        try:
            # 启动 gmapping launch 文件
            self.gmapping_process = subprocess.Popen(
                ["roslaunch", "monday9", "gmapping.launch"],
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            rospy.loginfo("✅ Gmapping 已启动")
            return TriggerResponse(True, "Gmapping 启动成功")
        except Exception as e:
            rospy.logerr(f"❌ 启动 Gmapping 失败: {e}")
            return TriggerResponse(False, str(e))
    
    def stop_gmapping(self, req):
        if self.gmapping_process is None:
            return TriggerResponse(False, "Gmapping 未在运行")
        
        try:
            self.gmapping_process.terminate()
            self.gmapping_process.wait()
            self.gmapping_process = None
            rospy.loginfo("✅ Gmapping 已停止")
            return TriggerResponse(True, "Gmapping 停止成功")
        except Exception as e:
            rospy.logerr(f"❌ 停止 Gmapping 失败: {e}")
            return TriggerResponse(False, str(e))

if __name__ == '__main__':
    rospy.init_node('mapping_controller')
    controller = MappingController()
    rospy.spin()