unit Neslib.Sdl3;

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
  Neslib.Sdl3.Events;

/// <summary>
///  Lightweight, very low-overhead, type-safe, object-oriented wrapper for SDL3.
///
///  Wraps most of SDL into a class library (but using records instead of classes
///  to reduce overhead). However, some functionality is not wrapped, in particular
///  functionality that is not applicable to Delphi, or that the Delphi RTL already
///  provides.
///
///  In addition, errors are forwarded to the virtual TSdlApp.HandleError
///  method (from the thread that caused the error). Be default, this method
///  raises an exception of type ESdlError, but you can override to perform some
///  other action, such as logging it instead. However, if you choose to not
///  raise an exception, then the flow of execution will not be interrupted and
///  you will have to use TSdlApp.HasError and TSdlApp.ErrorMessage to check for
///  errors. Also, when the construction of an object (eg. a Texture, Window,
///  Audio stream etc.) fails, and an exception is *not* raised, then you will
///  have to check if the object is not nil before using it.
/// </summary>

type
  /// <summary>
  ///  Return values for the main callback methods in TSdlApp.
  ///
  ///  Returning TSdlAppResult.Success or TSdlAppResult.Failure from TSdlApp.Init,
  ///  TSdlApp.Event, or TSdlApp.Iterate will terminate the program and report
  ///  success/failure to the operating system. What that means is
  ///  platform-dependent.
  ///
  ///  Returning TSdlAppResult.Continue from these callbacks will let the app
  ///  continue to run.
  /// </summary>
  TSdlAppResult = (
    /// <summary>Value that requests that the app continue from the main callbacks.</summary>
    Continue = SDL_APP_CONTINUE,

    /// <summary>Value that requests termination with success from the main callbacks.</summary>
    Success = SDL_APP_SUCCESS,

    /// <summary>Value that requests termination with error from the main callbacks.</summary>
    Failure = SDL_APP_FAILURE);

type
  /// <summary>
  ///  Entry point class for all SDL applications.
  ///  You *must* override this class and its methods where appropriate.
  /// </summary>
  TSdlApp = class abstract
  {$REGION 'Internal Declarations'}
  private class var
    FHasError: Boolean;
    FInstance: TSdlApp;
    class function GetHasError: Boolean; inline; static;
    class function GetErrorMessage: String; inline; static;
  public
    constructor Create;
    destructor Destroy; override;
  {$ENDREGION 'Internal Declarations'}
  protected
    /// <summary>
    ///  This method is called by SDL once, at startup. The method should
    ///  initialize whatever is necessary, possibly create windows and open
    ///  audio devices, etc.
    ///
    ///  This method should not go into an infinite mainloop; it should do any
    ///  one-time setup it requires and then return.
    ///
    ///  If this method returns TSdlAppResult.Continue, the app will proceed
    ///  to normal operation, and will begin receiving repeated calls to the
    ///  Iterate and Event methods for the life of the program. If this method
    ///  returns TSdlAppResult.Failure, SDL will call the Quit method and
    ///  terminate the process with an exit code that reports an error to the
    ///  platform. If it returns TSdlAppResult.Success, SDL calls the Quit
    ///  method and terminates with an exit code that reports success to the
    ///  platform.
    ///
    ///  This method is called by SDL on the main thread.
    ///
    ///  Can be overridden to initialize the application, for example to create
    ///  a window and renderer.
    ///
    ///  By default this method just returns TSdlAppResult.Continue.
    /// </summary>
    /// <returns>
    ///  Your should return TSdlAppResult.Failure to terminate with an error,
    ///  TSdlAppResult.Success to terminate with success or
    ///  TSdlAppResult.Continue to continue.
    /// </returns>
    function Init: TSdlAppResult; virtual;

    /// <summary>
    ///  This method is called repeatedly by SDL after the Init method returns
    ///  TSdlAppResult.Continue. The method should operate as a single
    ///  iteration the program's primary loop; it should update whatever state
    ///  it needs and draw a new frame of video, usually.
    ///
    ///  On some platforms, this method will be called at the refresh rate of
    ///  the display (which might change during the life of your app!). There
    ///  are no promises made about what frequency this function might run at.
    ///  You should use SDL's timer functions if you need to see how much time
    ///  has passed since the last iteration.
    ///
    ///  There is no need to process the SDL event queue during this method;
    ///  SDL will send events as they arrive in the Event method, and in most
    ///  cases the event queue will be empty when this method runs anyhow.
    ///
    ///  This method should not go into an infinite mainloop; it should do one
    ///  iteration of whatever the program does and return.
    ///
    ///  If this method returns TSdlAppResult.Continue, the app will continue
    ///  normal operation, receiving repeated calls to Iterate and Event for
    ///  the life of the program. If this method returns TSdlAppResult.Failure,
    ///  SDL will call Quit and terminate the process with an exit code that
    ///  reports an error to the platform. If it returns TSdlAppResult.Success,
    ///  SDL calls Quit and terminates with an exit code that reports success to
    ///  the platform.
    ///
    ///  This method is called by SDL on the main thread.
    ///
    ///  By default this method just returns TSdlAppResult.Continue.
    /// </summary>
    /// <returns>
    ///  Your should return TSdlAppResult.Failure to terminate with an error,
    ///  TSdlAppResult.Success to terminate with success or
    ///  TSdlAppResult.Continue to continue.
    /// </returns>
    /// <remarks>
    ///  This method may get called concurrently with the Event method for
    ///  events not pushed on the main thread.
    /// </remarks>
    function Iterate: TSdlAppResult; virtual;

    /// <summary>
    ///  This method is called as needed by SDL after the Init method returns
    ///  TSdlAppResult.Continue. It is called once for each new event.
    ///
    ///  There is (currently) no guarantee about what thread this will be called
    ///  from; whatever thread pushes an event onto SDL's queue will trigger this
    ///  method. SDL is responsible for pumping the event queue between each call
    ///  to Iterate, so in normal operation one should only get events in a
    ///  serial fashion, but be careful if you have a thread that explicitly calls
    ///  TSdlEvents.Push. SDL itself will push events to the queue on the main thread.
    ///
    ///  Events sent to this method are not owned by the app; if you need to save
    ///  the data, you should copy it.
    ///
    ///  This method should not go into an infinite mainloop; it should handle the
    ///  provided event appropriately and return.
    ///
    ///  If this method returns TSdlAppResult.Continue, the app will continue
    ///  normal operation, receiving repeated calls to Iterate and Event for the
    ///  life of the program. If this method returns TSdlAppResult.Failure,
    ///  SDL will call Quit and terminate the process with an exit code that
    ///  reports an error to the platform. If it returns TSdlAppResult.Success,
    ///  SDL calls Quit and terminates with an exit code that reports success to
    ///  the platform.
    ///
    ///  By default this method returns TSdlAppResult.Continue, unless a Quit
    ///  event is received, in which case it returns TSdlAppResult.Success.
    /// </summary>
    /// <param name="AEvent">The new event for the app to examine.</param>
    /// <returns>
    ///  Your should return TSdlAppResult.Failure to terminate with an error,
    ///  TSdlAppResult.Success to terminate with success or
    ///  TSdlAppResult.Continue to continue.
    /// </returns>
    /// <remarks>
    ///  This method may get called concurrently with Iterate or Quit for
    ///  events not pushed from the main thread.
    /// </remarks>
    function Event(const AEvent: TSdlEvent): TSdlAppResult; virtual;

    /// <summary>
    ///  This method is called once by SDL before terminating the program.
    ///
    ///  This method will be called no matter what, even if the Init method
    ///  requests termination.
    ///
    ///  This method should not go into an infinite mainloop; it should
    ///  deinitialize any resources necessary, perform whatever shutdown
    ///  activities, and return.
    ///
    ///  You do not need to call SdlQuit in this method, as SDL will call it
    ///  after this method returns and before the process terminates, but it is
    ///  safe to do so.
    ///
    ///  This method is called by SDL on the main thread.
    ///
    ///  Does nothing by default.
    /// </summary>
    /// <param name="AResult">the result code that terminated the app (success or failure).</param>
    /// <remarks>
    ///  The Event method may get called concurrently with this method if
    ///  other threads that push events are still active.
    /// </remarks>
    procedure Quit(const AResult: TSdlAppResult); virtual;

    /// <summary>
    ///  This method is called when an SDL API returned an error. It is called
    ///  from the thread that caused the error.
    ///
    ///  By default, this method raises an exception of type ESdlError, but you
    ///  can override this method perform some other action, such as logging
    ///  the error instead.
    ///  However, if you choose to not raise an exception, then the flow of
    ///  execution will not be interrupted and you will have to use HasError and
    ///  ErrorMessage to check for errors. Also, when the construction of an
    ///  object (eg. a Texture, Window, Audio stream etc.) fails, and an
    ///  exception is *not* raised, then you will have to check if the object is
    ///  not nil before using it.
    /// </summary>
    /// <param name="AMessage">The error message.</param>
    /// <seealso cref="HasError"/>
    /// <seealso cref="ErrorMessage"/>
    /// <remarks>
    ///  This method is called from the thread that caused the error.
    /// </remarks>
    procedure HandleError(const AMessage: String); virtual;
  public
    /// <summary>
    ///  Whether an SDL API returned an error.
    ///
    ///  You usually only need to use this property if you override HandleError
    ///  and decide not to raise an exception. In that case, you can use this
    ///  property to check if an error has occurred.
    ///
    ///  It doesn't tell you *what* API caused the error, just that *any* SDL
    ///  API that was used since the last check of this property caused an
    ///  error. It will only be reset to False once this property has been read.
    /// </summary>
    /// <seealso cref="HandleError"/>
    /// <seealso cref="ErrorMessage"/>
    /// <remarks>
    ///  This property is not specific to the thread that caused the error. Any
    ///  thread that causes an error will set this global property.
    /// </remarks>
    class property HasError: Boolean read GetHasError write FHasError;

    /// <summary>
    ///  The last SDL error message. It is possible for multiple errors to occur
    ///  checking this property.
    ///
    ///  You usually only need to use this property if you override HandleError
    ///  and decide not to raise an exception. In that case, you can use
    ///  HasError to check if an error has occurred, and if so, use this
    ///  property to retrieve the error message.
    ///
    ///  Reading this property will *not* clear the error message. You need to
    ///  use HasError at a later point again to check for errors.
    /// </summary>
    /// <seealso cref="HandleError"/>
    /// <seealso cref="HasError"/>
    /// <remarks>
    ///  This property will return the error message that was specific to the
    ///  thread that caused it.
    /// </remarks>
    class property ErrorMessage: String read GetErrorMessage;

    /// <summary>
    ///  The singleton application instance.
    /// </summary>
    class property Instance: TSdlApp read FInstance;
  end;

type
  /// <summary>
  ///  A class reference to the TSdlApp class.
  /// </summary>
  TSdlAppClass = class of TSdlApp;

/// <summary>
///  Starts an SDL application. You **must** use this method to start the
///  application, otherwise your application will fail.
/// </summary>
/// <param name="AAppClass">Your application class (derived from TSdlApp).
///  This is the main entry point of your app.</param>
procedure RunApp(const AAppClass: TSdlAppClass);

implementation

uses
  Neslib.Sdl3.Basics;

var
  GAppClass: TSdlAppClass = nil;
  GApp: TSdlApp = nil;

function AppInit(AAppstate: PPointer; AArgc: Integer; AArgv: PPUTF8Char): SDL_AppResult; cdecl;
begin
  Assert(Assigned(GApp));
  Result := Ord(GApp.Init);
end;

function AppIterate(AAppstate: Pointer): SDL_AppResult; cdecl;
begin
  Assert(Assigned(GApp));
  Result := Ord(GApp.Iterate);
end;

function AppEvent(AAppstate: Pointer; AEvent: PSDL_Event): SDL_AppResult; cdecl;
begin
  Assert(Assigned(GApp));
  Result := Ord(GApp.Event(PSdlEvent(AEvent)^));
end;

procedure AppQuit(AAppstate: Pointer; AResult: SDL_AppResult); cdecl;
begin
  Assert(Assigned(GApp));
  GApp.Quit(TSdlAppResult(AResult));
  GApp.Free;
  GApp := nil;
end;

function MainFunc(AArgc: Integer; AArgv: PPUTF8Char): Integer; cdecl;
begin
  if (GAppClass = nil) then
    Exit(SDL_APP_FAILURE);

  GApp := GAppClass.Create;
  Result := SDL_EnterAppMainCallbacks(0, nil, AppInit, AppIterate, AppEvent, AppQuit);
end;

procedure Main;
begin
  SDL_RunApp(0, nil, MainFunc, nil);
end;

procedure RunApp(const AAppClass: TSdlAppClass);
begin
  Assert(Assigned(AAppClass));
  GAppClass := AAppClass;
  SdlMain(Main);
end;

{ TSdlApp }

constructor TSdlApp.Create;
begin
  Assert(FInstance = nil);
  inherited;
  FInstance := Self;
end;

destructor TSdlApp.Destroy;
begin
  FInstance := nil;
  inherited;
end;

function TSdlApp.Event(const AEvent: TSdlEvent): TSdlAppResult;
begin
  { No default implementation }
  if (AEvent.Kind = TSdlEventKind.Quit) then
    Result := TSdlAppResult.Success
  else
    Result := TSdlAppResult.Continue;
end;

class function TSdlApp.GetErrorMessage: String;
begin
  Result := __ToString(SDL_GetError);
end;

class function TSdlApp.GetHasError: Boolean;
begin
  Result := FHasError;
  FHasError := False;
end;

procedure TSdlApp.HandleError(const AMessage: String);
begin
  raise ESdlError.Create(AMessage);
end;

function TSdlApp.Init: TSdlAppResult;
begin
  { No default implementation }
  Result := TSdlAppResult.Continue;
end;

function TSdlApp.Iterate: TSdlAppResult;
begin
  { No default implementation }
  Result := TSdlAppResult.Continue;
end;

procedure TSdlApp.Quit(const AResult: TSdlAppResult);
begin
  { No default implementation }
end;

end.
