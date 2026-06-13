# se_navigation

`se_navigation` 是课程项目的导航封装包。

## 职责

- 启动 map_server、AMCL、move_base 和导航 action server。
- 对前端暴露 `/se_navigation/navigate`，只需要调用者提供终点；机器人当前位置由 AMCL/TF 提供。
- 订阅 `/move_base/GlobalPlanner/plan`，把导航进度转成 action feedback。

## Action

- `/se_navigation/navigate` (`se_navigation/NavigateAction`)

## 启动

```bash
roslaunch se_navigation navigation.launch sim:=true map_file:=$(rospack find se_map)/maps/saved_map.yaml
```

发送测试目标：

```bash
rosrun se_navigation send_navigation_goal.py --goal-x 0.6 --goal-y 0.0
```

建图会话内导航：

```bash
roslaunch se_navigation navigation.launch sim:=false live_map:=true rviz:=false
```
