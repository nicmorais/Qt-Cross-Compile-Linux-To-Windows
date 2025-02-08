FROM debian:12
WORKDIR /
COPY mingw-w64-x86_64.cmake /
RUN apt update
RUN apt install llvm build-essential g++-mingw-w64 cmake ninja-build git libgl1-mesa-dev  libglu1-mesa-dev -y
RUN git clone https://github.com/qt/qt5 --branch 6.5.2 qt6
WORKDIR /qt6
RUN ./init-repository --module-subset=essential #you can change this subset if you want to
WORKDIR /qt6/build
RUN ../configure -prefix /qt6-linux -no-feature-accessibility -skip qtqa -no-feature-printsupport  -no-feature-linguist -skip qtdoc -no-harfbuzz -nomake tests -nomake examples -no-feature-assistant -no-feature-designer
RUN cmake --build . --parallel
RUN cmake --install . #installs host build to /qt6-linux

#qt requires posix threads
RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix
RUN update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
RUN rm -r * #cleans build directory
#windows configuring:
RUN ../configure -platform linux-g++  -xplatform win32-g++ -device-option CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32- -prefix /qt6-windows/ -qt-host-path /qt6-linux -opensource -confirm-license -skip qtqa -skip qtdoc -opengl desktop -no-feature-assistant -no-feature-designer -nomake tests -nomake examples -no-harfbuzz -- -DQT_FORCE_BUILD_TOOLS=ON -DCMAKE_TOOLCHAIN_FILE=/mingw-w64-x86_64.cmake

RUN cmake --build . --parallel
RUN cmake --install . #installs host build to /qt6-windows

