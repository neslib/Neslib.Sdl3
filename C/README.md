# Building the native SDL libraries

This is internal documentation. It gives a short bullet point descriptions for building the SDL native (dynamic and static) libraries. For details information, see https://github.com/libsdl-org/SDL/tree/main/docs.

## Windows

Download pre-compiled DLLs from GitHub releases.

## macOS

### SDL

* Download and unpack tar.gz from GitHub releases.
* Use CMake GUI. After Configure, set:
  * CMAKE_OSX_DEPLOYMENT_TARGET to 10.13
  * Check SDL_STATIC
  * Uncheck SDL_SHARED
  * Make sure SDL_FRAMEWORK is unchecked
* Configure again.
* Press Generate.
* Open project.
* Choose the SDL3-static project in the toolbar.
* In Xcode, choose "Product | Scheme | Edit Scheme.."
* Select the "Run" scheme and set Build Configuration to Release
* Choose "Product | Build For | Running"
* In the project view, expand the "Products" node to locate the libSDL3.a file. Right click it and select "Show in Finder". Copy and rename this file to "libSdl3_macos_intel.a".

### SDL_image

* Download and unpack tar.gz from GitHub releases.
* After pressing Configure in CMake, you get an error that SDL3Config.cmake cannot be found. Make these changes:
  * SDL3_DIR: set this to the directory where you build the macOS version of SDL3 above (not the SDL3 directory itself, but the subdirectory you specified in CMake for the macOS build)
  * Uncheck BUILD_SHARED_LIBS
  * Set CMAKE_OSX_DEPLOYMENT_TARGET to 10.13
* Press Configure again.
* The rest is similar to building SDL above.

### SDL_ttf

  * Download and unpack tar.gz from GitHub releases.
  * Navigate to "external" directory and execute "download.sh" in terminal window.
  * We don't use CMake since this requires building FreeType and HarfBuzz separately and results in multiple static libraries. Instead, we use a custom made shell script:
  * Copy "Sdl3TtfMacOS.sh" from the Neslib.Sdl3\C directory to the unpacked root directory.
  * Open a terminal and run this shell script. It creates the static library in the same directory.

## iOS

### SDL

* Download and unpack tar.gz from GitHub releases.
* Use CMake GUI. 
* When pressing "Configure", choose "Specify options for cross-compiling".
* On the next page, set "Operating System" to "iOS" (case sensitive) and "Version" to "12.0"
* After Configure, set:
  * CMAKE_OSX_DEPLOYMENT_TARGET to 12.0 (add if needed)
  * Check SDL_STATIC
  * Uncheck SDL_SHARED
  * Make sure SDL_FRAMEWORK is unchecked

* Configure again.
* Press Generate.
* Open project.
* Choose the SDL3-static project in the toolbar.
* Choose SDL3 in the side bar, and then the SDL3-static target in the nested side bar:
  * Select the "Build Settings" tab.
  * Navigate to "Apple Clang - Custom Compiler Flags | Other C Flags".
  * In the "Release" configuration, add the compiler options "-fno-objc-msgsend-selector-stubs". Without this option, Clang will create optimized msgsend calls, but Delphi does not understand these, resulting on a lot of "undefined _objc_msgSend$... symbol" error messages.
* We need to disable HID support since Delphi does not support importing the CoreBluetooth framework:
  * Navigate to "Apple Clang - Preprocessing | Preprocessing macros"
  * In the "Release" configuration, add "SDL_HIDAPI_DISABLED=1"
* In Xcode, choose "Product | Scheme | Edit Scheme.."
* Select the "Run" scheme and set Build Configuration to Release
* Choose "Product | Build For | Running"
* In the project view, expand the "Products" tab to locate the libSDL3.a file. Right click it and select "Show in Finder". Copy and rename this file to "libSdl3_ios.a".

### SDL_image

* Download and unpack tar.gz from GitHub releases.
* Use CMake GUI. 
* When pressing "Configure", choose "Specify options for cross-compiling".
* On the next page, set "Operating System" to "iOS" (case sensitive) and "Version" to "12.0"
* You get an error that SDL3Config.cmake cannot be found. Make these changes:
  * SDL3_DIR: set this to the directory where you build the iOS version of SDL3 above (not the SDL3 directory itself, but the subdirectory you specified in CMake for the iOS build)
  * Uncheck BUILD_SHARED_LIBS
  * Set CMAKE_OSX_DEPLOYMENT_TARGET to 12.0 (add if needed)
* Press Configure again.
* The rest is similar to building SDL above, including adding the "-fno-objc-msgsend-selector-stubs" flag, but no need to set the  "SDL_HIDAPI_DISABLED=1" define.

### SDL_ttf

Use macOS instructions, but use "Sdl3TtfIOS.sh" instead of "Sdl3TtfMacOS.sh".

## Android

### SDL

* Download and unzip source code from GitHub releases.
* Open "src\core\android\SDL_android.c":
  * Remove the `Android_JNI_GetNativeWindow` function (it is implemented in Delphi instead).
  * In the `JNI_OnLoad` function remove *all* the `register_methods` calls. These will fail because the Delphi app is compiled into a dynamic library (.so), and this registration only works if the main app is written in Java.
* In the unzipped directory, create a directory called Android.
* Copy the BuildAndroid.bat file from the Neslib.Sdl3\Android directory to the Android subdirectory just created.
* Create a directory called "jni" under the Android directory.
* Copy the Application.mk file from the Neslib.Sdl3\Android directory to this Android\jni directory.
* Copy the Android.mk file from the unzipped SDL source directory to this Android\jni directory as well. Open this copy and a text editor and make the following changes:
  * Change to first line to `LOCAL_PATH := $(call my-dir)/../../` (that is, add `/../../` to the end).
  * In the LOCAL_SRC_FILES list, remove the entry `$(wildcard $(LOCAL_PATH)/src/hidapi/android/*.cpp)`. This is the only used C++ file, and removing this file removes the C++ dependency. We don't use HID anyway because it doesn't work on iOS (see above). Also, there are some license restrictions in this file.
  * Add the define `-DSDL_HIDAPI_DISABLED=1` to the LOCAL_CFLAGS option (after `-DGL_GLEXT_PROTOTYPES`).
  * Remove the entire "SDL_test static library" section (from `LOCAL_MODULE := SDL3_test` through `include $(BUILD_STATIC_LIBRARY)`). We don't need this section, and it also prevents building the regular static library.
* Run the BuildAndroid.bat file from the Android directory.

The Android version of SDL uses some Java code (in the directory "android-project\app\src\main\java\org\libsdl\app\"). We compile this Java code into a JAR file to link with Delphi. We need to make some changes to the SDLActivity.java file though, since this file contains a Java activity and we need a Native activity for Delphi. So whenever there is a new SDL 3 version, we need to do the following:

* Compare the Java files of the previous SDL 3 version to the new one. If there are no changes, we can are done.
* Copy the changed Java files to the Neslib.Sdl3\Android\Java directory, *except* for the SDLActivity.java file, SDLSurface.java and the HID*.java files.
* If there are differences between the 2 SDLActivity.java files (of the new and old SDL 3 version), then open the Neslib.Sdl3\Android\Java\SDLActivity.java file and apply the changes where appropriate (look for comments marked "Neslib"). If needed, update the Neslib.Sdl3.Android.pas file accordingly.
* Run the BuildJar.bat file.
* Clean all Delphi projects or remove any generated "sdl3-dexed.jar" files in any of the project subdirectories.

### SDL_image

* Download and unzip source code from GitHub releases.
* In the unzipped directory, create a directory called Android.
* Copy the BuildAndroid.bat file from the Neslib.Sdl3\Android\Sdl3Image directory to the Android subdirectory just created.
* Create a directory called "jni" under the Android directory.
* Copy the Application.mk file from the Neslib.Sdl3\Android\Sdl3Image directory to this Android\jni directory.
* Copy the Android.mk file from the unzipped SDL_Image source directory to this Android\jni directory as well. Open this copy and a text editor and make the following changes:
  * Change to first line to `LOCAL_PATH := $(call my-dir)/../../` (that is, add `/../../` to the end).
  * Remove or comment out the line `include $(BUILD_SHARED_LIBRARY)`
  * Before the last line that build the static library, add: `LOCAL_C_INCLUDES += $(LOCAL_PATH)/../SDL-release-3.2.4/include`, updating the path the the SDL include directory as necessary.
* Run the BuildAndroid.bat file from the Android directory.

### SDL_ttf

* Download and unzip source code from GitHub releases.
* Open PowerShell prompt in "external" subdirectory and enter `./Get-GitModules.ps1`
* In the unzipped directory, create a directory called Android.
* Copy the BuildAndroid.bat file from the Neslib.Sdl3\Android\Sdl3Image directory to the Android subdirectory just created.
* Create a directory called "jni" under the Android directory.
* Copy the Android.mk and Application.mk files from the Neslib.Sdl3\Android\Sdl3Image directory to this Android\jni directory. Note that this is a custom Android.mk file that creates a single static library instead of separate static libraries for SDL_ttf, FreeType and HarfBuzz.
* Run the BuildAndroid.bat file from the Android directory.
