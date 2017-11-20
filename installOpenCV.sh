#!/bin/bash
# License: MIT. See license file in root directory
# Copyright(c) JetsonHacks (2017)

ocv=3.3.1
ocv_file=opencv-$ocv.zip
ocv_extra_file=opencv_extra-$ocv.zip

# Default mode is 3
jetson_mode=$(sudo nvpmodel -q | sed -n '2p')

# For more info
# http://www.jetsonhacks.com/2017/03/25/nvpmodel-nvidia-jetson-tx2-development-kit/
sudo nvpmodel -m 0

sudo apt-add-repository universe
sudo apt update

sudo apt install -y \
    libglew-dev \
    libtiff5-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng12-dev \
    libjasper-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libpostproc-dev \
    libswscale-dev \
    libeigen3-dev \
    libtbb-dev \
    libgtk2.0-dev \
    cmake \
    pkg-config

# Packages for Python 2 and 3
sudo apt install -y python-dev python-numpy python-py python-pytest
sudo apt install -y python3-dev python3-numpy python3-py python3-pytest

# GStreamer support
sudo apt install -y libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev 
sudo apt install -y --only-upgrade gstreamer*

cd $HOME

# if you have the files in the host, you can copy to the Jetson with:
# scp <file_name>.zip nvidia@<jetson ip>:/home/nvidia/
#
# examples:
# scp opencv-3.3.1.zip nvidia@10.42.0.100:/home/nvidia/
# scp opencv_extra-3.3.1.zip nvidia@10.42.0.100:/home/nvidia/

if [ ! -e $ocv_file ]; then
    wget https://github.com/opencv/opencv/archive/$ocv.zip -O $ocv_file --no-check-certificate
fi

unzip -q $ocv_file

if [ ! -e $ocv_extra_file ]; then
    wget https://github.com/opencv/opencv_extra/archive/$ocv.zip -O $ocv_extra_file --no-check-certificate
fi

unzip -q $ocv_extra_file

mkdir opencv-$ocv/build
cd opencv-$ocv/build

# OpenCV dependencies
sudo apt install -y \
    ccache \
    libgtk-3-dev \
    libavresample-dev \
    libgphoto2-dev \
    liblapacke-dev \
    libopenblas-dev \
    doxygen \
    pylint
    
# Jetson TX2 
cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DBUILD_PNG=OFF \
    -DBUILD_TIFF=OFF \
    -DBUILD_TBB=OFF \
    -DBUILD_JPEG=OFF \
    -DBUILD_JASPER=OFF \
    -DBUILD_ZLIB=OFF \
    -DBUILD_EXAMPLES=ON \
    -DBUILD_opencv_java=OFF \
    -DBUILD_opencv_python2=ON \
    -DBUILD_opencv_python3=ON \
    -DENABLE_PRECOMPILED_HEADERS=OFF \
    -DWITH_OPENCL=OFF \
    -DWITH_OPENMP=OFF \
    -DWITH_FFMPEG=ON \
    -DWITH_GSTREAMER=ON \
    -DWITH_GSTREAMER_0_10=OFF \
    -DWITH_CUDA=ON \
    -DWITH_GTK=ON \
    -DWITH_VTK=OFF \
    -DWITH_TBB=ON \
    -DWITH_1394=OFF \
    -DWITH_OPENEXR=OFF \
    -DCUDA_TOOLKIT_ROOT_DIR=/usr/local/cuda-8.0 \
    -DCUDA_ARCH_BIN=6.2 \
    -DCUDA_ARCH_PTX="" \
    -DINSTALL_C_EXAMPLES=ON \
    -DINSTALL_TESTS=ON \
    -DOPENCV_TEST_DATA_PATH=../opencv_extra-$ocv/testdata \
    ../

make -j6
make -j6
sudo make install

sudo apt autoremove -y

sudo nvpmodel -m $jetson_mode
