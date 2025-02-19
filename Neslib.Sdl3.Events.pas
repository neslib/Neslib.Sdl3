unit Neslib.Sdl3.Events;

{ Simple DirectMedia Layer
  Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org>

  Neslib.Sdl3
  Copyright (C) 2025 Erik van Bilsen

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution. }

{$Include 'Neslib.Sdl3.inc'}

interface

uses
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Input,
  Neslib.Sdl3.Additional,
  Neslib.Sdl3.Audio,
  Neslib.Sdl3.Video;

{$REGION 'Events'}
type
  /// <summary>
  ///  The types of events that can be delivered.
  /// </summary>
  TSdlEventKind = (
    /// <summary>Unused (do not remove)</summary>
    First                          = SDL_EVENT_FIRST,

    /// <summary>User-requested quit</summary>
    Quit                           = SDL_EVENT_QUIT,

    /// <summary>The application is being terminated by the OS. This event must
    ///  be handled in a callback set with TSdlEvents.AddWatch. Called on iOS in
    //   applicationWillTerminate(). Called on Android in onDestroy()
    /// </summary>
    Terminating                    = SDL_EVENT_TERMINATING,

    /// <summary>The application is low on memory, free memory if possible.
    ///  This event must be handled in a callback set with TSdlEvents.AddWatch.
    ///  Called on iOS in applicationDidReceiveMemoryWarning().
    ///  Called on Android in onTrimMemory().
    /// </summary>
    LowMemory                      = SDL_EVENT_LOW_MEMORY,

    /// <summary>The application is about to enter the background. This event
    ///  must be handled in a callback set with TSdlEvents.AddWatch.
    ///  Called on iOS in applicationWillResignActive().
    ///  Called on Android in onPause().
    /// </summary>
    WillEnterBackground            = SDL_EVENT_WILL_ENTER_BACKGROUND,

    /// <summary>The application did enter the background and may not get CPU
    ///  for some time. This event must be handled in a callback set with
    ///  TSdlEvents.AddWatch. Called on iOS in applicationDidEnterBackground().
    ///  Called on Android in onPause().
    /// </summary>
    DidEnterBackground             = SDL_EVENT_DID_ENTER_BACKGROUND,

    /// <summary>The application is about to enter the foreground. This event
    ///  must be handled in a callback set with TSdlEvents.AddWatch.
    ///  Called on iOS in applicationWillEnterForeground().
    ///  Called on Android in onResume().
    /// </summary>
    WillEnterForeground            = SDL_EVENT_WILL_ENTER_FOREGROUND,

    /// <summary>The application is now interactive. This event must be handled
    ///  in a callback set with TSdlEvents.AddWatch.
    ///  Called on iOS in applicationDidBecomeActive().
    ///  Called on Android in onResume().
    /// </summary>
    DidEnterForeground             = SDL_EVENT_DID_ENTER_FOREGROUND,

    /// <summary>The user's locale preferences have changed.</summary>
    LocaleChanged                  = SDL_EVENT_LOCALE_CHANGED,

    /// <summary>The system theme changed</summary>
    SystemThemeChanged             = SDL_EVENT_SYSTEM_THEME_CHANGED,

    /// <summary>Display orientation has changed to Data1</summary>
    DisplayOrientation             = SDL_EVENT_DISPLAY_ORIENTATION,

    /// <summary>Display has been added to the system</summary>
    DisplayAdded                   = SDL_EVENT_DISPLAY_ADDED,

    /// <summary>Display has been removed from the system</summary>
    DisplayRemoved                 = SDL_EVENT_DISPLAY_REMOVED,

    /// <summary>Display has changed position</summary>
    DisplayMoved                   = SDL_EVENT_DISPLAY_MOVED,

    /// <summary>Display has changed desktop mode</summary>
    DisplayDesktopModeChanged      = SDL_EVENT_DISPLAY_DESKTOP_MODE_CHANGED,

    /// <summary>Display has changed current mode</summary>
    DisplayCurrentModeChanged      = SDL_EVENT_DISPLAY_CURRENT_MODE_CHANGED,

    /// <summary>Display has changed content scale</summary>
    DisplayContentScaleChanged     = SDL_EVENT_DISPLAY_CONTENT_SCALE_CHANGED,

    DisplayFirst                   = SDL_EVENT_DISPLAY_FIRST,
    DisplayLast                    = SDL_EVENT_DISPLAY_LAST,

    /// <summary>Window has been shown</summary>
    WindowShown                    = SDL_EVENT_WINDOW_SHOWN,

    /// <summary>Window has been hidden</summary>
    WindowHidden                   = SDL_EVENT_WINDOW_HIDDEN,

    /// <summary>Window has been exposed and should be redrawn, and can be
    ///  redrawn directly from event watchers for this event</summary>
    WindowExposed                  = SDL_EVENT_WINDOW_EXPOSED,

    /// <summary>Window has been moved to Data1, Data2</summary>
    WindowMoved                    = SDL_EVENT_WINDOW_MOVED,

    /// <summary>Window has been resized to Data1 x Data2</summary>
    WindowResized                  = SDL_EVENT_WINDOW_RESIZED,

    /// <summary>The pixel size of the window has changed to Data1 x Data2</summary>
    WindowPixelSizeChanged         = SDL_EVENT_WINDOW_PIXEL_SIZE_CHANGED,

    /// <summary>The pixel size of a Metal view associated with the window has changed</summary>
    WindowMetalViewResized         = SDL_EVENT_WINDOW_METAL_VIEW_RESIZED,

    /// <summary>Window has been minimized</summary>
    WindowMinimized                = SDL_EVENT_WINDOW_MINIMIZED,

    /// <summary>Window has been maximized</summary>
    WindowMaximized                = SDL_EVENT_WINDOW_MAXIMIZED,

    /// <summary>Window has been restored to normal size and position</summary>
    WindowRestored                 = SDL_EVENT_WINDOW_RESTORED,

    /// <summary>Window has gained mouse focus</summary>
    WindowMouseEnter               = SDL_EVENT_WINDOW_MOUSE_ENTER,

    /// <summary>Window has lost mouse focus</summary>
    WindowMouseLeave               = SDL_EVENT_WINDOW_MOUSE_LEAVE,

    /// <summary>Window has gained keyboard focus</summary>
    WindowFocusGained              = SDL_EVENT_WINDOW_FOCUS_GAINED,

    /// <summary>Window has lost keyboard focus</summary>
    WindowFocusLost                = SDL_EVENT_WINDOW_FOCUS_LOST,

    /// <summary>The window manager requests that the window be closed</summary>
    WindowCloseRequested           = SDL_EVENT_WINDOW_CLOSE_REQUESTED,

    /// <summary>Window had a hit test that wasn't TSdlHitTestResult.Normal</summary>
    WindowHitTest                  = SDL_EVENT_WINDOW_HIT_TEST,

    /// <summary>The ICC profile of the window's display has changed</summary>
    WindowIccProfChanged           = SDL_EVENT_WINDOW_ICCPROF_CHANGED,

    /// <summary>Window has been moved to display data1</summary>
    WindowDisplayChanged           = SDL_EVENT_WINDOW_DISPLAY_CHANGED,

    /// <summary>Window display scale has been changed</summary>
    WindowDisplayScaleChanged      = SDL_EVENT_WINDOW_DISPLAY_SCALE_CHANGED,

    /// <summary>The window safe area has been changed</summary>
    WindowSafeAreaChanged          = SDL_EVENT_WINDOW_SAFE_AREA_CHANGED,

    /// <summary>The window has been occluded</summary>
    WindowOccluded                 = SDL_EVENT_WINDOW_OCCLUDED,

    /// <summary>The window has entered fullscreen mode</summary>
    WindowEnterFullscreen          = SDL_EVENT_WINDOW_ENTER_FULLSCREEN,

    /// <summary>The window has left fullscreen mode</summary>
    WindowLeaveFullscreen          = SDL_EVENT_WINDOW_LEAVE_FULLSCREEN,

    /// <summary>The window with the associated ID is being or has been destroyed.
    ///  If this message is being handled in an event watcher, the window handle
    ///  is still valid and can still be used to retrieve any properties
    ///  associated with the window. Otherwise, the handle has already been
    ///  destroyed and all resources associated with it are invalid</summary>
    WindowDestroyed                = SDL_EVENT_WINDOW_DESTROYED,

    /// <summary>Window HDR properties have changed</summary>
    WindowHdrStateChanged          = SDL_EVENT_WINDOW_HDR_STATE_CHANGED,

    WindowFirst                    = SDL_EVENT_WINDOW_FIRST,
    WindowLast                     = SDL_EVENT_WINDOW_LAST,

    /// <summary>Key pressed</summary>
    KeyDown                        = SDL_EVENT_KEY_DOWN,

    /// <summary>Key released</summary>
    KeyUp                          = SDL_EVENT_KEY_UP,

    /// <summary>Keyboard text editing (composition)</summary>
    TextEditing                    = SDL_EVENT_TEXT_EDITING,

    /// <summary>Keyboard text input</summary>
    TextInput                      = SDL_EVENT_TEXT_INPUT,

    /// <summary>Keymap changed due to a system event such as an
    ///  input language or keyboard layout change.</summary>
    KeymapChanged                  = SDL_EVENT_KEYMAP_CHANGED,

    /// <summary>A new keyboard has been inserted into the system</summary>
    KeyboardAdded                  = SDL_EVENT_KEYBOARD_ADDED,

    /// <summary>A keyboard has been removed</summary>
    KeyboardRemoved                = SDL_EVENT_KEYBOARD_REMOVED,

    /// <summary>Keyboard text editing candidates</summary>
    TextEditingCandidates          = SDL_EVENT_TEXT_EDITING_CANDIDATES,

    /// <summary>Mouse moved</summary>
    MouseMotion                    = SDL_EVENT_MOUSE_MOTION,

    /// <summary>Mouse button pressed</summary>
    MouseButtonDown                = SDL_EVENT_MOUSE_BUTTON_DOWN,

    /// <summary>Mouse button released</summary>
    MouseButtonUp                  = SDL_EVENT_MOUSE_BUTTON_UP,

    /// <summary>Mouse wheel motion</summary>
    MouseWheel                     = SDL_EVENT_MOUSE_WHEEL,

    /// <summary>A new mouse has been inserted into the system</summary>
    MouseAdded                     = SDL_EVENT_MOUSE_ADDED,

    /// <summary>A mouse has been removed</summary>
    MouseRemoved                   = SDL_EVENT_MOUSE_REMOVED,

    /// <summary>Joystick axis motion</summary>
    JoystickAxisMotion             = SDL_EVENT_JOYSTICK_AXIS_MOTION,

    /// <summary>Joystick trackball motion</summary>
    JoystickBallMotion             = SDL_EVENT_JOYSTICK_BALL_MOTION,

    /// <summary>Joystick hat position change</summary>
    JoystickHatMotion              = SDL_EVENT_JOYSTICK_HAT_MOTION,

    /// <summary>Joystick button pressed</summary>
    JoystickButtonDown             = SDL_EVENT_JOYSTICK_BUTTON_DOWN,

    /// <summary>Joystick button released</summary>
    JoystickButtonUp               = SDL_EVENT_JOYSTICK_BUTTON_UP,

    /// <summary>A new joystick has been inserted into the system</summary>
    JoystickAdded                  = SDL_EVENT_JOYSTICK_ADDED,

    /// <summary>An opened joystick has been removed</summary>
    JoystickRemoved                = SDL_EVENT_JOYSTICK_REMOVED,

    /// <summary>Joystick battery level change</summary>
    JoystickBatteryUpdated         = SDL_EVENT_JOYSTICK_BATTERY_UPDATED,

    /// <summary>Joystick update is complete</summary>
    JoystickUpdateComplete         = SDL_EVENT_JOYSTICK_UPDATE_COMPLETE,

    /// <summary>Gamepad axis motion</summary>
    GamepadAxisMotion              = SDL_EVENT_GAMEPAD_AXIS_MOTION,

    /// <summary>Gamepad button pressed</summary>
    GamepadButtonDown              = SDL_EVENT_GAMEPAD_BUTTON_DOWN,

    /// <summary>Gamepad button released</summary>
    GamepadButtonUp                = SDL_EVENT_GAMEPAD_BUTTON_UP,

    /// <summary>A new gamepad has been inserted into the system</summary>
    GamepadAdded                   = SDL_EVENT_GAMEPAD_ADDED,

    /// <summary>A gamepad has been removed</summary>
    GamepadRemoved                 = SDL_EVENT_GAMEPAD_REMOVED,

    /// <summary>The gamepad mapping was updated</summary>
    GamepadRemapped                = SDL_EVENT_GAMEPAD_REMAPPED,

    /// <summary>Gamepad touchpad was touched</summary>
    GamepadTouchpadDown            = SDL_EVENT_GAMEPAD_TOUCHPAD_DOWN,

    /// <summary>Gamepad touchpad finger was moved</summary>
    GamepadTouchpadMotion          = SDL_EVENT_GAMEPAD_TOUCHPAD_MOTION,

    /// <summary>Gamepad touchpad finger was lifted</summary>
    GamepadTouchpadUp              = SDL_EVENT_GAMEPAD_TOUCHPAD_UP,

    /// <summary>Gamepad sensor was updated</summary>
    GamepadSensorUpdate            = SDL_EVENT_GAMEPAD_SENSOR_UPDATE,

    /// <summary>Gamepad update is complete</summary>
    GamepadUpdateComplete          = SDL_EVENT_GAMEPAD_UPDATE_COMPLETE,

    /// <summary>Gamepad Steam handle has changed</summary>
    GamepadSteamHandleUpdated      = SDL_EVENT_GAMEPAD_STEAM_HANDLE_UPDATED,

    FingerDown                     = SDL_EVENT_FINGER_DOWN,
    Finger                         = SDL_EVENT_FINGER_UP,
    FingerMotion                   = SDL_EVENT_FINGER_MOTION,
    FingerCanceled                 = SDL_EVENT_FINGER_CANCELED,

    /// <summary>The clipboard or primary selection changed</summary>
    ClipboardUpdate                = SDL_EVENT_CLIPBOARD_UPDATE,

    /// <summary>The system requests a file open</summary>
    DropFile                       = SDL_EVENT_DROP_FILE,

    /// <summary>text/plain drag-and-drop event</summary>
    DropText                       = SDL_EVENT_DROP_TEXT,

    /// <summary>A new set of drops is beginning (NULL filename)</summary>
    DropBegin                      = SDL_EVENT_DROP_BEGIN,

    /// <summary>Current set of drops is now complete (NULL filename)</summary>
    DropComplete                   = SDL_EVENT_DROP_COMPLETE,

    /// <summary>Position while moving over the window</summary>
    DropPosition                   = SDL_EVENT_DROP_POSITION,

    /// <summary>A new audio device is available</summary>
    AudioDeviceAdded               = SDL_EVENT_AUDIO_DEVICE_ADDED,

    /// <summary>An audio device has been removed.</summary>
    AudioDeviceRemoved             = SDL_EVENT_AUDIO_DEVICE_REMOVED,

    /// <summary>An audio device's format has been changed by the system.</summary>
    AudioDeviceFormatChanged       = SDL_EVENT_AUDIO_DEVICE_FORMAT_CHANGED,

    /// <summary>A sensor was updated</summary>
    SensorUpdate                   = SDL_EVENT_SENSOR_UPDATE,

    /// <summary>Pressure-sensitive pen has become available</summary>
    PenProximityIn                 = SDL_EVENT_PEN_PROXIMITY_IN,

    /// <summary>Pressure-sensitive pen has become unavailable</summary>
    PenProximityOut                = SDL_EVENT_PEN_PROXIMITY_OUT,

    /// <summary>Pressure-sensitive pen touched drawing surface</summary>
    PenDown                        = SDL_EVENT_PEN_DOWN,

    /// <summary>Pressure-sensitive pen stopped touching drawing surface</summary>
    PenUp                          = SDL_EVENT_PEN_UP,

    /// <summary>Pressure-sensitive pen button pressed</summary>
    PenButtonDown                  = SDL_EVENT_PEN_BUTTON_DOWN,

    /// <summary>Pressure-sensitive pen button released</summary>
    PenButtonUp                    = SDL_EVENT_PEN_BUTTON_UP,

    /// <summary>Pressure-sensitive pen is moving on the tablet</summary>
    PenMotion                      = SDL_EVENT_PEN_MOTION,

    /// <summary>Pressure-sensitive pen angle/pressure/etc changed</summary>
    PenAxis                        = SDL_EVENT_PEN_AXIS,

    /// <summary>A new camera device is available</summary>
    CameraDeviceAdded              = SDL_EVENT_CAMERA_DEVICE_ADDED,

    /// <summary>A camera device has been removed.</summary>
    CameraDeviceRemoved            = SDL_EVENT_CAMERA_DEVICE_REMOVED,

    /// <summary>A camera device has been approved for use by the user.</summary>
    CameraDeviceApproved           = SDL_EVENT_CAMERA_DEVICE_APPROVED,

    /// <summary>A camera device has been denied for use by the user.</summary>
    CameraDeviceDenied             = SDL_EVENT_CAMERA_DEVICE_DENIED,

    /// <summary>The render targets have been reset and their contents need to be updated</summary>
    RenderTargetsResert            = SDL_EVENT_RENDER_TARGETS_RESET,

    /// <summary>The device has been reset and all textures need to be recreated</summary>
    RenderDeviceReset              = SDL_EVENT_RENDER_DEVICE_RESET,

    /// <summary>The device has been lost and can't be recovered.</summary>
    RenderDeviceLost               = SDL_EVENT_RENDER_DEVICE_LOST,

    /// <summary>Signals the end of an event poll cycle</summary>
    PollSentinel                   = SDL_EVENT_POLL_SENTINEL,

    /// <summary>
    ///  This last event is only for bounding internal arrays
    /// </summary>
    Last                           = SDL_EVENT_LAST);

type
  /// <summary>
  ///  Fields shared by every event.
  /// </summary>
  TSdlCommonEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_CommonEvent;
    function GetKind: TSdlEventKind; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind, shared with all events</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;
  end;

type
  /// <summary>
  ///  Display state change event data (Event.Display.* )
  /// </summary>
  TSdlDisplayEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_DisplayEvent;
    function GetKind: TSdlEventKind; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Display*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The associated display</summary>
    property DisplayID: TSdlDisplayID read FHandle.displayID;

    /// <summary>Event dependent data</summary>
    property Data1: Integer read FHandle.data1;

    /// <summary>Event dependent data</summary>
    property Data2: Integer read FHandle.data2;
  end;

type
  /// <summary>
  ///  Window state change event data (Event.Window.* )
  /// </summary>
  TSdlWindowEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_WindowEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Window*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID associated window</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The associated window</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>Event dependent data</summary>
    property Data1: Integer read FHandle.data1;

    /// <summary>Event dependent data</summary>
    property Data2: Integer read FHandle.data2;
  end;

type
  /// <summary>
  ///  Keyboard device event structure (Event.KeyboardDevice.* )
  /// </summary>
  TSdlKeyboardDeviceEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_KeyboardDeviceEvent;
    function GetKind: TSdlEventKind; inline;
    function GetKeyboard: TSdlKeyboard; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.KeyboardAdded/Removed)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The keyboard instance</summary>
    property Keyboard: TSdlKeyboard read GetKeyboard;
  end;

type
  /// <summary>
  ///  Keyboard button event structure (Event.Key.* )
  ///
  ///  The `Key` is the base TSdlKeycode generated by pressing the `Scancode`
  ///  using the current keyboard layout, applying any options specified in
  ///  TSdlHints.KeycodeOptions. You can get the TSdlKeycode corresponding to the
  ///  event scancode and modifiers directly from the keyboard layout, bypassing
  ///  TSdlHints.KeycodeOptions, by calling TSdlScancode.ToKeycode.
  /// </summary>
  /// <seealso cref="TSdlScancode.ToKeycode"/>
  /// <seealso cref="TSdlHints.KeycodeOptions"/>
  TSdlKeyboardEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_KeyboardEvent;
    function GetKind: TSdlEventKind; inline;
    function GetKeyboard: TSdlKeyboard; inline;
    function GetScancode: TSdlScancode; inline;
    function GetKey: TSdlKeycode; inline;
    function GetMods: TSdlKeymods; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Key*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The keyboard instance, or nil if unknown or virtual</summary>
    property Keyboard: TSdlKeyboard read GetKeyboard;

    /// <summary>SDL physical key code</summary>
    property Scancode: TSdlScancode read GetScancode;

    /// <summary>SDL virtual key code</summary>
    property Key: TSdlKeycode read GetKey;

    /// <summary>current key modifiers</summary>
    property Mods: TSdlKeymods read GetMods;

    /// <summary>The platform dependent scancode for this event</summary>
    property Raw: Word read FHandle.raw;

    /// <summary>True if the key is pressed</summary>
    property IsDown: Boolean read FHandle.down;

    /// <summary>True if this is a key repeat</summary>
    property IsRepeat: Boolean read FHandle.&repeat;
  end;

type
  /// <summary>
  ///  Keyboard text editing event structure (Event.TextEdit.* )
  ///
  ///  The start cursor is the position, in UTF-8 characters, where new typing
  ///  will be inserted into the editing text. The length is the number of UTF-8
  ///  characters that will be replaced by new typing.
  /// </summary>
  TSdlTextEditingEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TextEditingEvent;
    function GetKind: TSdlEventKind; inline;
    function GetText: String; inline;
    function GetWindow: TSdlWindow; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.TextEditing)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with keyboard focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with keyboard focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>Pointer to the editing text</summary>
    property TextPtr: PUTF8Char read FHandle.text;

    /// <summary>The editing text</summary>
    property Text: String read GetText;

    /// <summary>The start cursor of selected editing text, or -1 if not set</summary>
    property Start: Integer read FHandle.start;

    /// <summary>The length of selected editing text, or -1 if not set</summary>
    property Length: Integer read FHandle.length;
  end;

type
  /// <summary>
  ///  Keyboard IME candidates event structure (Event.TextCandidates.* )
  /// </summary>
  TSdlTextEditingCandidatesEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TextEditingCandidatesEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetCandidates: TArray<String>;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.TextEditingCandidates)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with keyboard focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with keyboard focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>Pointer to the list of candidates, or nil if there are no
    ///  candidates available</summary>
    property CandidatesPtr: PPUTF8Char read FHandle.candidates;

    /// <summary>Array of candidates, or nil if there are no candidates available</summary>
    property Candidates: TArray<String> read GetCandidates;

    /// <summary>The number of strings in `CandidatesPtr` and `Candidates`</summary>
    property NumCandidates: Integer read FHandle.num_candidates;

    /// <summary>The index of the selected candidate, or -1 if no candidate is selected</summary>
    property SelectedCandidate: Integer read FHandle.selected_candidate;

    /// <summary>True if the list is horizontal, False if it's vertical</summary>
    property IsHorizontal: Boolean read FHandle.horizontal;
  end;

type
  /// <summary>
  ///  Keyboard text input event structure (Event.TextInput.* )
  ///
  ///  This event will never be delivered unless text input is enabled by calling
  ///  TSdlKeyboard.StartTextInput. Text input is disabled by default!
  /// </summary>
  /// <seealso cref="TSdlKeyboard.StartTextInput"/>
  /// <seealso cref="TSdlKeyboard.StopTextInput"/>
  TSdlTextInputEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TextInputEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetText: String; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.TextInput)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with keyboard focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with keyboard focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>Pointer to the input text</summary>
    property TextPtr: PUTF8Char read FHandle.text;

    /// <summary>The input text</summary>
    property Text: String read GetText;
  end;

type
  /// <summary>
  ///  Mouse device event structure (Event.MouseDevice.* )
  /// </summary>
  TSdlMouseDeviceEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_MouseDeviceEvent;
    function GetKind: TSdlEventKind; inline;
    function GetMouse: TSdlMouse; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.MouseAdded/Removed)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The mouse instance</summary>
    property Mouse: TSdlMouse read GetMouse;
  end;

type
  /// <summary>
  ///  Mouse motion event structure (Event.MouseMotion.* )
  /// </summary>
  TSdlMouseMotionEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_MouseMotionEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetMouse: TSdlMouse; inline;
    function GetButtons: TSdlMouseButtons; inline;
    function GetPosition: TSdlPointF; inline;
    function GetRel: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.MouseMotion)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with mouse focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with mouse focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The mouse instance in relative mode,
    ///  TSdlMouse.Touch for touch events, or nil</summary>
    property Mouse: TSdlMouse read GetMouse;

    /// <summary>The currently pressed buttons</summary>
    property Buttons: TSdlMouseButtons read GetButtons;

    /// <summary>X coordinate, relative to window</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>The relative motion in the X direction</summary>
    property XRel: Single read FHandle.xrel;

    /// <summary>The relative motion in the Y direction</summary>
    property YRel: Single read FHandle.yrel;

    /// <summary>The relative motion</summary>
    property Rel: TSdlPointF read GetRel;
  end;

type
  /// <summary>
  ///  Mouse button event structure (Event.MouseButton.* )
  /// </summary>
  TSdlMouseButtonEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_MouseButtonEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetMouse: TSdlMouse; inline;
    function GetButton: TSdlMouseButton; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.MouseButtonUp/Down)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with mouse focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with mouse focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The mouse instance in relative mode,
    ///  TSdlMouse.Touch for touch events, or nil</summary>
    property Mouse: TSdlMouse read GetMouse;

    /// <summary>The mouse button</summary>
    property Button: TSdlMouseButton read GetButton;

    /// <summary>True if the button is pressed</summary>
    property IsDown: Boolean read FHandle.down;

    /// <summary>1 for single-click, 2 for double-click, etc.</summary>
    property Clicks: Byte read FHandle.clicks;

    /// <summary>X coordinate, relative to window</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;
  end;

type
  /// <summary>
  ///  Mouse wheel event structure (Event.MouseWheel.* )
  /// </summary>
  TSdlMouseWheelEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_MouseWheelEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetMouse: TSdlMouse; inline;
    function GetDirection: TSdlMouseWheelDirection; inline;
    function GetAmount: TSdlPointF; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.MouseWheel)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with mouse focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with mouse focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The mouse instance in relative mode or nil</summary>
    property Mouse: TSdlMouse read GetMouse;

    /// <summary>The amount scrolled horizontally, positive to the right and
    ///  negative to the left</summary>
    property X: Single read FHandle.x;

    /// <summary>The amount scrolled vertically, positive away from the user and
    ///  negative toward the user</summary>
    property Y: Single read FHandle.y;

    /// <summary>The amount scrolled.</summary>
    property Amount: TSdlPointF read GetAmount;

    /// <summary>When TSdlMouseWheelDirection.Flipped the values in X and Y will
    ///  be opposite. Multiply by -1 to change them back</summary>
    property Direction: TSdlMouseWheelDirection read GetDirection;

    /// <summary>X coordinate, relative to window</summary>
    property MouseX: Single read FHandle.mouse_x;

    /// <summary>Y coordinate, relative to window</summary>
    property MouseY: Single read FHandle.mouse_y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;
  end;

type
  /// <summary>
  ///  Joystick device event structure (Event.JoyDevice.* )
  ///
  ///  SDL will send TSdlEventKind.JoystickAdded events for devices that are
  ///  already plugged in during SdlInit.
  /// </summary>
  /// <seealso cref="TSdlGamepadDeviceEvent"/>
  TSdlJoyDeviceEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoyDeviceEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.JoystickAdded/Removed/UpdateComplete)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;
  end;

type
  /// <summary>
  ///  Joystick axis motion event structure (Event.JoyAxis.* )
  /// </summary>
  TSdlJoyAxisEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoyAxisEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.JoystickAxisMotion)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The joystick axis index</summary>
    property Axis: Byte read FHandle.axis;

    /// <summary>The axis value (range: -32768 to 32767)</summary>
    property Value: Smallint read FHandle.value;
  end;

type
  /// <summary>
  ///  Joystick trackball motion event structure (Event.JoyBball.* )
  /// </summary>
  TSdlJoyBallEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoyBallEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetRel: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.JoystickBallMotion)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The joystick trackball index</summary>
    property Ball: Byte read FHandle.ball;

    /// <summary>The relative motion in the X direction</summary>
    property XRel: Smallint read FHandle.xrel;

    /// <summary>The relative motion in the Y direction</summary>
    property YRel: Smallint read FHandle.yrel;

    /// <summary>The relative motion</summary>
    property Rel: TSdlPointF read GetRel;
  end;

type
  /// <summary>
  ///  Joystick hat position change event structure (Event.JoyHat.* )
  /// </summary>
  TSdlJoyHatEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoyHatEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetValue: TSdlHat; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.JoystickHatMotion)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The joystick hat index</summary>
    property Hat: Byte read FHandle.hat;

    /// <summary>The hat position value.
    /// Note that zero means the POV is centered.
    /// </summary>
    property Value: TSdlHat read GetValue;
  end;

type
  /// <summary>
  ///  Joystick button event structure (Event.JoyButton.* )
  /// </summary>
  TSdlJoyButtonEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoyButtonEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.JoystickButtonUp/Down)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The joystick button index</summary>
    property Button: Byte read FHandle.button;

    /// <summary>True if the button is pressed</summary>
    property IsDown: Boolean read FHandle.down;
  end;

type
  /// <summary>
  ///  Joystick battery level change event structure (Event.JoyBattery.* )
  /// </summary>
  TSdlJoyBatteryEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoyBatteryEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetState: TSdlPowerState; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.JoystickBatteryUpdated)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The joystick battery state</summary>
    property State: TSdlPowerState read GetState;

    /// <summary>The joystick battery percent charge remaining</summary>
    property Percent: Integer read FHandle.percent;
  end;

type
  /// <summary>
  ///  Gamepad device event structure (Event.GamepadDevice.* )
  ///
  ///  Joysticks that are supported gamepads receive both an TSdlJoyDeviceEvent
  ///  and an TSdlGamepadDeviceEvent.
  ///
  ///  SDL will send TSdlEventKind.GamepadAdded events for joysticks that are
  ///  already plugged in during SdlInit and are recognized as gamepads.
  ///  It will also send events for joysticks that get gamepad mappings at runtime.
  /// </summary>
  /// <seealso cref="TSdlJoyDeviceEvent"/>
  TSdlGamepadDeviceEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GamepadDeviceEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.GamepadAdded/Removed/Remapped/
    ///  UpdateComplete/SteamHandleUpdated)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;
  end;

type
  /// <summary>
  ///  Gamepad axis motion event structure (Event.GamepadAxis.* )
  /// </summary>
  TSdlGamepadAxisEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GamepadAxisEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetAxis: TSdlGamepadAxis; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.GamepadAxisMotion)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The gamepad axis</summary>
    property Axis: TSdlGamepadAxis read GetAxis;

    /// <summary>The axis value (range: -32768 to 32767)</summary>
    property Value: Smallint read FHandle.value;
  end;

type
  /// <summary>
  ///  Gamepad button event structure (Event.GamepadButton.* )
  /// </summary>
  TSdlGamepadButtonEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GamepadButtonEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetButton: TSdlGamepadButton; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.GamepadButtonUp/Down)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The gamepad button</summary>
    property Button: TSdlGamepadButton read GetButton;

    /// <summary>True if the button is pressed</summary>
    property IsDown: Boolean read FHandle.down;
  end;

type
  /// <summary>
  ///  Gamepad touchpad event structure (Event.GamepadTouch.* )
  /// </summary>
  TSdlGamepadTouchpadEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GamepadTouchpadEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.GamepadTouchpad*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The index of the touchpad</summary>
    property Touchpad: Integer read FHandle.touchpad;

    /// <summary>The index of the finger on the touchpad</summary>
    property Finger: Integer read FHandle.finger;

    /// <summary>Normalized in the range 0...1 with 0 being on the left</summary>
    property X: Single read FHandle.x;

    /// <summary>Normalized in the range 0...1 with 0 being at the top</summary>
    property Y: Single read FHandle.y;

    /// <summary>Normalized in the range (0...1, 0...1) with 0 being at the
    ///  top-left</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>Normalized in the range 0...1</summary>
    property Pressure: Single read FHandle.pressure;
  end;

type
  /// <summary>
  ///  Gamepad sensor event structure (Event.GamepadSensor.* )
  /// </summary>
  TSdlGamepadSensorEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GamepadSensorEvent;
    function GetKind: TSdlEventKind; inline;
    function GetJoystickID: TSdlJoystickID; inline;
    function GetJoystick: TSdlJoystick; inline;
    function GetSensor: TSdlSensorKind; inline;
    function GetData(const AIndex: Integer): Single; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.GamepadSensorUpdate)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The joystick instance ID</summary>
    property JoystickID: TSdlJoystickID read GetJoystickID;

    /// <summary>The joystick (or nil if not opened)</summary>
    property Joystick: TSdlJoystick read GetJoystick;

    /// <summary>The type of the sensor</summary>
    property Sensor: TSdlSensorKind read GetSensor;

    /// <summary>Up to 3 values from the sensor</summary>
    property Data[const AIndex: Integer]: Single read GetData;

    /// <summary>The timestamp of the sensor reading in nanoseconds,
    ///  not necessarily synchronized with the system clock</summary>
    property SensorTimestamp: UInt64 read FHandle.sensor_timestamp;
  end;

type
  /// <summary>
  ///  Audio device event structure (Event.Audio.* )
  /// </summary>
  TSdlAudioDeviceEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AudioDeviceEvent;
    function GetKind: TSdlEventKind; inline;
    function GetAudioDeviceID: TSdlAudioDeviceID; inline;
    function GetAudioDevice: TSdlAudioDevice; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.AudioDevice*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>ID for the device being added or removed or changing</summary>
    property AudioDeviceID: TSdlAudioDeviceID read GetAudioDeviceID;

    /// <summary>The device being added or removed or changing</summary>
    property AudioDevice: TSdlAudioDevice read GetAudioDevice;

    /// <summary>False if a playback device, True if a recording device.</summary>
    property IsRecording: Boolean read FHandle.recording;
  end;

type
  /// <summary>
  ///  Camera device event structure (Event.Camera.* )
  /// </summary>
  TSdlCameraDeviceEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_CameraDeviceEvent;
    function GetKind: TSdlEventKind; inline;
    function GetCameraID: TSdlCameraID; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.CameraDevice*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>ID for the device being added or removed or changing</summary>
    property CameraID: TSdlCameraID read GetCameraID;
  end;

type
  /// <summary>
  ///  Sensor event structure (Event.Sensor.* )
  /// </summary>
  TSdlSensorEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_SensorEvent;
    function GetKind: TSdlEventKind; inline;
    function GetSensorID: TSdlSensorID; inline;
    function GetData(const AIndex: Integer): Single; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.SensorUpdate)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The instance ID of the sensor</summary>
    property SensorID: TSdlSensorID read GetSensorID;

    /// <summary>Up to 6 values from the sensor - additional values can be
    ///  queried using TSdlSensor.GetData</summary>
    property Data[const AIndex: Integer]: Single read GetData;

    /// <summary>The timestamp of the sensor reading in nanoseconds,
    ///  not necessarily synchronized with the system clock</summary>
    property SensorTimestamp: UInt64 read FHandle.sensor_timestamp;
  end;

type
  /// <summary>
  ///  The "quit requested" event
  /// </summary>
  TSdlQuitEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_QuitEvent;
    function GetKind: TSdlEventKind; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Quit)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;
  end;

type
  /// <summary>
  ///  A user-defined event type (event.user.* )
  ///
  ///  This event is unique; it is never created by SDL, but only by the
  ///  application. The event can be pushed onto the event queue using
  ///  TSdlEvents.Push. The contents of the record members are completely up to
  ///  the programmer; the only requirement is that 'Kind' is a value obtained
  ///  from TSdlEvents.Register.
  /// </summary>
  TSdlUserEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_UserEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (registered with TSdlEvents.Register)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the associated window, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The associated window, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>User defined event code</summary>
    property Code: Integer read FHandle.code;

    /// <summary>User defined data pointer</summary>
    property Data1: Pointer read FHandle.data1;

    /// <summary>User defined data pointer</summary>
    property Data2: Pointer read FHandle.data2;
  end;

type
  /// <summary>
  ///  Touch finger event structure (Event.Finger.* )
  ///
  ///  Coordinates in this event are normalized. `X` and `Y` are normalized to a
  ///  range between 0.0 and 1.0, relative to the window, so (0,0) is the top
  ///  left and (1,1) is the bottom right. Delta coordinates `DX` and `DY` are
  ///  normalized in the ranges of -1.0 (traversed all the way from the bottom or
  ///  right to all the way up or left) to 1.0 (traversed all the way from the
  ///  top or left to all the way down or right).
  ///
  ///  Note that while the coordinates are _normalized_, they are not _clamped_,
  ///  which means in some circumstances you can get a value outside of this
  ///  range. For example, a renderer using logical presentation might give a
  ///  negative value when the touch is in the letterboxing. Some platforms might
  ///  report a touch outside of the window, which will also be outside of the
  ///  range.
  /// </summary>
  TSdlTouchFingerEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TouchFingerEvent;
    function GetKind: TSdlEventKind; inline;
    function GetTouch: TSdlTouch; inline;
    function GetWindow: TSdlWindow; inline;
    function GetPosition: TSdlPointF; inline;
    function GetDelta: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Finger*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The touch device</summary>
    property Touch: TSdlTouch read GetTouch;

    property FingerID: TSdlFingerID read FHandle.fingerID;

    /// <summary>Normalized in the range 0...1</summary>
    property X: Single read FHandle.x;

    /// <summary>Normalized in the range 0...1</summary>
    property Y: Single read FHandle.y;

    /// <summary>Normalized in the range (0...1, 0...1)</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>Normalized in the range -1...1</summary>
    property DX: Single read FHandle.dx;

    /// <summary>Normalized in the range -1...1</summary>
    property DY: Single read FHandle.dy;

    /// <summary>Normalized in the range (-1...1, -1...1)</summary>
    property Delta: TSdlPointF read GetDelta;

    /// <summary>Normalized in the range 0...1</summary>
    property Pressure: Single read FHandle.pressure;

    /// <summary>The ID of the window underneath the finger, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window underneath the finger, if any</summary>
    property Window: TSdlWindow read GetWindow;
  end;

type
  /// <summary>
  ///  Pressure-sensitive pen proximity event structure (Event.PenProximity.* )
  ///
  ///  When a pen becomes visible to the system (it is close enough to a tablet,
  ///  etc), SDL will send an TSdlEventKind.PenProximityIn event with the new pen's
  ///  ID. This ID is valid until the pen leaves proximity again (has been removed
  ///  from the tablet's area, the tablet has been unplugged, etc). If the same
  ///  pen reenters proximity again, it will be given a new ID.
  ///
  ///  Note that "proximity" means "close enough for the tablet to know the tool
  ///  is there." The pen touching and lifting off from the tablet while not
  ///  leaving the area are handled by TSdlEventKind.PenDown and TSdlEventKind.PenUp.
  /// </summary>
  TSdlPenProximityEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PenProximityEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.PenProximityIn/Out)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with pen focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with pen focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The pen instance id</summary>
    property PenID: TSdlPenID read FHandle.which;
  end;

type
  /// <summary>
  ///  Pressure-sensitive pen touched event structure (Event.PenTouch.* )
  ///
  ///  These events come when a pen touches a surface (a tablet, etc), or lifts
  ///  off from one.
  /// </summary>
  TSdlPenTouchEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PenTouchEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetPenState: TSdlPenInputFlags; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.PenUp/Down)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with pen focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with pen focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The pen instance id</summary>
    property PenID: TSdlPenID read FHandle.which;

    /// <summary>Complete pen input state at time of event</summary>
    property PenState: TSdlPenInputFlags read GetPenState;

    /// <summary>X coordinate, relative to window</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>True if eraser end is used (not all pens support this).</summary>
    property IsEraserUsed: Boolean read FHandle.eraser;

    /// <summary>True if the pen is touching or false if the pen is lifted off</summary>
    property IsDown: Boolean read FHandle.down;
  end;

type
  /// <summary>
  ///  Pressure-sensitive pen motion event structure (Event.PenMotion.* )
  ///
  ///  Depending on the hardware, you may get motion events when the pen is not
  ///  touching a tablet, for tracking a pen even when it isn't drawing. You
  ///  should listen for TSdlEventKind.PenDown and TSdlEventKind.PenUp events,
  ///  or check `TSdlPenInputFlags.Down in PenState` to decide if a pen is
  ///  "drawing" when dealing with pen motion.
  /// </summary>
  TSdlPenMotionEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PenMotionEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetPenState: TSdlPenInputFlags; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.PenMotion)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with pen focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with pen focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The pen instance id</summary>
    property PenID: TSdlPenID read FHandle.which;

    /// <summary>Complete pen input state at time of event</summary>
    property PenState: TSdlPenInputFlags read GetPenState;

    /// <summary>X coordinate, relative to window</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;
  end;

type
  /// <summary>
  ///  Pressure-sensitive pen button event structure (Event.PenButton.* )
  ///
  ///  This is for buttons on the pen itself that the user might click. The pen
  ///  itself pressing down to draw triggers a TSdlEventKind.PenDown event instead.
  /// </summary>
  TSdlPenButtonEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PenButtonEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetPenState: TSdlPenInputFlags; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.PenButtonUp/Down)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with pen focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with pen focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The pen instance id</summary>
    property PenID: TSdlPenID read FHandle.which;

    /// <summary>Complete pen input state at time of event</summary>
    property PenState: TSdlPenInputFlags read GetPenState;

    /// <summary>X coordinate, relative to window</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>The pen button index (first button is 1).</summary>
    property Button: Byte read FHandle.button;

    /// <summary>True if the button is pressed</summary>
    property IsDown: Boolean read FHandle.down;
  end;

type
  /// <summary>
  ///  Pressure-sensitive pen pressure / angle event structure (Event.PenAxis.* )
  ///
  ///  You might get some of these events even if the pen isn't touching the
  ///  tablet.
  /// </summary>
  TSdlPenAxisEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PenAxisEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetPenState: TSdlPenInputFlags; inline;
    function GetAxis: TSdlPenAxis; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.PenAxis)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window with pen focus, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window with pen focus, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>The pen instance id</summary>
    property PenID: TSdlPenID read FHandle.which;

    /// <summary>Complete pen input state at time of event</summary>
    property PenState: TSdlPenInputFlags read GetPenState;

    /// <summary>X coordinate, relative to window</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>Axis that has changed</summary>
    property Axis: TSdlPenAxis read GetAxis;

    /// <summary>New value of axis</summary>
    property Value: Single read FHandle.value;
  end;

type
  /// <summary>
  ///  Renderer event structure (Event.Render.* )
  /// </summary>
  TSdlRenderEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_RenderEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Render*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window containing the renderer in question.</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window containing the renderer in question.</summary>
    property Window: TSdlWindow read GetWindow;
  end;

type
  /// <summary>
  ///  An event used to drop text or request a file open by the system
  ///  (Event.Drop.* )
  /// </summary>
  TSdlDropEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_DropEvent;
    function GetKind: TSdlEventKind; inline;
    function GetWindow: TSdlWindow; inline;
    function GetSource: String; inline;
    function GetData: String; inline;
    function GetPosition: TSdlPointF; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.Drop*)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>The ID of the window that was dropped on, if any</summary>
    property WindowID: TSdlWindowID read FHandle.windowID;

    /// <summary>The window that was dropped on, if any</summary>
    property Window: TSdlWindow read GetWindow;

    /// <summary>X coordinate, relative to window (not on begin)</summary>
    property X: Single read FHandle.x;

    /// <summary>Y coordinate, relative to window (not on begin)</summary>
    property Y: Single read FHandle.y;

    /// <summary>Position, relative to window (not on begin)</summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>Pointer to a string of the source app that sent this drop event,
    ///  or nil if that isn't available</summary>
    property SourcePtr: PUTF8Char read FHandle.source;

    /// <summary>The source app that sent this drop event,
    ///  or empty if that isn't available</summary>
    property Source: String read GetSource;

    /// <summary>Pointer to the text for TSdlEventKind.DropText and the file
    ///  name for TSdlEventKind.DropFile, nil for other events</summary>
    property DataPtr: PUTF8Char read FHandle.data;

    /// <summary>The text for TSdlEventKind.DropText and the file name for
    ///  TSdlEventKind.DropFile, nil for other events</summary>
    property Data: String read GetData;
  end;

type
  /// <summary>
  ///  An event used to drop text or request a file open by the system
  ///  (Event.Drop.* )
  /// </summary>
  TSdlClipboardEvent = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_ClipboardEvent;
    function GetKind: TSdlEventKind; inline;
    function GetMimeTypes: TArray<String>;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>Event kind (TSdlEventKind.ClipboardUpdate)</summary> }
    property Kind: TSdlEventKind read GetKind;

    /// <summary>In nanoseconds, populated using SdlGetTicksNS</summary>
    property Timestamp: UInt64 read FHandle.timestamp;

    /// <summary>Are we owning the clipboard (internal update)</summary>
    property IsOwner: Boolean read FHandle.owner;

    /// <summary>Number of mime types</summary>
    property NumMimeTypes: Integer read FHandle.num_mime_types;

    /// <summary>Pointer to current mime types</summary>
    property MimeTypesPtr: PPUTF8Char read FHandle.mime_types;

    /// <summary>Current mime types</summary>
    property MimeTypes: TArray<String> read GetMimeTypes;
  end;

type
  /// <summary>
  ///  A variant record that contains records for the different event types.
  ///  The TSdlEvent record is the core of all event handling in SDL. TSdlEvent
  ///  is a variant record of all event records used in SDL. Using it is a
  ///  simple matter of knowing which event kind corresponds to which property.
  ///  The table below lists these relationships.
  ///
  ///  | TSdlEventKind              | Event Record                   | TSdlEvent Field |
  ///  | -------------------------- | ------------------------------ | --------------- |
  ///  | Display*                   | TSdlDisplayEvent               | Display         |
  ///  | Window*                    | TSdlWindowEvent                | Window          |
  ///  | KeyboardAdded/Removed      | TSdlKeyboardDeviceEvent        | KeyboardDevice  |
  ///  | Key*                       | TSdlKeyboardEvent              | Key             |
  ///  | TextEditing                | TSdlTextEditingEvent           | TextEdit        |
  ///  | TextEditingCandidates      | TSdlTextEditingCandidatesEvent | TextCandidates  |
  ///  | TextInput                  | TSdlTextInputEvent             | TextInput       |
  ///  | MouseAdded/Removed         | TSdlMouseDeviceEvent           | MouseDevice     |
  ///  | MouseMotion                | TSdlMouseMotionEvent           | MouseMotion     |
  ///  | MouseButtonUp/Down         | TSdlMouseButtonEvent           | MouseButton     |
  ///  | MouseWheel                 | TSdlMouseWheelEvent            | MouseWheel      |
  ///  | JoystickAdded/Removed/     |                                |                 |
  ///  |   UpdateComplete           | TSdlJoyDeviceEvent             | JoyDevice       |
  ///  | JoystickAxisMotion         | TSdlJoyAxisEvent               | JoyAxis         |
  ///  | JoystickBallMotion         | TSdlJoyBallEvent               | JoyBall         |
  ///  | JoystickHatMotion          | TSdlJoyHatEvent                | JoyHat          |
  ///  | JoystickButtonUp/Down      | TSdlJoyButtonEvent             | JoyButton       |
  ///  | JoystickBatteryUpdated     | TSdlJoyBatteryEvent            | JoyBattery      |
  ///  | GamepadAdded/Removed/      |                                |                 |
  ///  |   Remapped/UpdateComplete  |                                |                 |
  ///  |   SteamHandleUpdated       | TSdlGamepadDeviceEvent         | GamepadDevice   |
  ///  | GamepadAxisMotion          | TSdlGamepadAxisEvent           | GamepadAxis     |
  ///  | GamepadButtonUp/Down       | TSdlGamepadButtonEvent         | GamepadButton   |
  ///  | GamepadTouchpad*           | TSdlGamepadTouchpadEvent       | GamepadTouch    |
  ///  | GamepadSensorUpdate        | TSdlGamepadSensorEvent         | GamepadSensor   |
  ///  | AudioDevice*               | TSdlAudioDeviceEvent           | Audio           |
  ///  | CameraDevice*              | TSdlCameraDeviceEvent          | Camera          |
  ///  | SensorUpdate               | TSdlSensorEvent                | Sensor          |
  ///  | Quit                       | TSdlQuitEvent                  | Quit            |
  ///  | Finger*                    | TSdlTouchFingerEvent           | Finger          |
  ///  | PenProximityIn/Out         | TSdlPenProximityEvent          | PenProximity    |
  ///  | PenUp/Down                 | TSdlPenTouchEvent              | PenTouch        |
  ///  | PenMotion                  | TSdlPenMotionEvent             | PenMotion       |
  ///  | PenButtonUp/Down           | TSdlPenButtonEvent             | PenButton       |
  ///  | PenAxis                    | TSdlPenAxisEvent               | PenAxis         |
  ///  | Render*                    | TSdlRenderEvent                | Render          |
  ///  | Drop*                      | TSdlDropEvent                  | Drop            |
  ///  | ClipboardUpdate            | TSdlClipboardEvent             | Clipboard       |
  ///  | (registered user event)    | TSdlUserEvent                  | User            |
  ///  | (other events)             | TSdlCommonEvent                | Common          |
  /// </summary>
  TSdlEvent = record
  public
    /// <summary>
    ///  Convert the coordinates in an event to render coordinates.
    ///
    ///  This takes into account several states:
    ///
    ///  - The window dimensions.
    ///  - The logical presentation settings (SetLogicalPresentation)
    ///  - The scale (Scale)
    ///  - The viewport (Viewport)
    ///
    ///  Various event types are converted with this function: mouse, touch, pen,
    ///  etc.
    ///
    ///  Touch coordinates are converted from normalized coordinates in the window
    ///  to non-normalized rendering coordinates.
    ///
    ///  Relative mouse coordinates (XRel and YRel event fields) are _also_
    ///  converted. Applications that do not want these fields converted should use
    ///  TSdlRenderer.RenderCoordinatesFromWindow on the specific event fields
    ///  instead of converting the entire event structure.
    ///
    ///  Once converted, coordinates may be outside the rendering area.
    /// </summary>
    /// <param name="ARenderer">The rendering context.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlRenderer.RenderCoordinatesFromWindow"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure ConvertToRenderCoordinates(const ARenderer: TSdlRenderer); inline;
  public
    case Byte of
      /// <summary>Event kind, shared with all events</summary>
      0: (Kind: TSdlEventKind);

      /// <summary>Common event data</summary>
      1: (Common: TSdlCommonEvent);

      /// <summary>Display event data</summary>
      2: (Display: TSdlDisplayEvent);

      /// <summary>Window event data</summary>
      3: (Window: TSdlWindowEvent);

      /// <summary>Keyboard device change event data</summary>
      4: (KeyboardDevice: TSdlKeyboardDeviceEvent);

      /// <summary>Keyboard event data</summary>
      5: (Key: TSdlKeyboardEvent);

      /// <summary>Text editing event data</summary>
      6: (TextEdit: TSdlTextEditingEvent);

      /// <summary>Text editing candidates event data</summary>
      7: (TextCandidates: TSdlTextEditingCandidatesEvent);

      /// <summary>Text editing candidates event data</summary>
      8: (TextInput: TSdlTextInputEvent);

      /// <summary>Mouse device change event data</summary>
      9: (MouseDevice: TSdlMouseDeviceEvent);

      /// <summary>Mouse motion event data</summary>
      10: (MouseMotion: TSdlMouseMotionEvent);

      /// <summary>Mouse button event data</summary>
      11: (MouseButton: TSdlMouseButtonEvent);

      /// <summary>Mouse wheel event data</summary>
      12: (MouseWheel: TSdlMouseWheelEvent);

      /// <summary>Joystick device change event data</summary>
      13: (JoyDevice: TSdlJoyDeviceEvent);

      /// <summary>Joystick axis event data</summary>
      14: (JoyAxis: TSdlJoyAxisEvent);

      /// <summary>Joystick ball event data</summary>
      15: (JoyBall: TSdlJoyBallEvent);

      /// <summary>Joystick hat event data</summary>
      16: (JoyHat: TSdlJoyHatEvent);

      /// <summary>Joystick button event data</summary>
      17: (JoyButton: TSdlJoyButtonEvent);

      /// <summary>Joystick battery event data</summary>
      18: (JoyBattery: TSdlJoyBatteryEvent);

      /// <summary>Gamepad device event data</summary>
      19: (GamepadDevice: TSdlGamepadDeviceEvent);

      /// <summary>Gamepad axis event data</summary>
      20: (GamepadAxis: TSdlGamepadAxisEvent);

      /// <summary>Gamepad button event data</summary>
      21: (GamepadButton: TSdlGamepadButtonEvent);

      /// <summary>Gamepad touchpad event data</summary>
      22: (GamepadTouch: TSdlGamepadTouchpadEvent);

      /// <summary>Gamepad sensor event data</summary>
      23: (GamepadSensor: TSdlGamepadSensorEvent);

      /// <summary>Audio device event data</summary>
      24: (Audio: TSdlAudioDeviceEvent);

      /// <summary>Camera device event data</summary>
      25: (Camera: TSdlCameraDeviceEvent);

      /// <summary>Sensor event data</summary>
      26: (Sensor: TSdlSensorEvent);

      /// <summary>Quit request event data</summary>
      27: (Quit: TSdlQuitEvent);

      /// <summary>Custom event data</summary>
      28: (User: TSdlUserEvent);

      /// <summary>Touch finger event data</summary>
      29: (Finger: TSdlTouchFingerEvent);

      /// <summary>Pen proximity event data</summary>
      30: (PenProximity: TSdlPenProximityEvent);

      /// <summary>Pen tip touching event data</summary>
      31: (PenTouch: TSdlPenTouchEvent);

      /// <summary>Pen motion event data</summary>
      32: (PenMotion: TSdlPenMotionEvent);

      /// <summary>Pen button event data</summary>
      33: (PenButton: TSdlPenButtonEvent);

      /// <summary>Pen axis event data</summary>
      34: (PenAxis: TSdlPenAxisEvent);

      /// <summary>Render event data</summary>
      35: (Render: TSdlRenderEvent);

      /// <summary>Drag and drop event data</summary>
      36: (Drop: TSdlDropEvent);

      /// <summary>Clipboard event data</summary>
      37: (Clipboard: TSdlClipboardEvent);

      /// <summary>Handle to underlying C event record</summary>
      38: (Handle: SDL_Event);
  end;
  PSdlEvent = ^TSdlEvent;

type
  /// <summary>
  ///  The type of action to request from TSdlEvents.Peep.
  /// </summary>
  TSdlEventAction = (
    /// <summary>Add events to the back of the queue.</summary>
    Add  = SDL_ADDEVENT,

    /// <summary>Check but don't remove events from the queue front.</summary>
    Peek = SDL_PEEKEVENT,

    /// <summary>Retrieve/remove events from the front of the queue.</summary>
    Get  = SDL_GETEVENT);

type
  /// <summary>
  ///  A function type used for callbacks that watch the event queue.
  /// </summary>
  /// <param name="AEvent">The event that triggered the callback.</param>
  /// <returns>True to permit event to be added to the queue, and False to
  ///  disallow it. When used with TSdlEvents.AddWatch, the return value is ignored.</returns>
  /// <seealso cref="TSdlEvents.SetFilter"/>
  /// <seealso cref="TSdlEvents.AddWatch"/>
  /// <remarks>
  ///  SDL may call this callback at any time from any thread; the application
  ///  is responsible for locking resources the callback touches that need to be
  //   protected.
  /// </remarks>
  TSdlEventFilter = function(const AEvent: TSdlEvent): Boolean of object;

type
  /// <summary>
  ///  Event queue management.
  ///
  ///  It's extremely common--often required--that an app deal with SDL's event
  ///  queue. Almost all useful information about interactions with the real world
  ///  flow through here: the user interacting with the computer and app, hardware
  ///  coming and going, the system changing in some way, etc.
  ///
  ///  An app generally takes a moment, perhaps at the start of a new frame, to
  ///  examine any events that have occured since the last time and process or
  ///  ignore them. This is generally done by overriding TSdlApp.Event.
  ///
  ///  There is other forms of control, too: Peep has more functionality at the
  ///  cost of more complexity, and Wait can block the process until something
  ///  interesting happens, which might be beneficial for certain types of
  ///  programs on low-power hardware. One may also call AddWatch to set a
  ///  callback when new events arrive.
  ///
  ///  The app is free to generate their own events, too: Push allows the app to
  ///  put events onto the queue for later retrieval; Register can guarantee
  ///  that these events have a kind that isn't in use by other parts of the system.
  /// </summary>
  TSdlEvents = record
  {$REGION 'Internal Declarations'}
  private const
    MAX_WATCHES = 16;
  private type
    PSdlEventFilter = ^TSdlEventFilter;
  private class var
    FFilter: TSdlEventFilter;
    FWatches: array [0..MAX_WATCHES - 1] of TSdlEventFilter;
  private
    class function EventFilter(AUserdata: Pointer;
      AEvent: PSDL_Event): Boolean; static; cdecl;
    class function EventWatch(AUserdata: Pointer;
      AEvent: PSDL_Event): Boolean; static; cdecl;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Pump the event loop, gathering events from the input devices.
    ///
    ///  This function updates the event queue and internal input device state.
    ///
    ///  Pump gathers all the pending input information from devices and places
    ///  it in the event queue. Without calls to Pump no events would ever be
    ///  placed on the queue. Often the need for calls to Pump is hidden from
    ///  the user since TSdlApp.Event, Poll and Wait implicitly call Pump.
    ///  However, if you are not polling or waiting for events (e.g. you are
    ///  filtering them), then you must call Pump to force an event queue update.
    /// </summary>
    /// <seealso cref="Poll"/>
    /// <seealso cref="Wait"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class procedure Pump; inline; static;

    /// <summary>
    ///  Check the event queue for messages and optionally return them.
    ///
    ///  `AAction` may be any of the following:
    ///
    ///  - `TSdlEventAction.Add`: up to `ANumEvents` events will be added to the
    ///    back of the event queue.
    ///  - `TSdlEventAction.Peek`: `ANumEvents` events at the front of the event
    ///    queue, within the specified minimum and maximum type, will be returned
    ///    to the caller and will _not_ be removed from the queue. If you pass
    ///    nil for `AEvents`, then `ANumEvents` is ignored and the total number
    ///    of matching events will be returned.
    ///  - `TSdlEventAction.Get`: up to `ANumEvents` events at the front of the
    ///    event queue, within the specified minimum and maximum type, will be
    ///    returned to the caller and will be removed from the queue.
    ///
    ///  You may have to call Pump before calling this function. Otherwise, the
    ///  events may not be ready to be filtered when you call Peep.
    /// </summary>
    /// <param name="AEvents">Destination buffer for the retrieved events, may
    ///  be nil to leave the events in the queue and return the number of events
    ///  that would have been stored.</param>
    /// <param name="AAction">Action to take.</param>
    /// <param name="AMinKind">(Optional) Minimum value of the event kind to be
    ///  considered; TSdlEventKind.First is a safe choice.</param>
    /// <param name="AMaxType">(Optional) Maximum value of the event type to be
    ///  considered; TSdlEventKind.Last is a safe choice.</param>
    /// <returns>The number of events actually stored.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Poll"/>
    /// <seealso cref="Pump"/>
    /// <seealso cref="Push"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function Peep(const AEvents: TArray<TSdlEvent>;
      const AAction: TSdlEventAction;
      const AMinKind: TSdlEventKind = TSdlEventKind.First;
      const AMaxKind: TSdlEventKind = TSdlEventKind.Last): Integer; overload; inline; static;

    /// <summary>
    ///  Check the event queue for messages and optionally return them.
    ///
    ///  `AAction` may be any of the following:
    ///
    ///  - `TSdlEventAction.Add`: up to `ANumEvents` events will be added to the
    ///    back of the event queue.
    ///  - `TSdlEventAction.Peek`: `ANumEvents` events at the front of the event
    ///    queue, within the specified minimum and maximum type, will be returned
    ///    to the caller and will _not_ be removed from the queue. If you pass
    ///    nil for `AEvents`, then `ANumEvents` is ignored and the total number
    ///    of matching events will be returned.
    ///  - `TSdlEventAction.Get`: up to `ANumEvents` events at the front of the
    ///    event queue, within the specified minimum and maximum type, will be
    ///    returned to the caller and will be removed from the queue.
    ///
    ///  You may have to call Pump before calling this function. Otherwise, the
    ///  events may not be ready to be filtered when you call Peep.
    /// </summary>
    /// <param name="AEvents">Destination buffer for the retrieved events, may
    ///  be nil to leave the events in the queue and return the number of events
    ///  that would have been stored.</param>
    /// <param name="ANumEvents">If action is TSdlEventAction.Add, the number of
    ///  events to add back to the event queue; if action is TSdlEventAction.Peek
    ///  or TSdlEventAction.Get, the maximum number of events to retrieve.</param>
    /// <param name="AAction">Action to take.</param>
    /// <param name="AMinKind">(Optional) Minimum value of the event kind to be
    ///  considered; TSdlEventKind.First is a safe choice.</param>
    /// <param name="AMaxType">(Optional) Maximum value of the event type to be
    ///  considered; TSdlEventKind.Last is a safe choice.</param>
    /// <returns>The number of events actually stored.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Poll"/>
    /// <seealso cref="Pump"/>
    /// <seealso cref="Push"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function Peep(const AEvents: PSdlEvent; const ANumEvents: Integer;
      const AAction: TSdlEventAction;
      const AMinKind: TSdlEventKind = TSdlEventKind.First;
      const AMaxKind: TSdlEventKind = TSdlEventKind.Last): Integer; overload; inline; static;

    /// <summary>
    ///  Check for the existence of a certain event kind in the event queue.
    ///
    ///  If you need to check for a range of event types, use the other
    ///  overload instead.
    /// </summary>
    /// <param name="AKind">The kind of event to be queried.</param>
    /// <returns>True if events matching `AKind` are present, or False if events
    ///  matching `AKind` are not present.</returns>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function Has(const AKind: TSdlEventKind): Boolean; overload; inline; static;

    /// <summary>
    ///  Check for the existence of certain event kind in the event queue.
    ///
    ///  If you need to check for a single event kind, use the other overload
    ///  instead.
    /// </summary>
    /// <param name="AMinKind">The low end of event kind to be queried, inclusive.</param>
    /// <param name="AMaxType">The high end of event kind to be queried, inclusive.</param>
    /// <returns>True if events with type >= `AMinKind` and <= `AMaxKind` are
    ///  present, or False if not.</returns>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function Has(const AMinKind, AMaxKind: TSdlEventKind): Boolean; overload; inline; static;

    /// <summary>
    ///  Clear events of a specific kind from the event queue.
    ///
    ///  This will unconditionally remove any events from the queue that match
    ///  `AKind`. If you need to remove a range of event types, use the other
    ///  overload instead.
    ///
    ///  It's also normal to just ignore events you don't care about in your event
    ///  loop without calling this function.
    ///
    ///  This function only affects currently queued events. If you want to make
    ///  sure that all pending OS events are flushed, you can call Pump on the
    ///  main thread immediately before the flush call.
    ///
    ///  If you have user events with custom data that needs to be freed, you
    ///  should use Peep to remove and clean up those events before calling
    ///  this function.
    /// </summary>
    /// <param name="AKind">The kind of event to be cleared.</param>
    /// <seealso cref="FlushEvents"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class procedure Flush(const AKind: TSdlEventKind); overload; inline; static;

    /// <summary>
    ///  Clear events of a range of kinds from the event queue.
    ///
    ///  This will unconditionally remove any events from the queue that are in
    ///  the range of `AMinKind` to `AMaxKind`, inclusive. If you need to remove
    ///  a single event kind, use the other overload instead.
    ///
    ///  It's also normal to just ignore events you don't care about in your event
    ///  loop without calling this function.
    ///
    ///  This function only affects currently queued events. If you want to make
    ///  sure that all pending OS events are flushed, you can call Pump on the
    ///  main thread immediately before the flush call.
    /// </summary>
    /// <param name="AMinKind">The low end of event kind to be cleared.</param>
    /// <param name="AMaxKind">The high end of event kind to be cleared, inclusive.</param>
    /// <remarks>
    ///  This function is available since SDL 3.2.0.
    /// </remarks>
    class procedure Flush(const AMinKind, AMaxKind: TSdlEventKind); overload; inline; static;

    /// <summary>
    ///  Poll for currently pending events.
    ///
    ///  If `AEvent` is given, the next event is removed from the queue and
    ///  stored in this record. It returns True if there was an event.
    ///
    ///  If `AEvent` is not given, it simply returns True if there is an event
    ///  in the queue, but will not remove it from the queue.
    ///
    ///  As this function may implicitly call Pump, you can only call this
    ///  function in the thread that set the video mode.
    ///
    ///  Either using TSdlApp.Event or Poll are the favored ways of receiving
    ///  system events since it can be done from the main loop and does not
    ///  suspend the main loop while waiting on an event to be posted.
    ///
    ///  The common practice is to fully process the event queue once every frame,
    ///  usually as a first step before updating the game's state. This is done
    ///  automatically if you override TSdlApp.Poll.
    /// </summary>
    /// <param name="AEvent">(Optional) Event record to be filled with the next event from the queue.</param>
    /// <returns>True if this got an event or False if there are none available.</returns>
    /// <seealso cref="Push"/>
    /// <seealso cref="Wait"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class function Poll: Boolean; overload; inline; static;
    class function Poll(out AEvent: TSdlEvent): Boolean; overload; inline; static;

    /// <summary>
    ///  Wait indefinitely for the next available event.
    ///
    ///  If `AEvent` is not given, the next event is removed from the queue and
    ///  stored in this record.
    ///
    ///  As this function may implicitly call Pump, you can only call this
    ///  function in the thread that initialized the video subsystem.
    /// </summary>
    /// <param name="AEvent">(Optional) Event record to be filled in with the
    ///  next event from the queue.</param>
    /// <exception name="ESdlError">If there was an error while waiting for events.</exception>
    /// <seealso cref="Poll"/>
    /// <seealso cref="Push"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class procedure Wait; overload; inline; static;
    class procedure Wait(out AEvent: TSdlEvent); overload; inline; static;

    /// <summary>
    ///  Wait until the specified timeout (in milliseconds) for the next available
    ///  event.
    ///
    ///  If `AEvent` is not given, the next event is removed from the queue and
    ///  stored in this record.
    ///
    ///  As this function may implicitly call Pump, you can only call this
    ///  function in the thread that initialized the video subsystem.
    ///
    ///  The timeout is not guaranteed, the actual wait time could be longer due to
    ///  system scheduling.
    /// </summary>
    /// <param name="ATimeoutMS">the maximum number of milliseconds to wait for
    ///  the next available event.</param>
    /// <param name="AEvent">(Optional) Event record to be filled in with the
    ///  next event from the queue.</param>
    /// <returns>True if this got an event or False if the timeout elapsed
    ///  without any events available.</returns>
    /// <seealso cref="Poll"/>
    /// <seealso cref="Push"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class function Wait(const ATimeoutMS: Integer): Boolean; overload; inline; static;
    class function Wait(const ATimeoutMS: Integer;
      out AEvent: TSdlEvent): Boolean; overload; inline; static;

    /// <summary>
    ///  Add an event to the event queue.
    ///
    ///  The event queue can actually be used as a two way communication channel.
    ///  Not only can events be read from the queue, but the user can also push
    ///  their own events onto it. `AEvent` is the event record you wish to push
    ///  onto the queue. The event is copied into the queue.
    ///
    ///  Note: Pushing device input events onto the queue doesn't modify the state
    ///  of the device within SDL.
    ///
    ///  Note: Events pushed onto the queue with Push get passed through the
    ///  event filter but events added with Peep do not.
    ///
    ///  For pushing application-specific events, please use Register to get an
    ///  event kind that does not conflict with other code that also wants
    ///  its own custom event kinds.
    /// </summary>
    /// <param name="AEvent">The event to be added to the queue.</param>
    /// <returns>True on success, False if the event was filtered.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Peep"/>
    /// <seealso cref="Poll"/>
    /// <seealso cref="Register"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function Push(const AEvent: TSdlEvent): Boolean; inline; static;

    /// <summary>
    ///  Set up a filter to process all events before they are added to the internal
    ///  event queue.
    ///
    ///  If you just want to see events without modifying them or preventing them
    ///  from being queued, you should use AddWatch instead.
    ///
    ///  If the filter function returns True when called, then the event will be
    ///  added to the internal queue. If it returns False, then the event will be
    ///  dropped from the queue, but the internal state will still be updated. This
    ///  allows selective filtering of dynamically arriving events.
    ///
    ///  **WARNING**: Be very careful of what you do in the event filter function,
    ///  as it may run in a different thread!
    ///
    ///  On platforms that support it, if the quit event is generated by an
    ///  interrupt signal (e.g. pressing Ctrl-C), it will be delivered to the
    ///  application at the next event poll.
    ///
    ///  Note: Disabled events never make it to the event filter function; see
    ///  SetEnabled.
    ///
    ///  Note: Events pushed onto the queue with Push get passed through the
    ///  event filter, but events pushed onto the queue with Peep do not.
    /// </summary>
    /// <param name="AFilter">Filter function to call when an event happens.</param>
    /// <seealso cref="AddWatch"/>
    /// <seealso cref="SetEnabled"/>
    /// <seealso cref="GetFilter"/>
    /// <seealso cref="Peep"/>
    /// <seealso cref="Push"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class procedure SetFilter(const AFilter: TSdlEventFilter); static;

    /// <summary>
    ///  Query the current event filter.
    ///
    ///  This function can be used to "chain" filters, by saving the existing filter
    ///  before replacing it with a function that will call that saved filter.
    /// </summary>
    /// <param name="AFilter">The current callback function will be stored here.</param>
    /// <returns>True on success or False if there is no event filter set.</returns>
    /// <seealso cref="SetFilter"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function GetFilter(out AFilter: TSdlEventFilter): Boolean; static;

    /// <summary>
    ///  Add a callback to be triggered when an event is added to the event queue.
    ///
    ///  `AFilter` will be called when an event happens, and its return value is
    ///  ignored.
    ///
    ///  **WARNING**: Be very careful of what you do in the event filter function,
    ///  as it may run in a different thread!
    ///
    ///  If the quit event is generated by a signal (e.g. SIGINT), it will bypass
    ///  the internal queue and be delivered to the watch callback immediately, and
    ///  arrive at the next event poll.
    ///
    ///  Note: the callback is called for events posted by the user through
    ///  Push, but not for disabled events, nor for events by a filter callback
    ///  set with SetFilter, nor for events posted by the user through Peep.
    /// </summary>
    /// <param name="AFilter">Function to call when an event happens.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="RemoveWatch"/>
    /// <seealso cref="SetFilter"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class procedure AddWatch(const AFilter: TSdlEventFilter); static;

    /// <summary>
    ///  Remove an event watch callback added with AddWatch.
    ///
    ///  This function takes the same input as AddWatch to identify and
    ///  delete the corresponding callback.
    /// </summary>
    /// <param name="AFilter">The function originally passed to AddWatch.</param>
    /// <seealso cref="AddWatch"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class procedure RemoveWatch(const AFilter: TSdlEventFilter); static;

    /// <summary>
    ///  Run a specific filter function on the current event queue, removing any
    ///  events for which the filter returns false.
    ///
    ///  See SetFilter for more information. Unlike SetFilter, this method does
    ///  not change the filter permanently, it only uses the supplied filter
    ///  until this function returns.
    /// </summary>
    /// <param name="AFilter">The function to call when an event happens.</param>
    /// <seealso cref="GetFilter"/>
    /// <seealso cref="SetFilter"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class procedure Filter(const AFilter: TSdlEventFilter); static;

    /// <summary>
    ///  Set the state of processing events by kind.
    /// </summary>
    /// <param name="AKind">The kind of event.</param>
    /// <param name="AEnabled">Whether to process the event or not.</param>
    /// <seealso cref="IsEnabled"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class procedure SetEnabled(const AKind: TSdlEventKind;
      const AEnabled: Boolean); inline; static;

    /// <summary>
    ///  Query the state of processing events by kind.
    /// </summary>
    /// <param name="AKind">The kind of event.</param>
    /// <returns>True if the event is being processed, False otherwise.</returns>
    /// <seealso cref="SetEnabled"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function IsEnabled(const AKind: TSdlEventKind): Boolean; inline; static;

    /// <summary>
    ///  Registers a user-defined events.
    /// </summary>
    /// <returns>A new TSdlEventKind value, or TSdlEventKind.First if there are
    ///  not enough user-defined events left.</returns>
    /// <seealso cref="Push"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    ///
    ///  The returned value is outside of the standard TSdlEventKind enum
    ///  range, but can still be used with all event functionality.
    /// </remarks>
    class function Register: TSdlEventKind; inline; static;
  end;
{$ENDREGION 'Events'}

implementation

uses
  Neslib.Sdl3.Basics;

{ TSdlCommonEvent }

function TSdlCommonEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlDisplayEvent }

function TSdlDisplayEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlWindowEvent }

function TSdlWindowEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlWindowEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlKeyboardDeviceEvent }

function TSdlKeyboardDeviceEvent.GetKeyboard: TSdlKeyboard;
begin
  SDL_KeyboardID(Result) := FHandle.which;
end;

function TSdlKeyboardDeviceEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlKeyboardEvent }

function TSdlKeyboardEvent.GetKey: TSdlKeycode;
begin
  Result := TSdlKeycode(FHandle.key);
end;

function TSdlKeyboardEvent.GetKeyboard: TSdlKeyboard;
begin
  SDL_KeyboardID(Result) := FHandle.which;
end;

function TSdlKeyboardEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlKeyboardEvent.GetMods: TSdlKeymods;
begin
  Word(Result) := FHandle.&mod;
end;

function TSdlKeyboardEvent.GetScancode: TSdlScancode;
begin
  Result := TSdlScancode(FHandle.scancode);
end;

{ TSdlTextEditingEvent }

function TSdlTextEditingEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlTextEditingEvent.GetText: String;
begin
  Result := __ToString(FHandle.text);
end;

function TSdlTextEditingEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlTextEditingCandidatesEvent }

function TSdlTextEditingCandidatesEvent.GetCandidates: TArray<String>;
begin
  SetLength(Result, FHandle.num_candidates);
  var P := FHandle.candidates;
  for var I := 0 to Length(Result) - 1 do
  begin
    Result[I] := __ToString(P^);
    Inc(P);
  end;
end;

function TSdlTextEditingCandidatesEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlTextEditingCandidatesEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlTextInputEvent }

function TSdlTextInputEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlTextInputEvent.GetText: String;
begin
  Result := __ToString(FHandle.text);
end;

function TSdlTextInputEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlMouseDeviceEvent }

function TSdlMouseDeviceEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlMouseDeviceEvent.GetMouse: TSdlMouse;
begin
  SDL_MouseID(Result) := FHandle.which;
end;

{ TSdlMouseMotionEvent }

function TSdlMouseMotionEvent.GetButtons: TSdlMouseButtons;
begin
  Byte(Result) := FHandle.state;
end;

function TSdlMouseMotionEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlMouseMotionEvent.GetMouse: TSdlMouse;
begin
  SDL_MouseID(Result) := FHandle.which;
end;

function TSdlMouseMotionEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlMouseMotionEvent.GetRel: TSdlPointF;
begin
  Result.Init(FHandle.xrel, FHandle.yrel);
end;

function TSdlMouseMotionEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlMouseButtonEvent }

function TSdlMouseButtonEvent.GetButton: TSdlMouseButton;
begin
  Result := TSdlMouseButton(FHandle.button - 1);
end;

function TSdlMouseButtonEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlMouseButtonEvent.GetMouse: TSdlMouse;
begin
  SDL_MouseID(Result) := FHandle.which;
end;

function TSdlMouseButtonEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlMouseButtonEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlMouseWheelEvent }

function TSdlMouseWheelEvent.GetAmount: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlMouseWheelEvent.GetDirection: TSdlMouseWheelDirection;
begin
  Result := TSdlMouseWheelDirection(FHandle.direction);
end;

function TSdlMouseWheelEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlMouseWheelEvent.GetMouse: TSdlMouse;
begin
  SDL_MouseID(Result) := FHandle.which;
end;

function TSdlMouseWheelEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.mouse_x, FHandle.mouse_y);
end;

function TSdlMouseWheelEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlJoyDeviceEvent }

function TSdlJoyDeviceEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlJoyDeviceEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlJoyDeviceEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlJoyAxisEvent }

function TSdlJoyAxisEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlJoyAxisEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlJoyAxisEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlJoyBallEvent }

function TSdlJoyBallEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlJoyBallEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlJoyBallEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlJoyBallEvent.GetRel: TSdlPointF;
begin
  Result.Init(FHandle.xrel, FHandle.yrel);
end;

{ TSdlJoyHatEvent }

function TSdlJoyHatEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlJoyHatEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlJoyHatEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlJoyHatEvent.GetValue: TSdlHat;
begin
  Result := TSdlHat(FHandle.value);
end;

{ TSdlJoyButtonEvent }

function TSdlJoyButtonEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlJoyButtonEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlJoyButtonEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlJoyBatteryEvent }

function TSdlJoyBatteryEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlJoyBatteryEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlJoyBatteryEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlJoyBatteryEvent.GetState: TSdlPowerState;
begin
  Result := TSdlPowerState(FHandle.state);
end;

{ TSdlGamepadDeviceEvent }

function TSdlGamepadDeviceEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlGamepadDeviceEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlGamepadDeviceEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlGamepadAxisEvent }

function TSdlGamepadAxisEvent.GetAxis: TSdlGamepadAxis;
begin
  Result := TSdlGamepadAxis(FHandle.axis);
end;

function TSdlGamepadAxisEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlGamepadAxisEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlGamepadAxisEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlGamepadButtonEvent }

function TSdlGamepadButtonEvent.GetButton: TSdlGamepadButton;
begin
  Result := TSdlGamepadButton(FHandle.button);
end;

function TSdlGamepadButtonEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlGamepadButtonEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlGamepadButtonEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlGamepadTouchpadEvent }

function TSdlGamepadTouchpadEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlGamepadTouchpadEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlGamepadTouchpadEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlGamepadTouchpadEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

{ TSdlGamepadSensorEvent }

function TSdlGamepadSensorEvent.GetData(const AIndex: Integer): Single;
begin
  Assert(Cardinal(AIndex) < Cardinal(Length(FHandle.data)));
  if (Cardinal(AIndex) < Cardinal(Length(FHandle.data))) then
    Result := FHandle.data[AIndex]
  else
    Result := 0;
end;

function TSdlGamepadSensorEvent.GetJoystick: TSdlJoystick;
begin
  THandle(Result) := SDL_GetJoystickFromID(FHandle.which);
end;

function TSdlGamepadSensorEvent.GetJoystickID: TSdlJoystickID;
begin
  SDL_JoystickID(Result) := FHandle.which;
end;

function TSdlGamepadSensorEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlGamepadSensorEvent.GetSensor: TSdlSensorKind;
begin
  Result := TSdlSensorKind(FHandle.sensor);
end;

{ TSdlAudioDeviceEvent }

function TSdlAudioDeviceEvent.GetAudioDevice: TSdlAudioDevice;
begin
  SDL_AudioDeviceID(Result) := FHandle.which;
end;

function TSdlAudioDeviceEvent.GetAudioDeviceID: TSdlAudioDeviceID;
begin
  SDL_AudioDeviceID(Result) := FHandle.which;
end;

function TSdlAudioDeviceEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlCameraDeviceEvent }

function TSdlCameraDeviceEvent.GetCameraID: TSdlCameraID;
begin
  SDL_CameraID(Result) := FHandle.which;
end;

function TSdlCameraDeviceEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlSensorEvent }

function TSdlSensorEvent.GetData(const AIndex: Integer): Single;
begin
  Assert(Cardinal(AIndex) < Cardinal(Length(FHandle.data)));
  if (Cardinal(AIndex) < Cardinal(Length(FHandle.data))) then
    Result := FHandle.data[AIndex]
  else
    Result := 0;
end;

function TSdlSensorEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlSensorEvent.GetSensorID: TSdlSensorID;
begin
  SDL_SensorID(Result) := FHandle.which;
end;

{ TSdlQuitEvent }

function TSdlQuitEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

{ TSdlUserEvent }

function TSdlUserEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlUserEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlTouchFingerEvent }

function TSdlTouchFingerEvent.GetDelta: TSdlPointF;
begin
  Result.Init(FHandle.dx, FHandle.dy);
end;

function TSdlTouchFingerEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlTouchFingerEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlTouchFingerEvent.GetTouch: TSdlTouch;
begin
  SDL_TouchID(Result) := FHandle.touchID;
end;

function TSdlTouchFingerEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlPenProximityEvent }

function TSdlPenProximityEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlPenProximityEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlPenTouchEvent }

function TSdlPenTouchEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlPenTouchEvent.GetPenState: TSdlPenInputFlags;
begin
  Cardinal(Result) := FHandle.pen_state;
end;

function TSdlPenTouchEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlPenTouchEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlPenMotionEvent }

function TSdlPenMotionEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlPenMotionEvent.GetPenState: TSdlPenInputFlags;
begin
  Cardinal(Result) := FHandle.pen_state;
end;

function TSdlPenMotionEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlPenMotionEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlPenButtonEvent }

function TSdlPenButtonEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlPenButtonEvent.GetPenState: TSdlPenInputFlags;
begin
  Cardinal(Result) := FHandle.pen_state;
end;

function TSdlPenButtonEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlPenButtonEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlPenAxisEvent }

function TSdlPenAxisEvent.GetAxis: TSdlPenAxis;
begin
  Result := TSdlPenAxis(FHandle.axis);
end;

function TSdlPenAxisEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlPenAxisEvent.GetPenState: TSdlPenInputFlags;
begin
  Cardinal(Result) := FHandle.pen_state;
end;

function TSdlPenAxisEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlPenAxisEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlRenderEvent }

function TSdlRenderEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlRenderEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlDropEvent }

function TSdlDropEvent.GetData: String;
begin
  Result := __ToString(FHandle.data);
end;

function TSdlDropEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlDropEvent.GetPosition: TSdlPointF;
begin
  Result.Init(FHandle.x, FHandle.y);
end;

function TSdlDropEvent.GetSource: String;
begin
  Result := __ToString(FHandle.source);
end;

function TSdlDropEvent.GetWindow: TSdlWindow;
begin
  THandle(Result) := SDL_GetWindowFromEvent(PSDL_Event(@FHandle));
end;

{ TSdlClipboardEvent }

function TSdlClipboardEvent.GetKind: TSdlEventKind;
begin
  Result := TSdlEventKind(FHandle.&type);
end;

function TSdlClipboardEvent.GetMimeTypes: TArray<String>;
begin
  SetLength(Result, FHandle.num_mime_types);
  var P := FHandle.mime_types;
  for var I := 0 to Length(Result) - 1 do
  begin
    Result[I] := __ToString(P^);
    Inc(P);
  end;
end;

{ TSdlEvent }

procedure TSdlEvent.ConvertToRenderCoordinates(const ARenderer: TSdlRenderer);
begin
  SdlCheck(SDL_ConvertEventToRenderCoordinates(THandle(ARenderer), @Self));
end;

{ TSdlEvents }

class function TSdlEvents.Has(const AKind: TSdlEventKind): Boolean;
begin
  Result := SDL_HasEvent(Ord(AKind));
end;

class procedure TSdlEvents.Flush(const AKind: TSdlEventKind);
begin
  SDL_FlushEvent(Ord(AKind));
end;

class procedure TSdlEvents.AddWatch(const AFilter: TSdlEventFilter);
begin
  if (not Assigned(AFilter)) then
    Exit;

  { Look for empty slot }
  for var I := 0 to MAX_WATCHES - 1 do
  begin
    { Use empty or reuse previously deleted watch }
    if (not Assigned(FWatches[I])) then
    begin
      FWatches[I] := AFilter;

      { Note: the value of @FWatches[I] will stay constant for this watch since
        watches don't shift in the array. }
      SdlCheck(SDL_AddEventWatch(EventWatch, @FWatches[I]));
      Exit;
    end;
  end;

  { No empty slot. }
  __HandleError('Too many event watches');
end;

class function TSdlEvents.EventFilter(AUserdata: Pointer;
  AEvent: PSDL_Event): Boolean;
begin
  Assert(Assigned(FFilter));
  Result := FFilter(PSdlEvent(AEvent)^);
end;

class function TSdlEvents.EventWatch(AUserdata: Pointer;
  AEvent: PSDL_Event): Boolean;
var
  Watch: PSdlEventFilter absolute AUserdata;
begin
  Assert(Assigned(AUserdata));
  Result := Watch^(PSdlEvent(AEvent)^);
end;

class procedure TSdlEvents.Filter(const AFilter: TSdlEventFilter);
begin
  var PrevFilter: TSdlEventFilter := FFilter;
  FFilter := AFilter;
  try
    SDL_FilterEvents(EventFilter, nil);
  finally
    FFilter := PrevFilter;
  end;
end;

class procedure TSdlEvents.Flush(const AMinKind, AMaxKind: TSdlEventKind);
begin
  SDL_FlushEvents(Ord(AMinKind), Ord(AMaxKind));
end;

class function TSdlEvents.GetFilter(out AFilter: TSdlEventFilter): Boolean;
begin
  var Filter: SDL_EventFilter := nil;
  var UserData: Pointer := nil;
  Result := SDL_GetEventFilter(@Filter, @UserData);
  if (Result) then
    AFilter := FFilter
  else
    AFilter := nil;
end;

class function TSdlEvents.Has(const AMinKind, AMaxKind: TSdlEventKind): Boolean;
begin
  Result := SDL_HasEvents(Ord(AMinKind), Ord(AMaxKind));
end;

class function TSdlEvents.IsEnabled(const AKind: TSdlEventKind): Boolean;
begin
  Result := SDL_EventEnabled(Ord(AKind));
end;

class function TSdlEvents.Peep(const AEvents: PSdlEvent;
  const ANumEvents: Integer; const AAction: TSdlEventAction; const AMinKind,
  AMaxKind: TSdlEventKind): Integer;
begin
  Result := SDL_PeepEvents(Pointer(AEvents), ANumEvents, Ord(AAction),
    Ord(AMinKind), Ord(AMaxKind));
  if (Result < 0) then
    __HandleError;
end;

class function TSdlEvents.Poll(out AEvent: TSdlEvent): Boolean;
begin
  Result := SDL_PollEvent(@AEvent);
end;

class function TSdlEvents.Poll: Boolean;
begin
  Result := SDL_PollEvent(nil);
end;

class function TSdlEvents.Peep(const AEvents: TArray<TSdlEvent>;
  const AAction: TSdlEventAction; const AMinKind,
  AMaxKind: TSdlEventKind): Integer;
begin
  Result := SDL_PeepEvents(Pointer(AEvents), Length(AEvents), Ord(AAction),
    Ord(AMinKind), Ord(AMaxKind));
  if (Result < 0) then
    __HandleError;
end;

class procedure TSdlEvents.Pump;
begin
  SDL_PumpEvents;
end;

class function TSdlEvents.Push(const AEvent: TSdlEvent): Boolean;
begin
  SDL_ClearError;
  Result := SDL_PushEvent(@AEvent);
  if (not Result) then
  begin
    var Error := __ToString(SDL_GetError);
    if (Error <> '') then
      __HandleError(Error);
  end;
end;

class function TSdlEvents.Register: TSdlEventKind;
begin
  Result := TSdlEventKind(SDL_RegisterEvents(1));
end;

class procedure TSdlEvents.RemoveWatch(const AFilter: TSdlEventFilter);
begin
  if (not Assigned(AFilter)) then
    Exit;

  for var I := 0 to MAX_WATCHES - 1 do
  begin
    if (@AFilter = @FWatches[I]) then
    begin
      FWatches[I] := nil;

      { Note: even though we share the global EventWatch function for all
        watches, SDL_RemoveEventWatch will only delete a Filter/UserData pair
        (both have to match). }
      SDL_RemoveEventWatch(EventWatch, @FWatches[I]);
      Exit;
    end;
  end;
end;

class procedure TSdlEvents.SetEnabled(const AKind: TSdlEventKind;
  const AEnabled: Boolean);
begin
  SDL_SetEventEnabled(Ord(AKind), AEnabled);
end;

class procedure TSdlEvents.SetFilter(const AFilter: TSdlEventFilter);
begin
  FFilter := AFilter;
  if Assigned(AFilter) then
    SDL_SetEventFilter(EventFilter, nil)
  else
    SDL_SetEventFilter(nil, nil);
end;

class function TSdlEvents.Wait(const ATimeoutMS: Integer;
  out AEvent: TSdlEvent): Boolean;
begin
  Result := SDL_WaitEventTimeout(@AEvent, ATimeoutMS);
end;

class function TSdlEvents.Wait(const ATimeoutMS: Integer): Boolean;
begin
  Result := SDL_WaitEventTimeout(nil, ATimeoutMS);
end;

class procedure TSdlEvents.Wait(out AEvent: TSdlEvent);
begin
  SdlCheck(SDL_WaitEvent(@AEvent));
end;

class procedure TSdlEvents.Wait;
begin
  SdlCheck(SDL_WaitEvent(nil));
end;

end.
