program SimplePlaybackCallback;

{$R *.res}

uses
  System.Math,
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
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

var
  CurrentSineSample: Integer = 0;

procedure FeedTheAudioStreamMore(AUserData: Pointer; AStream: TSdlAudioStream;
  AAdditionalAmount, ATotalAmount: Integer); cdecl;
{ This routine will be called (usually in a background thread) when the audio
  stream is consuming data. }
const
  FREQ = 440;
var
  { This will feed 128 samples each iteration until we have enough. }
  Samples: array [0..127] of Single;
begin
  { ATotalAmount is how much data the audio stream is eating right now,
    AAdditionalAmount is how much more it needs than what it currently has
    queued (which might be zero!). You can supply any amount of data here; it
    will take what it needs and use the extra later. If you don't give it
    enough, it will take everything and then feed silence to the hardware for
    the rest. Ideally, though, we always give it what it needs and no extra, so
    we aren't buffering more than necessary.

    Convert from bytes to samples }
  AAdditionalAmount := AAdditionalAmount div SizeOf(Single);
  while (AAdditionalAmount > 0) do
  begin
    var Total := Min(AAdditionalAmount, Length(Samples));

    { Generate a 440Hz pure tone }
    for var I := 0 to Total - 1 do
    begin
      var Phase: Single := (CurrentSineSample * FREQ) / 8000;
      Samples[I] := Sin(Phase * 2 * Pi);
      Inc(CurrentSineSample);
    end;

    { Wrapping around to avoid floating-point errors }
    CurrentSineSample := CurrentSineSample mod 8000;

    { Feed the new data to the stream. It will queue at the end, and trickle out
      as the hardware needs more data. }
    AStream.PutData(@Samples, Total * SizeOf(Single));
    Dec(AAdditionalAmount, Total);
  end;
end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Audio Simple Playback Callback', '1.0', 'com.example.audio-simple-playback-callback');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Audio]);

  FRenderer := TSdlRenderer.Create('Examples/Audio/Simple Playback Callback', 640, 480, [], FWindow);

  { We're just playing a single thing here, so we'll use the simplified option.
    We are always going to feed audio in as mono, float32 data at 8000Hz.
    The stream will convert it to whatever the hardware wants on the other side. }
  var Spec := TSdlAudioSpec.Create(TSdlAudioFormat.F32, 1, 8000);
  FStream := TSdlAudioStream.Create(TSdlAudioDeviceID.DefaultPlaybackDevice,
    @Spec, FeedTheAudioStreamMore);

  { The stream starts the device paused. You have to tell it to start! }
  FStream.Resume;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
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
