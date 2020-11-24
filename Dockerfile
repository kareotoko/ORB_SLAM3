FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive

#install dependencies via apt
ENV DEBCONF_NOWARNINGS yes
RUN set -x && \
  apt-get update -y && \
  apt-get upgrade -y && \  
  : “basic dependencies” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y \
    build-essential \
    pkg-config \
    software-properties-common \
    checkinstall \
    yasm \
    cmake \
    git \
    wget \
    curl \
    tar \
    x11-apps \
    dbus-x11 \
    x11-xserver-utils \
    xauth \
    xorg \
    unzip \
    sudo \
    emacs \
    python \
    python3 \
    python-dev \
    python3-dev \
    python3-testresources \
    python-pip \
    python3-pip \
    && \ 
  : “OpenCV dependencies” && \ 
  ## di bawah ini dependencies nya
  add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
  apt-get install -y -q \
    ##pre-request for image processing
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libjasper-dev \
    ## libjasper1 after adding repository from xenial
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libxine2-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    ## video I/O
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libtbb-dev \
    qt4-default \
    libfaac-dev \
    libmp3lame-dev \
    libtheora-dev \
    libvorbis-dev \
    libopencore-amrnb-dev \
    libavresample-dev \
    x264 \
    v4l-utils \
    ffmpeg \
    ## GTK lib
    libgtk-3-dev \
    libgtk2.0-dev \
    ## to optimize opencv function
    libatlas-base-dev \
    gfortran \
    ## optional dependencies
    libprotobuf-dev \
    protobuf-compiler \
    libgoogle-glog-dev \
    libgflags-dev \
    libgphoto2-dev \
    libhdf5-dev \
    doxygen \
    && \   
  pip install \
    numpy \
    pyopengl \
    Pillow \
    pybind11 \
    && \
  pip3 install \
    numpy \
    pyopengl \
    Pillow \
    pybind11 \
    && \
  cd /usr/include/linux && \
  ln -s -f ../libv4l1-videodev.h videodev.h && \
  cd ~ && \
  : “g2o dependencies” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y -q \
    libsuitesparse-dev \
    qtdeclarative5-dev \
    qt5-qmake \
    libqglviewer-dev-qt5 \
    libglew-dev && \
  : “Pangolin dependencies” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y -q\
    libusb-dev \
    libavutil-dev \
    libswscale-dev \
    libavdevice-dev \
    libdc1394-22-dev \
    libraw1394-dev \
    libpng12-dev \
    libtiff5-dev \
    libopenexr-dev \
    libssl-dev \
    libgomp1 \
    libomp-dev \
    libyaml-cpp-dev \
    && \
  : “other dependencies for orb-slam3” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y -q \
    libboost-filesystem-dev \
    libopenblas-base \
    liblapacke-dev \
    flake8 \
    pylint \
    openmpi-common \
    libiomp-dev \
    libboost-all-dev \
    libblas-dev \
    liblapack-dev \
    libfftw3-dev \
    libegl1-mesa-dev \
    libwayland-dev \
    libxkbcommon-dev \
    wayland-protocols \
    libgl1-mesa-dev \
    libglew-dev \
    libmpfrc++-dev \
    libadolc-dev \
    libsparsehash-dev \
    libsuperlu-dev \
    pfsglview \
    libscotch-dev \
    libmetis-dev \
    python-numpy \
    freeglut3-dev \
    lvtk-dev \
    && \
  : “install gcc-6 and g++-6 versions” && \
  apt-get install -y -q \
    gcc-6 \
    g++-6 \
    && \
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 6 && \
  sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-6 6 && \
  : “remove cache” && \
  apt-get autoremove -y -q && \ 
  ##autoremove will remove those dependencies that were installed with applications and that are no longer used by anything else on the system | https://askubuntu.com/questions/527410/what-is-the-advantage-of-using-sudo-apt-get-autoremove-over-a-cleaner-app
  rm -rf /var/lib/apt/lists/*    
  ##menghapus file cache dependencies yang sudah tidak digunakan lagi
  

ARG CMAKE_INSTALL_PREFIX=/usr/local
ARG NUM_THREADS=1

ENV CPATH=${CMAKE_INSTALL_PREFIX}/include:${CPATH}
ENV C_INCLUDE_PATH=${CMAKE_INSTALL_PREFIX}/include:${C_INCLUDE_PATH}
ENV CPLUS_INCLUDE_PATH=${CMAKE_INSTALL_PREFIX}/include:${CPLUS_INCLUDE_PATH}
ENV LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib:${LIBRARY_PATH}
ENV LD_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib:${LD_LIBRARY_PATH}

#ENV NVIDIA_VISIBLE_DEVICES ${NVIDIA_VISIBLE_DEVICES:-all}
#ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

#Eigen
ARG EIGEN3_VERSION=3.1.4
WORKDIR /SLAM 
#Dependencies seperti Eigein, OpenCV, dan Pangolin membuat working directory di /temporary
RUN set -x && \
  wget -q https://gitlab.com/libeigen/eigen/-/archive/${EIGEN3_VERSION}/eigen-${EIGEN3_VERSION}.tar.bz2 && \
  tar xf eigen-${EIGEN3_VERSION}.tar.bz2 && \
  rm -rf eigen-${EIGEN3_VERSION}.tar.bz2 && \
  cd eigen-${EIGEN3_VERSION} && \
  mkdir -p build && \
  cd build && \
  cmake .. && \
  make install && \
##ENV Eigen3_DIR=${CMAKE_INSTALL_PREFIX}/share/eigen3/cmake \
ENV EIGEN3_LIBS=${CMAKE_INSTALL_PREFIX}/share/eigen3/cmake \
##//lokasi instalasi Eigen di /usr/local

#OpenCV
ARG OPENCV_VERSION=3.2.0
WORKDIR /SLAM 
RUN set -x && \
  git clone https://github.com/opencv/opencv.git && \  
  cd opencv && \
  git checkout tags/${OPENCV_VERSION} && \
  cd .. && \
  git clone https://github.com/opencv/opencv_contrib.git && \
  cd opencv_contrib && \
  git checkout tags/${OPENCV_VERSION} && \
  cd .. && \
  cd opencv && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DINSTALL_C_EXAMPLES=ON \
    -DINSTALL_PYTHON_EXAMPLES=ON \
    -DWITH_1394=ON \
    -DWITH_EIGEN=ON \
    -DWITH_FFMPEG=ON \
    -DWITH_GSTREAMER=ON \
    -DWITH_OPENEXR=ON \
    -DWITH_OPENMP=ON \
    -DWITH_V4L=ON \
    -DWITH_LIBV4L=OFF \
    -DWITH_OPENCL=ON \
    -DWITH_LAPACK=OFF \
    -DENABLE_CXX11=ON \
    -DENABLE_FAST_MATH=ON \
    -DOPENCV_GENERATE_PKGCONFIG=ON \ 
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DOPENCV_PYTHON3_INSTALL_PATH=/usr/local/lib/python3.6/dist-packages \
    -DBUILD_EXAMPLES=ON \
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
##ENV OpenCV_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/opencv3 
ENV OpenCV_LIBS=${CMAKE_INSTALL_PREFIX}/lib/cmake/opencv3 
##//lokasi instalasi Opencv di /usr/local

#Pangolin
WORKDIR /SLAM
RUN set -x && \
  git clone https://github.com/ktossell/libuvc.git && \
  cd libuvc && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ 
    ##//ini adalah lokasi menginstall OpenCV di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
  git clone https://github.com/stevenlovegrove/Pangolin.git && \
  cd Pangolin && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ 
    ##//ini adalah lokasi menginstall OpenCV di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
ENV PANGOLIN_LIBS=${CMAKE_INSTALL_PREFIX}/lib/cmake/Pangolin
##ENV Pangolin_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/Pangolin

#ORB-SLAM3 with DBoW2 and g2o
COPY . /ORB-SLAM3/
WORKDIR /ORB-SLAM3/
RUN set -x && \
  cd Thirdparty/DBoW2 && \
  echo "Configuring and building Thirdparty/DBoW2 ..." && \
  mkdir build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ 
    ##//ini adalah lokasi menginstall DBoW2 di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  echo "...DBoW2 is built..." && \
  echo "--------------------" && \
  cd ../../g2o  && \
  echo "...Configuring and building Thirdparty/g2o..." && \
  mkdir build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ 
    ##//ini adalah lokasi menginstall g2o di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  echo "...g2o is built..." && \
  echo "--------------------" && \
  cd ../../.. && \
  echo "...Uncompress vocabulary..." && \
  cd Vocabulary && \
  tar -xf ORBvoc.txt.tar.gz && \
  cd .. && \doc
  echo "...vocabulary is uncompressed..." && \
  echo "--------------------" && \
  echo "...Configuring and building ORB-SLAM3..." && \
  mkdir build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ 
    ##//ini adalah lokasi menginstall g2o di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  echo "...ORB-SLAM3 is built..." && \
  echo "--------------------" && \
  rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake example src && \
  chmod -R 777 ./*
WORKDIR /ORB-SLAM3/build/
ENTRYPOINT [“/bin/bash”]
