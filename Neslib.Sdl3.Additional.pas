unit Neslib.Sdl3.Additional;

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
  System.SysUtils,
  System.Generics.Collections,
  {$IF Defined(ANDROID)}
  Androidapi.Jni,
  {$ENDIF}
  Neslib.Sdl3.Api,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video;

{$REGION 'Runtime Library'}
const
  /// <summary>
  ///  Epsilon constant, used for comparing floating-point numbers.
  ///
  ///  Equals to 1.1920928955078125e-07
  /// </summary>
  /// <remarks>
  ///  Note that this is different from Delphi's Single.Epsilon value.
  /// </remarks>
  SDL_SINGLE_EPSILON = SDL_FLT_EPSILON;

/// <summary>
///  Allocate uninitialized memory using SDL's memory manager.
///
///  The allocated memory returned by this function must be freed with
///  SdlFree and *not* with Delphi's FreeMem.
///
///  If `ASize` is 0, it will be set to 1.
///
///  If you want to allocate memory aligned to a specific alignment, consider
///  using SdlAlignedAlloc.
/// </summary>
/// <param name="ASize">The size to allocate.</param>
/// <returns>A pointer to the allocated memory, or nil if allocation failed.</returns>
/// <seealso cref="SdlFree"/>
/// <seealso cref="SdlCAlloc"/>
/// <seealso cref="SdlRealloc"/>
/// <seealso cref="SdlAlignedAlloc"/>
/// <remarks>
///  It is safe to call this method from any thread
/// </remarks>
function SdlMAlloc(const ASize: NativeInt): Pointer; inline;

/// <summary>
///  Allocate a zero-initialized array using SDL's memory manager.
///
///  The memory returned by this function must be freed with SdlFree and *not*
///  with Delphi's FreeMem.
///
///  If either of `ANumElements` or `AElementSize` is 0, they will both be set to 1.
/// </summary>
/// <param name="ANumElements">The number of elements in the array.</param>
/// <param name="AElementSize">The size of each element of the array.</param>
/// <returns>A pointer to the allocated array, or nil if allocation failed.</returns>
/// <seealso cref="SdlFree"/>
/// <seealso cref="SdlMAlloc"/>
/// <seealso cref="SdlRealloc"/>
/// <remarks>
///  It is safe to call this method from any thread
/// </remarks>
function SdlCAlloc(const ANumElements, AElementSize: NativeInt): Pointer; inline;

/// <summary>
///  Change the size of allocated memory using SDL's memory manager.
///
///  The memory returned by this function must be freed with SdlFree and *not*
///  Delphi's FreeMem.
///
///  If `ASize` is 0, it will be set to 1.
///
///  If `AMem` is nil, the behavior of this function is equivalent to
///  SdlMAlloc. Otherwise, the function can have one of three possible
///  outcomes:
///
///  - If it returns the same pointer as `AMem`, it means that `AMem` was resized
///    in place without freeing.
///  - If it returns a different non-nil pointer, it means that `AMem` was freed
///    and cannot be dereferenced anymore.
///  - If it returns nil (indicating failure), then `AMem` will remain valid and
///    must still be freed with SdlFree.
/// </summary>
/// <param name="AMem">A pointer to allocated memory to reallocate, or nil.</param>
/// <param name="ASize">The new size of the memory.</param>
/// <returns>A pointer to the newly allocated memory, or nil if allocation failed.</returns>
/// <seealso cref="SdlFree"/>
/// <seealso cref="SdlMAlloc"/>
/// <seealso cref="SdlCAlloc"/>
/// <remarks>
///  It is safe to call this method from any thread
/// </remarks>
function SdlRealloc(const AMem: Pointer; const ASize: NativeInt): Pointer; inline;

/// <summary>
///  Free allocated memory using SDL's memory manager.
///
///  This should (and must) only be used for freeing memory allocated by SDL's
///  memory manager function (like SdlMAlloc). Do *not* use it to free memory
///  allocated by Delphi's memory manager functions (like GetMem).
///
///  The pointer is no longer valid after this call and cannot be dereferenced
///  anymore.
///
///  If `AMem` is nil, this routine does nothing.
/// </summary>
/// <param name="AMem">A pointer to allocated memory, or nil.</param>
/// <seealso cref="SdlMAlloc"/>
/// <seealso cref="SdlCAlloc"/>
/// <seealso cref="SdlRealloc"/>
/// <remarks>
///  It is safe to call this method from any thread
/// </remarks>
procedure SdlFree(const AMem: Pointer); inline;

/// <summary>
///  Allocate memory aligned to a specific alignment.
///
///  The memory returned by this function must be freed with SdlAlignedFree,
///  _not_ SdlFree.
///
///  If `AAlignment` is less than the size of a pointer, it will be increased to
///  match that.
///
///  The returned memory address will be a multiple of the alignment value, and
///  the size of the memory allocated will be a multiple of the alignment value.
/// </summary>
/// <param name="AAlignment">The alignment of the memory.</param>
/// <param name="ASize">The size to allocate.</param>
/// <returns>A pointer to the aligned memory, or nil if allocation failed.</returns>
/// <seealso cref="SdlAlignedFree"/>
/// <remarks>
///  It is safe to call this function from any thread
/// </remarks>
function SdlAlignedAlloc(const AAlignment, ASize: NativeInt): Pointer; inline;

/// <summary>
///  Free memory allocated by SdlAlignedAlloc.
///
///  The pointer is no longer valid after this call and cannot be dereferenced
///  anymore.
///
///  If `AMem` is nil, this function does nothing.
/// </summary>
/// <param name="AMem">A pointer previously returned by SdlAlignedAlloc, or nil.</param>
/// <seealso cref="SdlAlignedAlloc"/>
/// <remarks>
///  It is safe to call this function from any thread
/// </remarks>
procedure SdlAlignedFree(const AMem: Pointer); inline;

/// <summary>
///  Get the number of outstanding (unfreed) allocations.
/// </summary>
/// <returns>The number of allocations or -1 if allocation counting is disabled.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
///
///  This only counts the number of allocations made with SDL's memory functions.
/// </remarks>
function SdlNumAllocations: Integer; inline;

type
  /// <summary>
  ///  A callback used to implement SdlMAlloc.
  ///
  ///  SDL will always ensure that the passed `ASize` is greater than 0.
  /// </summary>
  /// <param name="ASize">The size to allocate.</param>
  /// <returns>A pointer to the allocated memory, or nil if allocation failed.</returns>
  /// <seealso cref="SdlMAlloc"/>
  /// <seealso cref="TSdlMemoryManager.Original"/>
  /// <seealso cref="TSdlMemoryManager.Current"/>
  /// <remarks>
  ///  It should be safe to call this callback from any thread.
  /// </remarks>
  TSdlMAllocFunc = function(ASize: NativeInt): Pointer; cdecl;

type
  /// <summary>
  ///  A callback used to implement SdlCAlloc.
  ///
  ///  SDL will always ensure that the passed `ANumElements` and `AElementSize`
  ///  are both greater than 0.
  /// </summary>
  /// <param name="ANumElements">The number of elements in the array.</param>
  /// <param name="AElementSize">The size of each element of the array.</param>
  /// <returns>A pointer to the allocated array, or nil if allocation failed.</returns>
  /// <seealso cref="SdlCAlloc"/>
  /// <seealso cref="TSdlMemoryManager.Original"/>
  /// <seealso cref="TSdlMemoryManager.Current"/>
  /// <remarks>
  ///  It should be safe to call this callback from any thread.
  /// </remarks>
  TSdlCAllocFunc = function(ANumElements, AElementSize: NativeInt): Pointer; cdecl;

type
  /// <summary>
  ///  A callback used to implement SdlRealloc.
  ///
  ///  SDL will always ensure that the passed `ASize` is greater than 0.
  /// </summary>
  /// <param name="AMem">A pointer to allocated memory to reallocate, or nil.</param>
  /// <param name="ASize">The new size of the memory.</param>
  /// <returns>A pointer to the newly allocated memory, or nil if allocation failed.</returns>
  /// <seealso cref="SdlRealloc"/>
  /// <seealso cref="TSdlMemoryManager.Original"/>
  /// <seealso cref="TSdlMemoryManager.Current"/>
  /// <remarks>
  ///  It should be safe to call this callback from any thread.
  /// </remarks>
  TSdlReallocFunc = function(AMem: Pointer; ASize: NativeInt): Pointer; cdecl;

type
  /// <summary>
  ///  A callback used to implement SdlFree.
  ///
  ///  SDL will always ensure that the passed `AMem` is a non-nil pointer.
  /// </summary>
  /// <param name="AMem">A pointer to allocated memory.</param>
  /// <seealso cref="SdlFree"/>
  /// <seealso cref="TSdlMemoryManager.Original"/>
  /// <seealso cref="TSdlMemoryManager.Current"/>
  /// <remarks>
  ///  It should be safe to call this callback from any thread.
  /// </remarks>
  TSdlFreeFunc = procedure(AMem: Pointer); cdecl;

type
  /// <summary>
  ///  To customize SDL's memory manager
  /// </summary>
  TSdlMemoryManager = record
  {$REGION 'Internal Declarations'}
  private
    class function GetOriginal: TSdlMemoryManager; static;
    class function GetCurrent: TSdlMemoryManager; static;
    class procedure SetCurrent(const AValue: TSdlMemoryManager); static;
  private
    class function DelphiMAlloc(ASize: NativeInt): Pointer; cdecl; static;
    class function DelphiCAlloc(ANumElements, AElementSize: NativeInt): Pointer; cdecl; static;
    class function DelphiRealloc(AMem: Pointer; ASize: NativeInt): Pointer; cdecl; static;
    class procedure DelphiFree(AMem: Pointer); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The callback used to implement SdlMAlloc.
    /// </summary>
    MAlloc: TSdlMAllocFunc;

    /// <summary>
    ///  The callback used to implement SdlCAlloc.
    /// </summary>
    CAlloc: TSdlCAllocFunc;

    /// <summary>
    ///  The callback used to implement SdlRealloc.
    /// </summary>
    Realloc: TSdlReallocFunc;

    /// <summary>
    ///  The callback used to implement SdlFree.
    /// </summary>
    Free: TSdlFreeFunc;
  public
    /// <summary>
    ///  Sets the memory functions to use Delphi's built-in functions (like
    ///  GetMem and FreeMem) instead.
    ///
    ///  This enables you to use a single set of memory management functions, as
    ///  well as enable features like ReportMemoryLeaksOnShutdown.
    ///
    ///  It is not safe to change the memory functions once any allocations have
    ///  been made, as future calls to SdlFree will use the new allocator, even
    ///  if they came from an SdlMAlloc made with the old one!
    ///
    ///  Uusually this needs to be the first call made into the SDL library,
    ///  if not the very first thing done at program startup time.
    /// </summary>
    /// <seealso cref="Original"/>
    /// <seealso cref="Current"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This does not hold a lock, so do not use this in the unlikely event of
    ///  a background thread setting this simultaneously.
    /// </remarks>
    class procedure UseDelphis; static;

    /// <summary>
    ///  The original set of SDL memory functions.
    ///
    ///  This is what SdlMAlloc and friends will use by default, if no custom
    ///  memory manager has been set (using Current). This is not necessarily
    ///  using the C runtime's `malloc` functions behind the scenes! Different
    ///  platforms and build configurations might do any number of unexpected
    ///  things.
    /// </summary>
    /// <seealso cref="Current"/>
    /// <seealso cref="UseDelphis"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Original: TSdlMemoryManager read GetOriginal;

    /// <summary>
    ///  The current set of SDL memory functions.
    ///
    ///  It is not safe to change the memory functions once any allocations have
    ///  been made, as future calls to SdlFree will use the new allocator, even
    ///  if they came from an SdlMAlloc made with the old one!
    ///
    ///  If set, usually this needs to be the first call made into the SDL library,
    ///  if not the very first thing done at program startup time.
    /// </summary>
    /// <seealso cref="Original"/>
    /// <seealso cref="UseDelphis"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This does not hold a lock, so do not use this in the unlikely event of
    ///  a background thread setting this simultaneously.
    /// </remarks>
    class property Current: TSdlMemoryManager read GetCurrent write SetCurrent;
  end;

type
  /// <summary>
  ///  A thread-safe set of environment variables
  /// </summary>
  TSdlEnvironment = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Environment;
    class function GetProcess: TSdlEnvironment; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlEnvironment; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlEnvironment; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlEnvironment; inline; static;
  public
    /// <summary>
    ///  Create a set of environment variables
    /// </summary>
    /// <param name="APopulated">True to initialize it from the runtime
    ///  environment, False to create an empty environment.</param>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  If `APopulated` is false, it is safe to call this constructor from any
    ///  thread, otherwise it is safe if no other threads are changing the
    ///  environment.
    /// </remarks>
    constructor Create(const APopulated: Boolean);

    /// <summary>
    ///  Free the set of environment variables.
    /// </summary>
    /// <seealso cref="Create"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the
    ///  environment is no longer in use.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Get the value of a variable in the environment.
    /// </summary>
    /// <param name="AName">The name of the variable to get.</param>
    /// <returns>The value of the variable or an empty string if it can't be found.</returns>
    /// <seealso cref="GetVariables"/>
    /// <seealso cref="SetVariable"/>
    /// <seealso cref="UnsetVariable"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function GetVariable(const AName: String): String; inline;

    /// <summary>
    ///  Get all variables in the environment.
    /// </summary>
    /// <returns>An array of pointers to environment variables in the form
    ///  'variable=value'.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetVariable"/>
    /// <seealso cref="SetVariable"/>
    /// <seealso cref="UnsetVariable"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function GetVariables: TArray<String>;

    /// <summary>
    ///  Set the value of a variable in the environment.
    /// </summary>
    /// <param name="AName">The name of the variable to set.</param>
    /// <param name="AValue">The value of the variable to set.</param>
    /// <param name="AOverwrite">True to overwrite the variable if it exists,
    ///  False to return success without setting the variable if it already exists.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetVariable"/>
    /// <seealso cref="GetVariables"/>
    /// <seealso cref="UnsetVariable"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure SetVariable(const AName, AValue: String; const AOverwrite: Boolean); inline;

    /// <summary>
    ///  Clear a variable from the environment.
    /// </summary>
    /// <param name="AName">The name of the variable to unset.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetVariable"/>
    /// <seealso cref="GetVariables"/>
    /// <seealso cref="SetVariable"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure UnsetVariable(const AName: String); inline;

    /// <summary>
    ///  Get the value of a variable in the environment.
    ///
    ///  This method bypasses SDL's cached copy of the environment and is not
    ///  thread-safe.
    /// </summary>
    /// <param name="AName">The name of the variable to get.</param>
    /// <returns>The value of the variable or an empty string if it can't be found.</returns>
    /// <seealso cref="SetUnsafe"/>
    /// <seealso cref="GetVariable"/>
    /// <remarks>
    ///  This function is not thread safe, consider using GetVariable instead.
    /// </remarks>
    class function GetUnsafe(const AName: String): String; inline; static;

    /// <summary>
    ///  Set the value of a variable in the environment.
    /// </summary>
    /// <param name="AName">The name of the variable to set.</param>
    /// <param name="AValue">The value of the variable to set.</param>
    /// <param name="AOverwrite">True to overwrite the variable if it exists,
    ///  False to return success without setting the variable if it already exists.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetUnsafe"/>
    /// <seealso cref="SetVariable"/>
    /// <remarks>
    ///  This function is not thread safe, consider using SetVariable instead.
    /// </remarks>
    class procedure SetUnsafe(const AName, AValue: String;
      const AOverwrite: Boolean); inline; static;

    /// <summary>
    ///  Clear a variable from the environment.
    /// </summary>
    /// <param name="AName">The name of the variable to unset.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="UnsetVariable"/>
    /// <remarks>
    ///  This function is not thread safe, consider using UnsetVariable instead.
    /// </remarks>
    class procedure UnsetUnsafe(const AName: String); inline; static;

    /// <summary>
    ///  The process environment.
    ///
    ///  This is initialized at application start and is not affected by any
    ///  changes to the environment variables after that point. Use SetVariable
    ///  and UnsetVariable if you want to modify this environment, or SetUnsafe
    ///  UnsetUnsafe if you want changes to persist to the runtime environment
    ///  after SdlQuit.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Process: TSdlEnvironment read GetProcess;
  end;

/// <summary>
///  Calculate a CRC-16 value.
///
///  See <see href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">Cyclic Redundancy Check</see>.
///
///  This function can be called multiple times, to stream data to be
///  checksummed in blocks. Each call must provide the previous CRC-16 return
///  value to be updated with the next block. The first call to this function
///  for a set of blocks should pass in a zero CRC value.
/// </summary>
/// <param name="ACrc">The current checksum for this data set, or 0 for a new data set.</param>
/// <param name="AData">A new block of data to add to the checksum.</param>
/// <param name="ASize">The size, in bytes, of the new block of data.</param>
/// <returns>A CRC-16 checksum value of all blocks in the data set.</returns>
/// <remarks>
///  It is safe to call this function from any thread
/// </remarks>
function SdlCrc16(const ACrc: Word; const AData: Pointer; const ASize: NativeInt): Word; inline;

/// <summary>
///  Calculate a CRC-32 value.
///
///  See <see href="https://en.wikipedia.org/wiki/Cyclic_redundancy_check">Cyclic Redundancy Check</see>.
///
///  This function can be called multiple times, to stream data to be
///  checksummed in blocks. Each call must provide the previous CRC-32 return
///  value to be updated with the next block. The first call to this function
///  for a set of blocks should pass in a zero CRC value.
/// </summary>
/// <param name="ACrc">The current checksum for this data set, or 0 for a new data set.</param>
/// <param name="AData"A new block of data to add to the checksum.</param>
/// <param name="ASize">The size, in bytes, of the new block of data.</param>
/// <returns>A CRC-32 checksum value of all blocks in the data set.</returns>
/// <remarks>
///  It is safe to call this function from any thread
/// </remarks>
function SdlCrc32(const ACrc: Cardinal; const AData: Pointer; const ASize: NativeInt): Cardinal; inline;

/// <summary>
///  Calculate a 32-bit MurmurHash3 value for a block of data.
///
///  See <see href="https://en.wikipedia.org/wiki/MurmurHash">MurmurHash</see>.
///
///  A seed may be specified, which changes the final results consistently, but
///  this does not work like SdlCrc16 and SdlCrc32: you can't feed a previous
///  result from this function back into itself as the next seed value to
///  calculate a hash in chunks; it won't produce the same hash as it would if
///  the same data was provided in a single call.
///
///  If you aren't sure what to provide for a seed, zero is fine. Murmur3 is not
///  cryptographically secure, so it shouldn't be used for hashing top-secret
///  data.
/// </summary>
/// <param name="AData">The data to be hashed.</param>
/// <param name="ALen">The size of data, in bytes.</param>
/// <param name="ASeed">(Optional) value that alters the final hash value.</param>
/// <returns>A Murmur3 32-bit hash value.</returns>
/// <remarks>
///  It is safe to call this function from any thread
/// </remarks>
function SdlMurmur3(const AData: Pointer; const ASize: NativeInt;
  const ASeed: Cardinal = 0): Cardinal; inline;

/// <summary>
///  Initialize all 32-bit words of buffer of memory to a specific value.
///
///  This function will set a buffer of `ACount` UInt32 values, pointed to by
///  `ADst`, to the value specified in `AVal`.
///
///  Unlike FillChar, this sets 32-bit values, not bytes, so it's not limited
///  to a range of 0-255.
/// </summary>
/// <param name="ADst">The destination memory region.</param>
/// <param name="ACount">The number of UInt32 values to set in `ADst`.</param>
/// <param name="AVal">The UInt32 value to set.</param>
/// <returns>The pointer to `ADst`.</returns>
/// <remarks>
///  It is safe to call this function from any thread
/// </remarks>
function SdlFillChar4(var ADst; const ACount: NativeInt; const AVal: Cardinal): Pointer; inline;
{$ENDREGION 'Runtime Library'}

{$REGION 'Clipboard'}
type
  /// <summary>
  ///  Implement this interface to provide (non-text) data for the clipboard.
  /// </summary>
  /// <seealso cref="TSdlClipboard.SetData"/>
  ISdlClipboardDataProvider = interface
  ['{F6EF3B55-3770-4F7E-92B7-A4B07D34C2EB}']
    /// <summary>
    ///  Will be called when data for the specified mime-type is requested by
    ///  the OS.
    ///
    ///  This method is called with an empty string as the mime_type when the
    ///  clipboard is cleared or new data is set. The clipboard is automatically
    ///  cleared in SdlQuit.
    /// </summary>
    /// <param name="AMimeType">The requested mime-type.</param>
    /// <param name="ASize">You should set this to the size of the returned data.</param>
    /// <returns>You should return a pointer to the data for the provided mime-type.
    ///  Returning nil or setting ASize to 0 will cause no data to be sent to the
    ///  "receiver". It is up to the receiver to handle this. Essentially
    ///  returning no data is more or less undefined behavior and may cause
    ///  breakage in receiving applications. The returned data will not be freed
    ///  so it needs to be retained and dealt with internally.</returns>
    /// <seealso cref="TSdlClipboard.SetData"/>
    function Data(const AMimeType: String; out ASize: NativeInt): Pointer;

    /// <summary>
    ///  Will be called when the clipboard is cleared, or new data is set.
    /// </summary>
    /// <seealso cref="TSdlClipboard.SetData"/>
    procedure Cleanup;
  end;

type
  /// <summary>
  ///  SDL provides access to the system clipboard, both for reading information
  ///  from other processes and publishing information of its own.
  ///
  ///  This is not just text! SDL apps can access and publish data by mimetype.
  ///
  ///  ## Basic use (text)
  ///
  ///  Obtaining and publishing simple text to the system clipboard is as easy
  ///  as using the Text property. Data transmission and encoding conversion is
  ///  completely managed by SDL.
  ///
  ///  ## Clipboard data provider (data other than text)
  ///
  ///  Things get more complicated when the clipboard contains something other
  ///  than text. Not only can the system clipboard contain data of any type, in
  ///  some cases it can contain the same data in different formats! For example,
  ///  an image painting app might let the user copy a graphic to the clipboard,
  ///  and offers it in .BMP, .JPG, or .PNG format for other apps to consume.
  ///
  ///  Obtaining clipboard data ("pasting") like this is a matter of calling
  ///  GetData and telling it the mime type of the data you want. But how does
  ///  one know if that format is available? HasData can report if a specific
  ///  mimetype is offered, and MimeTypes can provide the entire list of
  ///  mimetypes available, so the app can decide what to do with the data and
  ///  what formats it can support.
  ///
  ///  Setting the clipboard ("copying") to arbitrary data is done with SetData.
  ///  The app does not provide the data in this call, but rather the mime types
  ///  it is willing to provide and a ISdlClipboardDataProvider interface that
  ///  will be called when needed. During the ISdlClipboardDataProvider.Data
  ///  callback, the app will generate the data. This allows massive data sets
  ///  to be provided to the clipboard, without any data being copied before it
  ///  is explicitly requested. More specifically, it allows an app to offer
  ///  data in multiple formats without providing a copy of all of them upfront.
  ///  If the app has an image that it could provide in PNG or JPG format, it
  ///  doesn't have to encode it to either of those unless and until something
  ///  tries to paste it.
  /// </summary>
  TSdlClipboard = record
  {$REGION 'Internal Declarations'}
  private class var
    FProviders: TDictionary<String, ISdlClipboardDataProvider>;
  private
    class function DataCallback(AUserData: Pointer; const AMimeType: PUTF8Char;
      ASize: PNativeUInt): Pointer; cdecl; static;
    class procedure CleanupCallback(AUserData: Pointer); cdecl; static;
  private
    class function GetText: String; inline; static;
    class procedure SetText(const AValue: String); inline; static;
    class function GetHasText: Boolean; inline; static;
    class function GetMimeTypes: TArray<String>; static;
  public
    class constructor Create;
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Query whether there is data in the clipboard for the provided mime type.
    /// </summary>
    /// <param name="AMimeType">The mime type to check for data for.</param>
    /// <returns>True if there exists data in clipboard for the provided mime
    ///  type, False if it does not.</returns>
    /// <seealso cref="SetData"/>
    /// <seealso cref="GetData"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class function HasData(const AMimeType: String): Boolean; inline; static;

    /// <summary>
    ///  Get data from the clipboard for a given mime type.
    /// </summary>
    /// <param name="AMimeType">The mime type to read from the clipboard.</param>
    /// <returns>The retrieved data buffer or nil if there is none.</returns>
    /// <seealso cref="HasData"/>
    /// <seealso cref="SetData"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class function GetData(const AMimeType: String): TBytes; static;

    /// <summary>
    ///  Offer clipboard data to the OS.
    ///
    ///  Tell the operating system that the application is offering clipboard
    ///  data for each of the provided mime types. Once another application
    ///  requests the data the ISdlClipboardDataProvider.Data callback method
    ///  will be called, allowing it to generate and respond with the data for
    ///  the requested mime type.
    /// </summary>
    /// <param name="AProvider">A ISdlClipboardDataProvider interface that
    ///  provides the clipboard data. Cannot be nil.</param>
    /// <param name="AMimeTypes">A list of mime-types that are being offered.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ClearData"/>
    /// <seealso cref="GetData"/>
    /// <seealso cref="HasData"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure SetData(const AProvider: ISdlClipboardDataProvider;
      const AMimeTypes: TArray<String>); static;

    /// <summary>
    ///  Clear the clipboard data.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetData"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure ClearData; inline; static;

    /// <summary>
    ///  The text on the clipboard.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="HasText"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Text: String read GetText write SetText;

    /// <summary>
    ///  Whether the clipboard exists and contains a non-empty text string.
    /// </summary>
    /// <seealso cref="Text"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property HasText: Boolean read GetHasText;

    /// <summary>
    ///  The list of mime types available in the clipboard.
    /// </summary>
    /// <seealso cref="SetData"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property MimeTypes: TArray<String> read GetMimeTypes;
  end;
{$ENDREGION 'Clipboard'}

{$REGION 'CPU Info'}
const
  /// <summary>
  ///  A guess for the cacheline size used for padding.
  ///
  ///  Most x86 processors have a 64 byte cache line. The 64-bit PowerPC
  ///  processors have a 128 byte cache line. We use the larger value to be
  ///  generally safe.
  /// </summary>
  SDL_CACHELINE_SIZE = Neslib.Sdl3.Api.SDL_CACHELINE_SIZE; // 128

type
  /// <summary>
  ///  CPU feature detection for SDL.
  ///
  ///  These functions are largely concerned with reporting if the system has
  ///  access to various SIMD instruction sets, but also has other important info
  ///  to share, such as system RAM size and number of logical CPU cores.
  ///
  ///  CPU instruction set checks, like HasSse and HasNeon, are available on all
  ///  platforms, even if they don't make sense (an ARM processor will never
  ///  have SSE and an x86 processor will never have NEON, for example, but
  ///  these properties still exist and will simply return False in these).
  /// </summary>
  TSdlCpu = record
  {$REGION 'Internal Declarations'}
  private
    class function GetNumLogicalCores: Integer; inline; static;
    class function GetCacheLineSize: Integer; inline; static;
    class function GetHasAltiVec: Boolean; inline; static;
    class function GetHasMmx: Boolean; inline; static;
    class function GetHasSse: Boolean; inline; static;
    class function GetHasSse2: Boolean; inline; static;
    class function GetHasSse3: Boolean; inline; static;
    class function GetHasSse41: Boolean; inline; static;
    class function GetHasSse42: Boolean; inline; static;
    class function GetHasAvx: Boolean; inline; static;
    class function GetHasAvx2: Boolean; inline; static;
    class function GetHasAvx512F: Boolean; inline; static;
    class function GetHasArmSimd: Boolean; inline; static;
    class function GetHasNeon: Boolean; inline; static;
    class function GetHasLsx: Boolean; inline; static;
    class function GetHasLasx: Boolean; inline; static;
    class function GetSystemRamMiB: Integer; inline; static;
    class function GetSimdAlignment: Integer; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The number of logical CPU cores available.
    ///
    ///  On CPUs that include technologies such as hyperthreading, the number of
    ///  logical cores may be more than the number of physical cores.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property NumLogicalCores: Integer read GetNumLogicalCores;

    /// <summary>
    ///  Determine the L1 cache line size of the CPU.
    ///
    ///  This is useful for determining multi-threaded structure padding or SIMD
    ///  prefetch sizes.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property CacheLineSize: Integer read GetCacheLineSize;

    /// <summary>
    ///  Whether the CPU has AltiVec features.
    ///
    ///  This always returns False on CPUs that aren't using PowerPC instruction
    ///  sets.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasAltiVec: Boolean read GetHasAltiVec;

    /// <summary>
    ///  Whether the CPU has MMX features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasMmx: Boolean read GetHasMmx;

    /// <summary>
    ///  Determine whether the CPU has SSE features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasSse2"/>
    /// <seealso cref="HasSse3"/>
    /// <seealso cref="HasSse41"/>
    /// <seealso cref="HasSse42"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasSse: Boolean read GetHasSse;

    /// <summary>
    ///  Determine whether the CPU has SSE2 features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasSse"/>
    /// <seealso cref="HasSse3"/>
    /// <seealso cref="HasSse41"/>
    /// <seealso cref="HasSse42"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasSse2: Boolean read GetHasSse2;

    /// <summary>
    ///  Determine whether the CPU has SSE3 features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasSse"/>
    /// <seealso cref="HasSse2"/>
    /// <seealso cref="HasSse41"/>
    /// <seealso cref="HasSse42"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasSse3: Boolean read GetHasSse3;

    /// <summary>
    ///  Determine whether the CPU has SSE4.1 features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasSse"/>
    /// <seealso cref="HasSse2"/>
    /// <seealso cref="HasSse3"/>
    /// <seealso cref="HasSse42"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasSse41: Boolean read GetHasSse41;

    /// <summary>
    ///  Determine whether the CPU has SSE4.2 features.
    ///
    ///  This always returns false on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasSse"/>
    /// <seealso cref="HasSse2"/>
    /// <seealso cref="HasSse3"/>
    /// <seealso cref="HasSse41"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasSse42: Boolean read GetHasSse42;

    /// <summary>
    ///  Determine whether the CPU has AVX features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasAvx2"/>
    /// <seealso cref="HasAvx512F"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasAvx: Boolean read GetHasAvx;

    /// <summary>
    ///  Determine whether the CPU has AVX2 features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasAvx"/>
    /// <seealso cref="HasAvx512F"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasAvx2: Boolean read GetHasAvx2;

    /// <summary>
    ///  Determine whether the CPU has AVX-512F (foundation) features.
    ///
    ///  This always returns False on CPUs that aren't using Intel instruction sets.
    /// </summary>
    /// <seealso cref="HasAvx"/>
    /// <seealso cref="HasAvx2"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasAvx512F: Boolean read GetHasAvx512F;

    /// <summary>
    ///  Determine whether the CPU has ARM SIMD (ARMv6) features.
    ///
    ///  This is different from ARM NEON, which is a different instruction set.
    ///
    ///  This always returns False on CPUs that aren't using ARM instruction sets.
    /// </summary>
    /// <seealso cref="HasNeon"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasArmSimd: Boolean read GetHasArmSimd;

    /// <summary>
    ///  Determine whether the CPU has NEON (ARM SIMD) features.
    ///
    ///  This always returns False on CPUs that aren't using ARM instruction sets.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasNeon: Boolean read GetHasNeon;

    /// <summary>
    ///  Determine whether the CPU has LSX (LOONGARCH SIMD) features.
    ///
    ///  This always returns False on CPUs that aren't using LOONGARCH instruction
    ///  sets.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasLsx: Boolean read GetHasLsx;

    /// <summary>
    ///  Determine whether the CPU has LASX (LOONGARCH SIMD) features.
    ///
    ///  This always returns False on CPUs that aren't using LOONGARCH instruction
    ///  sets.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property HasLasx: Boolean read GetHasLasx;

    /// <summary>
    ///  Get the amount of RAM configured in the system in MiB.
    ///
    ///  One MiB (Mebibyte) is 1,048,576 bytes.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property SystemRamMiB: Integer read GetSystemRamMiB;

    /// <summary>
    ///  Report the alignment this system needs for SIMD allocations.
    ///
    ///  This will return the minimum number of bytes to which a pointer must be
    ///  aligned to be compatible with SIMD instructions on the current machine. For
    ///  example, if the machine supports SSE only, it will return 16, but if it
    ///  supports AVX-512F, it'll return 64 (etc). This only reports values for
    ///  instruction sets SDL knows about, so if your SDL build doesn't have
    ///  HasAvx512F( then it might return 16 for the SSE support it sees and
    ///  not 64 for the AVX-512 instructions that exist but SDL doesn't know about.
    ///  Plan accordingly.
    /// </summary>
    /// <seealso cref="SdlAlignedAlloc"/>
    /// <seealso cref="SdlAlignedFree"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property SimdAlignment: Integer read GetSimdAlignment;
  end;
{$ENDREGION 'CPU Info'}

{$REGION 'Power'}
/// <summary>
///  SDL power management routines.
///
///  There is a single function in this category: SdlGetPowerInfo.
///
///  This function is useful for games on the go. This allows an app to know if
///  it's running on a draining battery, which can be useful if the app wants to
///  reduce processing, or perhaps framerate, to extend the duration of the
///  battery's charge. Perhaps the app just wants to show a battery meter when
///  fullscreen, or alert the user when the power is getting extremely low, so
///  they can save their game.
/// </summary>

type
  /// <summary>
  ///  The basic state for the system's power supply.
  ///
  ///  These are results returned by SdlGetPowerInfo.
  /// </summary>
  TSdlPowerState = (
    /// <summary>
    ///  Error determining power status
    /// </summary>
    Error     = SDL_POWERSTATE_ERROR,

    /// <summary>
    ///  Cannot determine power status
    /// </summary>
    Unknown   = SDL_POWERSTATE_UNKNOWN,

    /// <summary>
    ///  Not plugged in, running on the battery
    /// </summary>
    OnBattery = SDL_POWERSTATE_ON_BATTERY,

    /// <summary>
    ///  Plugged in, no battery available
    /// </summary>
    NoBattery = SDL_POWERSTATE_NO_BATTERY,

    /// <summary>
    ///  Plugged in, charging battery
    /// </summary>
    Charging  = SDL_POWERSTATE_CHARGING,

    /// <summary>
    ///  Plugged in, battery charged
    /// </summary>
    Charged   = SDL_POWERSTATE_CHARGED);

/// <summary>
///  Get the current power supply details.
///
///  You should never take a battery status as absolute truth. Batteries
///  (especially failing batteries) are delicate hardware, and the values
///  reported here are best estimates based on what that hardware reports. It's
///  not uncommon for older batteries to lose stored power much faster than it
///  reports, or completely drain when reporting it has 20 percent left, etc.
///
///  Battery status can change at any time; if you are concerned with power
///  state, you should call this function frequently, and perhaps ignore changes
///  until they seem to be stable for a few seconds.
///
///  It's possible a platform can only report battery percentage or time left
///  but not both.
/// </summary>
/// <param name="ASeconds">Set to the seconds of battery life left. This
///  will be set to -1 if we can't determine a value or there is no battery.</param>
/// <param name="APercent">Set to the percentage of battery life left,
///  between 0 and 100. This will be set to -1 if we can't determine a value
///  or there is no battery.</param>
/// <returns>The current battery state.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
function SdlGetPowerInfo(out ASeconds, APercent: Integer): TSdlPowerState; inline;
{$ENDREGION 'Power'}

{$REGION 'Message Boxes'}
/// <summary>
///  SDL offers a simple message box API, which is useful for simple alerts,
///  such as informing the user when something fatal happens at startup without
///  the need to build a UI for it (or informing the user _before_ your UI is
///  ready).
///
///  These message boxes are native system dialogs where possible.
///
///  There is both a customizable function (SdlShowMessageBox) that offers
///  lots of options for what to display and reports on what choice the user
///  made, and also a much-simplified version (SdlShowSimpleMessageBox),
///  merely takes a text message and title, and waits until the user presses a
///  single "OK" UI button. Often, this is all that is necessary.
/// </summary>

type
  /// <summary>
  ///  Message box flags.
  ///
  ///  If supported will display warning icon, etc.
  /// </summary>
  TSdlMessageBoxFlag = (
    /// <summary>
    ///  Error dialog
    /// </summary>
    Error              = 4,

    /// <summary>
    ///  Warning dialog
    /// </summary>
    Warning            = 5,

    /// <summary>
    ///  Information dialog
    /// </summary>
    Information        = 6,

    /// <summary>
    ///  Buttons placed left to right
    /// </summary>
    ButtonsLeftToRight = 7,

    /// <summary>
    ///  Buttons placed right to left
    /// </summary>
    ButtonsRightToLeft = 8);

  /// <summary>
  ///  A set of message box flags.
  /// </summary>
  TSdlMessageBoxFlags = set of TSdlMessageBoxFlag;

type
  /// <summary>
  ///  Message box button flags.
  /// </summary>
  TSdlMessageBoxButtonFlag = (
    /// <summary>
    ///  Marks the default button when return is hit
    /// </summary>
    ReturnKeyDefault = 0,

    /// <summary>
    ///  Marks the default button when escape is hit
    /// </summary>
    EscapeKeyDefault = 1);

  /// <summary>
  ///  A set of message box button flags.
  /// </summary>
  TSdlMessageBoxButtonFlags = set of TSdlMessageBoxButtonFlag;

type
  /// <summary>
  ///  Individual button data.
  /// </summary>
  TSdlMessageBoxButtonData = record
  public
    /// <summary>
    ///  Button flags
    /// </summary>
    Flags: TSdlMessageBoxButtonFlags;

    /// <summary>
    ///  User defined button ID (value returned via SdlShowMessageBox)
    /// </summary>
    ButtonID: Integer;

    /// <summary>
    ///  The button text
    /// </summary>
    Text: String;
  public
    /// <summary>
    ///  Creates data for a button.
    /// </summary>
    /// <param name="AText">The button text.</param>
    /// <param name="AID">(Optional) button ID. Defaults to 0.</param>
    /// <param name="AFlags">(Optional) button flags. Defaults to [].</param>
    constructor Create(const AText: String; const AID: Integer = 0;
      const AFlags: TSdlMessageBoxButtonFlags = []);
  end;
  PSdlMessageBoxButtonData = ^TSdlMessageBoxButtonData;

type
  /// <summary>
  ///  RGB value used in a message box color scheme
  /// </summary>
  TSdlMessageBoxColor = record
  public
    /// <summary>
    ///  Red value
    /// </summary>
    R: Byte;

    /// <summary>
    ///  Green value
    /// </summary>
    G: Byte;

    /// <summary>
    ///  Blue value
    /// </summary>
    B: Byte;
  public
    /// <summary>
    ///  Creates a messages box color.
    /// </summary>
    /// <param name="ARed">The red value.</param>
    /// <param name="AGreen">The red value.</param>
    /// <param name="ABlue">The red value.</param>
    constructor Create(const ARed, AGreen, ABlue: Byte);
  end;

type
  /// <summary>
  ///  An enumeration of indices inside the colors array of
  ///  TSdlMessageBoxColorScheme.
  /// </summary>
  TSdlMessageBoxColorType = (
    Background       = SDL_MESSAGEBOX_COLOR_BACKGROUND,
    Text             = SDL_MESSAGEBOX_COLOR_TEXT,
    ButtonBorder     = SDL_MESSAGEBOX_COLOR_BUTTON_BORDER,
    ButtonBackground = SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND,
    ButtonSelected   = SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED);

type
  /// <summary>
  ///  A set of colors to use for message box dialogs
  /// </summary>
  TSdlMessageBoxColorScheme = record
  public
    /// <summary>
    ///  The colors in the scheme
    /// </summary>
    Colors: array [TSdlMessageBoxColorType] of TSdlMessageBoxColor;
  end;
  PSdlMessageBoxColorScheme = ^TSdlMessageBoxColorScheme;

type
  /// <summary>
  ///  MessageBox structure containing title, text, window, etc.
  /// </summary>
  TSdlMessageBoxData = record
  public
    /// <summary>
    ///  Message box flags
    /// </summary>
    Flags: TSdlMessageBoxFlags;

    /// <summary>
    ///  Parent window, can be nil
    /// </summary>
    Window: TSdlWindow;

    /// <summary>
    ///  Title
    /// </summary>
    Title: String;

    /// <summary>
    ///  Message text
    /// </summary>
    Text: String;

    /// <summary>
    ///  Array of buttons
    /// </summary>
    Buttons: TArray<TSdlMessageBoxButtonData>;

    /// <summary>
    ///  Pointer ta TSdlMessageBoxColorScheme.
    ///  Can be nil to use system settings
    /// </summary>
    ColorScheme: PSdlMessageBoxColorScheme;
  public
    /// <summary>
    ///  Creates a messages box color.
    /// </summary>
    /// <param name="AFlags">Message box flags.</param>
    /// <param name="ATitle">The title.</param>
    /// <param name="AMessage">The message text.</param>
    constructor Create(const AFlags: TSdlMessageBoxFlags;
      const ATitle, AMessage: String);
  end;

/// <summary>
///  Create a modal message box.
///
///  If your needs aren't complex, it might be easier to use
///  SdlShowSimpleMessageBox.
///
///  This function should be called on the thread that created the parent
///  window, or on the main thread if the messagebox has no parent. It will
///  block execution of that thread until the user clicks a button or closes the
///  messagebox.
///
///  This function may be called at any time, even before SdlInit. This makes
///  it useful for reporting errors like a failure to create a renderer or
///  OpenGL context.
///
///  On X11, SDL rolls its own dialog box with X11 primitives instead of a
///  formal toolkit like GTK+ or Qt.
///
///  Note that if SdlInit would fail because there isn't any available video
///  target, this function is likely to fail for the same reasons. If this is a
///  concern, check the return value from this function and fall back to writing
///  to stderr if you can.
/// </summary>
/// <param name="AData">The TSdlMessageBoxData record with title, text
///  and other options.</param>
/// <returns>The ID of the button the user pressed.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlShowSimpleMessageBox"/>
function SdlShowMessageBox(const AData: TSdlMessageBoxData): Integer;

/// <summary>
///  Display a simple modal message box.
///
///  If your needs aren't complex, this function is preferred over
///  SdlShowMessageBox.
///
///  This function should be called on the thread that created the parent
///  window, or on the main thread if the messagebox has no parent. It will
///  block execution of that thread until the user clicks a button or closes the
///  messagebox.
///
///  This function may be called at any time, even before SdlInit. This makes
///  it useful for reporting errors like a failure to create a renderer or
///  OpenGL context.
///
///  On X11, SDL rolls its own dialog box with X11 primitives instead of a
///  formal toolkit like GTK+ or Qt.
///
///  Note that if SdlInit would fail because there isn't any available video
///  target, this function is likely to fail for the same reasons. If this is a
///  concern, check the return value from this function and fall back to writing
///  to stderr if you can.
/// </summary>
/// <param name="AFlags">Message box flags.</param>
/// <param name="ATitle">Title.</param>
/// <param name="AMessage">Message text.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlShowMessageBox"/>
procedure SdlShowSimpleMessageBox(const AFlags: TSdlMessageBoxFlags;
  const ATitle, AMessage: String); overload;

/// <summary>
///  Display a simple modal message box.
///
///  If your needs aren't complex, this function is preferred over
///  SdlShowMessageBox.
///
///  This function should be called on the thread that created the parent
///  window, or on the main thread if the messagebox has no parent. It will
///  block execution of that thread until the user clicks a button or closes the
///  messagebox.
///
///  This function may be called at any time, even before SdlInit. This makes
///  it useful for reporting errors like a failure to create a renderer or
///  OpenGL context.
///
///  On X11, SDL rolls its own dialog box with X11 primitives instead of a
///  formal toolkit like GTK+ or Qt.
///
///  Note that if SdlInit would fail because there isn't any available video
///  target, this function is likely to fail for the same reasons. If this is a
///  concern, check the return value from this function and fall back to writing
///  to stderr if you can.
/// </summary>
/// <param name="AFlags">Message box flags.</param>
/// <param name="ATitle">Title.</param>
/// <param name="AMessage">Message text.</param>
/// <param name="AWindow">The parent window, or nil for no parent.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlShowMessageBox"/>
procedure SdlShowSimpleMessageBox(const AFlags: TSdlMessageBoxFlags;
  const ATitle, AMessage: String; const AWindow: TSdlWindow); overload;
{$ENDREGION 'Message Boxes'}

{$REGION 'Dialog Boxes'}
/// <summary>
///  File dialog support.
///
///  SDL offers file dialogs, to let users select files with native GUI
///  interfaces. There are "open" dialogs, "save" dialogs, and folder selection
///  dialogs. The app can control some details, such as filtering to specific
///  files, or whether multiple files can be selected by the user.
///
///  Note that launching a file dialog is a non-blocking operation; control
///  returns to the app immediately, and a callback is called later (possibly in
///  another thread) when the user makes a choice.
/// </summary>

type
  /// <summary>
  ///  An entry for filters for file dialogs.
  ///
  ///  `AName` is a user-readable label for the filter (for example, "Office
  ///  document").
  ///
  ///  `APattern` is a semicolon-separated list of file extensions (for example,
  ///  "doc;docx"). File extensions may only contain alphanumeric characters,
  ///  hyphens, underscores and periods. Alternatively, the whole string can be a
  ///  single asterisk ("*"), which serves as an "All files" filter.
  /// </summary>
  /// <seealso cref="TSdlDialogFileCallback"/>
  /// <seealso cref="TSdlDialog.ShowOpenFile"/>
  /// <seealso cref="TSdlDialog.ShowSaveFile"/>
  /// <seealso cref="TSdlDialog.ShowOpenFolder"/>
  TSdlDialogFileFilter = record
  public
    /// <summary>
    ///  A user-readable label for the filter (for example, "Office document").
    /// </summary>
    Name: String;

    /// <summary>
    ///  Semicolon-separated list of file extensions (for example, "doc;docx").
    ///
    ///  File extensions may only contain alphanumeric characters, hyphens,
    ///  underscores and periods. Alternatively, the whole string can be a
    ///  single asterisk ("*"), which serves as an "All files" filter.
    /// </summary>
    Pattern: String;
  end;

type
  /// <summary>
  ///  Callback used by file dialog functions.
  ///
  ///  The specific usage is described in each function.
  ///
  ///  If `AFilelist` is:
  ///
  ///  - nil: an error occurred, or the user didn't choose any file or canceled
  ///    the dialog.
  ///  - non-nil: the user chose one or more files.
  ///
  ///  The filter argument is the index of the filter that was selected, or -1
  ///  if no filter was selected or if the platform or method doesn't support
  ///  fetching the selected filter.
  ///
  ///  In Android, the `AFilelist` are `content://` URIs. They should be opened
  ///  using TSdlIOStream.Create with appropriate modes. This applies both to
  ///  open and save file dialog.
  /// </summary>
  /// <param name="AFileList">The file(s) chosen by the user.</param>
  /// <param name="AFilter">Index of the selected filter.</param>
  /// <seealso cref="TSdlDialogFileFilter"/>
  /// <seealso cref="TSdlDialog.ShowOpenFile"/>
  /// <seealso cref="TSdlDialog.ShowSaveFile"/>
  /// <seealso cref="TSdlDialog.ShowOpenFolder"/>
  TSdlDialogFileCallback = procedure(const AFileList: TArray<String>;
    const AFilter: Integer) of object;

type
  /// <summary>
  ///  Provides (file) dialog functionality
  /// </summary>
  TSdlDialog = record
  {$REGION 'Internal Declarations'}
  private const
    MAX_SIMULTANEOUS_DIALOGS = 8;
  private class var
    FCallbacks: array [0..MAX_SIMULTANEOUS_DIALOGS - 1] of TSdlDialogFileCallback;
    FUtf8Filters: array [0..MAX_SIMULTANEOUS_DIALOGS - 1] of TArray<UTF8String>;
    FFilters: array [0..MAX_SIMULTANEOUS_DIALOGS - 1] of TArray<SDL_DialogFileFilter>;
  private type
    TFilters = record
    public
      Filters: PSDL_DialogFileFilter;
      Count: Integer;
    end;
  private
    class procedure Callback(AUserData: Pointer; const AFileList: PPUTF8Char;
      AFilter: Integer); cdecl; static;
  private
    class function Setup(const ACallback: TSdlDialogFileCallback;
      const ASrcFilters: TArray<TSdlDialogFileFilter>;
      out AOutFilters: PSDL_DialogFileFilter; out AOutCount: Integer): Integer; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Displays a dialog that lets the user select a file on their filesystem
    ///  to open a file from.
    ///
    ///  This is an asynchronous function; it will return immediately, and the
    ///  result will be passed to the callback.
    ///
    ///  The callback will be invoked with a list of files the user chose. The
    ///  list will be nil (empty) if the user canceled the dialog.
    ///
    ///  Note that the callback may be called from a different thread than the
    ///  one the function was invoked on.
    ///
    ///  Depending on the platform, the user may be allowed to input paths that
    ///  don't yet exist.
    /// </summary>
    /// <param name="ACallback">The callback to be invoked when the user selects
    ///  one or more files and accepts, or cancels the dialog, or an error occurs.</param>
    /// <param name="AWindow">The window that the dialog should be modal for,
    ///  may be nil. Not all platforms support this option.</param>
    /// <param name="AFilters">(Optional) list of filters. Not all platforms
    ///  support this option, and platforms that do support it may allow the
    ///  user to ignore the filters.</param>
    /// <param name="ADefaultLocation">(Optional) default folder or file to
    /// start the dialog at. Not all platforms support this option.</param>
    /// <param name="AAllowMany">(Optional) whether the user will be allowed to
    ///  select multiple entries. Defaults to False. Not all platforms support
    ///  this option.</param>
    /// <seealso cref="TSdlDialogFileCallback"/>
    /// <seealso cref="TSdlDialogFileFilter"/>
    /// <seealso cref="ShowSaveFile"/>
    /// <seealso cref="ShowOpenFolder"/>
    /// <remarks>
    ///  This method should be called only from the main thread. The callback
    ///  may be invoked from the same thread or from a different one, depending
    ///  on the OS's constraints.
    /// </remarks>
    class procedure ShowOpenFile(const ACallback: TSdlDialogFileCallback;
      const AWindow: TSdlWindow; const AFilters: TArray<TSdlDialogFileFilter> = nil;
      const ADefaultLocation: String = ''; const AAllowMany: Boolean = False); static;

    /// <summary>
    ///  Displays a dialog that lets the user choose a new or existing file on
    ///  their filesystem to save a file to.
    ///
    ///  This is an asynchronous function; it will return immediately, and the
    ///  result will be passed to the callback.
    ///
    ///  The callback will be invoked with a list with the file the user chose.
    ///  The list will be empty if the user canceled the dialog.
    ///
    ///  Note that the callback may be called from a different thread than the
    ///  one the function was invoked on.
    ///
    ///  The chosen file may or may not already exist.
    /// </summary>
    /// <param name="ACallback">The callback to be invoked when the user selects
    ///  a file and accepts, or cancels the dialog, or an error occurs.</param>
    /// <param name="AWindow">The window that the dialog should be modal for,
    ///  may be nil. Not all platforms support this option.</param>
    /// <param name="AFilters">(Optional) list of filters. Not all platforms
    ///  support this option, and platforms that do support it may allow the
    ///  user to ignore the filters.</param>
    /// <param name="ADefaultLocation">(Optional) default folder or file to
    /// start the dialog at. Not all platforms support this option.</param>
    /// <seealso cref="TSdlDialogFileCallback"/>
    /// <seealso cref="TSdlDialogFileFilter"/>
    /// <seealso cref="ShowOpenFile"/>
    /// <seealso cref="ShowOpenFolder"/>
    /// <remarks>
    ///  This method should be called only from the main thread. The callback
    ///  may be invoked from the same thread or from a different one, depending
    ///  on the OS's constraints.
    /// </remarks>
    class procedure ShowSaveFile(const ACallback: TSdlDialogFileCallback;
      const AWindow: TSdlWindow; const AFilters: TArray<TSdlDialogFileFilter> = nil;
      const ADefaultLocation: String = ''); static;

    /// <summary>
    ///  Displays a dialog that lets the user select a folder on their
    ///  filesystem.
    ///
    ///  This is an asynchronous function; it will return immediately, and the
    ///  result will be passed to the callback.
    ///
    ///  The callback will be invoked with a list with the folder the user chose.
    ///  The list will be empty if the user canceled the dialog.
    ///
    ///  Note that the callback may be called from a different thread than the one
    ///  the function was invoked on.
    ///
    ///  Depending on the platform, the user may be allowed to input paths that
    ///  don't yet exist.
    /// </summary>
    /// <param name="ACallback">The callback to be invoked when the user selects
    ///  a folder and accepts, or cancels the dialog, or an error occurs.</param>
    /// <param name="AWindow">The window that the dialog should be modal for,
    ///  may be nil. Not all platforms support this option.</param>
    /// <param name="ADefaultLocation">(Optional) default folder or file to
    /// start the dialog at. Not all platforms support this option.</param>
    /// <param name="AAllowMany">(Optional) whether the user will be allowed to
    ///  select multiple entries. Defaults to False. Not all platforms support
    ///  this option.</param>
    /// <seealso cref="TSdlDialogFileCallback"/>
    /// <seealso cref="ShowOpenFile"/>
    /// <seealso cref="ShowSaveFile"/>
    /// <remarks>
    ///  This method should be called only from the main thread. The callback
    ///  may be invoked from the same thread or from a different one, depending
    ///  on the OS's constraints.
    /// </remarks>
    class procedure ShowOpenFolder(const ACallback: TSdlDialogFileCallback;
      const AWindow: TSdlWindow; const ADefaultLocation: String = '';
      const AAllowMany: Boolean = False); static;
  end;
{$ENDREGION 'Dialog Boxes'}

{$REGION 'System Tray'}
/// <summary>
///  SDL offers a way to add items to the "system tray" (more correctly called
///  the "notification area" on Windows). On platforms that offer this concept,
///  an SDL app can add a tray icon, submenus, checkboxes, and clickable
///  entries, and register a callback that is fired when the user clicks on
///  these pieces.
/// </summary>

type
  /// <summary>
  ///  Flags that control the creation of system tray entries.
  ///
  ///  Some of these flags are required; exactly one of them must be specified at
  ///  the time a tray entry is created. Other flags are optional.
  /// </summary>
  /// <seealso cref="TSdlTrayMenu.Insert"/>
  TSdlTrayEntryFlag = (
    /// <summary>
    ///  Make the entry a simple button. Required.
    /// </summary>
    Button   = 0,

    /// <summary>
    ///  Make the entry a checkbox. Required.
    /// </summary>
    Checkbox = 1,

    /// <summary>
    ///  Prepare the entry to have a submenu. Required.
    /// </summary>
    SubMenu  = 2,

    /// <summary>
    ///  Make the entry checked. This is valid only for checkboxes. Optional.
    /// </summary>
    Checked  = 30,

    /// <summary>
    ///  Make the entry disabled. Optional.
    /// </summary>
    Disabled = 31);

type
  /// <summary>
  ///  A set of tray entry flags.
  /// </summary>
  TSdlTrayEntryFlags = set of TSdlTrayEntryFlag;

type
  /// <summary>
  ///  A menu/submenu on a system tray object.
  /// </summary>
  TSdlTrayMenu = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TrayMenu;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTrayMenu; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTrayMenu; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTrayMenu; inline; static;
  public
  end;

type
  /// <summary>
  ///  A toplevel system tray object.
  /// </summary>
  TSdlTray = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Tray;
    function GetMenu: TSdlTrayMenu; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTray; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTray; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTray; inline; static;
  public
    /// <summary>
    ///  Create an icon to be placed in the operating system's tray, or equivalent.
    ///
    ///  Many platforms advise not using a system tray unless persistence is a
    ///  necessary feature. Avoid needlessly creating a tray icon, as the user may
    ///  feel like it clutters their interface.
    ///
    ///  Using tray icons require the video subsystem.
    /// </summary>
    /// <param name="AIcon">A surface to be used as icon. May be nil.</param>
    /// <param name="ATooltip">(Optional) tooltip to be displayed when the mouse
    ///  hovers the icon. Not supported on all platforms.</param>
    /// <seealso cref="TSdlTrayMenu"/>
    /// <seealso cref="Menu"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AIcon: TSdlSurface; const ATooltip: String = '');

    /// <summary>
    ///  Destroys the tray object.
    ///
    ///  This also destroys all associated menus and entries.
    /// </summary>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    procedure Free;

    /// <summary>
    ///  Updates the system tray icon's icon.
    /// </summary>
    /// <param name="AIcon">The new icon. May be nil.</param>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    procedure SetIcon(const AIcon: TSdlSurface); inline;

    /// <summary>
    ///  Updates the system tray icon's tooltip.
    /// </summary>
    /// <param name="ATooltip">The new tooltip.</param>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    procedure SetTooltip(const ATooltip: String); inline;

    /// <summary>
    ///  Create a menu for the system tray.
    ///
    ///  This should be called at most once per tray icon.
    ///
    ///  This function does the same thing as TSdlTrayEntry.CreateSubMenu,
    ///  except that it works on a TSdlTray instead of a TSdlTrayEntry.
    ///
    ///  A menu does not need to be destroyed; it will be destroyed with the tray.
    /// </summary>
    /// <returns>The newly created menu.</returns>
    /// <seealso cref="Menu"/>
    /// <seealso cref="TSdlTrayMenu.Parent"/>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    function CreateMenu: TSdlTrayMenu; inline;

    /// <summary>
    ///  Update the trays.
    ///
    ///  This is called automatically by the event loop and is only needed if you're
    ///  using trays but aren't handling SDL events.
    /// </summary>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure Update; inline; static;

    /// <summary>
    ///  The previously created tray menu.
    ///
    ///  You should have called CreateMenu. This property allows you to fetch it
    ///  again later.
    ///
    ///  This property does the same thing as TSdlTrayEntry.Submenu, except that
    ///  it works on a TSdlTray instead of a TSdlTrayEntry.
    ///
    ///  A menu does not need to be destroyed; it will be destroyed with the tray.
    /// </summary>
    /// <seealso cref="CreateMenu"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property Menu: TSdlTrayMenu read GetMenu;
  end;

type
  /// <summary>
  ///  An entry on a system tray object.
  /// </summary>
  TSdlTrayEntry = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TrayEntry;
    function GetSubmenu: TSdlTrayMenu; inline;
    function GetCaption: String; inline;
    procedure SetCaption(const AValue: String); inline;
    function GetIsChecked: Boolean; inline;
    procedure SetIsChecked(const AValue: Boolean); inline;
    function GetIsEnabled: Boolean; inline;
    procedure SetIsEnabled(const AValue: Boolean); inline;
    function GetParent: TSdlTrayMenu; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTrayEntry; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTrayEntry; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTrayEntry; inline; static;
  public
    /// <summary>
    ///  Create a submenu for the system tray entry.
    ///
    ///  This should be called at most once per tray entry.
    ///
    ///  This function does the same thing as TSdlTray.CreateMenu, except that
    ///  works on a TSdlTrayEntry instead of a TSdlTray.
    ///
    ///  A menu does not need to be destroyed; it will be destroyed with the tray.
    /// </summary>
    /// <returns>The newly created menu.</returns>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <seealso cref="Submenu"/>
    /// <seealso cref="TSdlTrayMenu.ParentEntry"/>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    function CreateSubmenu: TSdlTrayMenu; inline;

    /// <summary>
    ///  Removes this tray entry.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Entries"/>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    procedure Remove; inline;

    /// <summary>
    ///  Simulate a click on the tray entry.
    /// </summary>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    procedure Click; inline;

    /// <summary>
    ///  Gets a previously created tray entry submenu.
    ///
    ///  You should have called CreateSubmenu. This property allows you to fetch
    ///  it again later.
    ///
    ///  This property does the same thing as TSdlTray.Menu, except that it
    ///  works on a TSdlTrayEntry instead of a TSdlTray.
    ///
    ///  A menu does not need to be destroyed; it will be destroyed with the tray.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <seealso cref="CreateSubmenu"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property Submenu: TSdlTrayMenu read GetSubmenu;

    /// <summary>
    ///  The caption of the entry, or empty if the entry is a separator.
    ///
    ///  An entry cannot change between a separator and an ordinary entry; that is,
    ///  it is not possible to set a non-empty caption on an entry that has an empty
    ///  caption (separators), or to set an empty caption to an entry that has a
    ///  non-empty caption. It will silently fail if that happens.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Entries"/>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property Caption: String read GetCaption write SetCaption;

    /// <summary>
    ///  Whether or not the entry is checked.
    ///
    ///  The entry must have been created with TSdlTrayEntryFlag.Checkbox.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Entries"/>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property IsChecked: Boolean read GetIsChecked write SetIsChecked;

    /// <summary>
    ///  Whether or not an entry is enabled.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Entries"/>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property IsEnabled: Boolean read GetIsEnabled write SetIsEnabled;

    /// <summary>
    ///  The menu containing the tray entry.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property Parent: TSdlTrayMenu read GetParent;
  end;

  _TSdlTrayMenuHelper = record helper for TSdlTrayMenu
  {$REGION 'Internal Declarations'}
  private
    function GetEntries: TArray<TSdlTrayEntry>;
    function GetParentEntry: TSdlTrayEntry; inline;
    function GetParent: TSdlTray; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Insert a tray entry at a given position.
    ///
    ///  If ACaption is empty, the entry will be a separator. Many functions won't
    ///  work for an entry that is a separator.
    ///
    ///  An entry does not need to be destroyed; it will be destroyed with the tray.
    /// </summary>
    /// <param name="APos">The desired position for the new entry. Entries at
    ///  or following this place will be moved. If APos is -1, the entry is appended.</param>
    /// <param name="ACaption">The text to be displayed on the entry, or empty for
    ///  a separator.</param>
    /// <param name="AFlags">A combination of flags, some of which are mandatory.</param>
    /// <returns>The newly created entry.</returns>
    /// <exception name="ESdlError">Raised on failure (e.g. when APos is out
    ///  of bounds).</exception>
    /// <seealso cref="TSdlTrayEntryFlags"/>
    /// <seealso cref="Entries"/>
    /// <seealso cref="TSdlTrayEntry.Remove"/>
    /// <seealso cref="TSdlTrayEntry.Parent"/>
    /// <remarks>
    ///  This method should be called on the thread that created the tray.
    /// </remarks>
    function Insert(const APos: Integer; const ACaption: String;
      const AFlags: TSdlTrayEntryFlags): TSdlTrayEntry; inline;

    /// <summary>
    ///  A list of entries in the menu, in order.
    /// </summary>
    /// <seealso cref="TSdlTrayEntry.Remove"/>
    /// <seealso cref="Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property Entries: TArray<TSdlTrayEntry> read GetEntries;

    /// <summary>
    ///  The entry for which this menu is a submenu, if the current menu is a
    ///  submenu.
    ///
    ///  Either this property or Parent will return non-nil for any given menu.
    /// </summary>
    /// <returns>The parent entry, or nil if this menu is not a submenu.</returns>
    /// <seealso cref="TSdlTrayEntry.CreateSubmenu"/>
    /// <seealso cref="TSdlTrayEntry.Parent"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property ParentEntry: TSdlTrayEntry read GetParentEntry;

    /// <summary>
    ///  The tray for which this menu is the first-level menu, if the current
    ///  menu isn't a submenu.
    ///
    ///  Either this property or ParentEntry will return non-nil for any given menu.
    /// </summary>
    /// <param name="AMenu">the menu for which to get the parent enttrayry.</param>
    /// <returns>the parent tray, or NULL if this menu is a submenu.</returns>
    /// <seealso cref="TSdlTray.CreateMenu"/>
    /// <seealso cref="ParentEntry"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property Parent: TSdlTray read GetParent;
  end;

type
  /// <summary>
  ///  A callback that is invoked when a tray entry is selected.
  /// </summary>
  /// <param name="AEntry">The tray entry that was selected.</param>
  /// <seealso cref="TSdlTrayEntry.OnSelect"/>
  TSdlTrayCallback = procedure(const AEntry: TSdlTrayEntry) of object;

type
  _TSdlTrayEntryHelper = record helper for TSdlTrayEntry
  {$REGION 'Internal Declarations'}
  private
    procedure SetOnSelect(const AValue: TSdlTrayCallback);
  private
    class procedure Callback(AUserData: Pointer; AEntry: SDL_TrayEntry); cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  A callback to be invoked when the entry is selected.
    /// </summary>
    /// <seealso cref="TSdlTrayMenu.Entries"/>
    /// <seealso cref="TSdlTrayMenu.Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the tray.
    /// </remarks>
    property OnSelect: TSdlTrayCallback write SetOnSelect;
  end;
{$ENDREGION 'System Tray'}

{$REGION 'Locale Info'}
/// <summary>
///  SDL locale services.
///
///  This provides a way to get a list of preferred locales (language plus
///  country) for the user.
/// </summary>

type
  /// <summary>
  ///  A record to provide locale data.
  ///
  ///  Locale data is split into a spoken language, like English, and an optional
  ///  country, like Canada. The language will be in ISO-639 format (so English
  ///  would be 'en'), and the country, if not empty, will be an ISO-3166 country
  ///  code (so Canada would be 'CA').
  /// </summary>
  TSdlLocale = record
  {$REGION 'Internal Declarations'}
  private
    FLanguage: String;
    FCountry: String;
    class function GetPreferredLocales: TArray<TSdlLocale>; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  A language name, like 'en' for English.
    /// </summary>
    property Language: String read FLanguage;

    /// <summary>
    ///  A country, like 'US' for America. Can be empty.
    /// </summary>
    property Country: String read FCountry;

    /// <summary>
    ///  Report the user's preferred locales.
    ///
    ///  Language strings are (lowercase) ISO-639 language specifiers (such as
    ///  'en' for English, 'de' for German, etc). Country strings are
    ///  (uppercase) ISO-3166 country codes (such as 'US' for the United States,
    ///  'CA' for Canada, etc). Country might be empty if there's no specific
    ///  guidance on them (so you might get {'en', 'US'} for American English,
    ///  but {'en', ''} means "English language, generically"). Language strings
    ///  are never empty.
    ///
    ///  Please note that not all of these strings are 2 characters; some are
    ///  three or more.
    ///
    ///  The returned list of locales are in the order of the user's preference.
    ///  For example, a German citizen that is fluent in US English and knows
    ///  enough Japanese to navigate around Tokyo might have a list like:
    ///  [ {'de', ''}, {'en', 'US'}, {'jp', ''} ]. Someone from England might
    ///  prefer British English (where "color" is spelled "colour", etc), but
    ///  will settle for anything like it: [ {'en', 'GB'}, {'en', ''} ].
    ///
    ///  This property returns an empty array when the platform does not
    ///  supply this information at all.
    ///
    ///  This might be a "slow" call that has to query the operating system. It's
    ///  best to ask for this once and save the results. However, this list can
    ///  change, usually because the user has changed a system preference outside
    ///  of your program; SDL will send an TSdlEventKind.LocaleChanged event in
    ///  this case, if possible, and you can call this function again to get an
    ///  updated copy of preferred locales.
    /// </summary>
    class property PreferredLocales: TArray<TSdlLocale> read GetPreferredLocales;
  end;
{$ENDREGION 'Locale Info'}

{$REGION 'Process Control'}
/// <summary>
///  Process control support.
///
///  These functions provide a cross-platform way to spawn and manage OS-level
///  processes.
///
///  You can create a new subprocess with TSdlProcess and optionally read and
///  write to it using TSdlProcess.Read or TSdlProcess.Input and
///  TSdlProcess.Output. If more advanced functionality like chaining input
///  between processes is necessary, you can use the constructor that takes
///  TSdlProperties.
///
///  You can get the status of a created process with TSdlProcess.Wait, or
///  terminate the process with TSdlProcess.Kill.
///
///  Don't forget to call TSdlProcess.Free to clean up, whether the process
///  process was killed, terminated on its own, or is still running!
/// </summary>

type
  /// <summary>
  ///  Description of where standard I/O should be directed when creating a
  ///  process.
  ///
  ///  If a standard I/O stream is set to Inherited, it will go to the same
  ///  place as the application's I/O stream. This is the default for
  ///  standard output and standard error.
  ///
  ///  If a standard I/O stream is set to Null, it is connected to `NUL:` on
  ///  Windows and `/dev/null` on POSIX systems. This is the default
  ///  for standard input.
  ///
  ///  If a standard I/O stream is set to App, it is connected to a new
  ///  TSdlIOStream that is available to the application. Standard input
  ///  will be available as `TSdlProperty.ProcessStdIn` and allows
  ///  TSdlProcess.Input, standard output will be available as
  ///  `TSdlProperty.ProcessStdOut` and allows TSdlProcess.Read and
  ///  TSdlProcess.Output, and standard error will be available as
  ///  `TSdlProperty.ProcessStdErr` in the properties for the created process.
  ///
  ///  If a standard I/O stream is set to Redirect, it is connected to an
  ///  existing TSdlIOStream provided by the application. Standard
  ///  input is provided using `TSdlProperty.ProcessCreateStdIn`, standard
  ///  output is provided using `TSdlProperty.ProcessCreateStdOut`, and
  ///  standard error is provided using `TSdlProperty.ProcessCreateStdErr`
  ///  in the creation properties. These existing streams should be closed by the
  ///  application once the new process is created.
  ///
  ///  In order to use an TSdlIOStream with Redirect, it must have
  /// `TSdlProperty.IOStreamWindowHandle` or `TSdlProperty.IOStreamFileDescriptor`
  /// set. This is True for streams representing files and process I/O.
  /// </summary>
  /// <seealso cref="TSdlProcess"/>
  /// <seealso cref="TSdlProcess.Properties"/>
  /// <seealso cref="TSdlProcess.Read"/>
  /// <seealso cref="TSdlProcess.Input"/>
  /// <seealso cref="TSdlProcess.Output"/>
  TSdlProcessIO = (
    /// <summary>
    ///  The I/O stream is inherited from the application.
    /// </summary>
    &Inherited = SDL_PROCESS_STDIO_INHERITED,

    /// <summary>
    ///  The I/O stream is ignored.
    /// </summary>
    Null       = SDL_PROCESS_STDIO_NULL,

    /// <summary>
    ///  The I/O stream is connected to a new TSdlIOStream that the application
    ///  can read or write
    /// </summary>
    App        = SDL_PROCESS_STDIO_APP,

    /// <summary>
    ///  The I/O stream is redirected to an existing TSdlIOStream.
    /// </summary>
    Redirect   = SDL_PROCESS_STDIO_REDIRECT);

type
  /// <summary>
  ///  A system process.
  /// </summary>
  TSdlProcess = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Process;
    function GetProperties: TSdlProperties; inline;
    function GetInput: TSdlIOStream; inline;
    function GetOutput: TSdlIOStream; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlProcess; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlProcess; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlProcess; inline; static;
  public
    /// <summary>
    ///  Create a new process.
    ///
    ///  The path to the executable is supplied in AExePath. AArgs are
    ///  additional arguments passed on the command line of the new process.
    ///
    ///  Setting APipeStdIO to True is equivalent to setting
    ///  `TSdlProperty.ProcessCreateStdIn` and `TSdlProperty.ProcessCreateStdOut`
    ///  to `TSdlProcessStrIO.App`, and will allow the use of Read or Input and
    ///  Output.
    ///
    ///  See the other constructor for more details.
    /// </summary>
    /// <param name="AExePath">Path to the executable.</param>
    /// <param name="AArgs">Arguments for the new process.</param>
    /// <param name="APipeStdIO">True to create pipes to the process's standard
    ///  input and from the process's standard output, False for the process to
    ///   have no input and inherit the application's standard output.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Properties"/>
    /// <seealso cref="Read"/>
    /// <seealso cref="Input"/>
    /// <seealso cref="Output"/>
    /// <seealso cref="Kill"/>
    /// <seealso cref="Wait"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AExePath: String; const AArgs: TArray<String>;
      const APipeStdIO: Boolean); overload;

    /// <summary>
    ///  Create a new process with the specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlProperty.ProcessCreateArgs`: an array of strings (PUTF8Char)
    ///    containing the program to run, any arguments, and a nil pointer.
    ///    This is a required property.
    ///  - `TSdlProperty.ProcessCreateEnvironment`: a TSdlEnvironment
    ///    pointer. If this property is set, it will be the entire environment for
    ///    the process, otherwise the current environment is used.
    ///  - `TSdlProperty.ProcessCreateStdIn`: a TSdlProcessIO value describing
    ///    where standard input for the process comes from, defaults to
    ///    `TSdlProcessStdIO.Null`.
    ///  - `TSdlProperty.ProcessCreateStdInStream`: a TSdlIOStream pointer used
    ///    for standard input when `TSdlProperty.ProcessCreateStdIn` is set to
    ///    `TSdlProcessStdIO.Redirect`.
    ///  - `TSdlProperty.ProcessCreateStdOut`: a TSdlProcessIO value
    ///    describing where standard output for the process goes go, defaults to
    ///    `TSdlProcessStdIO.Inherited`.
    ///  - `TSdlProperty.ProcessCreateStdOutStream`: a TSdlIOStream pointer used
    ///    for standard output when `TSdlProperty.ProcessCreateStdOut` is set
    ///    `TSdlProcessStdIO.Redirect`.
    ///  - `TSdlProperty.ProcessCreateStdErr`: a TSdlProcessIO value
    ///    describing where standard error for the process goes go, defaults to
    ///    `TSdlProcessStdIO.Inherited`.
    ///  - `TSdlProperty.ProcessCreateStdErrStream`: a TSdlIOStream pointer used
    ///    for standard error when `TSdlProperty.ProcessCreateStdErr` is set to
    ///    `TSdlProcessStdIO.Redirect`.
    ///  - `TSdlProperty.ProcessCreateStdErrToStdOut`: True if the error
    ///    output of the process should be redirected into the standard output of
    ///    the process. This property has no effect if
    ///    `TSdlProperty.ProcessCreateStdErr` is set.
    ///  - `TSdlProperty.ProcessCreateBackground`: True if the process should
    ///    run in the background. In this case the default input and output is
    ///    `TSdlProcessStdIO.Null` and the exitcode of the process is not
    ///    available, and will always be 0.
    ///
    ///  On POSIX platforms, wait() and waitpid(-1, ...) should not be called, and
    ///  SIGCHLD should not be ignored or handled because those would prevent SDL
    ///  from properly tracking the lifetime of the underlying process. You should
    ///  use Wait instead.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Properties"/>
    /// <seealso cref="Read"/>
    /// <seealso cref="Input"/>
    /// <seealso cref="Output"/>
    /// <seealso cref="Kill"/>
    /// <seealso cref="Wait"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AProps: TSdlProperties); overload;

    /// <summary>
    ///  Destroy the previously created process object.
    ///
    ///  Note that this does not stop the process, just destroys the SDL object
    ///  used to track it. If you want to stop the process you should use Kill.
    /// </summary>
    /// <seealso cref="Kill"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Read all the output from a process.
    ///
    ///  If a process was created with I/O enabled, you can use this function to
    ///  read the output. This function blocks until the process is complete,
    ///  capturing all output, and providing the process exit code.
    /// </summary>
    /// <returns>The data.</returns>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function Read: TBytes; overload; inline;

    /// <summary>
    ///  Read all the output from a process.
    ///
    ///  If a process was created with I/O enabled, you can use this function to
    ///  read the output. This function blocks until the process is complete,
    ///  capturing all output, and providing the process exit code.
    /// </summary>
    /// <param name="AExitcode">Is set to the process exit code if the process
    ///  has exited.</param>
    /// <returns>The data.</returns>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function Read(out AExitCode: Integer): TBytes; overload; inline;

    /// <summary>
    ///  Stop the process.
    /// </summary>
    /// <param name="AForce">(Optional) True to terminate the process
    ///  immediately, False (Default) to try to stop the process gracefully. In
    ///  general you should try to stop the process gracefully first as
    ///  terminating a process may leave it with half-written data or in some
    ///  other unstable state.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Wait"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure Kill(const AForce: Boolean = False); inline;

    /// <summary>
    ///  Wait for the process to finish.
    ///
    ///  This can be called multiple times to get the status of a process.
    ///
    ///  If you create a process with standard output piped to the application
    ///  (`APipeStdIO` being True) then you should read all of the process output
    ///  before calling Wait. If you don't do this the process might be
    ///  blocked indefinitely waiting for output to be read and Wait
    ///  will never return True.
    /// </summary>
    /// <param name="ABlock">If True, block until the process finishes;
    ///  otherwise, report on the process' status.</param>
    /// <returns>True if the process exited, False otherwise.</returns>
    /// <seealso cref="Kill"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function Wait(const ABlock: Boolean): Boolean; overload; inline;

    /// <summary>
    ///  Wait for the process to finish.
    ///
    ///  This can be called multiple times to get the status of a process.
    ///
    ///  The exit code will be the exit code of the process if it terminates
    ///  normally, a negative signal if it terminated due to a signal, or -255
    ///  otherwise. It will not be changed if the process is still running.
    ///
    ///  If you create a process with standard output piped to the application
    ///  (`APipeStdIO` being True) then you should read all of the process output
    ///  before calling Wait. If you don't do this the process might be
    ///  blocked indefinitely waiting for output to be read and Wait
    ///  will never return True.
    /// </summary>
    /// <param name="ABlock">If True, block until the process finishes;
    ///  otherwise, report on the process' status.</param>
    /// <param name="AExitcode">Is set to the process exit code if the process
    ///  has exited.</param>
    /// <returns>True if the process exited, False otherwise.</returns>
    /// <seealso cref="Kill"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function Wait(const ABlock: Boolean; out AExitCode: Integer): Boolean; overload; inline;

    /// <summary>
    ///  The TSdlIOStream associated with process standard input.
    ///
    ///  The process must have been created with APipeStdIO set to True, or with
    ///  `TSdlProperty.ProcessCreateStdIn` set to `TSdlProcessStdIO.App`.
    ///
    ///  Writing to this stream can return less data than expected if the process
    ///  hasn't read its input. It may be blocked waiting for its output to be read,
    ///  if so you may need to use Output and read the output in parallel with
    ///  writing input.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Output"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Input: TSdlIOStream read GetInput;

    /// <summary>
    ///  The TSdlIOStream associated with process standard output.
    ///
    ///  The process must have been created with APipeStdIO set to True, or with
    ///  `TSdlProperty.ProcessCreateStdOut` set to `TSdlProcessStdIO.App`.
    ///
    ///  Reading from this stream can return 0 with TSdlIOStream.Status returning
    ///  TSdlIOStatus.NotReady if no output is available yet.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Input"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Output: TSdlIOStream read GetOutput;

    /// <summary>
    ///  The properties associated with a process.
    ///
    ///  The following read-only properties are provided by SDL:
    ///
    ///  - `TSdlProperty.ProcessPid`: the process ID of the process.
    ///  - `TSdlProperty.ProcessStdIn`: a TSdlIOStream that can be used to
    ///    write input to the process, if it was created with
    ///    `TSdlProperty.ProcessCreateStdIn` set to `TSdlProcessIO.App`.
    ///  - `TSdlProperty.ProcessStdOut`: a non-blocking TSdlIOStream that can
    ///    be used to read output from the process, if it was created with
    ///    `TSdlProperty.ProcessCreateStdOut` set to `TSdlProcessIO.App`.
    ///  - `TSdlProperty.ProcessStdErr`: a non-blocking TSdlIOStream that can
    ///    be used to read error output from the process, if it was created with
    ///    `TSdlProperty.ProcessCreateStdErr` set to `TSdlProcessIO.App`.
    ///  - `TSdlProperty.ProcessBackground`: True if the process is running in
    ///    the background.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;
{$ENDREGION 'Process Control'}

{$REGION 'Platform-specific Functionality'}
/// <summary>
///  Platform-specific SDL API functions. These are functions that deal with
///  needs of specific operating systems, that didn't make sense to offer as
///  platform-independent, generic APIs.
///
///  Most apps can make do without these functions, but they can be useful for
///  integrating with other parts of a specific system, adding platform-specific
///  polish to an app, or solving problems that only affect one target.
/// </summary>

{$IF Defined(MSWINDOWS)}
/// <summary>
///  Get the D3D9 adapter index that matches the specified display.
///
///  The returned adapter index can be passed to `IDirect3D9.CreateDevice` and
///  controls on which monitor a full screen application will appear.
/// </summary>
/// <param name="ADisplayID">The instance of the display to query.</param>
/// <returns>The D3D9 adapter index.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
function SdlGetDirect3D9AdapterIndex(const ADisplayID: TSdlDisplayID): Integer; inline;

/// <summary>
///  Get the DXGI Adapter and Output indices for the specified display.
///
///  The DXGI Adapter and Output indices can be passed to `EnumAdapters` and
///  `EnumOutputs` respectively to get the objects required to create a DX10 or
///  DX11 device and swap chain.
/// </summary>
/// <param name="ADisplayID">The instance of the display to query.</param>
/// <param name="AAdapterIndex">Is set to the adapter index.</param>
/// <param name="AOutputIndex">Is set to the output index.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
procedure SdlGetDxgiOutputInfo(const ADisplayID: TSdlDisplayID;
  out AAdapterIndex, AOutputIndex: Integer); inline;
{$ELSEIF Defined(IOS)}
/// <summary>
///  Enable or disable the SDL event pump on Apple iOS.
/// </summary>
/// <param name="AEnabled">True to enable the event pump, False to disable it.</param>
procedure SdlSetiOSEventPump(const AEnabled: Boolean); inline;
{$ELSEIF Defined(ANDROID)}
type
  /// <summary>
  ///  The state of external storage.
  ///  See the official Android developer guide for more information:
  ///  <see href="http://developer.android.com/guide/topics/data/data-storage.html">Data and File Storage</see>
  /// </summary>
  TSdlAndroidExternalStorageState = (
    /// <summary>
    ///  See the official Android developer guide for more information:
    ///  <see href="http://developer.android.com/guide/topics/data/data-storage.html">Data and File Storage</see>
    /// </summary>
    Read  = 0,

    /// <summary>
    ///  See the official Android developer guide for more information:
    ///  <see href="http://developer.android.com/guide/topics/data/data-storage.html">Data and File Storage</see>
    /// </summary>
    Write = 1);
  TSdlAndroidExternalStorageStates = set of TSdlAndroidExternalStorageState;

type
  /// <summary>
  ///  Callback that presents a response from a SdlRequestAndroidPermission call.
  /// </summary>
  /// <param name="APermission">The Android-specific permission name that was requested.</param>
  /// <param name="AGranted">True if permission is granted, False if denied.</param>
  /// <seealso cref="SdlRequestAndroidPermission"/>
  TSdlRequestAndroidPermissionCallback = procedure(const APermission: String;
    const AGranted: Boolean) of object;

/// <summary>
///  Get the Android Java Native Interface Environment of the current thread.
///
///  This is the JNIEnv one needs to access the Java virtual machine from native
///  code, and is needed for many Android APIs to be usable from Delphi.
/// </summary>
/// <returns>A pointer to Java native interface object (JNIEnv) to which the
///  current thread is attached.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlGetAndroidJniEnv: PJNIEnv; inline;

/// <summary>
///  Query Android API level of the current device.
///
///  - API level 35: Android 15 (VANILLA_ICE_CREAM)
///  - API level 34: Android 14 (UPSIDE_DOWN_CAKE)
///  - API level 33: Android 13 (TIRAMISU)
///  - API level 32: Android 12L (S_V2)
///  - API level 31: Android 12 (S)
///  - API level 30: Android 11 (R)
///  - API level 29: Android 10 (Q)
///  - API level 28: Android 9 (P)
///  - API level 27: Android 8.1 (O_MR1)
///  - API level 26: Android 8.0 (O)
///  - API level 25: Android 7.1 (N_MR1)
///  - API level 24: Android 7.0 (N)
///  - API level 23: Android 6.0 (M)
///  - API level 22: Android 5.1 (LOLLIPOP_MR1)
///  - API level 21: Android 5.0 (LOLLIPOP, L)
///  - API level 20: Android 4.4W (KITKAT_WATCH)
///  - API level 19: Android 4.4 (KITKAT)
///  - API level 18: Android 4.3 (JELLY_BEAN_MR2)
///  - API level 17: Android 4.2 (JELLY_BEAN_MR1)
///  - API level 16: Android 4.1 (JELLY_BEAN)
///  - API level 15: Android 4.0.3 (ICE_CREAM_SANDWICH_MR1)
///  - API level 14: Android 4.0 (ICE_CREAM_SANDWICH)
///  - API level 13: Android 3.2 (HONEYCOMB_MR2)
///  - API level 12: Android 3.1 (HONEYCOMB_MR1)
///  - API level 11: Android 3.0 (HONEYCOMB)
///  - API level 10: Android 2.3.3 (GINGERBREAD_MR1)
/// </summary>
/// <returns>The Android API level.</returns>
function SdlGetAndroidSdkVersion: Integer; inline;

/// <summary>
///  Query if the application is running on a Chromebook.
/// </summary>
/// <returns>True if this is a Chromebook, False otherwise.</returns>
function SdlIsChromeBook: Boolean; inline;

/// <summary>
///  Query if the application is running on a Samsung DeX docking station.
/// </summary>
/// <returns>True if this is a DeX docking station, False otherwise.</returns>
function SdlIsDeXMode: Boolean; inline;

/// <summary>
///  Trigger the Android system back button behavior.
/// </summary>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlSendAndroidBackButton; inline;

/// <summary>
///  Get the path used for internal storage for this Android application.
///
///  This path is unique to your application and cannot be written to by other
///  applications.
///
///  Your internal storage path is typically:
///  `/data/data/your.app.package/files`.
///
///  This is a Delphi wrapper over
///  <see href="https://developer.android.com/reference/android/content/Context#getFilesDir()">android.content.Context.getFilesDir()</see>.
/// </summary>
/// <returns>The path used for internal storage.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlGetAndroidExternalStoragePath"/>
/// <seealso cref="SdlGetAndroidCachePath"/>
function SdlGetAndroidInternalStoragePath: String; inline;

/// <summary>
///  Get the current state of external storage for this Android application.
///
///  If external storage is currently unavailable, this will return [].
/// </summary>
/// <returns>The current state of external storage, or [] if external storage
///  is currently unavailable.</returns>
/// <seealso cref="SdlGetAndroidExternalStoragePath"/>
function SdlGetAndroidExternalStorageState: TSdlAndroidExternalStorageStates; inline;

/// <summary>
///  Get the path used for external storage for this Android application.
///
///  This path is unique to your application, but is public and can be written
///  to by other applications.
///
///  Your external storage path is typically:
///  `/storage/sdcard0/Android/data/your.app.package/files`.
///
///  This is a Delphi wrapper over
///  <see href="https://developer.android.com/reference/android/content/Context#getExternalFilesDir()">android.content.Context.getExternalFilesDir()</see>.
/// </summary>
/// <returns>The path used for external storage for this application.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlGetAndroidExternalStorageState"/>
/// <seealso cref="SdlGetAndroidInternalStoragePath"/>
/// <seealso cref="SdlGetAndroidCachePath"/>
function SdlGetAndroidExternalStoragePath: String; inline;

/// <summary>
///  Get the path used for caching data for this Android application.
///
///  This path is unique to your application, but is public and can be written
///  to by other applications.
///
///  Your cache path is typically: `/data/data/your.app.package/cache/`.
///
///  This is a Delphi wrapper over
///  <see href="https://developer.android.com/reference/android/content/Context#getCacheDir()">android.content.Context.getCacheDir()</see>.
/// </summary>
/// <returns>The path used for caches for this application.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlGetAndroidInternalStoragePath"/>
/// <seealso cref="SdlGetAndroidExternalStoragePath"/>
function SdlGetAndroidCachePath: String; inline;

/// <summary>
///  Request permissions at runtime, asynchronously.
///
///  You do not need to call this for built-in functionality of SDL; recording
///  from a microphone or reading images from a camera, using standard SDL APIs,
///  will manage permission requests for you.
///
///  This function never blocks. Instead, the app-supplied callback will be
///  called when a decision has been made. This callback may happen on a
///  different thread, and possibly much later, as it might wait on a user to
///  respond to a system dialog. If permission has already been granted for a
///  specific entitlement, the callback will still fire, probably on the current
///  thread and before this function returns.
///
///  If the request submission fails, the callback will NOT be called, but this
///  should only happen in catastrophic conditions, like memory running out.
///  Normally there will be a yes or no to the request through the callback.
///
///  For the `APermission` parameter, choose a value from here:
///  <see href="https://developer.android.com/reference/android/Manifest.permission">Manifest.permission</see>.
/// </summary>
/// <param name="APermission">The permission to request.</param>
/// <param name="ACallback">The callback to trigger when the request has a response.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlRequestAndroidPermission(const APermission: String;
  const ACallback: TSdlRequestAndroidPermissionCallback);

/// <summary>
///  Shows an Android toast notification.
///
///  Toasts are a sort of lightweight notification that are unique to Android.
///
///  See <see href="https://developer.android.com/guide/topics/ui/notifiers/toasts">Toasts</see>.
///
///  Shows toast in UI thread.
///
///  For the `AGravity` parameter, choose a value from here, or -1 if you don't
///  have a preference:
///
///  See <see href="https://developer.android.com/reference/android/view/Gravity">Gravity</see>.
/// </summary>
/// <param name="AMessage">Text message to be shown.</param>
/// <param name="ADuration">0=short, 1=long.</param>
/// <param name="AGravity">Where the notification should appear on the screen.</param>
/// <param name="AXOffset">Set this parameter only when AGravity >=0.</param>
/// <param name="AYOffset">Set this parameter only when AGravity >=0.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <remarks>
///  It is safe to call this rouine from any thread.
/// </remarks>
procedure SdlShowAndroidToast(const AMessage: String; const ADuration,
  AGravity, AXOffset, AYOffset: Integer); inline;
{$ENDIF !Platform}

/// <summary>
///  Query if the current device is a tablet.
///
///  If SDL can't determine this, it will return False.
/// </summary>
/// <returns>True if the device is a tablet, False otherwise.</returns>
function SdlIsTablet: Boolean; inline;

/// <summary>
///  Query if the current device is a TV.
///
///  If SDL can't determine this, it will return False.
/// </summary>
/// <returns>True if the device is a TV, False otherwise.</returns>
function SdlIsTV: Boolean; inline;

type
  /// <summary>
  ///  Application sandbox environment.
  /// </summary>
  TSdlSandbox = (
    None             = SDL_SANDBOX_NONE,
    UnknownContainer = SDL_SANDBOX_UNKNOWN_CONTAINER,
    FlatPak          = SDL_SANDBOX_FLATPAK,
    Snap             = SDL_SANDBOX_SNAP,
    MacOS            = SDL_SANDBOX_MACOS);

/// <summary>
///  Get the application sandbox environment, if any.
/// </summary>
/// <returns>The application sandbox environment or TSdlSandbox.None if the
///  application is not running in a sandbox environment.</returns>
function SdlGetSandbox: TSdlSandbox; inline;
{$ENDREGION 'Platform-specific Functionality'}

{$REGION 'Miscellaneous'}
/// <summary>
///  SDL API functions that don't fit elsewhere.
/// </summary>

/// <summary>
///  Open a URL/URI in the browser or other appropriate external application.
///
///  Open a URL in a separate, system-provided application. How this works will
///  vary wildly depending on the platform. This will likely launch what makes
///  sense to handle a specific URL's protocol (a web browser for `http://`,
///  etc), but it might also be able to launch file managers for directories and
///  other things.
///
///  What happens when you open a URL varies wildly as well: your game window
///  may lose focus (and may or may not lose focus if your game was fullscreen
///  or grabbing input at the time). On mobile devices, your app will likely
///  move to the background or your process might be paused. Any given platform
///  may or may not handle a given URL.
///
///  If this is unimplemented (or simply unavailable) for a platform, this will
///  fail with an error. A successful result does not mean the URL loaded, just
///  that we launched _something_ to handle it (or at least believe we did).
///
///  All this to say: this function can be useful, but you should definitely
///  test it on every platform you target.
/// </summary>
/// <param name="AUrl">A valid URL/URI to open.
///  Use `file:///full/path/to/file` for local files, if supported.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
procedure SdlOpenUrl(const AUrl: String); inline;
{$ENDREGION 'Miscellaneous'}

implementation

uses
  System.Classes,
  System.Generics.Defaults;

function SdlMAlloc(const ASize: NativeInt): Pointer; inline;
begin
  Result := SDL_malloc(ASize);
end;

function SdlCAlloc(const ANumElements, AElementSize: NativeInt): Pointer; inline;
begin
  Result := SDL_calloc(ANumElements, AElementSize);
end;

function SdlRealloc(const AMem: Pointer; const ASize: NativeInt): Pointer; inline;
begin
  Result := SDL_realloc(AMem, ASize);
end;

procedure SdlFree(const AMem: Pointer); inline;
begin
  SDL_free(AMem);
end;

function SdlAlignedAlloc(const AAlignment, ASize: NativeInt): Pointer; inline;
begin
  Result := SDL_aligned_alloc(AAlignment, ASize);
end;

procedure SdlAlignedFree(const AMem: Pointer); inline;
begin
  SDL_aligned_free(AMem);
end;

function SdlNumAllocations: Integer; inline;
begin
  Result := SDL_GetNumAllocations;
end;

function SdlCrc16(const ACrc: Word; const AData: Pointer; const ASize: NativeInt): Word; inline;
begin
  Result := SDL_crc16(ACrc, AData, ASize);
end;

function SdlCrc32(const ACrc: Cardinal; const AData: Pointer; const ASize: NativeInt): Cardinal; inline;
begin
  Result := SDL_crc32(ACrc, AData, ASize);
end;

function SdlMurmur3(const AData: Pointer; const ASize: NativeInt;
  const ASeed: Cardinal = 0): Cardinal; inline;
begin
  Result := SDL_murmur3_32(AData, ASize, ASeed);
end;

function SdlFillChar4(var ADst; const ACount: NativeInt; const AVal: Cardinal): Pointer; inline;
begin
  Result := SDL_memset4(@ADst, AVal, ACount);
end;

function SdlGetPowerInfo(out ASeconds, APercent: Integer): TSdlPowerState; inline;
begin
  Result := TSdlPowerState(SDL_GetPowerInfo(@ASeconds, @APercent));
  if (Result = TSdlPowerState.Error) then
    __HandleError;
end;

{$IF Defined(MSWINDOWS)}
function SdlGetDirect3D9AdapterIndex(const ADisplayID: TSdlDisplayID): Integer; inline;
begin
  Result := SDL_GetDirect3D9AdapterIndex(ADisplayID);
  if (Result = -1) then
    __HandleError;
end;

procedure SdlGetDxgiOutputInfo(const ADisplayID: TSdlDisplayID;
  out AAdapterIndex, AOutputIndex: Integer); inline;
begin
  SdlCheck(SDL_GetDXGIOutputInfo(ADisplayID, @AAdapterIndex, @AOutputIndex));
end;
{$ELSEIF Defined(IOS)}
procedure SdlSetiOSEventPump(const AEnabled: Boolean); inline;
begin
  SDL_SetiOSEventPump(AEnabled);
end;
{$ELSEIF Defined(ANDROID)}
var
  GPermissionCallbacks: TDictionary<String, TSdlRequestAndroidPermissionCallback> = nil;

function SdlGetAndroidJniEnv: PJNIEnv; inline;
begin
  Result := SDL_GetAndroidJNIEnv;
end;

function SdlGetAndroidSdkVersion: Integer; inline;
begin
  Result := SDL_GetAndroidSDKVersion;
end;

function SdlIsChromeBook: Boolean; inline;
begin
  Result := SDL_IsChromebook;
end;

function SdlIsDeXMode: Boolean; inline;
begin
  Result := SDL_IsDeXMode;
end;

procedure SdlSendAndroidBackButton; inline;
begin
  SDL_SendAndroidBackButton;
end;

function SdlGetAndroidInternalStoragePath: String; inline;
begin
  var Path := SDL_GetAndroidInternalStoragePath;
  if (SdlSucceeded(Path)) then
    Result := __ToString(Path);
end;

function SdlGetAndroidExternalStorageState: TSdlAndroidExternalStorageStates; inline;
begin
  Byte(Result) := SDL_GetAndroidExternalStorageState;
end;

function SdlGetAndroidExternalStoragePath: String; inline;
begin
  var Path := SDL_GetAndroidExternalStoragePath;
  if (SdlSucceeded(Path)) then
    Result := __ToString(Path);
end;

function SdlGetAndroidCachePath: String; inline;
begin
  var Path := SDL_GetAndroidCachePath;
  if (SdlSucceeded(Path)) then
    Result := __ToString(Path);
end;

procedure PermissionCallback(AUserData: Pointer; const APermission: PUTF8Char;
  AGranted: Boolean); cdecl;
begin
  var Permission := __ToString(APermission);
  var Callback: TSdlRequestAndroidPermissionCallback;
  if (GPermissionCallbacks <> nil) and (GPermissionCallbacks.TryGetValue(Permission, Callback)) then
  begin
    GPermissionCallbacks.Remove(Permission);
    Callback(Permission, AGranted);
  end;
end;

procedure SdlRequestAndroidPermission(const APermission: String;
  const ACallback: TSdlRequestAndroidPermissionCallback);
begin
  if (GPermissionCallbacks = nil) then
    GPermissionCallbacks := TDictionary<String, TSdlRequestAndroidPermissionCallback>.Create;

  GPermissionCallbacks.AddOrSetValue(APermission, ACallback);
  SdlCheck(SDL_RequestAndroidPermission(__ToUtf8(APermission), PermissionCallback, nil));
end;

procedure SdlShowAndroidToast(const AMessage: String; const ADuration,
  AGravity, AXOffset, AYOffset: Integer); inline;
begin
  SdlCheck(SDL_ShowAndroidToast(__ToUtf8(AMessage), ADuration, AGravity,
    AXOffset, AYOffset));
end;
{$ENDIF !Platform}

function SdlIsTablet: Boolean; inline;
begin
  Result := SDL_IsTablet;
end;

function SdlIsTV: Boolean; inline;
begin
  Result := SDL_IsTV;
end;

function SdlGetSandbox: TSdlSandbox; inline;
begin
  Result := TSdlSandbox(SDL_GetSandbox);
end;

procedure SdlOpenUrl(const AUrl: String); inline;
begin
  SdlCheck(SDL_OpenURL(__ToUtf8(AUrl)));
end;

function SdlShowMessageBox(const AData: TSdlMessageBoxData): Integer;
begin
  var Data: SDL_MessageBoxData;
  Data.flags := Word(AData.Flags);
  Data.window := SDL_Window(AData.Window);
  Data.title := __ToUtf8(AData.Title);
  Data.message := __ToUtf8B(AData.Text);

  var Buttons: TArray<SDL_MessageBoxButtonData>;
  var ButtonCaptions: TArray<UTF8String>;
  SetLength(Buttons, Length(AData.Buttons));
  SetLength(ButtonCaptions, Length(AData.Buttons));

  var SrcButton := PSdlMessageBoxButtonData(AData.Buttons);
  var DstButton := PSDL_MessageBoxButtonData(Buttons);

  for var I := 0 to Length(Buttons) - 1 do
  begin
    DstButton.flags := Byte(SrcButton.Flags);
    DstButton.buttonID := SrcButton.ButtonID;
    ButtonCaptions[I] := UTF8String(SrcButton.Text);
    DstButton.text := PUTF8Char(ButtonCaptions[I]);

    Inc(SrcButton);
    Inc(DstButton);
  end;

  Data.numbuttons := Length(Buttons);
  Data.buttons := PSDL_MessageBoxButtonData(Buttons);
  Data.colorScheme := PSDL_MessageBoxColorScheme(AData.ColorScheme);;

  SdlCheck(SDL_ShowMessageBox(@Data, @Result));
end;

procedure SdlShowSimpleMessageBox(const AFlags: TSdlMessageBoxFlags;
  const ATitle, AMessage: String); overload;
begin
  SdlCheck(SDL_ShowSimpleMessageBox(Word(AFlags), __ToUtf8(ATitle),
    __ToUtf8B(AMessage), 0));
end;

procedure SdlShowSimpleMessageBox(const AFlags: TSdlMessageBoxFlags;
  const ATitle, AMessage: String; const AWindow: TSdlWindow); overload;
begin
  SdlCheck(SDL_ShowSimpleMessageBox(Word(AFlags), __ToUtf8(ATitle),
    __ToUtf8B(AMessage), SDL_Window(AWindow)));
end;

{ TSdlMessageBoxButtonData }

constructor TSdlMessageBoxButtonData.Create(const AText: String;
  const AID: Integer; const AFlags: TSdlMessageBoxButtonFlags);
begin
  Flags := AFlags;
  ButtonID := AID;
  Text := AText;
end;

{ TSdlMessageBoxColor }

constructor TSdlMessageBoxColor.Create(const ARed, AGreen, ABlue: Byte);
begin
  R := ARed;
  G := AGreen;
  B := ABlue;
end;

{ TSdlMessageBoxData }

constructor TSdlMessageBoxData.Create(const AFlags: TSdlMessageBoxFlags;
  const ATitle, AMessage: String);
begin
  Flags := AFlags;
  Window := nil;
  Title := ATitle;
  Text := AMessage;
  Buttons := nil;
  ColorScheme := nil;
end;

{ TSdlMemoryManager }

class function TSdlMemoryManager.DelphiCAlloc(ANumElements,
  AElementSize: NativeInt): Pointer;
begin
  var Size := ANumElements * AElementSize;
  GetMem(Result, Size);
  FillChar(Result^, Size, 0);
end;

class procedure TSdlMemoryManager.DelphiFree(AMem: Pointer);
begin
  FreeMem(AMem);
end;

class function TSdlMemoryManager.DelphiMAlloc(ASize: NativeInt): Pointer;
begin
  GetMem(Result, ASize);
end;

class function TSdlMemoryManager.DelphiRealloc(AMem: Pointer;
  ASize: NativeInt): Pointer;
begin
  Result := AMem;
  ReallocMem(Result, ASize);
end;

class function TSdlMemoryManager.GetCurrent: TSdlMemoryManager;
begin
  SDL_GetMemoryFunctions(@Result.MAlloc, @Result.CAlloc, @Result.Realloc, @Result.Free);
end;

class function TSdlMemoryManager.GetOriginal: TSdlMemoryManager;
begin
  SDL_GetOriginalMemoryFunctions(@Result.MAlloc, @Result.CAlloc, @Result.Realloc, @Result.Free);
end;

class procedure TSdlMemoryManager.SetCurrent(const AValue: TSdlMemoryManager);
begin
  SdlCheck(SDL_SetMemoryFunctions(AValue.MAlloc, AValue.CAlloc, AValue.Realloc, AValue.Free));
end;

class procedure TSdlMemoryManager.UseDelphis;
begin
  SDL_SetMemoryFunctions(DelphiMAlloc, DelphiCAlloc, DelphiRealloc, DelphiFree);
end;

{ TSdlEnvironment }

constructor TSdlEnvironment.Create(const APopulated: Boolean);
begin
  FHandle := SDL_CreateEnvironment(APopulated);
end;

class operator TSdlEnvironment.Equal(const ALeft: TSdlEnvironment;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlEnvironment.Free;
begin
  SDL_DestroyEnvironment(FHandle);
  FHandle := 0;
end;

class function TSdlEnvironment.GetProcess: TSdlEnvironment;
begin
  Result.FHandle := SDL_GetEnvironment;
end;

class function TSdlEnvironment.GetUnsafe(const AName: String): String;
begin
  Result := __ToString(SDL_getenv_unsafe(__ToUtf8(AName)));
end;

function TSdlEnvironment.GetVariable(const AName: String): String;
begin
  Result := __ToString(SDL_GetEnvironmentVariable(FHandle, __ToUtf8(AName)));
end;

function TSdlEnvironment.GetVariables: TArray<String>;
begin
  var AllVars := SDL_GetEnvironmentVariables(FHandle);
  if (SdlSucceeded(AllVars)) then
  try
    var V := AllVars;
    var Vars := TStringList.Create;
    try
      while (V^ <> nil) do
      begin
        Vars.Add(__ToString(V^));
        Inc(V);
      end;
      Result := Vars.ToStringArray;
    finally
      Vars.Free;
    end;
  finally
    SDL_free(AllVars);
  end;
end;

class operator TSdlEnvironment.Implicit(const AValue: Pointer): TSdlEnvironment;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlEnvironment.NotEqual(const ALeft: TSdlEnvironment;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class procedure TSdlEnvironment.SetUnsafe(const AName, AValue: String;
  const AOverwrite: Boolean);
begin
  if (SDL_setenv_unsafe(__ToUtf8(AName), __ToUtf8B(AValue), Ord(AOverwrite)) = -1) then
    __HandleError;
end;

procedure TSdlEnvironment.SetVariable(const AName, AValue: String;
  const AOverwrite: Boolean);
begin
  SdlCheck(SDL_SetEnvironmentVariable(FHandle, __ToUtf8(AName), __ToUtf8B(AValue), AOverwrite));
end;

class procedure TSdlEnvironment.UnsetUnsafe(const AName: String);
begin
  if (SDL_unsetenv_unsafe(__ToUtf8(AName)) = -1) then
    __HandleError;
end;

procedure TSdlEnvironment.UnsetVariable(const AName: String);
begin
  SdlCheck(SDL_UnsetEnvironmentVariable(FHandle, __ToUtf8(AName)));
end;

{ TSdlClipboard }

class procedure TSdlClipboard.CleanupCallback(AUserData: Pointer);
begin
  var Provider := ISdlClipboardDataProvider(AUserData);
  Provider.Cleanup;
end;

class procedure TSdlClipboard.ClearData;
begin
  SdlCheck(SDL_ClearClipboardData);
end;

class constructor TSdlClipboard.Create;
begin
  FProviders := nil;
end;

class function TSdlClipboard.DataCallback(AUserData: Pointer;
  const AMimeType: PUTF8Char; ASize: PNativeUInt): Pointer;
begin
  var Provider := ISdlClipboardDataProvider(AUserData);
  Result := Provider.Data(__ToString(AMimeType), PNativeInt(ASize)^);
end;

class destructor TSdlClipboard.Destroy;
begin
  FreeAndNil(FProviders);
end;

class function TSdlClipboard.GetData(const AMimeType: String): TBytes;
begin
  Result := nil;
  var Size: NativeInt := 0;
  var Data := SDL_GetClipboardData(__ToUtf8(AMimeType), @Size);
  if (Data <> nil) then
  try
    SetLength(Result, Size);
    Move(Data^, Result[0], Size);
  finally
    SdlFree(Data);
  end;
end;

class function TSdlClipboard.GetHasText: Boolean;
begin
  Result := SDL_HasClipboardText;
end;

class function TSdlClipboard.GetMimeTypes: TArray<String>;
begin
  var Count: NativeInt := 0;
  var MimeTypes := SDL_GetClipboardMimeTypes(@Count);
  if (MimeTypes = nil) then
    Exit(nil);

  try
    SetLength(Result, Count);
    var P := MimeTypes;
    for var I := 0 to Count - 1 do
    begin
      Result[I] := __ToString(P^);
      Inc(P);
    end;
  finally
    SdlFree(MimeTypes);
  end;
end;

class function TSdlClipboard.GetText: String;
begin
  Result := '';
  var Text := SDL_GetClipboardText;
  if (SdlSucceeded(Text)) then
  try
    Result := __ToString(Text);
  finally
    SdlFree(Text);
  end;
end;

class function TSdlClipboard.HasData(const AMimeType: String): Boolean;
begin
  Result := SDL_HasClipboardData(__ToUtf8(AMimeType));
end;

class procedure TSdlClipboard.SetData(
  const AProvider: ISdlClipboardDataProvider; const AMimeTypes: TArray<String>);
begin
  if (AProvider = nil) then
    __HandleError('No clipboard data provider specified');

  if (AMimeTypes = nil) then
    __HandleError('No clipboard mime types specified');

  if (FProviders = nil) then
    FProviders := TDictionary<String, ISdlClipboardDataProvider>.Create(TIStringComparer.Ordinal);

  var Utf8MimeTypes: TArray<UTF8String>;
  var MimeTypePtrs: TArray<PUTF8Char>;

  SetLength(Utf8MimeTypes, Length(AMimeTypes));
  SetLength(MimeTypePtrs, Length(AMimeTypes));
  for var I := 0 to Length(AMimeTypes) - 1 do
  begin
    Utf8MimeTypes[I] := UTF8String(AMimeTypes[I]);
    MimeTypePtrs[I] := PUTF8Char(Utf8MimeTypes[I]);
    FProviders.AddOrSetValue(AMimeTypes[I], AProvider);
  end;

  SdlCheck(SDL_SetClipboardData(DataCallback, CleanupCallback,
    Pointer(AProvider), Pointer(MimeTypePtrs), Length(MimeTypePtrs)));
end;

class procedure TSdlClipboard.SetText(const AValue: String);
begin
  SdlCheck(SDL_SetClipboardText(__ToUtf8(AValue)));
end;

{ TSdlCpu }

class function TSdlCpu.GetCacheLineSize: Integer;
begin
  Result := SDL_GetCPUCacheLineSize;
end;

class function TSdlCpu.GetHasAltiVec: Boolean;
begin
  Result := SDL_HasAltiVec;
end;

class function TSdlCpu.GetHasArmSimd: Boolean;
begin
  Result := SDL_HasARMSIMD;
end;

class function TSdlCpu.GetHasAvx: Boolean;
begin
  Result := SDL_HasAVX;
end;

class function TSdlCpu.GetHasAvx2: Boolean;
begin
  Result := SDL_HasAVX2;
end;

class function TSdlCpu.GetHasAvx512F: Boolean;
begin
  Result := SDL_HasAVX512F;
end;

class function TSdlCpu.GetHasLasx: Boolean;
begin
  Result := SDL_HasLASX;
end;

class function TSdlCpu.GetHasLsx: Boolean;
begin
  Result := SDL_HasLSX;
end;

class function TSdlCpu.GetHasMmx: Boolean;
begin
  Result := SDL_HasMMX;
end;

class function TSdlCpu.GetHasNeon: Boolean;
begin
  Result := SDL_HasNEON;
end;

class function TSdlCpu.GetHasSse: Boolean;
begin
  Result := SDL_HasSSE;
end;

class function TSdlCpu.GetHasSse2: Boolean;
begin
  Result := SDL_HasSSE2;
end;

class function TSdlCpu.GetHasSse3: Boolean;
begin
  Result := SDL_HasSSE3;
end;

class function TSdlCpu.GetHasSse41: Boolean;
begin
  Result := SDL_HasSSE41;
end;

class function TSdlCpu.GetHasSse42: Boolean;
begin
  Result := SDL_HasSSE42;
end;

class function TSdlCpu.GetNumLogicalCores: Integer;
begin
  Result := SDL_GetNumLogicalCPUCores;
end;

class function TSdlCpu.GetSimdAlignment: Integer;
begin
  Result := SDL_GetSIMDAlignment;
end;

class function TSdlCpu.GetSystemRamMiB: Integer;
begin
  Result := SDL_GetSystemRAM;
end;

{ TSdlDialog }

class procedure TSdlDialog.Callback(AUserData: Pointer;
  const AFileList: PPUTF8Char; AFilter: Integer);
begin
  var Index := IntPtr(AUserData);
  if (Index < 0) or (Index >= MAX_SIMULTANEOUS_DIALOGS) then
    Exit;

  var Callback := FCallbacks[Index];
  if (not Assigned(Callback)) then
    Exit;

  { Make available for another call }
  FCallbacks[Index] := nil;

  var Files: TArray<String> := nil;
  if (AFileList <> nil) then
  begin
    var Count := 0;
    var P := AFileList;
    while (P^ <> nil) do
    begin
      Inc(Count);
      Inc(P);
    end;

    SetLength(Files, Count);
    P := AFileList;
    for var I := 0 to Count - 1 do
    begin
      Files[I] := __ToString(P^);
      Inc(P);
    end;
  end;

  Callback(Files, AFilter);
end;

class function TSdlDialog.Setup(const ACallback: TSdlDialogFileCallback;
  const ASrcFilters: TArray<TSdlDialogFileFilter>;
  out AOutFilters: PSDL_DialogFileFilter; out AOutCount: Integer): Integer;
begin
  if (not Assigned(ACallback)) then
  begin
    __HandleError('No dialog callback specified');
    Exit(-1);
  end;

  var I := 0;
  while (I < MAX_SIMULTANEOUS_DIALOGS) do
  begin
    if (not Assigned(FCallbacks[I])) then
      Break;

    Inc(I);
  end;

  if (I = MAX_SIMULTANEOUS_DIALOGS) then
  begin
    __HandleError('Too many simultaneous dialog boxes');
    Exit(-1);
  end;

  FCallbacks[I] := ACallback;

  AOutCount := Length(ASrcFilters);
  SetLength(FUtf8Filters[I], AOutCount * 2);
  SetLength(FFilters[I], AOutCount);
  for var J := 0 to AOutCount - 1 do
  begin
    FUtf8Filters[I, (J * 2) + 0] := UTF8String(ASrcFilters[J].Name);
    FUtf8Filters[I, (J * 2) + 1] := UTF8String(ASrcFilters[J].Pattern);
    FFilters[I, J].name := PUTF8Char(FUtf8Filters[I, (J * 2) + 0]);
    FFilters[I, J].pattern := PUTF8Char(FUtf8Filters[I, (J * 2) + 1]);
  end;

  AOutFilters := nil;
  if (ASrcFilters <> nil) then
    AOutFilters := Pointer(FFilters[I]);

  Result := I;
end;

class procedure TSdlDialog.ShowOpenFile(const ACallback: TSdlDialogFileCallback;
  const AWindow: TSdlWindow; const AFilters: TArray<TSdlDialogFileFilter>;
  const ADefaultLocation: String; const AAllowMany: Boolean);
begin
  var Filters: PSDL_DialogFileFilter;
  var FilterCount: Integer;
  var Index := Setup(ACallback, AFilters, Filters, FilterCount);

  if (Index >= 0) then
  begin
    SDL_ShowOpenFileDialog(Callback, Pointer(Index), SDL_Window(AWindow),
      Filters, FilterCount, __ToUtf8(ADefaultLocation), AAllowMany);
  end;
end;

class procedure TSdlDialog.ShowOpenFolder(
  const ACallback: TSdlDialogFileCallback; const AWindow: TSdlWindow;
  const ADefaultLocation: String; const AAllowMany: Boolean);
begin
  var Filters: PSDL_DialogFileFilter;
  var FilterCount: Integer;
  var Index := Setup(ACallback, nil, Filters, FilterCount);

  if (Index >= 0) then
  begin
    SDL_ShowOpenFolderDialog(Callback, Pointer(Index), SDL_Window(AWindow),
      __ToUtf8(ADefaultLocation), AAllowMany);
  end;
end;

class procedure TSdlDialog.ShowSaveFile(const ACallback: TSdlDialogFileCallback;
  const AWindow: TSdlWindow; const AFilters: TArray<TSdlDialogFileFilter>;
  const ADefaultLocation: String);
begin
  var Filters: PSDL_DialogFileFilter;
  var FilterCount: Integer;
  var Index := Setup(ACallback, AFilters, Filters, FilterCount);

  if (Index >= 0) then
  begin
    SDL_ShowSaveFileDialog(Callback, Pointer(Index), SDL_Window(AWindow),
      Filters, FilterCount, __ToUtf8(ADefaultLocation));
  end;
end;

{ TSdlTray }

var
  GTrayCallbacks: TDictionary<SDL_TrayEntry, TSdlTrayCallback> = nil;

constructor TSdlTray.Create(const AIcon: TSdlSurface; const ATooltip: String);
begin
  FHandle := SDL_CreateTray(PSDL_Surface(AIcon), __ToUtf8(ATooltip));
end;

function TSdlTray.CreateMenu: TSdlTrayMenu;
begin
  Result.FHandle := SDL_CreateTrayMenu(FHandle);
end;

class operator TSdlTray.Equal(const ALeft: TSdlTray;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlTray.Free;
begin
  if (GTrayCallbacks <> nil) then
  begin
    var Menu := SDL_GetTrayMenu(FHandle);
    if (Menu <> 0) then
    begin
      var Size := 0;
      var Entry := SDL_GetTrayEntries(FHandle, @Size);
      if (Entry <> nil) then
      begin
        for var I := 0 to Size - 1 do
        begin
          GTrayCallbacks.Remove(Entry^);
          Inc(Entry);
        end;
      end;
    end;
  end;
  SDL_DestroyTray(FHandle);
end;

function TSdlTray.GetMenu: TSdlTrayMenu;
begin
  Result.FHandle := SDL_GetTrayMenu(FHandle);
end;

class operator TSdlTray.Implicit(const AValue: Pointer): TSdlTray;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlTray.NotEqual(const ALeft: TSdlTray;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlTray.SetIcon(const AIcon: TSdlSurface);
begin
  SDL_SetTrayIcon(FHandle, PSDL_Surface(AIcon));
end;

procedure TSdlTray.SetTooltip(const ATooltip: String);
begin
  SDL_SetTrayTooltip(FHandle, __ToUtf8(ATooltip));
end;

class procedure TSdlTray.Update;
begin
  SDL_UpdateTrays;
end;

{ TSdlTrayMenu }

class operator TSdlTrayMenu.Equal(const ALeft: TSdlTrayMenu;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlTrayMenu.Implicit(const AValue: Pointer): TSdlTrayMenu;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlTrayMenu.NotEqual(const ALeft: TSdlTrayMenu;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ _TSdlTrayMenuHelper }

function _TSdlTrayMenuHelper.GetEntries: TArray<TSdlTrayEntry>;
begin
  var Size := 0;
  var Entries := SDL_GetTrayEntries(FHandle, @Size);
  if (Entries = nil) then
    Exit(nil);

  SetLength(Result, Size);
  Move(Entries^, Result[0], Size * SizeOf(SDL_TrayEntry));
end;

function _TSdlTrayMenuHelper.GetParent: TSdlTray;
begin
  Result.FHandle := SDL_GetTrayMenuParentTray(FHandle);
end;

function _TSdlTrayMenuHelper.GetParentEntry: TSdlTrayEntry;
begin
  Result.FHandle := SDL_GetTrayMenuParentEntry(FHandle);
end;

function _TSdlTrayMenuHelper.Insert(const APos: Integer; const ACaption: String;
  const AFlags: TSdlTrayEntryFlags): TSdlTrayEntry;
begin
  Result.FHandle := SDL_InsertTrayEntryAt(FHandle, APos, __ToUtf8(ACaption),
    Cardinal(AFlags));
  SdlCheck(Result.FHandle);
end;

{ TSdlTrayEntry }

procedure TSdlTrayEntry.Click;
begin
  SDL_ClickTrayEntry(FHandle);
end;

function TSdlTrayEntry.CreateSubmenu: TSdlTrayMenu;
begin
  Result.FHandle := SDL_CreateTraySubmenu(FHandle);
end;

class operator TSdlTrayEntry.Equal(const ALeft: TSdlTrayEntry;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

function TSdlTrayEntry.GetCaption: String;
begin
  Result := __ToString(SDL_GetTrayEntryLabel(FHandle));
end;

function TSdlTrayEntry.GetIsChecked: Boolean;
begin
  Result := SDL_GetTrayEntryChecked(FHandle);
end;

function TSdlTrayEntry.GetIsEnabled: Boolean;
begin
  Result := SDL_GetTrayEntryEnabled(FHandle);
end;

function TSdlTrayEntry.GetParent: TSdlTrayMenu;
begin
  Result.FHandle := SDL_GetTrayEntryParent(FHandle);
end;

function TSdlTrayEntry.GetSubmenu: TSdlTrayMenu;
begin
  Result.FHandle := SDL_GetTraySubmenu(FHandle);
end;

class operator TSdlTrayEntry.Implicit(const AValue: Pointer): TSdlTrayEntry;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlTrayEntry.NotEqual(const ALeft: TSdlTrayEntry;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlTrayEntry.Remove;
begin
  SDL_RemoveTrayEntry(FHandle);
end;

procedure TSdlTrayEntry.SetCaption(const AValue: String);
begin
  SDL_SetTrayEntryLabel(FHandle, __ToUtf8(AValue));
end;

procedure TSdlTrayEntry.SetIsChecked(const AValue: Boolean);
begin
  SDL_SetTrayEntryChecked(FHandle, AValue);
end;

procedure TSdlTrayEntry.SetIsEnabled(const AValue: Boolean);
begin
  SDL_SetTrayEntryEnabled(FHandle, AValue);
end;

{ _TSdlTrayEntryHelper }

class procedure _TSdlTrayEntryHelper.Callback(AUserData: Pointer;
  AEntry: SDL_TrayEntry);
begin
  var Callback: TSdlTrayCallback;
  if (GTrayCallbacks <> nil) and (GTrayCallbacks.TryGetValue(AEntry, Callback)) then
    Callback(TSdlTrayEntry(AEntry));
end;

procedure _TSdlTrayEntryHelper.SetOnSelect(const AValue: TSdlTrayCallback);
begin
  if (GTrayCallbacks = nil) then
    GTrayCallbacks := TDictionary<SDL_TrayEntry, TSdlTrayCallback>.Create;

  GTrayCallbacks.AddOrSetValue(FHandle, AValue);
  SDL_SetTrayEntryCallback(FHandle, Callback, nil);
end;

{ TSdlLocale }

class function TSdlLocale.GetPreferredLocales: TArray<TSdlLocale>;
begin
  var Count := 0;
  var Locales := SDL_GetPreferredLocales(@Count);
  if (Locales = nil) then
    Exit(nil);

  try
    SetLength(Result, Count);
    var P := Locales;
    for var I := 0 to Count - 1 do
    begin
      Result[I].FLanguage := __ToString(P^.language);
      Result[I].FCountry := __ToString(P^.country);
      Inc(P);
    end;
  finally
    SDL_free(Locales);
  end;
end;

{ TSdlProcess }

constructor TSdlProcess.Create(const AExePath: String;
  const AArgs: TArray<String>; const APipeStdIO: Boolean);
begin
  var Utf8Args: TArray<UTF8String>;
  var Args: TArray<PUTF8Char>;
  SetLength(Utf8Args, Length(AArgs) + 1);
  SetLength(Args, Length(AArgs) + 1);

  Utf8Args[0] := UTF8String(AExePath);
  Args[0] := PUTF8Char(Utf8Args[0]);

  for var I := 0 to Length(AArgs) - 1 do
  begin
    Utf8Args[I + 1] := UTF8String(AArgs[I]);
    Args[I + 1] := PUTF8Char(Utf8Args[I + 1]);
  end;

  FHandle := SDL_CreateProcess(Pointer(Args), APipeStdIO);
  SdlCheck(FHandle);
end;

constructor TSdlProcess.Create(const AProps: TSdlProperties);
begin
  FHandle := SDL_CreateProcessWithProperties(SDL_PropertiesID(AProps));
  SdlCheck(FHandle);
end;

class operator TSdlProcess.Equal(const ALeft: TSdlProcess;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlProcess.Free;
begin
  SDL_DestroyProcess(FHandle);
  FHandle := 0;
end;

function TSdlProcess.GetInput: TSdlIOStream;
begin
  THandle(Result) := SDL_GetProcessInput(FHandle);
  SdlCheck(THandle(Result));
end;

function TSdlProcess.GetOutput: TSdlIOStream;
begin
  THandle(Result) := SDL_GetProcessOutput(FHandle);
  SdlCheck(THandle(Result));
end;

function TSdlProcess.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetProcessProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

class operator TSdlProcess.Implicit(const AValue: Pointer): TSdlProcess;
begin
  Result.FHandle := THandle(AValue);
end;

procedure TSdlProcess.Kill(const AForce: Boolean);
begin
  SdlCheck(SDL_KillProcess(FHandle, AForce));
end;

class operator TSdlProcess.NotEqual(const ALeft: TSdlProcess;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

function TSdlProcess.Read(out AExitCode: Integer): TBytes;
begin
  var Size: NativeUInt := 0;
  var Data := SDL_ReadProcess(FHandle, @Size, @AExitCode);
  if (SdlSucceeded(Data)) then
  try
    SetLength(Result, Size);
    Move(Data^, Result[0], Size);
  finally
    SDL_free(Data);
  end;
end;

function TSdlProcess.Wait(const ABlock: Boolean;
  out AExitCode: Integer): Boolean;
begin
  Result := SDL_WaitProcess(FHandle, ABlock, @AExitCode);
end;

function TSdlProcess.Wait(const ABlock: Boolean): Boolean;
begin
  Result := SDL_WaitProcess(FHandle, ABlock, nil);
end;

function TSdlProcess.Read: TBytes;
begin
  var ExitCode := 0;
  Result := Read(ExitCode);
end;

initialization

finalization
  {$IFDEF ANDROID}
  GPermissionCallbacks.Free;
  {$ENDIF}
  GTrayCallbacks.Free;

end.
