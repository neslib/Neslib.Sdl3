program StreamingTextures;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

const
  WINDOW_WIDTH  = 640;
  WINDOW_HEIGHT = 480;
  TEXTURE_SIZE  = 150;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTexture: TSdlTexture;
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

  SdlSetAppMetadata('Example Renderer Streaming Textures', '1.0', 'com.example.renderer-streaming-textures');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Streaming Textures',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  FTexture := FRenderer.CreateTexture(TSdlPixelFormat.Rgba8888,
    TSdlTextureAccess.Streaming, TEXTURE_SIZE, TEXTURE_SIZE);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  var Now := SdlGetTicks;

  { We'll have some color move around over a few seconds. }
  var Direction: Single;
  if ((Now mod 2000) >= 1000) then
    Direction := 1
  else
    Direction := -1;

  var Scale: Single := (((Now mod 1000) - 500) / 500) * Direction;

  { To update a streaming texture, you need to lock it first. This gets you
    access to the pixels.
    Note that this is considered a _write-only_ operation: the buffer you get
    from locking might not acutally have the existing contents of the texture,
    and you have to write to every locked pixel!

    You can use TSdlTexture.Lock to get an array of raw pixels, but we're going
    to use TSdlTexture.LockToSurface here, because it wraps that array in a
    temporary TSdlSurface, letting us use the surface drawing functions instead
    of lighting up individual pixels. }
  var Surface := FTexture.LockToSurface;
  try
    { Make the whole surface black }
    Surface.Fill(Surface.Format.Details.MapRgb(0, 0, 0));

    var R: TSdlRect;
    R.W := TEXTURE_SIZE;
    R.H := TEXTURE_SIZE div 10;
    R.X := 0;
    R.Y := Trunc((TEXTURE_SIZE - R.H) * ((Scale + 1) / 2));
    Surface.FillRect(R, Surface.Format.Details.MapRgb(0, 255, 0));
  finally
    FTexture.Unlock;
  end;

  { As you can see from this, rendering draws over whatever was drawn before it.
    Grey, full alpha. }
  FRenderer.SetDrawColor(66, 66, 66);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Just draw the static texture a few times. You can think of it like a
    stamp, there isn't a limit to the number of times you can draw with it.

    Center this one. It'll draw the latest version of the texture we drew while
    it was locked. }
  var DstRect := SdlRectF(
    (WINDOW_WIDTH - TEXTURE_SIZE) / 2, (WINDOW_HEIGHT - TEXTURE_SIZE) / 2,
    TEXTURE_SIZE, TEXTURE_SIZE);
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
