@echo off

set NDK_BUILD=c:\Users\Public\Documents\Embarcadero\Studio\23.0\CatalogRepository\AndroidNDK-21-23.0.51961.7529\android-ndk-r21\ndk-build.cmd
set NDK_STRIP32=c:\Users\Public\Documents\Embarcadero\Studio\23.0\CatalogRepository\AndroidNDK-21-23.0.51961.7529\android-ndk-r21\toolchains\arm-linux-androideabi-4.9\prebuilt\windows-x86_64\bin\arm-linux-androideabi-strip.exe
set NDK_STRIP64=c:\Users\Public\Documents\Embarcadero\Studio\23.0\CatalogRepository\AndroidNDK-21-23.0.51961.7529\android-ndk-r21\toolchains\aarch64-linux-android-4.9\prebuilt\windows-x86_64\aarch64-linux-android\bin\strip.exe

set LIB32=obj\local\armeabi-v7a\libSDL3_image.a
set LIB64=obj\local\arm64-v8a\libSDL3_image.a

if not exist %NDK_BUILD% (
  echo Cannot find ndk-build. Check NDK_BUILD in this batch file.
  exit /b
)

if not exist %NDK_STRIP32% (
  echo Cannot find ndk-strip32. Check NDK_STRIP32 in this batch file.
  exit /b
)
if not exist %NDK_STRIP64% (
  echo Cannot find ndk-strip64. Check NDK_STRIP64 in this batch file.
  exit /b
)

REM Run ndk-build to build static library
call %NDK_BUILD%

if not exist %LIB32% (
  echo Cannot find static library %LIB32%
  exit /b
)

if not exist %LIB64% (
  echo Cannot find static library %LIB64%
  exit /b
)

REM Remove debug symbols
%NDK_STRIP32% -g -X %LIB32%
%NDK_STRIP64% -g -X %LIB64%

REM Copy static library to directory with Delphi source code
copy %LIB32% .\libSdl3Image_android32.a
if %ERRORLEVEL% NEQ 0 (
  echo Cannot copy static library. Make sure it is not write protected
)

copy %LIB64% .\libSdl3Image_android64.a
if %ERRORLEVEL% NEQ 0 (
  echo Cannot copy static library. Make sure it is not write protected
)

REM Remove temprary files
rd obj /s /q