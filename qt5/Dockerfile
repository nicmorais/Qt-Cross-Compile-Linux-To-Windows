FROM ubuntu:jammy
WORKDIR /qt-windows

#qt requires posix threads
RUN apt update && \
    apt install wget xz-utils python3 llvm -y build-essential g++-mingw-w64 && \
    update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix && \
    update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix && \
    update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix && \
    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix && \
    git clone https://github.com/qt/qt5 --branch v5.15.2

WORKDIR /qt-windows/qt5

RUN ./init-repository --module-subset=essential && \
    ./configure -xplatform win32-g++ -device-option \
    CROSS_COMPILE=x86_64-w64-mingw32- -prefix /qt-windows/install \
    -opensource -confirm-license \
    -no-pch \
    -nomake tests \
    -nomake examples \
    -skip qtcharts \
    -skip qtconnectivity \
    -skip qtdatavis3d \
    -skip qtwebengine \
    -skip qtwebsockets \
    -skip qtwebview \
    -skip qt3d \
    -skip qtquick3d \
    -skip qtspeech \
    -skip qtgamepad \
    -no-harfbuzz \
    -skip qtpurchasing \
    -skip qttranslations \
    -skip qtserialport \
    -skip qtlocation \
    -skip activeqt \
    -opengl desktop

#fix: do not try to execute fxc.exe
RUN sed -i '/qtConfig(d3d12): SUBDIRS += d3d12/c\#qtConfig(d3d12): SUBDIRS += d3d12' qtdeclarative/src/plugins/scenegraph/scenegraph.pro && \
    make -j8 && \
    make install
