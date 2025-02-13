@echo off

set JAVA_HOME=C:\Program Files\Microsoft\jdk-11.0.16.101-hotspot\
set JAVAC="%JAVA_HOME%bin\javac.exe"
set JAR="%JAVA_HOME%bin\jar.exe"
set API_PATH=c:\Users\Public\Documents\Embarcadero\Studio\23.0\CatalogRepository\AndroidSDK-2525-23.0.51961.7529\platforms\android-34\

if not exist %JAVAC% (
  echo Cannot find java compiler. Check JAVA_HOME in this batch file.
  exit /b
)

if not exist %JAR% (
  echo Cannot find java archiver. Check JAVA_HOME in this batch file.
  exit /b
)

if not exist %API_PATH% (
  echo Cannot find API Level Path. Check API_PATH in this batch file.
  exit /b
)

REM Compile Java files
if exist classes (
  rmdir /S /Q classes
)
mkdir classes

%JAVAC% -classpath %API_PATH%\android.jar -d classes Java\SDL.java Java\SDLActivity.java Java\SDLAudioManager.java Java\SDLControllerManager.java Java\SDLDummyEdit.java Java\SDLInputConnection.java

REM Create Jar file
%JAR% cf ../Deploy/sdl3.jar -C classes .

