/*********************************************************************
* Software License Agreement (BSD License)
* 
*  Copyright (c) 2017-2020, Waterplus http://www.6-robot.com
*  All rights reserved.
* 
*  Redistribution and use in source and binary forms, with or without
*  modification, are permitted provided that the following conditions
*  are met:
* 
*   * Redistributions of source code must retain the above copyright
*     notice, this list of conditions and the following disclaimer.
*   * Redistributions in binary form must reproduce the above
*     copyright notice, this list of conditions and the following
*     disclaimer in the documentation and/or other materials provided
*     with the distribution.
*   * Neither the name of the WaterPlus nor the names of its
*     contributors may be used to endorse or promote products derived
*     from this software without specific prior written permission.
* 
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
*  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
*  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
*  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
*  FOOTPRINTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
*  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
*  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
*  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
*  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
*  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
*  POSSIBILITY OF SUCH DAMAGE.
*********************************************************************/
/*!******************************************************************
 @author     ZhangWanjie
 ********************************************************************/

#include <ros/ros.h>
#include <geometry_msgs/Pose2D.h>
#include <geometry_msgs/Pose.h>
#include <geometry_msgs/Twist.h>
#include <sensor_msgs/JointState.h>
#include <std_msgs/String.h>
#include <tf/transform_broadcaster.h>

// 放置参数调节（单位：米）
static float place_dist = 0.9;               //机器人放置前和目标点距离
static float place_y_offset = 0.0f;          //机器人的横向位移补偿量
static float place_lift_offset = 0.0f;       //手臂抬起高度的补偿量
static float place_forward_offset = 0.0f;    //手臂抬起后，机器人向前移动的位移补偿量
static float place_lift_clearance = 0.01f;   //释放前比目标中心高度略高的余量
static float place_hand_up_wait = 4.0f;      //放置前等待手臂到位的时间，避免边走边抬
static float place_release_wait = 1.0f;      //前进到位后，松爪前等待稳定的时间
static float place_hold_gripper_value = 0.032f; //放置靠近过程中保持夹紧的手爪宽度
static float place_gripper_value = 0.15;     //放置物品时，手爪松开后的手指间距
static int place_release_hold_ticks = 8*30;  //释放后保持开爪时间，30Hz

static float vel_max = 0.3;                     //移动限速

#define STEP_WAIT           0
#define STEP_HAND_UP        1
#define STEP_PLACE_DIST     2
#define STEP_FORWARD        3
#define STEP_RELEASE_WAIT   4
#define STEP_RELEASE        5
#define STEP_BACKWARD       6
#define STEP_Y_BACK         7
#define STEP_DONE           8
static int nStep = STEP_WAIT;

static std::string pc_topic;
static ros::Publisher vel_pub;
static ros::Publisher mani_ctrl_pub;
static sensor_msgs::JointState mani_ctrl_msg;
static ros::Publisher result_pub;
static std_msgs::String result_msg;
static ros::Publisher odom_ctrl_pub;
static std_msgs::String odom_ctrl_msg;
static geometry_msgs::Pose2D pose_diff;

void VelCmd(float inVx , float inVy, float inTz);

static float fPlaceX = 0;
static float fPlaceY = 0;
static float fPlaceZ = 0;
static float fMoveTargetX = 0;
static float fMoveTargetY = 0;

static int nTimeDelayCounter = 0;

void PlaceActionCallback(const geometry_msgs::Pose::ConstPtr& msg)
{
    ros::NodeHandle pnh("~");
    pnh.param("place_hold_gripper_value", place_hold_gripper_value, place_hold_gripper_value);
    pnh.param("place_gripper_value", place_gripper_value, place_gripper_value);
    mani_ctrl_msg.position[1] = place_hold_gripper_value;

    // 放置物品的坐标
    fPlaceX = msg->position.x;
    fPlaceY = msg->position.y;
    fPlaceZ = msg->position.z;
    ROS_WARN("[Place] x = %.2f y= %.2f ,z= %.2f hold=%.3f release=%.3f",
             fPlaceX, fPlaceY, fPlaceZ,
             place_hold_gripper_value, place_gripper_value);
    odom_ctrl_msg.data = "pose_diff reset";
    odom_ctrl_pub.publish(odom_ctrl_msg);

    // ajudge the dist to place
    fMoveTargetX = fPlaceX - place_dist;
    fMoveTargetY = fPlaceY + place_y_offset;
    ROS_WARN("[MOVE_TARGET] x = %.2f y= %.2f " ,fMoveTargetX, fMoveTargetY);
    nTimeDelayCounter = 0;
    nStep = STEP_HAND_UP;
}

void PoseDiffCallback(const geometry_msgs::Pose2D::ConstPtr& msg)
{
    pose_diff.x = msg->x;
    pose_diff.y = msg->y;
    pose_diff.theta = msg->theta;
}

float VelFixed(float inVel,float inMax)
{
    float retVel = inVel;
    if(retVel > inMax)
        retVel = inMax;
    if(retVel < -inMax)
        retVel = -inMax;
    return retVel;
}

void VelCmd(float inVx , float inVy, float inTz)
{
    geometry_msgs::Twist vel_cmd;
    vel_cmd.linear.x = VelFixed(inVx , vel_max);
    vel_cmd.linear.y = VelFixed(inVy , vel_max);
    vel_cmd.angular.z = VelFixed(inTz , vel_max);
    vel_pub.publish(vel_cmd);
}

void BehaviorCB(const std_msgs::String::ConstPtr &msg)
{
    int nFindIndex = msg->data.find("place stop");
    if( nFindIndex >= 0 )
    {
        ROS_WARN("[place stop] ");
        nStep = STEP_WAIT;
        geometry_msgs::Twist vel_cmd;
        vel_cmd.linear.x = 0;
        vel_cmd.linear.y = 0;
        vel_cmd.linear.z = 0;
        vel_cmd.angular.x = 0;
        vel_cmd.angular.y = 0;
        vel_cmd.angular.z = 0;
        vel_pub.publish(vel_cmd);
    }

}

int main(int argc, char **argv)
{
    ros::init(argc, argv, "wpb_home_place_action");
    ROS_INFO("wpb_home_place_action");

    ros::NodeHandle nh;
    ros::NodeHandle pnh("~");

    pnh.param("place_dist", place_dist, place_dist);
    pnh.param("place_y_offset", place_y_offset, place_y_offset);
    pnh.param("place_lift_offset", place_lift_offset, place_lift_offset);
    pnh.param("place_forward_offset", place_forward_offset, place_forward_offset);
    pnh.param("place_lift_clearance", place_lift_clearance, place_lift_clearance);
    pnh.param("place_hand_up_wait", place_hand_up_wait, place_hand_up_wait);
    pnh.param("place_release_wait", place_release_wait, place_release_wait);
    pnh.param("place_hold_gripper_value", place_hold_gripper_value, place_hold_gripper_value);
    pnh.param("place_gripper_value", place_gripper_value, place_gripper_value);
    pnh.param("place_release_hold_ticks", place_release_hold_ticks, place_release_hold_ticks);
    pnh.param("vel_max", vel_max, vel_max);

    vel_pub = nh.advertise<geometry_msgs::Twist>("/cmd_vel", 30);
    mani_ctrl_pub = nh.advertise<sensor_msgs::JointState>("/wpb_home/mani_ctrl", 30);
    result_pub = nh.advertise<std_msgs::String>("/wpb_home/place_result", 30);

    ros::Subscriber sub_grab_pose = nh.subscribe("/wpb_home/place_action", 1, PlaceActionCallback);
    ros::Subscriber sub_beh = nh.subscribe("/wpb_home/behaviors", 30, BehaviorCB);
    odom_ctrl_pub = nh.advertise<std_msgs::String>("/wpb_home/ctrl", 30);
    ros::Subscriber pose_diff_sub = nh.subscribe("/wpb_home/pose_diff", 1, PoseDiffCallback);

    mani_ctrl_msg.name.resize(2);
    mani_ctrl_msg.position.resize(2);
    mani_ctrl_msg.velocity.resize(2);
    mani_ctrl_msg.name[0] = "lift";
    mani_ctrl_msg.name[1] = "gripper";
    mani_ctrl_msg.position[0] = 0;
    mani_ctrl_msg.velocity[0] = 0.5;     //升降速度(单位:米/秒)
    mani_ctrl_msg.position[1] = place_hold_gripper_value;
    mani_ctrl_msg.velocity[1] = 5;       //手爪开合角速度(单位:度/秒)

    ros::Rate r(30);
    while(nh.ok())
    {
        //1、先抬起手臂并等待到位，底盘不移动
        if(nStep == STEP_HAND_UP)
        {
            if(nTimeDelayCounter == 0)
            {
                mani_ctrl_msg.position[0] = fPlaceZ + place_lift_clearance + place_lift_offset;
                mani_ctrl_pub.publish(mani_ctrl_msg);
                ROS_WARN("[STEP_HAND_UP] lift= %.2f gripper= %.2f wait= %.2f",
                         mani_ctrl_msg.position[0], mani_ctrl_msg.position[1], place_hand_up_wait);
                result_msg.data = "hand up";
                result_pub.publish(result_msg);
            }

            nTimeDelayCounter++;
            VelCmd(0,0,0);
            mani_ctrl_pub.publish(mani_ctrl_msg);

            if(nTimeDelayCounter > place_hand_up_wait * 30)
            {
                odom_ctrl_msg.data = "pose_diff reset";
                odom_ctrl_pub.publish(odom_ctrl_msg);
                nTimeDelayCounter = 0;
                nStep = STEP_PLACE_DIST;
                continue;
            }
        }

        //2、左右平移对准放置目标点
        if(nStep == STEP_PLACE_DIST)
        {
            float vx,vy;
            vx = (fMoveTargetX - pose_diff.x)/2;
            vy = (fMoveTargetY - pose_diff.y)/2;
            //ROS_INFO("[MOVE] T(%.2f %.2f)  od(%.2f , %.2f) v(%.2f,%.2f)" ,fMoveTargetX, fMoveTargetY, pose_diff.x ,pose_diff.y,vx,vy);
            if(fabs(vx) < 0.01 && fabs(vy) < 0.01)
            {
                VelCmd(0,0,0);
                if(nTimeDelayCounter > 8*30)
                {
                    odom_ctrl_msg.data = "pose_diff reset";
                    odom_ctrl_pub.publish(odom_ctrl_msg);
                    fMoveTargetX = place_dist - 0.65 + place_forward_offset;
                    fMoveTargetY = 0;
                    nTimeDelayCounter = 0;
                    nStep = STEP_FORWARD;
                    continue;
                }
            }
            else
            {
                VelCmd(vx,vy,0);
            }

            mani_ctrl_pub.publish(mani_ctrl_msg);
            nTimeDelayCounter ++;

            result_msg.data = "dist to place";
            result_pub.publish(result_msg);
        }

        //3、前进靠近放置点
        if(nStep == STEP_FORWARD)
        {
            float vx,vy;
            vx = (fMoveTargetX - pose_diff.x)/2;
            vy = (fMoveTargetY - pose_diff.y)/2;

            VelCmd(vx,vy,0);
            //ROS_INFO("[STEP_FORWARD] T(%.2f %.2f)  od(%.2f , %.2f) v(%.2f,%.2f)" ,fMoveTargetX, fMoveTargetY, pose_diff.x ,pose_diff.y,vx,vy);

            if(fabs(vx) < 0.01 && fabs(vy) < 0.01)
            {
                VelCmd(0,0,0);
                odom_ctrl_msg.data = "pose_diff reset";
                odom_ctrl_pub.publish(odom_ctrl_msg);
                nTimeDelayCounter = 0;
                ROS_WARN("[STEP_RELEASE_WAIT] lift= %.2f gripper= %.2f wait= %.2f",
                         mani_ctrl_msg.position[0], mani_ctrl_msg.position[1], place_release_wait);
                nStep = STEP_RELEASE_WAIT;
            }

            result_msg.data = "forward";
            result_pub.publish(result_msg);
        }

        //4、前进到位后先稳定，再松开，避免叠放时过早掉落
        if(nStep == STEP_RELEASE_WAIT)
        {
            nTimeDelayCounter++;
            VelCmd(0,0,0);
            mani_ctrl_pub.publish(mani_ctrl_msg);

            result_msg.data = "release wait";
            result_pub.publish(result_msg);

            if(nTimeDelayCounter > place_release_wait * 30)
            {
                nTimeDelayCounter = 0;
                ROS_WARN("[STEP_RELEASE] place_gripper_value = %.2f",place_gripper_value);
                nStep = STEP_RELEASE;
            }
        }

        //5、释放物品
        if(nStep == STEP_RELEASE)
        {
            if(nTimeDelayCounter == 0)
            {
                result_msg.data = "release";
                result_pub.publish(result_msg);
            }
            mani_ctrl_msg.position[1] = place_gripper_value;      //释放物品手爪闭合宽度
            mani_ctrl_pub.publish(mani_ctrl_msg);
            //ROS_WARN("[STEP_RELEASE] lift= %.2f  gripper= %.2f " ,mani_ctrl_msg.position[0], mani_ctrl_msg.position[1]);

            nTimeDelayCounter++;
            VelCmd(0,0,0);
            if(nTimeDelayCounter > place_release_hold_ticks)
            {
                nTimeDelayCounter = 0;
                fMoveTargetX = -(fPlaceX - 0.65 + place_forward_offset);
                //fMoveTargetY = 0;
                fMoveTargetY = -(fPlaceY + place_y_offset);
                ROS_WARN("[STEP_BACKWARD] x= %.2f y= %.2f " ,fMoveTargetX, fMoveTargetY);
                nStep = STEP_BACKWARD;
            }
        }

        //6、后退
        if(nStep == STEP_BACKWARD)
        {
            //ROS_WARN("[STEP_BACKWARD] nTimeDelayCounter = %d " ,nTimeDelayCounter);
            //nTimeDelayCounter++;
            float vx,vy;
            vx = (fMoveTargetX - pose_diff.x)/2;
            if(fabs(fMoveTargetX - pose_diff.x) > 0.1) //距离小于0.25(0.9-0.65）时就已经安全了
            {
                vy = 0;
            }
            else
            {
                vy = (fMoveTargetY - pose_diff.y)/2;
                nTimeDelayCounter ++;
            }
            VelCmd(vx,vy,0);
            //ROS_INFO("[MOVE] T(%.2f %.2f)  od(%.2f , %.2f) v(%.2f,%.2f)" ,fMoveTargetX, fMoveTargetY, pose_diff.x ,pose_diff.y,vx,vy);
            if(fabs(vx) < 0.01 && fabs(vy) < 0.01 && nTimeDelayCounter > 8*30)
            {
                VelCmd(0,0,0);
                odom_ctrl_msg.data = "pose_diff reset";
                odom_ctrl_pub.publish(odom_ctrl_msg);
                nTimeDelayCounter = 0;
                ROS_WARN("[STEP_DONE]");
                nStep = STEP_DONE;
                // odom_ctrl_msg.data = "pose_diff reset";
                // odom_ctrl_pub.publish(odom_ctrl_msg);
                // nTimeDelayCounter = 0;
                // fMoveTargetX = 0;
                // fMoveTargetY = -(fPlaceY + place_y_offset);
                // ROS_WARN("[STEP_Y_BACK] x= %.2f y= %.2f " ,fMoveTargetX, fMoveTargetY);
                // nStep = STEP_Y_BACK;
            }

            result_msg.data = "backward";
            result_pub.publish(result_msg);
        }

        //5、横向归位
        // if(nStep == STEP_Y_BACK)
        // {
        //     //ROS_WARN("[STEP_Y_BACK] nTimeDelayCounter = %d " ,nTimeDelayCounter);
        //     //nTimeDelayCounter++;
        //     float vx,vy;
        //     vx = (fMoveTargetX - pose_diff.x)/2;
        //     vy = (fMoveTargetY - pose_diff.y)/2;
        //     VelCmd(vx,vy,0);
        //     //ROS_INFO("[MOVE] T(%.2f %.2f)  od(%.2f , %.2f) v(%.2f,%.2f)" ,fMoveTargetX, fMoveTargetY, pose_diff.x ,pose_diff.y,vx,vy);
        //     if(fabs(vx) < 0.01 && fabs(vy) < 0.01)
        //     {
        //         VelCmd(0,0,0);
        //         odom_ctrl_msg.data = "pose_diff reset";
        //         odom_ctrl_pub.publish(odom_ctrl_msg);
        //         nTimeDelayCounter = 0;
        //         ROS_WARN("[STEP_DONE]");
        //         nStep = STEP_DONE;
        //     }
        //     mani_ctrl_msg.position[0] = 0.5;
        //     mani_ctrl_pub.publish(mani_ctrl_msg);

        //     result_msg.data = "backward";
        //     result_pub.publish(result_msg);
        // }

        //6、放置任务完毕
        if(nStep == STEP_DONE)
        {
            if(nTimeDelayCounter < 30)
            {
                VelCmd(0,0,0);
                nTimeDelayCounter ++;
                result_msg.data = "done";
                result_pub.publish(result_msg);
            }
            else
            {
                nStep = STEP_WAIT;
            }
        }

        ros::spinOnce();
        r.sleep();
    }

    return 0;
}
