program LoadWav;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Audio,
  Neslib.Sdl3,
  Sample.Utils;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FStream: TSdlAudioStream;
    FWavData: TSdlAudioBuffer;
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

  SdlSetAppMetadata('Example Audio Load Wave', '1.0', 'com.example.audio-load-wav');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Audio]);

  FRenderer := TSdlRenderer.Create('Examples/Audio/Load Wav', 640, 480, [], FWindow);

  { Load the .wav file from a resource }
  FWavData := LoadAudioBuffer('SAMPLE_WAV');

  { Create our audio stream in the same format as the .wav file. It'll convert
    to what the audio hardware wants. }
  var Spec := FWavData.Spec;
  FStream := TSdlAudioStream.Create(TSdlAudioDeviceID.DefaultPlaybackDevice,
    @Spec);

  { The stream starts the device paused. You have to tell it to start! }
  FStream.Resume;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  { See if we need to feed the audio stream more data yet.
    We're being lazy here, but if there's less than the entire wav file left to
    play, just shove a whole copy of it into the queue, so we always have _tons_
    of data queued for playback. }
  if (FStream.Available < FWavData.Size) then
    { Feed more data to the stream. It will queue at the end, and trickle out as
      the hardware needs more data. }
    FStream.PutData(FWavData.Buffer, FWavData.Size);

  { We're not doing anything with the renderer, so just blank it out. }
  FRenderer.Clear;
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  { SDL will clean up the window/renderer for us. }
  FWavData.Free;
  FStream.Free;
end;

begin
  RunApp(TApp);
end.
