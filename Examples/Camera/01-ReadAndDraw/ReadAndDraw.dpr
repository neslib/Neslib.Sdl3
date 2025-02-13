program ReadAndDraw;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Events,
  Neslib.Sdl3;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FCamera: TSdlCamera;
    FTexture: TSdlTexture;
  protected
    function Init: TSdlAppResult; override;
    function Event(const AEvent: TSdlEvent): TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Camera Read and Draw', '1.0', 'com.example.camera-read-and-draw');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Camera]);

  FRenderer := TSdlRenderer.Create('Examples/Camera/Read and Draw', 640, 480, [], FWindow);

  var Devices := TSdlCameraID.Cameras;
  if (Devices = nil) then
  begin
    TSdlLog.Info('Couldn''t find any camera devices! Please connect a camera and try again.');
    Exit(TSdlAppResult.Failure);
  end
  else
    FCamera := TSdlCamera.Open(Devices[0]);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Event(const AEvent: TSdlEvent): TSdlAppResult;
{ This method runs when a new event (mouse input, keypresses, etc) occurs. }
begin
  case AEvent.Kind of
    TSdlEventKind.Quit:
      { End the program, reporting success to the OS. }
      Exit(TSdlAppResult.Success);

    TSdlEventKind.CameraDeviceDenied:
      begin
        TSdlLog.Info('Camera use denied by user!');
        Exit(TSdlAppResult.Failure);
      end;
  end;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  var TimestampNS: UInt64 := 0;
  var Frame := FCamera.AcquireFrame(TimestampNS);

  if (Frame <> nil) then
  try
    { Some platforms don't know _what_ the camera offers until the user gives
      permission, so we build the texture and resize the window when we get a
      first frame from the camera. }
    if (FTexture = nil) then
    begin
      { Resize the window to match }
      FWindow.SetSize(Frame.W, Frame.H);
      FTexture := FRenderer.CreateTexture(Frame.Format,
        TSdlTextureAccess.Streaming, Frame.W, Frame.H);
    end;

    FTexture.Update(Frame.Pixels, Frame.Pitch);
  finally
    FCamera.ReleaseFrame(Frame);
  end;

  FRenderer.SetDrawColor($99, $99, $99);
  FRenderer.Clear;

  { Draw the latest camera frame, if available. }
  if (FTexture <> nil) then
    FRenderer.DrawTexture(FTexture, SdlRectF(0, 0, FTexture.W, FTexture.H));

  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FTexture.Free;
  FCamera.Close;
  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
