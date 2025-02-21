program Clear;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

{ This example code creates an SDL window and renderer, and then clears the
  window to a different color every frame, so you'll effectively get a window
  that's smoothly fading between colors. }

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Renderer Clear', '1.0', 'com.example.renderer-clear');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Clear', 640, 480, [], FWindow);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  { Convert from milliseconds to seconds. }
  var Now: Double := SdlGetTicks / 1000;

  { Choose the color for the frame we will draw.
    The sine wave trick makes it fade between colors smoothly. }
  var Red: Single := 0.5 + 0.5 * Sin(Now);
  var Green: Single := 0.5 + 0.5 * Sin(Now + PI * 2 / 3);
  var Blue: Single := 0.5 + 0.5 * Sin(Now + PI * 4 / 3);

  { New color, full alpha. }
  FRenderer.SetDrawColorFloat(Red, Green, Blue);

  { Clear the window to the draw color.  }
  FRenderer.Clear;

  { Put the newly-cleared rendering on the screen. }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

begin
  RunApp(TApp);
end.
