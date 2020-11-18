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
    python \
    unzip \
    sudo \
    emacs \
    python3-pip \
    python-pip \
    && \ 
    ## then donwload, extract and copy ontent of eigen 3.3.7 to /usr/local/include/eigen
  : “OpenCV dependencies” && \ 
  ## di bawah ini dependencies nya
  add-apt-repository "deb http://security.ubuntu.com/ubuntu xenial-security main" && \
  apt-get install -y -qq \
    software-properties-common \    
    checkinstall \
    yasm \
    ##pre-request for image processing
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libjasper1 \
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
    qt5-default \
    libfaac-dev \
    libmp3lame-dev \
    libtheora-dev \
    libvorbis-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
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
    libeigen3-dev \
    libhdf5-dev \
    doxygen \   
    ## python libraries
    python3-dev \
    python-dev \
    python3-testresources && \
  pip install -y \
    numpy \
    pyopengl \
    Pillow \
    pybind11 && \
  pip3 install -y \
    numpy \
    pyopengl \
    Pillow \
    pybind11 && \
  cd /usr/include/linux && \
  ln -s -f ../libv4l1-videodev.h videodev.h && \
  cd ~ && \
  sudo -H pip3 install -U pip numpy && \
  : “g2o dependencies” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y -qq \
    libsuitesparse-dev \
    libglew-dev && \
  : “Pangolin dependencies” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y \
    libusb-1.0 \
    libavcodec-dev \
    libavutil-dev \
    libavformat-dev \
    libswscale-dev \
    libavdevice-dev \
    libdc1394-22-dev \
    libraw1394-dev \
    libjpeg-dev \
    libpng12-dev \
    libtiff5-dev \
    libopenexr-dev && \
  : “other dependencies” && \ 
  ## di bawah ini dependencies nya
  apt-get install -y -qq \
    libssl-dev \
    libgomp1-amd64-cross \
    libomp-dev \
    libyaml-cpp-dev && \
  : “remove cache” && \
  apt-get autoremove -y -qq && \ 
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
ARG EIGEN3_VERSION=3.3.7
WORKDIR /SLAM 
#Dependencies seperti Eigein, OpenCV, dan Pangolin membuat working directory di /temporary
RUN set -x && \
  wget -q https://gitlab.com/libeigen/eigen/-/archive/${EIGEN3_VERSION}/eigen-${EIGEN3_VERSION}.tar.bz2 && \
  tar xf eigen-${EIGEN3_VERSION}.tar.bz2 && \
  rm -rf eigen-${EIGEN3_VERSION}.tar.bz2 && \
  cp eigen-${EIGEN3_VERSION} ${CMAKE_INSTALL_PREFIX}/include/eigen3 && \
  cp eigen-${EIGEN3_VERSION} ${CMAKE_INSTALL_PREFIX}/share/eigen3 && \
   
ENV Eigen3_DIR=${CMAKE_INSTALL_PREFIX}/share/eigen3/cmake \
##//lokasi instalasi Eigen di /usr/local


#OpenCV
ARG OPENCV_VERSION=3.4.12
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
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ 
    ##//ini adalah lokasi menginstall OpenCV di /usr/local
    -DINSTALL_C_EXAMPLES=ON \
    -DINSTALL_PYTHON_EXAMPLES=ON \
    -DWITH_QT=ON \
    -DWITH_OPENGL=ON \
    -DWITH_EIGEN=ON \
    -DWITH_TBB=ON \
    -DWITH_AVFOUNDATION=ON \
    -DWITH_OPENMP=ON \
    -DWITH_FFMPEG=ON \
    -DWITH_GSTREAMER=ON \
    -DENABLE_CXX11=ON \
    -DENABLE_FAST_MATH=ON \
    -DOPENCV_GENERATE_PKGCONFIG=ON \ 
    -DOPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
    -DOPENCV_PYTHON3_INSTALL_PATH=/usr/local/lib/python3.6/dist-packages \
    -DBUILD_EXAMPLES=ON \
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
ENV OpenCV_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/opencv3 
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
ENV Pangolin_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/Pangolin


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
