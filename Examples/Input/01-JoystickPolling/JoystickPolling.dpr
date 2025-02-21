program JoystickPolling;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Input,
  Neslib.Sdl3.Events,
  Neslib.Sdl3;

{ This example code looks for the current joystick state once per frame,
  and draws a visual representation of it.

  Joysticks are low-level interfaces: there's something with a bunch of
  buttons, axes and hats, in no understood order or position. This is
  a flexible interface, but you'll need to build some sort of configuration
  UI to let people tell you what button, etc, does what. On top of this
  interface, SDL offers the "gamepad" API, which works with lots of devices,
  and knows how to map arbitrary buttons and such to look like an
  Xbox/PlayStation/etc gamepad. This is easier, and better, for many games,
  but isn't necessarily a good fit for complex apps and hardware. A flight
  simulator, a realistic racing game, etc, might want this interface instead
  of gamepads.

  SDL can handle multiple joysticks, but for simplicity, this program only
  deals with the first stick it sees. }

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FJoystick: TSdlJoystick;
    FColors: array [0..63] of TSdlColor;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    function Event(const AEvent: TSdlEvent): TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Input Joystick Polling', '1.0', 'com.example.input-joystick-polling');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Joystick]);

  FRenderer := TSdlRenderer.Create('Examples/Input/Joystick Polling', 640, 480, [], FWindow);

  for var I := 0 to Length(FColors) - 1 do
    FColors[I].Init(Random(192) + 64, Random(192) + 64, Random(192) + 64);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Event(const AEvent: TSdlEvent): TSdlAppResult;
{ This method runs when a new event (mouse input, keypresses, etc) occurs. }
begin
  if (AEvent.Kind = TSdlEventKind.Quit) then
    { End the program, reporting success to the OS }
    Exit(TSdlAppResult.Success);

  if (AEvent.Kind = TSdlEventKind.JoystickAdded) then
  begin
    { This event is sent for each hotplugged stick, but also each
      already-connected joystick during SdlInit. }
    if (FJoystick = nil) then
      FJoystick := TSdlJoystick.Open(AEvent.JoyDevice.JoystickID);
  end
  else if (AEvent.Kind = TSdlEventKind.JoystickRemoved) then
  begin
    if (FJoystick <> nil) and (FJoystick.ID = AEvent.JoyDevice.JoystickID) then
    begin
      { Our joystick was unplugged. }
      FJoystick.Close;
      FJoystick := nil;
    end;
  end;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
const
  SIZE       = 30;
  THIRD_SIZE = SIZE / 3;
var
  X, Y, Val, DX: Single;
  I: Integer;
  Dst: TSdlRectF;
  Cross: array [0..1] of TSdlRectF;
begin
  var Text := 'Plug in a joystick, please.';

  if (FJoystick <> nil) then
    { We have a stick opened. }
    Text := FJoystick.Name;

  FRenderer.SetDrawColor(0, 0, 0);
  FRenderer.Clear;
  var WinSize := FWindow.Size;

  { Note that you can get input as events, instead of polling, which is better
    since it won't miss button presses if the system is lagging, but often times
    checking the current state per-frame is good enough, and maybe better if
    you'd rather _drop_ inputs due to lag. }

  if (FJoystick <> nil) then
  begin
    { We have a stick opened.

      Draw axes as bars going across middle of screen. We don't know if it's an
      X or Y or whatever axis, so we can't do more than this. }
    var Total := FJoystick.NumAxes;
    Y := 0.5 * (WinSize.H - (Total * SIZE));
    X := 0.5 * WinSize.W;
    for I := 0 to Total - 1 do
    begin
      Val := FJoystick.Axis[I] / 32767; { Make it -1.0 to 1.0 }
      DX := X + (Val * X);
      Dst.Init(DX, Y, X - Abs(DX), SIZE);
      FRenderer.DrawColor := FColors[I mod Length(FColors)];
      FRenderer.FillRect(Dst);
      Y := Y + SIZE;
    end;

    { Draw buttons as blocks across top of window. We only know the button
      numbers, but not where they are on the device. }
    Total := FJoystick.NumButtons;
    X := 0.5 * (WinSize.W - (Total * SIZE));
    for I := 0 to Total - 1 do
    begin
      Dst.Init(X, 0, SIZE, SIZE);

      if (FJoystick.Button[I]) then
        FRenderer.DrawColor := FColors[I mod Length(FColors)]
      else
        FRenderer.SetDrawColor(0, 0, 0);

      FRenderer.FillRect(Dst);
      FRenderer.SetDrawColor(255, 255, 255);
      FRenderer.DrawRect(Dst); { Outline it }
      X := X + SIZE;
    end;

    { Draw hats across the bottom of the screen. }
    Total := FJoystick.NumHats;
    X := (0.5 * (WinSize.W - (Total * SIZE * 2))) + (0.5 * SIZE);
    Y := WinSize.H - SIZE;
    for I := 0 to Total - 1 do
    begin
      Cross[0].Init(X, Y + THIRD_SIZE, SIZE, THIRD_SIZE);
      Cross[1].Init(X + THIRD_SIZE, Y, THIRD_SIZE, SIZE);
      var Hats := FJoystick.Hats[I];

      FRenderer.SetDrawColor(90, 90, 90);
      FRenderer.FillRects(Cross);

      FRenderer.DrawColor := FColors[I mod Length(FColors)];

      if (TSdlHat.Up in Hats) then
      begin
        Dst.Init(X + THIRD_SIZE, Y, THIRD_SIZE, THIRD_SIZE);
        FRenderer.FillRect(Dst);
      end;

      if (TSdlHat.Right in Hats) then
      begin
        Dst.Init(X + (THIRD_SIZE * 2), Y + THIRD_SIZE, THIRD_SIZE, THIRD_SIZE);
        FRenderer.FillRect(Dst);
      end;

      if (TSdlHat.Down in Hats) then
      begin
        Dst.Init(X + THIRD_SIZE, Y + (THIRD_SIZE * 2), THIRD_SIZE, THIRD_SIZE);
        FRenderer.FillRect(Dst);
      end;

      if (TSdlHat.Left in Hats) then
      begin
        Dst.Init(X, Y + THIRD_SIZE, THIRD_SIZE, THIRD_SIZE);
        FRenderer.FillRect(Dst);
      end;

      X := X + (SIZE * 2);
    end;
  end;

  X := 0.5 * (WinSize.W - (Length(Text) * SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE));
  Y := 0.5 * (WinSize.H - SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE);
  FRenderer.SetDrawColor(255, 255, 255);
  FRenderer.DrawDebugText(X, Y, Text);
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
{ This method runs once at shutdown. }
begin
  if (FJoystick <> nil) then
    FJoystick.Close;

  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
