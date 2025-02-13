program LoadBitmaps;

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Additional,
  Neslib.Sdl3.Video,
  Neslib.Sdl3,
  Sample.Utils;

const
  TOTAL_TEXTURES = 4;

const
  BITMAPS: array [0..TOTAL_TEXTURES - 1] of String = (
    'sample.bmp', 'gamepad_front.bmp', 'speaker.bmp', 'icon2x.bmp');

const
  TEXTURE_RECTS: array [0..TOTAL_TEXTURES - 1] of TSdlRectF = (
    (X: 116; Y: 156; W: 408; H: 167),
    (X:  20; Y: 200; W:  96; H:  60),
    (X: 525; Y: 180; W:  96; H:  96),
    (X: 288; Y: 375; W:  64; H:  64));

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTextures: array [0..TOTAL_TEXTURES - 1] of TSdlTexture;
    FQueue: TSdlAsyncIOQueue;
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

  SdlSetAppMetadata('Example AsyncIO Load Bitmap', '1.0', 'com.example.asyncio-load-bitmaps');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/ASyncIO/Load Bitmaps',
    640, 480, [], FWindow);

  FQueue := TSdlAsyncIOQueue.Create;

  { Load some .bmp files asynchronously from the Resources directory,
    put them in the same queue.

    NOTE: We only do this on Windows for this example for easier deployment }
  {$IFDEF MSWINDOWS}
  var Directory := TPath.GetDirectoryName(ParamStr(0));
  Directory := TPath.GetDirectoryName(Directory);
  Directory := TPath.Combine(Directory, 'Resources');

  for var I := 0 to TOTAL_TEXTURES - 1 do
  begin
    var Filename := TPath.Combine(Directory, BITMAPS[I]);

    { Attach index as app-specific data, so we can see it later. }
    SdlLoadAsync(Filename, FQueue, Pointer(I));
  end;
  {$ENDIF}

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  var Outcome: TSdlAsyncIOOutcome;
  if (FQueue.GetResult(Outcome)) then
  begin
    { A .bmp file load has finished. }
    if (Outcome.Result = TSdlAsyncIOResult.Complete) then
    begin
      { This might be _any_ of the bitmaps;
        they might finish loading in any order. }
      var I := IntPtr(Outcome.UserData);

      if (I >= 0) and (I < TOTAL_TEXTURES) then
      begin
        var Stream := TSdlIOStream.Create(Outcome.Buffer, Outcome.BytesTransferred);
        var Surface := TSdlSurface.LoadBmp(Stream, True);
        try
          { The renderer is not multithreaded, so create the texture here once
            the data loads. }
          FTextures[I] := FRenderer.CreateTexture(Surface);
        finally
          Surface.Free;
        end;
      end;
    end;
    SdlFree(Outcome.Buffer);
  end;

  FRenderer.SetDrawColor(0, 0, 0);
  FRenderer.Clear;

  for var I := 0 to TOTAL_TEXTURES - 1 do
  begin
    var Texture := FTextures[I];
    if (Texture <> nil) then
      FRenderer.DrawTexture(Texture, TEXTURE_RECTS[I]);
  end;

  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FQueue.Free;
  for var I := 0 to TOTAL_TEXTURES - 1 do
    FTextures[I].Free;

  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
