unit Neslib.Sdl3.Basics;

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
  System.SysUtils,
  System.Generics.Collections,
  Neslib.Sdl3.Api;

{$REGION 'Version Information'}
type
  /// <summary>
  ///  Information about the version of SDL in use.
  ///
  ///  Represents the library's version as three levels: major revision
  ///  (increments with massive changes, additions, and enhancements), minor
  ///  revision (increments with backwards-compatible changes to the major
  ///  revision), and patchlevel (increments with fixes to the minor revision).
  /// </summary>
  TSdlVersion = record
  {$REGION 'Internal Declarations'}
  private
    FMajor: Byte;
    FMinor: Byte;
    FPatch: Byte;
    class function GetCompiledVersion: TSdlVersion; inline; static;
    class function GetRuntimeVersion: TSdlVersion; inline; static;
    class function GetRevision: String; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Creates a version instance.
    /// </summary>
    /// <param name="AMajor">The major version number.</param>
    /// <param name="AMinor">(optional) Minor version number.</param>
    /// <param name="APatch">(optional) Patch level.</param>
    constructor Create(const AMajor: Byte; const AMinor: Byte = 0;
      const APatch: Byte = 0);

    /// <summary>
    ///  Checks whether the program was compiled against a version of SDL with
    ///  at least the given version number.
    /// </summary>
    /// <param name="AMajor">Major version to check against.</param>
    /// <param name="AMinor">(optional) Minor version to check against.</param>
    /// <param name="APatch">(optional) Patch level to check against.</param>
    /// <returns>True if the program was compiled with at least SDL version
    ///  AMajor.AMinor.APatch</returns>
    class function AtLeast(const AMajor: Byte; const AMinor: Byte = 0;
      const APatch: Byte = 0): Boolean; inline; static;

    /// <summary>
    ///  Turns this version numbers into a numeric value.
    ///
    ///  (1,2,3) becomes 1002003.
    /// </summary>
    function ToNumber: Integer; inline;

    /// <summary>
    ///  Creates a version from a numeric value.
    ///
    ///  Turns 1002003 into (1,2,3)
    /// </summary>
    class function FromNumber(const ANumber: Integer): TSdlVersion; inline; static;

    /// <summary>
    ///  The current major version of SDL headers.
    ///
    ///  If this were SDL version 3.2.1, this value would be 3.
    /// </summary>
    property Major: Byte read FMajor;

    /// <summary>
    ///  The current minor version of the SDL headers.
    ///
    ///  If this were SDL version 3.2.1, this value would be 2.
    /// </summary>
    property Minor: Byte read FMinor;

    /// <summary>
    ///  The current micro (or patchlevel) version of the SDL headers.
    ///
    ///  If this were SDL version 3.2.1, this value would be 1.
    /// </summary>
    property Patch: Byte read FPatch;

    /// <summary>
    ///  The SDL version the program was compiled against.
    ///
    ///  Note that if you dynamically linked the library, you might have a
    ///  slightly newer or older version at runtime. That version can be
    ///  determined with RuntimeVersion.
    /// </summary>
    class property CompiledVersion: TSdlVersion read GetCompiledVersion;

    /// <summary>
    ///  The version of SDL that is linked against your program.
    ///
    ///  If you are linking to SDL dynamically, then it is possible that the
    ///  current version will be different than the version you compiled
    ///  (see CompiledVersion) against.
    ///
    ///  This property may be called safely at any time, even before SdlInit.
    /// </summary>
    class property RuntimeVersion: TSdlVersion read GetRuntimeVersion;

    /// <summary>
    ///  Get the code revision of SDL that is linked against your program.
    ///
    ///  This value is the revision of the code you are linked with and may be
    ///  different from the code you are compiling with.
    ///
    ///  The revision is arbitrary string (a hash value) uniquely identifying the
    ///  exact revision of the SDL library in use, and is only useful in comparing
    ///  against other revisions. It is NOT an incrementing number.
    ///
    ///  If SDL wasn't built from a git repository with the appropriate tools, this
    ///  will return an empty string.
    ///
    ///  You shouldn't use this property for anything but logging it for debugging
    ///  purposes. The string is not intended to be reliable in any way.
    /// </summary>
    class property Revision: String read GetRevision;
  end;
{$ENDREGION 'Version Information'}

{$REGION 'Error Handling'}
type
  /// <summary>
  ///  Exception type for SDL errors.
  ///
  ///  When an underlying C-API SDL API returns an error code, an exception
  ///  of this type will be raised. The exception message is provided by the
  ///  underlying SDL library.
  ///
  ///  When a wrapped API can raise an exception, this is mentioned in the API's
  ///  documentation.
  /// </summary>
  /// <seealso cref="TSdlApp.HandleError"/>
  /// <remarks>
  ///  Is used to raise the last error that occurred on the current thread.
  ///
  ///  It is possible for multiple errors to occur. Only the last error is
  ///  raised.
  ///
  ///  SDL Exceptions can be disabled by overriding TSdlApp.HandleError.
  /// </remarks>
  ESdlError = class(Exception);

/// <summary>
///  Checks if an SDL API succeeded.
/// </summary>
/// <param name="ASdlResult">The Boolean result of an SDL API.</param>
/// <returns>ASdlResult.</returns>
/// <remarks>
///  If this method returns False, then TSdlApp.HandleError will be called.
/// </remarks>
function SdlSucceeded(const ASdlResult: Boolean): Boolean; overload; inline;

/// <summary>
///  Checks if an SDL API succeeded.
/// </summary>
/// <param name="ASdlResult">The Pointer result of an SDL API.</param>
/// <returns>True of ASdlResult is assigned, False if it is nil.</returns>
/// <remarks>
///  If this method returns False, then TSdlApp.HandleError will be called.
/// </remarks>
function SdlSucceeded(const ASdlResult: Pointer): Boolean; overload; inline;

/// <summary>
///  Checks if an SDL API succeeded.
/// </summary>
/// <param name="ASdlResult">The THandle result of an SDL API.</param>
/// <returns>True of ASdlResult<>0, False if it is 0.</returns>
/// <remarks>
///  If this method returns False, then TSdlApp.HandleError will be called.
/// </remarks>
function SdlSucceeded(const ASdlResult: THandle): Boolean; overload; inline;

/// <summary>
///  Checks if an SDL API failed.
/// </summary>
/// <param name="ASdlResult">The Boolean result of an SDL API.</param>
/// <returns>True if ASdlResult=False, False if ASdlResult=True.</returns>
/// <remarks>
///  If this method returns True, then TSdlApp.HandleError will be called.
/// </remarks>
function SdlFailed(const ASdlResult: Boolean): Boolean; overload; inline;

/// <summary>
///  Checks if an SDL API failed.
/// </summary>
/// <param name="ASdlResult">The Pointer result of an SDL API.</param>
/// <returns>True if ASdlResult=nil, False if ASdlResult<>nil.</returns>
/// <remarks>
///  If this method returns True, then TSdlApp.HandleError will be called.
/// </remarks>
function SdlFailed(const ASdlResult: Pointer): Boolean; overload; inline;

/// <summary>
///  Checks if an SDL API failed.
/// </summary>
/// <param name="ASdlResult">The THandle result of an SDL API.</param>
/// <returns>True if ASdlResult=0, False if ASdlResult<>0.</returns>
/// <remarks>
///  If this method returns True, then TSdlApp.HandleError will be called.
/// </remarks>
function SdlFailed(const ASdlResult: THandle): Boolean; overload; inline;

/// <summary>
///  Checks the result of an SDL API.
/// </summary>
/// <param name="ASdlResult">The Boolean result of an SDL API.</param>
/// <remarks>
///  If ASdlResult=False, then TSdlApp.HandleError will be called.
/// </remarks>
procedure SdlCheck(const ASdlResult: Boolean); overload; inline;

/// <summary>
///  Checks the result of an SDL API.
/// </summary>
/// <param name="ASdlResult">The Pointer result of an SDL API.</param>
/// <remarks>
///  If ASdlResult=nil, then TSdlApp.HandleError will be called.
/// </remarks>
procedure SdlCheck(const ASdlResult: Pointer); overload; inline;

/// <summary>
///  Checks the result of an SDL API.
/// </summary>
/// <param name="ASdlResult">The Pointer result of an SDL API.</param>
/// <remarks>
///  If ASdlResult=0, then TSdlApp.HandleError will be called.
/// </remarks>
procedure SdlCheck(const ASdlResult: THandle); overload; inline;
{$ENDREGION 'Error Handling'}

{$REGION 'Initialization and Shutdown'}
type
  /// <summary>
  ///  Initialization flags for SdlInit and/or SdlInitSubSystem.
  ///
  ///  These are the flags which may be passed to SdlInit. You should specify
  ///  the subsystems which you will be using in your application.
  /// </summary>
  /// <seealso cref="SdlInit"/>
  /// <seealso cref="SdlQuit"/>
  /// <seealso cref="SdlInitSubSystem"/>
  /// <seealso cref="SdlQuitSubSystem"/>
  /// <seealso cref="SdlWasInit"/>
  TSdlInitFlag = (
    /// <summary>
    ///  The audio subsystem. Implies TSdlInitFlag.Events.
    ///
    ///  Enables the functionality in the Neslib.Sdl3.Audio unit.
    /// </summary>
    Audio    = 4,

    /// <summary>
    ///  The video subsystem. Implies TSdlInitFlag.Events.
    ///  Should be initialized on the main thread.
    ///
    ///  Enables the functionality in the Neslib.Sdl3.Video unit.
    /// </summary>
    Video    = 5,

    /// <summary>
    ///  The joystick subsystem. Implies TSdlInitFlag.Events.
    ///  Should be initialized on the same thread as TSdlInitFlag.Video on
    ///  Windows if you don't set TSdlHints.JoystickThread.
    ///
    ///  Enables the joystick functionality in the Neslib.Sdl3.Events unit.
    /// </summary>
    Joystick = 9,

    /// <summary>
    ///  The haptick (force feedback) subsystem.
    /// </summary>
    Haptick  = 12,

    /// <summary>
    ///  The gamepad subsystem. Implies TSdlInitFlag.Joystick.
    ///
    ///  Enables the gamepad functionality in the Neslib.Sdl3.Events unit.
    /// </summary>
    Gamepad  = 13,

    /// <summary>
    ///  The events subsystem.
    ///
    ///  Enables the functionality in the Neslib.Sdl3.Events unit.
    /// </summary>
    Events   = 14,

    /// <summary>
    ///  The sensor subsystem. Implies TSdlInitFlag.Events.
    ///
    ///  Enables the sensor functionality in the Neslib.Sdl3.Events unit.
    /// </summary>
    Sensor   = 15,

    /// <summary>
    ///  The camera subsystem. Implies TSdlInitFlag.Events.
    ///
    ///  Enables the functionality in the Neslib.Sdl3.Camera and
    ///  Neslib.Sdl3.Events units.
    /// </summary>
    Camera   = 16);

  /// <summary>
  ///  A set of initialization flags for SdlInit and/or SdlInitSubSystem.
  /// </summary>
  TSdlInitFlags = set of TSdlInitFlag;

/// <summary>
///  Initialize the SDL library.
///
///  Init simply forwards to calling InitSubSystem. Therefore, the two may
///  be used interchangeably. Though for readability of your code
///  InitSubSystem might be preferred.
///
///  The file I/O and threading subsystems are initialized by default.
///  Message boxes also attempt to work without initializing the video
///  subsystem, in hopes of being useful in showing an error dialog when
///  Init fails. You must specifically initialize other subsystems if you
///  use them in your application.
///
///  Logging works without initialization, too.
///
///  AFlags may be zero or more of the following:
///
///  - `TSdlInitFlag.Audio`: audio subsystem; automatically initializes the
///    events subsystem.
///  - `TSdlInitFlag.Video`: video subsystem; automatically initializes the
///    events subsystem, should be initialized on the main thread.
///  - `TSdlInitFlag.Joystick`: joystick subsystem; automatically
///    initializes the events subsystem
///  - `TSdlInitFlag.Haptic`: haptic (force feedback) subsystem
///  - `TSdlInitFlag.Gamepad`: gamepad subsystem; automatically initializes
///    the joystick subsystem
///  - `TSdlInitFlag.Events`: events subsystem
///  - `TSdlInitFlag.Sensor`: sensor subsystem; automatically initializes
///    the events subsystem
///  - `TSdlInitFlag.Camera`: camera subsystem; automatically initializes
///    the events subsystem
///
///  Subsystem initialization is ref-counted, you must call QuitSubSystem
///  for each InitSubSystem to correctly shutdown a subsystem manually (or
///  call Quit to force shutdown). If a subsystem is already loaded then
///  this call will increase the ref-count and return.
///
///  Consider reporting some basic metadata about your application before
///  calling Init, using SdlSetAppMetadata.
/// </summary>
/// <param name="AFlags">Subsystem initialization flags.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlSetAppMetadata"/>
/// <seealso cref="SdlInitSubSystem"/>
/// <seealso cref="SdlQuit"/>
/// <seealso cref="SdlWasInit"/>
procedure SdlInit(const AFlags: TSdlInitFlags); inline;

/// <summary>
///  Compatibility function to initialize the SDL library.
///
///  This routine and SdlInit are interchangeable.
/// </summary>
/// <param name="AFlags">Any of the flags used by SdlInit; see SdlInit for details.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlInit"/>
/// <seealso cref="SdlQuit"/>
/// <seealso cref="SdlQuitSubSystem"/>
procedure SdlInitSubSystem(const AFlags: TSdlInitFlags); inline;

/// <summary>
///  Shut down specific SDL subsystems.
///
///  You still need to call SdlQuit even if you close all open subsystems
///  with SdlQuitSubSystem.
/// </summary>
/// <param name="AFlags">Any of the flags used by SdlInit; see SdlInit for details.</param>
/// <seealso cref="SdlInitSubSystem"/>
/// <seealso cref="SdlQuit"/>
procedure SdlQuitSubSystem(const AFlags: TSdlInitFlags); inline;

/// <summary>
///  Clean up all initialized subsystems.
///
///  You should call this function even if you have already shutdown each
///  initialized subsystem with SdlQuitSubSystem. It is safe to call this
///  function even in the case of errors in initialization.
///
///  You can use this function with atexit() to ensure that it is run when your
///  application is shutdown, but it is not wise to do this from a library or
///  other dynamically loaded code.
/// </summary>
/// <seealso cref="SdlInit"/>
/// <seealso cref="SdlQuitSubSystem"/>
procedure SdlQuit; inline;

/// <summary>
///  Get the specified subsystems which are currently initialized.
/// </summary>
/// <param name="AFlags">(Optional) flags used by SdlInit; see SdlInit for details.</param>
/// <returns>All initialized subsystems if `AFlags` is [], otherwise it returns
///  the initialization status of the specified subsystems.</returns>
/// <seealso cref="SdlInit"/>
/// <seealso cref="SdlInitSubSystem"/>
function SdlWasInit(const AFlags: TSdlInitFlags = []): TSdlInitFlags; inline;

/// <summary>
///  Return whether this is the main thread.
///
///  On Apple platforms, the main thread is the thread that runs your program's
///  entry point. On other platforms, the main thread is the one that calls
///  SdlInit([TSdlInitFlag.Video]), which should usually be the one that runs
///  your program's entry point.
/// </summary>
/// <returns>True if this thread is the main thread, or False otherwise.</returns>
/// <seealso cref="SdlRunOnMainThread"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlIsMainThread: Boolean; inline;

type
  /// <summary>
  ///  Callback run on the main thread.
  /// </summary>
  /// <seealso cref="SdlRunOnMainThread"/>
  TSdlMainThreadCallback = procedure of object;

/// <summary>
///  Call a function on the main thread during event processing.
///
///  If this is called on the main thread, the callback is executed immediately.
///  If this is called on another thread, this callback is queued for execution
///  on the main thread during event processing.
///
///  Be careful of deadlocks when using this functionality. You should not have
///  the main thread wait for the current thread while this function is being
///  called with `AWaitComplete` true.
/// </summary>
/// <param name="ACallback">The callback to call on the main thread.</param>
/// <param name="AWaitComplete">(Optional) True to wait for the callback to complete,
///  False (default) to return immediately.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlIsMainThread"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
procedure SdlRunOnMainThread(const ACallback: TSdlMainThreadCallback;
  const AWaitComplete: Boolean = False);

/// <summary>
///  Specify basic metadata about your app.
///
///  You can optionally provide metadata about your app to SDL. This is not
///  required, but strongly encouraged.
///
///  There are several locations where SDL can make use of metadata (an "About"
///  box in the macOS menu bar, the name of the app can be shown on some audio
///  mixers, etc). Any piece of metadata can be left empty, if a specific
///  detail doesn't make sense for the app.
///
///  This function should be called as early as possible, before Init.
///  Multiple calls to this function are allowed, but various state might not
///  change once it has been set up with a previous call to this function.
///
///  Passing an empty string removes any previous metadata.
///
///  This is a simplified interface for the most important information. You can
///  supply significantly more detailed metadata with
///  SetAppMetadataProperty.
/// </summary>
/// <param name="AAppName">The name of the application
///  ('My Game 2: Bad Guy's Revenge!').</param>
/// <param name="AAppVersion">The version of the application
///  ('1.0.0beta5' or a git hash, or whatever makes sense).</param>
/// <param name="AAppIdentifier">A unique string in reverse-domain format
///  that identifies this app ('com.example.mygame2').</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlGetAppMetadata"/>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlSetAppMetadata(const AAppName, AAppVersion, AAppIdentifier: String); overload; inline;

/// <summary>
///  Specify metadata about your app through a set of properties.
///
///  You can optionally provide metadata about your app to SDL. This is not
///  required, but strongly encouraged.
///
///  There are several locations where SDL can make use of metadata (an "About"
///  box in the macOS menu bar, the name of the app can be shown on some audio
///  mixers, etc). Any piece of metadata can be left out, if a specific detail
///  doesn't make sense for the app.
///
///  This routine should be called as early as possible, before SdlInit.
///  Multiple calls to this routine are allowed, but various state might not
///  change once it has been set up with a previous call to this routine.
///
///  Once set, this metadata can be read using SdlGetAppMetadata.
///
///  These are the supported properties:
///
///  - `TSdlProperty.AppMetadataName`: The human-readable name of the
///    application, like 'My Game 2: Bad Guy's Revenge!'. This will show up
///    anywhere the OS shows the name of the application separately from window
///    titles, such as volume control applets, etc. This defaults to 'SDL
///    Application'.
///  - `TSdlProperty.AppMetadataVersion`: The version of the app that is
///    running; there are no rules on format, so '1.0.3beta2' and 'April 22nd,
///    2024' and a git hash are all valid options. This has no default.
///  - `TSdlProperty.AppMetadataIdentifier`: A unique string that
///    identifies this app. This must be in reverse-domain format, like
///    'com.example.mygame2'. This string is used by desktop compositors to
///    identify and group windows together, as well as match applications with
///    associated desktop settings and icons. If you plan to package your
///    application in a container such as Flatpak, the app ID should match the
///    name of your Flatpak container as well. This has no default.
///  - `TSdlProperty.AppMetadataCreator`: The human-readable name of the
///    creator/developer/maker of this app, like 'MojoWorkshop, LLC'
///  - `TSdlProperty.AppMetadataCopyright`: The human-readable copyright
///    notice, like 'Copyright (c) 2025 MojoWorkshop, LLC' or whatnot. Keep this
///    to one line, don't paste a copy of a whole software license in here. This
///    has no default.
///  - `TSdlProperty.AppMetadataUrl`: A URL to the app on the web. Maybe a
///    product page, or a storefront, or even a GitHub repository, for user's
///    further information This has no default.
///  - `TSdlProperty.AppMetadataType`: The type of application this is.
///    Currently this string can be 'game' for a video game, 'mediaplayer' for a
///    media player, or generically 'application' if nothing else applies.
///    Future versions of SDL might add new types. This defaults to
///    'application'.
/// </summary>
/// <param name="AName">The name of the metadata property to set.</param>
/// <param name="AValue">The value of the property, or an empty string to remove
///  that property.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlGetAppMetadata"/>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlSetAppMetadata(const AName, AValue: String); overload; inline;

/// <summary>
///  Get metadata about your app.
///
///  This returns metadata previously set using SdlSetAppMetadata.
///  See SdlSetAppMetadata for the list of available properties and their meanings.
/// </summary>
/// <param name="AName">The name of the metadata property to get.</param>
/// <returns>The current value of the metadata property, the default if it is
///  not set, or an empty string for properties with no default.</returns>
/// <seealso cref="SdlSetAppMetadata"/>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
function SdlGetAppMetadata(const AName: String): String; inline;
{$ENDREGION 'Initialization and Shutdown'}

{$REGION 'Log Handling'}
/// <summary>
///  Simple log messages with priorities and categories. A message's
///  TSdlLogPriority signifies how important the message is. A message's
///  TSdlLogCategory signifies from what domain it belongs to. Every category
///  has a minimum priority specified: when a message belongs to that category,
///  it will only be sent out if it has that minimum priority or higher.
///
///  SDL's own logs are sent below the default priority threshold, so they are
///  quiet by default.
///
///  You can change the log verbosity programmatically using
///  SdlSetLogPriority or with TSdlHints.Logging, or with the "SDL_LOGGING"
///  environment variable. This variable is a comma separated set of
///  category=level tokens that define the default logging levels for SDL
///  applications.
///
///  The category can be a numeric category, one of 'app', 'error', 'assert',
///  'system', 'audio', 'video', 'render', 'input', 'test', or `*` for any
///  unspecified category.
///
///  The level can be a numeric level, one of 'verbose', 'debug', 'info',
///  'warn', 'error', 'critical', or 'quiet' to disable that category.
///
///  You can omit the category if you want to set the logging level for all
///  categories.
///
///  If this hint isn't set, the default log levels are equivalent to:
///
///  `app=info,assert=warn,test=verbose,*=error`
///
///  Here's where the messages go on different platforms:
///
///  - Windows: debug output stream
///  - Android: log output
///  - Others: standard error output (stderr)
///
///  The predefined log categories
///
///  By default the Application and Gpu categories are enabled at the Info
///  level, the Assert category is enabled at the Warn level, Test is enabled at
///  the Verbose level and all other categories are enabled at the Error level.
/// </summary>

type
  /// <summary>
  ///  The predefined log categories
  ///
  ///  By default the Application and Gpu categories are enabled at the Info
  ///  level, the Assert category is enabled at the Warn level, Test is enabled at
  ///  the Verbose level and all other categories are enabled at the Error level.
  /// </summary>
  TSdlLogCategory = (
    Application = SDL_LOG_CATEGORY_APPLICATION,
    Error       = SDL_LOG_CATEGORY_ERROR,
    Assert      = SDL_LOG_CATEGORY_ASSERT,
    System      = SDL_LOG_CATEGORY_SYSTEM,
    Audio       = SDL_LOG_CATEGORY_AUDIO,
    Video       = SDL_LOG_CATEGORY_VIDEO,
    Render      = SDL_LOG_CATEGORY_RENDER,
    Input       = SDL_LOG_CATEGORY_INPUT,
    Test        = SDL_LOG_CATEGORY_TEST,
    Gpu         = SDL_LOG_CATEGORY_GPU,
    Custom      = SDL_LOG_CATEGORY_CUSTOM);

type
  /// <summary>
  ///  The predefined log priorities
  /// </summary>
  TSdlLogPriority = (
    Invalid  = SDL_LOG_PRIORITY_INVALID,
    Trace    = SDL_LOG_PRIORITY_TRACE,
    Verbose  = SDL_LOG_PRIORITY_VERBOSE,
    Debug    = SDL_LOG_PRIORITY_DEBUG,
    Info     = SDL_LOG_PRIORITY_INFO,
    Warn     = SDL_LOG_PRIORITY_WARN,
    Error    = SDL_LOG_PRIORITY_ERROR,
    Critical = SDL_LOG_PRIORITY_CRITICAL);

type
  /// <summary>
  ///  The prototype for the log output callback function.
  ///
  ///  This function is called by SDL when there is new text to be logged. A mutex
  ///  is held so that this function is never called by more than one thread at
  ///  once.
  /// </summary>
  /// <param name="ACategory">The category of the message.</param>
  /// <param name="APriority">The priority of the message.</param>
  /// <param name="AMessage">The message being output.</param>
  TSdlLogOutputFunction = procedure(const ACategory: TSdlLogCategory;
    const APriority: TSdlLogPriority; const AMessage: String) of object;

type
  /// <summary>
  ///  Logging functionality.
  /// </summary>
  TSdlLog = record
  {$REGION 'Internal Declarations'}
  private class var
    FPriorities: array [TSdlLogCategory] of TSdlLogPriority;
    FCustomOutputFunction: TSdlLogOutputFunction;
    FDefaultOutputFunction: SDL_LogOutputFunction;
  private
    class function GetPriority(
      const ACategory: TSdlLogCategory): TSdlLogPriority; static;
    class procedure SetPriority(const ACategory: TSdlLogCategory;
      const AValue: TSdlLogPriority); static;
    class procedure SetCustomOutputFunction(const AValue: TSdlLogOutputFunction); static;
  private
    class procedure RetrievePriorities; static;
    class procedure OutputFunction(AUserData: Pointer; ACategory: Integer;
      APriority: SDL_LogPriority; const AMessage: PUTF8Char); cdecl; static;
  public
    class constructor Create;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Log a message with TSdlLogCategory.Application and TSdlLogPriority.Info.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Info(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogCategory.Application and TSdlLogPriority.Info.
    /// </summary>
    /// <param name="AMessage">The message with format specifiers.</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Info(const AMessage: String; const AArgs: array of const;
     const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Trace.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Trace(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Trace.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Trace(const AMessage: String; const AArgs: array of const;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Verbose.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Verbose(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Verbose.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Verbose(const AMessage: String; const AArgs: array of const;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Debug.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Debug(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Debug.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Debug(const AMessage: String; const AArgs: array of const;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Warn.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Warn(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Warn.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Warn(const AMessage: String; const AArgs: array of const;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Error.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Error(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Error.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Error(const AMessage: String; const AArgs: array of const;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Critical.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Critical(const AMessage: String;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; inline; static;

    /// <summary>
    ///  Log a message with TSdlLogPriority.Critical.
    /// </summary>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <param name="ACategory">(Optional) category. Defaults to Application.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Critical(const AMessage: String; const AArgs: array of const;
      const ACategory: TSdlLogCategory = TSdlLogCategory.Application); overload; static;

    /// <summary>
    ///  Log a message with the specified category and priority.
    /// </summary>
    /// <param name="ACategory">The category of the message.</param>
    /// <param name="APriority">The priority of the message.</param>
    /// <param name="AMessage">The message</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Message(const ACategory: TSdlLogCategory;
      const APriority: TSdlLogPriority; const AMessage: String); overload; inline; static;

    /// <summary>
    ///  Log a message with the specified category and priority.
    /// </summary>
    /// <param name="ACategory">The category of the message.</param>
    /// <param name="APriority">The priority of the message.</param>
    /// <param name="AMessage">The message</param>
    /// <param name="AArgs">Additional arguments matching the format specifiers.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Message(const ACategory: TSdlLogCategory;
      const APriority: TSdlLogPriority; const AMessage: String;
      const AArgs: array of const); overload; static;

    /// <summary>
    ///  Set the priority of all log categories.
    /// </summary>
    /// <param name="APriority">The TSdlLogPriority to assign.</param>
    /// <seealso cref="ResetPriorities"/>
    /// <seealso cref="Priorities"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure SetAllPriorities(const APriority: TSdlLogPriority); static;

    /// <summary>
    ///  Reset all priorities to default.
    ///
    ///  This is called by SdlQuit.
    /// </summary>
    /// <seealso cref="SetAllPriorities"/>
    /// <seealso cref="Priorities"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure ResetPriorities; static;

    /// <summary>
    ///  Set the text prepended to log messages of a given priority.
    ///
    ///  By default TSdlLogPriority.Info and below have no prefix, and
    ///  TSdlLogPriority.Warn and higher have a prefix showing their priority,
    ///  e.g. 'WARNING: '.
    /// </summary>
    /// <param name="APriority">The TSdlLogPriority to modify.</param>
    /// <param name="APrefix">The prefix to use for that log priority, or
    ///  an empty string to use no prefix.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetAllPriorities"/>
    /// <seealso cref="Priorities"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure SetPriorityPrefix(const APriority: TSdlLogPriority;
      const APrefix: String); static;

    /// <summary>
    ///  The priorities of log categories.
    /// </summary>
    /// <param name="ACategory">The log category.</param>
    /// <seealso cref="ResetPriorities"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property Priorities[const ACategory: TSdlLogCategory]: TSdlLogPriority read GetPriority write SetPriority;

    /// <summary>
    ///  A custom log output function, or nil to use the default log function.
    ///
    ///  Note that using a custom log output function can impact performance,
    ///  especially when a lot of messages are logged (for example, when using
    ///  a log log priority).
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property CustomOutputFunction: TSdlLogOutputFunction read FCustomOutputFunction write SetCustomOutputFunction;
  end;
{$ENDREGION 'Log Handling'}

{$REGION 'Hints'}
/// <summary>
///  This section contains methods to set and get configuration hints, as well as
///  listing each of them alphabetically.
///
///  In general these hints are just that - they may or may not be supported or
///  applicable on any given platform, but they provide a way for an application
///  or user to give the library a hint as to how they would like the library to
///  work.
/// </summary>

type
  /// <summary>
  ///  An enumeration of hint priorities.
  /// </summary>
  TSdlHintPriority = (
    Default  = SDL_HINT_DEFAULT,
    Normal   = SDL_HINT_NORMAL,
    Override = SDL_HINT_OVERRIDE);

type
  /// <summary>
  ///  A callback used to send notifications of hint value changes.
  ///
  ///  This is called an initial time during SDL_AddHintCallback with the hint's
  ///  current value, and then again each time the hint's value changes.
  /// </summary>
  /// <param name="AName">What was passed as `AName` to TSdlHints.AddCallback
  ///  (one of the TSdlHints constants).</param>
  /// <param name="AOldValue">The previous hint value.</param>
  /// <param name="ANewValue">The new value hint is to be set to.</param>
  /// <seealso cref="TSdlHints.AddCallback"/>
  /// <remarks>
  ///  This callback is fired from whatever thread is setting a new hint value.
  ///  SDL holds a lock on the hint subsystem when calling this callback.
  /// </remarks>
  TSdlHintCallback = procedure(const AName, AOldValue, ANewValue: String) of object;

type
  /// <summary>
  ///  Lists and manages hints.
  /// </summary>
  TSdlHints = record
  {$REGION 'Internal Declarations'}
  private type
    TCallback = class
    public
      Value: TSdlHintCallback;
    end;
  private type
    TCallbacks = TObjectList<TCallback>;
  private class var
    FCallbacks: TObjectDictionary<AnsiString, TCallbacks>;
    class procedure HintCallback(AUserData: Pointer; const AName, AOldValue,
      ANewValue: PUTF8Char); cdecl; static;
  private
    class function GetHint(const AName: PUTF8Char): String; inline; static;
    class procedure SetHint(const AName: PUTF8Char; const AValue: String); inline; static;
  public
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public const
    /// <summary>
    ///  Specify the behavior of Alt+Tab while the keyboard is grabbed.
    ///
    ///  By default, SDL emulates Alt+Tab functionality while the keyboard is
    ///  grabbed and your window is full-screen. This prevents the user from getting
    ///  stuck in your application if you've enabled keyboard grab.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': SDL will not handle Alt+Tab. Your application is responsible for
    ///    handling Alt+Tab while the keyboard is grabbed.
    ///  - '1': SDL will minimize your window when Alt+Tab is pressed (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AllowTabWhileGrabbed = SDL_HINT_ALLOW_ALT_TAB_WHILE_GRABBED;

    /// <summary>
    ///  A variable to control whether the SDL activity is allowed to be re-created.
    ///
    ///  If this hint is true, the activity can be recreated on demand by the OS,
    ///  and Java static data and C++ static data remain with their current values.
    ///  If this hint is false, then SDL will call Halt when you return from your
    ///  main function and the application will be terminated and then started fresh
    ///  each time.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The application starts fresh at each launch. (default)
    ///  - '1': The application activity can be recreated by the OS.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AndroidAllowRecreateActivity = SDL_HINT_ANDROID_ALLOW_RECREATE_ACTIVITY;

    /// <summary>
    ///  A variable to control whether the event loop will block itself when the app
    ///  is paused.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Non blocking.
    ///  - '1': Blocking. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    AndroidBlockOnPause = SDL_HINT_ANDROID_BLOCK_ON_PAUSE;

    /// <summary>
    ///  A variable to control whether low latency audio should be enabled.
    ///
    ///  Some devices have poor quality output when this is enabled, but this is
    ///  usually an improvement in audio latency.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Low latency audio is not enabled.
    ///  - '1': Low latency audio is enabled. (default)
    ///
    ///  This hint should be set before SDL audio is initialized.
    /// </summary>
    AndroidLowLatencyAudio = SDL_HINT_ANDROID_LOW_LATENCY_AUDIO;

    /// <summary>
    ///  A variable to control whether we trap the Android back button to handle it
    ///  manually.
    ///
    ///  This is necessary for the right mouse button to work on some Android
    ///  devices, or to be able to trap the back button for use in your code
    ///  reliably. If this hint is true, the back button will show up as an
    ///  TSdlEventKind.KeyDown / TSdlEventKind.KeyUp pair with a keycode of
    ///  TSdlScancode.ACBack.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Back button will be handled as usual for system. (default)
    ///  - '1': Back button will be trapped, allowing you to handle the key press
    ///    manually. (This will also let right mouse click work on systems where the
    ///    right mouse button functions as back.)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AndroidTrapBackButton = SDL_HINT_ANDROID_TRAP_BACK_BUTTON;

    /// <summary>
    ///  A variable setting the app ID string.
    ///
    ///  This string is used by desktop compositors to identify and group windows
    ///  together, as well as match applications with associated desktop settings
    ///  and icons.
    ///
    ///  This will override TSdlProperty.AppMetaDataIdentifier, if set by the
    ///  application.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    AppID = SDL_HINT_APP_ID;

    /// <summary>
    ///  A variable setting the application name.
    ///
    ///  This hint lets you specify the application name sent to the OS when
    ///  required. For example, this will often appear in volume control applets for
    ///  audio streams, and in lists of applications which are inhibiting the
    ///  screensaver. You should use a string that describes your program ('My Game
    ///  2: The Revenge')
    ///
    ///  This will override TSdlProperty.AppMetaDataName, if set by the
    ///  application.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    AppName = SDL_HINT_APP_NAME;

    /// <summary>
    ///  A variable controlling whether controllers used with the Apple TV generate
    ///  UI events.
    ///
    ///  When UI events are generated by controller input, the app will be
    ///  backgrounded when the Apple TV remote's menu button is pressed, and when
    ///  the pause or B buttons on gamepads are pressed.
    ///
    ///  More information about properly making use of controllers for the Apple TV
    ///  can be found here:
    ///  <see href="https://developer.apple.com/design/human-interface-guidelines/">Human Interface Guidelines</see>.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Controller input does not generate UI events. (default)
    ///  - '1': Controller input generates UI events.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AppleTVControllerUIEvents = SDL_HINT_APPLE_TV_CONTROLLER_UI_EVENTS;

    /// <summary>
    ///  A variable controlling whether the Apple TV remote's joystick axes will
    ///  automatically match the rotation of the remote.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Remote orientation does not affect joystick axes. (default)
    ///  - '1': Joystick axes are based on the orientation of the remote.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AppleTVRemoteAllowRotation = SDL_HINT_APPLE_TV_REMOTE_ALLOW_ROTATION;

    /// <summary>
    ///  Specify the default ALSA audio device name.
    ///
    ///  This variable is a specific audio device to open when the 'default' audio
    ///  device is used.
    ///
    ///  This hint will be ignored when opening the default playback device if
    ///  AudioAlsaDefaultPlaybackDevice is set, or when opening the
    ///  default recording device if AudioAlsaDefaultRecordingDevice is
    ///  set.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    /// <seealso cref='AudioAlsaDefaultPlaybackDevice'/>
    /// <seealso cref='AudioAlsaDefaultRecordingDevice'/>
    AudioAlsaDefaultDevice = SDL_HINT_AUDIO_ALSA_DEFAULT_DEVICE;

    /// <summary>
    ///  Specify the default ALSA audio playback device name.
    ///
    ///  This variable is a specific audio device to open for playback, when the
    ///  'default' audio device is used.
    ///
    ///  If this hint isn't set, SDL will check AudioAlsaDefaultDevice
    ///  before choosing a reasonable default.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    /// <seealso cref='AudioAlsaDefaultRecordingDevice'/>
    /// <seealso cref='AudioAlsaDefaultDevice'/>
    AudioAlsaDefaultPlaybackDevice = SDL_HINT_AUDIO_ALSA_DEFAULT_PLAYBACK_DEVICE;

    /// <summary>
    ///  Specify the default ALSA audio recording device name.
    ///
    ///  This variable is a specific audio device to open for recording, when the
    ///  'default' audio device is used.
    ///
    ///  If this hint isn't set, SDL will check AudioAlsaDefaultDevice
    ///  before choosing a reasonable default.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    /// <seealso cref='AudioAlsaDefaultPlaybackDevice'/>
    /// <seealso cref='AudioAlsaDefaultDevice'/>
    AudioAlsaDefaultRecordingDevice = SDL_HINT_AUDIO_ALSA_DEFAULT_RECORDING_DEVICE;

    /// <summary>
    ///  A variable controlling the audio category on iOS and macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'ambient': Use the AVAudioSessionCategoryAmbient audio category, will be
    ///    muted by the phone mute switch (default)
    ///  - 'playback': Use the AVAudioSessionCategoryPlayback category.
    ///
    ///  For more information, see <see href="https://developer.apple.com/library/content/documentation/Audio/Conceptual/AudioSessionProgrammingGuide/AudioSessionCategoriesandModes/AudioSessionCategoriesandModes.html">Apple's documentation</see>.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioCategory = SDL_HINT_AUDIO_CATEGORY;


    /// <summary>
    ///  A variable controlling the default audio channel count.
    ///
    ///  If the application doesn't specify the audio channel count when opening the
    ///  device, this hint can be used to specify a default channel count that will
    ///  be used. This defaults to '1' for recording and '2' for playback devices.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioChannels = SDL_HINT_AUDIO_CHANNELS;

    /// <summary>
    ///  Specify an application icon name for an audio device.
    ///
    ///  Some audio backends (such as Pulseaudio and Pipewire) allow you to set an
    ///  XDG icon name for your application. Among other things, this icon might
    ///  show up in a system control panel that lets the user adjust the volume on
    ///  specific audio streams instead of using one giant master volume slider.
    ///  Note that this is unrelated to the icon used by the windowing system, which
    ///  may be set with SDL_SetWindowIcon (or via desktop file on Wayland).
    ///
    ///  Setting this to '' or leaving it unset will have SDL use a reasonable
    ///  default, 'applications-games', which is likely to be installed. See
    ///  <see href="https://specifications.freedesktop.org/icon-theme-spec/latest/">Icon Theme Specification</see>
    ///  and
    ///  <see href="https://specifications.freedesktop.org/icon-naming-spec/latest/">Icon Naming Specification</see>
    ///  for the relevant XDG icon specs.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDeviceAppIconName = SDL_HINT_AUDIO_DEVICE_APP_ICON_NAME;

    /// <summary>
    ///  A variable controlling device buffer size.
    ///
    ///  This hint is an integer > 0, that represents the size of the device's
    ///  buffer in sample frames (stereo audio data in 16-bit format is 4 bytes per
    ///  sample frame, for example).
    ///
    ///  SDL3 generally decides this value on behalf of the app, but if for some
    ///  reason the app needs to dictate this (because they want either lower
    ///  latency or higher throughput AND ARE WILLING TO DEAL WITH what that might
    ///  require of the app), they can specify it.
    ///
    ///  SDL will try to accommodate this value, but there is no promise you'll get
    ///  the buffer size requested. Many platforms won't honor this request at all,
    ///  or might adjust it.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDeviceSampleFrames = SDL_HINT_AUDIO_DEVICE_SAMPLE_FRAMES;

    /// <summary>
    ///  Specify an audio stream name for an audio device.
    ///
    ///  Some audio backends (such as PulseAudio) allow you to describe your audio
    ///  stream. Among other things, this description might show up in a system
    ///  control panel that lets the user adjust the volume on specific audio
    ///  streams instead of using one giant master volume slider.
    ///
    ///  This hints lets you transmit that information to the OS. The contents of
    ///  this hint are used while opening an audio device. You should use a string
    ///  that describes your what your program is playing ('audio stream' is
    ///  probably sufficient in many cases, but this could be useful for something
    ///  like 'team chat' if you have a headset playing VoIP audio separately).
    ///
    ///  Setting this to '' or leaving it unset will have SDL use a reasonable
    ///  default: 'audio stream' or something similar.
    ///
    ///  Note that while this talks about audio streams, this is an OS-level
    ///  concept, so it applies to a physical audio device in this case, and not an
    ///  TSdlAudioStream, nor an SDL logical audio device.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDeviceStreamName = SDL_HINT_AUDIO_DEVICE_STREAM_NAME;

    /// <summary>
    ///  Specify an application role for an audio device.
    ///
    ///  Some audio backends (such as Pipewire) allow you to describe the role of
    ///  your audio stream. Among other things, this description might show up in a
    ///  system control panel or software for displaying and manipulating media
    ///  playback/recording graphs.
    ///
    ///  This hints lets you transmit that information to the OS. The contents of
    ///  this hint are used while opening an audio device. You should use a string
    ///  that describes your what your program is playing (Game, Music, Movie,
    ///  etc...).
    ///
    ///  Setting this to '' or leaving it unset will have SDL use a reasonable
    ///  default: 'Game' or something similar.
    ///
    ///  Note that while this talks about audio streams, this is an OS-level
    ///  concept, so it applies to a physical audio device in this case, and not an
    ///  TSdlAudioStream, nor an SDL logical audio device.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDeviceStreamRole = SDL_HINT_AUDIO_DEVICE_STREAM_ROLE;

    /// <summary>
    ///  Specify the input file when recording audio using the disk audio driver.
    ///
    ///  This defaults to 'sdlaudio-in.raw'
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDiskInputFile = SDL_HINT_AUDIO_DISK_INPUT_FILE;

    /// <summary>
    ///  Specify the output file when playing audio using the disk audio driver.
    ///
    ///  This defaults to 'sdlaudio.raw'
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDiskOutputFile = SDL_HINT_AUDIO_DISK_OUTPUT_FILE;

    /// <summary>
    ///  A variable controlling the audio rate when using the disk audio driver.
    ///
    ///  The disk audio driver normally simulates real-time for the audio rate that
    ///  was specified, but you can use this variable to adjust this rate higher or
    ///  lower down to 0. The default value is '1.0'.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDiskTimescale = SDL_HINT_AUDIO_DISK_TIMESCALE;

    /// <summary>
    ///  A variable that specifies an audio backend to use.
    ///
    ///  By default, SDL will try all available audio backends in a reasonable order
    ///  until it finds one that can work, but this hint allows the app or user to
    ///  force a specific driver, such as 'pipewire' if, say, you are on PulseAudio
    ///  but want to try talking to the lower level instead.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    AudioDriver = SDL_HINT_AUDIO_DRIVER;

    /// <summary>
    ///  A variable controlling the audio rate when using the dummy audio driver.
    ///
    ///  The dummy audio driver normally simulates real-time for the audio rate that
    ///  was specified, but you can use this variable to adjust this rate higher or
    ///  lower down to 0. The default value is '1.0'.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioDummyTimescale = SDL_HINT_AUDIO_DUMMY_TIMESCALE;

    /// <summary>
    ///  A variable controlling the default audio format.
    ///
    ///  If the application doesn't specify the audio format when opening the
    ///  device, this hint can be used to specify a default format that will be
    ///  used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'U8': Unsigned 8-bit audio
    ///  - 'S8': Signed 8-bit audio
    ///  - 'S16LE': Signed 16-bit little-endian audio
    ///  - 'S16BE': Signed 16-bit big-endian audio
    ///  - 'S16': Signed 16-bit native-endian audio (default)
    ///  - 'S32LE': Signed 32-bit little-endian audio
    ///  - 'S32BE': Signed 32-bit big-endian audio
    ///  - 'S32': Signed 32-bit native-endian audio
    ///  - 'F32LE': Floating point little-endian audio
    ///  - 'F32BE': Floating point big-endian audio
    ///  - 'F32': Floating point native-endian audio
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioFormat = SDL_HINT_AUDIO_FORMAT;

    /// <summary>
    ///  A variable controlling the default audio frequency.
    ///
    ///  If the application doesn't specify the audio frequency when opening the
    ///  device, this hint can be used to specify a default frequency that will be
    ///  used. This defaults to '44100'.
    ///
    ///  This hint should be set before an audio device is opened.
    /// </summary>
    AudioFrequency = SDL_HINT_AUDIO_FREQUENCY;

    /// <summary>
    ///  A variable that causes SDL to not ignore audio 'monitors'.
    ///
    ///  This is currently only used by the PulseAudio driver.
    ///
    ///  By default, SDL ignores audio devices that aren't associated with physical
    ///  hardware. Changing this hint to '1' will expose anything SDL sees that
    ///  appears to be an audio source or sink. This will add 'devices' to the list
    ///  that the user probably doesn't want or need, but it can be useful in
    ///  scenarios where you want to hook up SDL to some sort of virtual device,
    ///  etc.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Audio monitor devices will be ignored. (default)
    ///  - '1': Audio monitor devices will show up in the device list.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    AudioIncludeMonitors = SDL_HINT_AUDIO_INCLUDE_MONITORS;

    /// <summary>
    ///  A variable controlling whether SDL updates joystick state when getting
    ///  input events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': You'll call TSdlJoystick.Update manually.
    ///  - '1': SDL will automatically call TSdlJoystick.Update. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AutoUpdateJoysticks = SDL_HINT_AUTO_UPDATE_JOYSTICKS;

    /// <summary>
    ///  A variable controlling whether SDL updates sensor state when getting input
    ///  events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': You'll call TSdlSensor.Update manually.
    ///  - '1': SDL will automatically call TSdlSensor.Update. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    AutoUpdateSensors = SDL_HINT_AUTO_UPDATE_SENSORS;

    /// <summary>
    ///  Prevent SDL from using version 4 of the bitmap header when saving BMPs.
    ///
    ///  The bitmap header version 4 is required for proper alpha channel support
    ///  and SDL will use it when required. Should this not be desired, this hint
    ///  can force the use of the 40 byte header version which is supported
    ///  everywhere.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Surfaces with a colorkey or an alpha channel are saved to a 32-bit
    ///  BMP file with an alpha mask. SDL will use the bitmap header version 4 and
    ///  set the alpha mask accordingly. (default)
    ///  - '1': Surfaces with a colorkey or an alpha channel are saved to a 32-bit
    ///  BMP file without an alpha mask. The alpha channel data will be in the
    ///  file, but applications are going to ignore it.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    BmpSaveLegacyFormat = SDL_HINT_BMP_SAVE_LEGACY_FORMAT;

    /// <summary>
    ///  A variable that decides what camera backend to use.
    ///
    ///  By default, SDL will try all available camera backends in a reasonable
    ///  order until it finds one that can work, but this hint allows the app or
    ///  user to force a specific target, such as 'directshow' if, say, you are on
    ///  Windows Media Foundations but want to try DirectShow instead.
    ///
    ///  The default value is unset, in which case SDL will try to figure out the
    ///  best camera backend on your behalf. This hint needs to be set before
    ///  SdlInit is called to be useful.
    /// </summary>
    CameraDriver = SDL_HINT_CAMERA_DRIVER;

    /// <summary>
    ///  A variable that limits what CPU features are available.
    ///
    ///  By default, SDL marks all features the current CPU supports as available.
    ///  This hint allows to limit these to a subset.
    ///
    ///  When the hint is unset, or empty, SDL will enable all detected CPU
    ///  features.
    ///
    ///  The variable can be set to a comma separated list containing the following
    ///  items:
    ///
    ///  - 'all'
    ///  - 'altivec'
    ///  - 'sse'
    ///  - 'sse2'
    ///  - 'sse3'
    ///  - 'sse41'
    ///  - 'sse42'
    ///  - 'avx'
    ///  - 'avx2'
    ///  - 'avx512f'
    ///  - 'arm-simd'
    ///  - 'neon'
    ///  - 'lsx'
    ///  - 'lasx'
    ///
    ///  The items can be prefixed by '+'/'-' to add/remove features.
    /// </summary>
    CpuFeatureMask = SDL_HINT_CPU_FEATURE_MASK;

    /// <summary>
    ///  A variable controlling whether DirectInput should be used for controllers.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable DirectInput detection.
    ///  - '1': Enable DirectInput detection. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickDirectInput = SDL_HINT_JOYSTICK_DIRECTINPUT;

    /// <summary>
    ///  A variable that specifies a dialog backend to use.
    ///
    ///  By default, SDL will try all available dialog backends in a reasonable
    ///  order until it finds one that can work, but this hint allows the app or
    ///  user to force a specific target.
    ///
    ///  If the specified target does not exist or is not available, the
    ///  dialog-related function calls will fail.
    ///
    ///  This hint currently only applies to platforms using the generic 'Unix'
    ///  dialog implementation, but may be extended to more platforms in the future.
    ///  Note that some Unix and Unix-like platforms have their own implementation,
    ///  such as macOS and Haiku.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - nil: Select automatically (default, all platforms)
    ///  - 'portal': Use XDG Portals through DBus (Unix only)
    ///  - 'zenity': Use the Zenity program (Unix only)
    ///
    ///  More options may be added in the future.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    FileDialogDriver = SDL_HINT_FILE_DIALOG_DRIVER;

    /// <summary>
    ///  Override for TSdlDisplay.UsableBounds.
    ///
    ///  If set, this hint will override the expected results for
    ///  TSdlDisplay.UsableBounds for display index 0. Generally you don't want
    ///  to do this, but this allows an embedded system to request that some of the
    ///  screen be reserved for other uses when paired with a well-behaved
    ///  application.
    ///
    ///  The contents of this hint must be 4 comma-separated integers, the first is
    ///  the bounds x, then y, width and height, in that order.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    DisplayUsableBounds = SDL_HINT_DISPLAY_USABLE_BOUNDS;

    /// <summary>
    ///  A variable that controls whether the on-screen keyboard should be shown
    ///  when text input is active.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'auto': The on-screen keyboard will be shown if there is no physical
    ///    keyboard attached. (default)
    ///  - '0': Do not show the on-screen keyboard.
    ///  - '1': Show the on-screen keyboard, if available.
    ///
    ///  This hint must be set before TSdlWindow.StartTextInput is called
    /// </summary>
    EnableScreenKeyboard = SDL_HINT_ENABLE_SCREEN_KEYBOARD;

    /// <summary>
    ///  A variable containing a list of evdev devices to use if udev is not
    ///  available.
    ///
    ///  The list of devices is in the form:
    ///
    ///  deviceclass:path[,deviceclass:path[,...]]
    ///
    ///  where device class is an integer representing the SDL_UDEV_deviceclass and
    ///  path is the full path to the event device.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    EVDevDevices = SDL_HINT_EVDEV_DEVICES;

    /// <summary>
    ///  A variable controlling verbosity of the logging of SDL events pushed onto
    ///  the internal queue.
    ///
    ///  The variable can be set to the following values, from least to most
    ///  verbose:
    ///
    ///  - '0': Don't log any events. (default)
    ///  - '1': Log most events (other than the really spammy ones).
    ///  - '2': Include mouse and finger motion events.
    ///
    ///  This is generally meant to be used to debug SDL itself, but can be useful
    ///  for application developers that need better visibility into what is going
    ///  on in the event queue. Logged events are sent through SdlLog, which
    ///  means by default they appear on stdout on most platforms or maybe
    ///  OutputDebugString on Windows, and can be funneled by the app with
    ///  SdlSetLogOutputFunction, etc.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    EventLogging = SDL_HINT_EVENT_LOGGING;

    /// <summary>
    ///  A variable controlling whether raising the window should be done more
    ///  forcefully.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Honor the OS policy for raising windows. (default)
    ///  - '1': Force the window to be raised, overriding any OS policy.
    ///
    ///  At present, this is only an issue under MS Windows, which makes it nearly
    ///  impossible to programmatically move a window to the foreground, for
    ///  'security' reasons. See <see href="http://stackoverflow.com/a/34414846">Stack Overflow</see>
    ///  for a discussion.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    ForceRaiseWindow = SDL_HINT_FORCE_RAISEWINDOW;

    /// <summary>
    ///  A variable controlling how 3D acceleration is used to accelerate the SDL
    ///  screen surface.
    ///
    ///  SDL can try to accelerate the SDL screen surface by using streaming
    ///  textures with a 3D rendering engine. This variable controls whether and how
    ///  this is done.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable 3D acceleration
    ///  - '1': Enable 3D acceleration, using the default renderer. (default)
    ///  - 'X': Enable 3D acceleration, using X where X is one of the valid
    ///  rendering drivers. (e.g. 'direct3d', 'opengl', etc.)
    ///
    ///  This hint should be set before calling SDL_GetWindowSurface()
    /// </summary>
    FramebufferAcceleration = SDL_HINT_FRAMEBUFFER_ACCELERATION;

    /// <summary>
    ///  A variable that lets you manually hint extra gamecontroller db entries.
    ///
    ///  The variable should be newline delimited rows of gamecontroller config
    ///  data, see SDL_gamepad.h
    ///
    ///  You can update mappings after SDL is initialized with
    ///  TSdlGamepad.MappingForGuid and TSdlGamepad.AddMapping.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    GameControllerConfig = SDL_HINT_GAMECONTROLLERCONFIG;

    /// <summary>
    ///  A variable that lets you provide a file with extra gamecontroller db
    ///  entries.
    ///
    ///  The file should contain lines of gamecontroller config data, see
    ///  SDL_gamepad.h
    ///
    ///  You can update mappings after SDL is initialized with
    ///  TSdlGamepad.MappingForGuid and TSdlGamepad.AddMapping.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    GameControllerConfigFile = SDL_HINT_GAMECONTROLLERCONFIG_FILE;

    /// <summary>
    ///  A variable that overrides the automatic controller type detection.
    ///
    ///  The variable should be comma separated entries, in the form: VID/PID=type
    ///
    ///  The VID and PID should be hexadecimal with exactly 4 digits, e.g. 0x00fd
    ///
    ///  This hint affects what low level protocol is used with the HIDAPI driver.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'Xbox360'
    ///  - 'XboxOne'
    ///  - 'PS3'
    ///  - 'PS4'
    ///  - 'PS5'
    ///  - 'SwitchPro'
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    GameControllerType = SDL_HINT_GAMECONTROLLERTYPE;

    /// <summary>
    ///  A variable containing a list of devices to skip when scanning for game
    ///  controllers.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  0xAAAA/0xBBBB,0xCCCC/0xDDDD
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    GameControllerIgnoreDevices = SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES;

    /// <summary>
    ///  If set, all devices will be skipped when scanning for game controllers
    ///  except for the ones listed in this variable.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  0xAAAA/0xBBBB,0xCCCC/0xDDDD
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    GameControllerIgnoreDevicesExcept = SDL_HINT_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT;

    /// <summary>
    ///  A variable that controls whether the device's built-in accelerometer and
    ///  gyro should be used as sensors for gamepads.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Sensor fusion is disabled
    ///  - '1': Sensor fusion is enabled for all controllers that lack sensors
    ///
    ///  Or the variable can be a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  0xAAAA/0xBBBB,0xCCCC/0xDDDD
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint should be set before a gamepad is opened.
    /// </summary>
    GameControllerSensorFusion = SDL_HINT_GAMECONTROLLER_SENSOR_FUSION;

    /// <summary>
    ///  A variable to control whether HIDAPI uses libusb for device access.
    ///
    ///  By default libusb will only be used for a few devices that require direct
    ///  USB access, and this can be controlled with
    ///  HidApiLibUsbWhiteList.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI will not use libusb for device access.
    ///  - '1': HIDAPI will use libusb for device access if available. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    HidApiLibUsb = SDL_HINT_HIDAPI_LIBUSB;

    /// <summary>
    ///  A variable to control whether HIDAPI uses libusb only for whitelisted
    ///  devices.
    ///
    ///  By default libusb will only be used for a few devices that require direct
    ///  USB access.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI will use libusb for all device access.
    ///  - '1': HIDAPI will use libusb only for whitelisted devices. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    HidApiLibUsbWhiteList = SDL_HINT_HIDAPI_LIBUSB_WHITELIST;

    /// <summary>
    ///  A variable to control whether HIDAPI uses udev for device detection.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI will poll for device changes.
    ///  - '1': HIDAPI will use udev for device detection. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    HidApiLibUDev = SDL_HINT_HIDAPI_UDEV;

    /// <summary>
    ///  A variable that specifies a GPU backend to use.
    ///
    ///  By default, SDL will try all available GPU backends in a reasonable order
    ///  until it finds one that can work, but this hint allows the app or user to
    ///  force a specific target, such as 'direct3d11' if, say, your hardware
    ///  supports D3D12 but want to try using D3D11 instead.
    ///
    ///  This hint should be set before any GPU functions are called.
    /// </summary>
    GpuDriver = SDL_HINT_GPU_DRIVER;

    /// <summary>
    ///  A variable to control whether TSdlHid.Enumerate enumerates all HID
    ///  devices or only controllers.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': TSdlHid.Enumerate will enumerate all HID devices.
    ///  - '1': TSdlHid.Enumerate will only enumerate controllers. (default)
    ///
    ///  By default SDL will only enumerate controllers, to reduce risk of hanging
    ///  or crashing on devices with bad drivers and avoiding macOS keyboard capture
    ///  permission prompts.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    HidApiEnumerateOnlyControllers = SDL_HINT_HIDAPI_ENUMERATE_ONLY_CONTROLLERS;

    /// <summary>
    ///  A variable containing a list of devices to ignore in TSdlHid.Enumerate.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  For example, to ignore the Shanwan DS3 controller and any Valve controller,
    ///  you might use the string '0x2563/0x0523,0x28de/0x0000'
    ///
    ///  This hint can be set anytime.
    /// </summary>
    HidApiIgnoreDevices = SDL_HINT_HIDAPI_IGNORE_DEVICES;

    /// <summary>
    ///  A variable describing what IME UI elements the application can display.
    ///
    ///  By default IME UI is handled using native components by the OS where
    ///  possible, however this can interfere with or not be visible when exclusive
    ///  fullscreen mode is used.
    ///
    ///  The variable can be set to a comma separated list containing the following
    ///  items:
    ///
    ///  - 'none' or '0': The application can't render any IME elements, and native
    ///    UI should be used. (default)
    ///  - 'composition': The application handles TSdlEventKind.TextEditing events and
    ///    can render the composition text.
    ///  - 'candidates': The application handles TSdlEventKind.TextEditingCandidates
    ///    and can render the candidate list.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    ImeImplementedUI = SDL_HINT_IME_IMPLEMENTED_UI;

    /// <summary>
    ///  A variable controlling whether the home indicator bar on iPhone X should be
    ///  hidden.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The indicator bar is not hidden. (default for windowed applications)
    ///  - '1': The indicator bar is hidden and is shown when the screen is touched
    ///    (useful for movie playback applications).
    ///  - '2': The indicator bar is dim and the first swipe makes it visible and
    ///    the second swipe performs the 'home' action. (default for fullscreen
    ///    applications)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    IosHideHomeIndicator = SDL_HINT_IOS_HIDE_HOME_INDICATOR;

    /// <summary>
    ///  A variable that lets you enable joystick (and gamecontroller) events even
    ///  when your app is in the background.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable joystick & gamecontroller input events when the application
    ///    is in the background. (default)
    ///  - '1': Enable joystick & gamecontroller input events when the application
    ///    is in the background.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickAllowBackgroundEvents = SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS;

    /// <summary>
    ///  A variable containing a list of arcade stick style controllers.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickArcadestickDevices = SDL_HINT_JOYSTICK_ARCADESTICK_DEVICES;

    /// <summary>
    ///  A variable containing a list of devices that are not arcade stick style
    ///  controllers.
    ///
    ///  This will override JoystickArcadestickDevices and the built in
    ///  device list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickArcadestickDevicesExcluded = SDL_HINT_JOYSTICK_ARCADESTICK_DEVICES_EXCLUDED;

    /// <summary>
    ///  A variable containing a list of devices that should not be considered
    ///  joysticks.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickBlacklistDevices = SDL_HINT_JOYSTICK_BLACKLIST_DEVICES;

    /// <summary>
    ///  A variable containing a list of devices that should be considered
    ///  joysticks.
    ///
    ///  This will override JoystickBlacklistDevices and the built in
    ///  device list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickBlacklistDevicesExcluded = SDL_HINT_JOYSTICK_BLACKLIST_DEVICES_EXCLUDED;

    /// <summary>
    ///  A variable containing a comma separated list of devices to open as
    ///  joysticks.
    ///
    ///  This variable is currently only used by the Linux joystick driver.
    /// </summary>
    JoystickDevice = SDL_HINT_JOYSTICK_DEVICE;

    /// <summary>
    ///  A variable controlling whether enhanced reports should be used for
    ///  controllers when using the HIDAPI driver.
    ///
    ///  Enhanced reports allow rumble and effects on Bluetooth PlayStation
    ///  controllers and gyro on Nintendo Switch controllers, but break Windows
    ///  DirectInput for other applications that don't use SDL.
    ///
    ///  Once enhanced reports are enabled, they can't be disabled on PlayStation
    ///  controllers without power cycling the controller.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': enhanced reports are not enabled.
    ///  - '1': enhanced reports are enabled. (default)
    ///  - 'auto': enhanced features are advertised to the application, but SDL
    ///    doesn't change the controller report mode unless the application uses
    ///    them.
    ///
    ///  This hint can be enabled anytime.
    /// </summary>
    JoystickEnhancedReports = SDL_HINT_JOYSTICK_ENHANCED_REPORTS;

    /// <summary>
    ///  A variable containing a list of flightstick style controllers.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of @file, in which case the named file
    ///  will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickFlightstickDevices = SDL_HINT_JOYSTICK_FLIGHTSTICK_DEVICES;

    /// <summary>
    ///  A variable containing a list of devices that are not flightstick style
    ///  controllers.
    ///
    ///  This will override JoystickFlightstickDevices and the built in
    ///  device list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickFlightstickDevicesExcluded = SDL_HINT_JOYSTICK_FLIGHTSTICK_DEVICES_EXCLUDED;

    /// <summary>
    ///  A variable controlling whether GameInput should be used for controller
    ///  handling on Windows.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': GameInput is not used.
    ///  - '1': GameInput is used.
    ///
    ///  The default is '1' on GDK platforms, and '0' otherwise.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickGameInput = SDL_HINT_JOYSTICK_GAMEINPUT;

    /// <summary>
    ///  A variable containing a list of devices known to have a GameCube form
    ///  factor.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickGameCubeDevices = SDL_HINT_JOYSTICK_GAMECUBE_DEVICES;

    /// <summary>
    ///  A variable containing a list of devices known not to have a GameCube form
    ///  factor.
    ///
    ///  This will override JoystickGameCubeDevices and the built in
    ///  device list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickGameCubeDevicesExcluded = SDL_HINT_JOYSTICK_GAMECUBE_DEVICES_EXCLUDED;

    /// <summary>
    ///  A variable controlling whether the HIDAPI joystick drivers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI drivers are not used.
    ///  - '1': HIDAPI drivers are used. (default)
    ///
    ///  This variable is the default for all drivers, but can be overridden by the
    ///  hints for specific drivers below.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApi = SDL_HINT_JOYSTICK_HIDAPI;

    /// <summary>
    ///  A variable controlling whether Nintendo Switch Joy-Con controllers will be
    ///  combined into a single Pro-like controller when using the HIDAPI driver.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Left and right Joy-Con controllers will not be combined and each
    ///    will be a mini-gamepad.
    ///  - '1': Left and right Joy-Con controllers will be combined into a single
    ///    controller. (default)
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiCombineJoyCons = SDL_HINT_JOYSTICK_HIDAPI_COMBINE_JOY_CONS;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Nintendo GameCube
    ///  controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiGameCube = SDL_HINT_JOYSTICK_HIDAPI_GAMECUBE;

    /// <summary>
    ///  A variable controlling whether rumble is used to implement the GameCube
    ///  controller's 3 rumble modes, Stop(0), Rumble(1), and StopHard(2).
    ///
    ///  This is useful for applications that need full compatibility for things
    ///  like ADSR envelopes. - Stop is implemented by setting low_frequency_rumble
    ///  to 0 and high_frequency_rumble >0 - Rumble is both at any arbitrary value -
    ///  StopHard is implemented by setting both low_frequency_rumble and
    ///  high_frequency_rumble to 0
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Normal rumble behavior is behavior is used. (default)
    ///  - '1': Proper GameCube controller rumble behavior is used.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiGameCubeRumbleBrake = SDL_HINT_JOYSTICK_HIDAPI_GAMECUBE_RUMBLE_BRAKE;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Nintendo Switch
    ///  Joy-Cons should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiJoyCons = SDL_HINT_JOYSTICK_HIDAPI_JOY_CONS;

    /// <summary>
    ///  A variable controlling whether the Home button LED should be turned on when
    ///  a Nintendo Switch Joy-Con controller is opened.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': home button LED is turned off
    ///  - '1': home button LED is turned on
    ///
    ///  By default the Home button LED state is not changed. This hint can also be
    ///  set to a floating point value between 0.0 and 1.0 which controls the
    ///  brightness of the Home button LED.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiJoyConHomeLed = SDL_HINT_JOYSTICK_HIDAPI_JOYCON_HOME_LED;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Amazon Luna
    ///  controllers connected via Bluetooth should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiLuna = SDL_HINT_JOYSTICK_HIDAPI_LUNA;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Nintendo Online
    ///  classic controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiNintendoClassic = SDL_HINT_JOYSTICK_HIDAPI_NINTENDO_CLASSIC;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for PS3 controllers should
    ///  be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi on macOS, and '0' on
    ///  other platforms.
    ///
    ///  For official Sony driver (sixaxis.sys) use
    ///  JoystickHidApiPS3SixAxisDriver. See
    ///  <see href="https://github.com/ViGEm/DsHidMini">DsHidMini</see> for an alternative driver on Windows.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiPS3 = SDL_HINT_JOYSTICK_HIDAPI_PS3;

    /// <summary>
    ///  A variable controlling whether the Sony driver (sixaxis.sys) for PS3
    ///  controllers (Sixaxis/DualShock 3) should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Sony driver (sixaxis.sys) is not used.
    ///  - '1': Sony driver (sixaxis.sys) is used.
    ///
    ///  The default value is 0.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiPS3SixAxisDriver = SDL_HINT_JOYSTICK_HIDAPI_PS3_SIXAXIS_DRIVER;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for PS4 controllers should
    ///  be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiPS4 = SDL_HINT_JOYSTICK_HIDAPI_PS4;

    /// <summary>
    ///  A variable controlling the update rate of the PS4 controller over Bluetooth
    ///  when using the HIDAPI driver.
    ///
    ///  This defaults to 4 ms, to match the behavior over USB, and to be more
    ///  friendly to other Bluetooth devices and older Bluetooth hardware on the
    ///  computer. It can be set to '1' (1000Hz), '2' (500Hz) and '4' (250Hz)
    ///
    ///  This hint can be set anytime, but only takes effect when extended input
    ///  reports are enabled.
    /// </summary>
    JoystickHidApiPS4ReportInterval = SDL_HINT_JOYSTICK_HIDAPI_PS4_REPORT_INTERVAL;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for PS5 controllers should
    ///  be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiPS5 = SDL_HINT_JOYSTICK_HIDAPI_PS5;

    /// <summary>
    ///  A variable controlling whether the player LEDs should be lit to indicate
    ///  which player is associated with a PS5 controller.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': player LEDs are not enabled.
    ///  - '1': player LEDs are enabled. (default)
    /// </summary>
    JoystickHidApiPS5PlayerLed = SDL_HINT_JOYSTICK_HIDAPI_PS5_PLAYER_LED;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for NVIDIA SHIELD
    ///  controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiShield = SDL_HINT_JOYSTICK_HIDAPI_SHIELD;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Google Stadia
    ///  controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    /// </summary>
    JoystickHidApiStadia = SDL_HINT_JOYSTICK_HIDAPI_STADIA;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Bluetooth Steam
    ///  Controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used. (default)
    ///  - '1': HIDAPI driver is used for Steam Controllers, which requires
    ///  Bluetooth access and may prompt the user for permission on iOS and
    ///  Android.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiSteam = SDL_HINT_JOYSTICK_HIDAPI_STEAM;

    /// <summary>
    ///  A variable controlling whether the Steam button LED should be turned on
    ///  when a Steam controller is opened.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Steam button LED is turned off.
    ///  - '1': Steam button LED is turned on.
    ///
    ///  By default the Steam button LED state is not changed. This hint can also be
    ///  set to a floating point value between 0.0 and 1.0 which controls the
    ///  brightness of the Steam button LED.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiSteamHomeLed = SDL_HINT_JOYSTICK_HIDAPI_STEAM_HOME_LED;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for the Steam Deck builtin
    ///  controller should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiSteamDeck = SDL_HINT_JOYSTICK_HIDAPI_STEAMDECK;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for HORI licensed Steam
    ///  controllers should be used.
    ///
    ///  This variable can be set to the following values: '0' - HIDAPI driver is
    ///  not used '1' - HIDAPI driver is used
    ///
    ///  The default is the value of JoystickHidApi.
    /// </summary>
    JoystickHidApiSteamHori = SDL_HINT_JOYSTICK_HIDAPI_STEAM_HORI;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Nintendo Switch
    ///  controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApi.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiSwitch = SDL_HINT_JOYSTICK_HIDAPI_SWITCH;

    /// <summary>
    ///  A variable controlling whether the Home button LED should be turned on when
    ///  a Nintendo Switch Pro controller is opened.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Home button LED is turned off.
    ///  - '1': Home button LED is turned on.
    ///
    ///  By default the Home button LED state is not changed. This hint can also be
    ///  set to a floating point value between 0.0 and 1.0 which controls the
    ///  brightness of the Home button LED.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiSwitchHomeLed = SDL_HINT_JOYSTICK_HIDAPI_SWITCH_HOME_LED;

    /// <summary>
    ///  A variable controlling whether the player LEDs should be lit to indicate
    ///  which player is associated with a Nintendo Switch controller.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Player LEDs are not enabled.
    ///  - '1': Player LEDs are enabled. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiSwitchPlayerLed = SDL_HINT_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED;

    /// <summary>
    ///  A variable controlling whether Nintendo Switch Joy-Con controllers will be
    ///  in vertical mode when using the HIDAPI driver.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Left and right Joy-Con controllers will not be in vertical mode.
    ///    (default)
    ///  - '1': Left and right Joy-Con controllers will be in vertical mode.
    ///
    ///  This hint should be set before opening a Joy-Con controller.
    /// </summary>
    JoystickHidApiVerticalJoyCons = SDL_HINT_JOYSTICK_HIDAPI_VERTICAL_JOY_CONS;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for Nintendo Wii and Wii U
    ///  controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  This driver doesn't work with the dolphinbar, so the default is false for
    ///  now.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiWii = SDL_HINT_JOYSTICK_HIDAPI_WII;

    /// <summary>
    ///  A variable controlling whether the player LEDs should be lit to indicate
    ///  which player is associated with a Wii controller.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Player LEDs are not enabled.
    ///  - '1': Player LEDs are enabled. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiWiiPlayerLed = SDL_HINT_JOYSTICK_HIDAPI_WII_PLAYER_LED;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for XBox controllers
    ///  should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is '0' on Windows, otherwise the value of
    ///  JoystickHidApi
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiXbox = SDL_HINT_JOYSTICK_HIDAPI_XBOX;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for XBox 360 controllers
    ///  should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApiXbox
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiXbox360 = SDL_HINT_JOYSTICK_HIDAPI_XBOX_360;

    /// <summary>
    ///  A variable controlling whether the player LEDs should be lit to indicate
    ///  which player is associated with an Xbox 360 controller.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Player LEDs are not enabled.
    ///  - '1': Player LEDs are enabled. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiXbox360PlayerLed = SDL_HINT_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for XBox 360 wireless
    ///  controllers should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApiXbox360.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiXbox360Wireless = SDL_HINT_JOYSTICK_HIDAPI_XBOX_360_WIRELESS;

    /// <summary>
    ///  A variable controlling whether the HIDAPI driver for XBox One controllers
    ///  should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': HIDAPI driver is not used.
    ///  - '1': HIDAPI driver is used.
    ///
    ///  The default is the value of JoystickHidApiXbox.
    ///
    ///  This hint should be set before initializing joysticks and gamepads.
    /// </summary>
    JoystickHidApiXboxOne = SDL_HINT_JOYSTICK_HIDAPI_XBOX_ONE;

    /// <summary>
    ///  A variable controlling whether the Home button LED should be turned on when
    ///  an Xbox One controller is opened.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Home button LED is turned off.
    ///  - '1': Home button LED is turned on.
    ///
    ///  By default the Home button LED state is not changed. This hint can also be
    ///  set to a floating point value between 0.0 and 1.0 which controls the
    ///  brightness of the Home button LED. The default brightness is 0.4.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickHidApiXboxOneHomeLed = SDL_HINT_JOYSTICK_HIDAPI_XBOX_ONE_HOME_LED;

    /// <summary>
    ///  A variable controlling whether IOKit should be used for controller
    ///  handling.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': IOKit is not used.
    ///  - '1': IOKit is used. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickIOKit = SDL_HINT_JOYSTICK_IOKIT;

    /// <summary>
    ///  A variable controlling whether to use the classic /dev/input/js* joystick
    ///  interface or the newer /dev/input/event* joystick interface on Linux.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use /dev/input/event* (default)
    ///  - '1': Use /dev/input/js*
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickLinuxClassic = SDL_HINT_JOYSTICK_LINUX_CLASSIC;

    /// <summary>
    ///  A variable controlling whether joysticks on Linux adhere to their
    ///  HID-defined deadzones or return unfiltered values.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Return unfiltered joystick axis values. (default)
    ///  - '1': Return axis values with deadzones taken into account.
    ///
    ///  This hint should be set before a controller is opened.
    /// </summary>
    JoystickLinuxDeadzoned = SDL_HINT_JOYSTICK_LINUX_DEADZONES;

    /// <summary>
    ///  A variable controlling whether joysticks on Linux will always treat 'hat'
    ///  axis inputs (ABS_HAT0X - ABS_HAT3Y) as 8-way digital hats without checking
    ///  whether they may be analog.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Only map hat axis inputs to digital hat outputs if the input axes
    ///  appear to actually be digital. (default)
    ///  - '1': Always handle the input axes numbered ABS_HAT0X to ABS_HAT3Y as
    ///  digital hats.
    ///
    ///  This hint should be set before a controller is opened.
    /// </summary>
    JoystickLinuxDigitalHats = SDL_HINT_JOYSTICK_LINUX_DIGITAL_HATS;

    /// <summary>
    ///  A variable controlling whether digital hats on Linux will apply deadzones
    ///  to their underlying input axes or use unfiltered values.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Return digital hat values based on unfiltered input axis values.
    ///  - '1': Return digital hat values with deadzones on the input axes taken
    ///  into account. (default)
    ///
    ///  This hint should be set before a controller is opened.
    /// </summary>
    JoystickLinuxHatDeadzones = SDL_HINT_JOYSTICK_LINUX_HAT_DEADZONES;

    /// <summary>
    ///  A variable controlling whether GCController should be used for controller
    ///  handling.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': GCController is not used.
    ///  - '1': GCController is used. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickMfi = SDL_HINT_JOYSTICK_MFI;

    /// <summary>
    ///  A variable controlling whether the RAWINPUT joystick drivers should be used
    ///  for better handling XInput-capable devices.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': RAWINPUT drivers are not used.
    ///  - '1': RAWINPUT drivers are used. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickRawInput = SDL_HINT_JOYSTICK_RAWINPUT;

    /// <summary>
    ///  A variable controlling whether the RAWINPUT driver should pull correlated
    ///  data from XInput.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': RAWINPUT driver will only use data from raw input APIs.
    ///  - '1': RAWINPUT driver will also pull data from XInput and
    ///    Windows.Gaming.Input, providing better trigger axes, guide button
    ///    presses, and rumble support for Xbox controllers. (default)
    ///
    ///  This hint should be set before a gamepad is opened.
    /// </summary>
    JoystickRawInputCorrelateXInput = SDL_HINT_JOYSTICK_RAWINPUT_CORRELATE_XINPUT;

    /// <summary>
    ///  A variable controlling whether the ROG Chakram mice should show up as
    ///  joysticks.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': ROG Chakram mice do not show up as joysticks. (default)
    ///  - '1': ROG Chakram mice show up as joysticks.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickRogChakram = SDL_HINT_JOYSTICK_ROG_CHAKRAM;

    /// <summary>
    ///  A variable controlling whether a separate thread should be used for
    ///  handling joystick detection and raw input messages on Windows.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': A separate thread is not used.
    ///  - '1': A separate thread is used for handling raw input messages. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickThread = SDL_HINT_JOYSTICK_THREAD;

    /// <summary>
    ///  A variable containing a list of throttle style controllers.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickThrottleDevices = SDL_HINT_JOYSTICK_THROTTLE_DEVICES;

    /// <summary>
    ///  A variable containing a list of devices that are not throttle style
    ///  controllers.
    ///
    ///  This will override JoystickThrottleDevices and the built in
    ///  device list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickThrottleDevicesExcluded = SDL_HINT_JOYSTICK_THROTTLE_DEVICES_EXCLUDED;

    /// <summary>
    ///  A variable controlling whether Windows.Gaming.Input should be used for
    ///  controller handling.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': WGI is not used.
    ///  - '1': WGI is used. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    JoystickWgi = SDL_HINT_JOYSTICK_WGI;

    /// <summary>
    ///  A variable containing a list of wheel style controllers.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickWheelDevices = SDL_HINT_JOYSTICK_WHEEL_DEVICES;

    /// <summary>
    ///  A variable containing a list of devices that are not wheel style
    ///  controllers.
    ///
    ///  This will override JoystickWheelDevices and the built in device
    ///  list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    JoystickWheelDevicesExcluded = SDL_HINT_JOYSTICK_WHEEL_DEVICES_EXCLUDED;

    /// <summary>
    ///  A variable containing a list of devices known to have all axes centered at
    ///  zero.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint should be set before a controller is opened.
    /// </summary>
    JoystickZeroCenteredDevices = SDL_HINT_JOYSTICK_ZERO_CENTERED_DEVICES;

    /// <summary>
    ///  A variable that controls keycode representation in keyboard events.
    ///
    ///  This variable is a comma separated set of options for translating keycodes
    ///  in events:
    ///
    ///  - 'none': Keycode options are cleared, this overrides other options.
    ///  - 'hide_numpad': The numpad keysyms will be translated into their
    ///    non-numpad versions based on the current NumLock state. For example,
    ///    TSdlKeycode.KP4 would become TSdlKeycode._4 if TSdlKeyMod.Num is set
    ///    in the event modifiers, and TSdlKeycode.Left if it is unset.
    ///  - 'french_numbers': The number row on French keyboards is inverted, so
    ///    pressing the 1 key would yield the keycode TSdlKeycode._1, or '1',
    ///    instead of TSdlKeycode.Ampersand, or '&'
    ///  - 'latin_letters': For keyboards using non-Latin letters, such as Russian
    ///    or Thai, the letter keys generate keycodes as though it had an en_US
    ///    layout. e.g. pressing the key associated with TSdlScancode.A on a Russian
    ///    keyboard would yield 'a' instead of a Cyrillic letter.
    ///
    ///  The default value for this hint is 'french_numbers,latin_letters'
    ///
    ///  Some platforms like Emscripten only provide modified keycodes and the
    ///  options are not used.
    ///
    ///  These options do not affect the return value of TSdlKeycode.FromScancode or
    ///  TSdlScancode.FromKeycode, they just apply to the keycode included in key
    ///  events.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    KeycodeOptions = SDL_HINT_KEYCODE_OPTIONS;

    /// <summary>
    ///  A variable that controls what KMSDRM device to use.
    ///
    ///  SDL might open something like '/dev/dri/cardNN' to access KMSDRM
    ///  functionality, where 'NN' is a device index number. SDL makes a guess at
    ///  the best index to use (usually zero), but the app or user can set this hint
    ///  to a number between 0 and 99 to force selection.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    KmsDrmDeviceIndex = SDL_HINT_KMSDRM_DEVICE_INDEX;

    /// <summary>
    ///  A variable that controls whether SDL requires DRM master access in order to
    ///  initialize the KMSDRM video backend.
    ///
    ///  The DRM subsystem has a concept of a 'DRM master' which is a DRM client
    ///  that has the ability to set planes, set cursor, etc. When SDL is DRM
    ///  master, it can draw to the screen using the SDL rendering APIs. Without DRM
    ///  master, SDL is still able to process input and query attributes of attached
    ///  displays, but it cannot change display state or draw to the screen
    ///  directly.
    ///
    ///  In some cases, it can be useful to have the KMSDRM backend even if it
    ///  cannot be used for rendering. An app may want to use SDL for input
    ///  processing while using another rendering API (such as an MMAL overlay on
    ///  Raspberry Pi) or using its own code to render to DRM overlays that SDL
    ///  doesn't support.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': SDL will allow usage of the KMSDRM backend without DRM master.
    ///  - '1': SDL Will require DRM master to use the KMSDRM backend. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    KmsDrmRequireDrmMaster = SDL_HINT_KMSDRM_REQUIRE_DRM_MASTER;

    /// <summary>
    ///  A variable controlling the default SDL log levels.
    ///
    ///  This variable is a comma separated set of category=level tokens that define
    ///  the default logging levels for SDL applications.
    ///
    ///  The category can be a numeric category, one of 'app', 'error', 'assert',
    ///  'system', 'audio', 'video', 'render', 'input', 'test', or `*` for any
    ///  unspecified category.
    ///
    ///  The level can be a numeric level, one of 'verbose', 'debug', 'info',
    ///  'warn', 'error', 'critical', or 'quiet' to disable that category.
    ///
    ///  You can omit the category if you want to set the logging level for all
    ///  categories.
    ///
    ///  If this hint isn't set, the default log levels are equivalent to:
    ///
    ///  `app=info,assert=warn,test=verbose,*=error`
    ///
    ///  This hint can be set anytime.
    /// </summary>
    Logging = SDL_HINT_LOGGING;

    /// <summary>
    ///  A variable controlling whether to force the application to become the
    ///  foreground process when launched on macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The application is brought to the foreground when launched.
    ///    (default)
    ///  - '1': The application may remain in the background when launched.
    ///
    ///  This hint needs to be set before SDL_Init().
    /// </summary>
    MacBackgroundApp = SDL_HINT_MAC_BACKGROUND_APP;

    /// <summary>
    ///  A variable that determines whether Ctrl+Click should generate a right-click
    ///  event on macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Ctrl+Click does not generate a right mouse button click event.
    ///    (default)
    ///  - '1': Ctrl+Click generated a right mouse button click event.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MacCtrlClickEmulateRightClick = SDL_HINT_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK;

    /// <summary>
    ///  A variable controlling whether dispatching OpenGL context updates should
    ///  block the dispatching thread until the main thread finishes processing on
    ///  macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Dispatching OpenGL context updates will block the dispatching thread
    ///    until the main thread finishes processing. (default)
    ///  - '1': Dispatching OpenGL context updates will allow the dispatching thread
    ///    to continue execution.
    ///
    ///  Generally you want the default, but if you have OpenGL code in a background
    ///  thread on a Mac, and the main thread hangs because it's waiting for that
    ///  background thread, but that background thread is also hanging because it's
    ///  waiting for the main thread to do an update, this might fix your issue.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MacOpenGLAsyncDispatch = SDL_HINT_MAC_OPENGL_ASYNC_DISPATCH;

    /// <summary>
    ///  A variable controlling whether the Option key on macOS should be
    ///  remapped to act as the Alt key.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'none': The Option key is not remapped to Alt. (default)
    ///  - 'only_left': Only the left Option key is remapped to Alt.
    ///  - 'only_right': Only the right Option key is remapped to Alt.
    ///  - 'both': Both Option keys are remapped to Alt.
    ///
    ///  This will prevent the triggering of key compositions that rely on the
    ///  Option key, but will still send the Alt modifier for keyboard events. In
    ///  the case that both Alt and Option are pressed, the Option key will be
    ///  ignored. This is particularly useful for applications like terminal
    ///  emulators and graphical user interfaces (GUIs) that rely on Alt key
    ///  functionality for shortcuts or navigation. This does not apply to
    ///  TSdlKeycode.FromScancode and only has an effect if IME is enabled.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MacOptionAsAlt = SDL_HINT_MAC_OPTION_AS_ALT;

    /// <summary>
    ///  A variable controlling whether SDL_EVENT_MOUSE_WHEEL event values will have
    ///  momentum on macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The mouse wheel events will have no momentum. (default)
    ///  - '1': The mouse wheel events will have momentum.
    ///
    ///  This hint needs to be set before SDL_Init().
    /// </summary>
    MacScrollMomentum = SDL_HINT_MAC_SCROLL_MOMENTUM;

    /// <summary>
    ///  Request TSdlApp.Iterate be called at a specific rate.
    ///
    ///  If this is set to a number, it represents Hz, so '60' means try to iterate
    ///  60 times per second. '0' means to iterate as fast as possible. Negative
    ///  values are illegal, but reserved, in case they are useful in a future
    ///  revision of SDL.
    ///
    ///  There are other strings that have special meaning. If set to 'waitevent',
    ///  TSdlApp.Iterate will not be called until new event(s) have arrived (and been
    ///  processed by TSdlApp.Event). This can be useful for apps that are completely
    ///  idle except in response to input.
    ///
    ///  This defaults to 0, and specifying nil for the hint's value will restore
    ///  the default.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MainCallbackRate = SDL_HINT_MAIN_CALLBACK_RATE;

    /// <summary>
    ///  A variable controlling whether the mouse is captured while mouse buttons
    ///  are pressed.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The mouse is not captured while mouse buttons are pressed.
    ///  - '1': The mouse is captured while mouse buttons are pressed.
    ///
    ///  By default the mouse is captured while mouse buttons are pressed so if the
    ///  mouse is dragged outside the window, the application continues to receive
    ///  mouse events until the button is released.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseAutoCapture = SDL_HINT_MOUSE_AUTO_CAPTURE;

    /// <summary>
    ///  A variable setting the double click radius, in pixels.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseDoubleClickRadius = SDL_HINT_MOUSE_DOUBLE_CLICK_RADIUS;

    /// <summary>
    ///  A variable setting the double click time, in milliseconds.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseDoubleClickTime = SDL_HINT_MOUSE_DOUBLE_CLICK_TIME;

    /// <summary>
    ///  A variable setting which system cursor to use as the default cursor.
    ///
    ///  This should be an integer corresponding to the SDL_SystemCursor enum. The
    ///  default value is zero (TSdlSystemCursor.Default).
    ///
    ///  This hint needs to be set before SdlInit.
    /// </summary>
    MouseDefaultSystemCursor = SDL_HINT_MOUSE_DEFAULT_SYSTEM_CURSOR;

    /// <summary>
    ///  A variable controlling whether warping a hidden mouse cursor will activate
    ///  relative mouse mode.
    ///
    ///  When this hint is set, the mouse cursor is hidden, and multiple warps to
    ///  the window center occur within a short time period, SDL will emulate mouse
    ///  warps using relative mouse mode. This can provide smoother and more
    ///  reliable mouse motion for some older games, which continuously calculate
    ///  the distance travelled by the mouse pointer and warp it back to the center
    ///  of the window, rather than using relative mouse motion.
    ///
    ///  Note that relative mouse mode may have different mouse acceleration
    ///  behavior than pointer warps.
    ///
    ///  If your application needs to repeatedly warp the hidden mouse cursor at a
    ///  high-frequency for other purposes, it should disable this hint.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Attempts to warp the mouse will always be made.
    ///  - '1': Some mouse warps will be emulated by forcing relative mouse mode.
    ///    (default)
    ///
    ///  If not set, this is automatically enabled unless an application uses
    ///  relative mouse mode directly.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseEmulateWarpWithRelative = SDL_HINT_MOUSE_EMULATE_WARP_WITH_RELATIVE;

    /// <summary>
    ///  Allow mouse click events when clicking to focus an SDL window.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Ignore mouse clicks that activate a window. (default)
    ///  - '1': Generate events for mouse clicks that activate a window.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseFocusClickThrough = SDL_HINT_MOUSE_FOCUS_CLICKTHROUGH;

    /// <summary>
    ///  A variable setting the speed scale for mouse motion, in floating point,
    ///  when the mouse is not in relative mode.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseNormalSpeedScale = SDL_HINT_MOUSE_NORMAL_SPEED_SCALE;

    /// <summary>
    ///  A variable controlling whether relative mouse mode constrains the mouse to
    ///  the center of the window.
    ///
    ///  Constraining to the center of the window works better for FPS games and
    ///  when the application is running over RDP. Constraining to the whole window
    ///  works better for 2D games and increases the chance that the mouse will be
    ///  in the correct position when using high DPI mice.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Relative mouse mode constrains the mouse to the window.
    ///  - '1': Relative mouse mode constrains the mouse to the center of the
    ///    window. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseRelativeModeCenter = SDL_HINT_MOUSE_RELATIVE_MODE_CENTER;

    /// <summary>
    ///  A variable setting the scale for mouse motion, in floating point, when the
    ///  mouse is in relative mode.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseRelativeSpeedScale = SDL_HINT_MOUSE_RELATIVE_SPEED_SCALE;

    /// <summary>
    ///  A variable controlling whether the system mouse acceleration curve is used
    ///  for relative mouse motion.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Relative mouse motion will be unscaled. (default)
    ///  - '1': Relative mouse motion will be scaled using the system mouse
    ///  acceleration curve.
    ///
    ///  If MouseRelativeSpeedScale is set, that will be applied after
    ///  system speed scale.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseRelativeSystemScale = SDL_HINT_MOUSE_RELATIVE_SYSTEM_SCALE;

    /// <summary>
    ///  A variable controlling whether a motion event should be generated for mouse
    ///  warping in relative mode.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Warping the mouse will not generate a motion event in relative mode
    ///  - '1': Warping the mouse will generate a motion event in relative mode
    ///
    ///  By default warping the mouse will not generate motion events in relative
    ///  mode. This avoids the application having to filter out large relative
    ///  motion due to warping.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseRelativeWarpMotion = SDL_HINT_MOUSE_RELATIVE_WARP_MOTION;

    /// <summary>
    ///  A variable controlling whether the hardware cursor stays visible when
    ///  relative mode is active.
    ///
    ///  This variable can be set to the following values:
    ///
    ///  - '0': The cursor will be hidden while relative mode is active (default)
    ///  - '1': The cursor will remain visible while relative mode is active
    ///
    ///  Note that for systems without raw hardware inputs, relative mode is
    ///  implemented using warping, so the hardware cursor will visibly warp between
    ///  frames if this is enabled on those systems.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseRelativeCursorVisible = SDL_HINT_MOUSE_RELATIVE_CURSOR_VISIBLE;

    /// <summary>
    ///  A variable controlling whether mouse events should generate synthetic touch
    ///  events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Mouse events will not generate touch events. (default for desktop
    ///    platforms)
    ///  - '1': Mouse events will generate touch events. (default for mobile
    ///    platforms, such as Android and iOS)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    MouseTouchEvents = SDL_HINT_MOUSE_TOUCH_EVENTS;

    /// <summary>
    ///  A variable controlling whether the keyboard should be muted on the console.
    ///
    ///  Normally the keyboard is muted while SDL applications are running so that
    ///  keyboard input doesn't show up as key strokes on the console. This hint
    ///  allows you to turn that off for debugging purposes.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Allow keystrokes to go through to the console.
    ///  - '1': Mute keyboard input so it doesn't show up on the console. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    MuteConsoleKeyboard = SDL_HINT_MUTE_CONSOLE_KEYBOARD;

    /// <summary>
    ///  Tell SDL not to catch the SIGINT or SIGTERM signals on POSIX platforms.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': SDL will install a SIGINT and SIGTERM handler, and when it catches a
    ///    signal, convert it into an TSdlEventKind.Quit event. (default)
    ///  - '1': SDL will not install a signal handler at all.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    NoSignalHandlers = SDL_HINT_NO_SIGNAL_HANDLERS;

    /// <summary>
    ///  Specify the OpenGL library to load.
    ///
    ///  This hint should be set before creating an OpenGL window or creating an
    ///  OpenGL context. If this hint isn't set, SDL will choose a reasonable
    ///  default.
    /// </summary>
    OpenGLLibrary = SDL_HINT_OPENGL_LIBRARY;

    /// <summary>
    ///  Specify the EGL library to load.
    ///
    ///  This hint should be set before creating an OpenGL window or creating an
    ///  OpenGL context. This hint is only considered if SDL is using EGL to manage
    ///  OpenGL contexts. If this hint isn't set, SDL will choose a reasonable
    ///  default.
    /// </summary>
    EglLibrary = SDL_HINT_EGL_LIBRARY;

    /// <summary>
    ///  A variable controlling what driver to use for OpenGL ES contexts.
    ///
    ///  On some platforms, currently Windows and X11, OpenGL drivers may support
    ///  creating contexts with an OpenGL ES profile. By default SDL uses these
    ///  profiles, when available, otherwise it attempts to load an OpenGL ES
    ///  library, e.g. that provided by the ANGLE project. This variable controls
    ///  whether SDL follows this default behaviour or will always load an OpenGL ES
    ///  library.
    ///
    ///  Circumstances where this is useful include - Testing an app with a
    ///  particular OpenGL ES implementation, e.g ANGLE, or emulator, e.g. those
    ///  from ARM, Imagination or Qualcomm. - Resolving OpenGL ES function addresses
    ///  at link time by linking with the OpenGL ES library instead of querying them
    ///  at run time with TSdlGL.GetProcAddress.
    ///
    ///  Caution: for an application to work with the default behaviour across
    ///  different OpenGL drivers it must query the OpenGL ES function addresses at
    ///  run time using TSdlGL.GetProcAddress.
    ///
    ///  This variable is ignored on most platforms because OpenGL ES is native or
    ///  not supported.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use ES profile of OpenGL, if available. (default)
    ///  - '1': Load OpenGL ES library using the default library names.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    OpenGlesDriver = SDL_HINT_OPENGL_ES_DRIVER;

    /// <summary>
    ///  Mechanism to specify openvr_api library location
    ///
    ///  By default, when using the OpenVR driver, it will search for the API
    ///  library in the current folder. But, if you wish to use a system API you can
    ///  specify that by using this hint. This should be the full or relative path
    ///  to a .dll on Windows or .so on Linux.
    /// </summary>
    OpenVRLibrary = SDL_HINT_OPENVR_LIBRARY;

    /// <summary>
    ///  A variable controlling which orientations are allowed on iOS/Android.
    ///
    ///  In some circumstances it is necessary to be able to explicitly control
    ///  which UI orientations are allowed.
    ///
    ///  This variable is a space delimited list of the following values:
    ///
    ///  - 'LandscapeLeft'
    ///  - 'LandscapeRight'
    ///  - 'Portrait'
    ///  - 'PortraitUpsideDown'
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    Orientations = SDL_HINT_ORIENTATIONS;

    /// <summary>
    ///  A variable controlling the use of a sentinel event when polling the event
    ///  queue.
    ///
    ///  When polling for events, TSdlEvents.Pump is used to gather new events from
    ///  devices. If a device keeps producing new events between calls to
    ///  TSdlEvents.Pump, a poll loop will become stuck until the new events stop.
    ///  This is most noticeable when moving a high frequency mouse.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable poll sentinels.
    ///  - '1': Enable poll sentinels. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    PollSentinel = SDL_HINT_POLL_SENTINEL;

    /// <summary>
    ///  Override for TSdlLocale.PreferredLocales.
    ///
    ///  If set, this will be favored over anything the OS might report for the
    ///  user's preferred locales. Changing this hint at runtime will not generate a
    ///  TSdlEventKind.LocaleChanged event (but if you can change the hint, you can
    ///  push your own event, if you want).
    ///
    ///  The format of this hint is a comma-separated list of language and locale,
    ///  combined with an underscore, as is a common format: 'en_GB'. Locale is
    ///  optional: 'en'. So you might have a list like this: 'en_GB,jp,es_PT'
    ///
    ///  This hint can be set anytime.
    /// </summary>
    PreferredLocales = SDL_HINT_PREFERRED_LOCALES;

    /// <summary>
    ///  A variable that decides whether to send TSdlEventKind.Quit when closing the
    ///  last window.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': SDL will not send an TSdlEventKind.Quit event when the last window is
    ///    requesting to close. Note that in this case, there are still other
    ///    legitimate reasons one might get an TSdlEventKind.Quit event: choosing 'Quit'
    ///    from the macOS menu bar, sending a SIGINT (ctrl-c) on Unix, etc.
    ///  - '1': SDL will send a quit event when the last window is requesting to
    ///    close. (default)
    ///
    ///  If there is at least one active system tray icon, TSdlEventKind.Quit will
    ///  instead be sent when both the last window will be closed and the last tray
    ///  icon will be destroyed.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    QuitOnLastWindowClose = SDL_HINT_QUIT_ON_LAST_WINDOW_CLOSE;

    /// <summary>
    ///  A variable controlling whether the Direct3D device is initialized for
    ///  thread-safe operations.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Thread-safety is not enabled. (default)
    ///  - '1': Thread-safety is enabled.
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderDirect3DThreadSafe = SDL_HINT_RENDER_DIRECT3D_THREADSAFE;

    /// <summary>
    ///  A variable controlling whether to enable Direct3D 11+'s Debug Layer.
    ///
    ///  This variable does not have any effect on the Direct3D 9 based renderer.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable Debug Layer use. (default)
    ///  - '1': Enable Debug Layer use.
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderDirect3D11Debug = SDL_HINT_RENDER_DIRECT3D11_DEBUG;

    /// <summary>
    ///  A variable controlling whether to enable Vulkan Validation Layers.
    ///
    ///  This variable can be set to the following values:
    ///
    ///  - '0': Disable Validation Layer use
    ///  - '1': Enable Validation Layer use
    ///
    ///  By default, SDL does not use Vulkan Validation Layers.
    /// </summary>
    RenderVulkanDebug = SDL_HINT_RENDER_VULKAN_DEBUG;

    /// <summary>
    ///  A variable controlling whether to create the GPU device in debug mode.
    ///
    ///  This variable can be set to the following values:
    ///
    ///  - '0': Disable debug mode use (default)
    ///  - '1': Enable debug mode use
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderGpuDebug = SDL_HINT_RENDER_GPU_DEBUG;

    /// <summary>
    ///  A variable controlling whether to prefer a low-power GPU on multi-GPU
    ///  systems.
    ///
    ///  This variable can be set to the following values:
    ///
    ///  - '0': Prefer high-performance GPU (default)
    ///  - '1': Prefer low-power GPU
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderGpuLowPower = SDL_HINT_RENDER_GPU_LOW_POWER;

    /// <summary>
    ///  A variable specifying which render driver to use.
    ///
    ///  If the application doesn't pick a specific renderer to use, this variable
    ///  specifies the name of the preferred renderer. If the preferred renderer
    ///  can't be initialized, creating a renderer will fail.
    ///
    ///  This variable is case insensitive and can be set to the following values:
    ///
    ///  - 'direct3d'
    ///  - 'direct3d11'
    ///  - 'direct3d12'
    ///  - 'opengl'
    ///  - 'opengles2'
    ///  - 'opengles'
    ///  - 'metal'
    ///  - 'vulkan'
    ///  - 'gpu'
    ///  - 'software'
    ///
    ///  This hint accepts a comma-separated list of driver names, and each will be
    ///  tried in the order listed when creating a renderer until one succeeds or
    ///  all of them fail.
    ///
    ///  The default varies by platform, but it's the first one in the list that is
    ///  available on the current platform.
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderDriver = SDL_HINT_RENDER_DRIVER;

    /// <summary>
    ///  A variable controlling how the 2D render API renders lines.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use the default line drawing method (Bresenham's line algorithm)
    ///  - '1': Use the driver point API using Bresenham's line algorithm (correct,
    ///    draws many points)
    ///  - '2': Use the driver line API (occasionally misses line endpoints based on
    ///    hardware driver quirks
    ///  - '3': Use the driver geometry API (correct, draws thicker diagonal lines)
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderLineMethod = SDL_HINT_RENDER_LINE_METHOD;

    /// <summary>
    ///  A variable controlling whether the Metal render driver select low power
    ///  device over default one.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use the preferred OS device. (default)
    ///  - '1': Select a low power device.
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderMetalPreferLowPowerDevice = SDL_HINT_RENDER_METAL_PREFER_LOW_POWER_DEVICE;

    /// <summary>
    ///  A variable controlling whether updates to the SDL screen surface should be
    ///  synchronized with the vertical refresh, to avoid tearing.
    ///
    ///  This hint overrides the application preference when creating a renderer.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable vsync. (default)
    ///  - '1': Enable vsync.
    ///
    ///  This hint should be set before creating a renderer.
    /// </summary>
    RenderVSync = SDL_HINT_RENDER_VSYNC;

    /// <summary>
    ///  A variable to control whether the return key on the soft keyboard should
    ///  hide the soft keyboard on Android and iOS.
    ///
    ///  This hint sets the default value of TSdlProperty.TextInputMultiLine.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The return key will be handled as a key event. (default)
    ///  - '1': The return key will hide the keyboard.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    ReturnKeyHideIme = SDL_HINT_RETURN_KEY_HIDES_IME;

    /// <summary>
    ///  A variable containing a list of ROG gamepad capable mice.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    /// <seealso cref='RogGamepadMiceExcluded'/>
    RogGamepadMice = SDL_HINT_ROG_GAMEPAD_MICE;

    /// <summary>
    ///  A variable containing a list of devices that are not ROG gamepad capable
    ///  mice.
    ///
    ///  This will override RogGamepadMice and the built in device list.
    ///
    ///  The format of the string is a comma separated list of USB VID/PID pairs in
    ///  hexadecimal form, e.g.
    ///
    ///  `0xAAAA/0xBBBB,0xCCCC/0xDDDD`
    ///
    ///  The variable can also take the form of '@file', in which case the named
    ///  file will be loaded and interpreted as the value of the variable.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    RogGamepadMiceExcluded = SDL_HINT_ROG_GAMEPAD_MICE_EXCLUDED;

    /// <summary>
    ///  A variable controlling which Dispmanx layer to use on a Raspberry PI.
    ///
    ///  Also known as Z-order. The variable can take a negative or positive value.
    ///  The default is 10000.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    RpiVideoLayer = SDL_HINT_RPI_VIDEO_LAYER;

    /// <summary>
    ///  Specify an 'activity name' for screensaver inhibition.
    ///
    ///  Some platforms, notably Linux desktops, list the applications which are
    ///  inhibiting the screensaver or other power-saving features.
    ///
    ///  This hint lets you specify the 'activity name' sent to the OS when
    ///  TSdlScreenSaver.Disable is used (or the screensaver is automatically
    ///  disabled). The contents of this hint are used when the screensaver is
    ///  disabled. You should use a string that describes what your program is doing
    ///  (and, therefore, why the screensaver is disabled). For example, 'Playing a
    ///  game' or 'Watching a video'.
    ///
    ///  Setting this to '' or leaving it unset will have SDL use a reasonable
    ///  default: 'Playing a game' or something similar.
    ///
    ///  This hint should be set before calling TSdlScreenSaver.Disable.
    /// </summary>
    ScreenSaverInhibitActivityName = SDL_HINT_SCREENSAVER_INHIBIT_ACTIVITY_NAME;

    /// <summary>
    ///  A variable controlling whether SDL calls dbus_shutdown on quit.
    ///
    ///  This is useful as a debug tool to validate memory leaks, but shouldn't ever
    ///  be set in production applications, as other libraries used by the
    ///  application might use dbus under the hood and this can cause crashes if
    ///  they continue after SdlQuit.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': SDL will not call dbus_shutdown on quit. (default)
    ///  - '1': SDL will call dbus_shutdown on quit.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    ShutdownDbusOnQuit = SDL_HINT_SHUTDOWN_DBUS_ON_QUIT;

    /// <summary>
    ///  A variable that specifies a backend to use for title storage.
    ///
    ///  By default, SDL will try all available storage backends in a reasonable
    ///  order until it finds one that can work, but this hint allows the app or
    ///  user to force a specific target, such as 'pc' if, say, you are on Steam but
    ///  want to avoid SteamRemoteStorage for title data.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    StorageTitleDriver = SDL_HINT_STORAGE_TITLE_DRIVER;

    /// <summary>
    ///  A variable that specifies a backend to use for user storage.
    ///
    ///  By default, SDL will try all available storage backends in a reasonable
    ///  order until it finds one that can work, but this hint allows the app or
    ///  user to force a specific target, such as 'pc' if, say, you are on Steam but
    ///  want to avoid SteamRemoteStorage for user data.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    StorageUsbDriver = SDL_HINT_STORAGE_USER_DRIVER;

    /// <summary>
    ///  Specifies whether TSdlThreadPriority.TimeCritical should be treated as
    ///  realtime.
    ///
    ///  On some platforms, like Linux, a realtime priority thread may be subject to
    ///  restrictions that require special handling by the application. This hint
    ///  exists to let SDL know that the app is prepared to handle said
    ///  restrictions.
    ///
    ///  On Linux, SDL will apply the following configuration to any thread that
    ///  becomes realtime:
    ///
    ///  - The SCHED_RESET_ON_FORK bit will be set on the scheduling policy,
    ///  - An RLIMIT_RTTIME budget will be configured to the rtkit specified limit.
    ///  - Exceeding this limit will result in the kernel sending SIGKILL to the
    ///    app, refer to the man pages for more information.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': default platform specific behaviour
    ///  - '1': Force TSdlThreadPriority.TimeCritical to a realtime scheduling
    ///    policy
    ///
    ///  This hint should be set before calling TSdlThread.Current.Priority.
    /// </summary>
    ThreadForceRealtimeTimeCritical = SDL_HINT_THREAD_FORCE_REALTIME_TIME_CRITICAL;

    /// <summary>
    ///  A string specifying additional information to use with
    ///  TSdlThread.Current.Priority.
    ///
    ///  By default TSdlThread.Current.Priority will make appropriate system
    ///  changes in order to apply a thread priority. For example on systems using
    ///  pthreads the scheduler policy is changed automatically to a policy that
    ///  works well with a given priority. Code which has specific requirements can
    ///  override SDL's default behavior with this hint.
    ///
    ///  pthread hint values are 'current', 'other', 'fifo' and 'rr'. Currently no
    ///  other platform hint values are defined but may be in the future.
    ///
    ///  On Linux, the kernel may send SIGKILL to realtime tasks which exceed the
    ///  distro configured execution budget for rtkit. This budget can be queried
    ///  through RLIMIT_RTTIME after calling TSdlThread.Current.Priority.
    ///
    ///  This hint should be set before calling TSdlThread.Current.Priority.
    /// </summary>
    ThreadPriorityPolicy = SDL_HINT_THREAD_PRIORITY_POLICY;

    /// <summary>
    ///  A variable that controls the timer resolution, in milliseconds.
    ///
    ///  The higher resolution the timer, the more frequently the CPU services timer
    ///  interrupts, and the more precise delays are, but this takes up power and
    ///  CPU time. This hint is only used on Windows.
    ///
    ///  See <see href="http://randomascii.wordpress.com/2013/07/08/windows-timer-resolution-megawatts-wasted/">this blog post</see> for more information.
    ///
    ///  The default value is '1'.
    ///
    ///  If this variable is set to '0', the system timer resolution is not set.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    TimerResolution = SDL_HINT_TIMER_RESOLUTION;

    /// <summary>
    ///  A variable controlling whether touch events should generate synthetic mouse
    ///  events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Touch events will not generate mouse events.
    ///  - '1': Touch events will generate mouse events. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    TouchMouseEvents = SDL_HINT_TOUCH_MOUSE_EVENTS;

    /// <summary>
    ///  A variable controlling whether trackpads should be treated as touch
    ///  devices.
    ///
    ///  On macOS (and possibly other platforms in the future), SDL will report
    ///  touches on a trackpad as mouse input, which is generally what users expect
    ///  from this device; however, these are often actually full multitouch-capable
    ///  touch devices, so it might be preferable to some apps to treat them as
    ///  such.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Trackpad will send mouse events. (default)
    ///  - '1': Trackpad will send touch events.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    TrackpadIsTouchOnly = SDL_HINT_TRACKPAD_IS_TOUCH_ONLY;

    /// <summary>
    ///  A variable controlling whether the Android / tvOS remotes should be listed
    ///  as joystick devices, instead of sending keyboard events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Remotes send enter/escape/arrow key events.
    ///  - '1': Remotes are available as 2 axis, 2 button joysticks. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    TVRemoteAsJoystick = SDL_HINT_TV_REMOTE_AS_JOYSTICK;

    /// <summary>
    ///  A variable controlling whether the screensaver is enabled.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable screensaver. (default)
    ///  - '1': Enable screensaver.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoAllowScreensave = SDL_HINT_VIDEO_ALLOW_SCREENSAVER;

    /// <summary>
    ///  A comma separated list containing the names of the displays that SDL should
    ///  sort to the front of the display list.
    ///
    ///  When this hint is set, displays with matching name strings will be
    ///  prioritized in the list of displays, as exposed by calling
    ///  TSdlDisplay.Displays, with the first listed becoming the primary display. The
    ///  naming convention can vary depending on the environment, but it is usually
    ///  a connector name (e.g. 'DP-1', 'DP-2', 'HDMI-A-1',etc...).
    ///
    ///  On Wayland and X11 desktops, the connector names associated with displays
    ///  can typically be found by using the `xrandr` utility.
    ///
    ///  This hint is currently supported on the following drivers:
    ///
    ///  - KMSDRM (kmsdrm)
    ///  - Wayland (wayland)
    ///  - X11 (x11)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoDisplayPriority = SDL_HINT_VIDEO_DISPLAY_PRIORITY;

    /// <summary>
    ///  Tell the video driver that we only want a double buffer.
    ///
    ///  By default, most lowlevel 2D APIs will use a triple buffer scheme that
    ///  wastes no CPU time on waiting for vsync after issuing a flip, but
    ///  introduces a frame of latency. On the other hand, using a double buffer
    ///  scheme instead is recommended for cases where low latency is an important
    ///  factor because we save a whole frame of latency.
    ///
    ///  We do so by waiting for vsync immediately after issuing a flip, usually
    ///  just after eglSwapBuffers call in the backend's *_SwapWindow function.
    ///
    ///  This hint is currently supported on the following drivers:
    ///
    ///  - Raspberry Pi (raspberrypi)
    ///  - Wayland (wayland)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoDoubleBuffer = SDL_HINT_VIDEO_DOUBLE_BUFFER;

    /// <summary>
    ///  A variable that specifies a video backend to use.
    ///
    ///  By default, SDL will try all available video backends in a reasonable order
    ///  until it finds one that can work, but this hint allows the app or user to
    ///  force a specific target, such as 'x11' if, say, you are on Wayland but want
    ///  to try talking to the X server instead.
    ///
    ///  This hint accepts a comma-separated list of driver names, and each will be
    ///  tried in the order listed during init, until one succeeds or all of them
    ///  fail.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoDriver = SDL_HINT_VIDEO_DRIVER;

    /// <summary>
    ///  A variable controlling whether the dummy video driver saves output frames.
    ///
    ///  - '0': Video frames are not saved to disk. (default)
    ///  - '1': Video frames are saved to files in the format 'SDL_windowX-Y.bmp',
    ///    where X is the window ID, and Y is the frame number.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    VideoDummySaveFrames = SDL_HINT_VIDEO_DUMMY_SAVE_FRAMES;

    /// <summary>
    ///  If eglGetPlatformDisplay fails, fall back to calling eglGetDisplay.
    ///
    ///  The variable can be set to one of the following values:
    ///
    ///  - '0': Do not fall back to eglGetDisplay.
    ///  - '1': Fall back to eglGetDisplay if eglGetPlatformDisplay fails. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoEglAllowGetDisplayFallback = SDL_HINT_VIDEO_EGL_ALLOW_GETDISPLAY_FALLBACK;

    /// <summary>
    ///  A variable controlling whether the OpenGL context should be created with
    ///  EGL.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use platform-specific GL context creation API (GLX, WGL, CGL, etc).
    ///    (default)
    ///  - '1': Use EGL
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoForceEgl = SDL_HINT_VIDEO_FORCE_EGL;

    /// <summary>
    ///  A variable that specifies the policy for fullscreen Spaces on macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable Spaces support (TSdlWindowFlag.FullscreenDesktop won't
    ///    use them and TSdlWindowFlag.Resizable windows won't offer the
    ///    'fullscreen' button on their titlebars).
    ///  - '1': Enable Spaces support (TSdlWindowFlag.FullscreenDesktop will use
    ///    them and TSdlWindowFlag.Resizable windows will offer the 'fullscreen'
    ///    button on their titlebars). (default)
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    VideoMacFullscreenSpaces = SDL_HINT_VIDEO_MAC_FULLSCREEN_SPACES;

    /// <summary>
    ///  A variable that specifies the menu visibility when a window is fullscreen
    ///  in Spaces on macOS.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The menu will be hidden when the window is in a fullscreen space,
    ///    and not accessible by moving the mouse to the top of the screen.
    ///  - '1': The menu will be accessible when the window is in a fullscreen
    ///    space.
    ///  - 'auto': The menu will be hidden if fullscreen mode was toggled on
    ///    programmatically via `TSdlWindow.Fullscreen`, and accessible if
    ///    fullscreen was entered via the 'fullscreen' button on the window title
    ///    bar. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    VideoMacFullscreenMenuVisibility = SDL_HINT_VIDEO_MAC_FULLSCREEN_MENU_VISIBILITY;

    /// <summary>
    ///  A variable controlling whether fullscreen windows are minimized when they
    ///  lose focus.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Fullscreen windows will not be minimized when they lose focus.
    ///    (default)
    ///  - '1': Fullscreen windows are minimized when they lose focus.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    VideoMinimizeOnFocusLoss = SDL_HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS;

    /// <summary>
    ///  A variable controlling whether the offscreen video driver saves output
    ///  frames.
    ///
    ///  This only saves frames that are generated using software rendering, not
    ///  accelerated OpenGL rendering.
    ///
    ///  - '0': Video frames are not saved to disk. (default)
    ///  - '1': Video frames are saved to files in the format 'SDL_windowX-Y.bmp',
    ///    where X is the window ID, and Y is the frame number.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    VideoOffScreenSaveFrames = SDL_HINT_VIDEO_OFFSCREEN_SAVE_FRAMES;

    /// <summary>
    ///  A variable controlling whether all window operations will block until
    ///  complete.
    ///
    ///  Window systems that run asynchronously may not have the results of window
    ///  operations that resize or move the window applied immediately upon the
    ///  return of the requesting function. Setting this hint will cause such
    ///  operations to block after every call until the pending operation has
    ///  completed. Setting this to '1' is the equivalent of calling
    ///  TSdlWindow.Sync after every function call.
    ///
    ///  Be aware that amount of time spent blocking while waiting for window
    ///  operations to complete can be quite lengthy, as animations may have to
    ///  complete, which can take upwards of multiple seconds in some cases.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Window operations are non-blocking. (default)
    ///  - '1': Window operations will block until completed.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    VideoSyncWindowOperations = SDL_HINT_VIDEO_SYNC_WINDOW_OPERATIONS;

    /// <summary>
    ///  A variable controlling whether the libdecor Wayland backend is allowed to
    ///  be used.
    ///
    ///  libdecor is used over xdg-shell when xdg-decoration protocol is
    ///  unavailable.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': libdecor use is disabled.
    ///  - '1': libdecor use is enabled. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoWaylandAllowLibDecor = SDL_HINT_VIDEO_WAYLAND_ALLOW_LIBDECOR;

    /// <summary>
    ///  A variable controlling whether video mode emulation is enabled under
    ///  Wayland.
    ///
    ///  When this hint is set, a standard set of emulated CVT video modes will be
    ///  exposed for use by the application. If it is disabled, the only modes
    ///  exposed will be the logical desktop size and, in the case of a scaled
    ///  desktop, the native display resolution.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Video mode emulation is disabled.
    ///  - '1': Video mode emulation is enabled. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoWaylandModeEmulation = SDL_HINT_VIDEO_WAYLAND_MODE_EMULATION;

    /// <summary>
    ///  A variable controlling how modes with a non-native aspect ratio are
    ///  displayed under Wayland.
    ///
    ///  When this hint is set, the requested scaling will be used when displaying
    ///  fullscreen video modes that don't match the display's native aspect ratio.
    ///  This is contingent on compositor viewport support.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'aspect' - Video modes will be displayed scaled, in their proper aspect
    ///    ratio, with black bars.
    ///  - 'stretch' - Video modes will be scaled to fill the entire display.
    ///    (default)
    ///  - 'none' - Video modes will be displayed as 1:1 with no scaling.
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    VideoWaylandModeScaling = SDL_HINT_VIDEO_WAYLAND_MODE_SCALING;

    /// <summary>
    ///  A variable controlling whether the libdecor Wayland backend is preferred
    ///  over native decorations.
    ///
    ///  When this hint is set, libdecor will be used to provide window decorations,
    ///  even if xdg-decoration is available. (Note that, by default, libdecor will
    ///  use xdg-decoration itself if available).
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': libdecor is enabled only if server-side decorations are unavailable.
    ///    (default)
    ///  - '1': libdecor is always enabled if available.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoWaylandPreferLibDecor = SDL_HINT_VIDEO_WAYLAND_PREFER_LIBDECOR;

    /// <summary>
    ///  A variable forcing non-DPI-aware Wayland windows to output at 1:1 scaling.
    ///
    ///  This must be set before initializing the video subsystem.
    ///
    ///  When this hint is set, Wayland windows that are not flagged as being
    ///  DPI-aware will be output with scaling designed to force 1:1 pixel mapping.
    ///
    ///  This is intended to allow legacy applications to be displayed without
    ///  desktop scaling being applied, and has issues with certain display
    ///  configurations, as this forces the window to behave in a way that Wayland
    ///  desktops were not designed to accommodate:
    ///
    ///  - Rounding errors can result with odd window sizes and/or desktop scales,
    ///    which can cause the window contents to appear slightly blurry.
    ///  - Positioning the window may be imprecise due to unit conversions and
    ///    rounding.
    ///  - The window may be unusably small on scaled desktops.
    ///  - The window may jump in size when moving between displays of different
    ///    scale factors.
    ///  - Displays may appear to overlap when using a multi-monitor setup with
    ///    scaling enabled.
    ///  - Possible loss of cursor precision due to the logical size of the window
    ///    being reduced.
    ///
    ///  New applications should be designed with proper DPI awareness handling
    ///  instead of enabling this.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Windows will be scaled normally.
    ///  - '1': Windows will be forced to scale to achieve 1:1 output.
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    VideoWaylandScaleToDisplay = SDL_HINT_VIDEO_WAYLAND_SCALE_TO_DISPLAY;

    /// <summary>
    ///  A variable specifying which shader compiler to preload when using the
    ///  Chrome ANGLE binaries.
    ///
    ///  SDL has EGL and OpenGL ES2 support on Windows via the ANGLE project. It can
    ///  use two different sets of binaries, those compiled by the user from source
    ///  or those provided by the Chrome browser. In the later case, these binaries
    ///  require that SDL loads a DLL providing the shader compiler.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'd3dcompiler_46.dll' - best for Vista or later. (default)
    ///  - 'd3dcompiler_43.dll' - for XP support.
    ///  - 'none' - do not load any library, useful if you compiled ANGLE from
    ///    source and included the compiler in your binaries.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoWinD3DCompiler = SDL_HINT_VIDEO_WIN_D3DCOMPILER;

    /// <summary>
    ///  A variable controlling whether the X11 _NET_WM_BYPASS_COMPOSITOR hint
    ///  should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable _NET_WM_BYPASS_COMPOSITOR.
    ///  - '1': Enable _NET_WM_BYPASS_COMPOSITOR. (default)
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    VideoX11NetWMBypassCompositor = SDL_HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR;

    /// <summary>
    ///  A variable controlling whether the X11 _NET_WM_PING protocol should be
    ///  supported.
    ///
    ///  By default SDL will use _NET_WM_PING, but for applications that know they
    ///  will not always be able to respond to ping requests in a timely manner they
    ///  can turn it off to avoid the window manager thinking the app is hung.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable _NET_WM_PING.
    ///  - '1': Enable _NET_WM_PING. (default)
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    VideoX11NetWMPing = SDL_HINT_VIDEO_X11_NET_WM_PING;

    /// <summary>
    ///  A variable controlling whether SDL uses DirectColor visuals.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable DirectColor visuals.
    ///  - '1': Enable DirectColor visuals. (default)
    ///
    ///  This hint should be set before initializing the video subsystem.
    /// </summary>
    VideoX11NoDirectColor = SDL_HINT_VIDEO_X11_NODIRECTCOLOR;

    /// <summary>
    ///  A variable forcing the content scaling factor for X11 displays.
    ///
    ///  The variable can be set to a floating point value in the range 1.0-10.0
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoX11ScalingFactor = SDL_HINT_VIDEO_X11_SCALING_FACTOR;

    /// <summary>
    ///  A variable forcing the visual ID used for X11 display modes.
    ///
    ///  This hint should be set before initializing the video subsystem.
    /// </summary>
    VideoX11VisualID = SDL_HINT_VIDEO_X11_VISUALID;

    /// <summary>
    ///  A variable forcing the visual ID chosen for new X11 windows.
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    VideoX11WindowVisualID = SDL_HINT_VIDEO_X11_WINDOW_VISUALID;

    /// <summary>
    ///  A variable controlling whether the X11 XRandR extension should be used.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable XRandR.
    ///  - '1': Enable XRandR. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VideoX11XRandR = SDL_HINT_VIDEO_X11_XRANDR;

    /// <summary>
    ///  A variable controlling whether touch should be enabled on the back panel of
    ///  the PlayStation Vita.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable touch on the back panel.
    ///  - '1': Enable touch on the back panel. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VitaEnableBackTouch = SDL_HINT_VITA_ENABLE_BACK_TOUCH;

    /// <summary>
    ///  A variable controlling whether touch should be enabled on the front panel
    ///  of the PlayStation Vita.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Disable touch on the front panel.
    ///  - '1': Enable touch on the front panel. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VitaEnableFrontTouch = SDL_HINT_VITA_ENABLE_FRONT_TOUCH;

    /// <summary>
    ///  A variable controlling the module path on the PlayStation Vita.
    ///
    ///  This hint defaults to 'app0:module'
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VitaModulePath = SDL_HINT_VITA_MODULE_PATH;

    /// <summary>
    ///  A variable controlling whether to perform PVR initialization on the
    ///  PlayStation Vita.
    ///
    ///  - '0': Skip PVR initialization.
    ///  - '1': Perform the normal PVR initialization. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VitaPvrInit = SDL_HINT_VITA_PVR_INIT;

    /// <summary>
    ///  A variable overriding the resolution reported on the PlayStation Vita.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '544': 544p (default)
    ///  - '720': 725p for PSTV
    ///  - '1080': 1088i for PSTV
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VitaResolution = SDL_HINT_VITA_RESOLUTION;

    /// <summary>
    ///  A variable controlling whether OpenGL should be used instead of OpenGL ES
    ///  on the PlayStation Vita.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use OpenGL ES. (default)
    ///  - '1': Use OpenGL.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    VitaPvrOpenGL = SDL_HINT_VITA_PVR_OPENGL;

    /// <summary>
    ///  A variable controlling which touchpad should generate synthetic mouse
    ///  events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Only front touchpad should generate mouse events. (default)
    ///  - '1': Only back touchpad should generate mouse events.
    ///  - '2': Both touchpads should generate mouse events.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    VitaTouchMouseDevice = SDL_HINT_VITA_TOUCH_MOUSE_DEVICE;

    /// <summary>
    ///  A variable overriding the display index used in SdlVulkanCreateSurface.
    ///
    ///  The display index starts at 0, which is the default.
    ///
    ///  This hint should be set before calling SdlVulkanCreateSurface.
    /// </summary>
    VulkanDisplay = SDL_HINT_VULKAN_DISPLAY;

    /// <summary>
    ///  Specify the Vulkan library to load.
    ///
    ///  This hint should be set before creating a Vulkan window or calling
    ///  SdlVulkanLoadLibrary.
    /// </summary>
    VulkanLibrary = SDL_HINT_VULKAN_LIBRARY;

    /// <summary>
    ///  A variable controlling how the fact chunk affects the loading of a WAVE
    ///  file.
    ///
    ///  The fact chunk stores information about the number of samples of a WAVE
    ///  file. The Standards Update from Microsoft notes that this value can be used
    ///  to 'determine the length of the data in seconds'. This is especially useful
    ///  for compressed formats (for which this is a mandatory chunk) if they
    ///  produce multiple sample frames per block and truncating the block is not
    ///  allowed. The fact chunk can exactly specify how many sample frames there
    ///  should be in this case.
    ///
    ///  Unfortunately, most application seem to ignore the fact chunk and so SDL
    ///  ignores it by default as well.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'truncate' - Use the number of samples to truncate the wave data if the
    ///    fact chunk is present and valid.
    ///  - 'strict' - Like 'truncate', but raise an error if the fact chunk is
    ///    invalid, not present for non-PCM formats, or if the data chunk doesn't
    ///    have that many samples.
    ///  - 'ignorezero' - Like 'truncate', but ignore fact chunk if the number of
    ///    samples is zero.
    ///  - 'ignore' - Ignore fact chunk entirely. (default)
    ///
    ///  This hint should be set before calling TSdlAudioBuffer.CreateFromWav.
    /// </summary>
    WaveFactChunk = SDL_HINT_WAVE_FACT_CHUNK;

    /// <summary>
    ///  A variable controlling the maximum number of chunks in a WAVE file.
    ///
    ///  This sets an upper bound on the number of chunks in a WAVE file to avoid
    ///  wasting time on malformed or corrupt WAVE files. This defaults to '10000'.
    ///
    ///  This hint should be set before calling TSdlAudioBuffer.CreateFromWav.
    /// </summary>
    WaveChunkLimit = SDL_HINT_WAVE_CHUNK_LIMIT;

    /// <summary>
    ///  A variable controlling how the size of the RIFF chunk affects the loading
    ///  of a WAVE file.
    ///
    ///  The size of the RIFF chunk (which includes all the sub-chunks of the WAVE
    ///  file) is not always reliable. In case the size is wrong, it's possible to
    ///  just ignore it and step through the chunks until a fixed limit is reached.
    ///
    ///  Note that files that have trailing data unrelated to the WAVE file or
    ///  corrupt files may slow down the loading process without a reliable
    ///  boundary. By default, SDL stops after 10000 chunks to prevent wasting time.
    ///  Use WaveChunkLimit to adjust this value.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'force' - Always use the RIFF chunk size as a boundary for the chunk
    ///    search.
    ///  - 'ignorezero' - Like 'force', but a zero size searches up to 4 GiB.
    ///    (default)
    ///  - 'ignore' - Ignore the RIFF chunk size and always search up to 4 GiB.
    ///  - 'maximum' - Search for chunks until the end of file. (not recommended)
    ///
    ///  This hint should be set before calling TSdlAudioBuffer.CreateFromWav.
    /// </summary>
    WaveRiffChunkSize = SDL_HINT_WAVE_RIFF_CHUNK_SIZE;

    /// <summary>
    ///  A variable controlling how a truncated WAVE file is handled.
    ///
    ///  A WAVE file is considered truncated if any of the chunks are incomplete or
    ///  the data chunk size is not a multiple of the block size. By default, SDL
    ///  decodes until the first incomplete block, as most applications seem to do.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - 'verystrict' - Raise an error if the file is truncated.
    ///  - 'strict' - Like 'verystrict', but the size of the RIFF chunk is ignored.
    ///  - 'dropframe' - Decode until the first incomplete sample frame.
    ///  - 'dropblock' - Decode until the first incomplete block. (default)
    ///
    ///  This hint should be set before calling TSdlAudioBuffer.CreateFromWav.
    /// </summary>
    WaveTruncation = SDL_HINT_WAVE_TRUNCATION;

    /// <summary>
    ///  A variable controlling whether the window is activated when the
    ///  TSdlWindow.Raise function is called.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The window is not activated when the TSdlWindow.Raise function is
    ///    called.
    ///  - '1': The window is activated when the TSdlWindow.Raise function is called.
    ///    (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowActivateWhenRaised = SDL_HINT_WINDOW_ACTIVATE_WHEN_RAISED;

    /// <summary>
    ///  A variable controlling whether the window is activated when the
    ///  TSdlWindow.Show function is called.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The window is not activated when the TSdlWindow.Show function is
    ///    called.
    ///  - '1': The window is activated when the TSdlWindow.Show function is called.
    ///    (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowActivateWhenShown = SDL_HINT_WINDOW_ACTIVATE_WHEN_SHOWN;

    /// <summary>
    ///  If set to '0' then never set the top-most flag on an SDL Window even if the
    ///  application requests it.
    ///
    ///  This is a debugging aid for developers and not expected to be used by end
    ///  users.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': don't allow topmost
    ///  - '1': allow topmost (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowAllowTopMost = SDL_HINT_WINDOW_ALLOW_TOPMOST;

    /// <summary>
    ///  A variable controlling whether the window frame and title bar are
    ///  interactive when the cursor is hidden.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The window frame is not interactive when the cursor is hidden (no
    ///    move, resize, etc).
    ///  - '1': The window frame is interactive when the cursor is hidden. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowFrameUsableWhileCursorHidden = SDL_HINT_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN;

    /// <summary>
    ///  A variable controlling whether SDL generates window-close events for Alt+F4
    ///  on Windows.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': SDL will only do normal key handling for Alt+F4.
    ///  - '1': SDL will generate a window-close event when it sees Alt+F4.
    ///    (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowCloseOnAltF4 = SDL_HINT_WINDOWS_CLOSE_ON_ALT_F4;

    /// <summary>
    ///  A variable controlling whether menus can be opened with their keyboard
    ///  shortcut (Alt+mnemonic).
    ///
    ///  If the mnemonics are enabled, then menus can be opened by pressing the Alt
    ///  key and the corresponding mnemonic (for example, Alt+F opens the File
    ///  menu). However, in case an invalid mnemonic is pressed, Windows makes an
    ///  audible beep to convey that nothing happened. This is true even if the
    ///  window has no menu at all!
    ///
    ///  Because most SDL applications don't have menus, and some want to use the
    ///  Alt key for other purposes, SDL disables mnemonics (and the beeping) by
    ///  default.
    ///
    ///  Note: This also affects keyboard events: with mnemonics enabled, when a
    ///  menu is opened from the keyboard, you will not receive a KEYUP event for
    ///  the mnemonic key, and *might* not receive one for Alt.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Alt+mnemonic does nothing, no beeping. (default)
    ///  - '1': Alt+mnemonic opens menus, invalid mnemonics produce a beep.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowsEnableMenuMnemonics = SDL_HINT_WINDOWS_ENABLE_MENU_MNEMONICS;

    /// <summary>
    ///  A variable controlling whether the windows message loop is processed by
    ///  SDL.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The window message loop is not run.
    ///  - '1': The window message loop is processed in TSdlEvents.Pump. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowsEnableMessageLoop = SDL_HINT_WINDOWS_ENABLE_MESSAGELOOP;

    /// <summary>
    ///  A variable controlling whether GameInput is used for raw keyboard and mouse
    ///  on Windows.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': GameInput is not used for raw keyboard and mouse events.
    ///  - '1': GameInput is used for raw keyboard and mouse events, if available.
    ///    (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    WindowsGameInput = SDL_HINT_WINDOWS_GAMEINPUT;

    /// <summary>
    ///  A variable controlling whether raw keyboard events are used on Windows.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': The Windows message loop is used for keyboard events. (default)
    ///  - '1': Low latency raw keyboard events are used.
    ///
    ///  This hint can be set anytime.
    /// </summary>
    WindowsRawKeyboard = SDL_HINT_WINDOWS_RAW_KEYBOARD;

    /// <summary>
    ///  A variable controlling whether SDL uses Kernel Semaphores on Windows.
    ///
    ///  Kernel Semaphores are inter-process and require a context switch on every
    ///  interaction. On Windows 8 and newer, the WaitOnAddress API is available.
    ///  Using that and atomics to implement semaphores increases performance. SDL
    ///  will fall back to Kernel Objects on older OS versions or if forced to by
    ///  this hint.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use Atomics and WaitOnAddress API when available, otherwise fall
    ///    back to Kernel Objects. (default)
    ///  - '1': Force the use of Kernel Objects in all cases.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    WindowsForceSemaphoreKernel = SDL_HINT_WINDOWS_FORCE_SEMAPHORE_KERNEL;

    /// <summary>
    ///  A variable to specify custom icon resource id from RC file on Windows
    ///  platform.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    WindowsIntResourceIcon = SDL_HINT_WINDOWS_INTRESOURCE_ICON;

    /// <summary>
    ///  A variable to specify custom icon resource id from RC file on Windows
    ///  platform.
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    WindowsIntResourceIconSmall = SDL_HINT_WINDOWS_INTRESOURCE_ICON_SMALL;

    /// <summary>
    ///  A variable controlling whether SDL uses the D3D9Ex API introduced in
    ///  Windows Vista, instead of normal D3D9.
    ///
    ///  Direct3D 9Ex contains changes to state management that can eliminate device
    ///  loss errors during scenarios like Alt+Tab or UAC prompts. D3D9Ex may
    ///  require some changes to your application to cope with the new behavior, so
    ///  this is disabled by default.
    ///
    ///  For more information on Direct3D 9Ex, see:
    ///
    ///  - <see href="https://docs.microsoft.com/en-us/windows/win32/direct3darticles/graphics-apis-in-windows-vista#direct3d-9ex">Direct3D-9Ex</see>
    ///  - <see href="https://docs.microsoft.com/en-us/windows/win32/direct3darticles/direct3d-9ex-improvements">Direct3D 9Ex improvements</see>
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Use the original Direct3D 9 API. (default)
    ///  - '1': Use the Direct3D 9Ex API on Vista and later (and fall back if D3D9Ex
    ///    is unavailable)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    WindowsUseD3D9Ex = SDL_HINT_WINDOWS_USE_D3D9EX;

    /// <summary>
    ///  A variable controlling whether SDL will clear the window contents when the
    ///  WM_ERASEBKGND message is received.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0'/'never': Never clear the window.
    ///  - '1'/'initial': Clear the window when the first WM_ERASEBKGND event fires.
    ///    (default)
    ///  - '2'/'always': Clear the window on every WM_ERASEBKGND event.
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    WindowsEraseBackgroundMode = SDL_HINT_WINDOWS_ERASE_BACKGROUND_MODE;

    /// <summary>
    ///  A variable controlling whether X11 windows are marked as override-redirect.
    ///
    ///  If set, this _might_ increase framerate at the expense of the desktop not
    ///  working as expected. Override-redirect windows aren't noticed by the window
    ///  manager at all.
    ///
    ///  You should probably only use this for fullscreen windows, and you probably
    ///  shouldn't even use it for that. But it's here if you want to try!
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Do not mark the window as override-redirect. (default)
    ///  - '1': Mark the window as override-redirect.
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    X11ForceOverrideRedirect = SDL_HINT_X11_FORCE_OVERRIDE_REDIRECT;

    /// <summary>
    ///  A variable specifying the type of an X11 window.
    ///
    ///  During SDL_CreateWindow, SDL uses the _NET_WM_WINDOW_TYPE X11 property to
    ///  report to the window manager the type of window it wants to create. This
    ///  might be set to various things if TSdlWindowFlag.Tooltip or
    ///  TSdlWindowFlag.PopupMenu, etc, were specified. For 'normal' windows that
    ///  haven't set a specific type, this hint can be used to specify a custom
    ///  type. For example, a dock window might set this to
    ///  '_NET_WM_WINDOW_TYPE_DOCK'.
    ///
    ///  This hint should be set before creating a window.
    /// </summary>
    X11WindowType = SDL_HINT_X11_WINDOW_TYPE;

    /// <summary>
    ///  Specify the XCB library to load for the X11 driver.
    ///
    ///  The default is platform-specific, often 'libX11-xcb.so.1'.
    ///
    ///  This hint should be set before initializing the video subsystem.
    /// </summary>
    X11XcbLibrary = SDL_HINT_X11_XCB_LIBRARY;

    /// <summary>
    ///  A variable controlling whether XInput should be used for controller
    ///  handling.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': XInput is not enabled.
    ///  - '1': XInput is enabled. (default)
    ///
    ///  This hint should be set before SDL is initialized.
    /// </summary>
    XInputEnabled = SDL_HINT_XINPUT_ENABLED;

    /// <summary>
    ///  A variable controlling response to SdlAssert failures.
    ///
    ///  The variable can be set to the following case-sensitive values:
    ///
    ///  - 'abort': Program terminates immediately.
    ///  - 'break': Program triggers a debugger breakpoint.
    ///  - 'retry': Program reruns the SDL_assert's test again.
    ///  - 'ignore': Program continues on, ignoring this assertion failure this
    ///    time.
    ///  - 'always_ignore': Program continues on, ignoring this assertion failure
    ///    for the rest of the run.
    ///
    ///  Note that SdlSetAssertionHandler offers a programmatic means to deal with
    ///  assertion failures through a callback, and this hint is largely intended to
    ///  be used via environment variables by end users and automated tools.
    ///
    ///  This hint should be set before an assertion failure is triggered and can be
    ///  changed at any time.
    /// </summary>
    Assert = SDL_HINT_ASSERT;

    /// <summary>
    ///  A variable controlling whether pen events should generate synthetic mouse
    ///  events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Pen events will not generate mouse events.
    ///  - '1': Pen events will generate mouse events. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    PenMouseEvents = SDL_HINT_PEN_MOUSE_EVENTS;

    /// <summary>
    ///  A variable controlling whether pen events should generate synthetic touch
    ///  events.
    ///
    ///  The variable can be set to the following values:
    ///
    ///  - '0': Pen events will not generate touch events.
    ///  - '1': Pen events will generate touch events. (default)
    ///
    ///  This hint can be set anytime.
    /// </summary>
    PenTouchEvents = SDL_HINT_PEN_TOUCH_EVENTS;
  public
    /// <summary>
    ///  Set a hint with a specific priority.
    ///
    ///  The priority controls the behavior when setting a hint that already has a
    ///  value. Hints will replace existing hints of their priority and lower.
    ///  Environment variables are considered to have override priority.
    /// </summary>
    /// <param name="AName">The hint to set (one of the TSdlHints constants).</param>
    /// <param name="AValue">The value of the hint variable.</param>
    /// <param name="APriority">Priority level for the hint.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Get"/>
    /// <seealso cref="Reset"/>
    /// <seealso cref="Hints"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Apply(const AName: PUTF8Char; const AValue: String;
      const APriority: TSdlHintPriority); overload; inline; static;

    /// <summary>
    ///  Set a hint with normal priority.
    ///
    ///  Hints will not be set if there is an existing override hint or environment
    ///  variable that takes precedence. You can use the other overload to
    ///  set the hint with override priority instead.
    /// </summary>
    /// <param name="AName">The hint to set (one of the TSdlHints constants).</param>
    /// <param name="AValue">The value of the hint variable.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Get"/>
    /// <seealso cref="Reset"/>
    /// <seealso cref="Hints"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Apply(const AName: PUTF8Char; const AValue: String); overload; inline; static;

    /// <summary>
    ///  Reset a hint to the default value.
    ///
    ///  This will reset a hint to the value of the environment variable, or nil if
    ///  the environment isn't set. Callbacks will be called normally with this
    ///  change.
    /// </summary>
    /// <param name="AName">The hint to set (one of the TSdlHints constants).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Apply"/>
    /// <seealso cref="ResetAll"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure Reset(const AName: PUTF8Char); inline; static;

    /// <summary>
    ///  Reset all hints to the default values.
    ///
    ///  This will reset all hints to the value of the associated environment
    ///  variable, or nil if the environment isn't set. Callbacks will be called
    ///  normally with this change.
    /// </summary>
    /// <seealso cref="Reset"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure ResetAll; inline; static;

    /// <summary>
    ///  Get the value of a hint.
    /// </summary>
    /// <param name="AName">The hint to query (one of the TSdlHints constants).</param>
    /// <returns>The value of the hint or an empty string if the hint does not exist.</returns>
    /// <seealso cref="Apply"/>
    /// <seealso cref="Hints"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function Get(const AName: PUTF8Char): String; inline; static;

    /// <summary>
    ///  Get the Boolean value of a hint variable.
    /// </summary>
    /// <param name="AName">The name of the hint to get the boolean value from
    ///  (one of the TSdlHints constants).</param>
    /// <param name="ADefaultValue">(Optional) value to return if the hint does
    ///  not exist. Defaults to False.</param>
    /// <returns>The Boolean value of a hint or the provided default value if
    ///  the hint does not exist.</returns>
    /// <seealso cref="Get"/>
    /// <seealso cref="Apply"/>
    /// <seealso cref="Hints"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function GetBoolean(const AName: PUTF8Char;
      const ADefaultValue: Boolean = False): Boolean; inline; static;

    /// <summary>
    ///  Add a callback to watch a particular hint.
    ///
    ///  The callback function is called _during_ this method, to provide it an
    ///  initial value, and again each time the hint's value changes.
    /// </summary>
    /// <param name="AName">The hint to watch (one of the TSdlHints constants).</param>
    /// <param name="ACallback">TSdlHintCallback function that will be called
    ///  when the hint value changes.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="RemoveCallback"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure AddCallback(const AName: PUTF8Char;
      const ACallback: TSdlHintCallback); static;

    /// <summary>
    ///  Remove a callback watching a particular hint.
    /// </summary>
    /// <param name="AName">The hint being watched (one of the TSdlHints constants).</param>
    /// <param name="ACallback">TSdlHintCallback function that will be called when
    ///  the hint value changes.</param>
    /// <seealso cref="AddCallback"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class procedure RemoveCallback(const AName: PUTF8Char;
      const ACallback: TSdlHintCallback); static;

    /// <summary>
    ///  The hint values.
    ///
    ///  When getting, returns an empty string if not set.
    ///
    ///  When setting, it sets the hint with normal priority. Hints will not be
    ///  set if there is an existing override hint or environment variable that
    ///  takes precedence. You can use Apply with a priority to set the hint
    ///  with override priority instead.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Apply"/>
    /// <seealso cref="Get"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property Hints[const AName: PUTF8Char]: String read GetHint write SetHint; default;
  end;
{$ENDREGION 'Hints'}

{$REGION 'Properties'}
/// <summary>
///  A property is a variable that can be created and retrieved by name at
///  runtime.
///
///  All properties are part of a property group (TSdlProperties). A property
///  group can be created with the TSdlProperties.Create function and destroyed
///  with the TSdlProperties.Free function.
///
///  Properties can be added to and retrieved from a property group through the
///  following properties:
///
///  - AsPointer operates on pointer (or THandle) types.
///  - AsString operates on string types.
///  - AsNumber operates on signed 64-bit integer types.
///  - AsFloat operates on floating point types.
///  - AsBoolean operates on boolean types.
///
///  Properties can be removed from a group by using TSdlProperties.Delete.
/// </summary>

type
  /// <summary>
  ///  SDL property type
  /// </summary>
  TSdlPropertyType = (
    Invalid =  SDL_PROPERTY_TYPE_INVALID,
    Pointer  = SDL_PROPERTY_TYPE_POINTER,
    &String  = SDL_PROPERTY_TYPE_STRING,
    Number   = SDL_PROPERTY_TYPE_NUMBER,
    Float    = SDL_PROPERTY_TYPE_FLOAT,
    Bool     = SDL_PROPERTY_TYPE_BOOLEAN);

type
  /// <summary>
  ///  Standard SDL properties
  /// </summary>
  TSdlProperty = record
  public const
    (** Application metadata **)

    // String
    AppMetadataName       = SDL_PROP_APP_METADATA_NAME_STRING;

    // String
    AppMetadataVersion    = SDL_PROP_APP_METADATA_VERSION_STRING;

    // String
    AppMetadataIdentifier = SDL_PROP_APP_METADATA_IDENTIFIER_STRING;

    // String
    AppMetadataCreator    = SDL_PROP_APP_METADATA_CREATOR_STRING;

    // String
    AppMetadataCopyright  = SDL_PROP_APP_METADATA_COPYRIGHT_STRING;

    // String
    AppMetadataUrl        = SDL_PROP_APP_METADATA_URL_STRING;

    // String
    AppMetadataType       = SDL_PROP_APP_METADATA_TYPE_STRING;
  public const
    (** Window creation properties **)

    // Boolean
    WindowCreateAlwaysOnTop             = SDL_PROP_WINDOW_CREATE_ALWAYS_ON_TOP_BOOLEAN;

    // Boolean
    WindowCreateBorderless              = SDL_PROP_WINDOW_CREATE_BORDERLESS_BOOLEAN;

    // Boolean
    WindowCreateFocusable               = SDL_PROP_WINDOW_CREATE_FOCUSABLE_BOOLEAN;

    // Boolean
    WindowCreateExternalGraphicsContext = SDL_PROP_WINDOW_CREATE_EXTERNAL_GRAPHICS_CONTEXT_BOOLEAN;

    // Number
    WindowCreateFlags                   = SDL_PROP_WINDOW_CREATE_FLAGS_NUMBER;

    // Boolean
    WindowCreateFullscreen              = SDL_PROP_WINDOW_CREATE_FULLSCREEN_BOOLEAN;

    // Number
    WindowCreateHeight                  = SDL_PROP_WINDOW_CREATE_HEIGHT_NUMBER;

    // Boolean
    WindowCreateHidden                  = SDL_PROP_WINDOW_CREATE_HIDDEN_BOOLEAN;

    // Boolean
    WindowCreateHighPixelDensity        = SDL_PROP_WINDOW_CREATE_HIGH_PIXEL_DENSITY_BOOLEAN;

    // Boolean
    WindowCreateMaximized               = SDL_PROP_WINDOW_CREATE_MAXIMIZED_BOOLEAN;

    // Boolean
    WindowCreateMenu                    = SDL_PROP_WINDOW_CREATE_MENU_BOOLEAN;

    // Boolean
    WindowCreateMetal                   = SDL_PROP_WINDOW_CREATE_METAL_BOOLEAN;

    // Boolean
    WindowCreateMinimized               = SDL_PROP_WINDOW_CREATE_MINIMIZED_BOOLEAN;

    // Boolean
    WindowCreateModal                   = SDL_PROP_WINDOW_CREATE_MODAL_BOOLEAN;

    // Boolean
    WindowCreateMouseGrabbed            = SDL_PROP_WINDOW_CREATE_MOUSE_GRABBED_BOOLEAN;

    // Boolean
    WindowCreateOpenGL                  = SDL_PROP_WINDOW_CREATE_OPENGL_BOOLEAN;

    // Pointer/handle
    WindowCreateParent                  = SDL_PROP_WINDOW_CREATE_PARENT_POINTER;

    // Boolean
    WindowCreateResizable               = SDL_PROP_WINDOW_CREATE_RESIZABLE_BOOLEAN;

    // String
    WindowCreateTitle                   = SDL_PROP_WINDOW_CREATE_TITLE_STRING;

    // Boolean
    WindowCreateTransparent             = SDL_PROP_WINDOW_CREATE_TRANSPARENT_BOOLEAN;

    // Boolean
    WindowCreateTooltip                 = SDL_PROP_WINDOW_CREATE_TOOLTIP_BOOLEAN;

    // Boolean
    WindowCreateUtility                 = SDL_PROP_WINDOW_CREATE_UTILITY_BOOLEAN;

    // Boolean
    WindowCreateVulkan                  = SDL_PROP_WINDOW_CREATE_VULKAN_BOOLEAN;

    // Number
    WindowCreateWidth                   = SDL_PROP_WINDOW_CREATE_WIDTH_NUMBER;

    // Number
    WindowCreateX                       = SDL_PROP_WINDOW_CREATE_X_NUMBER;

    // Number
    WindowCreateY                       = SDL_PROP_WINDOW_CREATE_Y_NUMBER;

    // Pointer/handle
    WindowCreateCocoaWindow             = SDL_PROP_WINDOW_CREATE_COCOA_WINDOW_POINTER;

    // Pointer/handle
    WindowCreateCocoaView               = SDL_PROP_WINDOW_CREATE_COCOA_VIEW_POINTER;

    // Pointer/handle
    WindowCreateWin32HWnd               = SDL_PROP_WINDOW_CREATE_WIN32_HWND_POINTER;

    // Pointer/handle
    WindowCreateWin32PixelFormatHWnd    = SDL_PROP_WINDOW_CREATE_WIN32_PIXEL_FORMAT_HWND_POINTER;
  public const
    (** Window information properties **)

    // Pointer/handle
    WindowShape                         = SDL_PROP_WINDOW_SHAPE_POINTER;

    // Boolean
    WindowHdrEnabled                    = SDL_PROP_WINDOW_HDR_ENABLED_BOOLEAN;

    // Float
    WindowSdrWhiteLevel                 = SDL_PROP_WINDOW_SDR_WHITE_LEVEL_FLOAT;

    // Float
    WindowHdrHeadroom                   = SDL_PROP_WINDOW_HDR_HEADROOM_FLOAT;

    // Pointer/handle
    WindowAndroidWindow                 = SDL_PROP_WINDOW_ANDROID_WINDOW_POINTER;

    // Pointer/handle
    WindowAndroidSurface                = SDL_PROP_WINDOW_ANDROID_SURFACE_POINTER;

    // Pointer/handle
    WindowUIKitWindow                   = SDL_PROP_WINDOW_UIKIT_WINDOW_POINTER;

    // Number
    WindowUIKitMetalViewTag             = SDL_PROP_WINDOW_UIKIT_METAL_VIEW_TAG_NUMBER;

    // Number
    WindowUIKitOpenGLFramebuffer        = SDL_PROP_WINDOW_UIKIT_OPENGL_FRAMEBUFFER_NUMBER;

    // Number
    WindowUIKitOpenGLRenderbuffer       = SDL_PROP_WINDOW_UIKIT_OPENGL_RENDERBUFFER_NUMBER;

    // Number
    WindowUIKitOpenGLResolveFramebuffer = SDL_PROP_WINDOW_UIKIT_OPENGL_RESOLVE_FRAMEBUFFER_NUMBER;

    // Pointer/handle
    WindowCocoaWindow                   = SDL_PROP_WINDOW_COCOA_WINDOW_POINTER;

    // Number
    WindowCocoaMetalViewTag             = SDL_PROP_WINDOW_COCOA_METAL_VIEW_TAG_NUMBER;

    // Pointer/handle
    WindowWin32Hwnd                     = SDL_PROP_WINDOW_WIN32_HWND_POINTER;

    // Pointer/handle
    WindowWin32Hdc                      = SDL_PROP_WINDOW_WIN32_HDC_POINTER;

    // Pointer/handle
    WindowWin32Instance                 = SDL_PROP_WINDOW_WIN32_INSTANCE_POINTER;
  public const
    (** Surface properties **)

    // Float
    SurfaceSdrWhitePoint   = SDL_PROP_SURFACE_SDR_WHITE_POINT_FLOAT;

    // Float
    SurfaceHdrHeadroom     = SDL_PROP_SURFACE_HDR_HEADROOM_FLOAT;

    // String
    SurfaceTonemapOperator = SDL_PROP_SURFACE_TONEMAP_OPERATOR_STRING;
  public const
    (** I/O Stream properties **)

    // Pointer
    IOStreamWindowHandle     = SDL_PROP_IOSTREAM_WINDOWS_HANDLE_POINTER;

    // Number
    IOStreamFileDescriptor   = SDL_PROP_IOSTREAM_FILE_DESCRIPTOR_NUMBER;

    // Pointer
    IOStreamAndroidAAsset    = SDL_PROP_IOSTREAM_ANDROID_AASSET_POINTER;

    // Pointer
    IOStreamMemory           = SDL_PROP_IOSTREAM_MEMORY_POINTER;

    // Number
    IOStreamMemorySize       = SDL_PROP_IOSTREAM_MEMORY_SIZE_NUMBER;

    // Pointer
    IOStreamDynamicMemory    = SDL_PROP_IOSTREAM_DYNAMIC_MEMORY_POINTER;

    // Number
    IOStreamDynamicChunkSize = SDL_PROP_IOSTREAM_DYNAMIC_CHUNKSIZE_NUMBER;
  public const
    (** Renderer creation properties **)

    // String
    RendererCreateName                           = SDL_PROP_RENDERER_CREATE_NAME_STRING;

    // Pointer
    RendererCreateWindow                         = SDL_PROP_RENDERER_CREATE_WINDOW_POINTER;

    // Pointer
    RendererCreateSurface                        = SDL_PROP_RENDERER_CREATE_SURFACE_POINTER;

    // Number
    RendererCreateOutputColorspace               = SDL_PROP_RENDERER_CREATE_OUTPUT_COLORSPACE_NUMBER;

    // Number
    RendererCreatePresentVSync                   = SDL_PROP_RENDERER_CREATE_PRESENT_VSYNC_NUMBER;

    // Pointer
    RendererCreateVulkanInstance                 = SDL_PROP_RENDERER_CREATE_VULKAN_INSTANCE_POINTER;

    // Number
    RendererCreateVulkanSurface                  = SDL_PROP_RENDERER_CREATE_VULKAN_SURFACE_NUMBER;

    // Pointer
    RendererCreateVulkanPhysicalDevice           = SDL_PROP_RENDERER_CREATE_VULKAN_PHYSICAL_DEVICE_POINTER;

    // Pointer
    RendererCreateVulkanDevice                   = SDL_PROP_RENDERER_CREATE_VULKAN_DEVICE_POINTER;

    // Number
    RendererCreateVulkanGraphicsQueueFamilyIndex = SDL_PROP_RENDERER_CREATE_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER;

    // Number
    RendererCreateVulkanPresentQueueFamilyIndex  = SDL_PROP_RENDERER_CREATE_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER;
  public const
    (** Renderer properties **)

    // String
    RendererName                           = SDL_PROP_RENDERER_NAME_STRING;

    // Pointer
    RendererWindow                         = SDL_PROP_RENDERER_WINDOW_POINTER;

    // Pointer
    RendererSurface                        = SDL_PROP_RENDERER_SURFACE_POINTER;

    // Number
    RendererVSync                          = SDL_PROP_RENDERER_VSYNC_NUMBER;

    // Number
    RendererMaxTextureSize                 = SDL_PROP_RENDERER_MAX_TEXTURE_SIZE_NUMBER;

    // Pointer
    RendererTextureFormats                 = SDL_PROP_RENDERER_TEXTURE_FORMATS_POINTER;

    // Number
    RendererOutputColorspace               = SDL_PROP_RENDERER_OUTPUT_COLORSPACE_NUMBER;

    // Boolean
    RendererHdrEnabled                     = SDL_PROP_RENDERER_HDR_ENABLED_BOOLEAN;

    // Float
    RendererSdrWhitePoint                  = SDL_PROP_RENDERER_SDR_WHITE_POINT_FLOAT;

    // Float
    RendererHdrHeadroom                    = SDL_PROP_RENDERER_HDR_HEADROOM_FLOAT;

    // Pointer
    RendererD3D9Device                     = SDL_PROP_RENDERER_D3D9_DEVICE_POINTER;

    // Pointer
    RendererD3D11Device                    = SDL_PROP_RENDERER_D3D11_DEVICE_POINTER;

    // Pointer
    RendererD3D11SwapChain                 = SDL_PROP_RENDERER_D3D11_SWAPCHAIN_POINTER;

    // Pointer
    RendererD3D12Device                    = SDL_PROP_RENDERER_D3D12_DEVICE_POINTER;

    // Pointer
    RendererD3D12SwapChain                 = SDL_PROP_RENDERER_D3D12_SWAPCHAIN_POINTER;

    // Pointer
    RendererD3D12CommandQueue              = SDL_PROP_RENDERER_D3D12_COMMAND_QUEUE_POINTER;

    // Pointer
    RendererVulkanInstance                 = SDL_PROP_RENDERER_VULKAN_INSTANCE_POINTER;

    // Number
    RendererVulkanSurface                  = SDL_PROP_RENDERER_VULKAN_SURFACE_NUMBER;

    // Pointer
    RendererVulkanPhysicalDevice           = SDL_PROP_RENDERER_VULKAN_PHYSICAL_DEVICE_POINTER;

    // Pointer
    RendererVulkanDevice                   = SDL_PROP_RENDERER_VULKAN_DEVICE_POINTER;

    // Number
    RendererVulkanGraphicsQueueFamilyIndex = SDL_PROP_RENDERER_VULKAN_GRAPHICS_QUEUE_FAMILY_INDEX_NUMBER;

    // Number
    RendererVulkanPresentQueueFamilyIndex  = SDL_PROP_RENDERER_VULKAN_PRESENT_QUEUE_FAMILY_INDEX_NUMBER;

    // Number
    RendererVulkanSwapChainImageCount      = SDL_PROP_RENDERER_VULKAN_SWAPCHAIN_IMAGE_COUNT_NUMBER;

    // Pointer
    RendererGpuDevice                      = SDL_PROP_RENDERER_GPU_DEVICE_POINTER;
  public const
    (** Texture creation properties **)

    // Number
    TextureCreateColorspace         = SDL_PROP_TEXTURE_CREATE_COLORSPACE_NUMBER;

    // Number
    TextureCreateFormat             = SDL_PROP_TEXTURE_CREATE_FORMAT_NUMBER;

    // Number
    TextureCreateAccess             = SDL_PROP_TEXTURE_CREATE_ACCESS_NUMBER;

    // Number
    TextureCreateWidth              = SDL_PROP_TEXTURE_CREATE_WIDTH_NUMBER;

    // Number
    TextureCreateHeight             = SDL_PROP_TEXTURE_CREATE_HEIGHT_NUMBER;

    // Float
    TextureCreateSdrWhitePoint      = SDL_PROP_TEXTURE_CREATE_SDR_WHITE_POINT_FLOAT;

    // Float
    TextureCreateHdrHeadroom        = SDL_PROP_TEXTURE_CREATE_HDR_HEADROOM_FLOAT;

    // Pointer
    TextureCreateD3D11Texture       = SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_POINTER;

    // Pointer
    TextureCreateD3D11TextureU      = SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_U_POINTER;

    // Pointer
    TextureCreateD3D11TextureV      = SDL_PROP_TEXTURE_CREATE_D3D11_TEXTURE_V_POINTER;

    // Pointer
    TextureCreateD3D12Texture       = SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_POINTER;

    // Pointer
    TextureCreateD3D12TextureU      = SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_U_POINTER;

    // Pointer
    TextureCreateD3D12TextureV      = SDL_PROP_TEXTURE_CREATE_D3D12_TEXTURE_V_POINTER;

    // Pointer
    TextureCreateMetalPixelBuffer   = SDL_PROP_TEXTURE_CREATE_METAL_PIXELBUFFER_POINTER;

    // Number
    TextureCreateOpenGLTexture      = SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_NUMBER;

    // Number
    TextureCreateOpenGLTextureUV    = SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_UV_NUMBER;

    // Number
    TextureCreateOpenGLTextureU     = SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_U_NUMBER;

    // Number
    TextureCreateOpenGLTextureV     = SDL_PROP_TEXTURE_CREATE_OPENGL_TEXTURE_V_NUMBER;

    // Number
    TextureCreateOpenGles2Texture   = SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_NUMBER;

    // Number
    TextureCreateOpenGles2TextureUV = SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_UV_NUMBER;

    // Number
    TextureCreateOpenGles2TextureU  = SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_U_NUMBER;

    // Number
    TextureCreateOpenGles2TextureV  = SDL_PROP_TEXTURE_CREATE_OPENGLES2_TEXTURE_V_NUMBER;

    // Number
    TextureCreateVulkanTexture      = SDL_PROP_TEXTURE_CREATE_VULKAN_TEXTURE_NUMBER;
  public const
    (** Texture properties **)

    // Number
    TextureColorspace             = SDL_PROP_TEXTURE_COLORSPACE_NUMBER;

    // Number
    TextureFormat                 = SDL_PROP_TEXTURE_FORMAT_NUMBER;

    // Number
    TextureAccess                 = SDL_PROP_TEXTURE_ACCESS_NUMBER;

    // Number
    TextureWidth                  = SDL_PROP_TEXTURE_WIDTH_NUMBER;

    // Number
    TextureHeight                 = SDL_PROP_TEXTURE_HEIGHT_NUMBER;

    // Float
    TextureSdrWhitePoint          = SDL_PROP_TEXTURE_SDR_WHITE_POINT_FLOAT;

    // Float
    TextureHdrHeadroom            = SDL_PROP_TEXTURE_HDR_HEADROOM_FLOAT;

    // Pointer
    TextureD3D11Texture           = SDL_PROP_TEXTURE_D3D11_TEXTURE_POINTER;

    // Pointer
    TextureD3D11TextureU          = SDL_PROP_TEXTURE_D3D11_TEXTURE_U_POINTER;

    // Pointer
    TextureD3D11TextureV          = SDL_PROP_TEXTURE_D3D11_TEXTURE_V_POINTER;

    // Pointer
    TextureD3D12Texture           = SDL_PROP_TEXTURE_D3D12_TEXTURE_POINTER;

    // Pointer
    TextureD3D12TextureU          = SDL_PROP_TEXTURE_D3D12_TEXTURE_U_POINTER;

    // Pointer
    TextureD3D12TextureV          = SDL_PROP_TEXTURE_D3D12_TEXTURE_V_POINTER;

    // Number
    TextureOpenGLTexture          = SDL_PROP_TEXTURE_OPENGL_TEXTURE_NUMBER;

    // Number
    TextureOpenGLTextureUV        = SDL_PROP_TEXTURE_OPENGL_TEXTURE_UV_NUMBER;

    // Number
    TextureOpenGLTextureU         = SDL_PROP_TEXTURE_OPENGL_TEXTURE_U_NUMBER;

    // Number
    TextureOpenGLTextureV         = SDL_PROP_TEXTURE_OPENGL_TEXTURE_V_NUMBER;

    // Number
    TextureOpenGLTextureTarget    = SDL_PROP_TEXTURE_OPENGL_TEXTURE_TARGET_NUMBER;

    // Float
    TextureOpenGLTexW             = SDL_PROP_TEXTURE_OPENGL_TEX_W_FLOAT;

    // Float
    TextureOpenGLTexH             = SDL_PROP_TEXTURE_OPENGL_TEX_H_FLOAT;

    // Number
    TextureOpenGles2Texture       = SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_NUMBER;

    // Number
    TextureOpenGles2TextureUV     = SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_UV_NUMBER;

    // Number
    TextureOpenGles2TextureU      = SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_U_NUMBER;

    // Number
    TextureOpenGles2TextureV      = SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_V_NUMBER;

    // Number
    TextureOpenGles2TextureTarget = SDL_PROP_TEXTURE_OPENGLES2_TEXTURE_TARGET_NUMBER;

    // Number
    TextureVulkanTexture          = SDL_PROP_TEXTURE_VULKAN_TEXTURE_NUMBER;
  public const
    (** Text input properties **)

    // Number
    TextInputType             = SDL_PROP_TEXTINPUT_TYPE_NUMBER;

    // Number
    TextInputCapitalization   = SDL_PROP_TEXTINPUT_CAPITALIZATION_NUMBER;

    // Boolean
    TextInputAutoCorrect      = SDL_PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN;

    // Boolean
    TextInputMultiLine        = SDL_PROP_TEXTINPUT_MULTILINE_BOOLEAN;

    // Number
    TextInputAndroidInputType = SDL_PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER;
  public const
    (** Joystick properties **)

    // Boolean
    JoystickCapMonoLed       = SDL_PROP_JOYSTICK_CAP_MONO_LED_BOOLEAN;

    // Boolean
    JoystickCapRgbLed        = SDL_PROP_JOYSTICK_CAP_RGB_LED_BOOLEAN;

    // Boolean
    JoystickCapPlayerLed     = SDL_PROP_JOYSTICK_CAP_PLAYER_LED_BOOLEAN;

    // Boolean
    JoystickCapRumble        = SDL_PROP_JOYSTICK_CAP_RUMBLE_BOOLEAN;

    // Boolean
    JoystickCapTriggerRumble = SDL_PROP_JOYSTICK_CAP_TRIGGER_RUMBLE_BOOLEAN;
  public const
    (** Gamepad properties **)

    // Boolean
    GamepadCapMonoLed       = SDL_PROP_GAMEPAD_CAP_MONO_LED_BOOLEAN;

    // Boolean
    GamepadCapRgbLed        = SDL_PROP_GAMEPAD_CAP_RGB_LED_BOOLEAN;

    // Boolean
    GamepadCapPlayerLed     = SDL_PROP_GAMEPAD_CAP_PLAYER_LED_BOOLEAN;

    // Boolean
    GamepadCapRumble        = SDL_PROP_GAMEPAD_CAP_RUMBLE_BOOLEAN;

    // Boolean
    GamepadCapTriggerRumble = SDL_PROP_GAMEPAD_CAP_TRIGGER_RUMBLE_BOOLEAN;
  public const
    (** GPU device creation properties **)

    // Boolean
    GpuDeviceCreateDebugMode         = SDL_PROP_GPU_DEVICE_CREATE_DEBUGMODE_BOOLEAN;

    // Boolean
    GpuDeviceCreatePreferLowPower    = SDL_PROP_GPU_DEVICE_CREATE_PREFERLOWPOWER_BOOLEAN;

    // String
    GpuDeviceCreateName              = SDL_PROP_GPU_DEVICE_CREATE_NAME_STRING;

    // Boolean
    GpuDeviceCreateShadersPrivate    = SDL_PROP_GPU_DEVICE_CREATE_SHADERS_PRIVATE_BOOLEAN;

    // Boolean
    GpuDeviceCreateShadersSpirV      = SDL_PROP_GPU_DEVICE_CREATE_SHADERS_SPIRV_BOOLEAN;

    // Boolean
    GpuDeviceCreateShadersDxbc       = SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXBC_BOOLEAN;

    // Boolean
    GpuDeviceCreateShadersDxil       = SDL_PROP_GPU_DEVICE_CREATE_SHADERS_DXIL_BOOLEAN;

    // Boolean
    GpuDeviceCreateShadersMsl        = SDL_PROP_GPU_DEVICE_CREATE_SHADERS_MSL_BOOLEAN;

    // Boolean
    GpuDeviceCreateShadersMetalLib   = SDL_PROP_GPU_DEVICE_CREATE_SHADERS_METALLIB_BOOLEAN;

    // String
    GpuDeviceCreateD3D12SemanticName = SDL_PROP_GPU_DEVICE_CREATE_D3D12_SEMANTIC_NAME_STRING;
  public const
    (** GPU texture creation properties **)

    // Float
    GpuTextureCreateD3D12ClearR       = SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_R_FLOAT;

    // Float
    GpuTextureCreateD3D12ClearG       = SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_G_FLOAT;

    // Float
    GpuTextureCreateD3D12ClearB       = SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_B_FLOAT;

    // Float
    GpuTextureCreateD3D12ClearA       = SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_A_FLOAT;

    // Float
    GpuTextureCreateD3D12ClearDepth   = SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_DEPTH_FLOAT;

    // Byte
    GpuTextureCreateD3D12ClearStencil = SDL_PROP_GPU_TEXTURE_CREATE_D3D12_CLEAR_STENCIL_UINT8;

    // String
    GpuTextureCreateName              = SDL_PROP_GPU_TEXTURE_CREATE_NAME_STRING;
  public const
    (** GPU properties **)

    // String
    GpuComputePipelineCreateName  = SDL_PROP_GPU_COMPUTEPIPELINE_CREATE_NAME_STRING;

    // String
    GpuGraphicsPipelineCreateName = SDL_PROP_GPU_GRAPHICSPIPELINE_CREATE_NAME_STRING;

    // String
    GpuSamplerCreateName          = SDL_PROP_GPU_SAMPLER_CREATE_NAME_STRING;

    // String
    GpuShaderCreateName           = SDL_PROP_GPU_SHADER_CREATE_NAME_STRING;

    // String
    GpuBufferCreateName           = SDL_PROP_GPU_BUFFER_CREATE_NAME_STRING;

    // String
    GpuTransferBufferCreateName   = SDL_PROP_GPU_TRANSFERBUFFER_CREATE_NAME_STRING;
  public const
    (** Process creation properties **)

    // Pointer
    ProcessCreateArgs           = SDL_PROP_PROCESS_CREATE_ARGS_POINTER;

    // Pointer
    ProcessCreateEnvironment    = SDL_PROP_PROCESS_CREATE_ENVIRONMENT_POINTER;

    // Number
    ProcessCreateStdIn          = SDL_PROP_PROCESS_CREATE_STDIN_NUMBER;

    // Pointer
    ProcessCreateStdInStream    = SDL_PROP_PROCESS_CREATE_STDIN_POINTER;

    // Number
    ProcessCreateStdOut         = SDL_PROP_PROCESS_CREATE_STDOUT_NUMBER;

    // Pointer
    ProcessCreateStdOutStream   = SDL_PROP_PROCESS_CREATE_STDOUT_POINTER;

    // Number
    ProcessCreateStdErr         = SDL_PROP_PROCESS_CREATE_STDERR_NUMBER;

    // Pointer
    ProcessCreateStdErrStream   = SDL_PROP_PROCESS_CREATE_STDERR_POINTER;

    // Boolean
    ProcessCreateStdErrToStdOut = SDL_PROP_PROCESS_CREATE_STDERR_TO_STDOUT_BOOLEAN;

    // Boolean
    ProcessCreateBackground     = SDL_PROP_PROCESS_CREATE_BACKGROUND_BOOLEAN;
  public const
    (** Process properties **)
    ProcessPid        = SDL_PROP_PROCESS_PID_NUMBER;

    // Pointer
    ProcessStdIn      = SDL_PROP_PROCESS_STDIN_POINTER;

    // Pointer
    ProcessStdOut     = SDL_PROP_PROCESS_STDOUT_POINTER;

    // Pointer
    ProcessStdErr     = SDL_PROP_PROCESS_STDERR_POINTER;

    // Boolean
    ProcessBackground = SDL_PROP_PROCESS_BACKGROUND_BOOLEAN;
  end;

type
  /// <summary>
  ///  A callback used to free resources when a property is deleted.
  ///
  ///  This should release any resources associated with `AValue` that are no
  ///  longer needed.
  ///
  ///  This callback is set per-property. Different properties in the same group
  ///  can have different cleanup callbacks.
  ///
  ///  This callback will be called _during_
  ///  TSdlProperties.SetPointerWithCleanup if the function fails for any
  ///  reason.
  /// </summary>
  /// <param name="AValue">The pointer assigned to the property to clean up.</param>
  /// <seealso cref="TSdlProperties.SetPointerWithCleanup"/>
  /// <remarks>
  ///  This callback may fire without any locks held; if this is a concern, the
  ///  app should provide its own locking.
  /// </remarks>
  TSdlPropertyCleanupCallback = procedure(const AValue: Pointer) of object;

type
  /// <summary>
  ///  A group of SDL properties.
  /// </summary>
  TSdlProperties = record
  {$REGION 'Internal Declarations'}
  private type
    TCleanupInfo = class
    public
      Callback: TSdlPropertyCleanupCallback;
    end;
  private
    FHandle: SDL_PropertiesID;
    function GetAsPointer(const AName: String): Pointer; inline;
    procedure SetAsPointer(const AName: String; const AValue: Pointer); inline;
    function GetAsString(const AName: String): String; inline;
    procedure SetAsString(const AName, AValue: String); inline;
    function GetAsNumber(const AName: String): Int64; inline;
    procedure SetAsNumber(const AName: String; const AValue: Int64); inline;
    function GetAsFloat(const AName: String): Single; inline;
    procedure SetAsFloat(const AName: String; const AValue: Single); inline;
    function GetAsBoolean(const AName: String): Boolean; inline;
    procedure SetAsBoolean(const AName: String; const AValue: Boolean); inline;
    class function GetGlobal: TSdlProperties; inline; static;
  private
    class procedure CleanupCallback(AUserData, AValue: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlProperties; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlProperties; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlProperties; inline; static;
  public
    /// <summary>
    ///  Create a group of properties.
    ///
    ///  All properties are automatically destroyed when SdlQuit is called.
    /// </summary>
    /// <returns>A new group of properties.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    class function Create: TSdlProperties; inline; static;

    /// <summary>
    ///  Destroy this group of properties.
    ///
    ///  All properties are deleted and their cleanup functions will be called,
    ///  if any.
    /// </summary>
    /// <remarks>
    ///  This function should not be called while these properties are locked or
    ///  other threads might be setting or getting values from these properties.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Copy a group of properties.
    ///
    ///  Copy all the properties from ASource to this group, with the exception
    ///  of properties requiring cleanup (set using SetPointerWithCleanup),
    ///  which will not be copied. Any property that already exists in this
    ///   group will be overwritten.
    /// </summary>
    /// <param name="ASource">The properties to copy.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this function from any thread.
    /// </remarks>
    procedure Assign(const ASource: TSdlProperties); inline;

    /// <summary>
    ///  Lock this group of properties.
    ///
    ///  Obtain a multi-threaded lock for these properties. Other threads will wait
    ///  while trying to lock these properties until they are unlocked. Properties
    ///  must be unlocked before they are destroyed.
    ///
    ///  The lock is automatically taken when setting individual properties, this
    ///  function is only needed when you want to set several properties atomically
    ///  or want to guarantee that properties being queried aren't freed in another
    ///  thread.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Unlock"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Lock; inline;

    /// <summary>
    ///  Unlock this group of properties.
    /// </summary>
    /// <seealso cref="Lock"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Unlock; inline;

    /// <summary>
    ///  Return whether a property exists in this group of properties.
    /// </summary>
    /// <param name="AName">The name of the property to query.</param>
    /// <returns>True if the property exists, or False if it doesn't.</returns>
    /// <seealso cref="GetType"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function Has(const AName: String): Boolean; inline;

    /// <summary>
    ///  Get the type of a property in this group of properties.
    /// </summary>
    /// <param name="AName">The name of the property to query.</param>
    /// <returns>The type of the property, or TSdlPropertyType.Invalid if it is
    ///  not set.</returns>
    /// <seealso cref="Has"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function GetType(const AName: String): TSdlPropertyType; inline;

    /// <summary>
    ///  Delete a property from a group of properties.
    /// </summary>
    /// <param name="AName">The name of the property to delete.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Delete(const AName: String); inline;

    /// <summary>
    ///  Set a pointer property in this group of properties with a cleanup function
    ///  that is called when the property is deleted.
    ///
    ///  The cleanup function is also called if setting the property fails for any
    ///  reason.
    ///
    ///  For simply setting basic data types, like numbers, bools, or strings, use
    ///  AsNumber, AsBoolean or AsString instead, as those functions will handle
    ///  cleanup on your behalf. This function is only for more complex, custom data.
    /// </summary>
    /// <param name="AName">The name of the property to modify.</param>
    /// <param name="AValue">The new value of the property, or nil to delete the
    ///  property.</param>
    /// <param name="ACleanup">The function to call when this property is deleted,
    ///  or nil if no cleanup is necessary.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AsPointer"/>
    /// <seealso cref="TSdlPropertyCleanupCallback"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure SetPointerWithCleanup(const AName: String; const AValue: Pointer;
      const ACleanup: TSdlPropertyCleanupCallback);

    /// <summary>
    ///  Pointer property values.
    ///
    ///  By convention, the names of properties that SDL exposes on objects will
    ///  start with 'SDL.', and properties that SDL uses internally will start with
    ///  'SDL.internal.'. These should be considered read-only and should not be
    ///  modified by applications.
    /// </summary>
    /// <param name="AName">The name of the property to get or set.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Has"/>
    /// <seealso cref="AsBoolean"/>
    /// <seealso cref="AsFloat"/>
    /// <seealso cref="AsNumber"/>
    /// <seealso cref="AsString"/>
    /// <seealso cref="SetPointerWithCleanup"/>
    /// <remarks>
    ///  Set the value to nil to delete the property.
    ///
    ///  It is safe to use this property from any thread, although the data
    ///  returned is not protected and could potentially be freed if you set
    ///  the value to nil or call Delete on these properties from another
    ///  thread. If you need to avoid this, Lock and Unlock.
    /// </remarks>
    property AsPointer[const AName: String]: Pointer read GetAsPointer write SetAsPointer;

    /// <summary>
    ///  String property values.
    /// </summary>
    /// <param name="AName">The name of the property to get or set.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  Set the value to an empty string to delete the property.
    ///
    ///  It is safe to use this property from any thread, although the data
    ///  returned is not protected and could potentially be freed if you set
    ///  the value to an empty string or call Delete on these properties from
    ///  another thread. If you need to avoid this, Lock and Unlock.
    /// </remarks>
    property AsString[const AName: String]: String read GetAsString write SetAsString;

    /// <summary>
    ///  Integer property values.
    /// </summary>
    /// <param name="AName">The name of the property to get or set.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property AsNumber[const AName: String]: Int64 read GetAsNumber write SetAsNumber;

    /// <summary>
    ///  Floating-point property values.
    /// </summary>
    /// <param name="AName">The name of the property to get or set.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property AsFloat[const AName: String]: Single read GetAsFloat write SetAsFloat;

    /// <summary>
    ///  Boolean property values.
    /// </summary>
    /// <param name="AName">The name of the property to get or set.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property AsBoolean[const AName: String]: Boolean read GetAsBoolean write SetAsBoolean;

    /// <summary>
    ///  The global SDL properties.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class property Global: TSdlProperties read GetGlobal;
  end;

type
  /// <summary>
  ///  A callback used to enumerate all the properties in a group of properties.
  ///
  ///  This callback is called from TSdlProperties.Enumerate, and is called once
  ///  per property in the set.
  /// </summary>
  /// <param name="AProps">The properties that is being enumerated.</param>
  /// <param name="AName">The next property name in the enumeration.</param>
  /// <seealso cref="TSdlProperties.Enumerate"/>
  /// <remarks>
  ///  TSdlProperties.Enumerate holds a lock on `AProps` during this callback.
  /// </remarks>
  TSdlEnumeratePropertiesCallback = procedure(const AProps: TSdlProperties;
    const AName: String) of object;

type
  _TSdlPropertiesHelper = record helper for TSdlProperties
  {$REGION 'Internal Declarations'}
  private
    class procedure EnumProps(AUserdata: Pointer; AProps: SDL_PropertiesID;
      const AName: PUTF8Char); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Enumerate the properties contained in this group of properties.
    ///
    ///  The callback function is called for each property in the group of
    ///  properties. The properties are locked during enumeration.
    /// </summary>
    /// <param name="ACallback">The function to call for each property.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Enumerate(const ACallback: TSdlEnumeratePropertiesCallback);
  end;
{$ENDREGION 'Properties'}

{$REGION 'Internal Declarations'}
function __ToUtf8(const AString: String): PUTF8Char;
function __ToUtf8B(const AString: String): PUTF8Char;
function __ToString(const AUtf8: PUTF8Char): String;
procedure __HandleError; overload;
procedure __HandleError(const AMessage: String); overload;
{$ENDREGION 'Internal Declarations'}

implementation

uses
  Neslib.Sdl3;

{$POINTERMATH ON}
function Utf16ToUtf8(const ASource: Pointer; const ASourceLength: Integer;
  const ABuffer: Pointer): Integer;
var
  SrcLength: Integer;
  S: PWord;
  D, DStart: PByte;
  Codepoint: UInt32;
begin
  SrcLength := ASourceLength;
  S := ASource;
  D := ABuffer;
  DStart := D;

  { Try to convert 2 wide characters at a time if possible. This speeds up the
    process if those 2 characters are both ASCII characters (U+0..U+7F). }
  while (SrcLength >= 2) do
  begin
    if ((PCardinal(S)^ and $FF80FF80) = 0) then
    begin
      { Common case: 2 ASCII characters in a row.
        00000000 0yyyyyyy 00000000 0xxxxxxx => 0yyyyyyy 0xxxxxxx }
      D[0] := S[0]; // 00000000 0yyyyyyy => 0yyyyyyy
      D[1] := S[1]; // 00000000 0xxxxxxx => 0xxxxxxx
      Inc(S, 2);
      Inc(D, 2);
      Dec(SrcLength, 2);
    end
    else
    begin
      Codepoint := S^;
      Inc(S);
      Dec(SrcLength);

      if (Codepoint < $80) then
      begin
        { ASCI character (U+0..U+7F).
          00000000 0xxxxxxx => 0xxxxxxx }
        D^ := Codepoint;
        Inc(D);
      end
      else if (Codepoint < $800) then
      begin
        { 2-byte sequence (U+80..U+7FF)
          00000yyy yyxxxxxx => 110yyyyy 10xxxxxx }
        D^ := (Codepoint shr 6) or $C0;   // 00000yyy yyxxxxxx => 110yyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80; // 00000yyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end
      else if (Codepoint >= $D800) and (Codepoint <= $DBFF) then
      begin
        { The codepoint is part of a UTF-16 surrogate pair:
            S[0]: 110110yy yyyyyyyy ($D800-$DBFF, high-surrogate)
            S[1]: 110111xx xxxxxxxx ($DC00-$DFFF, low-surrogate)

          Where the UCS4 codepoint value is:
            0000yyyy yyyyyyxx xxxxxxxx + $00010000 (U+10000..U+10FFFF)

          This can be calculated using:
            (((S[0] and $03FF) shl 10) or (S[1] and $03FF)) + $00010000

          However it can be calculated faster using:
            (S[0] shl 10) + S[1] - $035FDC00

          because:
            * S[0] shl 10: also shifts the leading 110110 to the left, making
              the result $D800 shl 10 = $03600000 too large
            * S[1] is                   $0000DC00 too large
            * So we need to subract     $0360DC00 (sum of the above)
            * But we need to add        $00010000
            * So in total, we subtract  $035FDC00 (difference of the above) }

        Codepoint := (Codepoint shl 10) + S^ - $035FDC00;
        Inc(S);
        Dec(SrcLength);

        { The resulting codepoint is encoded as a 4-byte UTF-8 sequence:

          000uuuuu zzzzyyyy yyxxxxxx => 11110uuu 10uuzzzz 10yyyyyy 10xxxxxx }

        Assert(Codepoint > $FFFF);
        D^ := (Codepoint shr 18) or $F0;           // 000uuuuu zzzzyyyy yyxxxxxx => 11110uuu
        Inc(D);
        D^ := ((Codepoint shr 12) and $3F) or $80; // 000uuuuu zzzzyyyy yyxxxxxx => 10uuzzzz
        Inc(D);
        D^ := ((Codepoint shr 6) and $3F) or $80;  // 000uuuuu zzzzyyyy yyxxxxxx => 10yyyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80;          // 000uuuuu zzzzyyyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end
      else
      begin
        { 3-byte sequence (U+800..U+FFFF, excluding U+D800..U+DFFF).
          zzzzyyyy yyxxxxxx => 1110zzzz 10yyyyyy 10xxxxxx }
        D^ := (Codepoint shr 12) or $E0;           // zzzzyyyy yyxxxxxx => 1110zzzz
        Inc(D);
        D^ := ((Codepoint shr 6) and $3F) or $80;  // zzzzyyyy yyxxxxxx => 10yyyyyy
        Inc(D);
        D^ := (Codepoint and $3F) or $80;          // zzzzyyyy yyxxxxxx => 10xxxxxx
        Inc(D);
      end;
    end;
  end;

  { We may have 1 wide character left to encode.
    Use the same process as above. }
  if (SrcLength <> 0) then
  begin
    Codepoint := S^;
    Inc(S);

    if (Codepoint < $80) then
    begin
      D^ := Codepoint;
      Inc(D);
    end
    else if (Codepoint < $800) then
    begin
      D^ := (Codepoint shr 6) or $C0;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end
    else if (Codepoint >= $D800) and (Codepoint <= $DBFF) then
    begin
      Codepoint := (Codepoint shl 10) + S^ - $35FDC00;

      Assert(Codepoint > $FFFF);
      D^ := (Codepoint shr 18) or $F0;
      Inc(D);
      D^ := ((Codepoint shr 12) and $3F) or $80;
      Inc(D);
      D^ := ((Codepoint shr 6) and $3F) or $80;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end
    else
    begin
      D^ := (Codepoint shr 12) or $E0;
      Inc(D);
      D^ := ((Codepoint shr 6) and $3F) or $80;
      Inc(D);
      D^ := (Codepoint and $3F) or $80;
      Inc(D);
    end;
  end;

  Result := D - DStart;
end;

function Utf8ToUtf16(const ASource: Pointer; const ASourceLength: Integer): String;
var
  SrcLength: Integer;
  S: PByte;
  D, DStart: PWord;
  Codepoint: UInt32;
begin
  SrcLength := ASourceLength;
  if (SrcLength = 0) then
    Exit('');

  SetLength(Result, SrcLength + 1);
  S := ASource;
  D := Pointer(Result);
  DStart := D;

  { Try to convert 4 bytes at a time. This speeds up the process if those 4
    bytes are all ASCII characters (U+0..U+7F) }
  while (SrcLength >= 4) do
  begin
    if ((PCardinal(S)^ and $80808080) = 0) then
    begin
      { Common case: 4 ASCII characters in a row.
        0zzzzzzz 0yyyyyyy 0xxxxxxx 0wwwwwww => 00000000 0zzzzzzz 00000000 0yyyyyyy 00000000 0xxxxxxx 00000000 0wwwwwww }
      D[0] := S[0]; // 0zzzzzzz => 00000000 0zzzzzzz
      D[1] := S[1]; // 0yyyyyyy => 00000000 0yyyyyyy
      D[2] := S[2]; // 0xxxxxxx => 00000000 0xxxxxxx
      D[3] := S[3]; // 0wwwwwww => 00000000 0wwwwwww
      Inc(S, 4);
      Inc(D, 4);
      Dec(SrcLength, 4);
    end
    else
    begin
      Codepoint := S^;
      Inc(S);
      if (Codepoint < $80) then
      begin
        { ASCI character (U+0..U+7F).
          0xxxxxxx => 00000000 0xxxxxxx }
        D^ := Codepoint;
        Dec(SrcLength);
      end
      else
      if ((Codepoint shr 5) = $06) then
      begin
        { 2-byte sequence (U+80..U+7FF)
          110yyyyy 10xxxxxx => 00000yyy yyxxxxxx }
        D^ := ((Codepoint shl 6) and $7FF) // 110yyyyy => 00000yyy yy000000
            + (S^ and $3F);                // 10xxxxxx => 00000000 00xxxxxx
        Inc(S);
        Dec(SrcLength, 2);
      end
      else
      begin
        if ((Codepoint shr 4) = $0E) then
        begin
          { 3-byte sequence (U+800..U+FFFF, excluding U+D800..U+DFFF).
            1110zzzz 10yyyyyy 10xxxxxx => zzzzyyyy yyxxxxxx }
          Codepoint :=
             ((Codepoint shl 12) and $FFFF) // 1110zzzz => zzzz0000 00000000
           + ((S^ shl 6) and $FFF);         // 10yyyyyy => 0000yyyy yy000000
          Inc(S);
          Inc(Codepoint, S^ and $3F);       // 10xxxxxx => 00000000 00xxxxxx
          Inc(S);
          Dec(SrcLength, 3);
          Assert(CodePoint <= $FFFF);
          D^ := Codepoint;
        end
        else
        begin
          Assert((Codepoint shr 3) = $1E);
          { 4-byte sequence (U+10000..U+10FFFF).
            11110uuu 10uuzzzz 10yyyyyy 10xxxxxx => 000uuuuu zzzzyyyy yyxxxxxx }
          Codepoint :=
             ((Codepoint shl 18) and $1FFFFF) // 11110uuu => 000uuu00 00000000 00000000
           + ((S^ shl 12) and $3FFFF);        // 10uuzzzz => 000000uu zzzz0000 00000000
          Inc(S);
          Inc(Codepoint, (S^ shl 6) and $FFF);// 10yyyyyy => 00000000 0000yyyy yy000000
          Inc(S);
          Inc(Codepoint, S^ and $3F);         // 10xxxxxx => 00000000 00000000 00xxxxxx
          Inc(S);
          Dec(SrcLength, 4);

          { The value $00010000 must be subtracted from this codepoint, and the
            result must be converted to a UTF-16 surrogate pair:
              D[0]: 110110yy yyyyyyyy ($D800-$DBFF, high-surrogate)
              D[1]: 110111xx xxxxxxxx ($DC00-$DFFF, low-surrogate) }

          Assert(Codepoint > $FFFF);
          Dec(Codepoint, $00010000);
          D^ := $D800 + (Codepoint shr 10);
          Inc(D);
          D^ := $DC00 + (Codepoint and $3FF);
        end;
      end;
      Inc(D);
    end;
  end;

  { We may 1-3 bytes character left to encode.
    Use the same process as above. }
  while (SrcLength > 0) do
  begin
    Codepoint := S^;
    Inc(S);
    if (Codepoint < $80) then
    begin
      D^ := Codepoint;
      Dec(SrcLength);
    end
    else
    if ((Codepoint shr 5) = $06) then
    begin
      D^ := ((Codepoint shl 6) and $7FF) + (S^ and $3F);
      Inc(S);
      Dec(SrcLength, 2);
    end
    else
    begin
      if ((Codepoint shr 4) = $0E) then
      begin
        Codepoint := ((Codepoint shl 12) and $FFFF) + ((S^ shl 6) and $FFF);
        Inc(S);
        Inc(Codepoint, S^ and $3F);
        Inc(S);
        Dec(SrcLength, 3);
        Assert(CodePoint <= $FFFF);
        D^ := Codepoint;
      end
      else
      begin
        Assert((Codepoint shr 3) = $1E);
        Codepoint := ((Codepoint shl 18) and $1FFFFF) + ((S^ shl 12) and $3FFFF);
        Inc(S);
        Inc(Codepoint, (S^ shl 6) and $FFF);
        Inc(S);
        Inc(Codepoint, S^ and $3F);
        Inc(S);
        Dec(SrcLength, 4);

        Assert(CodePoint > $FFFF);
        D^ := $D7C0 + (Codepoint shr 10);
        Inc(D);
        D^ := $DC00 + (Codepoint and $3FF);
      end;
    end;
    Inc(D);
  end;
  SetLength(Result, D - DStart);
end;
{$POINTERMATH OFF}

var
  GUtf8Buf: TArray<UTF8Char>;
  GUtf8BBuf: TArray<UTF8Char>;

function __ToUtf8(const AString: String): PUTF8Char;
begin
  var SrcLen := Length(AString);
  if (SrcLen = 0) then
    Exit(nil);

  var DstLen := (SrcLen + 1) * 3;
  if (DstLen >= Length(GUtf8Buf)) then
    SetLength(GUtf8Buf, DstLen + 32);

  Result := Pointer(GUtf8Buf);
  DstLen := Utf16ToUtf8(Pointer(AString), SrcLen, Result);
  Result[DstLen] := #0;
end;

function __ToUtf8B(const AString: String): PUTF8Char;
begin
  var SrcLen := Length(AString);
  if (SrcLen = 0) then
    Exit(nil);

  var DstLen := (SrcLen + 1) * 3;
  if (DstLen >= Length(GUtf8BBuf)) then
    SetLength(GUtf8BBuf, DstLen + 32);

  Result := Pointer(GUtf8BBuf);
  DstLen := Utf16ToUtf8(Pointer(AString), SrcLen, Result);
  Result[DstLen] := #0;
end;

function __ToString(const AUtf8: PUTF8Char): String;
begin
  Result := Utf8ToUtf16(AUtf8, Length(PAnsiChar(AUtf8)));
end;

type
  TSdlAppOpener = class(TSdlApp);

procedure __HandleError;
begin
  TSdlApp.HasError := True;
  var Msg := __ToString(SDL_GetError);
  if Assigned(TSdlApp.Instance) then
    TSdlAppOpener(TSdlApp.Instance).HandleError(Msg)
  else
    raise ESdlError.Create(Msg);
end;

procedure __HandleError(const AMessage: String); overload;
begin
  TSdlApp.HasError := True;
  if Assigned(TSdlApp.Instance) then
    TSdlAppOpener(TSdlApp.Instance).HandleError(AMessage)
  else
    raise ESdlError.Create(AMessage);
end;

{ TSdlVersion }

class function TSdlVersion.AtLeast(const AMajor, AMinor, APatch: Byte): Boolean;
begin
  Result := SDL_VersionAtLeast(AMajor, AMinor, APatch);
end;

constructor TSdlVersion.Create(const AMajor, AMinor, APatch: Byte);
begin
  FMajor := AMajor;
  FMinor := AMinor;
  FPatch := APatch;
end;

class function TSdlVersion.FromNumber(const ANumber: Integer): TSdlVersion;
begin
  Result.FMajor := SDL_VersionNumMajor(ANumber);
  Result.FMinor := SDL_VersionNumMinor(ANumber);
  Result.FPatch := SDL_VersionNumMicro(ANumber);
end;

class function TSdlVersion.GetCompiledVersion: TSdlVersion;
begin
  Result.FMajor := SDL_MAJOR_VERSION;
  Result.FMinor := SDL_MINOR_VERSION;
  Result.FPatch := SDL_MICRO_VERSION;
end;

class function TSdlVersion.GetRevision: String;
begin
  Result := __ToString(SDL_GetRevision);
end;

class function TSdlVersion.GetRuntimeVersion: TSdlVersion;
begin
  var Version := SDL_GetVersion;
  Result.FMajor := SDL_VersionNumMajor(Version);
  Result.FMinor := SDL_VersionNumMinor(Version);
  Result.FPatch := SDL_VersionNumMicro(Version);
end;

function TSdlVersion.ToNumber: Integer;
begin
  Result := SDL_VersionNum(FMajor, FMinor, FPatch);
end;

{ ESdlError }

function SdlSucceeded(const ASdlResult: Boolean): Boolean;
begin
  Result := ASdlResult;
  if (not Result) then
    __HandleError;
end;

function SdlSucceeded(const ASdlResult: Pointer): Boolean;
begin
  Result := (ASdlResult <> nil);
  if (not Result) then
    __HandleError;
end;

function SdlSucceeded(const ASdlResult: THandle): Boolean;
begin
  Result := (ASdlResult <> 0);
  if (not Result) then
    __HandleError;
end;

function SdlFailed(const ASdlResult: Boolean): Boolean;
begin
  Result := not ASdlResult;
  if (Result) then
    __HandleError;
end;

function SdlFailed(const ASdlResult: Pointer): Boolean;
begin
  Result := (ASdlResult = nil);
  if (Result) then
    __HandleError;
end;

function SdlFailed(const ASdlResult: THandle): Boolean;
begin
  Result := (ASdlResult = 0);
  if (Result) then
    __HandleError;
end;

procedure SdlCheck(const ASdlResult: Boolean); overload; inline;
begin
  if (not ASdlResult) then
    __HandleError;
end;

procedure SdlCheck(const ASdlResult: Pointer); overload; inline;
begin
  if (ASdlResult = nil) then
    __HandleError;
end;

procedure SdlCheck(const ASdlResult: THandle); overload; inline;
begin
  if (ASdlResult = 0) then
    __HandleError;
end;

procedure SdlInit(const AFlags: TSdlInitFlags); inline;
begin
  SdlCheck(SDL_Init(Cardinal(AFlags)));
end;

procedure SdlInitSubSystem(const AFlags: TSdlInitFlags); inline;
begin
  SdlCheck(SDL_InitSubSystem(Cardinal(AFlags)));
end;

procedure SdlQuitSubSystem(const AFlags: TSdlInitFlags); inline;
begin
  SDL_QuitSubSystem(Cardinal(AFlags));
end;

procedure SdlQuit; inline;
begin
  SDL_Quit;
end;

function SdlWasInit(const AFlags: TSdlInitFlags): TSdlInitFlags; inline;
begin
  Cardinal(Result) := SDL_WasInit(Cardinal(AFlags));
end;

function SdlIsMainThread: Boolean; inline;
begin
  Result := SDL_IsMainThread;
end;

const
  MAX_THREAD_CALLBACKS = 8;

var
  GThreadCallbacks: array [0..MAX_THREAD_CALLBACKS - 1] of TSdlMainThreadCallback;

procedure ThreadCallback(AUserdata: Pointer); cdecl;
begin
  var Index := Cardinal(AUserdata);
  if (Index < MAX_THREAD_CALLBACKS) then
  begin
    var Callback := GThreadCallbacks[Index];
    if Assigned(Callback) then
    begin
      GThreadCallbacks[Index] := nil;
      Callback();
    end;
  end;
end;

procedure SdlRunOnMainThread(const ACallback: TSdlMainThreadCallback;
  const AWaitComplete: Boolean);
begin
  for var I := 0 to MAX_THREAD_CALLBACKS - 1 do
  begin
    if (not Assigned(GThreadCallbacks[I])) then
    begin
      GThreadCallbacks[I] := ACallback;
      SDL_RunOnMainThread(ThreadCallback, Pointer(I), AWaitComplete);
      Exit;
    end;
  end;
  __HandleError('Too many callbacks to run in main thread.');
end;

procedure SdlSetAppMetadata(const AAppName, AAppVersion, AAppIdentifier: String);
begin
  var Ident: PUTF8Char := nil;
  if (AAppIdentifier <> '') then
    Ident := PUTF8Char(UTF8String(AAppIdentifier));

  SdlCheck(SDL_SetAppMetadata(__ToUtf8(AAppName), __ToUtf8B(AAppVersion), Ident));
end;

procedure SdlSetAppMetadata(const AName, AValue: String); overload;
begin
  SdlCheck(SDL_SetAppMetadataProperty(__ToUtf8(AName), __ToUtf8B(AValue)));
end;

function SdlGetAppMetadata(const AName: String): String;
begin
  Result := __ToString(SDL_GetAppMetadataProperty(__ToUtf8(AName)));
end;

{ TSdlLog }

class constructor TSdlLog.Create;
begin
  RetrievePriorities;
  FDefaultOutputFunction := SDL_GetDefaultLogOutputFunction();
end;

class procedure TSdlLog.Critical(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Critical) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_CRITICAL, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Critical(const AMessage: String;
  const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Critical) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_CRITICAL, __ToUtf8(AMessage));
end;

class procedure TSdlLog.Debug(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Debug) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_DEBUG, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Debug(const AMessage: String;
  const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Debug) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_DEBUG, __ToUtf8(AMessage));
end;

class procedure TSdlLog.Error(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Error) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_ERROR, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Error(const AMessage: String;
  const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Error) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_ERROR, __ToUtf8(AMessage));
end;

class function TSdlLog.GetPriority(
  const ACategory: TSdlLogCategory): TSdlLogPriority;
begin
  Result := FPriorities[ACategory];
end;

class procedure TSdlLog.Info(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Info) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_INFO, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Info(const AMessage: String; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Info) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_INFO, __ToUtf8(AMessage));
end;

class procedure TSdlLog.Message(const ACategory: TSdlLogCategory;
  const APriority: TSdlLogPriority; const AMessage: String;
  const AArgs: array of const);
begin
  if (FPriorities[ACategory] <= APriority) then
    SDL_LogMessage(Ord(ACategory), Ord(APriority), __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.OutputFunction(AUserData: Pointer; ACategory: Integer;
  APriority: SDL_LogPriority; const AMessage: PUTF8Char);
begin
  Assert(Assigned(FCustomOutputFunction));
  FCustomOutputFunction(TSdlLogCategory(ACategory), TSdlLogPriority(APriority),
    __ToString(AMessage));
end;

class procedure TSdlLog.Message(const ACategory: TSdlLogCategory;
  const APriority: TSdlLogPriority; const AMessage: String);
begin
  if (FPriorities[ACategory] <= APriority) then
    SDL_LogMessage(Ord(ACategory), Ord(APriority), __ToUtf8(AMessage));
end;

class procedure TSdlLog.ResetPriorities;
begin
  SDL_ResetLogPriorities;
  RetrievePriorities;
end;

class procedure TSdlLog.RetrievePriorities;
begin
  for var I := Low(TSdlLogCategory) to High(TSdlLogCategory) do
    FPriorities[I] := TSdlLogPriority(SDL_GetLogPriority(Ord(I)));
end;

class procedure TSdlLog.SetAllPriorities(const APriority: TSdlLogPriority);
begin
  SDL_SetLogPriorities(Ord(APriority));
  RetrievePriorities;
end;

class procedure TSdlLog.SetCustomOutputFunction(
  const AValue: TSdlLogOutputFunction);
begin
  FCustomOutputFunction := AValue;
  if Assigned(AValue) then
    SDL_SetLogOutputFunction(OutputFunction, nil)
  else
    SDL_SetLogOutputFunction(FDefaultOutputFunction, nil);
end;

class procedure TSdlLog.SetPriority(const ACategory: TSdlLogCategory;
  const AValue: TSdlLogPriority);
begin
  SDL_SetLogPriority(Ord(ACategory), Ord(AValue));
  FPriorities[ACategory] := AValue;
end;

class procedure TSdlLog.SetPriorityPrefix(const APriority: TSdlLogPriority;
  const APrefix: String);
begin
  SdlCheck(SDL_SetLogPriorityPrefix(Ord(APriority), __ToUtf8(APrefix)));
end;

class procedure TSdlLog.Trace(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Trace) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_TRACE, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Trace(const AMessage: String;
  const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Trace) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_TRACE, __ToUtf8(AMessage));
end;

class procedure TSdlLog.Verbose(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Verbose) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_VERBOSE, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Verbose(const AMessage: String;
  const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Verbose) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_VERBOSE, __ToUtf8(AMessage));
end;

class procedure TSdlLog.Warn(const AMessage: String;
  const AArgs: array of const; const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Warn) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_WARN, __ToUtf8(Format(AMessage, AArgs)));
end;

class procedure TSdlLog.Warn(const AMessage: String;
  const ACategory: TSdlLogCategory);
begin
  if (FPriorities[ACategory] <= TSdlLogPriority.Warn) then
    SDL_LogMessage(Ord(ACategory), SDL_LOG_PRIORITY_WARN, __ToUtf8(AMessage));
end;

{ TSdlHints }

class procedure TSdlHints.Apply(const AName: PUTF8Char; const AValue: String;
  const APriority: TSdlHintPriority);
begin
  SdlCheck(SDL_SetHintWithPriority(AName, __ToUtf8(AValue), Ord(APriority)));
end;

class procedure TSdlHints.AddCallback(const AName: PUTF8Char;
  const ACallback: TSdlHintCallback);
begin
  if (FCallbacks = nil) then
    FCallbacks := TObjectDictionary<AnsiString, TCallbacks>.Create([doOwnsValues]);

  var Name := AnsiString(AName);
  var Callbacks: TCallbacks;
  if (not FCallbacks.TryGetValue(Name, Callbacks)) then
  begin
    Callbacks := TCallbacks.Create;
    FCallbacks.Add(Name, Callbacks);
  end;

  var Callback := TCallback.Create;
  Callbacks.Add(Callback);

  Callback.Value := ACallback;
  SdlCheck(SDL_AddHintCallback(AName, HintCallback, Callback));
end;

class procedure TSdlHints.Apply(const AName: PUTF8Char; const AValue: String);
begin
  SdlCheck(SDL_SetHint(AName, __ToUtf8(AValue)));
end;

class destructor TSdlHints.Destroy;
begin
  FCallbacks.Free;
end;

class function TSdlHints.Get(const AName: PUTF8Char): String;
begin
  Result := __ToString(SDL_GetHint(AName));
end;

class function TSdlHints.GetBoolean(const AName: PUTF8Char;
  const ADefaultValue: Boolean): Boolean;
begin
  Result := SDL_GetHintBoolean(AName, ADefaultValue);
end;

class function TSdlHints.GetHint(const AName: PUTF8Char): String;
begin
  Result := __ToString(SDL_GetHint(AName));
end;

class procedure TSdlHints.HintCallback(AUserData: Pointer; const AName,
  AOldValue, ANewValue: PUTF8Char);
var
  Callback: TCallback absolute AUserData;
begin
  System.Assert(Assigned(AUserData));
  var Name := String(UTF8String(AName));
  var OldValue := String(UTF8String(AOldValue));
  Callback.Value(Name, OldValue, __ToString(ANewValue));
end;

class procedure TSdlHints.RemoveCallback(const AName: PUTF8Char;
  const ACallback: TSdlHintCallback);
var
  Method1: TMethod absolute ACallback;
begin
  if (FCallbacks = nil) then
    Exit;

  var Name := AnsiString(AName);
  var Callbacks: TCallbacks;
  if (not FCallbacks.TryGetValue(Name, Callbacks)) then
    Exit;

  for var I := 0 to Callbacks.Count - 1 do
  begin
    var Callback := Callbacks[I];
    var Method2 := TMethod(Callback.Value);
    if (Method1 = Method2) then
    begin
      SDL_RemoveHintCallback(AName, HintCallback, Callback);
      Callbacks.Delete(I);
      if (Callbacks.Count = 0) then
        FCallbacks.Remove(Name);

      Break;
    end;
  end;
end;

class procedure TSdlHints.Reset(const AName: PUTF8Char);
begin
  SdlCheck(SDL_ResetHint(AName));
end;

class procedure TSdlHints.ResetAll;
begin
  SDL_ResetHints;
end;

class procedure TSdlHints.SetHint(const AName: PUTF8Char; const AValue: String);
begin
  SdlCheck(SDL_SetHint(AName, __ToUtf8(AValue)));
end;

{ TSdlProperties }

procedure TSdlProperties.Assign(const ASource: TSdlProperties);
begin
  SdlCheck(SDL_CopyProperties(ASource.FHandle, FHandle));
end;

class procedure TSdlProperties.CleanupCallback(AUserData, AValue: Pointer);
var
  Info: TCleanupInfo absolute AUserData;
begin
  Assert(Assigned(Info));
  try
    Info.Callback(AValue);
  finally
    Info.Free;
  end;
end;

class function TSdlProperties.Create: TSdlProperties;
begin
  Result.FHandle := SDL_CreateProperties;
  SdlCheck(Result.FHandle);
end;

procedure TSdlProperties.Delete(const AName: String);
begin
  SdlCheck(SDL_ClearProperty(FHandle, __ToUtf8(AName)));
end;

class operator TSdlProperties.Equal(const ALeft: TSdlProperties;
  const ARight: Pointer): Boolean;
begin
  Result := ((ALeft.FHandle = 0) and (ARight = nil))
         or ((ALeft.FHandle <> 0) and (ARight <> nil));
end;

procedure TSdlProperties.Free;
begin
  SDL_DestroyProperties(FHandle);
end;

function TSdlProperties.GetAsBoolean(const AName: String): Boolean;
begin
  Result := SDL_GetBooleanProperty(FHandle, __ToUtf8(AName), False);
end;

function TSdlProperties.GetAsFloat(const AName: String): Single;
begin
  Result := SDL_GetFloatProperty(FHandle, __ToUtf8(AName), 0);
end;

function TSdlProperties.GetAsNumber(const AName: String): Int64;
begin
  Result := SDL_GetNumberProperty(FHandle, __ToUtf8(AName), 0);
end;

function TSdlProperties.GetAsPointer(const AName: String): Pointer;
begin
  Result := SDL_GetPointerProperty(FHandle, __ToUtf8(AName), nil);
end;

function TSdlProperties.GetAsString(const AName: String): String;
begin
  Result := __ToString(SDL_GetStringProperty(FHandle, __ToUtf8(AName), nil));
end;

class function TSdlProperties.GetGlobal: TSdlProperties;
begin
  Result.FHandle := SDL_GetGlobalProperties;
  SdlCheck(Result.FHandle);
end;

function TSdlProperties.GetType(const AName: String): TSdlPropertyType;
begin
  Result := TSdlPropertyType(SDL_GetPropertyType(FHandle, __ToUtf8(AName)));
end;

function TSdlProperties.Has(const AName: String): Boolean;
begin
  Result := SDL_HasProperty(FHandle, __ToUtf8(AName));
end;

class operator TSdlProperties.Implicit(const AValue: Pointer): TSdlProperties;
begin
  Assert(AValue = nil);
  Result.FHandle := 0;
end;

procedure TSdlProperties.Lock;
begin
  SdlCheck(SDL_LockProperties(FHandle));
end;

class operator TSdlProperties.NotEqual(const ALeft: TSdlProperties;
  const ARight: Pointer): Boolean;
begin
  Result := not (ALeft = ARight);
end;

procedure TSdlProperties.SetAsBoolean(const AName: String;
  const AValue: Boolean);
begin
  SdlCheck(SDL_SetBooleanProperty(FHandle, __ToUtf8(AName), AValue));
end;

procedure TSdlProperties.SetAsFloat(const AName: String; const AValue: Single);
begin
  SdlCheck(SDL_SetFloatProperty(FHandle, __ToUtf8(AName), AValue));
end;

procedure TSdlProperties.SetAsNumber(const AName: String; const AValue: Int64);
begin
  SdlCheck(SDL_SetNumberProperty(FHandle, __ToUtf8(AName), AValue));
end;

procedure TSdlProperties.SetAsPointer(const AName: String;
  const AValue: Pointer);
begin
  SdlCheck(SDL_SetPointerProperty(FHandle, __ToUtf8(AName), AValue));
end;

procedure TSdlProperties.SetAsString(const AName, AValue: String);
begin
  SdlCheck(SDL_SetStringProperty(FHandle, __ToUtf8(AName), __ToUtf8B(AValue)));
end;

procedure TSdlProperties.SetPointerWithCleanup(const AName: String;
  const AValue: Pointer; const ACleanup: TSdlPropertyCleanupCallback);
begin
  var Cleanup: SDL_CleanupPropertyCallback := nil;
  var Info: TCleanupInfo := nil;

  if Assigned(ACleanup) then
  begin
    Cleanup := CleanupCallback;
    Info := TCleanupInfo.Create;
    Info.Callback := ACleanup;
    { NOTE: Info will be destroyed when the callback is called, which should
      always happen at some point. }
  end;

  SdlCheck(SDL_SetPointerPropertyWithCleanup(FHandle, __ToUtf8(AName), AValue,
    Cleanup, Info));
end;

procedure TSdlProperties.Unlock;
begin
  SDL_UnlockProperties(FHandle);
end;

{ _TSdlPropertiesHelper }

procedure _TSdlPropertiesHelper.Enumerate(
  const ACallback: TSdlEnumeratePropertiesCallback);
begin
  if (not Assigned(ACallback)) then
    Exit;

  SdlCheck(SDL_EnumerateProperties(FHandle, EnumProps, @ACallback));
end;

class procedure _TSdlPropertiesHelper.EnumProps(AUserdata: Pointer;
  AProps: SDL_PropertiesID; const AName: PUTF8Char);
type
  PSdlEnumeratePropertiesCallback = ^TSdlEnumeratePropertiesCallback;
var
  Callback: PSdlEnumeratePropertiesCallback absolute AUserdata;
begin
  Assert(Assigned(Callback));
  Callback^(TSdlProperties(AProps), __ToString(AName));
end;

initialization
  FillChar(GThreadCallbacks, SizeOf(GThreadCallbacks), 0);

end.
