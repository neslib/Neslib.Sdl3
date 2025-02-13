program DrawingLines;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Input,
  Neslib.Sdl3.Events,
  Neslib.Sdl3;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FRenderTarget: TSdlTexture;
    FPressure: Single;
    FPreviousTouch: TSdlPointF;
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
  FPreviousTouch.Init(-1, -1);

  SdlSetAppMetadata('Example Pen Drawing Lines', '1.0', 'com.example.pen-drawing-lines');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Pen/Drawing Lines', 640, 480, [], FWindow);

  { We make a render target so we can draw lines to it and not have to record
    and redraw every pen stroke each frame. Instead rendering a frame for us is
    a single texture draw. }

  { Make sure the render target matches output size (for hidpi displays, etc) so
    drawing matches the pen's position on a tablet display. }
  var Size := FRenderer.OuputSize;
  FRenderTarget := FRenderer.CreateTexture(TSdlPixelFormat.Rgba8888,
    TSdlTextureAccess.Target, Size.W, Size.H);

  { Just blank the render target to gray to start. }
  FRenderer.Target := FRenderTarget;
  FRenderer.SetDrawColor(100, 100, 100);
  FRenderer.Clear;
  FRenderer.Target := nil;
  FRenderer.DrawBlendMode := TSdlBlendMode.Blend;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Event(const AEvent: TSdlEvent): TSdlAppResult;
{ This method runs when a new event (mouse input, keypresses, etc) occurs. }
begin
  { There are several events that track the specific stages of pen activity,
    but we're only going to look for motion and pressure, for simplicity. }
  case AEvent.Kind of
    TSdlEventKind.Quit:
      { End the program, reporting success to the OS. }
      Exit(TSdlAppResult.Success);

    TSdlEventKind.PenMotion:
      begin
        { You can check for when the pen is touching, but if FPressure > 0.0,
          it's definitely touching! }
        if (FPressure > 0) then
        begin
          if (FPreviousTouch.X >= 0) then
          begin
            { Only draw if we're moving while touching.
              Draw with the alpha set to the pressure, so you effectively get a
              fainter line for lighter presses. }
            FRenderer.Target := FRenderTarget;
            FRenderer.SetDrawColorFloat(0, 0, 0, FPressure);
            FRenderer.DrawLine(FPreviousTouch, AEvent.PenMotion.Position);
          end;
          FPreviousTouch := AEvent.PenMotion.Position;
        end
        else
          FPreviousTouch.Init(-1, -1);
      end;

    TSdlEventKind.PenAxis:
      if (AEvent.PenAxis.Axis = TSdlPenAxis.Presssure) then
        { Remember new pressure for later draws. }
        FPressure := AEvent.PenAxis.Value;
  end;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  { Make sure we're drawing to the window and not the render target }
  FRenderer.Target := nil;
  FRenderer.SetDrawColor(0, 0, 0);

  { Just in case }
  FRenderer.Clear;

  FRenderer.DrawTexture(FRenderTarget, SdlRectF(0, 0, FRenderTarget.W, FRenderTarget.H));
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FRenderTarget.Free;
  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
