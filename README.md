# SnakeBite — 码垛机器人

## 一、本组人员构成

1. **唐悦洋**
2. **刘栖言**
3. **张永康**
4. **俞博文**
5. **刘峻昊**

## 二、项目进展

1. 编写软件开发计划
2. 编写软件需求规格说明书
3. 编写软件设计说明

## 三、快速开始

### 克隆仓库

```bash
git clone --recurse-submodules git@gitlab.oo.buaa.edu.cn:2026_embedded_software/Tuesday/team8/project-plan.git
cd project-plan/src
```

### 一键部署

```bash
bash setup.sh
```

部署脚本会自动完成：
- 前端环境安装（nvm / node 17 / pnpm）与构建
- ROS melodic 安装与依赖配置
- Miniconda 环境初始化
- 工作空间部署与编译

> 可能需要再次运行 `scripts/setup_miniconda.sh`

### 启动

```bash
# 启动前端
cd frontend && pnpm preview

# 启动 ROS（真实环境）
roslaunch controller use_case_1.launch

# 启动 ROS（仿真环境）
roslaunch controller use_case_1_sim.launch
```

详细文档见 [src/README.md](src/README.md)
