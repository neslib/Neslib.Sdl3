program Viewport;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3,
  Sample.Utils;

{ This example creates an SDL window and renderer, and then draws some
  textures to it every frame, adjusting the viewport. }

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

  SdlSetAppMetadata('Example Renderer Viewport', '1.0', 'com.example.renderer-viewport');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Viewport',
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
  var DstRect := SdlRectF(0, 0, FTextureWidth, FTextureHeight);

  { Setting a viewport has the effect of limiting the area that rendering
    can happen, and making coordinate (0, 0) live somewhere else in the
    window. It does _not_ scale rendering to fit the viewport.

    As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Draw once with the whole window as the viewport. }
  FRenderer.ResetViewport;
  FRenderer.DrawTexture(FTexture, DstRect);

  { Top right quarter of the window. }
  FRenderer.Viewport := SdlRect(
    WINDOW_WIDTH div 2, WINDOW_HEIGHT div 2,
    WINDOW_WIDTH div 2, WINDOW_HEIGHT div 2);
  FRenderer.DrawTexture(FTexture, DstRect);

  { Bottom 20% of the window. Note it clips the width! }
  FRenderer.Viewport := SdlRect(
    0, WINDOW_HEIGHT - (WINDOW_HEIGHT div 5),
    WINDOW_WIDTH div 5, WINDOW_HEIGHT div 5);
  FRenderer.DrawTexture(FTexture, DstRect);

  { What happens if you try to draw above the viewport? It should clip! }
  FRenderer.Viewport := SdlRect(100, 200, WINDOW_WIDTH, WINDOW_HEIGHT);
  DstRect.Y := DstRect.Y - 50;
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
