program ColorMods;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3,
  Sample.Utils;

{ This example creates an SDL window and renderer, and then draws some
  textures to it every frame, adjusting their color. }

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

  SdlSetAppMetadata('Example Renderer Color Mods', '1.0', 'com.example.renderer-color-mods');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Color Mods',
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
  { Convert from milliseconds to seconds. }
  var Now := SdlGetTicks / 1000;

  { Choose the modulation values for the center texture.
    The sine wave trick makes it fade between colors smoothly. }
  var ColorMod := SdlColorF(
    0.5 + (0.5 * Sin(Now)),
    0.5 + (0.5 * Sin(Now + (Pi * 2 / 3))),
    0.5 + (0.5 * Sin(Now + (Pi * 4 / 3))));

  { As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Just draw the static texture a few times. You can think of it like a
    stamp, there isn't a limit to the number of times you can draw with it.

    Color modulation multiplies each pixel's red, green, and blue intensities by
    the mod values, so multiplying by 1.0 will leave a color intensity alone,
    0.0 will shut off that color completely, etc.

    Top left; let's make this one blue! }
  var DstRect := SdlRectF(0, 0, FTextureWidth, FTextureHeight);

  { Kill all red and green }
  FTexture.ColorModFloat := SdlColorF(0, 0, 1);
  FRenderer.DrawTexture(FTexture, DstRect);

  { Center this one, and have it cycle through red/green/blue modulations. }
  DstRect.X := (WINDOW_WIDTH - FTextureWidth) / 2;
  DstRect.Y := (WINDOW_HEIGHT - FTextureHeight) / 2;
  FTexture.ColorModFloat := ColorMod;
  FRenderer.DrawTexture(FTexture, DstRect);

  { Bottom right; let's make this one red! }
  DstRect.X := WINDOW_WIDTH - FTextureWidth;
  DstRect.Y := WINDOW_HEIGHT - FTextureHeight;

  { Kill all green and blue }
  FTexture.ColorModFloat := SdlColorF(1, 0, 0);
  FRenderer.DrawTexture(FTexture, DstRect);

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
