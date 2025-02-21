program DebugText;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

{ This example creates an SDL window and renderer, and then draws some text
  using TSdlRenderer.DrawDebugText every frame. }

const
  WINDOW_WIDTH  = 640;
  WINDOW_HEIGHT = 480;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Renderer Debug Text', '1.0', 'com.example.renderer-debug-text');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Debug Text',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
const
  CHAR_SIZE = SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE;
begin
  { As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { White, full alpha. }
  FRenderer.SetDrawColor(255, 255, 255);
  FRenderer.DrawDebugText(272, 100, 'Hello world!');
  FRenderer.DrawDebugText(224, 150, 'This is some debug text.');

  { Light blue, full alpha. }
  FRenderer.SetDrawColor(51, 102, 255);
  FRenderer.DrawDebugText(184, 200, 'You can do it in different colors.');

  { White, full alpha. }
  FRenderer.SetDrawColor(255, 255, 255);

  FRenderer.Scale := SdlPointF(4, 4);
  FRenderer.DrawDebugText(14, 65, 'It can be scaled.');

  FRenderer.Scale := SdlPointF(1, 1);
  FRenderer.DrawDebugText(64, 350, 'This only does ASCII chars. So this laughing emoji won''t draw: 🤣');

  FRenderer.DrawDebugText((WINDOW_WIDTH - (CHAR_SIZE * 46)) / 2, 400, Format(
    '(This program has been running for %d seconds.)',
    [SdlGetTicks div 1000]));

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

begin
  RunApp(TApp);
end.
