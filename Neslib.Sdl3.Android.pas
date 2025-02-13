unit Neslib.Sdl3.Android;

{$Include 'Neslib.Sdl3.inc'}

interface

uses
  Androidapi.AppGlue,
  Neslib.Sdl3.Api;

procedure AndroidInitSdl(const AMainProc: TSdlProc);

implementation

uses
  System.Math,
  System.Types,
//  System.TypInfo,
  System.Character,
  System.Classes,
  System.SysUtils,
  Androidapi.Helpers,
  Androidapi.Input,
  Androidapi.Jni,
  Androidapi.Jni.App,
  Androidapi.Jni.GraphicsContentViewText,
  Androidapi.Jni.JavaTypes,
  Androidapi.Jni.Util,
  Androidapi.JniBridge,
  Androidapi.KeyCodes,
  Androidapi.Looper,
//  Androidapi.Log,
  Androidapi.NativeActivity,
  Androidapi.NativeWindow,
  Androidapi.Sensor;

{ Force linking in some system libraries that are required by SDL.
  Note that these are just dummy procedures that are never actually called.
  They are just here to force the Delphi linker to link the corresponding
  system library. }

procedure __DummyGLESv2; cdecl; external '/usr/lib/libGLESv2.so' name 'glUseProgram';
procedure __DummyLog; cdecl; external '/usr/lib/liblog.so' name '__android_log_write';
procedure __DummyOpenSLES; cdecl; external '/usr/lib/libOpenSLES.so' name 'slCreateEngine';

{ SDL calls the NDK functions android_getCpuFamily and android_getCpuFeatures.
  However, these functions are not available in any library, only as source code
  in the NDK. So we need to implement and export these functions ourselves.
  Fortunately, for our needs the implementations can be very simple. See the
  NDK source code for reference. }

function android_getCpuFamily: Int32; cdecl;
begin
  {$IFDEF CPU32BITS}
  Result := 1; // ANDROID_CPU_FAMILY_ARM
  {$ELSE}
  Result := 4; // ANDROID_CPU_FAMILY_ARM64
  {$ENDIF}
end;

function android_getCpuFeatures: UInt64; cdecl;
begin
  {$IFDEF CPU32BITS}
  Result := (1 shl 2);// ANDROID_CPU_ARM_FEATURE_NEON (only flag that is checked by SDL)
  {$ELSE}
  Result := 0;
  {$ENDIF}
end;

{ NOTE: SDL3 for Android normally depends on a Java activity (called
  SDLActivity). Since Delphi already has its own (native) activity, we cannot
  use the Java activity as well.

  So we modified SDLActivity.java so that the SDLActivity class is not an
  activity anymore, but a plain old class. It still provides some of the
  original functionality (which is used through JNI by the SDL_android.c file
  in the static library). However, other functionality, such as window and input
  management has been replaced with native NDK code in this unit (see
  TSdlAppGlue).

  Java calls back into the C code using native methods with names that begin
  with Java_org_libsdl_app_*. We need to import these methods here, and export
  them again so that the Java library can find them. For most of these methods,
  we don't provide a function signature (parameters), since it just suffices to'
  make the symbols available to Java. However, a couple of these methods are
  called from this unit now instead, so these have full signatures.

  The function Android_JNI_GetNativeWindow has been removed SDL_android.c. This
  function used to call into Java to get the window surface, and convert it to a
  native window. Since we don't use a window surface on the Java side anymore,
  this function is now implemented (and exported) in this unit. It returns the
  NDK native window instead. }

{ Called from SDLActivity.java (and some from TSdlAppGlue) }

procedure Java_org_libsdl_app_SDLActivity_nativeGetVersion; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeSetupJNI; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeInitMainThread; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeCleanupMainThread; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeRunMain; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeLowMemory(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeSendQuit; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeQuit(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativePause(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeResume(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeFocusChanged(env: PJNIEnv; cls: JNIClass; hasFocus: JNIBoolean); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeDropFile; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeSetScreenResolution; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeResize(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeKeyDown; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeKeyUp; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeSoftReturnKey; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeKeyboardFocusLost; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeMouse; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeTouch; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativePen; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeAccel(env: PJNIEnv; cls: JNIClass; x, y, z: Single); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeClipboardChanged; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeSurfaceCreated; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeSurfaceChanged(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeSurfaceDestroyed(env: PJNIEnv; cls: JNIClass); cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeGetHint; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeGetHintBoolean; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeSetenv; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeRotationChanged; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeInsetsChanged; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeAddTouch; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativePermissionResult; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeLocaleChanged; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeDarkModeChanged; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeAllowRecreateActivity; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_nativeCheckSDLThreadCounter; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLActivity_onNativeFileDialog; cdecl; external LIB_SDL3;

{ Called from SDLAudioManager.java }

procedure Java_org_libsdl_app_SDLAudioManager_nativeSetupJNI; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLAudioManager_removeAudioDevice; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLAudioManager_addAudioDevice; cdecl; external LIB_SDL3;

{ Called from SDLControllerManager.java }

procedure Java_org_libsdl_app_SDLControllerManager_nativeSetupJNI; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_nativeAddJoystick; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_nativeRemoveJoystick; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_nativeAddHaptic; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_nativeRemoveHaptic; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_onNativePadDown; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_onNativePadUp; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_onNativeJoy; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLControllerManager_onNativeHat; cdecl; external LIB_SDL3;

{ Called from SDLInputConnection.java }

procedure Java_org_libsdl_app_SDLInputConnection_nativeCommitText; cdecl; external LIB_SDL3;
procedure Java_org_libsdl_app_SDLInputConnection_nativeGenerateScancodeForUnichar; cdecl; external LIB_SDL3;

{ Additional internal SDL APIs }

function JNI_OnLoad(vm: PJavaVM; reserved: Pointer): JNIInt;
  cdecl; external LIB_SDL3;

function Android_OnPadDown(deviceId, KeyCode: Integer): Integer;
  cdecl; external LIB_SDL3;

function Android_OnPadUp(deviceId, KeyCode: Integer): Integer;
  cdecl; external LIB_SDL3;

function Android_OnKeyDown(KeyCode: Integer): Integer;
  cdecl; external LIB_SDL3;

function Android_OnKeyUp(KeyCode: Integer): Integer;
  cdecl; external LIB_SDL3;

procedure Android_OnMouse(window: SDL_Window; state, action: Integer; x, y: Single; relative: Boolean);
  cdecl; external LIB_SDL3;

procedure Android_OnPen(window: SDL_Window; pen_id_in, button, action: Integer; x, y, p: Single);
  cdecl; external LIB_SDL3;

procedure Android_OnTouch(window: SDL_Window; touch_device_id_in, pointer_finger_id_in, action: Integer; x, y, p: Single);
  cdecl; external LIB_SDL3;

procedure Android_SetScreenResolution(surfaceWidth, surfaceHeight, deviceWidth, deviceHeight: Integer; density, rate: Single);
  cdecl; external LIB_SDL3;

procedure _Android_Window; cdecl; external LIB_SDL3 name 'Android_Window';

function SDL_SendKeyboardText(const text: MarshaledAString): Integer;
  cdecl; external LIB_SDL3;

//procedure Log(const AMsg: String); overload;
//begin
//  __android_log_write(android_LogPriority.ANDROID_LOG_INFO, '##SDL##',
//    PAnsiChar(AnsiString(AMsg)));
//end;
//
//procedure Log(const AMsg: String; const AArgs: array of const); overload;
//begin
//  Log(Format(AMsg, AArgs));
//end;

var
  GAndroidWindow: PSDL_Window = nil;

function AndroidWindow: SDL_Window;
begin
//  Log('AndroidWindow BEGIN');
  if (GAndroidWindow = nil) then
    GAndroidWindow := @_Android_Window;

  Result := GAndroidWindow^;
//  if (Result = 0) then
//    Log('AndroidWindow(nil)')
//  else
//  begin
//    var W, H: Integer;
//    SDL_GetWindowSize(Result, @W, @H);
//    Log('AndroidWindow(%d x %d)', [W, H]);
//  end;
end;

type
  { Gives access to the SDLActivity class.
    We don't really care about the methods in this class since they are only
    used internally, or using JNI on in SDL_android.c.
    We do need the constructor (init function) though. }
  [JavaSignature('org/libsdl/app/SDLActivity')]
  JSDLActivity = interface(JObject)
  ['{7B28B221-7106-4965-B838-4A7A166F8B85}']
  end;

  JSDLActivityClass = interface(JObjectClass)
  ['{29EEA562-EED0-4D3E-8D97-C82ADD1E4281}']
    {class} function init(activity: JActivity; hostLibName: JString): JSDLActivity; cdecl;
  end;
  TJSDLActivity = class(TJavaGenericImport<JSDLActivityClass, JSDLActivity>) end;

type
  { Partial import of SDLControllerManager }
  [JavaSignature('org/libsdl/app/SDLControllerManager')]
  JSDLControllerManager = interface(JObject)
  ['{F9EA575E-5254-41CC-90CF-B15B91258D36}']
  end;

  JSDLControllerManagerClass = interface(JObjectClass)
  ['{2E5B9E03-62D4-4D86-8EC7-A5C144B9942C}']
    {class} function isDeviceSDLJoystick(deviceId: Integer): Boolean; cdecl;
  end;
  TJSDLControllerManager = class(TJavaGenericImport<JSDLControllerManagerClass, JSDLControllerManager>) end;

{$SCOPEDENUMS ON}

type
  { SDL-specific application glue }
  { TODO : Implement multi-window stuff from SDLActivity.java }
  TSdlAppGlue = class
  private type
    TNativeState = (Init, Resumed, Paused);
  private
    FMainProc: TSdlProc;
    FSdlThread: TThread;
    FDisplay: JDisplay;
    FSdlActivity: JSDLActivity;
    FSensor: PASensor;
    FSensorEventQueue: PASensorEventQueue;
    FWidth: Integer;
    FHeight: Integer;
    FRotation: Integer;
    FNextNativeState: TNativeState;
    FCurrentNativeState: TNativeState;
    FIsResumedCalled: Boolean;
    FIsSurfaceReady: Boolean;
    FInitialized: Boolean;
    FHasFocus: Boolean;
  private
    class function SensorLooperCallback(AFileDescriptor, AEvents: Integer;
      AData: Pointer): Integer; cdecl; static;
  private
    class function IsTextInputEvent(const AKeyCode, AMeta: Integer): Boolean; static;
  private
    procedure HandleAppCommand(const AApp: TAndroidApplicationGlue;
      const ACommand: TAndroidApplicationCommand);
    function HandleInput(const AApp: TAndroidApplicationGlue;
      const AEvent: PAInputEvent): Int32;
    procedure HandleContentRect(const AApp: TAndroidApplicationGlue;
      const ARect: TRect);
  private
    procedure HandleNativeState;
    function HandleKeyEvent(const AEvent: PAInputEvent): Int32;
    function HandleMotionEvent(const AEvent: PAInputEvent): Int32;
    procedure HandleSensorEvents;
    procedure EnableSensor(const AType: Integer; const AEnable: Boolean);
  private
    procedure SurfaceChanged;
    procedure SurfaceDestroyed;
  public
    constructor Create(const AMainProc: TSdlProc);
  end;

var
  GAppGlue: TSdlAppGlue = nil;

procedure AndroidInitSdl(const AMainProc: TSdlProc);
begin
  GAppGlue := TSdlAppGlue.Create(AMainProc);
  SDL_SetMainReady;
end;

function Android_JNI_GetNativeWindow: PANativeWindow; cdecl;
{ This function was originally in SDL_android.c but reimplemented here to not
  require a Java surface }
begin
  Result := TAndroidApplicationGlue.Current.Window;
//  if (Result = nil) then
//    Log('Android_JNI_GetNativeWindow(nil)')
//  else
//    Log('Android_JNI_GetNativeWindow(%d x %d)', [ANativeWindow_getWidth(Result), ANativeWindow_getHeight(Result)]);
end;

{ TSdlAppGlue }

const // Key codes to ansi characters
  KEY_CHARS: array [0..AKEYCODE_NUMPAD_RIGHT_PAREN] of UTF8Char = (
    #0 , #0 , #0 , #0 , #0 , #0 , #0 , '0', '1', '2', '3', '4', '5', '6', '7', '8',
    '9', '*', '#', #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , 'a', 'b', 'c',
    'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
    't', 'u', 'v', 'w', 'x', 'y', 'z', ',', '.', #0 , #0 , #0 , #0 , #0 , ' ', #0 ,
    #0 , #0 , #0 , #0 , '`', '-', '=', '[', ']', '\', ';', '''', '/', '@', #0, #0 ,
    #0 , '+', #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 ,
    #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 ,
    #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 ,
    #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 , #0 ,
    '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '/', '*', '-', '+', '.', ',',
    #0 , '=', '(', ')');

constructor TSdlAppGlue.Create(const AMainProc: TSdlProc);
begin
//  Log('TSdlAppGlue.Create BEGIN');
  Assert(Assigned(AMainProc));
  inherited Create;
  FMainProc := AMainProc;
  FDisplay := TAndroidHelper.Display;
  FRotation := FDisplay.getRotation;
  FWidth := 1;
  FHeight := 1;

  var NativeActivity := PANativeActivity(DelphiActivity);
  JNI_OnLoad(NativeActivity.vm, nil);

  var App := TAndroidApplicationGlue.Current;
  App.OnApplicationCommandEvent := HandleAppCommand;
  App.OnInputEvent := HandleInput;
  App.OnContentRectEvent := HandleContentRect;

  var SensorManager := ASensorManager_getInstance;
  FSensor := ASensorManager_getDefaultSensor(SensorManager, ASENSOR_TYPE_ACCELEROMETER);
  FSensorEventQueue := ASensorManager_createEventQueue(SensorManager,
    ALooper_forThread, ALOOPER_POLL_CALLBACK, SensorLooperCallback, nil);

  var LibName := JStringToString(TAndroidHelper.Context.getPackageName); // com.embarcadero.<name>
  LibName := ExtractFileExt(LibName); // .<name>
  if (LibName.StartsWith('.')) then
    LibName := LibName.Substring(1);

  FSdlActivity := TJSDLActivity.JavaClass.init(TAndroidHelper.Activity,
    StringToJString(LibName));
//  Log('TSdlAppGlue.Create END')
end;

exports
  android_getCpuFamily,
  android_getCpuFeatures,
  Android_JNI_GetNativeWindow,
  Java_org_libsdl_app_SDLActivity_nativeGetVersion,
  Java_org_libsdl_app_SDLActivity_nativeSetupJNI,
  Java_org_libsdl_app_SDLActivity_nativeInitMainThread,
  Java_org_libsdl_app_SDLActivity_nativeCleanupMainThread,
  Java_org_libsdl_app_SDLActivity_nativeRunMain,
  Java_org_libsdl_app_SDLActivity_nativeLowMemory,
  Java_org_libsdl_app_SDLActivity_nativeSendQuit,
  Java_org_libsdl_app_SDLActivity_nativeQuit,
  Java_org_libsdl_app_SDLActivity_nativePause,
  Java_org_libsdl_app_SDLActivity_nativeResume,
  Java_org_libsdl_app_SDLActivity_nativeFocusChanged,
  Java_org_libsdl_app_SDLActivity_onNativeDropFile,
  Java_org_libsdl_app_SDLActivity_nativeSetScreenResolution,
  Java_org_libsdl_app_SDLActivity_onNativeResize,
  Java_org_libsdl_app_SDLActivity_onNativeKeyDown,
  Java_org_libsdl_app_SDLActivity_onNativeKeyUp,
  Java_org_libsdl_app_SDLActivity_onNativeSoftReturnKey,
  Java_org_libsdl_app_SDLActivity_onNativeKeyboardFocusLost,
  Java_org_libsdl_app_SDLActivity_onNativeMouse,
  Java_org_libsdl_app_SDLActivity_onNativeTouch,
  Java_org_libsdl_app_SDLActivity_onNativePen,
  Java_org_libsdl_app_SDLActivity_onNativeAccel,
  Java_org_libsdl_app_SDLActivity_onNativeClipboardChanged,
  Java_org_libsdl_app_SDLActivity_onNativeSurfaceCreated,
  Java_org_libsdl_app_SDLActivity_onNativeSurfaceChanged,
  Java_org_libsdl_app_SDLActivity_onNativeSurfaceDestroyed,
  Java_org_libsdl_app_SDLActivity_nativeGetHint,
  Java_org_libsdl_app_SDLActivity_nativeGetHintBoolean,
  Java_org_libsdl_app_SDLActivity_nativeSetenv,
  Java_org_libsdl_app_SDLActivity_nativeSetNaturalOrientation,
  Java_org_libsdl_app_SDLActivity_onNativeRotationChanged,
  Java_org_libsdl_app_SDLActivity_onNativeInsetsChanged,
  Java_org_libsdl_app_SDLActivity_nativeAddTouch,
  Java_org_libsdl_app_SDLActivity_nativePermissionResult,
  Java_org_libsdl_app_SDLActivity_onNativeLocaleChanged,
  Java_org_libsdl_app_SDLActivity_onNativeDarkModeChanged,
  Java_org_libsdl_app_SDLActivity_nativeAllowRecreateActivity,
  Java_org_libsdl_app_SDLActivity_nativeCheckSDLThreadCounter,
  Java_org_libsdl_app_SDLActivity_onNativeFileDialog,
  Java_org_libsdl_app_SDLAudioManager_nativeSetupJNI,
  Java_org_libsdl_app_SDLAudioManager_removeAudioDevice,
  Java_org_libsdl_app_SDLAudioManager_addAudioDevice,
  Java_org_libsdl_app_SDLControllerManager_nativeSetupJNI,
  Java_org_libsdl_app_SDLControllerManager_nativeAddJoystick,
  Java_org_libsdl_app_SDLControllerManager_nativeRemoveJoystick,
  Java_org_libsdl_app_SDLControllerManager_nativeAddHaptic,
  Java_org_libsdl_app_SDLControllerManager_nativeRemoveHaptic,
  Java_org_libsdl_app_SDLControllerManager_onNativePadDown,
  Java_org_libsdl_app_SDLControllerManager_onNativePadUp,
  Java_org_libsdl_app_SDLControllerManager_onNativeJoy,
  Java_org_libsdl_app_SDLControllerManager_onNativeHat,
  Java_org_libsdl_app_SDLInputConnection_nativeCommitText,
  Java_org_libsdl_app_SDLInputConnection_nativeGenerateScancodeForUnichar;

procedure TSdlAppGlue.EnableSensor(const AType: Integer;
  const AEnable: Boolean);
begin
  if (AEnable) then
  begin
    ASensorEventQueue_enableSensor(FSensorEventQueue, FSensor);
    ASensorEventQueue_setEventRate(FSensorEventQueue, FSensor, 1000);
  end
  else
    ASensorEventQueue_disableSensor(FSensorEventQueue, FSensor);
end;

procedure TSdlAppGlue.HandleAppCommand(const AApp: TAndroidApplicationGlue;
  const ACommand: TAndroidApplicationCommand);
begin
//  Log('TSdlAppGlue.HandleAppCommand(%s)', [GetEnumName(TypeInfo(TAndroidApplicationCommand), Ord(ACommand))]);
  case ACommand of
    TAndroidApplicationCommand.Start:
      { TODO : Implement? };

    TAndroidApplicationCommand.Stop:
      { TODO : Implement? };

    TAndroidApplicationCommand.Pause:
      begin
        FNextNativeState := TNativeState.Paused;
        FIsResumedCalled := False;
        HandleNativeState;
      end;

    TAndroidApplicationCommand.Resume:
      begin
        FNextNativeState := TNativeState.Resumed;
        FIsResumedCalled := True;
        HandleNativeState;
      end;

    TAndroidApplicationCommand.InitWindow:
      begin
        SurfaceChanged;
        EnableSensor(ASENSOR_TYPE_ACCELEROMETER, True);
        if (not FInitialized) then
        begin
          FInitialized := True;
          Assert(Assigned(FMainProc));
          FSdlThread := TThread.CreateAnonymousThread(FMainProc);
          FSdlThread.Start;
        end;
      end;

    TAndroidApplicationCommand.TermWindow:
      SurfaceDestroyed;

    TAndroidApplicationCommand.WindowResized:
      { TODO : Implement? };

    TAndroidApplicationCommand.WindowRedrawNeeded:
      { TODO : Implement? };

    TAndroidApplicationCommand.GainedFocus:
      begin
        FHasFocus := True;
        FNextNativeState := TNativeState.Resumed;
        { TODO : Handle motion listener }
        HandleNativeState;
        Java_org_libsdl_app_SDLActivity_nativeFocusChanged(TJNIResolver.GetJNIEnv, nil, 1);
      end;

    TAndroidApplicationCommand.LostFocus:
      begin
        FHasFocus := False;
        Java_org_libsdl_app_SDLActivity_nativeFocusChanged(TJNIResolver.GetJNIEnv, nil, 0);
        FNextNativeState := TNativeState.Paused;
        HandleNativeState;
      end;

    TAndroidApplicationCommand.ConfigChanged:
      FRotation := FDisplay.getRotation;

    TAndroidApplicationCommand.LowMemory:
      Java_org_libsdl_app_SDLActivity_nativeLowMemory(TJNIResolver.GetJNIEnv, nil);

    TAndroidApplicationCommand.Destroy:
      begin
        FNextNativeState := TNativeState.Paused;
        HandleNativeState;
        Java_org_libsdl_app_SDLActivity_nativeQuit(TJNIResolver.GetJNIEnv, nil);
        if (FSdlThread <> nil) then
        begin
          FSdlThread.Terminate;
          FSdlThread.WaitFor;
          FSdlThread.Free;
          FSdlThread := nil;
        end;
      end;
  end;
end;

procedure TSdlAppGlue.HandleContentRect(const AApp: TAndroidApplicationGlue;
  const ARect: TRect);
begin
//  Log('TSdlAppGlue.HandleContentRect');
  if (GAppGlue <> nil) then
  begin
    GAppGlue.SurfaceChanged;
    GAppGlue.FRotation := GAppGlue.FDisplay.getRotation;
  end;
end;

function TSdlAppGlue.HandleInput(const AApp: TAndroidApplicationGlue;
  const AEvent: PAInputEvent): Int32;
begin
//  Log('TSdlAppGlue.HandleInput');
  Result := 0;
  var EventType := AInputEvent_getType(AEvent);
  case EventType of
    AINPUT_EVENT_TYPE_KEY:
      Result := HandleKeyEvent(AEvent);

    AINPUT_EVENT_TYPE_MOTION:
      Result := HandleMotionEvent(AEvent);
  end;
end;

function TSdlAppGlue.HandleKeyEvent(const AEvent: PAInputEvent): Int32;
begin
  Result := 0;
  var DeviceId := AInputEvent_getDeviceId(AEvent);
  var Source := AInputEvent_getSource(AEvent);
  var Action := AKeyEvent_getAction(AEvent);
  var KeyCode := AKeyEvent_getKeyCode(AEvent);
  var Meta := AKeyEvent_getMetaState(AEvent);

  if (TJSDLControllerManager.JavaClass.isDeviceSDLJoystick(DeviceId)) then
  begin
    if (Action = AKEY_EVENT_ACTION_DOWN) then
    begin
      if (Android_OnPadDown(DeviceId, KeyCode) = 0) then
        Exit(1);
    end
    else if (Action = AKEY_EVENT_ACTION_UP) then
    begin
      if (Android_OnPadUp(DeviceId, KeyCode) = 0) then
        Exit(1);
    end
  end;

  if ((Source and AINPUT_SOURCE_MOUSE) = AINPUT_SOURCE_MOUSE) then
  begin
    { TODO : Check VR headset }
    if (KeyCode = AKEYCODE_BACK) or (KeyCode = AKEYCODE_FORWARD) then
    begin
      if (Action = AKEY_EVENT_ACTION_DOWN) or (Action = AKEY_EVENT_ACTION_UP) then
        Exit(1);
    end;
  end;

  if (Action = AKEY_EVENT_ACTION_DOWN) then
  begin
    if (IsTextInputEvent(KeyCode, Meta)) then
    begin
      var Text: array [0..1] of UTF8Char;
      Text[0] := KEY_CHARS[KeyCode];
      Text[1] := #0;
      if ((Meta and AMETA_SHIFT_ON) <> 0) then
      begin
        var C := Char(Text[0]);
        C := C.ToUpper;
        Text[0] := UTF8Char(C);
      end;
      SDL_SendKeyboardText(@Text);
    end;
    Android_OnKeyDown(KeyCode);
    Exit(1);
  end
  else if (Action = AKEY_EVENT_ACTION_UP) then
  begin
    Android_OnKeyUp(KeyCode);
    Exit(1);
  end;
end;

function TSdlAppGlue.HandleMotionEvent(const AEvent: PAInputEvent): Int32;
begin
  var DeviceId := AInputEvent_getDeviceId(AEvent);
  var Source := AInputEvent_getSource(AEvent);
  var PointerCount := Integer(AMotionEvent_getPointerCount(AEvent));
  var ActionBits := AMotionEvent_getAction(AEvent);
  var Action := ActionBits and AMOTION_EVENT_ACTION_MASK;
  var Window := AndroidWindow;
  var I := 0;

  if (Action = AMOTION_EVENT_ACTION_POINTER_UP)
    or (Action = AMOTION_EVENT_ACTION_POINTER_DOWN)
  then
    I := ActionBits and AMOTION_EVENT_ACTION_PointerIndex_MASK;

  repeat
    var X, Y, P: Single;
    var PointerId, ButtonState: Integer;
    var ToolType := AMotionEvent_getToolType(AEvent, I);

    if (ToolType = AMOTION_EVENT_TOOL_TYPE_MOUSE)then
    begin
      ButtonState := AMotionEvent_getButtonState(AEvent);
      X := AMotionEvent_getX(AEvent, I);
      Y := AMotionEvent_getY(AEvent, I);
      var Relative := ((Source and AINPUT_SOURCE_MOUSE_RELATIVE) = AINPUT_SOURCE_MOUSE_RELATIVE);
      Android_OnMouse(Window, ButtonState, Action, X, Y, Relative);
    end
    else if (ToolType = AMOTION_EVENT_TOOL_TYPE_STYLUS)
      or (ToolType = AMOTION_EVENT_TOOL_TYPE_ERASER) then
    begin
      PointerId := AMotionEvent_getPointerId(AEvent, I);
      X := AMotionEvent_getX(AEvent, I);
      Y := AMotionEvent_getY(AEvent, I);
      P := AMotionEvent_getPressure(AEvent, I);
      if (P > 1.0) then
        P := 1.0;

      ButtonState := (AMotionEvent_getButtonState(AEvent) shr 4);
      if (ToolType = AMOTION_EVENT_TOOL_TYPE_STYLUS) then
        ButtonState := ButtonState or 1
      else
        ButtonState := ButtonState or (1 shl 30);

      Android_OnPen(Window, PointerId, ButtonState, Action, X, Y, P);
    end
    else if (ToolType = AMOTION_EVENT_TOOL_TYPE_FINGER) then
    begin
      PointerId := AMotionEvent_getPointerId(AEvent, I);
      X := AMotionEvent_getX(AEvent, I); // Java version uses getNormalizedX
      Y := AMotionEvent_getY(AEvent, I);
      P := AMotionEvent_getPressure(AEvent, I);
      if (P > 1.0) then
        P := 1.0;

      Android_OnTouch(Window, DeviceId, PointerId, Action, X, Y, P);
    end;

    if (Action = AMOTION_EVENT_ACTION_POINTER_UP)
      or (Action = AMOTION_EVENT_ACTION_POINTER_DOWN)
    then
      Break;

    Inc(I);
  until (I >= PointerCount);

  Result := 1;
end;

procedure TSdlAppGlue.HandleNativeState;
begin
  if (FNextNativeState = FCurrentNativeState) then
    Exit;

//  Log('TSdlAppGlue.HandleNativeState(Cur=%d, Next=%d)', [Ord(FCurrentNativeState), Ord(FNextNativeState)]);
  if (FNextNativeState = TNativeState.Init) then
  begin
    FCurrentNativeState := FNextNativeState;
    Exit;
  end;

  if (FNextNativeState = TNativeState.Paused) then
  begin
    if (FSdlThread <> nil) then
      Java_org_libsdl_app_SDLActivity_nativePause(TJNIResolver.GetJNIEnv, nil);
    EnableSensor(ASENSOR_TYPE_ACCELEROMETER, False);
    FCurrentNativeState := FNextNativeState;
    Exit;
  end;

  if (FNextNativeState = TNativeState.Resumed) and (FIsSurfaceReady)
    and (FHasFocus) and (FIsResumedCalled) then
  begin
    if (FSdlThread <> nil) then
      Java_org_libsdl_app_SDLActivity_nativeResume(TJNIResolver.GetJNIEnv, nil);
    EnableSensor(ASENSOR_TYPE_ACCELEROMETER, True);
    FCurrentNativeState := FNextNativeState;
  end;
end;

procedure TSdlAppGlue.HandleSensorEvents;
begin
  var SensorEvent, LastSensorEvent: ASensorEvent;
  LastSensorEvent.__type := MaxInt;
  while (ASensorEventQueue_getEvents(FSensorEventQueue, @SensorEvent, 1) > 0) do
    LastSensorEvent := SensorEvent;

  if (LastSensorEvent.__type = ASENSOR_TYPE_ACCELEROMETER) then
  begin
    var X: Single := LastSensorEvent.acceleration.x / ASENSOR_STANDARD_GRAVITY;
    var Y: Single := LastSensorEvent.acceleration.y / ASENSOR_STANDARD_GRAVITY;
    var Z: Single := LastSensorEvent.acceleration.z / ASENSOR_STANDARD_GRAVITY;
    var Temp: Single;

    case FRotation of
      1: begin // 90 degrees
           Temp := X;
           X := -Y;
           Y := Temp;
         end;
      2: begin // 180 degrees
           X := -X;
           Y := -Y;
         end;
      3: begin // 270 degrees
           Temp := X;
           X := Y;
           Y := -Temp;
         end;
    end;

    Java_org_libsdl_app_SDLActivity_onNativeAccel(TJNIResolver.GetJNIEnv, nil, X, Y, Z);
  end;
end;

class function TSdlAppGlue.IsTextInputEvent(const AKeyCode,
  AMeta: Integer): Boolean;
begin
  if ((AMeta and AMETA_CTRL_ON) <> 0)then
    Exit(False);

  if (AKeyCode >= 0) and (AKeyCode < Length(KEY_CHARS)) then
    Result := (KEY_CHARS[AKeyCode] <> #0)
  else
    Result := False;
end;

class function TSdlAppGlue.SensorLooperCallback(AFileDescriptor,
  AEvents: Integer; AData: Pointer): Integer;
begin
  if (GAppGlue <> nil) then
    GAppGlue.HandleSensorEvents;

  Result := 1;
end;

procedure TSdlAppGlue.SurfaceChanged;
begin
  var Window := TAndroidApplicationGlue.Current.Window;
  if (Window = nil) or (FDisplay = nil) then
  begin
//    Log('TSdlAppGlue.SurfaceChanged(nil)');
    Exit;
  end;

  FWidth := ANativeWindow_getWidth(Window);
  FHeight := ANativeWindow_getHeight(Window);
//  Log('TSdlAppGlue.SurfaceChanged(%d x %d)', [FWidth, FHeight]);

  var RealMetrics := TJDisplayMetrics.Create;
  FDisplay.getRealMetrics(RealMetrics);
  var DeviceWidth := RealMetrics.widthPixels;
  var DeviceHeight := RealMetrics.heightPixels;
  var Density: Single := RealMetrics.densityDpi / 160;

//  Log('DeviceWidth=%d, DeviceHeight=%d, Density=%.1f, Refresh=%.1f', [DeviceWidth, DeviceHeight,
//    Density, FDisplay.getRefreshRate]);
  Android_SetScreenResolution(FWidth, FHeight, DeviceWidth, DeviceHeight,
    Density, FDisplay.getRefreshRate);
  Java_org_libsdl_app_SDLActivity_onNativeResize(TJNIResolver.GetJNIEnv, nil);

  var Skip := False;
  var RequestedOrientation := TAndroidHelper.Activity.getRequestedOrientation;
  if (RequestedOrientation = TJActivityInfo.JavaClass.SCREEN_ORIENTATION_PORTRAIT)
    or (RequestedOrientation = TJActivityInfo.JavaClass.SCREEN_ORIENTATION_SENSOR_PORTRAIT) then
  begin
    if (FWidth > FHeight) then
      Skip := True;
  end
  else if (RequestedOrientation = TJActivityInfo.JavaClass.SCREEN_ORIENTATION_LANDSCAPE)
    or (RequestedOrientation = TJActivityInfo.JavaClass.SCREEN_ORIENTATION_SENSOR_LANDSCAPE) then
  begin
    if (FWidth < FHeight) then
      Skip := True;
  end;

  if (Skip) then
  begin
    var Mn := Min(FWidth, FHeight);
    var Mx := Max(FWidth, FHeight);
    if ((Mx / Mn) < 1.2) then
      Skip := False;
  end;

  if (Skip) then
  begin
    FIsSurfaceReady := False;
    Exit;
//    Log('FIsSurfaceReady=False');
  end;

//  Log('FIsSurfaceReady=True');
  Java_org_libsdl_app_SDLActivity_onNativeSurfaceChanged(TJNIResolver.GetJNIEnv, nil);
  FIsSurfaceReady := True;
  FNextNativeState := TNativeState.Resumed;
  HandleNativeState;
end;

procedure TSdlAppGlue.SurfaceDestroyed;
begin
  FNextNativeState := TNativeState.Paused;
  HandleNativeState;

  FIsSurfaceReady := False;
  Java_org_libsdl_app_SDLActivity_onNativeSurfaceDestroyed(TJNIResolver.GetJNIEnv, nil);
end;

initialization

finalization
  GAppGlue.Free;

end.
