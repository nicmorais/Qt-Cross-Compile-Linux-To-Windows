FROM debian:bullseye
WORKDIR /qt-windows
RUN apt update
RUN apt install wget xz-utils python3 llvm -y
RUN wget --no-verbose --show-progress --progress=bar:force:noscroll https://download.qt.io/archive/qt/5.15/5.15.2/single/qt-everywhere-src-5.15.2.tar.xz
#excludes really heavy components, which are used only on specific projects
RUN tar -xvf qt-everywhere-src-5.15.2.tar.xz --exclude='qtwebengine' --exclude='qtwebview' --exclude='qtquick3d'
RUN rm qt-everywhere-src-5.15.2.tar.xz
RUN apt install build-essential g++-mingw-w64 -y
#qt requires posix threads
RUN update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix
RUN update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
RUN update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
RUN update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix
WORKDIR /qt-windows/qt-everywhere-src-5.15.2
#the following configure command also skips lots of stuff. activeqt must be skipped, otherwise, it wont compile
RUN ./configure -xplatform win32-g++ -device-option CROSS_COMPILE=x86_64-w64-mingw32- -prefix /qt-windows/install -opensource -confirm-license -no-pch -nomake tests -nomake examples -skip qtcharts -skip qtconnectivity -skip qtdatavis3d -skip qtwebengine -skip qtwebsockets -skip qtwebview -skip qt3d -skip qtquick3d -skip qtspeech -skip qtgamepad -no-harfbuzz -skip qtpurchasing -skip qttranslations -skip qtserialport -skip qtlocation -skip activeqt -opengl desktop
#fix: do not try to execute fxc.exe
RUN sed -i '/qtConfig(d3d12): SUBDIRS += d3d12/c\#qtConfig(d3d12): SUBDIRS += d3d12' qtdeclarative/src/plugins/scenegraph/scenegraph.pro
RUN make -j8
RUN make install
