program Points;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3;

{ This example creates an SDL window and renderer, and then draws some points
  to it every frame. }

const
  WINDOW_WIDTH  = 640;
  WINDOW_HEIGHT = 480;

  NUM_POINTS            = 500;
  MIN_PIXELS_PER_SECOND = 30; // move at least this many pixels per second.
  MAX_PIXELS_PER_SECOND = 60; // move this many pixels per second at most.

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FLastTime: Int64;

    { (Track everything as parallel arrays instead of a array of structs,
      so we can pass the coordinates to the renderer in a single function call.)

      Points are plotted as a set of X and Y coordinates.
      (0, 0) is the top left of the window, and larger numbers go down
      and to the right. This isn't how geometry works, but this is pretty
      standard in 2D graphics. }
    FPoints: array [0..NUM_POINTS - 1] of TSdlPointF;
    FPointSpeeds: array [0..NUM_POINTS - 1] of Single;
  protected
    function Init: TSdlAppResult; override;
    function Iterate: TSdlAppResult; override;
  end;

{ TApp }

function TApp.Init: TSdlAppResult;
{ This function runs once at startup }
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Renderer Points', '1.0', 'com.example.renderer-points');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Points',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  { Set up the data for a bunch of points. }
  for var I := 0 to NUM_POINTS - 1 do
  begin
    FPoints[I].X := Random * WINDOW_WIDTH;
    FPoints[I].Y := Random * WINDOW_HEIGHT;
    FPointSpeeds[I] := MIN_PIXELS_PER_SECOND + (Random * (MAX_PIXELS_PER_SECOND - MIN_PIXELS_PER_SECOND));
  end;

  FLastTime := SdlGetTicks;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  var Now := SdlGetTicks;

  { Seconds since last iteration }
  var Elapsed: Single := (Now - FLastTime) / 1000;

  { Let's move all our points a little for a new frame. }
  for var I := 0 to NUM_POINTS - 1 do
  begin
    var Distance: SIngle := Elapsed * FPointSpeeds[I];
    FPoints[I].X := FPoints[I].X + Distance;
    FPoints[I].Y := FPoints[I].Y + Distance;

    if (FPoints[I].X >= WINDOW_WIDTH) or (FPoints[I].Y >= WINDOW_HEIGHT) then
    begin
      { Off the screen; restart it elsewhere! }
      if (Random(2) = 0) then
      begin
        FPoints[I].X := Random * WINDOW_WIDTH;
        FPoints[I].Y := 0;
      end
      else
      begin
        FPoints[I].X := 0;
        FPoints[I].Y := Random * WINDOW_HEIGHT;
      end;

      FPointSpeeds[I] := MIN_PIXELS_PER_SECOND + (Random * (MAX_PIXELS_PER_SECOND - MIN_PIXELS_PER_SECOND));
    end;
  end;

  FLastTime := Now;

  { As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { White, full alpha. }
  FRenderer.SetDrawColor(255, 255, 255);

  { Draw all the points! }
  FRenderer.DrawPoints(FPoints);

  { You can also draw single points with DrawPoint, but it's cheaper (sometimes
    significantly so) to do them all at once. }

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

begin
  RunApp(TApp);
end.
