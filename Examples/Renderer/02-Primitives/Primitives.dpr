program Primitives;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FPoints: array [0..499] of TSdlPointF;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Renderer Primitives', '1.0', 'com.example.renderer-primitives');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Primitives', 640, 480, [], FWindow);

  { Set up some random points }
  for var I := 0 to Length(FPoints) - 1 do
    FPoints[I].Init((Random * 440) + 100, (Random * 280) + 100);

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  { As you can see from this, rendering draws over whatever was drawn before it.
    Dark gray, full alpha. }
  FRenderer.SetDrawColor(255, 33, 33);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Draw a filled rectangle in the middle of the canvas.
    Blue, full alpha. }
  FRenderer.SetDrawColor(0, 0, 255);
  var Rect := TSdlRectF.Create(100, 100, 440, 280);
  FRenderer.FillRect(Rect);

  { Draw some points across the canvas.
    Red, full alpha. }
  FRenderer.SetDrawColor(255, 0, 0);
  FRenderer.DrawPoints(FPoints);

  { Draw a unfilled rectangle in-set a little bit.
    Green, full alpha. }
  FRenderer.SetDrawColor(0, 255, 0);
  Rect.X := Rect.X + 30;
  Rect.Y := Rect.Y + 30;
  Rect.W := Rect.W - 60;
  Rect.H := Rect.H - 60;
  FRenderer.DrawRect(Rect);

  { Draw two lines in an X across the whole canvas.
    Yellow, full alpha. }
  FRenderer.SetDrawColor(255, 255, 0);
  FRenderer.DrawLine(0, 0, 640, 480);
  FRenderer.DrawLine(0, 480, 640, 0);

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

begin
  RunApp(TApp);
end.
