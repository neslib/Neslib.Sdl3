program MultipleStreams;

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
    FAudioDevice: TSdlAudioDevice;
    FSounds: array [0..1] of TSdlAudioBuffer;
    FStreams: array [0..1] of TSdlAudioStream;
  private
    procedure InitSound(const AIndex: Integer; const AResourceName: String);
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

  SdlSetAppMetadata('Example Audio Multiple Streams', '1.0', 'com.example.audio-multiple-streams');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Audio]);

  FRenderer := TSdlRenderer.Create('Examples/Audio/Multiple Streams', 640, 480, [], FWindow);

  { Open the default audio device in whatever format it prefers; our audio
    streams will adjust to it. }
  FAudioDevice := TSdlAudioDevice.Open(TSdlAudioDeviceID.DefaultPlaybackDevice);

  InitSound(0, 'SAMPLE_WAV');
  InitSound(1, 'SWORD_WAV');

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.InitSound(const AIndex: Integer; const AResourceName: String);
begin
  FSounds[AIndex] := LoadAudioBuffer(AResourceName);

  { Create an audio stream. Set the source format to the wav's format (what
    we'll input), leave the dest format NULL here (it'll change to what the
    device wants once we bind it). }
  FStreams[AIndex] := TSdlAudioStream.Create(FSounds[AIndex].Spec);
  FAudioDevice.Bind(FStreams[AIndex]);
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  for var I := 0 to 1 do
  begin
    { If less than a full copy of the audio is queued for playback, put another
      copy in there. This is overkill, but easy when lots of RAM is cheap. One
      could be more careful and  queue less at a time, as long as the stream
      doesn't run dry. }
    if (FStreams[I].Available < FSounds[I].Size) then
      FStreams[I].PutData(FSounds[I].Buffer, FSounds[I].Size);
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
  FSounds[1].Free;
  FSounds[0].Free;
  FStreams[1].Free;
  FStreams[0].Free;
  FAudioDevice.Close;
end;

begin
  RunApp(TApp);
end.
