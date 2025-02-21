program Snake;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Input,
  Neslib.Sdl3.Events,
  Neslib.Sdl3;

{$SCOPEDENUMS ON}

{ Logic implementation of the Snake game. It is designed to efficiently
  represent the state of the game in memory. }

const
  STEP_RATE_IN_MILLISECONDS  = 125;
  SNAKE_BLOCK_SIZE_IN_PIXELS = 24;
  SNAKE_GAME_WIDTH           = 24;
  SNAKE_GAME_HEIGHT          = 18;
  SDL_WINDOW_WIDTH           = (SNAKE_BLOCK_SIZE_IN_PIXELS * SNAKE_GAME_WIDTH);
  SDL_WINDOW_HEIGHT          = (SNAKE_BLOCK_SIZE_IN_PIXELS * SNAKE_GAME_HEIGHT);

type
  TSnakeCell      = (Nothing, Right, Up, Left, Down, Food);
  TSnakeDirection = (Right, Up, Left, Down);

type
  TSnakeContext = record
  private
    FCells: array [0..SNAKE_GAME_HEIGHT - 1, 0..SNAKE_GAME_WIDTH - 1] of TSnakeCell;
    FHeadPos: TSdlPoint;
    FTailPos: TSdlPoint;
    FNextDir: TSnakeDirection;
    FInhibitTailStep: Integer;
    FOccupiedCells: Integer;
  private
    procedure NewFoodPos;
    procedure Redir(const ADir: TSnakeDirection);
    function AreCellsFull: Boolean;
  private
    class procedure WrapAround(var AValue: Integer; const AMax: Integer); static;
  public
    procedure Initialize;
    function HandleKeyEvent(const AKeyCode: TSdlScancode): TSdlAppResult;
    procedure Step;
  end;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FSnakeCtx: TSnakeContext;
    FLastStep: Int64;
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

    TSdlEventKind.KeyDown:
      Exit(FSnakeCtx.HandleKeyEvent(AEvent.Key.Scancode));
  end;

  Result := TSdlAppResult.Continue;
end;

function TApp.Init: TSdlAppResult;
begin
  ReportMemoryLeaksOnShutdown := True;

  SdlSetAppMetadata('Example Snake game', '1.0', 'com.example.snake');
  SdlSetAppMetadata(TSdlProperty.AppMetadataUrl, 'https://examples.libsdl.org/SDL3/demo/01-snake/');
  SdlSetAppMetadata(TSdlProperty.AppMetadataCreator, 'SDL team');
  SdlSetAppMetadata(TSdlProperty.AppMetadataCopyright, 'Placed in the public domain');
  SdlSetAppMetadata(TSdlProperty.AppMetadataType, 'Game');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Demo/Snake',
    SDL_WINDOW_WIDTH, SDL_WINDOW_HEIGHT, [], FWindow);

  FSnakeCtx.Initialize;
  FLastStep := SdlGetTicks;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
begin
  var Now := SdlGetTicks;

  { Run game logic if we're at or past the time to run it.
    If we're _really_ behind the time to run it, run it several times. }
  while ((Now - FLastStep) >= STEP_RATE_IN_MILLISECONDS) do
  begin
    FSnakeCtx.Step;
    Inc(FLastStep, STEP_RATE_IN_MILLISECONDS);
  end;

  var R := SdlRectF(0, 0, SNAKE_BLOCK_SIZE_IN_PIXELS, SNAKE_BLOCK_SIZE_IN_PIXELS);
  FRenderer.SetDrawColor(0, 0, 0);
  FRenderer.Clear;

  for var Y := 0 to SNAKE_GAME_HEIGHT - 1 do
  begin
    for var X := 0 to SNAKE_GAME_WIDTH - 1 do
    begin
      var Cell := FSnakeCtx.FCells[Y, X];
      if (Cell = TSnakeCell.Nothing) then
        Continue;

      R.X := X * SNAKE_BLOCK_SIZE_IN_PIXELS;
      R.Y := Y * SNAKE_BLOCK_SIZE_IN_PIXELS;

      if (Cell = TSnakeCell.Food) then
        { Food }
        FRenderer.SetDrawColor(80, 80, 255)
      else
        { Body }
        FRenderer.SetDrawColor(0, 128, 0);

      FRenderer.FillRect(R);
    end;
  end;

  { Head }
  FRenderer.SetDrawColor(255, 255, 0);
  R.X := FSnakeCtx.FHeadPos.X * SNAKE_BLOCK_SIZE_IN_PIXELS;
  R.Y := FSnakeCtx.FHeadPos.Y * SNAKE_BLOCK_SIZE_IN_PIXELS;
  FRenderer.FillRect(R);

  FRenderer.Present;
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FRenderer.Free;
  FWindow.Free;
end;

{ TSnakeContext }

function TSnakeContext.AreCellsFull: Boolean;
begin
  Result := (FOccupiedCells = (SNAKE_GAME_WIDTH * SNAKE_GAME_HEIGHT));
end;

function TSnakeContext.HandleKeyEvent(
  const AKeyCode: TSdlScancode): TSdlAppResult;
begin
  case AKeyCode of
    TSdlScancode.Escape,
    TSdlScancode.Q:
      { Quit }
      Exit(TSdlAppResult.Success);

    TSdlScancode.R:
      { Restart the game as if the program was launched }
      Initialize;

    TSdlScancode.Right:
      Redir(TSnakeDirection.Right);

    TSdlScancode.Up:
      Redir(TSnakeDirection.Up);

    TSdlScancode.Left:
      Redir(TSnakeDirection.Left);

    TSdlScancode.Down:
      Redir(TSnakeDirection.Down);
  end;

  Result := TSdlAppResult.Continue;
end;

procedure TSnakeContext.Initialize;
begin
  FillChar(Self, SizeOf(Self), 0);

  FHeadPos.Init(SNAKE_GAME_WIDTH div 2, SNAKE_GAME_HEIGHT div 2);
  FTailPos := FHeadPos;
  FNextDir := TSnakeDirection.Right;
  FInhibitTailStep := 4;
  FOccupiedCells := 3;
  FCells[FTailPos.Y, FTailPos.X] := TSnakeCell.Right;

  for var I := 0 to 3 do
  begin
    NewFoodPos;
    Inc(FOccupiedCells);
  end;
end;

procedure TSnakeContext.NewFoodPos;
begin
  while (True) do
  begin
    var X := Random(SNAKE_GAME_WIDTH);
    var Y := Random(SNAKE_GAME_HEIGHT);
    if (FCells[Y, X] = TSnakeCell.Nothing) then
    begin
      FCells[Y, X] := TSnakeCell.Food;
      Break;
    end;
  end;
end;

procedure TSnakeContext.Redir(const ADir: TSnakeDirection);
begin
  var Cell := FCells[FHeadPos.Y, FHeadPos.X];

  if ((ADir = TSnakeDirection.Right) and (Cell <> TSnakeCell.Left)) or
     ((ADir = TSnakeDirection.Up)    and (Cell <> TSnakeCell.Down)) or
     ((ADir = TSnakeDirection.Left)  and (Cell <> TSnakeCell.Right)) or
     ((ADir = TSnakeDirection.Down)  and (Cell <> TSnakeCell.Up))
  then
    FNextDir := ADir;
end;

procedure TSnakeContext.Step;
begin
  var DirAsCell := TSnakeCell(Ord(FNextDir) + 1);
  var Cell: TSnakeCell;

  { Move tail forward }
  Dec(FInhibitTailStep);
  if (FInhibitTailStep = 0) then
  begin
    Inc(FInhibitTailStep);
    Cell := FCells[FTailPos.Y, FTailPos.X];
    FCells[FTailPos.Y, FTailPos.X] := TSnakeCell.Nothing;

    case Cell of
      TSnakeCell.Right:
        Inc(FTailPos.X);

      TSnakeCell.Up:
        Dec(FTailPos.Y);

      TSnakeCell.Left:
        Dec(FTailPos.X);

      TSnakeCell.Down:
        Inc(FTailPos.Y);
    end;

    WrapAround(FTailPos.X, SNAKE_GAME_WIDTH);
    WrapAround(FTailPos.Y, SNAKE_GAME_HEIGHT);
  end;

  { Move head forward }
  var PrevPos := FHeadPos;
  case FNextDir of
    TSnakeDirection.Right:
      Inc(FHeadPos.X);

    TSnakeDirection.Up:
      Dec(FHeadPos.Y);

    TSnakeDirection.Left:
      Dec(FHeadPos.X);

    TSnakeDirection.Down:
      Inc(FHeadPos.Y);
  end;

  WrapAround(FHeadPos.X, SNAKE_GAME_WIDTH);
  WrapAround(FHeadPos.Y, SNAKE_GAME_HEIGHT);

  { Collisions }
  Cell := FCells[FHeadPos.Y, FHeadPos.X];
  if (not (Cell in [TSnakeCell.Nothing, TSnakeCell.Food])) then
  begin
    Initialize;
    Exit;
  end;

  FCells[PrevPos.Y, PrevPos.X] := DirAsCell;
  FCells[FHeadPos.Y, FheadPos.X] := DirAsCell;

  if (Cell = TSnakeCell.Food) then
  begin
    if (AreCellsFull) then
    begin
      Initialize;
      Exit;
    end;

    NewFoodPos;
    Inc(FInhibitTailStep);
    Inc(FOccupiedCells);
  end;
end;

class procedure TSnakeContext.WrapAround(var AValue: Integer;
  const AMax: Integer);
begin
  if (AValue < 0) then
    AValue := AMax - 1
  else if (AValue >= AMax) then
    AValue := 0;
end;

begin
  RunApp(TApp);
end.
