# Cross-compiling Qt to Windows from Linux


## Qt 5.15.2

First of all, download Qt source files:

`wget https://download.qt.io/archive/qt/5.15/5.15.2/single/qt-everywhere-src-5.15.2.tar.xz`


After that, install the building stuff:

- Ubuntu/Debian:

- `sudo apt install build-essential g++-mingw-w64`

We need to switch the compilers to the Posix alternative (as shown in [here](https://stackoverflow.com/questions/14191566/c-mutex-in-namespace-std-does-not-name-a-type)) . You can do so by running:

```bash

sudo update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix

sudo update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix

sudo update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix

sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

```

Now, extract the Qt source files:

`tar -xvf qt-everywhere-src-5.15.2.tar.xz`

Cd in there:

`cd qt-everywhere-src-5.15.2`

### Configuring

The following command may be customized to fit your needs:

We are skipping some features that are not so popular among Qt users.

`./configure -xplatform win32-g++ -device-option CROSS_COMPILE=x86_64-w64-mingw32- -prefix $HOME/qt-windows-install -opensource -confirm-license -no-pch -nomake tests -nomake examples -skip qtcharts -skip qtconnectivity -skip qtdatavis3d -skip qtwebengine -skip qtwebsockets -skip qtwebview -skip qt3d -skip qtquick3d -skip qtspeech -skip qtgamepad -no-harfbuzz -skip qtpurchasing -skip qttranslations -skip qtserialport -skip qtlocation -skip activeqt -opengl desktop`

The `-prefix $HOME/qt-windows-install` variable tells where you want the libraries to be placed when executing `make install`.

### Building

To prevent Qt from trying to call an .exe to process DirectX things, run the following line:

`sed -i '/qtConfig(d3d12): SUBDIRS += d3d12/c\#qtConfig(d3d12): SUBDIRS += d3d12' qtdeclarative/src/plugins/scenegraph/scenegraph.pro`

Everything ready? Let's go:

`make -j8`

**Tip:** You can make it faster by replacing the number 8 by a greater value, or by just running `make -j`. Beware: the greater the number, the more RAM is consumed. Running it with `make -j` can cause an OOM (out of memory) exception to occur.

### Installing

Because the `./configure` part above was executed with `-prefix $HOME/qt-windows-install`, compiled files will be placed at `~/qt-windows-install` during the installation step. If you're ok with that, just do:

```bash
make install
```

## Qt 6

The Qt framework is now requiring a host build to be pointed when cross compiling. We could get it from the package manager (such as APT), but if the version available there is different from the one we want to cross compile, it may not work.

The safest way to get it done is by buiding Qt 6 targeting the host (Linux) before building it targeting Windows®.

```bash
sudo apt install build-essential g++-mingw-w64 cmake ninja-build git libgl1-mesa-dev  libglu1-mesa-dev -y
git clone https://github.com/qt/qt5 --branch 6.5.2 qt6
cd qt6
./init-repository --module-subset=essential #you can change this subset if you want to
mkdir qt6/build
cd qt6/build
../configure -prefix ../qt6-linux -no-feature-accessibility -skip qtqa -no-feature-printsupport  -no-feature-linguist -skip qtdoc -no-harfbuzz -nomake tests -nomake examples -no-feature-assistant -no-feature-designer
cmake --build . --parallel #builds it
cmake --install . #installs it at '../qt6-linux'
rm -r * #cleaning the building directory to build it for Windows®

sudo update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix
sudo update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix
sudo update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix
sudo update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix

../configure -platform linux-g++  -xplatform win32-g++ -device-option CROSS_COMPILE=/usr/bin/x86_64-w64-mingw32- -prefix ../qt6-windows/ -qt-host-path ../qt6-linux -opensource -confirm-license -skip qtqa -skip qtdoc -opengl desktop -no-feature-assistant -no-feature-designer -nomake tests -nomake examples -no-harfbuzz -- -DQT_FORCE_BUILD_TOOLS=ON -DCMAKE_TOOLCHAIN_FILE=/mingw-w64-x86_64.cmake

RUN cmake --build . --parallel
RUN cmake --install . #installs host build to '../qt6-windows'
```


#### Cross compiling your application

Let's say we got an application called `QuickTest`, built with CMake:

```
QuickTest/
├── CMakeLists.txt
├── main.cpp
├── main.qml
└── qml.qrc
```

This is how you would cross compile `QuickTest` for Windows (make sure to match CMAKE_PREFIX_PATH to your cross compiled Qt for Windows directory):

`cd QuickTest`

`cmake -S . -B build -DCMAKE_PREFIX_PATH=$HOME/qt-windows-install/lib/cmake -DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc -DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++`

`cd build`

`make -j`

If everything goes well, there will be a QuickTest.exe under the `build` directory.

#### Deploying your application

The .exe file may _not_ be enough when deploying your application.

You will probably need to ship some Qt dlls along your app, and such dlls can be just copied from `$HOME/qt-windows-install/bin` to the same directory where the .exe is at.

Just make sure to not copy unnecessary dlls (can make your deploy bloated).

Non-Qt dlls should be copied from /usr/lib/gcc/x86_64-w64-mingw32/10-posix/, like:

- D3Dcompiler_47.dll
- libatomic-1.dll
- libcrypto-1_1-x64.dll
- libEGL.dll
- libGLESv2.dll
- libgcc_s_seh-1.dll
- libstdc++-6.dll
- libwinpthread-1.dll
- opengl32sw.dll

These are needed to your app run in Windows machines.

Now, make a `plugins` folder and copy the most relevants stuff in `$HOME/qt-windows-install/plugins`.

If your app has QML code, make a `qml` directory and copy files from `$HOME/qt-windows-install/qml`.


### Cross-compiling with Docker

Clone this repository:

`git clone https://github.com/nicmorais/Qt-Cross-Compile-Linux-To-Windows`

Cd:

`cd Qt-Cross-Compile-Linux-To-Windows`

`cd qt6`

Start building the image:

`sudo docker build .`

This can take 30 minutes, depending on your machine. You can edit the line `RUN make -j8` in the Dockerfile to speed up the process (beware of OOM).
