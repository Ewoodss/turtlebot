# Ubuntu 20.04 image with NVIDIA CUDA + OpenGL and ROS Noetic
FROM nvidia/cudagl:11.4.2-base-ubuntu20.04

# Install basic apt packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y locales lsb-release
RUN apt-get install -y curl
RUN dpkg-reconfigure locales

# Install ROS Noetic

#addaption of install_ros_noetic.sh

# [Add the ROS repository]
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt-get update

# "[Install ros-desktop-full version of Noetic"
RUN apt-get install -y --no-install-recommends ros-noetic-desktop-full
# "[Install RQT & Gazebo]"
RUN apt-get install -y ros-noetic-rqt-* ros-noetic-gazebo-*
# "[Environment setup and getting rosinstall]"
RUN apt-get install -y python3-rosinstall python3-rosinstall-generator python3-wstool build-essential git
# "[Install rosdep and Update]"
RUN apt-get install -y --no-install-recommends python3-rosdep
RUN sh -c "rosdep init"
RUN rosdep update

# end
RUN rosdep fix-permissions \
    && rosdep update

RUN apt-get install -y ros-noetic-joy ros-noetic-teleop-twist-joy \
    ros-noetic-teleop-twist-keyboard ros-noetic-laser-proc \
    ros-noetic-rgbd-launch ros-noetic-rosserial-arduino \
    ros-noetic-rosserial-python ros-noetic-rosserial-client \
    ros-noetic-rosserial-msgs ros-noetic-amcl ros-noetic-map-server \
    ros-noetic-move-base ros-noetic-urdf ros-noetic-xacro \
    ros-noetic-compressed-image-transport ros-noetic-rqt* ros-noetic-rviz \
    ros-noetic-gmapping ros-noetic-navigation ros-noetic-interactive-markers

RUN apt-get install -y ros-noetic-dynamixel-sdk
RUN apt-get install -y ros-noetic-turtlebot3-msgs
RUN apt-get install -y ros-noetic-turtlebot3

# switch shell to bash
SHELL ["/bin/bash", "-c"]

RUN source /opt/ros/noetic/setup.sh \
    && mkdir -p /catkin_ws/src \
    && cd /catkin_ws \ 
    && catkin_init_workspace
VOLUME "/catkin_ws"
RUN touch test.txt

WORKDIR /catkin_ws


RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

RUN mkdir /tmp/runtime-root
ENV XDG_RUNTIME_DIR "/tmp/runtime-root"
ENV NO_AT_BRIDGE 1

CMD [ "/bin/bash","-c","source /opt/ros/noetic/setup.bash && roscore"]
