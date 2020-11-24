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
include/System.h # Dep.: <unistd.h> <stdio.h> <stdlib.h> <string> <thread> <opencv2/core/core.hpp> "Tracking.h" "FrameDrawer.h" "MapDrawer.h" "Atlas.h" "LocalMapping.h" "LoopClosing.h" "KeyFrameDatabase.h" "ORBVocabulary.h" "Viewer.h" "ImuTypes.h"
include/Tracking.h # Dep.: <opencv2/core/core.hpp> <opencv2/features2d/features2d.hpp> <opencv2/video/tracking.hpp> <mutex> <unordered_set> "Viewer.h" "FrameDrawer.h" "Atlas.h" "LocalMapping.h" "LoopClosing.h" "Frame.h" "ORBVocabulary.h" "KeyFrameDatabase.h" "ORBextractor.h" "Initializer.h" "MapDrawer.h" "System.h" "ImuTypes.h" "GeometricCamera.h" 
include/LocalMapping.h # Dep.: <mutex> "KeyFrame.h" "Atlas.h" "LoopClosing.h" "Tracking.h" "KeyFrameDatabase.h" "Initializer.h" 
include/LoopClosing.h # Dep.: <boost/algorithm/string.hpp> <thread> <mutex> "Thirdparty/g2o/g2o/types/types_seven_dof_expmap.h"
include/ORBextractor.h # Dep.: <vector> <list> <opencv/cv.h>
include/ORBmatcher.h # Dep.: <vector> <opencv2/core/core.hpp> <opencv2/features2d/features2d.hpp> "MapPoint.h" "KeyFrame.h" "Frame.h"
include/FrameDrawer.h # Dep.: <opencv2/core/core.hpp> <opencv2/features2d/features2d.hpp> <mutex> <unordered_set> "Tracking.h" "MapPoint.h" "Atlas.h"
include/Converter.h # Dep.: <opencv2/core/core.hpp> <Eigen/Dense> "Thirdparty/g2o/g2o/types/types_six_dof_expmap.h" "Thirdparty/g2o/g2o/types/types_seven_dof_expmap.h" 
include/MapPoint.h # Dep.: <opencv2/core/core.hpp> <mutex> <boost/serialization/serialization.hpp> <boost/serialization/array.hpp> <boost/serialization/map.hpp> "KeyFrame.h" "Frame.h" "Map.h"
include/KeyFrame.h # Dep.: <mutex> <boost/serialization/base_object.hpp> <boost/serialization/vector.hpp> <boost/serialization/map.hpp> "MapPoint.h" "Thirdparty/DBoW2/DBoW2/BowVector.h" "Thirdparty/DBoW2/DBoW2/FeatureVector.h" "ORBVocabulary.h" "ORBextractor.h" "Frame.h" "KeyFrameDatabase.h" "ImuTypes.h" "GeometricCamera.h"
include/Atlas.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <set> <mutex> <boost/serialization/vector.hpp> <boost/serialization/export.hpp> "Map.h" "MapPoint.h" "KeyFrame.h" "GeometricCamera.h" "Pinhole.h" "KannalaBrandt8.h" 
include/Map.h # Dep.: <set> <pangolin/pangolin.h> <mutex> <boost/serialization/base_object.hpp> "MapPoint.h" "KeyFrame.h" 
include/MapDrawer.h # Dep.: <pangolin/pangolin.h> <mutex> "Atlas.h" "MapPoint.h" "KeyFrame.h" 
include/Optimizer.h # Dep.: <math.h> "Map.h" "MapPoint.h" "KeyFrame.h" "LoopClosing.h" "Frame.h" "Thirdparty/g2o/g2o/types/types_seven_dof_expmap.h" "Thirdparty/g2o/g2o/core/sparse_block_matrix.h" "Thirdparty/g2o/g2o/core/block_solver.h" "Thirdparty/g2o/g2o/core/optimization_algorithm_levenberg.h" "Thirdparty/g2o/g2o/core/optimization_algorithm_gauss_newton.h" "Thirdparty/g2o/g2o/solvers/linear_solver_eigen.h" "Thirdparty/g2o/g2o/types/types_six_dof_expmap.h" "Thirdparty/g2o/g2o/core/robust_kernel_impl.h" "Thirdparty/g2o/g2o/solvers/linear_solver_dense.h"
include/PnPsolver.h # Dep.: <opencv2/core/core.hpp> "MapPoint.h" "Frame.h"
include/Frame.h # Dep.: <vector> <mutex> <opencv2/opencv.hpp> "Thirdparty/DBoW2/DBoW2/BowVector.h" "Thirdparty/DBoW2/DBoW2/FeatureVector.h" "ImuTypes.h" "ORBVocabulary.h"
include/KeyFrameDatabase.h # Dep.: <vector> <list> <set> <boost/serialization/base_object.hpp> <boost/serialization/vector.hpp> <boost/serialization/list.hpp> <mutex> "KeyFrame.h" "Frame.h" "ORBVocabulary.h" "Map.h"
include/Sim3Solver.h # Dep.: <opencv2/opencv.hpp> <vector> "KeyFrame.h"
include/Initializer.h # Dep.: <opencv2/opencv.hpp> <unordered_set> "Frame.h"
include/Viewer.h # Dep.: <mutex> "FrameDrawer.h" "MapDrawer.h" "Tracking.h" "System.h"
include/ImuTypes.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <vector> <utility> <opencv2/core/core.hpp> <Eigen/Core> <Eigen/Geometry> <Eigen/Dense> <mutex> <boost/serialization/serialization.hpp> <boost/serialization/vector.hpp>
include/G2oTypes.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <opencv2/core/core.hpp> <Eigen/Core> <Eigen/Geometry> <Eigen/Dense> <Frame.h> <KeyFrame.h> <math.h> "Converter.h" "Thirdparty/g2o/g2o/core/base_vertex.h" "Thirdparty/g2o/g2o/core/base_binary_edge.h" "Thirdparty/g2o/g2o/types/types_sba.h" "Thirdparty/g2o/g2o/core/base_multi_edge.h" "Thirdparty/g2o/g2o/core/base_unary_edge.h"
include/CameraModels/GeometricCamera.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <opencv2/core/core.hpp> <opencv2/imgproc/imgproc.hpp> <opencv2/features2d/features2d.hpp> <boost/serialization/serialization.hpp> <boost/serialization/access.hpp> <boost/serialization/base_object.hpp> <boost/serialization/export.hpp> <boost/serialization/vector.hpp> <boost/serialization/assume_abstract.hpp> <Eigen/Geometry>
include/CameraModels/Pinhole.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <assert.h> <vector> <opencv2/core/core.hpp> <boost/serialization/serialization.hpp> <boost/serialization/base_object.hpp> <boost/serialization/vector.hpp> <boost/serialization/assume_abstract.hpp> "GeometricCamera.h" "TwoViewReconstruction.h"
include/CameraModels/KannalaBrandt8.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <assert.h> <vector> <opencv2/core/core.hpp> <boost/serialization/serialization.hpp> <boost/serialization/base_object.hpp> <boost/serialization/vector.hpp> "GeometricCamera.h" "TwoViewReconstruction.h"
include/OptimizableTypes.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <Eigen/Geometry> <include/CameraModels/GeometricCamera.h> <Thirdparty/g2o/g2o/types/types_six_dof_expmap.h> <Thirdparty/g2o/g2o/types/sim3.h> "Thirdparty/g2o/g2o/core/base_unary_edge.h"
include/MLPnPsolver.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <Eigen/Dense> <Eigen/Sparse> "MapPoint.h" "Frame.h" 
include/TwoViewReconstruction.h # ??ini-header pada ORB-SLAM2 itu tidak ada | Dep.: <opencv2/opencv.hpp> <unordered_set> 
src/TwoViewReconstruction.cc) # ??ini pada ORB-SLAM2 itu tidak ada 

add_subdirectory(Thirdparty/g2o) 

target_link_libraries(${PROJECT_NAME}
${OpenCV_LIBS}
${EIGEN3_LIBS}
${Pangolin_LIBRARIES}
${PROJECT_SOURCE_DIR}/Thirdparty/DBoW2/lib/libDBoW2.so
${PROJECT_SOURCE_DIR}/Thirdparty/g2o/lib/libg2o.so
-lboost_serialization # ??-lboost_serialization itu adalah library tambahan selain dari gcc dan g++ untuk mempercepat proses pengolahan data | ??pada ORB-SLAM2 itu tidak ada mengapa ya.
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


