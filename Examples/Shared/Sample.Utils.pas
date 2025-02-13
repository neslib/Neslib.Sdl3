unit Sample.Utils;
{ This is a helper unit to provide sample resources (bitmaps etc.) from an
  embedded SampleResource.res resource file. This simplifies deployment since
  we don't need to worry about deploying these files to their appropriate
  locations on different platforms. }

interface

uses
  Neslib.Sdl3,
  Neslib.Sdl3.Audio,
  Neslib.Sdl3.Video;

{ Loads an embedded bitmap resource given its name. }
function LoadBitmap(const AName: String): TSdlSurface;

{ Loads an embedded wav file resource given its name. }
function LoadAudioBuffer(const AName: String): TSdlAudioBuffer;

implementation

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.IO;

{$R '..\Resources\SampleResources.res'}

function LoadBitmap(const AName: String): TSdlSurface;
begin
  var Data: TBytes;
  var Stream := TResourceStream.Create(HInstance, AName, RT_RCDATA);
  try
    SetLength(Data, Stream.Size);
    Stream.ReadBuffer(Data, Length(Data));
  finally
    Stream.Free;
  end;

  var IOStream := TSdlIOStream.Create(Pointer(Data), Length(Data), True);
  Result := TSdlSurface.LoadBmp(IOStream, True);
end;

function LoadAudioBuffer(const AName: String): TSdlAudioBuffer;
begin
  var Data: TBytes;
  var Stream := TResourceStream.Create(HInstance, AName, RT_RCDATA);
  try
    SetLength(Data, Stream.Size);
    Stream.ReadBuffer(Data, Length(Data));
  finally
    Stream.Free;
  end;

  var IOStream := TSdlIOStream.Create(Pointer(Data), Length(Data), True);
  Result := TSdlAudioBuffer.CreateFromWav(IOStream, True);
end;

end.
