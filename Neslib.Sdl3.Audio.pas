/// <summary>
///  Audio functionality for the SDL library.
///
///  All audio in SDL3 revolves around TSdlAudioStream. Whether you want to play
///  or record audio, convert it, stream it, buffer it, or mix it, you're going
///  to be passing it through an audio stream.
///
///  Audio streams are quite flexible; they can accept any amount of data at a
///  time, in any supported format, and output it as needed in any other format,
///  even if the data format changes on either side halfway through.
///
///  An app opens an audio device and binds any number of audio streams to it,
///  feeding more data to the streams as available. When the device needs more
///  data, it will pull it from all bound streams and mix them together for
///  playback.
///
///  Audio streams can also use an app-provided callback to supply data
///  on-demand, which maps pretty closely to the SDL2 audio model.
///
///  SDL also provides a simple .WAV loader in TSdlAudioSpec.LoadWav as a basic
///  means to load sound data into your program.
///
///  ## Logical audio devices
///
///  In SDL3, opening a physical device (like a SoundBlaster 16 Pro) gives you a
///  logical device ID that you can bind audio streams to. In almost all cases,
///  logical devices can be used anywhere in the API that a physical device is
///  normally used. However, since each device opening generates a new logical
///  device, different parts of the program (say, a VoIP library, or
///  text-to-speech framework, or maybe some other sort of mixer on top of SDL)
///  can have their own device opens that do not interfere with each other; each
///  logical device will mix its separate audio down to a single buffer, fed to
///  the physical device, behind the scenes. As many logical devices as you like
///  can come and go; SDL will only have to open the physical device at the OS
///  level once, and will manage all the logical devices on top of it
///  internally.
///
///  One other benefit of logical devices: if you don't open a specific physical
///  device, instead opting for the default, SDL can automatically migrate those
///  logical devices to different hardware as circumstances change: a user
///  plugged in headphones? The system default changed? SDL can transparently
///  migrate the logical devices to the correct physical device seamlessly and
///  keep playing; the app doesn't even have to know it happened if it doesn't
///  want to.
///
///  ## Simplified audio
///
///  As a simplified model for when a single source of audio is all that's
///  needed, an app can use TSdlAudioStream.Open, which is a single function to
///  open an audio device, create an audio stream, bind that stream
///  to the newly-opened device, and (optionally) provide a callback for
///  obtaining audio data. When using this function, the primary interface is
///  the TSdlAudioStream and the device handle is mostly hidden away; destroying
///  a stream created through this function will also close the device, stream
///  bindings cannot be changed, etc. One other quirk of this is that the device
///  is started in a _paused_ state and must be explicitly resumed; this is
///  partially to offer a clean migration for SDL2 apps and partially because
///  the app might have to do more setup before playback begins; in the
///  non-simplified form, nothing will play until a stream is bound to a device,
///  so they start _unpaused_.
///
///  ## Channel layouts
///
///  Audio data passing through SDL is uncompressed PCM data, interleaved. One
///  can provide their own decompression through an MP3, etc, decoder, but SDL
///  does not provide this directly. Each interleaved channel of data is meant
///  to be in a specific order.
///
///  Abbreviations:
///
///  - FRONT = single mono speaker
///  - FL = front left speaker
///  - FR = front right speaker
///  - FC = front center speaker
///  - BL = back left speaker
///  - BR = back right speaker
///  - SR = surround right speaker
///  - SL = surround left speaker
///  - BC = back center speaker
///  - LFE = low-frequency speaker
///
///  These are listed in the order they are laid out in memory, so "FL, FR"
///  means "the front left speaker is laid out in memory first, then the front
///  right, then it repeats for the next audio frame".
///
///  - 1 channel (mono) layout: FRONT
///  - 2 channels (stereo) layout: FL, FR
///  - 3 channels (2.1) layout: FL, FR, LFE
///  - 4 channels (quad) layout: FL, FR, BL, BR
///  - 5 channels (4.1) layout: FL, FR, LFE, BL, BR
///  - 6 channels (5.1) layout: FL, FR, FC, LFE, BL, BR (last two can also be
///    SL, SR)
///  - 7 channels (6.1) layout: FL, FR, FC, LFE, BC, SL, SR
///  - 8 channels (7.1) layout: FL, FR, FC, LFE, BL, BR, SL, SR
///
///  This is the same order as DirectSound expects, but applied to all
///  platforms; SDL will swizzle the channels as necessary if a platform expects
///  something different.
///
///  TSdlAudioStream can also be provided channel maps to change this ordering
///  to whatever is necessary, in other audio processing scenarios.
/// </summary>
unit Neslib.Sdl3.Audio;

{ Simple DirectMedia Layer
  Copyright (C) 1997-2025 Sam Lantinga <slouken@libsdl.org>

  Neslib.Sdl3
  Copyright (C) 2025 Erik van Bilsen

  This software is provided 'as-is', without any express or implied
  warranty.  In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution. }

{$Include 'Neslib.Sdl3.inc'}

interface

uses
  Neslib.Sdl3.Api,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Basics;

{$REGION 'Audio'}
type
  /// <summary>
  ///  Audio format.
  /// </summary>
  TSdlAudioFormat = (
    /// <summary>
    ///  Unspecified audio format
    /// </summary>
    Unknown = SDL_AUDIO_UNKNOWN,

    /// <summary>
    ///  Unsigned 8-bit samples
    /// </summary>
    U8      = SDL_AUDIO_U8,

    /// <summary>
    ///  Signed 8-bit samples
    /// </summary>
    S8      = SDL_AUDIO_S8,

    /// <summary>
    ///  Signed 16-bit samples
    /// </summary>
    S16     = SDL_AUDIO_S16,

    /// <summary>
    ///  32-bit integer samples
    /// </summary>
    S32     = SDL_AUDIO_S32,

    ///  32-bit floating point samples
    F32     = SDL_AUDIO_F32,

    /// <summary>
    ///  Signed 16-bit samples, in little-endian byte order
    /// </summary>
    S16LE   = SDL_AUDIO_S16LE,

    /// <summary>
    ///  Signed 16-bit samples, big-endian byte order
    /// </summary>
    S16BE   = SDL_AUDIO_S16BE,

    /// <summary>
    ///  32-bit integer samples, in little-endian byte order
    /// </summary>
    S32LE   = SDL_AUDIO_S32LE,

    /// <summary>
    ///  32-bit integer samples, in big-endian byte order
    /// </summary>
    S32BE   = SDL_AUDIO_S32BE,

    /// <summary>
    ///  32-bit floating point samples, in little-endian byte order
    /// </summary>
    F32LE   = SDL_AUDIO_F32LE,

    /// <summary>
    ///  32-bit floating point samples, in big-endian byte order
    /// </summary>
    F32BE   = SDL_AUDIO_F32BE);

  _TSdlAudioFormatHelper = record helper for TSdlAudioFormat
  {$REGION 'Internal Declarations'}
  private
    function GetBitSize: Byte; inline;
    function GetByteSize: Byte; inline;
    function GetIsFloat: Boolean; inline;
    function GetIsInteger: Boolean; inline;
    function GetIsBigEndian: Boolean; inline;
    function GetIsLittleEndian: Boolean; inline;
    function GetIsSigned: Boolean; inline;
    function GetIsUnsigned: Boolean; inline;
    function GetName: String; inline;
    function GetSilenceValue: Byte; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The size, in bits.
    ///
    ///  For example, `TSdlAudioFormat.S16` returns 16.
    /// </summary>
    property BitSize: Byte read GetBitSize;

    /// <summary>
    ///  The size, in bytes.
    ///
    ///  For example, `TSdlAudioFormat.S16` returns 2.
    /// </summary>
    property ByteSize: Byte read GetByteSize;

    /// <summary>
    ///  Whether this format represents floating point data.
    ///
    ///  For example, `TSdlAudioFormat.S16` returns False.
    /// </summary>
    property IsFloat: Boolean read GetIsFloat;

    /// <summary>
    ///  Whether this format represents integer data.
    ///
    ///  For example, `TSdlAudioFormat.S16` returns True.
    /// </summary>
    property IsInteger: Boolean read GetIsInteger;

    /// <summary>
    ///  Whether this format represents big-endian data.
    ///
    ///  For example, `TSdlAudioFormat.S16LE` returns False.
    /// </summary>
    property IsBigEndian: Boolean read GetIsBigEndian;

    /// <summary>
    ///  Whether this format represents little-endian data.
    ///
    ///  For example, `TSdlAudioFormat.S16LE` returns True.
    /// </summary>
    property IsLittleEndian: Boolean read GetIsLittleEndian;

    /// <summary>
    ///  Whether this format represents signed data.
    ///
    ///  For example, `TSdlAudioFormat.U8` returns False.
    /// </summary>
    property IsSigned: Boolean read GetIsSigned;

    /// <summary>
    ///  Whether this format represents unsigned data.
    ///
    ///  For example, `TSdlAudioFormat.U8` returns True.
    /// </summary>
    property IsUnsigned: Boolean read GetIsUnsigned;

    /// <summary>
    ///  The human readable name of the audio format.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  Get the appropriate `FillChar` value for silencing this audio format.
    ///
    ///  The value returned by this property can be used as the third argument to
    ///  `FillChar` to set an audio buffer in this format to silence.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property SilenceValue: Byte read GetSilenceValue;
  end;

type
  /// <summary>
  ///  Format specifier for audio data.
  /// </summary>
  /// <seealso cref="TSdlAudioFormat"/>
  TSdlAudioSpec = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AudioSpec;
    function GetFormat: TSdlAudioFormat; inline;
    procedure SetFormat(const AValue: TSdlAudioFormat); inline;
    function GetFrameSize: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Creates a new audion format specification.
    /// </summary>
    /// <param name="AFormat">Audio data format.</param>
    /// <param name="ANumChannels">Number of channels: 1 mono, 2 stereo, etc.</param>
    /// <param name="AFreq">Sample rate: sample frames per second.</param>
    constructor Create(const AFormat: TSdlAudioFormat; const ANumChannels,
      AFreq: Integer);

    /// <summary>
    ///  Audio data format
    /// </summary>
    property Format: TSdlAudioFormat read GetFormat write SetFormat;

    /// <summary>
    ///  Number of channels: 1 mono, 2 stereo, etc
    /// </summary>
    property NumChannels: Integer read FHandle.channels write FHandle.channels;

    /// <summary>
    ///  Sample rate: sample frames per second
    /// </summary>
    property Freq: Integer read FHandle.freq write FHandle.freq;

    /// <summary>
    ///  Calculate the size of each audio frame (in bytes).
    ///
    ///  This reports on the size of an audio sample frame: stereo Int16 data (2
    ///  channels of 2 bytes each) would be 4 bytes per frame, for example.
    /// </summary>
    property FrameSize: Integer read GetFrameSize;
  end;
  PSdlAudioSpec = ^TSdlAudioSpec;

type
  /// <summary>
  ///  SDL Audio Device instance IDs.
  ///
  ///  Zero is used to signify an invalid/null device.
  /// </summary>
  TSdlAudioDeviceID = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AudioDeviceID;
    function GetName: String; inline;
    function GetChannelMap: TArray<Integer>; inline;
    function GetIsPlaybackDevice: Boolean; inline;
    class function GetDefaultPlaybackDevice: TSdlAudioDeviceID; inline; static;
    class function GetDefaultRecordingDevice: TSdlAudioDeviceID; inline; static;
    class function GetPlaybackDevices: TArray<TSdlAudioDeviceID>; static;
    class function GetRecordingDevices: TArray<TSdlAudioDeviceID>; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAudioDeviceID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAudioDeviceID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlAudioDeviceID; inline; static;
  public
    /// <summary>
    ///  Get the device's preferred format (or a reasonable default if this
    ///  can't be determined).
    ///
    ///  You can also use this to request the current device buffer size. This is
    ///  specified in sample frames and represents the amount of data SDL will feed
    ///  to the physical hardware in each chunk. This can be converted to
    ///  milliseconds of audio with the following equation:
    ///
    ///  `ms = ((frames * 1000) / spec.freq);`
    ///
    ///  Buffer size is only important if you need low-level control over the audio
    ///  playback timing. Most apps do not need this.
    /// </summary>
    /// <param name="ASpec">Will be filled with device details.</param>
    /// <returns>The device buffer size, in sample frames.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function GetFormat(out ASpec: TSdlAudioSpec): Integer; inline;

    /// <summary>
    ///  The human-readable name of this audio device.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PlaybackDevices"/>
    /// <seealso cref="RecordingDevices"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  The current channel map.
    ///
    ///  Channel maps are optional; most things do not need them, instead passing
    ///  data in the order that SDL expects.
    ///
    ///  Audio devices usually have no remapping applied. This is represented by
    ///  returning nil, and does not signify an error.
    /// </summary>
    /// <seealso cref="TSdlAudioStream.InputChannelMap"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property ChannelMap: TArray<Integer> read GetChannelMap;

    /// <summary>
    ///  Whether this audio device is a playback device (instead of recording).
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property IsPlaybackDevice: Boolean read GetIsPlaybackDevice;

    /// <summary>
    ///  The default playback audio device ID.
    /// </summary>
    class property DefaultPlaybackDevice: TSdlAudioDeviceID read GetDefaultPlaybackDevice;

    /// <summary>
    ///  The default recording audio device ID.
    /// </summary>
    class property DefaultRecordingDevice: TSdlAudioDeviceID read GetDefaultRecordingDevice;

    /// <summary>
    ///  A list of currently-connected audio playback devices.
    ///
    ///  This returns of list of available devices that play sound, perhaps to
    ///  speakers or headphones ("playback" devices). If you want devices that
    ///  record audio, like a microphone ("recording" devices), use
    ///  RecordingDevices instead.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlAudioDevice.Open"/>
    /// <seealso cref="RecordingDevices"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property PlaybackDevices: TArray<TSdlAudioDeviceID> read GetPlaybackDevices;

    /// <summary>
    ///  A list of currently-connected audio recording devices.
    ///
    ///  This returns of list of available devices that record audio, like a
    ///  microphone ("recording" devices). If you want devices that play sound,
    ///  perhaps to speakers or headphones ("playback" devices), use
    ///  PlaybackDevices instead.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlAudioDevice.Open"/>
    /// <seealso cref="PlaybackDevices"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property RecordingDevices: TArray<TSdlAudioDeviceID> read GetRecordingDevices;
  end;

type
  /// <summary>
  ///  Represents an audio stream.
  ///
  ///  TSdlAudioStream is an audio conversion interface.
  ///
  ///  - It can handle resampling data in chunks without generating artifacts,
  ///    when it doesn't have the complete buffer available.
  ///  - It can handle incoming data in any variable size.
  ///  - It can handle input/output format changes on the fly.
  ///  - It can remap audio channels between inputs and outputs.
  ///  - You push data as you have it, and pull it when you need it
  ///  - It can also function as a basic audio data queue even if you just have
  ///    sound that needs to pass from one place to another.
  ///  - You can hook callbacks up to them when more data is added or requested,
  ///    to manage data on-the-fly.
  ///
  ///  Audio streams are the core of the SDL3 audio interface. You create one or
  ///  more of them, bind them to an opened audio device, and feed data to them
  ///  (or for recording, consume data from them).
  /// </summary>
  TSdlAudioStream = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AudioStream;
    function GetProperties: TSdlProperties; inline;
    function GetFrequencyRatio: Single; inline;
    procedure SetFrequencyRatio(const AValue: Single); inline;
    function GetGain: Single; inline;
    procedure SetGain(const AValue: Single); inline;
    function GetInputChannelMap: TArray<Integer>; inline;
    procedure SetInputChannelMap(const AValue: TArray<Integer>); inline;
    function GetOutputChannelMap: TArray<Integer>; inline;
    procedure SetOutputChannelMap(const AValue: TArray<Integer>); inline;
    function GetAvailable: Integer; inline;
    function GetQueued: Integer; inline;
    function GetIsPaused: Boolean; inline;
    procedure SetIsPaused(const AValue: Boolean); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAudioStream; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAudioStream; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlAudioStream; inline; static;
  public
    /// <summary>
    ///  Create a new audio stream.
    /// </summary>
    /// <param name="ASpec">The format details of the (input) audio.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PutData"/>
    /// <seealso cref="GetData"/>
    /// <seealso cref="Available"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="Clear"/>
    /// <seealso cref="SetFormat"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    constructor Create(const ASpec: TSdlAudioSpec); overload;

    /// <summary>
    ///  Create a new audio stream.
    /// </summary>
    /// <param name="ASrcSpec">The format details of the input audio.</param>
    /// <param name="ADstSpec">The format details of the output audio.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PutData"/>
    /// <seealso cref="GetData"/>
    /// <seealso cref="Available"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="Clear"/>
    /// <seealso cref="SetFormat"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    constructor Create(const ASrcSpec, ADstSpec: TSdlAudioSpec); overload;

    /// <summary>
    ///  Free the audio stream.
    ///
    ///  This will release all allocated data, including any audio that is still
    ///  queued. You do not need to manually clear the stream first.
    ///
    ///  If this stream was bound to an audio device, it is unbound during this
    ///  call. If this stream was created using a device, the audio device that
    ///  was opened alongside this stream's creation will be closed, too.
    /// </summary>
    /// <seealso cref="Create"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Unbinds this audio stream from its audio device.
    /// </summary>
    /// <seealso cref="TSdlAudioDevice.Bind"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Unbind; inline;

    /// <summary>
    ///  Query the current format of the stream.
    /// </summary>
    /// <param name="ASrcSpec">Where to store the input audio format,
    ///  or nil if not needed.</param>
    /// <param name="ADstSpec">Where to store the output audio format,
    ///  or nil if not needed.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetFormat"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure GetFormat(const ASrcSpec, ADstSpec: PSdlAudioSpec); inline;

    /// <summary>
    ///  Change the input and output formats of the audio stream.
    ///
    ///  Future calls to and Available and GetData will reflect the new format,
    ///  and future calls to PutData must provide data in the new input formats.
    ///
    ///  Data that was previously queued in the stream will still be operated on
    ///  in the format that was current when it was added, which is to say you
    ///  can put the end of a sound file in one format to a stream, change
    ///  formats for the next sound file, and start putting that new data while
    ///  the previous sound file is still queued, and everything will still play
    ///  back correctly.
    ///
    ///  If a stream is bound to a device, then the format of the side of the
    ///  stream bound to a device cannot be changed (ASrcSpec for recording
    ///  devices, ADstSpec for playback devices). Attempts to make a change to
    ///  this side will be ignored, but this will not report an error. The other
    ///  side's format can be changed.
    /// </summary>
    /// <param name="ASrcSpec">The new format of the audio input or nil to
    ///  leave it unchanged.</param>
    /// <param name="ADstSpec">The new format of the audio output or nil to
    ///  leave it unchanged.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetFormat"/>
    /// <seealso cref="FrequencyRatio"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure SetFormat(const ASrcSpec, ADstSpec: PSdlAudioSpec); inline;

    /// <summary>
    ///  Add data to the stream.
    ///
    ///  This data must match the format/channels/samplerate specified in the
    ///  latest call to SetFormat, or the format specified when creating the
    ///  stream if it hasn't been changed.
    ///
    ///  Note that this call simply copies the unconverted data for later. This is
    ///  different than SDL2, where data was converted during the Put call and the
    ///  Get call would just dequeue the previously-converted data.
    /// </summary>
    /// <param name="ABuffer">A pointer to the audio data to add.</param>
    /// <param name="ASize">The number of bytes to write to the stream.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Clear"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="GetData"/>
    /// <seealso cref="Queued"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, but if the stream has a
    ///  callback set, the caller might need to manage extra locking.
    /// </remarks>
    procedure PutData(const ABuffer: Pointer; const ASize: Integer); inline;

    /// <summary>
    ///  Get converted/resampled data from the stream.
    ///
    ///  The input/output data format/channels/samplerate is specified when
    ///  creating the stream, and can be changed after creation by setting
    ///  calling SetFormat.
    ///
    ///  Note that any conversion and resampling necessary is done during this call,
    ///  and PutData simply queues unconverted data for later. This is different
    ///  than SDL2, where that work was done while inputting new data to the
    ///  stream and requesting the output just copied the converted data.
    /// </summary>
    /// <param name="ABuffer">A buffer to fill with audio data.</param>
    /// <param name="ASize">The maximum number of bytes to fill.</param>
    /// <returns>The number of bytes read from the stream.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Clear"/>
    /// <seealso cref="Available"/>
    /// <seealso cref="PutData"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, but if the stream has a
    ///  callback set, the caller might need to manage extra locking.
    /// </remarks>
    function GetData(const ABuffer: Pointer; const ASize: Integer): Integer; inline;

    /// <summary>
    ///  Tell the stream that you're done sending data, and anything being buffered
    ///  should be converted/resampled and made available immediately.
    ///
    ///  It is legal to add more data to a stream after flushing, but there may be
    ///  audio gaps in the output. Generally this is intended to signal the end of
    ///  input, so the complete output becomes available.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PutData"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Flush; inline;

    /// <summary>
    ///  Clear any pending data in the stream.
    ///
    ///  This drops any queued data, so there will be nothing to read from the
    ///  stream until more is added.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Available"/>
    /// <seealso cref="GetData"/>
    /// <seealso cref="Queued"/>
    /// <seealso cref="PutData"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Clear; inline;

    /// <summary>
    ///  Pause audio playback on the audio device associated with this audio stream.
    ///
    ///  This method pauses audio processing for a given device. Any bound audio
    ///  streams will not progress, and no audio will be generated. Pausing one
    ///  device does not prevent other unpaused devices from running.
    ///
    ///  Pausing a device can be useful to halt all audio without unbinding all the
    ///  audio streams. This might be useful while a game is paused, or a level is
    ///  loading, etc.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Resume"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Pause; inline;

    /// <summary>
    ///  Unpause audio playback on the audio device associated with this audio stream.
    ///
    ///  This method unpauses audio processing for a given device that has
    ///  previously been paused. Once unpaused, any bound audio streams will begin
    ///  to progress again, and audio can be generated.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Pause"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Resume; inline;

    /// <summary>
    ///  Lock the audio stream for serialized access.
    ///
    ///  Each audio stream has an internal mutex it uses to protect its data
    ///  structures from threading conflicts. This function allows an app to lock
    ///  that mutex, which could be useful if registering callbacks on this stream.
    ///
    ///  One does not need to lock a stream to use in it most cases, as the stream
    ///  manages this lock internally. However, this lock is held during callbacks,
    ///  which may run from arbitrary threads at any time, so if an app needs to
    ///  protect shared data during those callbacks, locking the stream guarantees
    ///  that the callback is not running while the lock is held.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Unlock"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Lock; inline;

    /// <summary>
    ///  Unlock the audio stream for serialized access.
    ///
    ///  This unlocks an audio stream after a call to Lock.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Lock"/>
    /// <remarks>
    ///  You should only call this from the same thread that previously called
    ///  Lock.
    /// </remarks>
    procedure Unlock; inline;

    /// <summary>
    ///  The frequency ratio of the audio stream.
    ///
    ///  The frequency ratio is used to adjust the rate at which input data is
    ///  consumed. Changing this effectively modifies the speed and pitch of the
    ///  audio. A value greater than 1.0 will play the audio faster, and at a higher
    ///  pitch. A value less than 1.0 will play the audio slower, and at a lower
    ///  pitch.
    ///
    ///  This is applied during GetData, and can be continuously changed to
    ///  create various effects.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property FrequencyRatio: Single read GetFrequencyRatio write SetFrequencyRatio;

    /// <summary>
    ///  The gain of an audio stream.
    ///
    ///  The gain of a stream is its volume; a larger gain means a louder output,
    ///  with a gain of zero being silence.
    ///
    ///  Audio streams default to a gain of 1.0 (no change in output).
    ///
    ///  This is applied during GetData, and can be continuously changed to
    ///  create various effects.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Gain: Single read GetGain write SetGain;

    /// <summary>
    ///  Get the current input channel map of the audio stream.
    ///
    ///  Channel maps are optional; most things do not need them, instead passing
    ///  data in the order that SDL expects.
    ///
    ///  Audio streams default to no remapping applied. This is represented by
    ///  returning nil, and does not signify an error.
    ///
    ///  The input channel map reorders data that is added to a stream via
    ///  PutData. Future calls to PutData must provide data in the new channel
    ///  order.
    ///
    ///  Each item in the array represents an input channel, and its value is the
    ///  channel that it should be remapped to. To reverse a stereo signal's left
    ///  and right values, you'd have an array of `{ 1, 0 }`. It is legal to remap
    ///  multiple channels to the same thing, so `{ 1, 1 }` would duplicate the
    ///  right channel to both channels of a stereo signal. An element in the
    ///  channel map set to -1 instead of a valid channel will mute that channel,
    ///  setting it to a silence value.
    ///
    ///  You cannot change the number of channels through a channel map, just
    ///  reorder/mute them.
    ///
    ///  Data that was previously queued in the stream will still be operated on in
    ///  the order that was current when it was added, which is to say you can put
    ///  the end of a sound file in one order to a stream, change orders for the
    ///  next sound file, and start putting that new data while the previous sound
    ///  file is still queued, and everything will still play back correctly.
    ///
    ///  Audio streams default to no remapping applied. Passing a nil channel map
    ///  is legal, and turns off remapping.
    ///
    ///  If the length of the array is not equal to the current number of
    ///  channels in the audio stream's format, this will fail. This is a safety
    ///  measure to make sure a race condition hasn't changed the format while
    ///  this call is setting the channel map.
    ///
    ///  Unlike attempting to change the stream's format, the input channel map on a
    ///  stream bound to a recording device is permitted to change at any time; any
    ///  data added to the stream from the device after this call will have the new
    ///  mapping, but previously-added data will still have the prior mapping.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property InputChannelMap: TArray<Integer> read GetInputChannelMap write SetInputChannelMap;

    /// <summary>
    ///  Get the current output channel map of the audio stream.
    ///
    ///  Channel maps are optional; most things do not need them, instead passing
    ///  data in the order that SDL expects.
    ///
    ///  Audio streams default to no remapping applied. This is represented by
    ///  returning nil, and does not signify an error.
    ///
    ///  The output channel map reorders data that leaving a stream via GetData.
    ///
    ///  Each item in the array represents an input channel, and its value is the
    ///  channel that it should be remapped to. To reverse a stereo signal's left
    ///  and right values, you'd have an array of `{ 1, 0 }`. It is legal to remap
    ///  multiple channels to the same thing, so `{ 1, 1 }` would duplicate the
    ///  right channel to both channels of a stereo signal. An element in the
    ///  channel map set to -1 instead of a valid channel will mute that channel,
    ///  setting it to a silence value.
    ///
    ///  You cannot change the number of channels through a channel map, just
    ///  reorder/mute them.
    ///
    ///  The output channel map can be changed at any time, as output remapping is
    ///  applied during GetData.
    ///
    ///  Audio streams default to no remapping applied. Passing a nil channel map
    ///  is legal, and turns off remapping.
    ///
    ///  If the length of the array is not equal to the current number of
    ///  channels in the audio stream's format, this will fail. This is a safety
    ///  measure to make sure a race condition hasn't changed the format while
    ///  this call is setting the channel map.
    ///
    ///  Unlike attempting to change the stream's format, the output channel map on
    ///  a stream bound to a recording device is permitted to change at any time;
    ///  any data added to the stream after this call will have the new mapping, but
    ///  previously-added data will still have the prior mapping. When the channel
    ///  map doesn't match the hardware's channel layout, SDL will convert the data
    ///  before feeding it to the device for playback.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property OutputChannelMap: TArray<Integer> read GetOutputChannelMap write SetOutputChannelMap;

    /// <summary>
    ///  The number of converted/resampled bytes available.
    ///
    ///  The stream may be buffering data behind the scenes until it has enough to
    ///  resample correctly, so this number might be lower than what you expect, or
    ///  even be zero. Add more data or flush the stream if you need the data now.
    ///
    ///  If the stream has so much data that it would overflow an int, the return
    ///  value is clamped to a maximum value, but no queued data is lost; if there
    ///  are gigabytes of data queued, the app might need to read some of it with
    ///  GetData before this function's return value is no longer clamped.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetData"/>
    /// <seealso cref="PutData"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Available: Integer read GetAvailable;

    /// <summary>
    ///  Get the number of bytes currently queued.
    ///
    ///  This is the number of bytes put into a stream as input, not the number that
    ///  can be retrieved as output. Because of several details, it's not possible
    ///  to calculate one number directly from the other. If you need to know how
    ///  much usable data can be retrieved right now, you should use Available.
    ///
    ///  Note that audio streams can change their input format at any time, even if
    ///  there is still data queued in a different format, so the returned byte
    ///  count will not necessarily match the number of _sample frames_ available.
    ///  Users of this API should be aware of format changes they make when feeding
    ///  a stream and plan accordingly.
    ///
    ///  Queued data is not converted until it is consumed by GetData, so this
    ///  value should be representative of the exact data that was put into the
    ///  stream.
    ///
    ///  If the stream has so much data that it would overflow an int, the return
    ///  value is clamped to a maximum value, but no queued data is lost; if there
    ///  are gigabytes of data queued, the app might need to read some of it with
    ///  GetData before this function's return value is no longer clamped.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PutData"/>
    /// <seealso cref="Clear"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Queued: Integer read GetQueued;

    /// <summary>
    ///  Whether the audio device associated with a stream is paused.
    ///
    ///  Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    ///  has to bind a stream before any audio will flow.
    ///
    ///  You can also set this property to pause/unpause the stream.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Pause"/>
    /// <seealso cref="Resume"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property IsPaused: Boolean read GetIsPaused write SetIsPaused;

    /// <summary>
    ///  The properties associated with an audio stream.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;

type
  /// <summary>
  ///  A callback that fires when data is about to be fed to an audio device.
  ///
  ///  This is useful for accessing the final mix, perhaps for writing a
  ///  visualizer or applying a final effect to the audio data before playback.
  ///
  ///  This callback should run as quickly as possible and not block for any
  ///  significant time, as this callback delays submission of data to the audio
  ///  device, which can cause audio playback problems.
  ///
  ///  The postmix callback _must_ be able to handle any audio data format
  ///  specified in `ASpec`, which can change between callbacks if the audio device
  ///  changed. However, this only covers frequency and channel count; data is
  ///  always provided here in TSdlAudioFormat.F32 format.
  ///
  ///  The postmix callback runs _after_ logical device gain and audiostream gain
  ///  have been applied, which is to say you can make the output data louder at
  ///  this point than the gain settings would suggest.
  /// </summary>
  /// <param name="AUserData">A pointer provided by the app through
  ///  TSdlAudioDevice.SetPostmixCallback, for its own use.</param>
  /// <param name="ASpec">The current format of audio that is to be submitted to
  ///  the audio device.</param>
  /// <param name="ABuffer">The buffer of audio samples to be submitted.
  ///  The callback can inspect and/or modify this data.</param>
  /// <param name="ASize">The size of `ABuffer` in bytes.</param>
  /// <seealso cref="TSdlAudioDevice.SetPostmixCallback"/>
  /// <remarks>
  ///  This will run from a background thread owned by SDL. The application is
  ///  responsible for locking resources the callback touches that need to be
  ///  protected.
  /// </remarks>
  TSdlAudioPostmixCallback = procedure(AUserData: Pointer;
    const ASpec: PSdlAudioSpec; ABuffer: PSingle; ASize: Integer); cdecl;

type
  /// <summary>
  ///  SDL Audio Device.
  /// </summary>
  TSdlAudioDevice = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AudioDeviceID;
    function GetChannelMap: TArray<Integer>; inline;
    function GetIsPlaybackDevice: Boolean; inline;
    function GetIsPaused: Boolean; inline;
    procedure SetIsPaused(const AValue: Boolean); inline;
    function GetGain: Single; inline;
    procedure SetGain(const AValue: Single); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAudioDevice; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAudioDevice; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlAudioDevice; inline; static;
  public
    /// <summary>
    ///  Open a specific audio device.
    ///
    ///  You can open both playback and recording devices through this method.
    ///  Playback devices will take data from bound audio streams, mix it, and send
    ///  it to the hardware. Recording devices will feed any bound audio streams
    ///  with a copy of any incoming data.
    ///
    ///  An opened audio device starts out with no audio streams bound. To start
    ///  audio playing, bind a stream and supply audio data to it. Unlike SDL2,
    ///  there is no audio callback; you only bind audio streams and make sure they
    ///  have data flowing into them (however, you can simulate SDL2's semantics
    ///  fairly closely by using TSdlAudioStream.Open instead of this method).
    ///
    ///  If you don't care about opening a specific device, pass a `ADeviceID`
    ///  of either `TSdlAudioDeviceID.DefaultPlaybackDevice` or
    ///  `TSdlAudioDeviceID.DefaultRecordingDevice`. In this case, SDL will try
    ///  to pick the most reasonable default, and may also switch between
    ///  physical devices seamlessly later, if the most reasonable default
    ///  changes during the lifetime of this opened device (user changed the
    ///  default in the OS's system preferences, the default got unplugged so
    ///  the system jumped to a new default, the user plugged in headphones on a
    ///  mobile device, etc). Unless you have a good reason to choose a specific
    ///  device, this is probably what you want.
    ///
    ///  It's legal to open the same device ID more than once; each successful open
    ///  will generate a new logical audio device that is managed separately
    ///  from others on the same physical device. This allows libraries to open a
    ///  device separately from the main app and bind its own streams without
    ///  conflicting.
    ///
    ///  Some backends might offer arbitrary devices (for example, a networked audio
    ///  protocol that can connect to an arbitrary server). For these, as a change
    ///  from SDL2, you should open a default device ID and use an SDL hint to
    ///  specify the target if you care, or otherwise let the backend figure out a
    ///  reasonable default. Most backends don't offer anything like this, and often
    ///  this would be an end user setting an environment variable for their custom
    ///  need, and not something an application should specifically manage.
    ///
    ///  When done with an audio device, possibly at the end of the app's life, one
    ///  should call Close.
    /// </summary>
    /// <param name="ADeviceID">The device instance id to open, or
    ///  TSdlAudioDeviceID.DefaultPlaybackDevice or
    ///  TSdlAudioDeviceID.DefaultRecordingDevice for the most reasonable default
    ///  device.</param>
    /// <returns>The audio device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    /// <seealso cref="TSdlAudioDeviceID.GetFormat"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    class function Open(const ADeviceID: TSdlAudioDeviceID): TSdlAudioDevice; overload; inline; static;

    /// <summary>
    ///  Open a specific audio device.
    ///
    ///  You can open both playback and recording devices through this method.
    ///  Playback devices will take data from bound audio streams, mix it, and send
    ///  it to the hardware. Recording devices will feed any bound audio streams
    ///  with a copy of any incoming data.
    ///
    ///  An opened audio device starts out with no audio streams bound. To start
    ///  audio playing, bind a stream and supply audio data to it. Unlike SDL2,
    ///  there is no audio callback; you only bind audio streams and make sure they
    ///  have data flowing into them (however, you can simulate SDL2's semantics
    ///  fairly closely by using TSdlAudioStream.Open instead of this method).
    ///
    ///  If you don't care about opening a specific device, pass a `ADeviceID`
    ///  of either `TSdlAudioDeviceID.DefaultPlaybackDevice` or
    ///  `TSdlAudioDeviceID.DefaultRecordingDevice`. In this case, SDL will try
    ///  to pick the most reasonable default, and may also switch between
    ///  physical devices seamlessly later, if the most reasonable default
    ///  changes during the lifetime of this opened device (user changed the
    ///  default in the OS's system preferences, the default got unplugged so
    ///  the system jumped to a new default, the user plugged in headphones on a
    ///  mobile device, etc). Unless you have a good reason to choose a specific
    ///  device, this is probably what you want.
    ///
    ///  You may request a specific format for the audio device, but there is no
    ///  promise the device will honor that request for several reasons. As such,
    ///  it's only meant to be a hint as to what data your app will provide. Audio
    ///  streams will accept data in whatever format you specify and manage
    ///  conversion for you as appropriate. TSdlAudioDeviceID.GetFormat can tell
    ///  you the preferred format for the device before opening and the actual
    ///  format the device is using after opening.
    ///
    ///  It's legal to open the same device ID more than once; each successful open
    ///  will generate a new logical audio device that is managed separately
    ///  from others on the same physical device. This allows libraries to open a
    ///  device separately from the main app and bind its own streams without
    ///  conflicting.
    ///
    ///  Some backends might offer arbitrary devices (for example, a networked audio
    ///  protocol that can connect to an arbitrary server). For these, as a change
    ///  from SDL2, you should open a default device ID and use an SDL hint to
    ///  specify the target if you care, or otherwise let the backend figure out a
    ///  reasonable default. Most backends don't offer anything like this, and often
    ///  this would be an end user setting an environment variable for their custom
    ///  need, and not something an application should specifically manage.
    ///
    ///  When done with an audio device, possibly at the end of the app's life, one
    ///  should call Close.
    /// </summary>
    /// <param name="ADeviceID">The device instance id to open, or
    ///  TSdlAudioDeviceID.DefaultPlaybackDevice or
    ///  TSdlAudioDeviceID.DefaultRecordingDevice for the most reasonable default
    ///  device.</param>
    /// <param name="ASpec">The requested device configuration.</param>
    /// <returns>The audio device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    /// <seealso cref="TSdlAudioDeviceID.GetFormat"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    class function Open(const ADeviceID: TSdlAudioDeviceID;
      const ASpec: TSdlAudioSpec): TSdlAudioDevice; overload; inline; static;

    /// <summary>
    ///  Open a device from a previously opened device. This just creates
    ///  another logical device on the same physical device. This may be useful
    ///  for making logical groupings of audio streams.
    ///
    ///  An opened audio device starts out with no audio streams bound. To start
    ///  audio playing, bind a stream and supply audio data to it. Unlike SDL2,
    ///  there is no audio callback; you only bind audio streams and make sure they
    ///  have data flowing into them (however, you can simulate SDL2's semantics
    ///  fairly closely by using TSdlAudioStream.Open instead of this method).
    ///
    ///  When done with an audio device, possibly at the end of the app's life, one
    ///  should call Close.
    /// </summary>
    /// <param name="ADevice">The previously opened device.</param>
    /// <param name="ASpec">The requested device configuration.</param>
    /// <returns>The audio device.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    class function Open(const ADevice: TSdlAudioDevice): TSdlAudioDevice; overload; inline; static;

    /// <summary>
    ///  Close a previously-opened audio device.
    ///
    ///  The application should close open audio devices once they are no longer
    ///  needed.
    ///
    ///  This function may block briefly while pending audio data is played by the
    ///  hardware, so that applications don't drop the last buffer of data they
    ///  supplied if terminating immediately afterwards.
    /// </summary>
    /// <seealso cref="Open"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Close; inline;

    /// <summary>
    ///  Get audio format this device is currently using.
    ///
    ///  You can also use this to request the current device buffer size. This is
    ///  specified in sample frames and represents the amount of data SDL will feed
    ///  to the physical hardware in each chunk. This can be converted to
    ///  milliseconds of audio with the following equation:
    ///
    ///  `ms = ((frames * 1000) / spec.freq);`
    ///
    ///  Buffer size is only important if you need low-level control over the audio
    ///  playback timing. Most apps do not need this.
    /// </summary>
    /// <param name="ASpec">Will be filled with device details.</param>
    /// <returns>The device buffer size, in sample frames.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function GetFormat(out ASpec: TSdlAudioSpec): Integer; inline;

    /// <summary>
    ///  Pause audio playback on the device.
    ///
    ///  This method pauses audio processing for the device. Any bound audio
    ///  streams will not progress, and no audio will be generated. Pausing one
    ///  device does not prevent other unpaused devices from running.
    ///
    ///  Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    ///  has to bind a stream before any audio will flow. Pausing a paused device is
    ///  a legal no-op.
    ///
    ///  Pausing a device can be useful to halt all audio without unbinding all the
    ///  audio streams. This might be useful while a game is paused, or a level is
    ///  loading, etc.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Resume"/>
    /// <seealso cref="IsPaused"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Pause; inline;

    /// <summary>
    ///  Use this method to unpause audio playback on a specified device.
    ///
    ///  This function unpauses audio processing for a given device that has
    ///  previously been paused with Pause. Once unpaused, any bound audio
    ///  streams will begin to progress again, and audio can be generated.
    ///
    ///  Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    ///  has to bind a stream before any audio will flow. Unpausing an unpaused
    ///  device is a legal no-op.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsPaused"/>
    /// <seealso cref="Pause"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Resume; inline;

    /// <summary>
    ///  Bind a list of audio streams to an audio device.
    ///
    ///  Audio data will flow through any bound streams. For a playback device, data
    ///  for all bound streams will be mixed together and fed to the device. For a
    ///  recording device, a copy of recorded data will be provided to each bound
    ///  stream.
    ///
    ///  This operation is atomic--all streams bound in the same call will start
    ///  processing at the same time, so they can stay in sync. Also: either all
    ///  streams will be bound or none of them will be.
    ///
    ///  It is an error to bind an already-bound stream; it must be explicitly
    ///  unbound first.
    ///
    ///  Binding a stream to a device will set its output format for playback
    ///  devices, and its input format for recording devices, so they match the
    ///  device's settings. The caller is welcome to change the other end of the
    ///  stream's format at any time with TSdlAudioStream.Format.
    /// </summary>
    /// <param name="AStreams">The array of audio streams to bind.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Unbind"/>
    /// <seealso cref="TSdlAudioStream.Device"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Bind(const AStreams: TArray<TSdlAudioStream>); overload; inline;

    /// <summary>
    ///  Bind a single audio stream to an audio device.
    ///
    ///  This is a convenience method, equivalent to calling the other
    ///  overload with an array containing 1 stream.
    /// </summary>
    /// <param name="AStream">The audio stream to bind to a device.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Unbind"/>
    /// <seealso cref="TSdlAudioStream.Device"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Bind(const AStream: TSdlAudioStream); overload; inline;

    /// <summary>
    ///  Unbind a list of audio streams from their audio devices.
    ///
    ///  The streams being unbound do not all have to be on the same device. All
    ///  streams on the same device will be unbound atomically (data will stop
    ///  flowing through all unbound streams on the same device at the same time).
    ///
    ///  Unbinding a stream that isn't bound to a device is a legal no-op.
    /// </summary>
    /// <param name="AStreams">An array of audio streams to unbind.</param>
    /// <seealso cref="Bind"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    class procedure Unbind(const AStreams: TArray<TSdlAudioStream>); overload; inline; static;

    /// <summary>
    ///  Unbind a single audio stream from its audio device.
    ///
    ///  This is a convenience method, equivalent to calling the other
    ///  overload with an array containing 1 stream.
    /// </summary>
    /// <param name="AStream">The audio stream to unbind.</param>
    /// <seealso cref="Bind"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    class procedure Unbind(const AStream: TSdlAudioStream); overload; inline; static;

    /// <summary>
    ///  Set a callback that fires when data is about to be fed to an audio device.
    ///
    ///  This is useful for accessing the final mix, perhaps for writing a
    ///  visualizer or applying a final effect to the audio data before playback.
    ///
    ///  The buffer is the final mix of all bound audio streams on an opened device;
    ///  this callback will fire regularly for any device that is both opened and
    ///  unpaused. If there is no new data to mix, either because no streams are
    ///  bound to the device or all the streams are empty, this callback will still
    ///  fire with the entire buffer set to silence.
    ///
    ///  This callback is allowed to make changes to the data; the contents of the
    ///  buffer after this call is what is ultimately passed along to the hardware.
    ///
    ///  The callback is always provided the data in float format (values from -1.0
    ///  to 1.0), but the number of channels or sample rate may be different than
    ///  the format the app requested when opening the device; SDL might have had to
    ///  manage a conversion behind the scenes, or the playback might have jumped to
    ///  new physical hardware when a system default changed, etc. These details may
    ///  change between calls. Accordingly, the size of the buffer might change
    ///  between calls as well.
    ///
    ///  This callback can run at any time, and from any thread; if you need to
    ///  serialize access to your app's data, you should provide and use a mutex or
    ///  other synchronization device.
    ///
    ///  All of this to say: there are specific needs this callback can fulfill, but
    ///  it is not the simplest interface. Apps should generally provide audio in
    ///  their preferred format through an TSdlAudioStream and let SDL handle the
    ///  difference.
    ///
    ///  This function is extremely time-sensitive; the callback should do the least
    ///  amount of work possible and return as quickly as it can. The longer the
    ///  callback runs, the higher the risk of audio dropouts or other problems.
    ///
    ///  This function will block until the audio device is in between iterations,
    ///  so any existing callback that might be running will finish before this
    ///  function sets the new callback and returns.
    ///
    ///  Setting a nil callback function disables any previously-set callback.
    /// </summary>
    /// <param name="ACallback">A callback function to be called. Can be nil.</param>
    /// <param name="AUserData">App-controlled pointer passed to callback. Can be nil.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure SetPostmixCallback(const ACallback: TSdlAudioPostmixCallback;
      const AUserData: Pointer); inline;

    /// <summary>
    ///  The current channel map.
    ///
    ///  Channel maps are optional; most things do not need them, instead passing
    ///  data in the order that SDL expects.
    ///
    ///  Audio devices usually have no remapping applied. This is represented by
    ///  returning nil, and does not signify an error.
    /// </summary>
    /// <seealso cref="TSdlAudioStream.InputChannelMap"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property ChannelMap: TArray<Integer> read GetChannelMap;

    /// <summary>
    ///  Whether this audio device is a playback device (instead of recording).
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property IsPlaybackDevice: Boolean read GetIsPlaybackDevice;

    /// <summary>
    ///  Whether the audio device is paused.
    ///
    ///  Unlike in SDL2, audio devices start in an _unpaused_ state, since an app
    ///  has to bind a stream before any audio will flow.
    ///
    ///  You can also set this property to pause/unpause the device.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Pause"/>
    /// <seealso cref="Resume"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property IsPaused: Boolean read GetIsPaused write SetIsPaused;

    /// <summary>
    ///  The gain of the audio device.
    ///
    ///  The gain of a device is its volume; a larger gain means a louder output,
    ///  with a gain of zero being silence.
    ///
    ///  Audio devices default to a gain of 1.0 (no change in output).
    ///
    ///  This is applied, along with any per-audiostream gain, during playback to
    ///  the hardware, and can be continuously changed to create various effects. On
    ///  recording devices, this will adjust the gain before passing the data into
    ///  an audiostream; that recording audiostream can then adjust its gain further
    ///  when outputting the data elsewhere, if it likes, but that second gain is
    ///  not applied until the data leaves the audiostream again.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Gain: Single read GetGain write SetGain;
  end;

type
  /// <summary>
  ///  A callback that fires when data passes through a TSdlAudioStream.
  ///
  ///  Apps can (optionally) register a callback with an audio stream that is
  ///  called when data is added with TSdlAudioStream.PutData, or requested with
  ///  TSdlAudioStream.GetData.
  ///
  ///  Two values are offered here: one is the amount of additional data needed to
  ///  satisfy the immediate request (which might be zero if the stream already
  ///  has enough data queued) and the other is the total amount being requested.
  ///  In a Get call triggering a Put callback, these values can be different. In
  ///  a Put call triggering a Get callback, these values are always the same.
  ///
  ///  Byte counts might be slightly overestimated due to buffering or resampling,
  ///  and may change from call to call.
  ///
  ///  This callback is not required to do anything. Generally this is useful for
  ///  adding/reading data on demand, and the app will often put/get data as
  ///  appropriate, but the system goes on with the data currently available to it
  ///  if this callback does nothing.
  /// </summary>
  /// <param name="AUserdata">An opaque pointer provided by the app for their
  ///  personal use.</param>
  /// <param name="AStream">The SDL audio stream associated with this callback.</param>
  /// <param name="AAdditionalAmount">The amount of data, in bytes,
  ///  that is needed right now.</param>
  /// <param name="ATotalAmount">The total amount of data requested, in bytes,
  ///  that is requested or available.</param>
  /// <seealso cref="SDL_SetAudioStreamGetCallback"/>
  /// <seealso cref="SDL_SetAudioStreamPutCallback"/>
  /// <remarks>
  ///  This callback may run from any thread, so if you need to protect shared
  ///  data, you should use TSdlAudioStream.Lock to serialize access; this lock
  ///  will be held before your callback is called, so your callback does not
  ///  need to manage the lock explicitly.
  /// </remarks>
  TSdlAudioStreamCallback = procedure(AUserData: Pointer;
    AStream: TSdlAudioStream; AAdditionalAmount, ATotalAmount: Integer); cdecl;

type
  _TSdlAudioStreamHelper = record helper for TSdlAudioStream
  {$REGION 'Internal Declarations'}
  private
    function GetDevice: TSdlAudioDevice;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Convenience constructor for straightforward audio init for the common case.
    ///
    ///  If all your app intends to do is provide a single source of PCM audio, this
    ///  constructor allows you to do all your audio setup in a single call.
    ///
    ///  This is also intended to be a clean means to migrate apps from SDL2.
    ///
    ///  This constructor will open an audio device, create a stream and bind it.
    ///  Unlike other methods of setup, the audio device will be closed when this
    ///  stream is destroyed, so the app can treat the returned stream as
    ///  the only object needed to manage audio playback.
    ///
    ///  Also unlike other functions, the audio device begins paused. This is to map
    ///  more closely to SDL2-style behavior, since there is no extra step here to
    ///  bind a stream to begin audio flowing. The audio device should be resumed
    ///  with `Resume`.
    ///
    ///  This constructor works with both playback and recording devices.
    ///
    ///  The `ASpec` parameter represents the app's side of the audio stream. That
    ///  is, for recording audio, this will be the output format, and for playing
    ///  audio, this will be the input format. If spec is nil, the system will
    ///  choose the format, and the app can use GetFormat to obtain this
    ///  information later.
    ///
    ///  If you don't care about opening a specific audio device, you can (and
    ///  probably _should_), use TSdlAudioDeviceID.DefaultPlaybackDevice for
    ///  playback and TSdlAudioDeviceID.DefaultRecordingDevice for recording.
    ///
    ///  One can optionally provide a callback function; if nil, the app is
    ///  expected to queue audio data for playback (or unqueue audio data if
    ///  capturing). Otherwise, the callback will begin to fire once the device is
    ///  unpaused.
    ///
    ///  Destroying the returned stream with Free will also close
    ///  the audio device associated with this stream.
    /// </summary>
    /// <param name="ADeviceID">An audio device to open, or
    ///  TSdlAudioDeviceID.DefaultPlaybackDevice or
    ///  TSdlAudioDeviceID.DefaultRecordingDevice.</param>
    /// <param name="ASpec">(Optional) Audio stream's data format. Can be nil.</param>
    /// <param name="ACallback">(Optional) Callback where the app will provide
    ///  new data for playback, or receive new data for recording. Can be nil,
    ///  in which case the app will need to call PutData or GetData as necessary.</param>
    /// <param name="AUserData">(Optional) App-controlled pointer passed to callback.
    ///  Can be nil. Ignored if callback is nil.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Resume"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    constructor Create(const ADeviceID: TSdlAudioDeviceID;
      const ASpec: PSdlAudioSpec = nil;
      const ACallback: TSdlAudioStreamCallback = nil;
      const AUserData: Pointer = nil); overload;

    /// <summary>
    ///  Set a callback that runs when data is requested from an audio stream.
    ///
    ///  This callback is called _before_ data is obtained from the stream, giving
    ///  the callback the chance to add more on-demand.
    ///
    ///  The callback can (optionally) call PutData to add more audio to the
    ///  stream during this call; if needed, the request that triggered
    ///  this callback will obtain the new data immediately.
    ///
    ///  The callback's `AAdditionalAmount` argument is roughly how many bytes of
    ///  _unconverted_ data (in the stream's input format) is needed by the caller,
    ///  although this may overestimate a little for safety. This takes into account
    ///  how much is already in the stream and only asks for any extra necessary to
    ///  resolve the request, which means the callback may be asked for zero bytes,
    ///  and a different amount on each call.
    ///
    ///  The callback is not required to supply exact amounts; it is allowed to
    ///  supply too much or too little or none at all. The caller will get what's
    ///  available, up to the amount they requested, regardless of this callback's
    ///  outcome.
    ///
    ///  Clearing or flushing an audio stream does not call this callback.
    ///
    ///  This function obtains the stream's lock, which means any existing callback
    ///  (get or put) in progress will finish running before setting the new
    ///  callback.
    ///
    ///  Setting a nil function turns off the callback.
    /// </summary>
    /// <param name="ACallback">The new callback function to call when data is
    ///  requested from the stream.</param>
    /// <param name="AUserData">An opaque pointer provided to the callback for
    ///  its own personal use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetPutCallback"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure SetGetCallback(const ACallback: TSdlAudioStreamCallback;
      const AUserData: Pointer); inline;

    /// <summary>
    ///  Set a callback that runs when data is added to an audio stream.
    ///
    ///  This callback is called _after_ the data is added to the stream, giving the
    ///  callback the chance to obtain it immediately.
    ///
    ///  The callback can (optionally) call GetData to obtain audio from the
    ///  stream during this call.
    ///
    ///  The callback's `AAdditionalAmount` argument is how many bytes of _converted_
    ///  data (in the stream's output format) was provided by the caller, although
    ///  this may underestimate a little for safety. This value might be less than
    ///  what is currently available in the stream, if data was already there, and
    ///  might be less than the caller provided if the stream needs to keep a buffer
    ///  to aid in resampling. Which means the callback may be provided with zero
    ///  bytes, and a different amount on each call.
    ///
    ///  The callback may use Available to see the total amount currently
    ///  available to read from the stream, instead of the total provided
    ///  by the current call.
    ///
    ///  The callback is not required to obtain all data. It is allowed to read less
    ///  or none at all. Anything not read now simply remains in the stream for
    ///  later access.
    ///
    ///  Clearing or flushing an audio stream does not call this callback.
    ///
    ///  This function obtains the stream's lock, which means any existing callback
    ///  (get or put) in progress will finish running before setting the new
    ///  callback.
    ///
    ///  Setting a nil function turns off the callback.
    /// </summary>
    /// <param name="ACallback">The new callback function to call when data is
    ///  added to the stream.</param>
    /// <param name="AUserData">an opaque pointer provided to the callback for
    ///  its own personal use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetGetCallback"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure SetPutCallback(const ACallback: TSdlAudioStreamCallback;
      const AUserData: Pointer); inline;

    /// <summary>
    ///  The currently-bound device of the stream
    ///
    ///  This reports the audio device that an audio stream is currently bound to.
    ///
    ///  If not bound, or invalid, this returns zero, which is not a valid device
    ///  ID.
    /// </summary>
    /// <seealso cref="TSdlAudioDevice.Bind"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Device: TSdlAudioDevice read GetDevice;
  end;

type
  /// <summary>
  ///  A buffer that holds audio data in a specific format
  /// </summary>
  TSdlAudioBuffer = record
  {$REGION 'Internal Declarations'}
  private
    FSpec: TSdlAudioSpec;
    FBuffer: Pointer;
    FSize: Integer;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Creates a new audio buffer.
    ///
    ///  When the application is done with this buffer, it should call Free to
    ///  dispose of it.
    /// </summary>
    /// <param name="AFormat">The format of the audio in the buffer.</param>
    /// <param name="ASize">The size in bytes of the buffer to create.</param>
    /// <param name="ANumChannels">The number of audio channels.</param>
    /// <param name="AFreq">The sample frequency in Hz.</param>
    /// <seealso cref="Free"/>
    constructor Create(const AFormat: TSdlAudioFormat; const ASize,
      ANumChannels, AFreq: Integer); overload;

    /// <summary>
    ///  Creates a buffer from another buffer and converts it to the given
    ///  format if needed.
    ///
    ///  Please note that this constructor is for convenience, but should not be used
    ///  to resample audio in blocks, as it will introduce audio artifacts on the
    ///  boundaries. You should only use this constructor if you are converting audio
    ///  data in its entirety in one call. If you want to convert audio in smaller
    ///  chunks, use an TSDlAudioStream, which is designed for this situation.
    ///
    ///  Internally, this function creates and destroys an TSdlAudioStream on each
    ///  use, so it's also less efficient than using one directly, if you need to
    ///  convert multiple times.
    ///
    ///  When the application is done with this buffer, it should call Free to
    ///  dispose of it.
    /// </summary>
    /// <param name="AFormat">The format of the audio in this buffer.</param>
    /// <param name="ANumChannels">The number of audio channels for this buffer.</param>
    /// <param name="AFreq">The sample frequency in Hz for this buffer.</param>
    /// <param name="ASrc">The input audio buffer that will be converted.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    constructor Create(const AFormat: TSdlAudioFormat; const ANumChannels,
      AFreq: Integer; const ASrc: TSdlAudioBuffer); overload;

    /// <summary>
    ///  Load the audio data of a WAVE file into this buffer.
    ///
    ///  Supported formats are RIFF WAVE files with the formats PCM (8, 16, 24, and
    ///  32 bits), IEEE Float (32 bits), Microsoft ADPCM and IMA ADPCM (4 bits), and
    ///  A-law and mu-law (8 bits). Other formats are currently unsupported and
    ///  cause an error.
    ///
    ///  It's necessary to use Free to free this buffer when it is no longer used.
    ///
    ///  Because of the underspecification of the .WAV format, there are many
    ///  problematic files in the wild that cause issues with strict decoders. To
    ///  provide compatibility with these files, this decoder is lenient in regards
    ///  to the truncation of the file, the fact chunk, and the size of the RIFF
    ///  chunk. The hints `TSdlHints.WaveRiffChunkSize`, `TSdlHints.WaveTruncation`,
    ///  and `TSdlHints.WaveFactChunk` can be used to tune the behavior of the
    ///  loading process.
    ///
    ///  Any file that is invalid (due to truncation, corruption, or wrong values in
    ///  the headers), too big, or unsupported causes an error. Additionally, any
    ///  critical I/O error from the data source will terminate the loading process
    ///  with an error.
    ///
    ///  It is required that the data source supports seeking.
    ///
    ///  This constructor raises an error if the .WAV file cannot be opened, uses an
    ///  unknown data format, or is corrupt.
    ///
    ///  When the application is done with this buffer, it should call Free to
    ///  dispose of it.
    /// </summary>
    /// <param name="ASrc">The data source for the WAVE data.</param>
    /// <param name="ACloseIO">If True, calls TSdlIOStream.Close on `ASrc` before
    ///  returning, even in the case of an error.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    constructor CreateFromWav(const ASrc: TSdlIOStream; const ACloseIO: Boolean); overload;

    /// <summary>
    ///  Loads a WAV from a file path.
    ///
    ///  This constructor raises an error if the .WAV file cannot be opened, uses an
    ///  unknown data format, or is corrupt.
    ///
    ///  When the application is done with this buffer, it should call Free to
    ///  dispose of it.
    /// </summary>
    /// <param name="APath">The file path of the WAV file to open.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    constructor CreateFromWav(const APath: String); overload;

    /// <summary>
    ///  Frees the audio buffer
    /// </summary>
    procedure Free; inline;

    /// <summary>
    ///  Mix audio data.
    ///
    ///  This mixes ASrc into this buffer, performing addition, volume
    ///  adjustment, and overflow clipping.
    ///
    ///  The ASrc buffer must be in the same format as this buffer.
    ///
    ///  This is provided for convenience -- you can mix your own audio data.
    ///
    ///  Do not use this method for mixing together more than two streams of
    ///  sample data. The output from repeated application of this function may be
    ///  distorted by clipping, because there is no accumulator with greater range
    ///  than the input (not to mention this being an inefficient way of doing it).
    ///
    ///  It is a common misconception that this method is required to write audio
    ///  data to an output stream in an audio callback. While you can do that,
    ///  this method is really only needed when you're mixing a single audio
    ///  stream with a volume adjustment.
    /// </summary>
    /// <param name="ASrc">The source audio buffer to be mixed.</param>
    /// <param name="ASize">(Optional) size in bytes of the audio buffers.
    ///  If 0 (the default), it will use the minimum size of the 2 buffers.</param>
    /// <param name="AVolume">(Optional) volume, ranging from 0.0 - 1.0, and
    ///  should be set to 1.0 (default) for full audio volume.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Mix(const ASrc: TSdlAudioBuffer; const ASize: Integer = 0;
      const AVolume: Single = 1);

    /// <summary>
    ///  Specifies the format of the audio in the buffer.
    /// </summary>
    property Spec: TSdlAudioSpec read FSpec;

    /// <summary>
    ///  The audio data, in the format specified in Spec.
    /// </summary>
    property Buffer: Pointer read FBuffer;

    /// <summary>
    ///  The size of the audio data, in bytes.
    /// </summary>
    property Size: Integer read FSize;
  end;

type
  /// <summary>
  ///  Audio driver.
  /// </summary>
  TSdlAudioDriver = record
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    class function GetDriverCount: Integer; inline; static;
    class function GetDriver(const AIndex: Integer): TSdlAudioDriver; inline; static;
    class function GetCurrent: TSdlAudioDriver; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAudioDriver; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAudioDriver; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlAudioDriver; inline; static;
  public
    /// <summary>
    ///  The name of the driver.
    ///
    ///  The names of drivers are all simple, low-ASCII identifiers, like "alsa",
    ///  "coreaudio" or "wasapi". These never have Unicode characters, and are not
    ///  meant to be proper names.
    /// </summary>
    property Name: String read FName;

    /// <summary>
    ///  The number of built-in audio drivers.
    ///
    ///  This property returns a hardcoded number. This never returns a negative
    ///  value; if there are no drivers compiled into this build of SDL, this
    ///  property returns zero. The presence of a driver in this list does not mean
    ///  it will function, it just means SDL is capable of interacting with that
    ///  interface. For example, a build of SDL might have esound support, but if
    ///  there's no esound server available, SDL's esound driver would fail if used.
    ///
    ///  By default, SDL tries all drivers, in its preferred order, until one is
    ///  found to be usable.
    /// </summary>
    /// <seealso cref="Drivers"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property DriverCount: Integer read GetDriverCount;

    /// <summary>
    ///  The name built in audio drivers.
    ///
    ///  The list of audio drivers is given in the order that they are normally
    ///  initialized by default; the drivers that seem more reasonable to choose
    ///  first (as far as the SDL developers believe) are earlier in the list.
    /// </summary>
    /// <param name="AIndex">The index of the audio driver; the value ranges
    ///  from 0 to DriverCount - 1.</param>
    /// <seealso cref="NumDrivers"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Drivers[const AIndex: Integer]: TSdlAudioDriver read GetDriver;

    /// <summary>
    ///  The current audio driver, or nil if no driver has been initialized.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Current: TSdlAudioDriver read GetCurrent;
  end;
{$ENDREGION 'Audio'}

implementation

uses
  System.Math;

{ _TSdlAudioFormatHelper }

function _TSdlAudioFormatHelper.GetBitSize: Byte;
begin
  Result := SDL_AudioBitSize(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetByteSize: Byte;
begin
  Result := SDL_AudioByteSize(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetIsBigEndian: Boolean;
begin
  Result := SDL_AudioIsBigEndian(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetIsFloat: Boolean;
begin
  Result := SDL_AudioIsFloat(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetIsInteger: Boolean;
begin
  Result := SDL_AudioIsInt(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetIsLittleEndian: Boolean;
begin
  Result := SDL_AudioIsLittleEndian(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetIsSigned: Boolean;
begin
  Result := SDL_AudioIsSigned(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetIsUnsigned: Boolean;
begin
  Result := SDL_AudioIsUnsigned(Ord(Self));
end;

function _TSdlAudioFormatHelper.GetName: String;
begin
  Result := __ToString(SDL_GetAudioFormatName(Ord(Self)));
end;

function _TSdlAudioFormatHelper.GetSilenceValue: Byte;
begin
  Result := Byte(SDL_GetSilenceValueForFormat(Ord(Self)));
end;

{ TSdlAudioDeviceID }

class operator TSdlAudioDeviceID.Equal(const ALeft: TSdlAudioDeviceID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

function TSdlAudioDeviceID.GetChannelMap: TArray<Integer>;
begin
  var Count := 0;
  var Map := SDL_GetAudioDeviceChannelMap(FHandle, @Count);
  if (Count = 0) then
    Exit(nil);

  try
    SetLength(Result, Count);
    Move(Map^, Result[0], Count * SizeOf(Integer));
  finally
    SDL_free(Map);
  end;
end;

class function TSdlAudioDeviceID.GetDefaultPlaybackDevice: TSdlAudioDeviceID;
begin
  Result.FHandle := SDL_AUDIO_DEVICE_DEFAULT_PLAYBACK;
end;

class function TSdlAudioDeviceID.GetDefaultRecordingDevice: TSdlAudioDeviceID;
begin
  Result.FHandle := SDL_AUDIO_DEVICE_DEFAULT_RECORDING;
end;

function TSdlAudioDeviceID.GetFormat(out ASpec: TSdlAudioSpec): Integer;
begin
  SdlCheck(SDL_GetAudioDeviceFormat(FHandle, @ASpec.FHandle, @Result));
end;

function TSdlAudioDeviceID.GetIsPlaybackDevice: Boolean;
begin
  Result := SDL_IsAudioDevicePlayback(FHandle);
end;

function TSdlAudioDeviceID.GetName: String;
begin
  var Name := SDL_GetAudioDeviceName(FHandle);
  SdlCheck(Name);
  Result := __ToString(Name);
end;

class function TSdlAudioDeviceID.GetPlaybackDevices: TArray<TSdlAudioDeviceID>;
begin
  var Count := 0;
  var Devices := SDL_GetAudioPlaybackDevices(@Count);
  if (SdlSucceeded(Devices)) then
  try
    SetLength(Result, Count);
    Move(Devices^, Result[0], Count * SizeOf(SDL_AudioDeviceID));
  finally
    SDL_free(Devices);
  end;
end;

class function TSdlAudioDeviceID.GetRecordingDevices: TArray<TSdlAudioDeviceID>;
begin
  var Count := 0;
  var Devices := SDL_GetAudioRecordingDevices(@Count);
  if (SdlSucceeded(Devices)) then
  try
    SetLength(Result, Count);
    Move(Devices^, Result[0], Count * SizeOf(SDL_AudioDeviceID));
  finally
    SDL_free(Devices);
  end;
end;

class operator TSdlAudioDeviceID.Implicit(const AValue: Cardinal): TSdlAudioDeviceID;
begin
  Result.FHandle := AValue;
end;

class operator TSdlAudioDeviceID.NotEqual(const ALeft: TSdlAudioDeviceID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlAudioDevice }

procedure TSdlAudioDevice.Bind(const AStreams: TArray<TSdlAudioStream>);
begin
  SdlCheck(SDL_BindAudioStreams(FHandle, Pointer(AStreams), Length(AStreams)));
end;

procedure TSdlAudioDevice.Bind(const AStream: TSdlAudioStream);
begin
  SdlCheck(SDL_BindAudioStream(FHandle, AStream.FHandle));
end;

procedure TSdlAudioDevice.Close;
begin
  SDL_CloseAudioDevice(FHandle);
  FHandle := 0;
end;

class operator TSdlAudioDevice.Equal(const ALeft: TSdlAudioDevice;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

function TSdlAudioDevice.GetChannelMap: TArray<Integer>;
begin
  var Count := 0;
  var Map := SDL_GetAudioDeviceChannelMap(FHandle, @Count);
  if (Count = 0) then
    Exit(nil);

  try
    SetLength(Result, Count);
    Move(Map^, Result[0], Count * SizeOf(Integer));
  finally
    SDL_free(Map);
  end;
end;

function TSdlAudioDevice.GetFormat(out ASpec: TSdlAudioSpec): Integer;
begin
  SdlCheck(SDL_GetAudioDeviceFormat(FHandle, @ASpec.FHandle, @Result));
end;

function TSdlAudioDevice.GetGain: Single;
begin
  Result := SDL_GetAudioDeviceGain(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlAudioDevice.GetIsPaused: Boolean;
begin
  Result := SDL_AudioDevicePaused(FHandle);
end;

function TSdlAudioDevice.GetIsPlaybackDevice: Boolean;
begin
  Result := SDL_IsAudioDevicePlayback(FHandle);
end;

class operator TSdlAudioDevice.Implicit(
  const AValue: Cardinal): TSdlAudioDevice;
begin
  Result.FHandle := AValue;
end;

class operator TSdlAudioDevice.NotEqual(const ALeft: TSdlAudioDevice;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

class function TSdlAudioDevice.Open(
  const ADeviceID: TSdlAudioDeviceID): TSdlAudioDevice;
begin
  Result.FHandle := SDL_OpenAudioDevice(ADeviceID.FHandle, nil);
  SdlCheck(Result.FHandle);
end;

class function TSdlAudioDevice.Open(const ADeviceID: TSdlAudioDeviceID;
  const ASpec: TSdlAudioSpec): TSdlAudioDevice;
begin
  Result.FHandle := SDL_OpenAudioDevice(ADeviceID.FHandle, @ASpec.FHandle);
  SdlCheck(Result.FHandle);
end;

class function TSdlAudioDevice.Open(
  const ADevice: TSdlAudioDevice): TSdlAudioDevice;
begin
  Result.FHandle := SDL_OpenAudioDevice(ADevice.FHandle, nil);
  SdlCheck(Result.FHandle);
end;

procedure TSdlAudioDevice.Pause;
begin
  SdlCheck(SDL_PauseAudioDevice(FHandle));
end;

procedure TSdlAudioDevice.Resume;
begin
  SdlCheck(SDL_ResumeAudioDevice(FHandle));
end;

procedure TSdlAudioDevice.SetGain(const AValue: Single);
begin
  SdlCheck(SDL_SetAudioDeviceGain(FHandle, AValue));
end;

procedure TSdlAudioDevice.SetIsPaused(const AValue: Boolean);
begin
  if (AValue) then
    SdlCheck(SDL_PauseAudioDevice(FHandle))
  else
    SdlCheck(SDL_ResumeAudioDevice(FHandle));
end;

procedure TSdlAudioDevice.SetPostmixCallback(
  const ACallback: TSdlAudioPostmixCallback; const AUserData: Pointer);
begin
  SdlCheck(SDL_SetAudioPostmixCallback(FHandle,
    SDL_AudioPostmixCallback(ACallback), AUserData));
end;

class procedure TSdlAudioDevice.Unbind(const AStream: TSdlAudioStream);
begin
  SDL_UnbindAudioStream(AStream.FHandle);
end;

class procedure TSdlAudioDevice.Unbind(const AStreams: TArray<TSdlAudioStream>);
begin
  SDL_UnbindAudioStreams(Pointer(AStreams), Length(AStreams));
end;

{ TSdlAudioSpec }

constructor TSdlAudioSpec.Create(const AFormat: TSdlAudioFormat;
  const ANumChannels, AFreq: Integer);
begin
  FHandle.format := Ord(AFormat);
  FHandle.channels := ANumChannels;
  FHandle.freq := AFreq;
end;

function TSdlAudioSpec.GetFormat: TSdlAudioFormat;
begin
  Result := TSdlAudioFormat(FHandle.format);
end;

function TSdlAudioSpec.GetFrameSize: Integer;
begin
  Result := SDL_AudioFrameSize(FHandle);
end;

procedure TSdlAudioSpec.SetFormat(const AValue: TSdlAudioFormat);
begin
  FHandle.format := Ord(AValue);
end;

{ TSdlAudioStream }

procedure TSdlAudioStream.Clear;
begin
  SdlCheck(SDL_ClearAudioStream(FHandle));
end;

constructor TSdlAudioStream.Create(const ASrcSpec, ADstSpec: TSdlAudioSpec);
begin
  FHandle := SDL_CreateAudioStream(@ASrcSpec.FHandle, @ADstSpec.FHandle);
  SdlCheck(FHandle);
end;

constructor TSdlAudioStream.Create(const ASpec: TSdlAudioSpec);
begin
  FHandle := SDL_CreateAudioStream(@ASpec.FHandle, nil);
  SdlCheck(FHandle);
end;

class operator TSdlAudioStream.Equal(const ALeft: TSdlAudioStream;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlAudioStream.Flush;
begin
  SdlCheck(SDL_FlushAudioStream(FHandle));
end;

procedure TSdlAudioStream.Free;
begin
  SDL_DestroyAudioStream(FHandle);
  FHandle := 0;
end;

function TSdlAudioStream.GetAvailable: Integer;
begin
  Result := SDL_GetAudioStreamAvailable(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlAudioStream.GetData(const ABuffer: Pointer;
  const ASize: Integer): Integer;
begin
  Result := SDL_GetAudioStreamData(FHandle, ABuffer, ASize);
  if (Result = -1) then
    __HandleError;
end;

procedure TSdlAudioStream.GetFormat(const ASrcSpec,
  ADstSpec: PSdlAudioSpec);
begin
  SdlCheck(SDL_GetAudioStreamFormat(FHandle, Pointer(ASrcSpec), Pointer(ADstSpec)));
end;

function TSdlAudioStream.GetFrequencyRatio: Single;
begin
  Result := SDL_GetAudioStreamFrequencyRatio(FHandle);
  if (Result = 0) then
    __HandleError;
end;

function TSdlAudioStream.GetGain: Single;
begin
  Result := SDL_GetAudioStreamGain(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlAudioStream.GetInputChannelMap: TArray<Integer>;
begin
  var Count := 0;
  var Map := SDL_GetAudioStreamInputChannelMap(FHandle, @Count);
  if (Count = 0) then
    Exit(nil);

  try
    SetLength(Result, Count);
    Move(Map^, Result[0], Count * SizeOf(Integer));
  finally
    SDL_free(Map);
  end;
end;

function TSdlAudioStream.GetIsPaused: Boolean;
begin
  Result := SDL_AudioStreamDevicePaused(FHandle);
end;

function TSdlAudioStream.GetOutputChannelMap: TArray<Integer>;
begin
  var Count := 0;
  var Map := SDL_GetAudioStreamOutputChannelMap(FHandle, @Count);
  if (Count = 0) then
    Exit(nil);

  try
    SetLength(Result, Count);
    Move(Map^, Result[0], Count * SizeOf(Integer));
  finally
    SDL_free(Map);
  end;
end;

function TSdlAudioStream.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetAudioStreamProperties(FHandle);
end;

function TSdlAudioStream.GetQueued: Integer;
begin
  Result := SDL_GetAudioStreamQueued(FHandle);
  if (Result = -1) then
    __HandleError;
end;

class operator TSdlAudioStream.Implicit(const AValue: Pointer): TSdlAudioStream;
begin
  Result.FHandle := THandle(AValue);
end;

procedure TSdlAudioStream.Lock;
begin
  SdlCheck(SDL_LockAudioStream(FHandle));
end;

class operator TSdlAudioStream.NotEqual(const ALeft: TSdlAudioStream;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlAudioStream.Pause;
begin
  SdlCheck(SDL_PauseAudioStreamDevice(FHandle));
end;

procedure TSdlAudioStream.PutData(const ABuffer: Pointer; const ASize: Integer);
begin
  SdlCheck(SDL_PutAudioStreamData(FHandle, ABuffer, ASize));
end;

procedure TSdlAudioStream.Resume;
begin
  SdlCheck(SDL_ResumeAudioStreamDevice(FHandle));
end;

procedure TSdlAudioStream.SetFormat(const ASrcSpec,
  ADstSpec: PSdlAudioSpec);
begin
  SdlCheck(SDL_SetAudioStreamFormat(FHandle, Pointer(ASrcSpec), Pointer(ADstSpec)));
end;

procedure TSdlAudioStream.SetFrequencyRatio(const AValue: Single);
begin
  SdlCheck(SDL_SetAudioStreamFrequencyRatio(FHandle, AValue));
end;

procedure TSdlAudioStream.SetGain(const AValue: Single);
begin
  SdlCheck(SDL_SetAudioStreamGain(FHandle, AValue));
end;

procedure TSdlAudioStream.SetInputChannelMap(const AValue: TArray<Integer>);
begin
  SdlCheck(SDL_SetAudioStreamInputChannelMap(FHandle, Pointer(AValue), Length(AValue)));
end;

procedure TSdlAudioStream.SetIsPaused(const AValue: Boolean);
begin
  if (AValue) then
    SdlCheck(SDL_PauseAudioStreamDevice(FHandle))
  else
    SdlCheck(SDL_ResumeAudioStreamDevice(FHandle));
end;

procedure TSdlAudioStream.SetOutputChannelMap(const AValue: TArray<Integer>);
begin
  SdlCheck(SDL_SetAudioStreamOutputChannelMap(FHandle, Pointer(AValue), Length(AValue)));
end;

procedure TSdlAudioStream.Unbind;
begin
  SDL_UnbindAudioStream(FHandle);
end;

procedure TSdlAudioStream.Unlock;
begin
  SdlCheck(SDL_UnlockAudioStream(FHandle));
end;

{ _TSdlAudioStreamHelper }

constructor _TSdlAudioStreamHelper.Create(const ADeviceID: TSdlAudioDeviceID;
  const ASpec: PSdlAudioSpec; const ACallback: TSdlAudioStreamCallback;
  const AUserData: Pointer);
begin
  FHandle := SDL_OpenAudioDeviceStream(ADeviceID.FHandle, Pointer(ASpec),
    SDL_AudioStreamCallback(ACallback), AUserData);
  SdlCheck(FHandle);
end;

function _TSdlAudioStreamHelper.GetDevice: TSdlAudioDevice;
begin
  Result.FHandle := SDL_GetAudioStreamDevice(FHandle);
end;

procedure _TSdlAudioStreamHelper.SetGetCallback(
  const ACallback: TSdlAudioStreamCallback; const AUserData: Pointer);
begin
  SdlCheck(SDL_SetAudioStreamGetCallback(FHandle,
    SDL_AudioStreamCallback(ACallback), AUserData));
end;

procedure _TSdlAudioStreamHelper.SetPutCallback(
  const ACallback: TSdlAudioStreamCallback; const AUserData: Pointer);
begin
  SdlCheck(SDL_SetAudioStreamPutCallback(FHandle,
    SDL_AudioStreamCallback(ACallback), AUserData));
end;

{ TSdlAudioBuffer }

constructor TSdlAudioBuffer.Create(const AFormat: TSdlAudioFormat;
  const ASize, ANumChannels, AFreq: Integer);
begin
  FSpec.Format := AFormat;
  FSpec.NumChannels := ANumChannels;
  FSpec.Freq := AFreq;
  FSize := ASize;
  FBuffer := SDL_malloc(ASize);
end;

constructor TSdlAudioBuffer.Create(const AFormat: TSdlAudioFormat;
  const ANumChannels, AFreq: Integer; const ASrc: TSdlAudioBuffer);
begin
  SdlCheck(SDL_ConvertAudioSamples(@ASrc.FSpec.FHandle, @ASrc.FBuffer, ASrc.FSize,
    @FSpec.FHandle, @FBuffer, @FSize));
end;

constructor TSdlAudioBuffer.CreateFromWav(const ASrc: TSdlIOStream;
  const ACloseIO: Boolean);
begin
  SdlCheck(SDL_LoadWAV_IO(THandle(ASrc), ACloseIO, @FSpec.FHandle, @FBuffer, @FSize));
end;

constructor TSdlAudioBuffer.CreateFromWav(const APath: String);
begin
  SdlCheck(SDL_LoadWAV(__ToUtf8(APath), @FSpec.FHandle, @FBuffer, @FSize));
end;

procedure TSdlAudioBuffer.Free;
begin
  if (FBuffer <> nil) then
  begin
    SDL_free(FBuffer);
    FBuffer := nil;
  end;
  FSize := 0;
end;

procedure TSdlAudioBuffer.Mix(const ASrc: TSdlAudioBuffer; const ASize: Integer;
  const AVolume: Single);
begin
  if (ASrc.FSpec.Format <> FSpec.Format) then
    __HandleError('Audio format of source and target buffers do not match');

  var Size := Min(FSize, ASrc.FSize);
  if (ASize <> 0) then
    Size := Min(Size, ASize);

  SdlCheck(SDL_MixAudio(FBuffer, ASrc.FBuffer, FSpec.FHandle.format, Size, AVolume));
end;

{ TSdlAudioDriver }

class operator TSdlAudioDriver.Equal(const ALeft: TSdlAudioDriver;
  const ARight: Pointer): Boolean;
begin
  Result := (Pointer(ALeft.FName) = ARight);
end;

class function TSdlAudioDriver.GetCurrent: TSdlAudioDriver;
begin
  Result.FName := __ToString(SDL_GetCurrentAudioDriver);
end;

class function TSdlAudioDriver.GetDriver(
  const AIndex: Integer): TSdlAudioDriver;
begin
  Result.FName := __ToString(SDL_GetAudioDriver(AIndex));
end;

class function TSdlAudioDriver.GetDriverCount: Integer;
begin
  Result := SDL_GetNumAudioDrivers;
end;

class operator TSdlAudioDriver.Implicit(const AValue: Pointer): TSdlAudioDriver;
begin
  Result.FName := '';
end;

class operator TSdlAudioDriver.NotEqual(const ALeft: TSdlAudioDriver;
  const ARight: Pointer): Boolean;
begin
  Result := (Pointer(ALeft.FName) <> ARight);
end;

end.
