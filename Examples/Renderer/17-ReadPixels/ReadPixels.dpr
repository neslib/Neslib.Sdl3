program ReadPixels;

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
  WINDOW_WIDTH  = 640;
  WINDOW_HEIGHT = 480;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTexture: TSdlTexture;
    FTextureWidth: Integer;
    FTextureHeight: Integer;
    FConvertedTexture: TSdlTexture;
    FConvertedTextureWidth: Integer;
    FConvertedTextureHeight: Integer;
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

  SdlSetAppMetadata('Example Renderer Read Pixels', '1.0', 'com.example.renderer-read-pixels');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Read Pixels',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  { Textures are pixel data that we upload to the video hardware for fast drawing.
    Lots of 2D engines refer to these as "sprites." We'll do a static texture
    (upload once, draw many times) with data from a bitmap file.

    TSdlSurface is pixel data the CPU can access. TSdlTexture is pixel data the
    GPU can access. Load a .bmp into a surface, move it to a texture from there. }
  var Surface := LoadBitmap('SAMPLE_BMP');
  try
    FTextureWidth := Surface.W;
    FTextureHeight := Surface.H;
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
  var Now := SdlGetTicks;

  { We'll have a texture rotate around over 2 seconds (2000 milliseconds).
    360 degrees in a circle! }
  var Rotation: Single := ((Now mod 2000) / 2000) * 360;

  { As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Center this one, and draw it with some rotation so it spins! }
  var DstRect := SdlRectF(
    (WINDOW_WIDTH - FTextureWidth) / 2, (WINDOW_HEIGHT - FTextureHeight) / 2,
    FTextureWidth, FTextureHeight);

  { Rotate it around the center of the texture;
    you can rotate it from a different point, too! }
  var Center := SdlPointF(FTextureWidth / 2, FTextureHeight / 2);
  FRenderer.DrawTextureRotated(FTexture, DstRect, Rotation, Center);

  { This next whole thing is _super_ expensive.
    Seriously, don't do this in real life.

    Download the pixels of what has just been rendered. This has to wait for the
    GPU to finish rendering it and everything before it, and then make an
    expensive copy from the GPU to system RAM! }
  var Surface := FRenderer.ReadPixels;
  try
    { This is also expensive, but easier: convert the pixels to a format we want. }
    if (Surface.Format <> TSdlPixelFormat.Rgba8888) and (Surface.Format <> TSdlPixelFormat.Bgra8888) then
    begin
      var Converted := Surface.Convert(TSdlPixelFormat.Rgba8888);
      Surface.Free;
      Surface := Converted;
    end;

    { Rebuild FConvertedTexture if the dimensions have changed (window resized, etc). }
    if (Surface.W <> FConvertedTextureWidth) or (Surface.H <> FConvertedTextureHeight) then
    begin
      FConvertedTexture.Free;
      FConvertedTexture := FRenderer.CreateTexture(TSdlPixelFormat.Rgba8888,
        TSdlTextureAccess.Streaming, Surface.W, Surface.H);
      FConvertedTextureWidth := Surface.W;
      FConvertedTextureHeight := Surface.H;
    end;

    { Turn each pixel into either black or white. This is a lousy technique but
      it works here.
      In real life, something like Floyd-Steinberg dithering might work
      better: https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering }
    for var Y :=  0 to Surface.H - 1 do
    begin
      var P := PByte(Surface.Pixels) + (Y * Surface.Pitch);
      for var X := 0 to Surface.W - 1 do
      begin
        var Average: Cardinal := (P[1] + P[2] + P[3]) div 3;
        if (Average = 0) then
        begin
          { Make pure black pixels red }
          P[0] := $FF;
          P[1] := $00;
          P[2] := $00;
        end
        else if (Average > 50) then
        begin
          { White }
          P[0] := $FF;
          P[1] := $FF;
          P[2] := $FF;
        end
        else
        begin
          { Black }
          P[0] := $00;
          P[1] := $00;
          P[2] := $00;
        end;
        P[3] := $FF;

        Inc(P, 4);
      end;
    end;

    { Upload the processed pixels back into a texture. }
    FConvertedTexture.Update(Surface.Pixels, Surface.Pitch);
  finally
    Surface.Free;
  end;

  { Draw the texture to the top-left of the screen. }
  DstRect := SdlRectF(0, 0, WINDOW_WIDTH / 4, WINDOW_HEIGHT / 4);
  FRenderer.DrawTexture(FConvertedTexture, DstRect);

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FConvertedTexture.Free;
  FTexture.Free;
  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
