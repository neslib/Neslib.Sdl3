program RotatingTextures;

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

  SdlSetAppMetadata('Example Renderer Rotating Textures', '1.0', 'com.example.renderer-rotating-textures');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Rotating Textures',
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
    you can rotate it from a different point, too by using another version! }
  FRenderer.DrawTextureRotated(FTexture, DstRect, Rotation);

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
