program SimplePlayback;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Audio,
  Neslib.Sdl3;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FStream: TSdlAudioStream;
    FCurrentSineSample: Integer;
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

  SdlSetAppMetadata('Example Audio Simple Playback', '1.0', 'com.example.audio-simple-playback');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Audio]);

  FRenderer := TSdlRenderer.Create('Examples/Audio/Simple Playback', 640, 480, [], FWindow);

  { We're just playing a single thing here, so we'll use the simplified option.
    We are always going to feed audio in as mono, float32 data at 8000Hz.
    The stream will convert it to whatever the hardware wants on the other side. }
  var Spec := TSdlAudioSpec.Create(TSdlAudioFormat.F32, 1, 8000);
  FStream := TSdlAudioStream.Create(TSdlAudioDeviceID.DefaultPlaybackDevice, @Spec);

  { The stream starts the device paused. You have to tell it to start! }
  FStream.Resume;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
const
  { 8000 float samples per second. Half of that }
  MINIMUM_AUDIO = (8000 * SizeOf(Single)) div 2;
  FREQ = 440;
var
  { This will feed 512 samples each frame until we get to our maximum. }
  Samples: array [0..511] of Single;
begin
  { See if we need to feed the audio stream more data yet.
    We're being lazy here, but if there's less than half a second queued,
    generate more. A sine wave is unchanging audio--easy to stream--but for
    video games, you'll want to generate significantly _less_ audio ahead of
    time! }
  if (FStream.Available < MINIMUM_AUDIO) then
  begin
    { Generate a 440Hz pure tone }
    for var I := 0 to Length(Samples) - 1 do
    begin
      var Phase: Single := (FCurrentSineSample * FREQ) / 8000;
      Samples[I] := Sin(Phase * 2 * PI);
      Inc(FCurrentSineSample);
    end;

    { Wrapping around to avoid floating-point errors }
    FCurrentSineSample := FCurrentSineSample mod 8000;

    { Feed the new data to the stream. It will queue at the end, and trickle out
      as the hardware needs more data. }
    FStream.PutData(@Samples, SizeOf(Samples));
  end;

  { We're not doing anything with the renderer, so just blank it out. }
  FRenderer.Clear;
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  { SDL will clean up the window/renderer for us. }
  FStream.Free;
end;

begin
  RunApp(TApp);
end.
