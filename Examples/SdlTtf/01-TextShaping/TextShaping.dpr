program TextShaping;

{$R *.res}

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Ttf.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Ttf,
  Neslib.Sdl3;

{ A test application for the SDL TTF library. }

{$R 'Resources.res'} { Contains TTF fonts }

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTtf: TBytes;
    FFont: TSdlTtfFont;
    FTextEngine: TSdlTtfRendererTextEngine;
    FText: TSdlTtfText;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
    procedure Quit(const AResult: TSdlAppResult); override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example SdlTtf TextShaping', '1.0', 'com.example.sdlttf-text-shaping');

  SdlInit([TSdlInitFlag.Video]);
  SdlTtfInit;

  { Create maximized window and renderer }
  FRenderer := TSdlRenderer.Create('Examples/SdlTtf/Text Shaping',
    0, 0, [TSdlWindowFlag.Resizable, TSdlWindowFlag.Maximized], FWindow);

  { Create a text engine for use with the renderer }
  FTextEngine := TSdlTtfRendererTextEngine.Create(FRenderer);

  { Determine display scale to scale font }
  var Scale: Single := FWindow.DisplayScale;

  { Load "NotoSansArabic-Regular.ttf" from resource }
  var Stream := TResourceStream.Create(HInstance, 'NOTO_SANS_ARABIC', RT_RCDATA);
  try
    SetLength(FTtf, Stream.Size);
    Stream.ReadBuffer(FTtf, Length(FTtf));
  finally
    Stream.Free;
  end;

  { Create TSdlIOStream from raw TTF data. }
  var IOStream := TSdlIOStream.Create(Pointer(FTtf), Length(FTtf), True);

  { The stream *must* stay alive while the font is in use, so set the 2nd
    parameter to True to have the font free the stream when the font is
    destroyed. }
  FFont := TSdlTtfFont.Create(IOStream, True, 48 * Scale);

  FText := FTextEngine.CreateText(FFont, 'نص عربي');

  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
begin
  { Clear background. }
  FRenderer.SetDrawColorFloat(0, 0, 0);
  FRenderer.Clear;

  { Draw the text }
  var OutputSize := FRenderer.CurrentOutputSize;
  var TextSize := FText.Size;
  FTextEngine.Draw(FText,
    (OutputSize.W - TextSize.W) div 2,
    (OutputSize.H - TextSize.H) div 2);

  { Put the newly-cleared rendering on the screen. }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FText.Free;
  FFont.Free;
  FTextEngine.Free;
  FRenderer.Free;
  FWindow.Free;
  SdlTtfQuit;
end;

begin
  RunApp(TApp);
end.
