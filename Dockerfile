FROM ubuntu:18.04
ENV DEBIAN_FRONTEND noninteractive


#install dependencies via apt
ENV DEBCONF_NOWARNINGS yes
RUN set -x && \
  apt-get update -y -qq && \
  apt-get upgrade -y -qq --no-install-recommends && \
  : “basic dependencies” && \ ## di bawah ini dependencies nya
  apt-get install -y -qq \
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
    mesa-utils \
    libpython2.7-dev \
    unzip && \
  : “g2o dependencies” && \ ## di bawah ini dependencies nya
  apt-get install -y -qq \
    libgoogle-glog-dev \
    libatlas-base-dev \
    libsuitesparse-dev \
    libglew-dev && \
  : “OpenCV dependencies” && \ ## di bawah ini dependencies nya
  apt-get install -y -qq \
    libgtk-3-dev \
    libjpeg-dev \
    libpng++-dev \
    libtiff-dev \
    libopenexr-dev \
    libwebp-dev \
    ffmpeg \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libswscale-dev \
    libavresample-dev && \
  : “other dependencies” && \ ## di bawah ini dependencies nya
  apt-get install -y -qq \
    libyaml-cpp-dev && \
  : “remove cache” && \
  apt-get autoremove -y -qq && \ ##autoremove will remove those dependencies that were installed with applications and that are no longer used by anything else on the system | https://askubuntu.com/questions/527410/what-is-the-advantage-of-using-sudo-apt-get-autoremove-over-a-cleaner-app
  rm -rf /var/lib/apt/lists/*    ##menghapus file cache dependencies yang sudah tidak digunakan lagi


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
ARG EIGEN3_VERSION=3.3.8
WORKDIR /tmp #Dependencies seperti Eigein, OpenCV, dan Pangolin membuat working directory di
RUN set -x && \
  wget -q https://gitlab.com/libeigen/eigen/-/archive/${EIGEN3_VERSION}/eigen-${EIGEN3_VERSION}.tar.bz2 && \
  tar xf eigen-${EIGEN3_VERSION}.tar.bz2 && \
  rm -rf eigen-${EIGEN3_VERSION}.tar.bz2 && \
  cd eigen-${EIGEN3_VERSION} && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \ ##to set the configuration type
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ ##ini adalah lokasi menginstall Eigen di /usr/local
    .. && \
  make -j${NUM_THREADS} && \ #default make -j1 tetapi bisa dipercepat di saat awal menginstall
  make install && \ ##perintah untuk menginstall make
  cd /tmp && \
  rm -rf * ##// setelah berhasil membangun Eigen lalu folder temporary tersebut didelete
ENV Eigen3_DIR=${CMAKE_INSTALL_PREFIX}/share/eigen3/cmake ##//lokasi instalasi Eigen di /usr/local


#OpenCV
ARG OPENCV_VERSION=3.2.0
WORKDIR /tmp
RUN set -x && \
  wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip && \
  unzip -q ${OPENCV_VERSION}.zip && \
  rm -rf ${OPENCV_VERSION}.zip && \
  cd opencv-${OPENCV_VERSION} && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ ##//ini adalah lokasi menginstall OpenCV di /usr/local
    -DENABLE_CXX11=ON \
    -DENABLE_FAST_MATH=ON \
    -DWITH_EIGEN=ON \
    -DWITH_FFMPEG=ON \
    -DWITH_OPENMP=ON \
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
  cd /tmp && \ ##//lokasi penyinpanan sementar file yang tidak ada hubungannya dengan Cmake didelete
  rm -rf * ##// setelah berhasil membangun Eigen lalu folder temporary tersebut didelete
ENV OpenCV_DIR=${CMAKE_INSTALL_PREFIX}/lib/cmake/opencv4 ##//lokasi instalasi Opencv di /usr/local


#Pangolin
ARG PANGOLIN_COMMIT=ad8b5f83222291c51b4800d5a5873b0e90a0cf81 ##// sepertinya ini adalah versi pangolin yang berfungsi pada openvslam tetapi apakah juga berfungsi pada orb-slam3??
WORKDIR /tmp
RUN set -x && \
  git clone https://github.com/stevenlovegrove/Pangolin.git && \
  cd Pangolin && \
  git checkout ${PANGOLIN_COMMIT} && \
  sed -i -e “193,198d” ./src/utils/file_utils.cpp && \
  mkdir -p build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ ##//ini adalah lokasi menginstall OpenCV di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  make install && \
  cd /tmp && \
  rm -rf *
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
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ ##//ini adalah lokasi menginstall DBoW2 di /usr/local
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
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ ##//ini adalah lokasi menginstall g2o di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  echo "...g2o is built..." && \
  echo "--------------------" && \
  
  cd ../../../ && \
  echo "...Uncompress vocabulary..." && \
  cd Vocabulary && \
  tar -xf ORBvoc.txt.tar.gz && \
  cd .. && \
  echo "...vocabulary is uncompressed..." && \
  echo "--------------------" && \
  
  echo "...Configuring and building ORB-SLAM3..." && \
  mkdir build && \
  cd build && \
  cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX} \ ##//ini adalah lokasi menginstall g2o di /usr/local
    .. && \
  make -j${NUM_THREADS} && \
  echo "...ORB-SLAM3 is built..." && \
  echo "--------------------" && \
  rm -rf CMakeCache.txt CMakeFiles Makefile cmake_install.cmake example src && \
  chmod -R 777 ./*

WORKDIR /ORB-SLAM3/build/
ENTRYPOINT [“/bin/bash”]
