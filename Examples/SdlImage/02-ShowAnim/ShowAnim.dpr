program ShowAnim;

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
  Neslib.Sdl3.Time,
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
    FTextures: TArray<TSdlTexture>;
    FDelays: TArray<Integer>;
    FTargetRect: TSdlRectF;
    FCurrentFrameIndex: Integer;
    FNextTicks: Int64;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example SdlImage ShowAnim', '1.0', 'com.example.sdlimage-show-anim');

  SdlInit([TSdlInitFlag.Video]);

  { Create maximized window and renderer }
  FRenderer := TSdlRenderer.Create('Examples/SdlImage/Show Anim',
    0, 0, [TSdlWindowFlag.Resizable, TSdlWindowFlag.Maximized], FWindow);

  { Determine size of renderable area of the window. }
  var OutputSize := FRenderer.OutputSize;

  { Load animated GIF from resource }
  var Data: TBytes;
  var Stream := TResourceStream.Create(HInstance, 'TEST', RT_RCDATA);
  try
    SetLength(Data, Stream.Size);
    Stream.ReadBuffer(Data, Length(Data));
  finally
    Stream.Free;
  end;

  { Create TSdlIOStream from raw GIF data }
  var IOStream := TSdlIOStream.Create(Pointer(Data), Length(Data), True);
  var Anim := TSdlAnimatedImage.Create(IOStream, True);
  try
    { Calculate target rect so the animation is centered on the screen }
    var Scale := FWindow.Display.ContentScale;
    var W: Single := Anim.Width * Scale;
    var H: Single := Anim.Height * Scale;
    FTargetRect.X := Trunc((OutputSize.W - W) / 2);
    FTargetRect.Y := Trunc((OutputSize.H - H) / 2);
    FTargetRect.W := W;
    FTargetRect.H := H;

    { Convert animation frames to textures }
    SetLength(FTextures, Anim.FrameCount);
    SetLength(FDelays, Anim.FrameCount);
    for var I := 0 to Anim.FrameCount - 1 do
    begin
      FTextures[I] := FRenderer.CreateTexture(Anim.Frames[I]);
      FDelays[I] := Anim.Delays[I];
      if (FDelays[I] = 0) then
        FDelays[I] := 100;
    end;
  finally
    Anim.Free;
  end;

  FNextTicks := SdlGetTicks + FDelays[0];
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
begin
  { Clear background. }
  FRenderer.SetDrawColorFloat(0, 0, 0);
  FRenderer.Clear;

  { Draw the current frame }
  FRenderer.DrawTexture(FTextures[FCurrentFrameIndex], FTargetRect);

  { Advance frame if needed }
  if (SdlGetTicks >= FNextTicks) then
  begin
    Inc(FCurrentFrameIndex);
    if (FCurrentFrameIndex = Length(FTextures)) then
      FCurrentFrameIndex := 0;

    Inc(FNextTicks, FDelays[FCurrentFrameIndex]);
  end;
  { Put the newly-cleared rendering on the screen. }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  for var Texture in FTextures do
    Texture.Free;
  FRenderer.Free;
  FWindow.Free;
end;

begin
  RunApp(TApp);
end.
