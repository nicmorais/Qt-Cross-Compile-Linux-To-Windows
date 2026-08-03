FROM ubuntu:latest AS builder
 
WORKDIR /
COPY mingw-w64-x86_64.cmake /
 
RUN apt update && \
    apt install git g++ g++-mingw-w64 cmake ninja-build libclang-dev llvm-dev libgl1-mesa-dev libglu1-mesa-dev python3 -y && \
    git clone https://github.com/qt/qt5 --branch 6.11.0 qt6 && \
    cd /qt6 && \
    #you can change this subset if you want to
    ./init-repository --module-subset=essential,-qtwebengine,-qt3d,-qtdoc,-qtlanguageserver,-qtactiveqt,-qt3d,-qtwebengine,-qtqa && \
    mkdir -p /qt6/build && \
    cd /qt6/build && \
    echo -e "Building Qt6 for host (Linux)\n"  && \
    ../configure -prefix /qt6-linux \
    -no-feature-accessibility \
    -skip qtqa \
    -no-pch \
    -no-feature-testlib \
    -no-feature-xml \
    -no-feature-sql \
    -no-feature-printsupport \
    -no-feature-linguist \
    -no-feature-dbus  \
    -skip qtdoc \
    -no-harfbuzz \
    -nomake tests \
    -nomake examples \
   -no-feature-assistant \
    -no-feature-designer -- -Wno-dev && \
    cmake --build . --parallel && \
    #installs host build to /qt6-linux
    cmake --install .
 
     #qt requires posix threads
RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix && \
    update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix && \
    update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix && \
    update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix && \
    cd /qt6/build && \
    rm -r /qt6/build/* && \
    #windows configuring:
    echo -e "Building Qt6 for target (Windows)\n"  && \
    ../configure -platform linux-g++ \
    -xplatform win32-g++ \
    -device-option CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32- -prefix /qt6-windows/ \
    -qt-host-path /qt6-linux \
    -opensource -confirm-license \
    -skip qtqa \
    -skip qtdoc \
    -opengl desktop \
    -no-feature-assistant \
    -no-pch \
    -no-feature-testlib \
    -no-feature-xml \
    -no-feature-sql \
    -no-feature-linguist \
    -no-feature-dbus \
    -no-feature-printsupport \
    -no-feature-designer \
    -nomake tests \
    -nomake examples \
    -no-harfbuzz -- -DQT_FORCE_BUILD_TOOLS=ON -DCMAKE_TOOLCHAIN_FILE=/mingw-w64-x86_64.cmake && \
    #hack, because netlistmgr.h on linux lacks this
    sed -i 's/NLM_INTERNET_CONNECTIVITY_WEBHIJACK/0x1/g' ../qtbase/src/plugins/networkinformation/networklistmanager/qnetworklistmanagerevents.cpp && \
    cmake --build . --parallel && \
    cmake --install . #installs host build to /qt6-windows
