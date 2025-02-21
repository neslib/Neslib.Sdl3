program JoystickEvents;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Input,
  Neslib.Sdl3.Events,
  Neslib.Sdl3.Additional,
  Neslib.Sdl3.Time,
  Neslib.Sdl3;

{ This example code looks for joystick input in the event handler, and
  reports any changes as a flood of info.

  Joysticks are low-level interfaces: there's something with a bunch of
  buttons, axes and hats, in no understood order or position. This is
  a flexible interface, but you'll need to build some sort of configuration
  UI to let people tell you what button, etc, does what. On top of this
  interface, SDL offers the "gamepad" API, which works with lots of devices,
  and knows how to map arbitrary buttons and such to look like an
  Xbox/PlayStation/etc gamepad. This is easier, and better, for many games,
  but isn't necessarily a good fit for complex apps and hardware. A flight
  simulator, a realistic racing game, etc, might want this interface instead
  of gamepads. }

const
  MOTION_EVENT_COOLDOWN = 40;

type
  PEventMessage = ^TEventMessage;
  TEventMessage = record
  public
    Text: String;
    Color: TSdlColor;
    StartTicks: Int64;
    Next: PEventMessage;
  end;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FColors: array [0..63] of TSdlColor;
    FMessages: TEventMessage;
    FMessagesTail: PEventMessage;
    FAxisMotionCooldownTime: Int64;
    FBallMotionCooldownTime: Int64;
  private
    procedure AddMessage(const AJoystickID: TSdlJoystickID;
      const AMessage: String); overload;
    procedure AddMessage(const AJoystickID: TSdlJoystickID;
      const AMessage: String; const AArgs: array of const); overload;
  private
    class function HatStateString(const AState: TSdlHats): String; static;
    class function BatteryStateString(const AState: TSdlPowerState): String; static;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    function Event(const AEvent: TSdlEvent): TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

procedure TApp.AddMessage(const AJoystickID: TSdlJoystickID;
  const AMessage: String);
begin
  var Msg := PEventMessage(SdlCAlloc(1, SizeOf(TEventMessage)));
  Msg.Text := AMessage;
  Msg.Color := FColors[Integer(AJoystickID.ID) mod Length(FColors)];
  Msg.StartTicks := SdlGetTicks;

  FMessagesTail.Next := Msg;
  FMessagesTail := Msg;
end;

procedure TApp.AddMessage(const AJoystickID: TSdlJoystickID;
  const AMessage: String; const AArgs: array of const);
begin
  AddMessage(AJoystickID, Format(AMessage, AArgs));
end;

class function TApp.BatteryStateString(const AState: TSdlPowerState): String;
begin
  case AState of
    TSdlPowerState.Error:
      Result := 'ERROR';

    TSdlPowerState.OnBattery:
      Result := 'ON BATTERY';

    TSdlPowerState.NoBattery:
      Result := 'NO BATTERY';

    TSdlPowerState.Charging:
      Result := 'CHARGING';

    TSdlPowerState.Charged:
      Result := 'CHARGED';
  else
    Result := 'UNKNOWN';
  end;
end;

class function TApp.HatStateString(const AState: TSdlHats): String;

  procedure CheckState(const AHat: TSdlHat; const AValue: String);
  begin
    if (AHat in AState) then
    begin
      if (Result <> '') then
        Result := Result + '+';
      Result := Result + AValue;
    end;
  end;

begin
  if (AState = []) then
    Exit('CENTERED');

  Result := '';
  CheckState(TSdlHat.Left, 'LEFT');
  CheckState(TSdlHat.Right, 'RIGHT');
  CheckState(TSdlHat.Up, 'UP');
  CheckState(TSdlHat.Down, 'DOWN');
end;

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Input Joystick Events', '1.0', 'com.example.input-joystick-events');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Joystick]);

  FRenderer := TSdlRenderer.Create('Examples/Input/Joystick Polling', 640, 480, [], FWindow);

  FColors[0].Init(255, 255, 255);
  for var I := 1 to Length(FColors) - 1 do
    FColors[I].Init(Random(128) + 128, Random(128) + 128, Random(128) + 128);

  FMessagesTail := @FMessages;
  AddMessage(0, 'Please plug in a joystick.');

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Event(const AEvent: TSdlEvent): TSdlAppResult;
{ This method runs when a new event (mouse input, keypresses, etc) occurs. }
var
  Joystick: TSdlJoystick;
  Now: Int64;
begin
  case AEvent.Kind of
    TSdlEventKind.Quit:
      { End the program, reporting success to the OS }
      Exit(TSdlAppResult.Success);

    TSdlEventKind.JoystickAdded:
      begin
        { This event is sent for each hotplugged stick, but also each
          already-connected joystick during SdlInit. }
        Joystick := TSdlJoystick.Open(AEvent.JoyDevice.JoystickID);
        AddMessage(Joystick.ID, 'Joystick #%d ("%s") added',
          [Joystick.ID.ID, Joystick.Name]);
      end;

    TSdlEventKind.JoystickRemoved:
      begin
        Joystick := AEvent.JoyDevice.Joystick;
        if (Joystick <> nil) then
          Joystick.Close;

        AddMessage(AEvent.JoyDevice.JoystickID, 'Joystick #%d removed',
          [AEvent.JoyDevice.JoystickID.ID]);
      end;

    TSdlEventKind.JoystickAxisMotion:
      begin
        { These are spammy, only show every MOTION_EVENT_COOLDOWN milliseconds }
        Now := SdlGetTicks;
        if (Now >= FAxisMotionCooldownTime) then
        begin
          FAxisMotionCooldownTime := Now + MOTION_EVENT_COOLDOWN;
          AddMessage(AEvent.JoyAxis.JoystickID, 'Joystick #%d axis %d -> %d',
            [AEvent.JoyAxis.JoystickID.ID, AEvent.JoyAxis.Axis, AEvent.JoyAxis.Value]);
        end;
      end;

    TSdlEventKind.JoystickBallMotion:
      begin
        { These are spammy, only show every MOTION_EVENT_COOLDOWN milliseconds }
        Now := SdlGetTicks;
        if (Now >= FBallMotionCooldownTime) then
        begin
          FBallMotionCooldownTime := Now + MOTION_EVENT_COOLDOWN;
          AddMessage(AEvent.JoyBall.JoystickID, 'Joystick #%d ball %d -> %d, %d',
            [AEvent.JoyBall.JoystickID.ID, AEvent.JoyBall.Ball,
             AEvent.JoyBall.XRel, AEvent.JoyBall.YRel]);
        end;
      end;

    TSdlEventKind.JoystickHatMotion:
      begin
        AddMessage(AEvent.JoyHat.JoystickID, 'Joystick #%d hat %d -> %s',
          [AEvent.JoyHat.JoystickID.ID, AEvent.JoyHat.Hat,
           HatStateString(AEvent.JoyHat.Value)]);
      end;

    TSdlEventKind.JoystickButtonUp:
      begin
        AddMessage(AEvent.JoyButton.JoystickID, 'Joystick #%d button %d -> RELEASED',
          [AEvent.JoyButton.JoystickID.ID, AEvent.JoyButton.Button]);
      end;

    TSdlEventKind.JoystickButtonDown:
      begin
        AddMessage(AEvent.JoyButton.JoystickID, 'Joystick #%d button %d -> PRESSED',
          [AEvent.JoyButton.JoystickID.ID, AEvent.JoyButton.Button]);
      end;

    TSdlEventKind.JoystickBatteryUpdated:
      begin
        AddMessage(AEvent.JoyBattery.JoystickID, 'Joystick #%d battery %s -> %d%%',
          [AEvent.JoyBattery.JoystickID.ID,
           BatteryStateString(AEvent.JoyBattery.State), AEvent.JoyBattery.Percent]);
      end;
  end;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
const
  MSG_LIFETIME = 3500; { Mlliseconds a message lives for }
begin
  var Now := SdlGetTicks;
  var Msg := FMessages.Next;

  FRenderer.SetDrawColor(0, 0, 0);
  FRenderer.Clear;
  var WinSize := FWindow.Size;
  var PrevY: Single := 0;

  while Assigned(Msg) do
  begin
    var LifePercent: Single := (Now - Msg.StartTicks) / MSG_LIFETIME;
    if (LifePercent >= 1) then
    begin
      { Message is done. }
      FMessages.Next := Msg.Next;
      if (FMessagesTail = Msg) then
        FMessagesTail := @FMessages;

      Msg.Text := '';
      SdlFree(Msg);
      Msg := FMessages.Next;
      Continue;
    end;

    var X: Single := 0.5 * (WinSize.W - (Length(Msg.Text) * SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE));
    var Y: Single := WinSize.H * LifePercent;

    if (PrevY <> 0) and ((PrevY - Y) < SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE) then
    begin
      { Wait for the previous message to tick up a little. }
      Msg.StartTicks := Now;
      Break;
    end;

    Msg.Color.A := Trunc((1 - LifePercent) * 255);
    FRenderer.DrawColor := Msg.Color;
    FRenderer.DrawDebugText(X, Y, Msg.Text);

    PrevY := Y;
    Msg := Msg.Next;
  end;

  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
{ This method runs once at shutdown. }
begin
  var Msg := FMessages.Next;
  while Assigned(Msg) do
  begin
    var Next := Msg.Next;

    Msg.Text := '';
    SdlFree(Msg);

    Msg := Next;
  end;

  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
