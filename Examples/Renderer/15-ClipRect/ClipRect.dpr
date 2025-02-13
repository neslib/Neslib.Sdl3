program ClipRect;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3,
  Sample.Utils;

const
  WINDOW_WIDTH   = 640;
  WINDOW_HEIGHT  = 480;
  CLIPRECT_SIZE  = 250;
  CLIPRECT_SPEED = 200; // Pixels per second

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTexture: TSdlTexture;
    FClipRectPosition: TSdlPointF;
    FClipRectDirection: TSdlPointF;
    FLastTime: Int64;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Renderer Clipping Rectangle', '1.0', 'com.example.renderer-cliprect');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/ClipRect',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  FClipRectDirection.Init(1, 1);
  FLastTime := SdlGetTicks;

  { Textures are pixel data that we upload to the video hardware for fast drawing.
    Lots of 2D engines refer to these as "sprites." We'll do a static texture
    (upload once, draw many times) with data from a bitmap file.

    TSdlSurface is pixel data the CPU can access. TSdlTexture is pixel data the
    GPU can access. Load a .bmp into a surface, move it to a texture from there. }
  var Surface := LoadBitmap('SAMPLE_BMP');
  try
    FTexture := FRenderer.CreateTexture(Surface);
  finally
    { Done with this, the texture has a copy of the pixels now. }
    Surface.Free;
  end;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  FRenderer.ClipRect := SdlRect(
    Round(FClipRectPosition.X), Round(FClipRectPosition.Y),
    CLIPRECT_SIZE, CLIPRECT_SIZE);

  var Now := SdlGetTicks;

  { Seconds since last iteration }
  var Elapsed: Single := (Now - FLastTime) / 1000;
  var Distance: Single := Elapsed * CLIPRECT_SPEED;

  { Set a new clipping rectangle position }
  FClipRectPosition.X := FClipRectPosition.X + (Distance * FClipRectDirection.X);
  if (FClipRectPosition.X < 0) then
  begin
    FClipRectPosition.X := 0;
    FClipRectDirection.X := 1;
  end
  else if (FClipRectPosition.X >= (WINDOW_WIDTH - CLIPRECT_SIZE)) then
  begin
    FClipRectPosition.X := (WINDOW_WIDTH - CLIPRECT_SIZE) - 1;
    FClipRectDirection.X := -1;
  end;

  FClipRectPosition.Y := FClipRectPosition.Y + (Distance * FClipRectDirection.Y);
  if (FClipRectPosition.Y < 0) then
  begin
    FClipRectPosition.Y := 0;
    FClipRectDirection.Y := 1;
  end
  else if (FClipRectPosition.Y >= (WINDOW_HEIGHT - CLIPRECT_SIZE)) then
  begin
    FClipRectPosition.Y := (WINDOW_HEIGHT - CLIPRECT_SIZE) - 1;
    FClipRectDirection.Y := -1;
  end;

  FLastTime := Now;

  { Okay, now draw!

    Note that TSdlRenderer.Clear is _not_ affected by the clipping rectangle!
    Grey, full alpha }
  FRenderer.SetDrawColor(33, 33, 33);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Stretch the texture across the entire window. Only the piece in the
    clipping rectangle will actually render, though! }
  FRenderer.DrawTexture(FTexture, SdlRectF(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT));

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FTexture.Free;
  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
