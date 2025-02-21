unit Neslib.Sdl3.Time;

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
  Neslib.Sdl3.Api;

{$REGION 'Timer Support'}
/// <summary>
///  SDL provides time management functionality. It is useful for dealing with
///  (usually) small durations of time.
///
///  This is not to be confused with _calendar time_ management.
///
///  This category covers measuring time elapsed (SdlGetTicks,
///  SdlGetPerformanceCounter), putting a thread to sleep for a certain
///  amount of time (SdlDelay, SdlDelayNS, SdlDelayPrecise), and firing
///  a callback function after a certain amount of time has elasped
///  (SdlAddTimer etc.).
///
///  There are also useful function to convert between time units, like
///  SdlSecondsToNS and such.
/// </summary>

const
  /// <summary>
  ///  Number of milliseconds in a second.
  ///
  ///  This is always 1,000.
  /// </summary>
  SDL_MS_PER_SECOND = 1000;

  /// <summary>
  ///  Number of microseconds in a second.
  ///
  ///  This is always 1,000,000.
  /// </summary>
  SDL_US_PER_SECOND = 1000000;

  /// <summary>
  ///  Number of nanoseconds in a second.
  ///
  ///  This is always 1,000,000,000.
  /// </summary>
  SDL_NS_PER_SECOND = 1000000000;

  /// <summary>
  ///  Number of nanoseconds in a millisecond.
  ///
  ///  This is always 1,000,000.
  /// </summary>
  SDL_NS_PER_MS = 1000000;

  /// <summary>
  ///  Number of nanoseconds in a microsecond.
  ///
  ///  This is always 1,000.
  /// </summary>
  SDL_NS_PER_US = 1000;

/// <summary>
///  Convert seconds to nanoseconds.
/// </summary>
/// <param name="ASeconds">the number of seconds to convert.</param>
/// <returns>ASeconds, expressed in nanoseconds.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlSecondsToNS(const ASeconds: Double): Int64; inline;

/// <summary>
///  Convert nanoseconds to seconds.
/// </summary>
/// <param name="ANanoSeconds">The number of nanoseconds to convert.</param>
/// <returns>ANanoSeconds, expressed in seconds.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlNSToSeconds(const ANanoSeconds: Int64): Double; inline;

/// <summary>
///  Convert milliseconds to nanoseconds.
/// </summary>
/// <param name="AMilliSeconds">The number of milliseconds to convert.</param>
/// <returns>AMilliSeconds, expressed in nanoseconds.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlMSToNS(const AMilliSeconds: Integer): Int64; inline;

/// <summary>
///  Convert nanoseconds to milliseconds.
/// </summary>
/// <param name="ANanoSeconds">the number of nanoseconds to convert.</param>
/// <returns>ANanoSeconds, expressed in milliseconds.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlNSToMS(const ANanoSeconds: Int64): Integer; inline;

/// <summary>
///  Convert microseconds to nanoseconds.
/// </summary>
/// <param name="AMicroSeconds">the number of microseconds to convert.</param>
/// <returns>AMicroSeconds, expressed in nanoseconds.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlUSToNS(const AMicroSeconds: Int64): Int64; inline;

/// <summary>
///  Convert nanoseconds to microseconds.
/// </summary>
/// <param name="ANanoSeconds">the number of nanoseconds to convert.</param>
/// <returns>ANanoSeconds, expressed in microseconds.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlNSToUS(const ANanoSeconds: Int64): Int64; inline;

/// <summary>
///  Get the number of milliseconds since SDL library initialization.
/// </summary>
/// <returns>A signed 64-bit value representing the number of
///  milliseconds since the SDL library initialized.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlGetTicks: Int64; inline;

/// <summary>
///  Get the number of nanoseconds since SDL library initialization.
/// </summary>
/// <returns>A signed 64-bit value representing the number of
///  nanoseconds since the SDL library initialized.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlGetTicksNS: Int64; inline;

/// <summary>
///  Get the current value of the high resolution counter.
///
///  This function is typically used for profiling.
///
///  The counter values are only meaningful relative to each other. Differences
///  between values can be converted to times by using
///  SdlGetPerformanceFrequency.
/// </summary>
/// <returns>The current counter value.</returns>
/// <seealso cref="SdlGetPerformanceFrequency"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlGetPerformanceCounter: Int64; inline;

/// <summary>
///  Get the count per second of the high resolution counter.
/// </summary>
/// <returns>A platform-specific count per second.</returns>
/// <seealso cref="SdlGetPerformanceCounter"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlGetPerformanceFrequency: Int64; inline;

/// <summary>
///  Wait a specified number of milliseconds before returning.
///
///  This function waits a specified number of milliseconds before returning. It
///  waits at least the specified time, but possibly longer due to OS
///  scheduling.
/// </summary>
/// <param name="AMilliSeconds">The number of milliseconds to delay.</param>
/// <seealso cref="SdlDelayNS"/>
/// <seealso cref="SdlDelayPrecise"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
procedure SdlDelay(const AMilliSeconds: Integer); inline;

/// <summary>
///  Wait a specified number of nanoseconds before returning.
///
///  This function waits a specified number of nanoseconds before returning. It
///  waits at least the specified time, but possibly longer due to OS
///  scheduling.
/// </summary>
/// <param name="ANanoSeconds">The number of nanoseconds to delay.</param>
/// <seealso cref="SdlDelay"/>
/// <seealso cref="SdlDelayPrecise"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
procedure SdlDelayNS(const ANanoSeconds: Int64); inline;

/// <summary>
///  Wait a specified number of nanoseconds before returning.
///
///  This function waits a specified number of nanoseconds before returning. It
///  will attempt to wait as close to the requested time as possible, busy
///  waiting if necessary, but could return later due to OS scheduling.
/// </summary>
/// <param name="ANanoSeconds">the number of nanoseconds to delay.</param>
/// <seealso cref="SdlDelay"/>
/// <seealso cref="SdlDelayNS"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
procedure SdlDelayPrecise(const ANanoSeconds: Int64); inline;

type
  /// <summary>
  ///  A timer ID.
  /// </summary>
  TSdlTimerID = SDL_TimerID;

type
  /// <summary>
  ///  Function prototype for the millisecond timer callback function.
  ///
  ///  The callback function is passed the current timer interval and returns the
  ///  next timer interval, in milliseconds. If the returned value is the same as
  ///  the one passed in, the periodic alarm continues, otherwise a new alarm is
  ///  scheduled. If the callback returns 0, the periodic alarm is canceled and
  ///  will be removed.
  /// </summary>
  /// <param name="ATimerID">The current timer being processed.</param>
  /// <param name="AInterval">The current callback time interval.</param>
  /// <returns>The new callback time interval, or 0 to disable further runs of
  ///  the callback.</returns>
  /// <seealso cref="SdlAddTimer"/>
  /// <remarks>
  ///  SDL may call this callback at any time from a background thread;
  ///  the application is responsible for locking resources the callback touches
  ///  that need to be protected.
  /// </remarks>
  TSdlTimerCallback = function(const ATimerID: TSdlTimerID;
    const AInterval: Integer): Integer of object;

/// <summary>
///  Call a callback function at a future time.
///
///  The callback function is passed the current timer interval and should
///  return the next timer interval. If the value returned from the callback
///  is 0, the timer is canceled and will be removed.
///
///  The callback is run on a separate thread, and for short timeouts can
///  potentially be called before this function returns.
///
///  Timers take into account the amount of time it took to execute the
///  callback. For example, if the callback took 250 ms to execute and returned
///  1000 (ms), the timer would only wait another 750 ms before its next
///  iteration.
///
///  Timing may be inexact due to OS scheduling. Be sure to note the current
///  time with SdlGetTicksNS or SdlGetPerformanceCounter in case your
///  callback needs to adjust for variances.
/// </summary>
/// <param name="AInterval">The timer delay, in milliseconds, passed to `ACallback`.</param>
/// <param name="ACallback">The SdlTimerCallback function to call when the
///  specified `AInterval` elapses.</param>
/// <returns>A timer ID.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlAddTimerNS"/>
/// <seealso cref="SdlRemoveTimer"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlAddTimer(const AInterval: Integer;
  const ACallback: TSdlTimerCallback): TSdlTimerID;

type
  /// <summary>
  ///  Function prototype for the nanosecond timer callback function.
  ///
  ///  The callback function is passed the current timer interval and returns the
  ///  next timer interval, in nanoseconds. If the returned value is the same as
  ///  the one passed in, the periodic alarm continues, otherwise a new alarm is
  ///  scheduled. If the callback returns 0, the periodic alarm is canceled and
  ///  will be removed.
  /// </summary>
  /// <param name="ATimerID">The current timer being processed.</param>
  /// <param name="AInterval">The current callback time interval.</param>
  /// <returns>The new callback time interval, or 0 to disable further runs of
  ///  the callback.</returns>
  /// <seealso cref="SdlAddTimerNS"/>
  /// <remarks>
  ///  SDL may call this callback at any time from a background thread;
  ///  the application is responsible for locking resources the callback touches
  ///  that need to be protected.
  /// </remarks>
  TSdlTimerNSCallback = function(const ATimerID: TSdlTimerID;
    const AInterval: Int64): Int64 of object;

/// <summary>
///  Call a callback function at a future time.
///
///  The callback function is passed the current timer interval and should
///  return the next timer interval. If the value returned from the callback
///  is 0, the timer is canceled and will be removed.
///
///  The callback is run on a separate thread, and for short timeouts can
///  potentially be called before this function returns.
///
///  Timers take into account the amount of time it took to execute the
///  callback. For example, if the callback took 250 ns to execute and returned
///  1000 (ns), the timer would only wait another 750 ns before its next
///  iteration.
///
///  Timing may be inexact due to OS scheduling. Be sure to note the current
///  time with SdlGetTicksNS or SdlGetPerformanceCounter in case your
///  callback needs to adjust for variances.
/// </summary>
/// <param name="AInterval">The timer delay, in nanoseconds, passed to `Aallback`.</param>
/// <param name="ACallback">The TSdlTimerNSCallback function to call when the
///  specified `AInterval` elapses.</param>
/// <returns>A timer ID.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlAddTimer"/>
/// <seealso cref="SdlRemoveTimer"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlAddTimerNS(const AInterval: Int64;
  const ACallback: TSdlTimerNSCallback): TSdlTimerID;

/// <summary>
///  Remove a timer created with SdlAddTimer or SdlAddTimerNS.
/// </summary>
/// <param name="AID">The ID of the timer to remove.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlAddTimer"/>
/// <seealso cref="SdlAddTimerNS"/>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlRemoveTimer(const AID: TSdlTimerID);
{$ENDREGION 'Timer Support'}

implementation

uses
  System.Generics.Collections,
  Neslib.Sdl3.Basics;

var
  GCallbacks: TDictionary<TSdlTimerID, TSdlTimerCallback> = nil;
  GCallbacksNS: TDictionary<TSdlTimerID, TSdlTimerNSCallback> = nil;

function SdlSecondsToNS(const ASeconds: Double): Int64;
begin
  Result := SDL_SecondsToNS(ASeconds);
end;

function SdlNSToSeconds(const ANanoSeconds: Int64): Double;
begin
  Result := SDL_NSToSeconds(ANanoSeconds);
end;

function SdlMSToNS(const AMilliSeconds: Integer): Int64; inline;
begin
  Result := SDL_MSToNS(AMilliSeconds);
end;

function SdlNSToMS(const ANanoSeconds: Int64): Integer; inline;
begin
  Result := SDL_NSToMS(ANanoSeconds);
end;

function SdlUSToNS(const AMicroSeconds: Int64): Int64; inline;
begin
  Result := SDL_USToNS(AMicroSeconds);
end;

function SdlNSToUS(const ANanoSeconds: Int64): Int64; inline;
begin
  Result := SDL_NSToUS(ANanoSeconds);
end;

function SdlGetTicks: Int64;
begin
  Result := Int64(SDL_GetTicks);
end;

function SdlGetTicksNS: Int64;
begin
  Result := Int64(SDL_GetTicksNS);
end;

function SdlGetPerformanceCounter: Int64;
begin
  Result := Int64(SDL_GetPerformanceCounter);
end;

function SdlGetPerformanceFrequency: Int64;
begin
  Result := Int64(SDL_GetPerformanceFrequency);
end;

procedure SdlDelay(const AMilliSeconds: Integer);
begin
  SdlDelay(AMilliSeconds);
end;

procedure SdlDelayNS(const ANanoSeconds: Int64);
begin
  SdlDelayNS(ANanoSeconds);
end;

procedure SdlDelayPrecise(const ANanoSeconds: Int64);
begin
  SdlDelayPrecise(ANanoSeconds);
end;

function TimerCallback(AUserData: Pointer; ATimerID: SDL_TimerID;
  AInterval: UInt32): UInt32; cdecl;
begin
  var Callback: TSdlTimerCallback;
  if Assigned(GCallbacks) and (GCallbacks.TryGetValue(ATimerID, Callback)) then
  begin
    Result := Callback(ATimerID, AInterval);
    if (Result = 0) then
      GCallbacks.Remove(ATimerID);
  end
  else
    Result := 0;
end;

function SdlAddTimer(const AInterval: Integer;
  const ACallback: TSdlTimerCallback): TSdlTimerID;
begin
  if (not Assigned(ACallback)) then
  begin
    __HandleError('No timer callback specified.');
    Exit(0);
  end;

  if (GCallbacks = nil) then
    GCallbacks :=  TDictionary<TSdlTimerID, TSdlTimerCallback>.Create;

  Result := SDL_AddTimer(AInterval, TimerCallback, nil);
  if (SdlSucceeded(Result)) then
    GCallbacks.AddOrSetValue(Result, ACallback);
end;

function TimerNSCallback(AUserdata: Pointer; ATimerID: SDL_TimerID;
  AInterval: UInt64): UInt64; cdecl;
begin
  var Callback: TSdlTimerNSCallback;
  if Assigned(GCallbacksNS) and (GCallbacksNS.TryGetValue(ATimerID, Callback)) then
  begin
    Result := Callback(ATimerID, AInterval);
    if (Result = 0) then
      GCallbacksNS.Remove(ATimerID);
  end
  else
    Result := 0;
end;

function SdlAddTimerNS(const AInterval: Int64;
  const ACallback: TSdlTimerNSCallback): TSdlTimerID;
begin
  if (not Assigned(ACallback)) then
  begin
    __HandleError('No timer callback specified.');
    Exit(0);
  end;

  if (GCallbacksNS = nil) then
    GCallbacksNS :=  TDictionary<TSdlTimerID, TSdlTimerNSCallback>.Create;

  Result := SDL_AddTimerNS(AInterval, TimerNSCallback, nil);
  if (SdlSucceeded(Result)) then
    GCallbacksNS.AddOrSetValue(Result, ACallback);
end;

procedure SdlRemoveTimer(const AID: TSdlTimerID);
begin
  if Assigned(GCallbacks) then
    GCallbacks.Remove(AID);

  if Assigned(GCallbacksNS) then
    GCallbacksNS.Remove(AID);

  SdlCheck(SDL_RemoveTimer(AID));
end;

initialization

finalization
  GCallbacks.Free;
  GCallbacksNS.Free;

end.
