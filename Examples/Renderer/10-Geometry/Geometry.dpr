program Geometry;

{$R *.res}

uses
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Time,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3,
  Sample.Utils;

const
  WINDOW_WIDTH  = 640;
  WINDOW_HEIGHT = 480;

type
  TApp = class(TSdlApp)
  private
    FWindow: TSdlWindow;
    FRenderer: TSdlRenderer;
    FTexture: TSdlTexture;
    FTextureWidth: Integer;
    FTextureHeight: Integer;
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

  SdlSetAppMetadata('Example Renderer Geometry', '1.0', 'com.example.renderer-geometry');

  SdlInit([TSdlInitFlag.Video]);

  FRenderer := TSdlRenderer.Create('Examples/Renderer/Geometry',
    WINDOW_WIDTH, WINDOW_HEIGHT, [], FWindow);

  { Textures are pixel data that we upload to the video hardware for fast drawing.
    Lots of 2D engines refer to these as "sprites." We'll do a static texture
    (upload once, draw many times) with data from a bitmap file.

    TSdlSurface is pixel data the CPU can access. TSdlTexture is pixel data the
    GPU can access. Load a .bmp into a surface, move it to a texture from there. }
  var Surface := LoadBitmap('SAMPLE_BMP');
  try
    FTextureWidth := Surface.W;
    FTextureHeight := Surface.H;
    FTexture := FRenderer.CreateTexture(Surface);
  finally
    { Done with this, the texture has a copy of the pixels now. }
    Surface.Free;
  end;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

function TApp.Iterate: TSdlAppResult;
{ This method runs once per frame, and is the heart of the program. }
begin
  var Now := SdlGetTicks;

  { We'll have the triangle grow and shrink over a few seconds. }
  var Direction: Single;
  if ((Now mod 2000) >= 1000) then
    Direction := 1
  else
    Direction := -1;

  var Scale: Single := (((Now mod 1000) - 500) / 500) * Direction;
  var Size: Single := 200 + (200 * Scale);

  { As you can see from this, rendering draws over whatever was drawn before it.
    Black, full alpha. }
  FRenderer.SetDrawColor(0, 0, 0);

  { Start with a blank canvas. }
  FRenderer.Clear;

  { Draw a single triangle with a different color at each vertex.
    Center this one and make it grow and shrink.
    You always draw triangles with this, but you can string triangles together
    to form polygons. }
  var Vertices: TArray<TSdlVertex>;
  SetLength(Vertices, 3);
  Vertices[0].Position.X := WINDOW_WIDTH / 2;
  Vertices[0].Position.Y := (WINDOW_HEIGHT - Size) / 2.0;
  Vertices[0].Color.R := 1.0;
  Vertices[0].Color.A := 1.0;
  Vertices[1].Position.X := (WINDOW_WIDTH + Size) / 2.0;
  Vertices[1].Position.Y := (WINDOW_HEIGHT + Size) / 2.0;
  Vertices[1].Color.G := 1.0;
  Vertices[1].Color.A := 1.0;
  Vertices[2].Position.X := (WINDOW_WIDTH - Size) / 2.0;
  Vertices[2].Position.Y := (WINDOW_HEIGHT + Size) / 2.0;
  Vertices[2].Color.B := 1.0;
  Vertices[2].Color.A := 1.0;
  FRenderer.DrawGeometry(Vertices);

  { You can also map a texture to the geometry!
    Texture coordinates go from 0.0 to 1.0. That will be the location in the
    texture bound to this vertex. }
  FillChar(Vertices[0], Length(Vertices) * SizeOf(TSdlVertex), 0);
  Vertices[0].Position.X := 10.0;
  Vertices[0].Position.Y := 10.0;
  Vertices[0].Color.R := 1.0;
  Vertices[0].Color.G := 1.0;
  Vertices[0].Color.B := 1.0;
  Vertices[0].Color.A := 1.0;
  Vertices[0].TexCoord.X := 0.0;
  Vertices[0].TexCoord.Y := 0.0;
  Vertices[1].Position.X := 150.0;
  Vertices[1].Position.Y := 10.0;
  Vertices[1].Color.R := 1.0;
  Vertices[1].Color.G := 1.0;
  Vertices[1].Color.B := 1.0;
  Vertices[1].Color.A := 1.0;
  Vertices[1].TexCoord.X := 1.0;
  Vertices[1].TexCoord.Y := 0.0;
  Vertices[2].Position.X := 10.0;
  Vertices[2].Position.Y := 150.0;
  Vertices[2].Color.R := 1.0;
  Vertices[2].Color.G := 1.0;
  Vertices[2].Color.B := 1.0;
  Vertices[2].Color.A := 1.0;
  Vertices[2].TexCoord.X := 0.0;
  Vertices[2].TexCoord.Y := 1.0;
  FRenderer.DrawGeometry(FTexture, Vertices);

  { Did that only draw half of the texture?
    You can do multiple triangles sharing some vertices, using indices, to get
    the whole thing on the screen:

    Let's just move this over so it doesn't overlap... }
  for var I := 0 to 2 do
    Vertices[I].Position.X := Vertices[I].Position.X + 450;

  { We need one more vertex, since the two triangles can share two of them. }
  SetLength(Vertices, Length(Vertices) + 1);
  Vertices[3].Position.X := 600.0;
  Vertices[3].Position.Y := 150.0;
  Vertices[3].Color.R := 1.0;
  Vertices[3].Color.G := 1.0;
  Vertices[3].Color.B := 1.0;
  Vertices[3].Color.A := 1.0;
  Vertices[3].TexCoord.X := 1.0;
  Vertices[3].TexCoord.Y := 1.0;

  { And an index to tell it to reuse some of the vertices between triangles...
    4 vertices, but 6 actual places they used. Indices need less bandwidth to
    transfer and can reorder vertices easily! }
  var Indices := TArray<Integer>.Create(0, 1, 2, 1, 2, 3);
  FRenderer.DrawGeometry(FTexture, Vertices, Indices);

  { Put it all on the screen! }
  FRenderer.Present;

  { Carry on with the program! }
  Result := TSdlAppResult.Continue;
end;

procedure TApp.Quit(const AResult: TSdlAppResult);
begin
  FTexture.Free;
  { SDL will clean up the window/renderer for us. }
end;

begin
  RunApp(TApp);
end.
