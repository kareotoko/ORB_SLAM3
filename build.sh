## Ini adalah file pertama yang dieksekusi untuk membangun ORB-SLAM3
## Di dalamnya terdapat serangkaian langkah2 untuk membangun dependencies yang diakhiri dengan ORB-SLAM3

echo "Configuring and building Thirdparty/DBoW2 ..."

cd Thirdparty/DBoW2 # Thirdparty tidak diinstall lebih dulu, ??apa alasan khususnya ya.
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j

cd ../../g2o

echo "Configuring and building Thirdparty/g2o ..." # Thirdparty tidak diinstall lebih dulu, ??apa alasan khususnya ya.
mkdir build

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j

cd ../../../

echo "Uncompress vocabulary ..." # Vocabulary itu isinya sangat penting yaitu https://webdiis.unizar.es/~dorian/papers/GalvezTRO12.pdf | baca juga https://github.com/raulmur/ORB_SLAM2/issues/139

cd Vocabulary
tar -xf ORBvoc.txt.tar.gz
cd ..

echo "Configuring and building ORB_SLAM3 ..."

mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j
