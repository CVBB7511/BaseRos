"""码垛机器人系统 Python 包安装配置。"""

from setuptools import setup
from catkin_pkg.python_setup import generate_distutils_setup

d = generate_distutils_setup(
    packages=["palletizing_core"],
    package_dir={"": "src"},
)

setup(**d)
