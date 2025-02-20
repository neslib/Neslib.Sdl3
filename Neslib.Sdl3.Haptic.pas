unit Neslib.Sdl3.Haptic;

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
     in a product, an acknowledgment in the product d
     ocumentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution. }

{$Include 'Neslib.Sdl3.inc'}

interface

uses
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Input;

{$REGION 'Force Feedback ("Haptic")'}
/// <summary>
///  The SDL haptic subsystem manages haptic (force feedback) devices.
///
///  The basic usage is as follows:
///
///  - Initialize the subsystem (TSdlInitFlag.Haptic).
///  - Open a haptic device.
///  - TSdlHaptic.Open or TSdlHapticID.Open to open from a haptic device ID or
///    TSdlHaptic.OpenFromMouse and TSdlHaptic.OpenFromJoystick to open from an
///    existing mouse or joystick.
///  - Create an effect (TSdlHapticEffect).
///  - Upload the effect with TSdlHaptic.CreateEffect.
///  - Run the effect with TSdlHaptic.RunEffect.
///  - (optional) Free the effect with TSdlHaptic.FreeEffect.
///  - Close the haptic device with TSdlHaptic.Close.
///
///  Simple rumble example:
///
///  ```delphi
///  // Open the device
///  var Haptics := TSdlHapticID.Devices;
///  if (Haptics <> nil) then
///  begin
///    var Haptic := Haptics[0].Open;
///    try
///      // Initialize simple rumble
///      Haptic.InitRumble;
///
///      // Play effect at 50% strength for 2 seconds
///      Haptic.PlayRumble(0.5, 2000);
///      SdlDelay(2000);
///    finally
///      // Clean up
///      Haptic.Close;
///    end;
///  end;
///  ```
///
///  Complete example:
///
///  ```delphi
///  procedure TestHaptic(const AJoystick: TSdlJoystick)
///  begin
///    // Open the device
///    var Haptic := TSdlHaptic.OpenFromJoystick(Joystick);
///    if (Haptic = nil) then
///      Exit; // Most likely joystick isn't haptic
///
///    try
///      // See if it can do sine waves
///      if (not (TSdlHapticKind.Sine Haptic.Features)) then
///        Exit; // No sine effect
///
///      // Create the effect
///      var Effect := TSdlHapticEffect.Create;
///      Effect.Kind := TSdlHapticKind.Sine;
///      Effect.Periodic.Direction.Kind := TSdlHapticDirectionKind.Polar; // Polar coordinates
///      Effect.Periodic.Direction.Dir[0] := 18000; // Force comes from south
///      Effect.Periodic.Period := 1000; // 1000 ms
///      Effect.Periodic.Magnitude := 20000; // 20000/32767 strength
///      Effect.Periodic.Length := 5000; // 5 seconds long
///      Effect.Periodic.AttackLength := 1000; // Takes 1 second to get max strength
///      Effect.Periodic.FadeLength := 1000; // Takes 1 second to fade away
///
///      // Upload the effect
///      var EffectID := Haptic.CreateEffect(Effect);
///      try
///        // Test the effect
///        Haptic.RunEffect(EffectID, 1);
///        SdlDelay(5000); // Wait for the effect to finish
///      finally
///        // We destroy the effect, although closing the device also does this
///        Haptic.FreeEffect(EffectID);
///      end;
///    finally
///      // Close the device
///      Haptic.Close;
///    end;
///  end;
///  ```
///
///  Note that the SDL haptic subsystem is not thread-safe.
/// </summary>

{$MINENUMSIZE 2}
type
  /// <summary>
  ///  Types of effects.
  /// </summary>
  TSdlHapticKind = (
    /// <summary>
    ///  Constant haptic effect.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Constant     = SDL_HAPTIC_CONSTANT,

    /// <summary>
    ///  Periodic haptic effect that simulates sine waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    Sine         = SDL_HAPTIC_SINE,

    /// <summary>
    ///  Periodic haptic effect that simulates square waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    Square       = SDL_HAPTIC_SQUARE,

    /// <summary>
    ///  Periodic haptic effect that simulates triangular waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    Triangle     = SDL_HAPTIC_TRIANGLE,

    /// <summary>
    ///  Periodic haptic effect that simulates saw tooth up waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    SawToothUp   = SDL_HAPTIC_SAWTOOTHUP,

    /// <summary>
    ///  Periodic haptic effect that simulates saw tooth down waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    SawToothDown = SDL_HAPTIC_SAWTOOTHDOWN,

    /// <summary>
    ///  Ramp haptic effect.
    /// </summary>
    /// <seealso cref="TSdlHapticRamp"/>
    Ramp         = SDL_HAPTIC_RAMP,

    /// <summary>
    ///  Condition haptic effect that simulates a spring. Effect is based on the
    ///  axes position.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Spring       = SDL_HAPTIC_SPRING,

    /// <summary>
    ///  Condition haptic effect that simulates dampening. Effect is based on the
    ///  axes velocity.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Damper       = SDL_HAPTIC_DAMPER,

    /// <summary>
    ///  Condition haptic effect that simulates inertia. Effect is based on the axes
    ///  acceleration.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Inertia      = SDL_HAPTIC_INERTIA,

    /// <summary>
    ///  Condition haptic effect that simulates friction. Effect is based on the
    ///  axes movement.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Friction     = SDL_HAPTIC_FRICTION,

    /// <summary>
    ///  Haptic effect for direct control over high/low frequency motors.
    /// </summary>
    /// <seealso cref="TSdlHapticLeftRight"/>
    LeftRight    = SDL_HAPTIC_LEFTRIGHT,

    /// <summary>
    ///  User defined custom haptic effect.
    /// </summary>
    Custom       = SDL_HAPTIC_CUSTOM);
{$MINENUMSIZE 4}

type
  /// <summary>
  ///  Haptic features.
  /// </summary>
  TSdlHapticFeature = (
    /// <summary>
    ///  Supports constant haptic effect.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Constant     = 0,

    /// <summary>
    ///  Supports periodic haptic effect that simulates sine waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    Sine         = 1,

    /// <summary>
    ///  Supports periodic haptic effect that simulates square waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    Square       = 2,

    /// <summary>
    ///  Supports periodic haptic effect that simulates triangular waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    Triangle     = 3,

    /// <summary>
    ///  Supports periodic haptic effect that simulates saw tooth up waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    SawToothUp   = 4,

    /// <summary>
    ///  Supports periodic haptic effect that simulates saw tooth down waves.
    /// </summary>
    /// <seealso cref="TSdlHapticPeriodic"/>
    SawToothDown = 5,

    /// <summary>
    ///  Supports ramp haptic effect.
    /// </summary>
    /// <seealso cref="TSdlHapticRamp"/>
    Ramp         = 6,

    /// <summary>
    ///  Supports condition haptic effect that simulates a spring. Effect is
    ///  based on the axes position.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Spring       = 7,

    /// <summary>
    ///  Supports condition haptic effect that simulates dampening. Effect is
    ///  based on the axes velocity.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Damper       = 8,

    /// <summary>
    ///  Supports condition haptic effect that simulates inertia. Effect is
    ///  based on the axes acceleration.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Inertia      = 9,

    /// <summary>
    ///  Supports condition haptic effect that simulates friction. Effect is
    ///  based on the axes movement.
    /// </summary>
    /// <seealso cref="TSdlHapticCondition"/>
    Friction     = 10,

    /// <summary>
    ///  Supports haptic effect for direct control over high/low frequency motors.
    /// </summary>
    /// <seealso cref="TSdlHapticLeftRight"/>
    LeftRight    = 11,

    /// <summary>
    ///  Supports user defined custom haptic effect.
    /// </summary>
    Custom       = 15,

    /// <summary>
    ///  Device supports setting the global gain.
    /// </summary>
    /// <seealso cref="TSdlHaptic.SetGain"/>
    Gain         = 16,

    /// <summary>
    ///  Device supports setting autocenter.
    /// </summary>
    /// <seealso cref="TSdlHaptic.SetAutoCenter"/>
    AutoCenter   = 17,

    /// <summary>
    ///  Device supports querying effect status.
    /// </summary>
    /// <seealso cref="TSdlHaptic.GetEffectStatus"/>
    Status       = 18,

    /// <summary>
    ///  Devices supports being paused.
    /// </summary>
    /// <seealso cref="TSdlHaptic.Pause"/>
    /// <seealso cref="TSdlHaptic.Resume"/>
    Pause        = 19);
  TSdlHapticFeatures = set of TSdlHapticFeature;

type
  /// <summary>
  ///  Types of haptic directions
  /// </summary>
  TSdlHapticDirectionKind = (
    /// <summary>
    ///  Uses polar coordinates for the direction.
    /// </summary>
    /// <seealso cref="TSdlHapticDirection"/>
    Polar        = SDL_HAPTIC_POLAR,

    /// <summary>
    ///  Uses cartesian coordinates for the direction.
    /// </summary>
    /// <seealso cref="TSdlHapticDirection"/>
    Cartesian    = SDL_HAPTIC_CARTESIAN,

    /// <summary>
    ///  Uses spherical coordinates for the direction.
    /// </summary>
    /// <seealso cref="TSdlHapticDirection"/>
    Spherical    = SDL_HAPTIC_SPHERICAL,

    /// <summary>
    ///  Use this value to play an effect on the steering wheel axis.
    ///
    ///  This provides better compatibility across platforms and devices as SDL
    ///  will guess the correct axis.
    /// </summary>
    /// <seealso cref="TSdlHapticDirection"/>
    SteeringAxis = SDL_HAPTIC_STEERING_AXIS);

const
  /// <summary>
  ///  Used to play a device an infinite number of times.
  /// </summary>
  /// <seealso cref="TSdlHaptic.RunEffect"/>
  SDL_HAPTIC_INFINITY = Neslib.Sdl3.Api.SDL_HAPTIC_INFINITY;

type
  /// <summary>
  ///  Structure that represents a haptic direction.
  ///
  ///  This is the direction where the force comes from, instead of the direction
  ///  in which the force is exerted.
  ///
  ///  Directions can be specified by:
  ///
  ///  - TSdlHapticDirectionKind.Polar    : Specified by polar coordinates.
  ///  - TSdlHapticDirectionKind.Cartesian: Specified by cartesian coordinates.
  ///  - TSdlHapticDirectionKind.Spherical: Specified by spherical coordinates.
  ///
  ///  Cardinal directions of the haptic device are relative to the positioning of
  ///  the device. North is considered to be away from the user.
  ///
  ///  The following diagram represents the cardinal directions:
  ///
  ///  ```
  ///                .--.
  ///                |__| .-------.
  ///                |=.| |.-----.|
  ///                |--| ||     ||
  ///                |  | |'-----'|
  ///                |__|~')_____('
  ///                  [ COMPUTER ]
  ///
  ///
  ///                    North (0,-1)
  ///                        ^
  ///                        |
  ///                        |
  ///  (-1,0)  West ˂----[ HAPTIC ]----˃ East (1,0)
  ///                        |
  ///                        |
  ///                        v
  ///                     South (0,1)
  ///
  ///
  ///                     [ USER ]
  ///                       \|||/
  ///                       (o o)
  ///                 ---ooO-(_)-Ooo---
  ///  ```
  ///
  ///  If type is TSdlHapticDirectionKind.Polar, direction is encoded by
  ///  hundredths of a degree starting north and turning clockwise.
  ///  TSdlHapticDirectionKind.Polar only uses the first `Dir` property. The
  ///  cardinal directions would be:
  ///
  ///  - North:     0 (0 degrees)
  ///  - East :  9000 (90 degrees)
  ///  - South: 18000 (180 degrees)
  ///  - West : 27000 (270 degrees)
  ///
  ///  If type is TSdlHapticDirectionKind.Cartesian, direction is encoded by
  ///  three positions (X axis, Y axis and Z axis (with 3 axes)).
  ///  TSdlHapticDirectionKind.Cartesian uses the first three `Dir` properties.
  ///  The cardinal directions would be:
  ///
  ///  - North:  0,-1, 0
  ///  - East :  1, 0, 0
  ///  - South:  0, 1, 0
  ///  - West : -1, 0, 0
  ///
  ///  The Z axis represents the height of the effect if supported, otherwise it's
  ///  unused. In cartesian encoding (1, 2) would be the same as (2, 4), you can
  ///  use any multiple you want, only the direction matters.
  ///
  ///  If type is TSdlHapticDirectionKind.Spherical, direction is encoded by two
  ///  rotations. The first two `Dir` properties are used. The `Dir` properties
  ///  are as follows (all values are in hundredths of degrees):
  ///
  ///  - Degrees from (1, 0) rotated towards (0, 1).
  ///  - Degrees towards (0, 0, 1) (device needs at least 3 axes).
  ///
  ///  Example of force coming from the south with all encodings (force coming
  ///  from the south means the user will have to pull the stick to counteract):
  ///
  ///  ```delphi
  ///  var Direction: TSdlHapticDirection;
  ///
  ///  // Cartesian directions
  ///  Direction.Kind := TSdlHapticDirectionKind.Cartesian; // Using cartesian direction encoding.
  ///  Direction.Dir[0] := 0; // X position
  ///  Direction.Dir[1] := 1; // Y position
  ///  // Assuming the device has 2 axes, we don't need to specify third parameter.
  ///
  ///  // Polar directions
  ///  Direction.Kind := TSdlHapticDirectionKind.Polar; // We'll be using polar direction encoding.
  ///  Direction.Dir[0] := 18000; // Polar only uses first parameter
  ///
  ///  // Spherical coordinates
  ///  Direction.Kind := TSdlHapticDirectionKind.Spherical; // Spherical encoding
  ///  Direction.Dir[0] := 9000; // Since we only have two axes we don't need more parameters.
  ///  ```
  /// </summary>
  /// <seealso cref="TSdlHapticDirectionKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  /// <seealso cref="TSdlHaptic.NumAxes"/>
  TSdlHapticDirection = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticDirection;
    function GetKind: TSdlHapticDirectionKind; inline;
    procedure SetKind(const AValue: TSdlHapticDirectionKind); inline;
    function GetDir(const AIndex: Integer): Integer; inline;
    procedure SetDir(const AIndex, AValue: Integer); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The type of encoding.
    /// </summary>
    property Kind: TSdlHapticDirectionKind read GetKind write SetKind;

    /// <summary>
    ///  The encoded direction.
    /// </summary>
    property Dir[const AIndex: Integer]: Integer read GetDir write SetDir;
  end;
  PSdlHapticDirection = ^TSdlHapticDirection;

type
  /// <summary>
  ///  A record containing a template for a Constant effect.
  ///
  ///  This record is exclusively for the TSdlHapticKind.Constant effect.
  ///
  ///  A constant effect applies a constant force in the specified direction to
  ///  the joystick.
  /// </summary>
  /// <seealso cref="TSdlHapticKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  TSdlHapticConstant = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticConstant;
    function GetKind: TSdlHapticKind; inline;
    procedure SetKind(const AValue: TSdlHapticKind); inline;
    function GetDirection: PSdlHapticDirection; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  TSdlHapticKind.Constant
    /// </summary>
    property Kind: TSdlHapticKind read GetKind write SetKind;

    /// <summary>
    ///  Direction of the effect.
    /// </summary>
    property Direction: PSdlHapticDirection read GetDirection;

    /// <summary>
    ///  Duration of the effect in milliseconds.
    /// </summary>
    property Length: Cardinal read FHandle.length write FHandle.length;

    /// <summary>
    ///  Delay before starting the effect.
    /// </summary>
    property Delay: Word read FHandle.delay write FHandle.delay;

    /// <summary>
    ///  Button that triggers the effect.
    /// </summary>
    property Button: Word read FHandle.button write FHandle.button;

    /// <summary>
    ///  How soon it can be triggered again after button.
    /// </summary>
    property Interval: Word read FHandle.interval write FHandle.interval;

    /// <summary>
    ///  Strength of the constant effect.
    /// </summary>
    property Level: Smallint read FHandle.level write FHandle.level;

    /// <summary>
    ///  Duration of the attack.
    /// </summary>
    property AttackLength: Word read FHandle.attack_length write FHandle.attack_length;

    /// <summary>
    ///  Level at the start of the attack.
    /// </summary>
    property AttackLevel: Word read FHandle.attack_level write FHandle.attack_level;

    /// <summary>
    ///  Duration of the fade.
    /// </summary>
    property FadeLength: Word read FHandle.fade_length write FHandle.fade_length;

    /// <summary>
    ///  Level at the end of the fade.
    /// </summary>
    property FadeLevel: Word read FHandle.fade_level write FHandle.fade_level;
  end;

  /// <summary>
  ///  A record containing a template for a Periodic effect.
  ///
  ///  The record handles the following effects:
  ///
  ///  - TSdlHapticKind.Sine
  ///  - TSdlHapticKind.Square
  ///  - TSdlHapticKind.Triangle
  ///  - TSdlHapticKind.SawToothUp
  ///  - TSdlHapticKind.SawToothDown
  ///
  ///  A periodic effect consists in a wave-shaped effect that repeats itself over
  ///  time. The type determines the shape of the wave and the parameters
  ///  determine the dimensions of the wave.
  ///
  ///  Phase is given by hundredth of a degree meaning that giving the phase a
  ///  value of 9000 will displace it 25% of its period. Here are sample values:
  ///
  ///  - 0    : No phase displacement.
  ///  - 9000 : Displaced 25% of its period.
  ///  - 18000: Displaced 50% of its period.
  ///  - 27000: Displaced 75% of its period.
  ///  - 36000: Displaced 100% of its period, same as 0, but 0 is preferred.
  ///
  ///  Examples:
  ///
  ///  ```
  ///  TSdlHapticKind.Sine
  ///    __      __      __      __
  ///   /  \    /  \    /  \    /
  ///  /    \__/    \__/    \__/
  ///
  ///  TSdlHapticKind.Square
  ///   __    __    __    __    __
  ///  |  |  |  |  |  |  |  |  |  |
  ///  |  |__|  |__|  |__|  |__|  |
  ///
  ///  TSdlHapticKind.Triangle
  ///    /\    /\    /\    /\    /\
  ///   /  \  /  \  /  \  /  \  /
  ///  /    \/    \/    \/    \/
  ///
  ///  TSdlHapticKind.SawToothUp
  ///    /|  /|  /|  /|  /|  /|  /|
  ///   / | / | / | / | / | / | / |
  ///  /  |/  |/  |/  |/  |/  |/  |
  ///
  ///  TSdlHapticKind.SawToothDown
  ///  \  |\  |\  |\  |\  |\  |\  |
  ///   \ | \ | \ | \ | \ | \ | \ |
  ///    \|  \|  \|  \|  \|  \|  \|
  ///  ```
  /// </summary>
  /// <seealso cref="TSdlHapticKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  TSdlHapticPeriodic = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticPeriodic;
    function GetKind: TSdlHapticKind; inline;
    procedure SetKind(const AValue: TSdlHapticKind); inline;
    function GetDirection: PSdlHapticDirection; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  TSdlHapticKind.Sine, TSdlHapticKind.Square, TSdlHapticKind.Triangle,
    ///  TSdlHapticKind.SawToothUp or TSdlHapticKind.SawToothDown.
    /// </summary>
    property Kind: TSdlHapticKind read GetKind write SetKind;

    /// <summary>
    ///  Direction of the effect.
    /// </summary>
    property Direction: PSdlHapticDirection read GetDirection;

    /// <summary>
    ///  Duration of the effect in milliseconds.
    /// </summary>
    property Length: Cardinal read FHandle.length write FHandle.length;

    /// <summary>
    ///  Delay before starting the effect.
    /// </summary>
    property Delay: Word read FHandle.delay write FHandle.delay;

    /// <summary>
    ///  Button that triggers the effect.
    /// </summary>
    property Button: Word read FHandle.button write FHandle.button;

    /// <summary>
    ///  How soon it can be triggered again after button.
    /// </summary>
    property Interval: Word read FHandle.interval write FHandle.interval;

    /// <summary>
    ///  Period of the wave.
    /// </summary>
    property Period: Word read FHandle.period write FHandle.period;

    /// <summary>
    ///  Peak value; if negative, equivalent to 180 degrees extra phase shift.
    /// </summary>
    property Magnitude: Smallint read FHandle.magnitude write FHandle.magnitude;

    /// <summary>
    ///  Mean value of the wave.
    /// </summary>
    property Offset: Smallint read FHandle.offset write FHandle.offset;

    /// <summary>
    ///  Positive phase shift given by hundredth of a degree.
    /// </summary>
    property Phase: Word read FHandle.phase write FHandle.phase;

    /// <summary>
    ///  Duration of the attack.
    /// </summary>
    property AttackLength: Word read FHandle.attack_length write FHandle.attack_length;

    /// <summary>
    ///  Level at the start of the attack.
    /// </summary>
    property AttackLevel: Word read FHandle.attack_level write FHandle.attack_level;

    /// <summary>
    ///  Duration of the fade.
    /// </summary>
    property FadeLength: Word read FHandle.fade_length write FHandle.fade_length;

    /// <summary>
    ///  Level at the end of the fade.
    /// </summary>
    property FadeLevel: Word read FHandle.fade_level write FHandle.fade_level;
  end;

type
  /// <summary>
  ///  A record containing a template for a Condition effect.
  ///
  ///  The record handles the following effects:
  ///
  ///  - TSdlHapticKind.Spring: Effect based on axes position.
  ///  - TSdlHapticKind.Damper: Effect based on axes velocity.
  ///  - TSdlHapticKind.Inertia: Effect based on axes acceleration.
  ///  - TSdlHapticKind.Friction: Effect based on axes movement.
  ///
  ///  Direction is handled by condition internals instead of a direction member.
  ///  The condition effect specific members have three parameters. The first
  ///  refers to the X axis, the second refers to the Y axis and the third refers
  ///  to the Z axis. The right terms refer to the positive side of the axis and
  ///  the left terms refer to the negative side of the axis. Please refer to the
  ///  SDL_HapticDirection diagram for which side is positive and which is
  ///  negative.
  /// </summary>
  /// <seealso cref="TSdlHapticDirection"/>
  /// <seealso cref="TSdlHapticKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  TSdlHapticCondition = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticCondition;
    function GetKind: TSdlHapticKind; inline;
    procedure SetKind(const AValue: TSdlHapticKind); inline;
    function GetDirection: PSdlHapticDirection; inline;
    function GetCenter(const AIndex: Integer): Smallint; inline;
    function GetDeadBand(const AIndex: Integer): Word; inline;
    function GetLeftCoeff(const AIndex: Integer): Smallint; inline;
    function GetLeftSat(const AIndex: Integer): Word; inline;
    function GetRightCoeff(const AIndex: Integer): Smallint; inline;
    function GetRightSat(const AIndex: Integer): Word; inline;
    procedure SetCenter(const AIndex: Integer; const AValue: Smallint); inline;
    procedure SetDeadBand(const AIndex: Integer; const AValue: Word); inline;
    procedure SetLeftCoeff(const AIndex: Integer; const AValue: Smallint); inline;
    procedure SetLeftSat(const AIndex: Integer; const AValue: Word); inline;
    procedure SetRightCoeff(const AIndex: Integer; const AValue: Smallint); inline;
    procedure SetRightSat(const AIndex: Integer; const AValue: Word); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  TSdlHapticKind.Spring, TSdlHapticKind.Damper, TSdlHapticKind.Inertia or
    ///  TSdlHapticKind.Friction
    /// </summary>
    property Kind: TSdlHapticKind read GetKind write SetKind;

    /// <summary>
    ///  Direction of the effect.
    /// </summary>
    property Direction: PSdlHapticDirection read GetDirection;

    /// <summary>
    ///  Duration of the effect in milliseconds.
    /// </summary>
    property Length: Cardinal read FHandle.length write FHandle.length;

    /// <summary>
    ///  Delay before starting the effect.
    /// </summary>
    property Delay: Word read FHandle.delay write FHandle.delay;

    /// <summary>
    ///  Button that triggers the effect.
    /// </summary>
    property Button: Word read FHandle.button write FHandle.button;

    /// <summary>
    ///  How soon it can be triggered again after button.
    /// </summary>
    property Interval: Word read FHandle.interval write FHandle.interval;

    /// <summary>
    ///  Level when joystick is to the positive side; [0..2] max $FFFF.
    /// </summary>
    property RightSat[const AIndex: Integer]: Word read GetRightSat write SetRightSat;

    /// <summary>
    ///  Level when joystick is to the negative side; [0..2] max $FFFF.
    /// </summary>
    property LeftSat[const AIndex: Integer]: Word read GetLeftSat write SetLeftSat;

    /// <summary>
    ///  How fast to increase the force towards the positive side; [0..2].
    /// </summary>
    property RightCoeff[const AIndex: Integer]: Smallint read GetRightCoeff write SetRightCoeff;

    /// <summary>
    ///  How fast to increase the force towards the negative side; [0..2].
    /// </summary>
    property LeftCoeff[const AIndex: Integer]: Smallint read GetLeftCoeff write SetLeftCoeff;

    /// <summary>
    ///  Size of the dead zone; [0..2] max $FFFF: whole axis-range when 0-centered.
    /// </summary>
    property DeadBand[const AIndex: Integer]: Word read GetDeadBand write SetDeadBand;

    /// <summary>
    ///  Position of the dead zone; [0..2].
    /// </summary>
    property Center[const AIndex: Integer]: Smallint read GetCenter write SetCenter;
  end;

type
  /// <summary>
  ///  A record containing a template for a Ramp effect.
  ///
  ///  This record is exclusively for the TSdlHapticKind.Ramp effect.
  ///
  ///  The ramp effect starts at start strength and ends at end strength. It
  ///  augments in linear fashion. If you use attack and fade with a ramp the
  ///  effects get added to the ramp effect making the effect become quadratic
  ///  instead of linear.
  /// </summary>
  /// <seealso cref="TSdlHapticKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  TSdlHapticRamp = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticRamp;
    function GetKind: TSdlHapticKind; inline;
    procedure SetKind(const AValue: TSdlHapticKind); inline;
    function GetDirection: PSdlHapticDirection; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  TSdlHapticKind.Ramp
    /// </summary>
    property Kind: TSdlHapticKind read GetKind write SetKind;

    /// <summary>
    ///  Direction of the effect.
    /// </summary>
    property Direction: PSdlHapticDirection read GetDirection;

    /// <summary>
    ///  Duration of the effect in milliseconds.
    /// </summary>
    property Length: Cardinal read FHandle.length write FHandle.length;

    /// <summary>
    ///  Delay before starting the effect.
    /// </summary>
    property Delay: Word read FHandle.delay write FHandle.delay;

    /// <summary>
    ///  Button that triggers the effect.
    /// </summary>
    property Button: Word read FHandle.button write FHandle.button;

    /// <summary>
    ///  How soon it can be triggered again after button.
    /// </summary>
    property Interval: Word read FHandle.interval write FHandle.interval;

    /// <summary>
    ///  Beginning strength level.
    /// </summary>
    property Start: Smallint read FHandle.start write FHandle.start;

    /// <summary>
    ///  Ending strength level.
    /// </summary>
    property &End: Smallint read FHandle.&end write FHandle.&end;

    /// <summary>
    ///  Duration of the attack.
    /// </summary>
    property AttackLength: Word read FHandle.attack_length write FHandle.attack_length;

    /// <summary>
    ///  Level at the start of the attack.
    /// </summary>
    property AttackLevel: Word read FHandle.attack_level write FHandle.attack_level;

    /// <summary>
    ///  Duration of the fade.
    /// </summary>
    property FadeLength: Word read FHandle.fade_length write FHandle.fade_length;

    /// <summary>
    ///  Level at the end of the fade.
    /// </summary>
    property FadeLevel: Word read FHandle.fade_level write FHandle.fade_level;
  end;

type
  /// <summary>
  ///  A record containing a template for a Left/Right effect.
  ///
  ///  This record is exclusively for the TSdlHapticKind.LeftRight effect.
  ///
  ///  The Left/Right effect is used to explicitly control the large and small
  ///  motors, commonly found in modern game controllers. The small (right) motor
  ///  is high frequency, and the large (left) motor is low frequency.
  /// </summary>
  /// <seealso cref="TSdlHapticKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  TSdlHapticLeftRight = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticLeftRight;
    function GetKind: TSdlHapticKind; inline;
    procedure SetKind(const AValue: TSdlHapticKind); inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  TSdlHapticKind.LeftRight
    /// </summary>
    property Kind: TSdlHapticKind read GetKind write SetKind;

    /// <summary>
    ///  Duration of the effect in milliseconds.
    /// </summary>
    property Length: Cardinal read FHandle.length write FHandle.length;

    /// <summary>
    ///  Control of the large controller motor.
    /// </summary>
    property LargeMagnitude: Word read FHandle.large_magnitude write FHandle.large_magnitude;

    /// <summary>
    ///  Control of the small controller motor.
    /// </summary>
    property SmallMagnitude: Word read FHandle.small_magnitude write FHandle.small_magnitude;
  end;

type
  /// <summary>
  ///  A record containing a template for the TSdlHapticKind.Custom effect.
  ///
  ///  This record is exclusively for the TSdlHapticKind.Custom effect.
  ///
  ///  A custom force feedback effect is much like a periodic effect, where the
  ///  application can define its exact shape. You will have to allocate the data
  ///  yourself. Data should consist of Channels * Samples UInt16 samples.
  ///
  ///  If channels is one, the effect is rotated using the defined direction.
  ///  Otherwise it uses the samples in data for the different axes.
  /// </summary>
  /// <seealso cref="TSdlHapticKind"/>
  /// <seealso cref="TSdlHapticEffect"/>
  TSdlHapticCustom = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticCustom;
    function GetKind: TSdlHapticKind; inline;
    procedure SetKind(const AValue: TSdlHapticKind); inline;
    function GetDirection: PSdlHapticDirection; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  TSdlHapticKind.Custom
    /// </summary>
    property Kind: TSdlHapticKind read GetKind write SetKind;

    /// <summary>
    ///  Direction of the effect.
    /// </summary>
    property Direction: PSdlHapticDirection read GetDirection;

    /// <summary>
    ///  Duration of the effect in milliseconds.
    /// </summary>
    property Length: Cardinal read FHandle.length write FHandle.length;

    /// <summary>
    ///  Delay before starting the effect.
    /// </summary>
    property Delay: Word read FHandle.delay write FHandle.delay;

    /// <summary>
    ///  Button that triggers the effect.
    /// </summary>
    property Button: Word read FHandle.button write FHandle.button;

    /// <summary>
    ///  How soon it can be triggered again after button.
    /// </summary>
    property Interval: Word read FHandle.interval write FHandle.interval;

    /// <summary>
    ///  Axes to use, minimum of one.
    /// </summary>
    property Channels: Byte read FHandle.channels write FHandle.channels;

    /// <summary>
    ///  Sample periods.
    /// </summary>
    property Period: Word read FHandle.period write FHandle.period;

    /// <summary>
    ///  Amount of samples.
    /// </summary>
    property Samples: Word read FHandle.samples write FHandle.samples;

    /// <summary>
    ///  Should contain channels*samples items.
    /// </summary>
    property Data: PWord read FHandle.data write FHandle.data;

    /// <summary>
    ///  Duration of the attack.
    /// </summary>
    property AttackLength: Word read FHandle.attack_length write FHandle.attack_length;

    /// <summary>
    ///  Level at the start of the attack.
    /// </summary>
    property AttackLevel: Word read FHandle.attack_level write FHandle.attack_level;

    /// <summary>
    ///  Duration of the fade.
    /// </summary>
    property FadeLength: Word read FHandle.fade_length write FHandle.fade_length;

    /// <summary>
    ///  Level at the end of the fade.
    /// </summary>
    property FadeLevel: Word read FHandle.fade_level write FHandle.fade_level;
  end;

type
  /// <summary>
  ///  The generic template for any haptic effect.
  ///
  ///  All values max at 32767 ($7FFF). Signed values also can be negative. Time
  ///  values unless specified otherwise are in milliseconds.
  ///
  ///  You can also pass SDL_HAPTIC_INFINITY to length instead of a 0-32767 value.
  ///  Neither Delay, Interval, AttackLength nor FadeLength support
  ///  SDL_HAPTIC_INFINITY. Fade will also not be used since effect never ends.
  ///
  ///  Additionally, the TSdlHapticKind.Ramp effect does not support a duration of
  ///  SDL_HAPTIC_INFINITY.
  ///
  ///  Button triggers may not be supported on all devices, it is advised to not
  ///  use them if possible. Buttons start at index 1 instead of index 0 like the
  ///  joystick.
  ///
  ///  If both AttackLength and FadeLevel are 0, the envelope is not used,
  ///  otherwise both values are used.
  ///
  ///  Common parts:
  ///
  ///  ```delphi
  ///  // Replay - All effects have this
  ///  Length: Cardinal;   // Duration of effect (ms).
  ///  Delay: Word;        // Delay before starting effect.
  ///
  ///  // Trigger - All effects have this
  ///  Button: Word;       // Button that triggers effect.
  ///  Interval: Word;     // How soon before effect can be triggered again.
  ///
  ///  // Envelope - All effects except condition effects have this
  ///  AttackLength: Word; // Duration of the attack (ms).
  ///  AttackLevel: Word;  // Level at the start of the attack.
  ///  FadeLength: Word;   // Duration of the fade out (ms).
  ///  FadeLevel: Word;    // Level at the end of the fade.
  ///  ```
  ///
  ///  Here we have an example of a constant effect evolution in time:
  ///
  ///  ```
  ///  Strength
  ///  ^
  ///  |
  ///  |    effect level -->  _________________
  ///  |                     /                 \
  ///  |                    /                   \
  ///  |                   /                     \
  ///  |                  /                       \
  ///  | attack_level --> |                        \
  ///  |                  |                        |  ˂---  fade_level
  ///  |
  ///  +--------------------------------------------------> Time
  ///                     [--]                 [---]
  ///                     attack_length        fade_length
  ///
  ///  [------------------][-----------------------]
  ///  delay               length
  ///  ```
  ///
  ///  Note either the attack_level or the fade_level may be above the actual
  ///  effect level.
  /// </summary>
  /// <seealso cref="TSdlHapticConstant"/>
  /// <seealso cref="TSdlHapticPeriodic"/>
  /// <seealso cref="TSdlHapticCondition"/>
  /// <seealso cref="TSdlHapticRamp"/>
  /// <seealso cref="TSdlHapticLeftRight"/>
  /// <seealso cref="TSdlHapticCustom"/>
  TSdlHapticEffect = record
  public
    case Byte of
      /// <summary>Effect type, shared with all effects.</summary>
      0: (Kind: TSdlHapticKind);

      /// <summary>Constant effect.</summary>
      1: (Constant: TSdlHapticConstant);

      /// <summary>Periodic effect.</summary>
      2: (Periodic: TSdlHapticPeriodic);

      /// <summary>Condition effect.</summary>
      3: (Condition: TSdlHapticCondition);

      /// <summary>Ramp effect.</summary>
      4: (Ramp: TSdlHapticRamp);

      /// <summary>Left/Right effect.</summary>
      5: (LeftRight: TSdlHapticLeftRight);

      /// <summary>Custom effect.</summary>
      6: (Custom: TSdlHapticCustom);
  end;

type
  /// <summary>
  ///  This is a unique ID for a haptic device for the time it is connected to the
  ///  system, and is never reused for the lifetime of the application.
  ///
  ///  If the haptic device is disconnected and reconnected, it will get a new ID.
  ///
  ///  The value 0 is an invalid ID.
  /// </summary>
  TSdlHapticID = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_HapticID;
    function GetName: String; inline;
    class function GetDevices: TArray<TSdlHapticID>; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlHapticID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlHapticID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlHapticID; inline; static;
  public
    /// <summary>
    ///  Get the implementation dependent name of the haptic device, or an empty
    ///  string if no name can be found.
    ///
    ///  This can be used before any haptic devices are opened.
    /// </summary>
    /// <seealso cref="TSdlHaptic.Name"/>
    /// <seealso cref="Open"/>
    property Name: String read GetName;

    /// <summary>
    ///  A list of currently connected haptic devices.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Open"/>
    class property Devices: TArray<TSdlHapticID> read GetDevices;
  end;

type
  /// <summary>
  ///  A haptic effect ID
  /// </summary>
  TSdlHapticEffectID = Integer;

type
  /// <summary>
  ///  The haptic record used to identify an SDL haptic.
  /// </summary>
  TSdlHaptic = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Haptic;
    function GetID: TSdlHapticID; inline;
    function GetName: String; inline;
    function GetMaxEffects: Integer; inline;
    function GetMaxEffectsPlaying: Integer; inline;
    function GetFeatures: TSdlHapticFeatures; inline;
    function GetNumAxes: Integer; inline;
    function GetIsRumbleSupported: Boolean; inline;
  {$REGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlHaptic; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlHaptic; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlHaptic; inline; static;
  public
    /// <summary>
    ///  Open a haptic device for use.
    ///
    ///  When opening a haptic device, its gain will be set to maximum and
    ///  autocenter will be disabled. To modify these values use
    ///  TSdlHaptic.SetGain and TSdlHaptic.SetAutoCenter.
    /// </summary>
    /// <param name="AInstanceID">The haptic device instance ID.</param>
    /// <returns>The haptic device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlHapticID.Open"/>
    /// <seealso cref="TSdlHaptic.Close"/>
    /// <seealso cref="TSdlHapticID.Devices"/>
    /// <seealso cref="TSdlHaptic.SetAutoCenter"/>
    /// <seealso cref="TSdlHaptic.SetGain"/>
    class function Open(const AInstanceID: TSdlHapticID): TSdlHaptic; inline; static;

    /// <summary>
    ///  Try to open a haptic device from the current mouse.
    /// </summary>
    /// <returns>The haptic device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    /// <seealso cref="SdlIsMouseHaptic"/>
    class function OpenFromMouse: TSdlHaptic; inline; static;

    /// <summary>
    ///  Open a haptic device for use from a joystick device.
    ///
    ///  You must still close the haptic device separately. It will not be closed
    ///  with the joystick.
    ///
    ///  When opened from a joystick you should first close the haptic device before
    ///  closing the joystick device. If not, on some implementations the haptic
    ///  device will also get unallocated and you'll be unable to use force feedback
    ///  on that device.
    /// </summary>
    /// <param name="AJoystick">The joystick to create a haptic device from.</param>
    /// <returns>The haptic device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    /// <seealso cref="SdlIsJoystickHaptic"/>
    class function OpenFromJoystick(const AJoystick: TSdlJoystick): TSdlHaptic; inline; static;

    /// <summary>
    ///  Close the haptic device previously opened.
    /// </summary>
    /// <seealso cref="Open"/>
    /// <seealso cref="OpenFromMouse"/>
    /// <seealso cref="OpenFromJoystick"/>
    procedure Close; inline;

    /// <summary>
    ///  Get the haptic device associated with an instance ID, if it has been opened.
    /// </summary>
    /// <param name="AInstanceId">The instance ID to get the haptic device for.</param>
    /// <exception name="ESdlError">Raised on failure (eg. if it hasn't been opened yet).</exception>
    class function From(const AInstanceID: TSdlHapticID): TSdlHaptic; inline; static;

    /// <summary>
    ///  Check to see if an effect is supported by the haptic device.
    /// </summary>
    /// <param name="AEffect">The desired effect to query.</param>
    /// <returns>True if the effect is supported or False if it isn't.</returns>
    /// <seealso cref="TSdlHapticEffect"/>
    /// <seealso cref="Features"/>
    function IsEffectSupported(const AEffect: TSdlHapticEffect): Boolean; inline;

    /// <summary>
    ///  Create a new haptic effect on this device.
    /// </summary>
    /// <param name="AEffect">A TSdlHapticEffect record containing the properties
    ///  of the effect to create.</param>
    /// <returns>The effect ID.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FreeEffect"/>
    /// <seealso cref="RunEffect"/>
    /// <seealso cref="UpdateEffect"/>
    function CreateEffect(const AEffect: TSdlHapticEffect): TSdlHapticEffectID; inline;

    /// <summary>
    ///  Update the properties of an effect.
    ///
    ///  Can be used dynamically, although behavior when dynamically changing
    ///  direction may be strange. Specifically the effect may re-upload itself and
    ///  start playing from the start. You also cannot change the type either when
    ///  running UpdateEffect.
    /// </summary>
    /// <param name="AEffect">The identifier of the effect to update.</param>
    /// <param name="AData">A TSdlHapticEffect structure containing the new
    ///  effect properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="CreateEffect"/>
    /// <seealso cref="RunEffect"/>
    procedure UpdateEffect(const AEffect: TSdlHapticEffectID;
      const AData: TSdlHapticEffect); inline;

    /// <summary>
    ///  Run the haptic effect on this haptic device.
    ///
    ///  To repeat the effect over and over indefinitely, set `AIterations` to
    ///  `SDL_HAPTIC_INFINITY`. (Repeats the envelope - attack and fade.) To make
    ///  one instance of the effect last indefinitely (so the effect does not fade),
    ///  set the effect's `Length` in its record to `SDL_HAPTIC_INFINITY`
    ///  instead.
    /// </summary>
    /// <param name="AEffect">The ID of the haptic effect to run.</param>
    /// <param name="AIterations">The number of iterations to run the effect;
    ///  use `SDL_HAPTIC_INFINITY` to repeat forever.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetEffectStatus"/>
    /// <seealso cref="StopEffect"/>
    /// <seealso cref="StopEffects"/>
    procedure RunEffect(const AEffect: TSdlHapticEffectID;
      const AIterations: Cardinal); inline;

    /// <summary>
    ///  Stop the haptic effect on this device.
    /// </summary>
    /// <param name="AEffect">The ID of the haptic effect to stop.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="RunEffect"/>
    /// <seealso cref="StopEffects"/>
    procedure StopEffect(const AEffect: TSdlHapticEffectID); inline;

    /// <summary>
    ///  Destroy a haptic effect on this device.
    ///
    ///  This will stop the effect if it's running. Effects are automatically
    ///  destroyed when the device is closed.
    /// </summary>
    /// <param name="AEffect">The ID of the haptic effect to destroy.</param>
    /// <seealso cref="CreateEffect"/>
    procedure FreeEffect(const AEffect: TSdlHapticEffectID); inline;

    /// <summary>
    ///  Get the status of the current effect on this haptic device.
    ///
    ///  Device must support the TSdlHapticFeature.Status feature.
    /// </summary>
    /// <param name="AEffect">The ID of the haptic effect to query its status.</param>
    /// <returns>True if it is playing, False if it isn't playing or haptic
    ///  status isn't supported.</returns>
    /// <seealso cref="Features"/>
    function GetEffectStatus(const AEffect: TSdlHapticEffectID): Boolean; inline;

    /// <summary>
    ///  Set the global gain of the haptic device.
    ///
    ///  Device must support the TSdlHapticFeature.Gain feature.
    ///
    ///  The user may specify the maximum gain by setting the environment variable
    ///  `SDL_HAPTIC_GAIN_MAX` which should be between 0 and 100. All calls to
    ///  SetGain will scale linearly using `SDL_HAPTIC_GAIN_MAX` as the maximum.
    /// </summary>
    /// <param name="AGain">Value to set the gain to, should be between 0 and 100.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Features"/>
    procedure SetGain(const AGain: Integer); inline;

    /// <summary>
    ///  Set the global autocenter of the device.
    ///
    ///  Autocenter should be between 0 and 100. Setting it to 0 will disable
    ///  autocentering.
    ///
    ///  Device must support the TSdlHapticFeature.AutoCenter feature.
    /// </summary>
    /// <param name="AAutocenter">Value to set autocenter to (0-100).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Features"/>
    procedure SetAutoCenter(const AAutoCenter: Integer); inline;

    /// <summary>
    ///  Pause the haptic device.
    ///
    ///  Device must support the `TSdlHapticFeature.Pause` feature. Call
    ///  Resume to resume playback.
    ///
    ///  Do not modify the effects nor add new ones while the device is paused. That
    ///  can cause all sorts of weird errors.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Resume"/>
    procedure Pause; inline;

    /// <summary>
    ///  Resume the haptic device.
    ///
    ///  Call to unpause after Pause.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Pause"/>
    procedure Resume; inline;

    /// <summary>
    ///  Stop all the currently playing effects on the haptic device.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="RunEffect"/>
    /// <seealso cref="StopEffect"/>
    procedure StopEffects; inline;

    /// <summary>
    ///  Initialize the haptic device for simple rumble playback.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PlayRumble"/>
    /// <seealso cref="StopRumble"/>
    /// <seealso cref="IsRumbleSupported"/>
    procedure InitRumble; inline;


    /// <summary>
    ///  Run a simple rumble effect on the haptic device.
    /// </summary>
    /// <param name="AStrength">Strength of the rumble to play as a 0-1 float value.</param>
    /// <param name="ALengthMs">Length of the rumble to play in milliseconds.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="InitRumble"/>
    /// <seealso cref="StopRumble"/>
    procedure PlayRumble(const AStrength: Single; const ALengthMs: Integer); inline;

    /// <summary>
    ///  Stop the simple rumble on the haptic device.
    /// </summary>
    /// <seealso cref="PlayRumble"/>
    procedure StopRumble; inline;

    /// <summary>
    ///  The instance ID of this opened haptic device.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property ID: TSdlHapticID read GetID;

    /// <summary>
    ///  The implementation dependent name of this haptic device, or an empty
    ///  string if no name can be found.
    /// </summary>
    /// <seealso cref="TSdlHapticID.Name"/>
    property Name: String read GetName;

    /// <summary>
    ///  The number of effects a haptic device can store.
    ///
    ///  On some platforms this isn't fully supported, and therefore is an
    ///  approximation. Always check to see if your created effect was actually
    ///  created and do not rely solely on this property.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MaxEffectsPlaying"/>
    /// <seealso cref="Features"/>
    property MaxEffects: Integer read GetMaxEffects;

    /// <summary>
    ///  The number of effects a haptic device can play at the same time.
    ///
    ///  This is not supported on all platforms, but will always return a value.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MaxEffects"/>
    /// <seealso cref="Features"/>
    property MaxEffectsPlaying: Integer read GetMaxEffectsPlaying;

    /// <summary>
    ///  The haptic device's supported features.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsEffectSupported"/>
    /// <seealso cref="MaxEffects"/>
    property Features: TSdlHapticFeatures read GetFeatures;

    /// <summary>
    ///  The number of haptic axes the device has.
    ///
    ///  The number of haptic axes might be useful if working with the
    ///  TSdlHapticDirection effect.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NumAxes: Integer read GetNumAxes;

    /// <summary>
    ///  Whether rumble is supported on this haptic device.
    /// </summary>
    /// <seealso cref="InitRumble"/>
    property IsRumbleSupported: Boolean read GetIsRumbleSupported;
  end;

type
  _TSdlHapticIDHelper = record helper for TSdlHapticID
  public
    /// <summary>
    ///  Open a haptic device for use.
    ///
    ///  When opening a haptic device, its gain will be set to maximum and
    ///  autocenter will be disabled. To modify these values use
    ///  TSdlHaptic.SetGain and TSdlHaptic.SetAutoCenter.
    /// </summary>
    /// <returns>The haptic device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlHaptic.Open"/>
    /// <seealso cref="TSdlHaptic.Close"/>
    /// <seealso cref="TSdlHapticID.Devices"/>
    /// <seealso cref="TSdlHaptic.SetAutoCenter"/>
    /// <seealso cref="TSdlHaptic.SetGain"/>
    function Open: TSdlHaptic; inline;
  end;

/// <summary>
///  Query whether or not the current mouse has haptic capabilities.
/// </summary>
/// <returns>True if the mouse is haptic or False if it isn't.</returns>
/// <seealso cref="TSdlHaptic.OpenFromMouse"/>
function SdlIsMouseHaptic: Boolean; inline;

/// <summary>
///  Query if a joystick has haptic features.
/// </summary>
/// <param name="AJoystick">The joystick to test for haptic capabilities.</param>
/// <returns>True if the joystick is haptic or False if it isn't.</returns>
/// <seealso cref="TSdlHaptic.Open"/>
function SdlIsJoystickHaptic(const AJoystick: TSdlJoystick): Boolean; inline;
{$ENDREGION 'Force Feedback ("Haptic")'}

implementation

function SdlIsMouseHaptic: Boolean;
begin
  Result := SDL_IsMouseHaptic;
end;

function SdlIsJoystickHaptic(const AJoystick: TSdlJoystick): Boolean;
begin
  Result := SDL_IsJoystickHaptic(SDL_Joystick(AJoystick));
end;

{ TSdlHapticDirection }

function TSdlHapticDirection.GetDir(const AIndex: Integer): Integer;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.dir[AIndex];
end;

function TSdlHapticDirection.GetKind: TSdlHapticDirectionKind;
begin
  Result := TSdlHapticDirectionKind(FHandle.&type);
end;

procedure TSdlHapticDirection.SetDir(const AIndex, AValue: Integer);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.dir[AIndex] := AValue;
end;

procedure TSdlHapticDirection.SetKind(const AValue: TSdlHapticDirectionKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlHapticConstant }

function TSdlHapticConstant.GetDirection: PSdlHapticDirection;
begin
  Result := @FHandle.direction;
end;

function TSdlHapticConstant.GetKind: TSdlHapticKind;
begin
  Result := TSdlHapticKind(FHandle.&type);
end;

procedure TSdlHapticConstant.SetKind(const AValue: TSdlHapticKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlHapticPeriodic }

function TSdlHapticPeriodic.GetDirection: PSdlHapticDirection;
begin
  Result := @FHandle.direction;
end;

function TSdlHapticPeriodic.GetKind: TSdlHapticKind;
begin
  Result := TSdlHapticKind(FHandle.&type);
end;

procedure TSdlHapticPeriodic.SetKind(const AValue: TSdlHapticKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlHapticCondition }

function TSdlHapticCondition.GetCenter(const AIndex: Integer): Smallint;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.center[AIndex];
end;

function TSdlHapticCondition.GetDeadBand(const AIndex: Integer): Word;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.deadband[AIndex];
end;

function TSdlHapticCondition.GetDirection: PSdlHapticDirection;
begin
  Result := @FHandle.direction;
end;

function TSdlHapticCondition.GetKind: TSdlHapticKind;
begin
  Result := TSdlHapticKind(FHandle.&type);
end;

function TSdlHapticCondition.GetLeftCoeff(const AIndex: Integer): Smallint;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.left_coeff[AIndex];
end;

function TSdlHapticCondition.GetLeftSat(const AIndex: Integer): Word;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.left_sat[AIndex];
end;

function TSdlHapticCondition.GetRightCoeff(const AIndex: Integer): Smallint;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.right_coeff[AIndex];
end;

function TSdlHapticCondition.GetRightSat(const AIndex: Integer): Word;
begin
  Assert(Cardinal(AIndex) <= 2);
  Result := FHandle.right_sat[AIndex];
end;

procedure TSdlHapticCondition.SetCenter(const AIndex: Integer;
  const AValue: Smallint);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.center[AIndex] := AValue;;
end;

procedure TSdlHapticCondition.SetDeadBand(const AIndex: Integer;
  const AValue: Word);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.deadband[AIndex] := AValue;;
end;

procedure TSdlHapticCondition.SetKind(const AValue: TSdlHapticKind);
begin
  FHandle.&type := Ord(AValue);
end;

procedure TSdlHapticCondition.SetLeftCoeff(const AIndex: Integer;
  const AValue: Smallint);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.left_coeff[AIndex] := AValue;;
end;

procedure TSdlHapticCondition.SetLeftSat(const AIndex: Integer;
  const AValue: Word);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.left_sat[AIndex] := AValue;;
end;

procedure TSdlHapticCondition.SetRightCoeff(const AIndex: Integer;
  const AValue: Smallint);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.right_coeff[AIndex] := AValue;;
end;

procedure TSdlHapticCondition.SetRightSat(const AIndex: Integer;
  const AValue: Word);
begin
  Assert(Cardinal(AIndex) <= 2);
  FHandle.right_sat[AIndex] := AValue;;
end;

{ TSdlHapticRamp }

function TSdlHapticRamp.GetDirection: PSdlHapticDirection;
begin
  Result := @FHandle.direction;
end;

function TSdlHapticRamp.GetKind: TSdlHapticKind;
begin
  Result := TSdlHapticKind(FHandle.&type);
end;

procedure TSdlHapticRamp.SetKind(const AValue: TSdlHapticKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlHapticLeftRight }

function TSdlHapticLeftRight.GetKind: TSdlHapticKind;
begin
  Result := TSdlHapticKind(FHandle.&type);
end;

procedure TSdlHapticLeftRight.SetKind(const AValue: TSdlHapticKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlHapticCustom }

function TSdlHapticCustom.GetDirection: PSdlHapticDirection;
begin
  Result := @FHandle.direction;
end;

function TSdlHapticCustom.GetKind: TSdlHapticKind;
begin
  Result := TSdlHapticKind(FHandle.&type);
end;

procedure TSdlHapticCustom.SetKind(const AValue: TSdlHapticKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlHapticID }

class operator TSdlHapticID.Equal(const ALeft: TSdlHapticID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class function TSdlHapticID.GetDevices: TArray<TSdlHapticID>;
begin
  var Count := 0;
  var Devices := SDL_GetHaptics(@Count);
  if (SdlSucceeded(Devices)) then
  try
    SetLength(Result, Count);
    Move(Devices^, Result[0], Count * SizeOf(SDL_HapticID));
  finally
    SDL_free(Devices);
  end;
end;

function TSdlHapticID.GetName: String;
begin
  Result := __ToString(SDL_GetHapticNameForID(FHandle));
end;

class operator TSdlHapticID.Implicit(const AValue: Cardinal): TSdlHapticID;
begin
  Result.FHandle := AValue;
end;

class operator TSdlHapticID.NotEqual(const ALeft: TSdlHapticID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ _TSdlHapticIDHelper }

function _TSdlHapticIDHelper.Open: TSdlHaptic;
begin
  Result.FHandle := SDL_OpenHaptic(FHandle);
  SdlCheck(Result.FHandle);
end;

{ TSdlHaptic }

procedure TSdlHaptic.Close;
begin
  SDL_CloseHaptic(FHandle);
  FHandle := 0;
end;

function TSdlHaptic.CreateEffect(
  const AEffect: TSdlHapticEffect): TSdlHapticEffectID;
begin
  Result := SDL_CreateHapticEffect(FHandle, @AEffect);
  if (Result = -1) then
    __HandleError;
end;

class operator TSdlHaptic.Equal(const ALeft: TSdlHaptic;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlHaptic.FreeEffect(const AEffect: TSdlHapticEffectID);
begin
  SDL_DestroyHapticEffect(FHandle, AEffect);
end;

class function TSdlHaptic.From(const AInstanceID: TSdlHapticID): TSdlHaptic;
begin
  Result.FHandle := SDL_GetHapticFromID(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlHaptic.GetEffectStatus(const AEffect: TSdlHapticEffectID): Boolean;
begin
  Result := SDL_GetHapticEffectStatus(FHandle, AEffect);
end;

function TSdlHaptic.GetFeatures: TSdlHapticFeatures;
begin
  Cardinal(Result) := SDL_GetHapticFeatures(FHandle);
  if (Result = []) then
    __HandleError;
end;

function TSdlHaptic.GetID: TSdlHapticID;
begin
  Result.FHandle := SDL_GetHapticID(FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlHaptic.GetIsRumbleSupported: Boolean;
begin
  Result := SDL_HapticRumbleSupported(FHandle);
end;

function TSdlHaptic.GetMaxEffects: Integer;
begin
  Result := SDL_GetMaxHapticEffects(FHandle);
  if (Result < 0) then
    __HandleError;
end;

function TSdlHaptic.GetMaxEffectsPlaying: Integer;
begin
  Result := SDL_GetMaxHapticEffectsPlaying(FHandle);
  if (Result < 0) then
    __HandleError;
end;

function TSdlHaptic.GetName: String;
begin
  Result := __ToString(SDL_GetHapticName(FHandle));
end;

function TSdlHaptic.GetNumAxes: Integer;
begin
  Result := SDL_GetNumHapticAxes(FHandle);
  if (Result = -1) then
    __HandleError;
end;

class operator TSdlHaptic.Implicit(const AValue: Pointer): TSdlHaptic;
begin
  Result.FHandle := THandle(AValue);
end;

procedure TSdlHaptic.InitRumble;
begin
  SdlCheck(SDL_InitHapticRumble(FHandle));
end;

function TSdlHaptic.IsEffectSupported(const AEffect: TSdlHapticEffect): Boolean;
begin
  Result := SDL_HapticEffectSupported(FHandle, @AEffect);
end;

class operator TSdlHaptic.NotEqual(const ALeft: TSdlHaptic;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class function TSdlHaptic.Open(const AInstanceID: TSdlHapticID): TSdlHaptic;
begin
  Result.FHandle := SDL_OpenHaptic(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

class function TSdlHaptic.OpenFromJoystick(
  const AJoystick: TSdlJoystick): TSdlHaptic;
begin
  Result.FHandle := SDL_OpenHapticFromJoystick(SDL_Joystick(AJoystick));
  SdlCheck(Result.FHandle);
end;

class function TSdlHaptic.OpenFromMouse: TSdlHaptic;
begin
  Result.FHandle := SDL_OpenHapticFromMouse;
  SdlCheck(Result.FHandle);
end;

procedure TSdlHaptic.Pause;
begin
  SdlCheck(SDL_PauseHaptic(FHandle));
end;

procedure TSdlHaptic.PlayRumble(const AStrength: Single;
  const ALengthMs: Integer);
begin
  SdlCheck(SDL_PlayHapticRumble(FHandle, AStrength, ALengthMs));
end;

procedure TSdlHaptic.Resume;
begin
  SdlCheck(SDL_ResumeHaptic(FHandle));
end;

procedure TSdlHaptic.RunEffect(const AEffect: TSdlHapticEffectID;
  const AIterations: Cardinal);
begin
  SdlCheck(SDL_RunHapticEffect(FHandle, AEffect, AIterations));
end;

procedure TSdlHaptic.SetAutoCenter(const AAutoCenter: Integer);
begin
  SdlCheck(SDL_SetHapticAutocenter(FHandle, AAutoCenter));
end;

procedure TSdlHaptic.SetGain(const AGain: Integer);
begin
  SdlCheck(SDL_SetHapticGain(FHandle, AGain));
end;

procedure TSdlHaptic.StopEffect(const AEffect: TSdlHapticEffectID);
begin
  SdlCheck(SDL_StopHapticEffect(FHandle, AEffect));
end;

procedure TSdlHaptic.StopEffects;
begin
  SdlCheck(SDL_StopHapticEffects(FHandle));
end;

procedure TSdlHaptic.StopRumble;
begin
  SdlCheck(SDL_StopHapticRumble(FHandle));
end;

procedure TSdlHaptic.UpdateEffect(const AEffect: TSdlHapticEffectID;
  const AData: TSdlHapticEffect);
begin
  SdlCheck(SDL_UpdateHapticEffect(FHandle, AEffect, @AData));
end;

initialization
  Assert(SizeOf(TSdlHapticKind) = 2);
  Assert(SizeOf(TSdlHapticDirectionKind) = 4);

end.
