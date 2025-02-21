program BytePusher;

{$R *.res}

uses
  System.Math,
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Audio,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Input,
  Neslib.Sdl3.Events,
  Neslib.Sdl3;

{ An implementation of the BytePusher VM.

  For example programs and more information about BytePusher, see
  https://esolangs.org/wiki/BytePusher }

const
  SCREEN_W                 = 256;
  SCREEN_H                 = 256;
  RAM_SIZE                 = $1000000;
  FRAMES_PER_SECOND        = 60;
  SAMPLES_PER_FRAME        = 256;
  NS_PER_SECOND            = SDL_NS_PER_SECOND;
  MAX_AUDIO_LATENCY_FRAMES = 5;

const
  IO_KEYBOARD    = 0;
  IO_PC          = 2;
  IO_SCREEN_PAGE = 5;
  IO_AUDIO_BANK  = 6;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FScreen: TSdlSurface;
    FScreenTex: TSdlTexture;
    FAudioStream: TSdlAudioStream;
    FRenderTarget: TSdlTexture; { We need this render target for text to look good }
    FRam: array [0..RAM_SIZE + 7] of Byte;
    FScreenBuf: array [0..(SCREEN_W * SCREEN_H) - 1] of Byte;
    FStatus: String;
    FStatusTicks: Integer;
    FLastTick: Int64;
    FTickAcc: Int64;
    FKeyState: Word;
    FDisplayHelp: Boolean;
    FPositionalInput: Boolean;
  private
    procedure SetStatus(const AStatus: String);
    function ReadU16(const AAddress: Integer): Integer;
    function ReadU24(const AAddress: Integer): Integer;
    procedure Print(const AX, AY: Integer; const AText: String);
    procedure LoadFile(const APath: String);
    function Load(const AStream: TSdlIOStream): Boolean;
  private
    class function KeycodeMask(const AKey: TSdlKeycode): Word; static;
    class function ScancodeMask(const AScancode: TSdlScancode): Word; static;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    function Event(const AEvent: TSdlEvent): TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

function TApp.Event(const AEvent: TSdlEvent): TSdlAppResult;
begin
  case AEvent.Kind of
    TSdlEventKind.Quit:
      Exit(TSdlAppResult.Success);

    TSdlEventKind.DropFile:
      LoadFile(AEvent.Drop.Data);

    TSdlEventKind.KeyDown:
      begin
        if (AEvent.Key.Key = TSdlKeycode.Return) then
        begin
          FPositionalInput := not FPositionalInput;
          FKeyState := 0;
          if (FPositionalInput) then
            SetStatus('switched to positional input')
          else
            SetStatus('switched to symbolic input');
        end;

        if (FPositionalInput) then
          FKeyState := FKeyState or ScancodeMask(Aevent.Key.Scancode)
        else
          FKeyState := FKeyState or KeycodeMask(Aevent.Key.Key);
      end;

    TSdlEventKind.KeyUp:
      begin
        if (FPositionalInput) then
          FKeyState := FKeyState and not ScancodeMask(Aevent.Key.Scancode)
        else
          FKeyState := FKeyState and not KeycodeMask(Aevent.Key.Key);
      end;
  end;

  Result := TSdlAppResult.Continue;
end;

function TApp.Init: TSdlAppResult;
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('SDL 3 BytePusher', '1.0', 'com.example.SDL3BytePusher');
  SdlSetAppMetadata(TSdlProperty.AppMetadataUrl, 'https://examples.libsdl.org/SDL3/demo/04-bytepusher/');
  SdlSetAppMetadata(TSdlProperty.AppMetadataCreator, 'SDL team');
  SdlSetAppMetadata(TSdlProperty.AppMetadataCopyright, 'Placed in the public domain');
  SdlSetAppMetadata(TSdlProperty.AppMetadataType, 'game');

  SdlInit([TSdlInitFlag.Video, TSdlInitFlag.Audio]);

  FDisplayHelp := True;
  var PrimaryDisplay := TSdlDisplay.Primary;
  var UsableBounds := PrimaryDisplay.UsableBounds;
  var ZoomW := (((UsableBounds.W - UsableBounds.X) * 2) div 3) div SCREEN_W;
  var ZoomH := (((UsableBounds.H - UsableBounds.Y) * 2) div 3) div SCREEN_W;
  var Zoom := Max(Min(ZoomW, ZoomH), 1);
  FRenderer := TSdlRenderer.Create('SDL 3 BytePusher',
    SCREEN_W * Zoom, SCREEN_H * Zoom, [TSdlWindowFlag.Resizable], FWindow);

  FRenderer.SetLogicalPresentation(SCREEN_W, SCREEN_H,
    TSdlRendererLogicalPresentation.IntegerScale);

  FScreen := TSdlSurface.Create(SCREEN_W, SCREEN_H, TSdlPixelFormat.Index8,
    @FScreenBuf, SCREEN_W);

  var Palette := FScreen.CreatePalette;
  { NOTE: No need to destroy the palette. It is owned by the surface. }

  var I := 0;
  for var R := 0 to 5 do
    for var G := 0 to 5 do
      for var B := 0 to 5 do
      begin
        Palette.Colors[I].Init(R * $33, G * $33, B * $33);
        Inc(I);
      end;

  while (I < 256) do
  begin
    Palette.Colors[I].Init(0, 0, 0);
    Inc(I);
  end;

  var TexProps := TSdlProperties.Create;
  try
    TexProps.AsNumber[TSdlProperty.TextureCreateAccess] := Ord(TSdlTextureAccess.Streaming);
    TexProps.AsNumber[TSdlProperty.TextureCreateWidth] := SCREEN_W;
    TexProps.AsNumber[TSdlProperty.TextureCreateHeight] := SCREEN_H;
    FScreenTex := FRenderer.CreateTexture(TexProps);

    TexProps.AsNumber[TSdlProperty.TextureCreateAccess] := Ord(TSdlTextureAccess.Target);
    FRenderTarget := FRenderer.CreateTexture(TexProps);
  finally
    TexProps.Free;
  end;

  FScreenTex.ScaleMode := TSdlScaleMode.Nearest;
  FRenderTarget.ScaleMode := TSdlScaleMode.Nearest;

  var AudioSpec := TSdlAudioSpec.Create(TSdlAudioFormat.S8, 1, SAMPLES_PER_FRAME * FRAMES_PER_SECOND);
  FAudioStream := TSdlAudioStream.Create(TSdlAudioDeviceID.DefaultPlaybackDevice,
    @AudioSpec);

  FAudioStream.Gain := 0.1; { Examples are loud! }
  FAudioStream.Resume;

  SetStatus('renderer: ' + FRenderer.Name);

  FLastTick := SdlGetTicksNS;
  FTickAcc := NS_PER_SECOND;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
begin
  var Tick := SdlGetTicksNS;
  var Delta := Tick - FLastTick;
  FLastTick := Tick;

  Inc(FTickAcc, Delta * FRAMES_PER_SECOND);
  var Updated := (FTickAcc >= NS_PER_SECOND);
  var SkipAudio := (FTickAcc >= (Int64(MAX_AUDIO_LATENCY_FRAMES) * NS_PER_SECOND));

  if (SkipAudio) then
    { Don't let audio fall too far behind }
    FAudioStream.Clear;

  while (FTickAcc >= NS_PER_SECOND) do
  begin
    Dec(FTickAcc, NS_PER_SECOND);

    FRam[IO_KEYBOARD]     := FKeyState shr 8;
    FRam[IO_KEYBOARD + 1] := Byte(FKeyState);

    var PC := ReadU24(IO_PC);
    for var I := 0 to (SCREEN_W * SCREEN_H) - 1 do
    begin
      var Src := ReadU24(PC);
      var Dst := ReadU24(PC + 3);
      FRam[Dst] := FRam[Src];
      PC := ReadU24(PC + 6);
    end;

    if (not SkipAudio) or (FTickAcc < NS_PER_SECOND) then
      FAudioStream.PutData(@FRam[ReadU16(IO_AUDIO_BANK) shl 8], SAMPLES_PER_FRAME);
  end;

  if (Updated) then
  begin
    FRenderer.Target := FRenderTarget;

    var Tex := FScreenTex.LockToSurface;
    try
      FScreen.Pixels := @FRam[FRam[IO_SCREEN_PAGE] shl 16];
      FScreen.Blit(nil, Tex, nil);
    finally
      FScreenTex.Unlock;
    end;

    FRenderer.DrawTexture(FScreenTex);
  end;

  if (FDisplayHelp) then
  begin
    Print(4,  4, 'Drop a BytePusher file in this');
    Print(8, 12, 'window to load and run it!');
    Print(4, 28, 'Press ENTER to switch between');
    Print(8, 36, 'positional and symbolic input.');
  end;

  if (FStatusTicks > 0) then
  begin
    Dec(FStatusTicks);
    Print(4, SCREEN_H - 12, FStatus);
  end;

  FRenderer.Target := nil;
  FRenderer.Clear;
  FRenderer.DrawTexture(FRenderTarget);
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

class function TApp.KeycodeMask(const AKey: TSdlKeycode): Word;
begin
  if (AKey >= TSdlKeycode._0) and (AKey <= TSdlKeycode._9) then
    Result := Ord(AKey) - Ord(TSdlKeycode._0)
  else if (AKey >= TSdlKeycode.A) and (AKey <= TSdlKeycode.F) then
    Result := Ord(AKey) - Ord(TSdlKeycode.A) + 10
  else
    Exit(0);

  Result := 1 shl Result;
end;

function TApp.Load(const AStream: TSdlIOStream): Boolean;
begin
  Result := True;
  FillChar(FRam, RAM_SIZE, 0);

  var BytesRead := 0;
  while (BytesRead < RAM_SIZE) do
  begin
    var Read := AStream.Read(@FRam[BytesRead], RAM_SIZE - BytesRead);
    Inc(BytesRead, Read);

    if (Read = 0) then
    begin
      Result := (AStream.Status = TSdlIOStatus.Eof);
      Break;
    end;
  end;

  FAudioStream.Clear;
  FDisplayHelp := not Result;
end;

procedure TApp.LoadFile(const APath: String);
begin
  var Stream := TSdlIOStream.Create(APath, 'rb');
  try
    if (Load(Stream)) then
      SetStatus('loaded ' + ExtractFileName(APath))
    else
      SetStatus('load failed: ' + ExtractFileName(APath));
  finally
    Stream.Free;
  end;
end;

procedure TApp.Print(const AX, AY: Integer; const AText: String);
begin
  FRenderer.SetDrawColor(0, 0, 0);
  FRenderer.DrawDebugText(AX + 1, AY + 1, AText);

  FRenderer.SetDrawColor($FF, $FF, $FF);
  FRenderer.DrawDebugText(AX, AY, AText);

  FRenderer.SetDrawColor(0, 0, 0);
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FAudioStream.Free;
  FRenderTarget.Free;
  FScreenTex.Free;
  FScreen.Free;
  FRenderer.Free;
  FWindow.Free;
end;

function TApp.ReadU16(const AAddress: Integer): Integer;
begin
  var P: PByte := @FRam[AAddress];
  Result := (P[0] shl 8) or P[1];
end;

function TApp.ReadU24(const AAddress: Integer): Integer;
begin
  var P: PByte := @FRam[AAddress];
  Result := (P[0] shl 16) or (P[1] shl 8) or P[2];
end;

class function TApp.ScancodeMask(const AScancode: TSdlScancode): Word;
begin
  case AScancode of
    TSdlScancode._1:
      Result := $01;

    TSdlScancode._2:
      Result := $02;

    TSdlScancode._3:
      Result := $03;

    TSdlScancode._4:
      Result := $0C;

    TSdlScancode.Q:
      Result := $04;

    TSdlScancode.W:
      Result := $05;

    TSdlScancode.E:
      Result := $06;

    TSdlScancode.R:
      Result := $0D;

    TSdlScancode.A:
      Result := $07;

    TSdlScancode.S:
      Result := $08;

    TSdlScancode.D:
      Result := $09;

    TSdlScancode.F:
      Result := $0E;

    TSdlScancode.Z:
      Result := $0A;

    TSdlScancode.X:
      Result := $00;

    TSdlScancode.C:
      Result := $0B;

    TSdlScancode.V:
      Result := $0F;
  else
    Exit(0);
  end;

  Result := 1 shl Result;
end;

procedure TApp.SetStatus(const AStatus: String);
begin
  FStatus := AStatus;
  FStatusTicks := FRAMES_PER_SECOND * 3;
end;

begin
  RunApp(TApp);
end.
