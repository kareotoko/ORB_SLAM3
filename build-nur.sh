apt-get update -y
apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive apt-get install -y -q build-essential pkg-config software-properties-common checkinstall yasm cmake git wget curl tar x11-apps dbus-x11 x11-xserver-utils xauth xorg unzip sudo emacs python python3 python3-dev python-dev python3-testresources python3-pip python-pip
add-apt-repository “deb http://security.ubuntu.com/ubuntu xenial-security main”
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libjpeg-dev libpng-dev libtiff-dev libjasper-dev libavcodec-dev libavformat-dev libswscale-dev libxine2-dev libv4l-dev libxvidcore-dev libx264-dev libgstreamer1.0-dev  libgstreamer-plugins-base1.0-dev libtbb-dev qt4-default libfaac-dev libmp3lame-dev libtheora-dev libvorbis-dev libopencore-amrnb-dev libavresample-dev x264 v4l-utils ffmpeg libgtk-3-dev libgtk2.0-dev libatlas-base-dev gfortran
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libprotobuf-dev protobuf-compiler libgoogle-glog-dev libgflags-dev libgphoto2-dev libhdf5-dev doxygen
pip install numpy pyopengl Pillow pybind11
pip3 install numpy pyopengl Pillow pybind11
cd /usr/include/linux
ln -s -f ../libv4l1-videodev.h videodev.h
cd ~
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libsuitesparse-dev qtdeclarative5-dev qt5-qmake libqglviewer-dev-qt5 libglew-dev
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libusb-1.0 libusb-dev libavutil-dev libswscale-dev libavdevice-dev libdc1394-22-dev libraw1394-dev libpng12-dev libtiff5-dev libopenexr-dev libssl-dev libgomp1 libomp-dev libyaml-cpp-dev
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libopenblas-base liblapacke-dev flake8 pylint openmpi-common libiomp-dev libboost-all-dev libboost-dev libboost-filesystem-dev libboost-system-dev libboost-thread-dev libblas-dev liblapack-dev libfftw3-dev libegl1-mesa-dev libwayland-dev libxkbcommon-dev wayland-protocols libgl1-mesa-dev libglew-dev
DEBIAN_FRONTEND=noninteractive apt-get install -y -q libmpfrc++-dev libadolc-dev libsparsehash-dev libsuperlu-dev pfsglview libscotch-dev libmetis-dev python-numpy freeglut3-dev libvtk6-dev libssl-dev
apt-get autoremove -y
mkdir -p ~/SLAM
cd ~/SLAM
wget -q https://gitlab.com/libeigen/eigen/-/archive/3.1.4/eigen-3.1.4.tar.bz2
tar -xf eigen-3.1.4.tar.bz2
rm -rf eigen-3.1.4.tar.bz2
git clone https://github.com/opencv/opencv.git
git clone https://github.com/opencv/opencv_contrib.git
git clone https://github.com/dorian3d/DLib.git
git clone https://github.com/libuvc/libuvc.git
git clone https://github.com/stevenlovegrove/Pangolin.git
git clone https://github.com/kareotoko/ORB_SLAM3.git
echo “==========================================”
echo “Configuring and building Eigen 3.1.4 ...”
echo “------------------------------------------”
cd eigen-3.1.4
mkdir build
cd build
cmake ..
make install
cd ~/SLAM
echo “==========================================”
echo “Configuring and building OpenCV 3.2.0 ...”
echo “------------------------------------------”
cd opencv
git checkout tags/3.2.0
cd ..
cd opencv_contrib
git checkout tags/3.2.0
cd ../opencv
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release -DINSTALL_C_EXAMPLES=ON -DINSTALL_PYTHON_EXAMPLES=ON -DENABLE_PRECOMPILED_HEADERS=OFF -DOPENCV_GENERATE_PKGCONFIG=ON -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules -DOPENCV_PYTHON3_INSTALL_PATH=/usr/local/lib/python3.6/dist-packages ..
make -j4
make install
cd ~/SLAM
echo “==========================================”
echo “Configuring and building DLib...”
echo “------------------------------------------”
cd DLib
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j2
make install
cd ~/SLAM
echo “==========================================”
echo “Configuring and building libuvc...”
echo “------------------------------------------”
cd libuvc
mkdir build
cd build
cmake ..
make && sudo make install
cd ~/SLAM
echo “==========================================”
echo “Configuring and building Pangolin...”
echo “------------------------------------------”
cd Pangolin
mkdir build
cd build
cmake -DCPP11_NO_BOOST=1 ..
make -j2
make install
cd ~/SLAM
echo “==========================================”
echo “Configuring and building Thirdparty/DBoW2 ...”
echo “------------------------------------------”
cd ORB_SLAM3/Thirdparty/DBoW2
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j2
cd ../../g2o
echo “==========================================”
echo “Configuring and building Thirdparty/g2o ...”
echo “------------------------------------------”
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j2
cd ../../../
echo “==========================================”
echo “Uncompress vocabulary ...”
echo “------------------------------------------”
cd Vocabulary
tar -xf ORBvoc.txt.tar.gz
cd ..
echo “==========================================”
echo “Configuring and building ORB_SLAM3 ...”
echo “------------------------------------------”
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j2
make install
