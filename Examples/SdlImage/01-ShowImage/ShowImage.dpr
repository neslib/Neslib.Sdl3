program ShowImage;

{$R *.res}

uses
  System.Math,
  System.Types,
  System.Classes,
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Image.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Image,
  Neslib.Sdl3;

{ A test application for the SDL image loading library. }

{$R 'Resources.res'} { Contains tiger.svg image }

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTexture: TSdlTexture;
    FTargetRect: TSdlRectF;
  private
    procedure DrawBackground;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

procedure TApp.DrawBackground;
const
  COLORS: array [0..1] of TSdlColor = (
    (R: $66; G: $66; B: $66; A: $FF),
    (R: $99; G: $99; B: $99; A: $FF));
  DELTA = 8;
begin
  var MaxX := Trunc(FTargetRect.X + FTargetRect.W);
  var MaxY := Trunc(FTargetRect.Y + FTargetRect.H);

  var R: TSdlRectF;
  R.W := DELTA;
  R.H := DELTA;

  R.Y := FTargetRect.Y;
  var Y := Trunc(R.Y);
  while (Y < MaxY) do
  begin
    R.X := FTargetRect.X;
    var X := Trunc(R.X);
    while (X < MaxX) do
    begin
      { Create an 8x8 checkerboard pattern }
      var I := ((X xor Y) shr 3) and 1;
      FRenderer.DrawColor := COLORS[I];

      FRenderer.FillRect(R);

      R.X := R.X + DELTA;
      Inc(X, DELTA);
    end;
    R.Y := R.Y + DELTA;
    Inc(Y, DELTA);
  end;
end;

function TApp.Init: TSdlAppResult;
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example SdlImage ShowImage', '1.0', 'com.example.sdlimage-show-image');

  SdlInit([TSdlInitFlag.Video]);

  { Create maximized window and renderer }
  FRenderer := TSdlRenderer.Create('Examples/SdlImage/Show Image',
    0, 0, [TSdlWindowFlag.Resizable, TSdlWindowFlag.Maximized], FWindow);

  { Determine size of renderable area of the window, and calculate desired
    image size to fill it, limited by the maximum texture size supported by
    the GPU. }
  var Props := FRenderer.Properties;
  var MaxTextureSize := Props.AsNumber[TSdlProperty.RendererMaxTextureSize];
  var OutputSize := FRenderer.OutputSize;
  var TargetImageSize := Min(Min(OutputSize.W, OutputSize.H), MaxTextureSize);

  { Load "tiger.svg" from resource }
  var Data: TBytes;
  var Stream := TResourceStream.Create(HInstance, 'TIGER', RT_RCDATA);
  try
    SetLength(Data, Stream.Size);
    Stream.ReadBuffer(Data, Length(Data));
  finally
    Stream.Free;
  end;

  { Create TSdlIOStream from raw SVG data }
  var IOStream := TSdlIOStream.Create(Pointer(Data), Length(Data), True);
  try
    { Load SVG surface from stream, rasterizing it to the desired dimensions.
      By setting the desired Width or Height to 0, it is calculated
      automatically to preserve aspect ratio. }
    var Surface := TSdlImage.LoadSvg(IOStream, 0, TargetImageSize);
    try
      { Create texture from surface }
      FTexture := FRenderer.CreateTexture(Surface);
    finally
      Surface.Free;
    end;
  finally
    IOStream.Free;
  end;

  { Calculate target rect so it's centered on the screen }
  var TextureSize := FTexture.Size;
  FTargetRect.X := Trunc((OutputSize.W - TextureSize.W) / 2);
  FTargetRect.Y := Trunc((OutputSize.H - TextureSize.H) / 2);
  FTargetRect.W := TextureSize.W;
  FTargetRect.H := TextureSize.H;

  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
begin
  { Clear background. }
  FRenderer.SetDrawColorFloat(0, 0, 0);
  FRenderer.Clear;

  { Draw a background pattern to indicate transparency }
  DrawBackground;

  { Draw the texture }
  FRenderer.DrawTexture(FTexture, FTargetRect);

  { Put the newly-cleared rendering on the screen. }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FTexture.Free;
  FRenderer.Free;
  FWindow.Free;
end;

begin
  RunApp(TApp);
end.
