program Rectangles;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

{ This example creates an SDL window and renderer, and then draws some
  rectangles to it every frame. }

const
  WINDOW_WIDTH  = 640;
  WINDOW_HEIGHT = 480;

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

  SdlSetAppMetadata('Example Renderer Rectangles', '1.0', 'com.example.renderer-rectangles');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Rectangles',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
var
  CenterRects: array [0..2] of TSdlRectF;
  Rects: array [0..15] of TSdlRectF;
const
  W = WINDOW_WIDTH / Length(Rects);
begin
  var Now := SdlGetTicks;

  { We'll have the rectangles grow and shrink over a few seconds. }
  var Direction: Single;
  if ((Now mod 2000) >= 1000) then
    Direction := 1
  else
    Direction := -1;

  var Scale: Single := (((Now mod 1000) - 500) / 500) * Direction;

  { As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Rectangles are comprised of set of X and Y coordinates, plus width and
    height. (0, 0) is the top left of the window, and larger numbers go
    down and to the right. This isn't how geometry works, but this is
    pretty standard in 2D graphics.

    Let's draw a single rectangle (square, really). }
  Rects[0].Init(100, 100, 100 + (100 * Scale), 100 + (100 * Scale));

  { Red, full alpha. }
  FRenderer.SetDrawColor(255, 0, 0);
  FRenderer.DrawRect(Rects[0]);

  { Now let's draw several rectangles with one function call. }
  for var I := 0 to Length(CenterRects) - 1 do
  begin
    var Size: Single := (I + 1) * 50;
    CenterRects[I].W := Size + (Size * Scale);
    CenterRects[I].H := CenterRects[I].W;

    { Center it }
    CenterRects[I].X := (WINDOW_WIDTH - CenterRects[I].W) / 2;
    CenterRects[I].Y := (WINDOW_HEIGHT - CenterRects[I].H) / 2;
  end;

  { Green, full alpha. }
  FRenderer.SetDrawColor(0, 255, 0);

  { Draw three rectangles at once }
  FRenderer.DrawRects(CenterRects);

  { Those were rectangle _outlines_, really.
    You can also draw _filled_ rectangles! }
  Rects[0].Init(400, 50, 100 + (100 * Scale), 50 + (50 * Scale));

  { Blue, full alpha. }
  FRenderer.SetDrawColor(0, 0, 255);
  FRenderer.FillRect(Rects[0]);

  { ...and also fill a bunch of rectangles at once... }
  for var I := 0 to Length(Rects) - 1 do
  begin
    var H: Single := I * 8;
    Rects[I].Init(I * W, WINDOW_HEIGHT - H, W, H);
  end;

  { White, full alpha. }
  FRenderer.SetDrawColor(255, 255, 255);
  FRenderer.FillRects(Rects);

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

begin
  RunApp(TApp);
end.
