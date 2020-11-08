cmake_minimum_required(VERSION 2.8)
project(ORB_SLAM3)

IF(NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE Release)
ENDIF()

MESSAGE("Build type: " ${CMAKE_BUILD_TYPE})

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}  -Wall   -O3") # ??CMAKE_C_FLAG itu perintah standar atau buatan. | ??-Wall   -O3 itu fungsinya apa ya.
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall   -O3") # ??CMAKE_CXX_FLAGS itu perintah standar atau buatan.
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -march=native") # ??CMAKE_C_FLAGS_RELEASE itu perintah standar atau buatan.
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -march=native") # ??CMAKE_CXX_FLAGS_RELEASE itu perintah standar atau buatan.

# set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -Wall -Wno-deprecated -O3 -march=native ") # ??-Wall -Wno-deprecated -O3 -march=native itu fungsinya apa dan bedanya dengan yang atas apa.
# set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wno-deprecated -O3 -march=native")

# Check C++11 or C++0x support
include(CheckCXXCompilerFlag)
CHECK_CXX_COMPILER_FLAG("-std=c++11" COMPILER_SUPPORTS_CXX11)
CHECK_CXX_COMPILER_FLAG("-std=c++0x" COMPILER_SUPPORTS_CXX0X)
if(COMPILER_SUPPORTS_CXX11)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
   add_definitions(-DCOMPILEDWITHC11) # ??add_definitions itu apakah standar perintah. | ??-DCOMPILEDWITHC11 itu juga stardar perintah.
   message(STATUS "Using flag -std=c++11.")
elseif(COMPILER_SUPPORTS_CXX0X)
   set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x")
   add_definitions(-DCOMPILEDWITHC0X)
   message(STATUS "Using flag -std=c++0x.")
else()
   message(FATAL_ERROR "The compiler ${CMAKE_CXX_COMPILER} has no C++11 support. Please use a different C++ compiler.")
endif()

LIST(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake_modules) ## Menambahkan Path direktori cmake_modules pada CMAKE_MODULE_PATH

find_package(OpenCV 3) # ??OpenCV 3 tanpa ada QUIET pada ORB-SLAM3 sedangkan pada ORB-SLAM2 ada QUIET
if(NOT OpenCV_FOUND)
   find_package(OpenCV 2.4.3 QUIET) # ??QUIET itu fungsinya apa ya.
   if(NOT OpenCV_FOUND)
      message(FATAL_ERROR "OpenCV > 2.4.3 not found.")
   endif()
endif()

MESSAGE("OPENCV VERSION:")
MESSAGE(${OpenCV_VERSION})

find_package(Eigen3 3.1.0 REQUIRED)
find_package(Pangolin REQUIRED)

include_directories(
${PROJECT_SOURCE_DIR}
${PROJECT_SOURCE_DIR}/include
${PROJECT_SOURCE_DIR}/include/CameraModels # ??..}/include/CameraModels pada ORB-SLAM2 itu tidak ada mengapa ya.
${EIGEN3_INCLUDE_DIR}
${Pangolin_INCLUDE_DIRS}
)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/lib) 

## Ini adalah perintah untuk menambahkan library dan header pada CMakeList yang dipersiapkan untuk membangun ORB-SLAM3 dengan perintah "make -j"
add_library(${PROJECT_NAME} SHARED
src/System.cc
src/Tracking.cc
src/LocalMapping.cc
src/LoopClosing.cc
src/ORBextractor.cc
src/ORBmatcher.cc
src/FrameDrawer.cc
src/Converter.cc
src/MapPoint.cc
src/KeyFrame.cc
src/Atlas.cc # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
src/Map.cc
src/MapDrawer.cc
src/Optimizer.cc
src/PnPsolver.cc
src/Frame.cc
src/KeyFrameDatabase.cc
src/Sim3Solver.cc
src/Initializer.cc
src/Viewer.cc
src/ImuTypes.cc # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
src/G2oTypes.cc # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
src/CameraModels/Pinhole.cpp # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
src/CameraModels/KannalaBrandt8.cpp # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
src/OptimizableTypes.cpp # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
src/MLPnPsolver.cpp # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.
include/System.h
include/Tracking.h
include/LocalMapping.h
include/LoopClosing.h
include/ORBextractor.h
include/ORBmatcher.h
include/FrameDrawer.h
include/Converter.h
include/MapPoint.h
include/KeyFrame.h
include/Atlas.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/Map.h
include/MapDrawer.h
include/Optimizer.h
include/PnPsolver.h
include/Frame.h
include/KeyFrameDatabase.h
include/Sim3Solver.h
include/Initializer.h
include/Viewer.h
include/ImuTypes.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/G2oTypes.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/CameraModels/GeometricCamera.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/CameraModels/Pinhole.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/CameraModels/KannalaBrandt8.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/OptimizableTypes.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/MLPnPsolver.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
include/TwoViewReconstruction.h # ??ini-header pada ORB-SLAM2 itu tidak ada mengapa ya.
src/TwoViewReconstruction.cc) # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya.

add_subdirectory(Thirdparty/g2o) # ??ini pada ORB-SLAM2 itu tidak ada mengapa ya. | Thirdparty/g2o baiknya dibangun dari sumber aslinya atau lewat ORB-SLAM3

target_link_libraries(${PROJECT_NAME}
${OpenCV_LIBS}
${EIGEN3_LIBS}
${Pangolin_LIBRARIES}
${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
-lboost_serialization # ??-lboost_serialization itu apa ya | ??pada ORB-SLAM2 itu tidak ada mengapa ya.
-lcrypto # ??-lcrypto itu apa ya | ??pada ORB-SLAM2 itu tidak ada mengapa ya.
)


# Build examples

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Examples/RGB-D)
add_executable(rgbd_tum
Examples/RGB-D/rgbd_tum.cc)
target_link_libraries(rgbd_tum ${PROJECT_NAME})


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Examples/Stereo)

add_executable(stereo_kitti
Examples/Stereo/stereo_kitti.cc)
target_link_libraries(stereo_kitti ${PROJECT_NAME})

add_executable(stereo_euroc
Examples/Stereo/stereo_euroc.cc)
target_link_libraries(stereo_euroc ${PROJECT_NAME})

add_executable(stereo_tum_vi ## tambahan dataset yang memiliki vi atau visual-inertia
Examples/Stereo/stereo_tum_vi.cc)
target_link_libraries(stereo_tum_vi ${PROJECT_NAME})


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Examples/Monocular)

add_executable(mono_tum
Examples/Monocular/mono_tum.cc)
target_link_libraries(mono_tum ${PROJECT_NAME})

add_executable(mono_kitti
Examples/Monocular/mono_kitti.cc)
target_link_libraries(mono_kitti ${PROJECT_NAME})

add_executable(mono_euroc
Examples/Monocular/mono_euroc.cc)
target_link_libraries(mono_euroc ${PROJECT_NAME})

add_executable(mono_tum_vi ## tambahan dataset yang memiliki vi atau visual-inertia
Examples/Monocular/mono_tum_vi.cc)
target_link_libraries(mono_tum_vi ${PROJECT_NAME})


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Examples/Monocular-Inertial)

add_executable(mono_inertial_euroc ## tambahan dataset yang memiliki vi atau visual-inertia
Examples/Monocular-Inertial/mono_inertial_euroc.cc)
target_link_libraries(mono_inertial_euroc ${PROJECT_NAME})

add_executable(mono_inertial_tum_vi ## tambahan dataset yang memiliki vi atau visual-inertia
Examples/Monocular-Inertial/mono_inertial_tum_vi.cc)
target_link_libraries(mono_inertial_tum_vi ${PROJECT_NAME})


set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/Examples/Stereo-Inertial)

add_executable(stereo_inertial_euroc ## tambahan dataset yang memiliki vi atau visual-inertia
Examples/Stereo-Inertial/stereo_inertial_euroc.cc)
target_link_libraries(stereo_inertial_euroc ${PROJECT_NAME})


add_executable(stereo_inertial_tum_vi ## tambahan dataset yang memiliki vi atau visual-inertia
Examples/Stereo-Inertial/stereo_inertial_tum_vi.cc)
target_link_libraries(stereo_inertial_tum_vi ${PROJECT_NAME})


