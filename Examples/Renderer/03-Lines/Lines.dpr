program Lines;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

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

  SdlSetAppMetadata('Example Renderer Lines', '1.0', 'com.example.renderer-lines');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Lines', 640, 480, [], FWindow);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
const
  { Lines (line segments, really) are drawn in terms of points: a set of X and Y
    coordinates, one set for each end of the line.
    (0, 0) is the top left of the window, and larger numbers go down and to the
    right. This isn't how geometry works, but this is pretty standard in 2D graphics. }
  LINE_POINTS: array [0..8] of TSdlPointF = (
    (X: 100; Y: 354), (X: 220; Y: 230), (X: 140; Y: 230), (X: 320; Y: 100),
    (X: 500; Y: 230), (X: 420; Y: 230), (X: 540; Y: 354), (X: 400; Y: 354),
    (X: 100; Y: 354));
const
  SIZE = 30;
  X    = 320;
  Y    = 95 - (SIZE div 2);
begin
  { As you can see from this, rendering draws over whatever was drawn before it.
    Grey, full alpha. }
  FRenderer.SetDrawColor(100, 100, 100);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { You can draw lines, one at a time, like these brown ones... }
  FRenderer.SetDrawColor(127, 49, 32);
  FRenderer.DrawLine(240, 450, 400, 450);
  FRenderer.DrawLine(240, 356, 400, 356);
  FRenderer.DrawLine(240, 356, 240, 450);
  FRenderer.DrawLine(400, 356, 400, 450);

  { You can also draw a series of connected lines in a single batch... }
  FRenderer.SetDrawColor(0, 255, 0);
  FRenderer.DrawLines(LINE_POINTS);

  { Here's a bunch of lines drawn out from a center point in a circle.
    We randomize the color of each line, so it functions as animation. }
  for var I := 0 to 359 do
  begin
    FRenderer.SetDrawColor(Random(256), Random(256), Random(256));
    FRenderer.DrawLine(X, Y, X + Sin(I) * SIZE, Y + Cos(I) * SIZE);
  end;

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

begin
  RunApp(TApp);
end.
