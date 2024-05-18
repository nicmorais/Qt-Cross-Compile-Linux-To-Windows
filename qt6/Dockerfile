FROM ubuntu:jammy
WORKDIR /qt-windows
COPY mingw-w64-x86_64.cmake /qt-windows/
RUN apt update
RUN apt install wget llvm build-essential g++-mingw-w64 cmake ninja-build git qt6-base-dev -y
RUN git clone https://github.com/qt/qt5 --branch 6.2.4 qt6
WORKDIR /qt-windows/qt6
RUN git clone https://github.com/qt/qtbase --branch 6.2.4
#qt requires posix threads
RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix
RUN update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

RUN ./configure -platform linux-g++  -xplatform win32-g++ -device-option CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32- -prefix /qt-windows/qt6/install -qt-host-path /usr/lib/x86_64-linux-gnu/cmake  -opensource -confirm-license -opengl desktop -no-pch -nomake tests -nomake examples -no-harfbuzz -- -DQT_FORCE_BUILD_TOOLS=ON -DCMAKE_TOOLCHAIN_FILE=/qt-windows/mingw-w64-x86_64.cmake

#hack: this value is not defined in g++-mingw-w64, so we replace it with 0
#this will break the feature of detecting hotspot networks that require authentication.
# RUN sed -i 's/NLM_INTERNET_CONNECTIVITY_WEBHIJACK/0x0/g' qtbase/src/plugins/networkinformation/networklistmanager/qnetworklistmanagernetworkinformationbackend.cpp

RUN ninja
RUN ninja install

