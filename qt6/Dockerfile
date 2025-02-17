FROM ubuntu:latest
WORKDIR /
COPY mingw-w64-x86_64.cmake /
RUN apt update
RUN apt install git g++ g++-mingw-w64 cmake ninja-build libclang-dev llvm-dev libgl1-mesa-dev libglu1-mesa-dev python3 -y
RUN git clone https://github.com/qt/qt5 --branch 6.5.2 qt6
WORKDIR /qt6
RUN ./init-repository --module-subset=essential #you can change this subset if you want to
WORKDIR /qt6/build
RUN ../configure -prefix /qt6-linux -no-feature-accessibility -skip qtqa -no-pch -no-feature-testlib -no-feature-xml -no-feature-sql -no-feature-printsupport -no-feature-linguist -no-feature-dbus  -skip qtdoc -no-harfbuzz -nomake tests -nomake examples -no-feature-assistant -no-feature-designer -- -Wno-dev
RUN cmake --build . --parallel
RUN cmake --install . #installs host build to /qt6-linux

#qt requires posix threads
RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix
RUN update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
RUN rm -r * #cleans build directory
#windows configuring:
RUN ../configure -platform linux-g++  -xplatform win32-g++ -device-option CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32- -prefix /qt6-windows/ -qt-host-path /qt6-linux -opensource -confirm-license -skip qtqa -skip qtdoc -opengl desktop -no-feature-assistant -no-pch -no-feature-testlib -no-feature-xml -no-feature-sql -no-feature-linguist -no-feature-dbus -no-feature-printsupport -no-feature-designer -nomake tests -nomake examples -no-harfbuzz -- -DQT_FORCE_BUILD_TOOLS=ON -DCMAKE_TOOLCHAIN_FILE=/mingw-w64-x86_64.cmake

RUN cmake --build . --parallel
RUN cmake --install . #installs host build to /qt6-windows

