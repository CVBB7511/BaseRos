#include <ros/ros.h>
#include <std_msgs/Float64.h>
#include <std_msgs/String.h>
#include <iostream>
#include <string>
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
#include <cmath>

class RobotArmController
{
private:
    ros::NodeHandle nh_;
    
    // ========== 机械臂控制发布者 ==========
    // 升降臂
    ros::Publisher lift_pub_;
    // 肘关节
    ros::Publisher elbow_pub_;
    // 夹爪系统（4个关节）
    ros::Publisher left_finger_pub_;   // 左手指
    ros::Publisher left_tip_pub_;      // 左指尖
    ros::Publisher right_finger_pub_;  // 右手指
    ros::Publisher right_tip_pub_;     // 右指尖
    
    // ========== 高层接口 ==========
    ros::Publisher behaviors_pub_;
    ros::Subscriber grab_result_sub_;
    
    // ========== 关节参数 ==========
    // 升降臂（prismatic joint）
    const double LIFT_MIN = 0.0;
    const double LIFT_MAX = 0.7;
    
    // 肘关节（revolute joint）
    const double ELBOW_MIN = 0.0;
    const double ELBOW_MAX = 1.57;
    
    // 夹爪范围
    const double FINGER_OPEN = 1.57;     // 手指完全张开
    const double FINGER_CLOSE = -0.07;   // 手指完全闭合
    const double TIP_MAX = 1.57;         // 指尖最大角度
    const double TIP_MIN = -1.57;        // 指尖最小角度
    
    // 当前状态
    double current_lift_;
    double current_elbow_;
    double current_finger_angle_;
    
    // 键盘设置
    struct termios old_term_;
    
public:
    RobotArmController()
    {
        // ========== 初始化发布者 ==========
        // 升降臂
        lift_pub_ = nh_.advertise<std_msgs::Float64>(
            "/wpb_home/mani_base_position_controller/command", 10);
        
        // 肘关节
        elbow_pub_ = nh_.advertise<std_msgs::Float64>(
            "/wpb_home/elbow_forearm_position_controller/command", 10);
        
        // 左手指（主控制）
        left_finger_pub_ = nh_.advertise<std_msgs::Float64>(
            "/wpb_home/palm_left_finger_position_controller/command", 10);
        
        // 左指尖（用于补偿，保持朝向）
        left_tip_pub_ = nh_.advertise<std_msgs::Float64>(
            "/wpb_home/left_finger_tip_position_controller/command", 10);
        
        // 右手指（对称跟随）
        right_finger_pub_ = nh_.advertise<std_msgs::Float64>(
            "/wpb_home/palm_right_finger_position_controller/command", 10);
        
        // 右指尖（对称补偿）
        right_tip_pub_ = nh_.advertise<std_msgs::Float64>(
            "/wpb_home/right_finger_tip_position_controller/command", 10);
        
        // 高层行为接口
        behaviors_pub_ = nh_.advertise<std_msgs::String>("/wpb_home/behaviors", 10);
        grab_result_sub_ = nh_.subscribe("/wpb_home/grab_result", 10, 
                                         &RobotArmController::grabResultCallback, this);
        
        // 初始化状态
        current_lift_ = 0.0;
        current_elbow_ = 0.0;
        current_finger_angle_ = FINGER_OPEN;
        
        // 等待连接建立
        ros::Duration(0.5).sleep();
        
        // 打印启动信息
        printStartupInfo();
    }
    
    ~RobotArmController()
    {
        tcsetattr(STDIN_FILENO, TCSANOW, &old_term_);
    }
    
    void printStartupInfo()
    {
        ROS_INFO("========================================");
        ROS_INFO("   机器人机械臂控制系统");
        ROS_INFO("========================================");
        ROS_INFO("【控制特性】");
        ROS_INFO("  - 升降臂: 独立控制");
        ROS_INFO("  - 肘关节: 独立控制");
        ROS_INFO("  - 夹爪:   手指运动时，指尖主动反向补偿");
        ROS_INFO("            保持指尖相对于地面的朝向不变");
        ROS_INFO("========================================");
        ROS_INFO("【关节范围】");
        ROS_INFO("  升降臂: %.2f ~ %.2f 米", LIFT_MIN, LIFT_MAX);
        ROS_INFO("  肘关节: %.2f ~ %.2f 弧度", ELBOW_MIN, ELBOW_MAX);
        ROS_INFO("  手指:   %.2f(闭) ~ %.2f(开) 弧度", FINGER_CLOSE, FINGER_OPEN);
        ROS_INFO("  指尖:   %.2f ~ %.2f 弧度 (自动补偿)", TIP_MIN, TIP_MAX);
        ROS_INFO("========================================");
    }
    
    // ========== 升降臂控制 ==========
    void setLift(double position)
    {
        if (position < LIFT_MIN) position = LIFT_MIN;
        if (position > LIFT_MAX) position = LIFT_MAX;
        
        std_msgs::Float64 msg;
        msg.data = position;
        lift_pub_.publish(msg);
        current_lift_ = position;
        
        ROS_INFO("升降臂: %.3f 米", position);
    }
    
    // ========== 肘关节控制 ==========
    void setElbow(double position)
    {
        if (position < ELBOW_MIN) position = ELBOW_MIN;
        if (position > ELBOW_MAX) position = ELBOW_MAX;
        
        std_msgs::Float64 msg;
        msg.data = position;
        elbow_pub_.publish(msg);
        current_elbow_ = position;
        
        ROS_INFO("肘关节: %.3f 弧度 (%.1f度)", position, position * 180 / M_PI);
    }
    
    // ========== 核心：夹爪控制（保持指尖朝向） ==========
    void setGripper(double finger_angle)
    {
        // 限制手指角度范围
        if (finger_angle < FINGER_CLOSE) finger_angle = FINGER_CLOSE;
        if (finger_angle > FINGER_OPEN) finger_angle = FINGER_OPEN;
        
        // 1. 控制左手指
        std_msgs::Float64 finger_msg;
        finger_msg.data = finger_angle;
        left_finger_pub_.publish(finger_msg);
        
        // 2. 控制右手指（对称反向，保证夹爪对称开合）
        std_msgs::Float64 right_finger_msg;
        right_finger_msg.data = -finger_angle;
        right_finger_pub_.publish(right_finger_msg);
        
        // 3. 关键：左指尖反向补偿，保持物理朝向不变
        //    原理：左指尖角度 = -手指角度
        //    这样指尖相对于世界的绝对角度 = 手指角度 + 指尖角度 = 手指角度 + (-手指角度) = 0
        double left_tip_angle = -finger_angle;
        
        // 限制指尖范围
        if (left_tip_angle > TIP_MAX) left_tip_angle = TIP_MAX;
        if (left_tip_angle < TIP_MIN) left_tip_angle = TIP_MIN;
        
        std_msgs::Float64 left_tip_msg;
        left_tip_msg.data = left_tip_angle;
        left_tip_pub_.publish(left_tip_msg);
        
        // 4. 控制右指尖（对称补偿）
        //    为了保持夹爪对称，右指尖需要与左指尖对称
        double right_tip_angle = finger_angle;
        if (right_tip_angle > TIP_MAX) right_tip_angle = TIP_MAX;
        if (right_tip_angle < TIP_MIN) right_tip_angle = TIP_MIN;
        
        std_msgs::Float64 right_tip_msg;
        right_tip_msg.data = right_tip_angle;
        right_tip_pub_.publish(right_tip_msg);
        
        current_finger_angle_ = finger_angle;
        
        // 打印详细信息
        ROS_INFO("=========================================");
        ROS_INFO("夹爪控制 - 保持指尖朝向不变");
        ROS_INFO("  左手指: %+.3f rad (%+.1f°)", finger_angle, finger_angle * 180 / M_PI);
        ROS_INFO("  右手指: %+.3f rad (%+.1f°)", -finger_angle, -finger_angle * 180 / M_PI);
        ROS_INFO("  左指尖: %+.3f rad (%+.1f°) [补偿]", left_tip_angle, left_tip_angle * 180 / M_PI);
        ROS_INFO("  右指尖: %+.3f rad (%+.1f°) [补偿]", right_tip_angle, right_tip_angle * 180 / M_PI);
        ROS_INFO("  效果: 指尖绝对朝向 = 手指角度 + 指尖角度 = 0");
        ROS_INFO("=========================================");
    }
    
    // 张开夹爪
    void openGripper()
    {
        ROS_WARN(">>> 张开夹爪，保持指尖朝向 <<<");
        setGripper(FINGER_OPEN);
    }
    
    // 闭合夹爪
    void closeGripper()
    {
        ROS_WARN(">>> 闭合夹爪，保持指尖朝向 <<<");
        setGripper(FINGER_CLOSE);
    }
    
    // 夹爪微张开
    void openGripperSmall()
    {
        ROS_WARN(">>> 微张开夹爪 <<<");
        setGripper(0.5);
    }
    
    // 夹爪微闭合
    void closeGripperSmall()
    {
        ROS_WARN(">>> 微闭合夹爪 <<<");
        setGripper(0.2);
    }
    
    // ========== 高层行为接口 ==========
    void grabStart()
    {
        std_msgs::String msg;
        msg.data = "grab start";
        behaviors_pub_.publish(msg);
        ROS_WARN(">>> 启动完整抓取流程 (高层接口) <<<");
    }
    
    void grabStop()
    {
        std_msgs::String msg;
        msg.data = "grab stop";
        behaviors_pub_.publish(msg);
        ROS_INFO("停止抓取");
    }
    
    void grabResultCallback(const std_msgs::String::ConstPtr& msg)
    {
        ROS_INFO("抓取结果反馈: %s", msg->data.c_str());
    }
    
    // ========== 机械臂复位 ==========
    void resetArm()
    {
        ROS_WARN("========== 机械臂复位 ==========");
        
        // 先复位肘关节
        setElbow(0.0);
        ros::Duration(0.3).sleep();
        
        // 再复位升降臂
        setLift(0.0);
        ros::Duration(0.3).sleep();
        
        // 最后张开夹爪
        openGripper();
        
        ROS_WARN("========== 机械臂已复位 ==========");
    }
    
    // ========== 预设姿势 ==========
    void presetGrabPose()
    {
        ROS_WARN("========== 设置抓取姿势 ==========");
        setLift(0.35);
        ros::Duration(0.3).sleep();
        setElbow(0.8);
        ros::Duration(0.3).sleep();
        openGripper();
        ROS_WARN("========== 抓取姿势设置完成 ==========");
    }
    
    // ========== 键盘控制 ==========
    void setupKeyboard()
    {
        tcgetattr(STDIN_FILENO, &old_term_);
        struct termios new_term = old_term_;
        new_term.c_lflag &= ~(ICANON | ECHO);
        tcsetattr(STDIN_FILENO, TCSANOW, &new_term);
        fcntl(STDIN_FILENO, F_SETFL, fcntl(STDIN_FILENO, F_GETFL) | O_NONBLOCK);
    }
    
    void printHelp()
    {
        std::cout << "\n╔══════════════════════════════════════════════════════════════╗" << std::endl;
        std::cout << "║              机器人机械臂控制系统 - 命令菜单                  ║" << std::endl;
        std::cout << "╠══════════════════════════════════════════════════════════════╣" << std::endl;
        std::cout << "║ 【升降臂】                                                  ║" << std::endl;
        std::cout << "║   q - 升到最高 (0.70米)      a - 降到最低 (0.00米)         ║" << std::endl;
        std::cout << "║   z - 升到中间 (0.35米)                                     ║" << std::endl;
        std::cout << "║                                                             ║" << std::endl;
        std::cout << "║ 【肘关节】                                                  ║" << std::endl;
        std::cout << "║   w - 最大弯曲 (1.57rad)     s - 伸直 (0.00rad)            ║" << std::endl;
        std::cout << "║   x - 中间角度 (0.80rad)                                    ║" << std::endl;
        std::cout << "║                                                             ║" << std::endl;
        std::cout << "║ 【夹爪 - 保持指尖朝向不变】                                  ║" << std::endl;
        std::cout << "║   e - 完全张开               d - 完全闭合                  ║" << std::endl;
        std::cout << "║   r - 微张开                 f - 微闭合                    ║" << std::endl;
        std::cout << "║                                                             ║" << std::endl;
        std::cout << "║ 【预设动作】                                                ║" << std::endl;
        std::cout << "║   g - 抓取姿势 (升降0.35 + 肘0.8 + 张开)                   ║" << std::endl;
        std::cout << "║   t - 机械臂复位                                            ║" << std::endl;
        std::cout << "║                                                             ║" << std::endl;
        std::cout << "║ 【高层接口】                                                ║" << std::endl;
        std::cout << "║   v - 完整抓取流程 (自动对位+抓取)                          ║" << std::endl;
        std::cout << "║   b - 停止抓取                                              ║" << std::endl;
        std::cout << "║                                                             ║" << std::endl;
        std::cout << "║ 【其他】                                                    ║" << std::endl;
        std::cout << "║   h - 显示帮助                 ESC - 退出                  ║" << std::endl;
        std::cout << "╚══════════════════════════════════════════════════════════════╝" << std::endl;
        
        std::cout << "\n【核心特性】手指运动时，指尖主动反向补偿，保持物理朝向不变！\n" << std::endl;
    }
    
    void keyboardControl()
    {
        setupKeyboard();
        printHelp();
        
        char c;
        while (ros::ok())
        {
            if (read(STDIN_FILENO, &c, 1) > 0)
            {
                switch (c)
                {
                    // 升降臂
                    case 'q': setLift(LIFT_MAX); break;
                    case 'a': setLift(LIFT_MIN); break;
                    case 'z': setLift(0.35); break;
                    
                    // 肘关节
                    case 'w': setElbow(ELBOW_MAX); break;
                    case 's': setElbow(ELBOW_MIN); break;
                    case 'x': setElbow(0.8); break;
                    
                    // 夹爪（保持朝向）
                    case 'e': openGripper(); break;
                    case 'd': closeGripper(); break;
                    case 'r': openGripperSmall(); break;
                    case 'f': closeGripperSmall(); break;
                    
                    // 预设动作
                    case 'g': presetGrabPose(); break;
                    case 't': resetArm(); break;
                    
                    // 高层接口
                    case 'v': grabStart(); break;
                    case 'b': grabStop(); break;
                    
                    // 帮助
                    case 'h': printHelp(); break;
                    
                    // 退出
                    case 27:
                        ROS_INFO("退出程序");
                        return;
                        
                    default:
                        break;
                }
                ros::spinOnce();
            }
            ros::Duration(0.05).sleep();
        }
    }
};

int main(int argc, char** argv)
{
    ros::init(argc, argv, "robot_arm_controller");
    
    RobotArmController controller;
    controller.keyboardControl();
    
    return 0;
}