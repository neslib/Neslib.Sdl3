unit Neslib.Sdl3.IO;

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
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Basics;

{$REGION 'I/O Streams'}
/// <summary>
///  SDL provides an abstract interface for reading and writing data streams. It
///  offers implementations for files, memory, etc, and the app can provide
///  their own implementations, too.
///
///  TSdlIOStream is not related to the standard Delphi stream classes, other than
///  both are abstract interfaces to read/write data.
/// </summary>

type
  /// <summary>
  ///  TSdlIOStream status, set by a read or write operation.
  /// </summary>
  TSdlIOStatus = (
    /// <summary>
    ///  Everything is ready (no errors and not EOF).
    /// </summary>
    Ready     = SDL_IO_STATUS_READY,

    /// <summary>
    ///  Read or write I/O error
    /// </summary>
    Error     = SDL_IO_STATUS_ERROR,

    /// <summary>
    ///  End of file
    /// </summary>
    Eof       = SDL_IO_STATUS_EOF,

    /// <summary>
    ///  Non blocking I/O, not ready
    /// </summary>
    NotReady  = SDL_IO_STATUS_NOT_READY,

    /// <summary>
    ///  Tried to write a read-only buffer
    /// </summary>
    ReadOnly  = SDL_IO_STATUS_READONLY,

    /// <summary>
    ///  Tried to read a write-only buffer
    /// </summary>
    WriteOnly = SDL_IO_STATUS_WRITEONLY);

type
  /// <summary>
  ///  Possible `whence` values for TSdlIOStream seeking.
  ///
  ///  These map to the same TSeekOrigin used in the Delphi RTL.
  /// </summary>
  TSdlIOWhence = (
    /// <summary>
    ///  Seek from the beginning of data
    /// </summary>
    &Set = SDL_IO_SEEK_SET,

    /// <summary>
    ///  Seek relative to current read point
    /// </summary>
    Cur  = SDL_IO_SEEK_CUR,

    /// <summary>
    ///  Seek relative to the end of data
    /// </summary>
    &End = SDL_IO_SEEK_END);

type
  /// <summary>
  ///  The function pointers that drive a TSdlIOStream.
  ///
  ///  Applications can provide this struct to TSdlIOStream.Create to create
  ///  their own implementation of TSdlIOStream. This is not necessarily required,
  ///  as SDL already offers several common types of I/O streams, via other
  ///  constructors of TSdlIOStream.
  ///
  ///  This structure should be initialized calling Init.
  ///
  ///  Note that all function pointers uses the "cdecl" calling conventions
  ///  since these are directly using by the SDL C API.
  /// </summary>
  TSdlIOStreamInterface = record
  public
    /// <summary>
    ///  The version of the interface. Is set by calling Init.
    /// </summary>
    Version: Cardinal;

    /// <summary>
    ///  Return the number of bytes in this TSdlIOStream
    /// </summary>
    /// <returns>The total size of the data stream, or -1 on error.</returns>
    Size: function (AUserData: Pointer): Int64; cdecl;

    /// <summary>
    ///  Seek to `AOffset` relative to `AWhence`.
    /// </summary>
    /// <returns>The final offset in the data stream, or -1 on error.</returns>
    Seek: function (AUserData: Pointer; AOffset: Int64;
      AWhence: TSdlIOWhence): Int64; cdecl;

    /// <summary>
    ///  Read up to `ASize` bytes from the data stream to the area pointed
    ///  at by `APtr`.
    ///
    ///  On an incomplete read, you should set `AStatus` to a value from the
    ///  TSdlIOStatus enum. You do not have to explicitly set this on
    ///  a complete, successful read.
    /// </summary>
    /// <returns>The number of bytes read</returns>
    Read: function (AUserData, APtr: Pointer; ASize: NativeInt;
      var AStatus: TSdlIOStatus): NativeInt; cdecl;

    /// <summary>
    ///  Write exactly `ASize` bytes from the area pointed at by `APtr`
    ///  to data stream.
    ///
    ///  On an incomplete write, you should set `AStatus` to a value from the
    ///  TSdlIOStatus enum. You do not have to explicitly set this on
    ///  a complete, successful write.
    /// </summary>
    /// <returns>The number of bytes written</returns>
    Write: function (AUserData: Pointer; const APtr: Pointer; ASize: NativeInt;
      var AStatus: TSdlIOStatus): NativeInt; cdecl;

    /// <summary>
    ///  If the stream is buffering, make sure the data is written out.
    ///
    ///  On failure, you should set `AStatus` to a value from the
    ///  TSdlIOStatus enum. You do not have to explicitly set this on
    ///  a successful flush.
    /// </summary>
    /// <returns>True if successful or False on write error when flushing data.</returns>
    Flush: function (AUserData: Pointer; var AStatus: TSdlIOStatus): Boolean; cdecl;

    /// <summary>
    ///  Close and free any allocated resources.
    ///
    ///  This does not guarantee file writes will sync to physical media; they
    ///  can be in the system's file cache, waiting to go to disk.
    ///
    ///  The TSdlIOStream is still destroyed even if this fails, so clean up anything
    ///  even if flushing buffers, etc, returns an error.
    /// </summary>
    /// <returns>True if successful or False on write error when flushing data.</returns>
    Close: function (AUserData: Pointer): Boolean; cdecl;
  public
    /// <summary>
    ///  Initializes this interface by setting the Version field and clearing
    ///  all other fields.
    /// </summary>
    procedure Init;
  end;

type
  /// <summary>
  ///  The read/write operation structure.
  /// </summary>
  TSdlIOStream = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_IOStream;
    function GetProperties: TSdlProperties; inline;
    function GetStatus: TSdlIOStatus; inline;
    function GetSize: Int64; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlIOStream; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlIOStream; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlIOStream; inline; static;
  public
    /// <summary>
    ///  Creates an I/O stream for reading from and/or writing to a named file.
    ///
    ///  The `AMode` string is treated roughly the same as in a call to the C
    ///  library's fopen, even if SDL doesn't happen to use fopen behind the
    ///  scenes.
    ///
    ///  Available `AMode` strings:
    ///
    ///  - 'r': Open a file for reading. The file must exist.
    ///  - 'w': Create an empty file for writing. If a file with the same name
    ///    already exists its content is erased and the file is treated as a new
    ///    empty file.
    ///  - 'a': Append to a file. Writing operations append data at the end of the
    ///    file. The file is created if it does not exist.
    ///  - 'r+': Open a file for update both reading and writing. The file must
    ///    exist.
    ///  - 'w+': Create an empty file for both reading and writing. If a file with
    ///    the same name already exists its content is erased and the file is
    ///    treated as a new empty file.
    ///  - 'a+': Open a file for reading and appending. All writing operations are
    ///    performed at the end of the file, protecting the previous content to be
    ///    overwritten. You can reposition (fseek, rewind) the internal pointer to
    ///    anywhere in the file for reading, but writing operations will move it
    ///    back to the end of file. The file is created if it does not exist.
    ///
    ///  **NOTE**: In order to open a file as a binary file, a 'b' character has to
    ///  be included in the `AMode` string. This additional 'b' character can either
    ///  be appended at the end of the string (thus making the following compound
    ///  modes: 'rb', 'wb', 'ab', 'r+b', 'w+b', 'a+b') or be inserted between the
    ///  letter and the '+' sign for the mixed modes ('rb+', 'wb+', 'ab+').
    ///  Additional characters may follow the sequence, although they should have no
    ///  effect. For example, 't' is sometimes appended to make explicit the file is
    ///  a text file.
    ///
    ///  In Android, this constructor can be used to open content:// URIs. As a
    ///  fallback, this constructor will transparently open a matching filename in
    ///  the app's `assets`.
    ///
    ///  Freeing the I/O stream will close SDL's internal file handle.
    ///
    ///  The following properties may be set at creation time by SDL:
    ///
    ///  - `TSdlProperty.IOStreamWindowHandle`: a pointer, that can be cast
    ///    to a THandle, that this TSdlIOStream is using to access the
    ///    filesystem. If the program isn't running on Windows, or SDL used some
    ///    other method to access the filesystem, this property will not be set.
    ///  - `TSdlProperty.IOStreamFileDescriptor`: a file descriptor that this
    ///    TSdlIOStream is using to access the filesystem.
    ///  - `TSdlProperty.IOStreamAndroidAAsset`: a pointer, that can be cast
    ///    to an Android NDK `AAsset`, that this TSdlIOStream is using to access
    ///    the filesystem. If SDL used some other method to access the filesystem,
    ///    this property will not be set.
    /// </summary>
    /// <param name="AFilename">The filename to open.</param>
    /// <param name="AMode">A string representing the mode to be used for opening
    ///  the file.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="Read"/>
    /// <seealso cref="Seek"/>
    /// <seealso cref="Tell"/>
    /// <seealso cref="Write"/>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    constructor Create(const AFilename, AMode: String); overload;

    /// <summary>
    ///  Create an I/O stream from a read-write memory buffer.
    ///
    ///  This function sets up this record based on a memory area of a
    ///  certain size, for both read and write access.
    ///
    ///  This memory buffer is not copied by the TSdlIOStream; the pointer you
    ///  provide must remain valid until you close the stream. Closing the stream
    ///  will not free the original buffer.
    ///
    ///  If you need to make sure the TSdlIOStream never writes to the memory
    ///  buffer, you should set AReadOnly to True.
    ///
    ///  The following properties will be set at creation time by SDL:
    ///
    ///  - `TSdlProperty.IOStreamMemory`: this will be the `AMem` parameter that
    ///    was passed to this constructor.
    ///  - `TSdlProperty.IOStreamMemorySize`: this will be the `ASize` parameter
    ///    that was passed to this constructor.
    /// </summary>
    /// <param name="AMem">A pointer to a buffer to feed an TSdlIOStream stream.</param>
    /// <param name="ASize">The buffer size, in bytes.</param>
    /// <param name="AReadOnly">(Optional) to disallow writing to this stream.
    ///  Default to False (that is, you can read and write to this stream).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="Read"/>
    /// <seealso cref="Seek"/>
    /// <seealso cref="Tell"/>
    /// <seealso cref="Write"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    constructor Create(const AMem: Pointer; const ASize: NativeInt;
      const AReadOnly: Boolean = False); overload;

    /// <summary>
    ///  Creates an I/O stream that is backed by dynamically allocated memory.
    ///
    ///  This supports the following properties to provide access to the memory and
    ///  control over allocations:
    ///
    ///  - `TSdlProperty.IOStreamDynamicMemory`: a pointer to the internal
    ///    memory of the stream. This can be set to nil to transfer ownership of
    ///    the memory to the application, which should free the memory with
    ///    SdlFree. If this is done, the next operation on the stream must be
    ///    Free.
    ///  - `TSdlProperty.IOStreamDynamicChunkSize`: memory will be allocated in
    ///    multiples of this size, defaulting to 1024.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="Read"/>
    /// <seealso cref="Seek"/>
    /// <seealso cref="Tell"/>
    /// <seealso cref="Write"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    class function Create: TSdlIOStream; overload; inline; static;

    /// <summary>
    ///  Create a custom I/O stream.
    ///
    ///  Applications do not need to use this constructor unless they are providing
    ///  their own TSdlIOStream implementation. If you just need a TSdlIOStream to
    ///  read/write a common data source, you should use the built-in
    ///  implementations in SDL, by using the other constructors.
    /// </summary>
    /// <param name="AInterface">The interface that implements this TSdlIOStream,
    ///  initialized by calling its Init method.</param>
    /// <param name="AUserdata">The pointer that will be passed to the interface
    ///  functions.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="TSdlIOStreamInterface.Init"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    constructor Create(const AInterface: TSdlIOStreamInterface;
      const AUserData: Pointer); overload;

    /// <summary>
    ///  Close and free the I/O stream.
    ///
    ///  This closes and cleans up the stream. It releases any resources used by
    ///  the stream and frees the itself.
    ///
    ///  Note that if this fails to flush the stream for any reason, this function
    ///  raises an error, but the stream is still invalid once this function
    ///  returns.
    ///
    ///  This call flushes any buffered writes to the operating system, but there
    ///  are no guarantees that those writes have gone to physical media; they might
    ///  be in the OS's file cache, waiting to go to disk later. If it's absolutely
    ///  crucial that writes go to disk immediately, so they are definitely stored
    ///  even if the power fails before the file cache would have caught up, one
    ///  should call Flush before closing. Note that flushing takes time and
    ///  makes the system and your app operate less efficiently, so do so sparingly.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure (eg. when the stream
    ///  failed to flush its output).</exception>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Seek within the data stream.
    ///
    ///  This method seeks to byte `AOffset`, relative to `AWhence`.
    ///
    ///  `AWhence` may be any of the following values:
    ///
    ///  - `TSdlIOWhence.Set`: seek from the beginning of data
    ///  - `TSdlIOWhence.Cur`: seek relative to current read point
    ///  - `TSdlIOWhence.End`: seek relative to the end of data
    /// </summary>
    /// <param name="AOffset">An offset in bytes, relative to `AWhence` location;
    ///  can be negative.</param>
    /// <param name="AWhence">Relative seek origin.</param>
    /// <returns>The final offset in the data stream after the seek.</returns>
    /// <seealso cref="Tell"/>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    function Seek(const AOffset: Int64; const AWhence: TSdlIOWhence): Int64; inline;

    /// <summary>
    ///  Determine the current read/write offset in the data stream.
    ///
    ///  This is actually a wrapper function that calls `Seek` with an offset of
    ///  0 bytes from `TSdlIOWhence.Cur`, to simplify application development.
    /// </summary>
    /// <returns>The current offset in the stream, or -1 if the information can
    ///  not be determined.</returns>
    /// <seealso cref="Seek"/>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    function Tell: Int64; inline;

    /// <summary>
    ///  Read from the stream.
    ///
    ///  This function reads up `ASize` bytes from the stream to the area
    ///  pointed at by `APtr`. This function may read less bytes than requested.
    ///
    ///  This function will return zero when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof. If zero is returned and the stream
    ///  is not at EOF, Status will return a different error value and an
    ///  ESdlError will be raised.
    /// </summary>
    /// <param name="APtr">A pointer to a buffer to read data into.</param>
    /// <param name="ASize">The number of bytes to read from the stream.</param>
    /// <returns>The number of bytes read, or 0 on end of file.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Write"/>
    /// <seealso cref="Status"/>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    function Read(const APtr: Pointer; const ASize: NativeInt): NativeInt;

    /// <summary>
    ///  Write to the stream.
    ///
    ///  This function writes exactly `ASize` bytes from the area pointed at by
    ///  `APtr` to the stream. If this fails for any reason, it will return less
    ///  than `ASize` to demonstrate how far the write progressed. On success,
    ///  it returns `ASize`.
    ///
    ///  On error, this function still attempts to write as much as possible, so it
    ///  might return a positive value less than the requested write size.
    ///
    ///  The caller can use Status to determine if the problem is recoverable,
    ///  such as a non-blocking write that can simply be retried later. When
    ///  there is a fatal error, an ESdlError will be raised.
    /// </summary>
    /// <param name="APtr">A pointer to a buffer containing data to write.</param>
    /// <param name="ASize">The number of bytes to write.</param>
    /// <returns>The number of bytes written, which will be less than `ASize` on
    ///  failure.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Read"/>
    /// <seealso cref="Seek"/>
    /// <seealso cref="Flush"/>
    /// <seealso cref="Status"/>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    function Write(const APtr: Pointer; const ASize: NativeInt): NativeInt;

    /// <summary>
    ///  Flush any buffered data in the stream.
    ///
    ///  This method makes sure that any buffered data is written to the stream.
    ///  Normally this isn't necessary but if the stream is a pipe or socket it
    ///  guarantees that any pending data is sent.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Write"/>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    procedure Flush; inline;

    /// <summary>
    ///  Load all the data from the stream.
    ///
    ///  The data is allocated with a zero byte at the end (null terminated) for
    ///  convenience. This extra byte is not included in the value reported via
    ///  `ADataSize`.
    ///
    ///  The data should be freed with SdlFree.
    /// </summary>
    /// <param name="ADataSize">Will be set to the number of bytes read.</param>
    /// <param name="AClose">If True, calls Free before returning, even in the
    ///  case of an error.</param>
    /// <returns>The data.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SdlLoadFile"/>
    /// <seealso cref="Save"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function Load(out ADataSize: NativeInt; const AClose: Boolean): Pointer; overload; inline;

    /// <summary>
    ///  Load all the data from the stream.
    ///
    ///  The data is allocated with a zero byte at the end (null terminated) for
    ///  convenience.
    ///
    ///  The data should be freed with SdlFree.
    /// </summary>
    /// <param name="AClose">If True, calls Free before returning, even in the
    ///  case of an error.</param>
    /// <returns>The data.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadFile"/>
    /// <seealso cref="Save"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function Load(const AClose: Boolean): Pointer; overload; inline;

    /// <summary>
    ///  Save all the data into the stream.
    /// </summary>
    /// <param name="AData">The data to be written. If ADataSize is 0, may be
    ///  nil or a invalid pointer.</param>
    /// <param name="ADataSize">The number of bytes to be written.</param>
    /// <param name="AClose">If true, calls Free before returning, even in the
    ///  case of an error.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SdlSave"/>
    /// <seealso cref="Load"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure Save(const AData: Pointer; const ADataSize: NativeInt;
      const AClose: Boolean); inline;

    /// <summary>
    ///  Read an unsigned byte from the stream.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU8: UInt8; inline;

    /// <summary>
    ///  Read a signed byte from the stream.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS8: Int8; inline;

    /// <summary>
    ///  Read an unsigned 16-bit little-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU16LE: UInt16; inline;

    /// <summary>
    ///  Read a signed 16-bit little-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS16LE: Int16; inline;

    /// <summary>
    ///  Read an unsigned 16-bit big-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU16BE: UInt16; inline;

    /// <summary>
    ///  Read a signed 16-bit big-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS16BE: Int16; inline;

    /// <summary>
    ///  Read an unsigned 32-bit little-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU32LE: UInt32; inline;

    /// <summary>
    ///  Read a signed 32-bit little-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS32LE: Int32; inline;

    /// <summary>
    ///  Read an unsigned 32-bit big-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU32BE: UInt32; inline;

    /// <summary>
    ///  Read a signed 32-bit big-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS32BE: Int32; inline;

    /// <summary>
    ///  Read an unsigned 64-bit little-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU64LE: UInt64; inline;

    /// <summary>
    ///  Read a signed 64-bit little-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS64LE: Int64; inline;

    /// <summary>
    ///  Read an unsigned 64-bit big-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadU64BE: UInt64; inline;

    /// <summary>
    ///  Read a signed 64-bit big-endian integer from the stream.
    ///
    ///  SDL byteswaps the data only if necessary, so the data returned will be in
    ///  the native byte order.
    ///
    ///  This function will return False when the data stream is completely read,
    ///  Status will return TSdlIOStatus.Eof.
    /// </summary>
    /// <returns>The data read.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ReadS64BE: Int64; inline;

    /// <summary>
    ///  Write an unsigned byte to the stream.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU8(const AValue: UInt8); inline;

    /// <summary>
    ///  Write a signed byte to the stream.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS8(const AValue: Int8); inline;

    /// <summary>
    ///  Write an unsigned 16-bit integer to the stream as little-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in little-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU16LE(const AValue: UInt16); inline;

    /// <summary>
    ///  Write a signed 16-bit integer to the stream as little-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in little-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS16LE(const AValue: Int16); inline;

    /// <summary>
    ///  Write an unsigned 16-bit integer to the stream as big-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in big-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU16BE(const AValue: UInt16); inline;

    /// <summary>
    ///  Write a signed 16-bit integer to the stream as big-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in big-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS16BE(const AValue: Int16); inline;

    /// <summary>
    ///  Write an unsigned 32-bit integer to the stream as little-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in little-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU32LE(const AValue: UInt32); inline;

    /// <summary>
    ///  Write a signed 32-bit integer to the stream as little-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in little-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS32LE(const AValue: Int32); inline;

    /// <summary>
    ///  Write an unsigned 32-bit integer to the stream as big-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in big-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU32BE(const AValue: UInt32); inline;

    /// <summary>
    ///  Write a signed 32-bit integer to the stream as big-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in big-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS32BE(const AValue: Int32); inline;

    /// <summary>
    ///  Write an unsigned 64-bit integer to the stream as little-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in little-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU64LE(const AValue: UInt64); inline;

    /// <summary>
    ///  Write a signed 64-bit integer to the stream as little-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in little-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS64LE(const AValue: Int64); inline;

    /// <summary>
    ///  Write an unsigned 64-bit integer to the stream as big-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in big-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteU64BE(const AValue: UInt64); inline;

    /// <summary>
    ///  Write a signed 64-bit integer to the stream as big-endian data.
    ///
    ///  SDL byteswaps the data only if necessary, so the application always
    ///  specifies native format, and the data written will be in big-endian
    ///  format.
    /// </summary>
    /// <param name="AValue">The value to write.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    procedure WriteS64BE(const AValue: Int64); inline;

    /// <summary>
    ///  The status of the stream.
    ///
    ///  This information can be useful to decide if a short read or write was due
    ///  to an error, an EOF, or a non-blocking operation that isn't yet ready to
    ///  complete.
    ///
    ///  The status is only expected to change after a Read or Write call; don't
    ///  expect it to change if you just read this property in a tight loop.
    /// </summary>
    /// <remarks>
    ///  This property is not thread safe.
    /// </remarks>
    property Status: TSdlIOStatus read GetStatus;

    /// <summary>
    ///  The size of the data stream.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function is not thread safe.
    /// </remarks>
    property Size: Int64 read GetSize;

    /// <summary>
    ///  The properties associated with this stream.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property is not thread safe.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;

/// <summary>
///  Load all the data from a file path.
///
///  The data is allocated with a zero byte at the end (null terminated) for
///  convenience. This extra byte is not included in the value reported via
///  `ADataSize`.
///
///  The data should be freed with SdlFree.
/// </summary>
/// <param name="AFilename">The path to read all available data from.</param>
/// <param name="ADataSize">Set to the number of bytes read.</param>
/// <returns>The data.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlIOStream.Load"/>
/// <seealso cref="SdlSave"/>
/// <remarks>
///  This function is not thread safe.
/// </remarks>
function SdlLoad(const AFilename: String; out ADataSize: NativeInt): Pointer; overload; inline;

/// <summary>
///  Load all the data from a file path.
///
///  The data is allocated with a zero byte at the end (null terminated) for
///  convenience.
///
///  The data should be freed with SdlFree.
/// </summary>
/// <param name="AFilename">The path to read all available data from.</param>
/// <returns>The data.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlIOStream.Load"/>
/// <seealso cref="SdlSave"/>
/// <remarks>
///  This function is not thread safe.
/// </remarks>
function SdlLoad(const AFilename: String): Pointer; overload; inline;

/// <summary>
///  Save all the data into a file path.
/// </summary>
/// <param name="AFilename">The path to write all available data into.</param>
/// <param name="AData">The data to be written. If ADataSize is 0, may be nil
///  or a invalid pointer.</param>
/// <param name="ADataSize">The number of bytes to be written.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlIOStream.Save"/>
/// <seealso cref="SdlLoad"/>
/// <remarks>
///  This routine is not thread safe.
/// </remarks>
procedure SdlSave(const AFilename: String; const AData: Pointer;
  const ADataSize: NativeInt); inline;
{$ENDREGION 'I/O Streams'}

{$REGION 'Async I/O'}
/// <summary>
///  SDL offers a way to perform I/O asynchronously. This allows an app to read
///  or write files without waiting for data to actually transfer; the functions
///  that request I/O never block while the request is fulfilled.
///
///  Instead, the data moves in the background and the app can check for results
///  at their leisure.
///
///  This is more complicated than just reading and writing files in a
///  synchronous way, but it can allow for more efficiency, and never having
///  framerate drops as the hard drive catches up, etc.
///
///  The general usage pattern for async I/O is:
///
///  - Create one or more TSdlAsyncIOQueue objects.
///  - Open files with TSdlAsyncIO.
///  - Start I/O tasks to the files with TSdlAsyncIO.Read or TSdlAsyncIO.Write,
///    putting those tasks into one of the queues.
///  - Later on, use TSdlAsyncIOQueue.GetResult on a queue to see if any task is
///    finished without blocking. Tasks might finish in any order with success
///    or failure.
///  - When all your tasks are done, close the file with TSdlAsyncIO.Free. This
///    also generates a task, since it might flush data to disk!
///
///  This all works, without blocking, in a single thread, but one can also wait
///  on a queue in a background thread, sleeping until new results have arrived:
///
///  - Call TSdlAsyncIOQueue.GetResult from one or more threads to efficiently
///    block until new tasks complete.
///  - When shutting down, call TSdlAsyncIOQueue.Signal to unblock any sleeping
///    threads despite there being no new tasks completed.
///
///  And, of course, to match the synchronous SdlLoad, we offer SdlLoadAsync as
///  a convenience function. This will handle allocating a buffer, slurping in
///  the file data, and null-terminating it; you still check for results later.
///
///  Behind the scenes, SDL will use newer, efficient APIs on platforms that
///  support them: Linux's io_uring and Windows 11's IoRing, for example. If
///  those technologies aren't available, SDL will offload the work to a thread
///  pool that will manage otherwise-synchronous loads without blocking the app.
///
///  ## Best Practices
///
///  Simple non-blocking I/O--for an app that just wants to pick up data
///  whenever it's ready without losing framerate waiting on disks to spin--can
///  use whatever pattern works well for the program. In this case, simply call
///  TSdlAsyncIO.Read, or maybe SdlLoadAsync, as needed. Once a frame, call
///  TSdlAsyncIOQueue.GetResult to check for any completed tasks and deal with
///  the data as it arrives.
///
///  If two separate pieces of the same program need their own I/O, it is legal
///  for each to create their own queue. This will prevent either piece from
///  accidentally consuming the other's completed tasks. Each queue does require
///  some amount of resources, but it is not an overwhelming cost. Do not make a
///  queue for each task, however. It is better to put many tasks into a single
///  queue. They will be reported in order of completion, not in the order they
///  were submitted, so it doesn't generally matter what order tasks are
///  started.
///
///  One async I/O queue can be shared by multiple threads, or one thread can
///  have more than one queue, but the most efficient way--if ruthless
///  efficiency is the goal--is to have one queue per thread, with multiple
///  threads working in parallel, and attempt to keep each queue loaded with
///  tasks that are both started by and consumed by the same thread. On modern
///  platforms that can use newer interfaces, this can keep data flowing as
///  efficiently as possible all the way from storage hardware to the app, with
///  no contention between threads for access to the same queue.
///
///  Written data is not guaranteed to make it to physical media by the time a
///  closing task is completed, unless TSdlAsyncIO.Free is called with its
///  `AFlush` parameter set to true, which is to say that a successful result
///  here can still result in lost data during an unfortunately-timed power
///  outage if not flushed. However, flushing will take longer and may be
///  unnecessary, depending on the app's needs.
/// </summary>

type
  /// <summary>
  ///  Types of asynchronous I/O tasks.
  /// </summary>
  TSdlAsyncIOTaskKind = (
    /// <summary>
    ///  A read operation.
    /// </summary>
    Read  = SDL_ASYNCIO_TASK_READ,

    /// <summary>
    ///  A write operation.
    /// </summary>
    Write = SDL_ASYNCIO_TASK_WRITE,

    /// <summary>
    ///  A close operation.
    /// </summary>
    Close = SDL_ASYNCIO_TASK_CLOSE);

type
  /// <summary>
  ///  Possible outcomes of an asynchronous I/O task.
  /// </summary>
  TSdlAsyncIOResult = (
    /// <summary>
    ///  Request was completed without error.
    /// </summary>
    Complete = SDL_ASYNCIO_COMPLETE,

    /// <summary>
    ///  Request failed for some reason.
    /// </summary>
    Failure  = SDL_ASYNCIO_FAILURE,

    /// <summary>
    ///  Request was canceled before completing.
    /// </summary>
    Canceled = SDL_ASYNCIO_CANCELED);

type
  /// <summary>
  ///  Information about a completed asynchronous I/O request.
  /// </summary>
  TSdlAsyncIOOutcome = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AsyncIOOutcome;
    function GetKind: TSdlAsyncIOTaskKind; inline;
    function GetResult: TSdlAsyncIOResult; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  What sort of task was this? Read, write, etc?
    /// </summary>
    property Kind: TSdlAsyncIOTaskKind read GetKind;

    /// <summary>
    ///  The result of the work (success, failure, cancellation).
    /// </summary>
    property Result: TSdlAsyncIOResult read GetResult;

    /// <summary>
    ///  Buffer where data was read/written.
    /// </summary>
    property Buffer: Pointer read FHandle.buffer;

    /// <summary>
    ///  Offset in the TSdlAsyncIO where data was read/written.
    /// </summary>
    property Offset: Int64 read FHandle.offset;

    /// <summary>
    ///  Number of bytes the task was to read/write.
    /// </summary>
    property BytesRequested: Int64 read FHandle.bytes_requested;

    /// <summary>
    ///  actual number of bytes that were read/written.
    /// </summary>
    property BytesTransferred: Int64 read FHandle.bytes_transferred;

    /// <summary>
    ///  pointer provided by the app when starting the task
    /// </summary>
    property UserData: Pointer read FHandle.userdata;
  end;

type
  /// <summary>
  ///  A queue of completed asynchronous I/O tasks.
  ///
  ///  When starting an asynchronous operation, you specify a queue for the new
  ///  task. A queue can be asked later if any tasks in it have completed,
  ///  allowing an app to manage multiple pending tasks in one place, in whatever
  ///  order they complete.
  /// </summary>
  TSdlAsyncIOQueue = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AsyncIOQueue;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAsyncIOQueue; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAsyncIOQueue; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlAsyncIOQueue; inline; static;
  public
    /// <summary>
    ///  Create a task queue for tracking multiple I/O operations.
    ///
    ///  Async I/O operations are assigned to a queue when started. The queue can be
    ///  checked for completed tasks thereafter.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetResult"/>
    /// <seealso cref="WaitResult"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread
    /// </remarks>
    class function Create: TSdlAsyncIOQueue; inline; static;

    /// <summary>
    ///  Destroy a previously-created async I/O task queue.
    ///
    ///  If there are still tasks pending for this queue, this call will block until
    ///  those tasks are finished. All those tasks will be deallocated. Their
    ///  results will be lost to the app.
    ///
    ///  Any pending reads from SdlLoadAsync that are still in this queue will
    ///  have their buffers deallocated by this function, to prevent a memory
    ///  leak.
    ///
    ///  Once this function is called, the queue is no longer valid and should not
    ///  be used, including by other threads that might access it while destruction
    ///  is blocking on pending tasks.
    ///
    ///  Do not destroy a queue that still has threads waiting on it through
    ///  WaitResult. You can call Signal first to unblock those threads, and take
    ///  measures (such as waiting on a thread) to make sure they have finished
    ///  their wait and won't wait on the queue again.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this method from any thread, so long as no other
    ///  thread is waiting on the queue with WaitResult.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Query the async I/O task queue for completed tasks.
    ///
    ///  If a task assigned to this queue has finished, this will return True and
    ///  fill in `AOutcome` with the details of the task. If no task in the queue has
    ///  finished, this function will return False. This function does not block.
    ///
    ///  If a task has completed, this function will free its resources and the task
    ///  pointer will no longer be valid. The task will be removed from the queue.
    ///
    ///  It is safe for multiple threads to call this function on the same queue at
    ///  once; a completed task will only go to one of the threads.
    /// </summary>
    /// <param name="AOutcome">Details of a finished task will be written here.</param>
    /// <returns>True if a task has completed, False otherwise.</returns>
    /// <seealso cref="WaitResult"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function GetResult(out AOutcome: TSdlAsyncIOOutcome): Boolean; inline;

    /// <summary>
    ///  Block until an async I/O task queue has a completed task.
    ///
    ///  This function puts the calling thread to sleep until there a task assigned
    ///  to the queue that has finished.
    ///
    ///  If a task assigned to the queue has finished, this will return True and
    ///  fill in `AOutcome` with the details of the task. If no task in the queue has
    ///  finished, this function will return false.
    ///
    ///  If a task has completed, this function will free its resources and the task
    ///  pointer will no longer be valid. The task will be removed from the queue.
    ///
    ///  It is safe for multiple threads to call this function on the same queue at
    ///  once; a completed task will only go to one of the threads.
    ///
    ///  Note that by the nature of various platforms, more than one waiting thread
    ///  may wake to handle a single task, but only one will obtain it, so
    ///  `ATimeoutMS` is a _maximum_ wait time, and this function may return False
    ///  sooner.
    ///
    ///  This function may return False if there was a system error, the OS
    ///  inadvertently awoke multiple threads, or if Signal was called to wake
    ///  up all waiting threads without a finished task.
    ///
    ///  A timeout can be used to specify a maximum wait time, but rather than
    ///  polling, it is possible to have a timeout of -1 to wait forever, and use
    ///  Signal to wake up the waiting threads later.
    /// </summary>
    /// <param name="AOutcome">Details of a finished task will be written here.</param>
    /// <param name="ATimeoutMS">The maximum time to wait, in milliseconds,
    ///  or -1 to wait indefinitely.</param>
    /// <returns>True if task has completed, False otherwise.</returns>
    /// <seealso cref="Signal"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    function WaitResult(out AOutcome: TSdlAsyncIOOutcome;
      const ATimeoutMS: Integer): Boolean; inline;

    /// <summary>
    ///  Wake up any threads that are blocking in WaitResult.
    ///
    ///  This will unblock any threads that are sleeping in a call to WaitResult
    ///  for the specified queue, and cause them to return from that function.
    ///
    ///  This can be useful when destroying a queue to make sure nothing is touching
    ///  it indefinitely. In this case, once this call completes, the caller should
    ///  take measures to make sure any previously-blocked threads have returned
    ///  from their wait and will not touch the queue again (perhaps by setting a
    ///  flag to tell the threads to terminate and then waiting for a thread to
    ///  finish to make sure they've done so).
    /// </summary>
    /// <seealso cref="WaitResult"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Signal; inline;
  end;

type
  /// <summary>
  ///  The asynchronous I/O operation structure.
  ///
  ///  This operates as an opaque handle. One can then request read or write
  ///  operations on it.
  /// </summary>
  TSdlAsyncIO = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_AsyncIO;
    function GetSize: Int64; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAsyncIO; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAsyncIO; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlAsyncIO; inline; static;
  public
    /// <summary>
    ///  Create a new TSdlAsyncIO object for reading from and/or writing to a
    ///  named file.
    ///
    ///  The `AMode` string understands the following values:
    ///
    ///  - 'r': Open a file for reading. The file must exist.
    ///  - 'w': Open a file for writing only. It will create missing files or
    ///    truncate existing ones.
    ///  - 'r+': Open a file for update both reading and writing. The file must
    ///    exist.
    ///  - 'w+': Create an empty file for both reading and writing. If a file with
    ///    the same name already exists its content is erased and the file is
    ///    treated as a new empty file.
    ///
    ///  There is no 'b' mode, as there is only "binary" style I/O, and no 'a' mode
    ///  for appending, since you specify the position when starting a task.
    ///
    ///  This call is _not_ asynchronous; it will open the file before returning,
    ///  under the assumption that doing so is generally a fast operation. Future
    ///  reads and writes to the opened file will be async, however.
    /// </summary>
    /// <param name="AFilename">The filename to open.</param>
    /// <param name="AMode">String representing the mode to be used for opening
    ///  the file.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Read"/>
    /// <seealso cref="Write"/>
    constructor Create(const AFilename, AMode: String);

    /// <summary>
    ///  Close and free any allocated resources for an async I/O object.
    ///
    ///  Closing a file is _also_ an asynchronous task! If a write failure were to
    ///  happen during the closing process, for example, the task results will
    ///  report it as usual.
    ///
    ///  Closing a file that has been written to does not guarantee the data has
    ///  made it to physical media; it may remain in the operating system's file
    ///  cache, for later writing to disk. This means that a successfully-closed
    ///  file can be lost if the system crashes or loses power in this small window.
    ///  To prevent this, call this method with the `AFlush` parameter set to True.
    ///  This will make the operation take longer, and perhaps increase system load
    ///  in general, but a successful result guarantees that the data has made it to
    ///  physical storage. Don't use this for temporary files, caches, and
    ///  unimportant data, and definitely use it for crucial irreplaceable files,
    ///  like game saves.
    ///
    ///  This method guarantees that the close will happen after any other
    ///  pending tasks, so it's safe to open a file, start several operations,
    ///  close the file immediately, then check for all results later. This method
    ///  will not block until the tasks have completed.
    ///
    ///  Once this method returns, this object is no longer valid, regardless
    ///  of any future outcomes. Any completed tasks might still contain this
    ///  pointer in their TSdlAsyncIOOutcome data, in case the app was using this
    ///  value to track information, but it should not be used again.
    ///
    ///  If this function raises an error, the close wasn't started at all, and
    ///  it's safe to attempt to close again later.
    ///
    ///  A TSdlAsyncIOQueue must be specified. The newly-created task will be added
    ///  to it when it completes its work.
    /// </summary>
    /// <param name="AFlush">True if data should sync to disk before the task completes.</param>
    /// <param name="AQueue">A queue to add the TSdlAsyncIO to.</param>
    /// <param name="AUserdata">An app-defined pointer that will be provided
    ///  with the task results.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread, but two threads should
    ///  not attempt to close the same object.
    /// </remarks>
    procedure Free(const AFlush: Boolean; const AQueue: TSdlAsyncIOQueue;
      const AUserData: Pointer); inline;

    /// <summary>
    ///  Start an async read.
    ///
    ///  This method reads up to `ASize` bytes from `AOffset` position in the data
    ///  source to the area pointed at by `APtr`. This method may read less bytes
    ///  than requested.
    ///
    ///  This method returns as quickly as possible; it does not wait for the read
    ///  to complete. On a successful return, this work will continue in the
    ///  background. If the work begins, even failure is asynchronous: a failing
    ///  return value from this method only means the work couldn't start at all.
    ///
    ///  `APtr` must remain available until the work is done, and may be accessed by
    ///  the system at any time until then. Do not allocate it on the stack, as this
    ///  might take longer than the life of the calling method to complete!
    ///
    ///  A TSdlAsyncIOQueue must be specified. The newly-created task will be added
    ///  to it when it completes its work.
    /// </summary>
    /// <param name="APtr">A pointer to a buffer to read data into.</param>
    /// <param name="AOffset">The position to start reading in the data source.</param>
    /// <param name="ASize">The number of bytes to read from the data source.</param>
    /// <param name="AQueue">A queue to add the TSdlAsyncIO to.</param>
    /// <param name="AUserdata">An app-defined pointer that will be provided
    ///  with the task results.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Write"/>
    /// <seealso cref="TSdlAsyncIOQueue"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Read(const APtr: Pointer; const AOffset, ASize: Int64;
      const AQueue: TSdlAsyncIOQueue; const AUserData: Pointer); inline;

    /// <summary>
    ///  Start an async write.
    ///
    ///  This method writes `ASize` bytes from `AOffset` position in the data source
    ///  to the area pointed at by `APtr`.
    ///
    ///  This method returns as quickly as possible; it does not wait for the
    ///  write to complete. On a successful return, this work will continue in the
    ///  background. If the work begins, even failure is asynchronous: a failing
    ///  return value from this method only means the work couldn't start at all.
    ///
    ///  `APtr` must remain available until the work is done, and may be accessed by
    ///  the system at any time until then. Do not allocate it on the stack, as this
    ///  might take longer than the life of the calling method to complete!
    ///
    ///  A TSdlAsyncIOQueue must be specified. The newly-created task will be added
    ///  to it when it completes its work.
    /// </summary>
    /// <param name="APtr">A pointer to a buffer to write data from.</param>
    /// <param name="AOffset">The position to start writing to the data source.</param>
    /// <param name="ASize">The number of bytes to write to the data source.</param>
    /// <param name="AQueue">A queue to add the TSdlAsyncIO to.</param>
    /// <param name="AUserdata">An app-defined pointer that will be provided
    ///  with the task results.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Read"/>
    /// <seealso cref="TSdlAsyncIOQueue"/>
    /// <remarks>
    ///  It is safe to call this method from any thread
    /// </remarks>
    procedure Write(const APtr: Pointer; const AOffset, ASize: Int64;
      const AQueue: TSdlAsyncIOQueue; const AUserData: Pointer); inline;

    /// <summary>
    ///  The size of the data stream.
    ///
    ///  This call is _not_ asynchronous; it assumes that obtaining this info is a
    ///  non-blocking operation in most reasonable cases.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Size: Int64 read GetSize;
  end;

type
  _SdlAsyncIOOutcomeHelper = record helper for TSdlAsyncIOOutcome
  {$REGION 'Internal Declarations'}
  private
    function GetAsyncIO: TSdlAsyncIO; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  What generated this task. This will be invalid if it was closed!
    /// </summary>
    property AsyncIO: TSdlAsyncIO read GetAsyncIO;
  end;

/// <summary>
///  Load all the data from a file path, asynchronously.
///
///  This routine returns as quickly as possible; it does not wait for the read
///  to complete. On a successful return, this work will continue in the
///  background. If the work begins, even failure is asynchronous: a failing
///  return value from this function only means the work couldn't start at all.
///
///  The data is allocated with a zero byte at the end (null terminated) for
///  convenience. This extra byte is not included in TSdlAsyncIOOutcome's
///  BytesTransferred value.
///
///  This routine will allocate the buffer to contain the file. It must be
///  deallocated by calling SdlFree on TSdlAsyncIOOutcome's buffer field
///  after completion.
///
///  A TSdlAsyncIOQueue must be specified. The newly-created task will be added
///  to it when it completes its work.
/// </summary>
/// <param name="AFilename">The path to read all available data from.</param>
/// <param name="AQueue">A queue to add the new TSdlAsyncIO to.</param>
/// <param name="AUserdata">An app-defined pointer that will be provided with
///  the task results.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlLoad"/>
procedure SdlLoadAsync(const AFilename: String; const AQueue: TSdlAsyncIOQueue;
  const AUserData: Pointer);
{$ENDREGION 'Async I/O'}

{$REGION 'Storage Abstraction'}
/// <summary>
///  The storage API is a high-level API designed to abstract away the
///  portability issues that come up when using something lower-level (in SDL's
///  case, this sits on top of the Filesystem and TSdlIOStream subsystems). It
///  is significantly more restrictive than a typical filesystem API, for
///  a number of reasons:
///
///  1. **What to Access:** A common pitfall with existing filesystem APIs is
///  the assumption that all storage is monolithic. However, many other
///  platforms (game consoles in particular) are more strict about what _type_
///  of filesystem is being accessed; for example, game content and user data
///  are usually two separate storage devices with entirely different
///  characteristics (and possibly different low-level APIs altogether!).
///
///  2. **How to Access:** Another common mistake is applications assuming that
///  all storage is universally writeable - again, many platforms treat game
///  content and user data as two separate storage devices, and only user data
///  is writeable while game content is read-only.
///
///  3. **When to Access:** The most common portability issue with filesystem
///  access is _timing_ - you cannot always assume that the storage device is
///  always accessible all of the time, nor can you assume that there are no
///  limits to how long you have access to a particular device.
///
///  Consider the following example:
///
///  ```
///  procedure ReadGameData(const AFilenames: TArray<String>);
///  begin
///    for var Filename in AFilenames do
///    begin
///      try
///        var Stream := TFileStream.Create(Filename, fmOpenRead or fmShareDenyWrite);
///        try
///          // A bunch of stuff happens here
///        finally
///          Stream.Free;
///        end;
///      except
///        // Something bad happened
///      end;
///    end;
///  end;
///
///  procedure ReadSave;
///  begin
///    try
///      var Save := TFileStream.Create('saves/save0.sav', fmOpenRead or fmShareDenyWrite);
///      try
///        // A bunch of stuff happens here
///      finally
///        Stream.Free;
///      end;
///    except
///      // Something bad happened
///    end;
///  end;
///
///  procedure WriteSave;
///  begin
///    try
///      var Save := TFileStream.Create('saves/save0.sav', fmCreate or fmShareDenyWrite);
///      try
///        // A bunch of stuff happens here
///      finally
///        Stream.Free;
///      end;
///    except
///      // Something bad happened
///    end;
///  end;
///  ```
///
///  Going over the bullet points again:
///
///  1. **What to Access:** This code accesses a global filesystem; game data
///  and saves are all presumed to be in the current working directory (which
///  may or may not be the game's installation folder!).
///
///  2. **How to Access:** This code assumes that content paths are writeable,
///  and that save data is also writeable despite being in the same location as
///  the game data.
///
///  3. **When to Access:** This code assumes that they can be called at any
///  time, since the filesystem is always accessible and has no limits on how
///  long the filesystem is being accessed.
///
///  Due to these assumptions, the filesystem code is not portable and will fail
///  under these common scenarios:
///
///  - The game is installed on a device that is read-only, both content loading
///    and game saves will fail or crash outright
///  - Game/User storage is not implicitly mounted, so no files will be found
///    for either scenario when a platform requires explicitly mounting
///    filesystems
///  - Save data may not be safe since the I/O is not being flushed or
///    validated, so an error occurring elsewhere in the program may result in
///    missing/corrupted save data
///
///  When using TSdlStorage, these types of problems are virtually impossible to
///  trip over:
///
///  ```
///  procedure ReadGameData(const AFilenames: TArray<String>);
///  begin
///    var Title := TSdlStorage.OpenTitle;
///    try
///      while (not Title.IsReady) do
///        SdlDelay(1);
///
///      for var Filename in AFilenames do
///      begin
///        var Data := Title.ReadFile(Filename);
///        // A bunch of stuff happens here
///      end;
///    finally
///      Title.Free;
///    end;
///  end;
///
///  procedure ReadSave;
///  begin
///    var User := TSdlStorage.OpenUser('libsdl', 'Storage Example');
///    try
///      while (not User.IsReady) do
///        SdlDelay(1);
///
///      var Data := User.ReadFile('save0.sav');
///      // A bunch of stuff happens here
///    finally
///      User.Free;
///    end;
///  end;
///
///  procedure WriteSave(const AData: TBytes);
///  begin
///    var User := TSdlStorage.OpenUser('libsdl', 'Storage Example');
///    try
///      while (not User.IsReady) do
///        SdlDelay(1);
///
///      // A bunch of stuff happens here
///      User.WriteFile('save0.sav', AData);
///    finally
///      User.Free;
///    end;
///  end;
///  ```
///
///  Note the improvements that TSdlStorage makes:
///
///  1. **What to Access:** This code explicitly reads from a title or user
///     storage device based on the context of the function.
///
///  2. **How to Access:** This code explicitly uses either a read or write
///     function based on the context of the function.
///
///  3. **When to Access:** This code explicitly opens the device when it needs
///     to, and closes it when it is finished working with the filesystem.
///
///  The result is an application that is significantly more robust against the
///  increasing demands of platforms and their filesystems!
///
///  A publicly available example of an SDL_Storage backend is the
///  [Steam Cloud](https://partner.steamgames.com/doc/features/cloud)
///  backend - you can initialize Steamworks when starting the program, and then
///  SDL will recognize that Steamworks is initialized and automatically use
///  ISteamRemoteStorage when the application opens user storage. More
///  importantly, when you _open_ storage it knows to begin a "batch" of
///  filesystem operations, and when you _close_ storage it knows to end and
///  flush the batch. This is used by Steam to support
///  [Dynamic Cloud Sync](https://steamcommunity.com/groups/steamworks/announcements/detail/3142949576401813670)
///  ; users can save data on one PC, put the device to sleep, and then continue
///  playing on another PC (and vice versa) with the save data fully
///  synchronized across all devices, allowing for a seamless experience without
///  having to do full restarts of the program.
///
///  ## Notes on valid paths
///
///  All paths in the Storage API use Unix-style path separators ('/'). Using a
///  different path separator will not work, even if the underlying platform
///  would otherwise accept it. This is to keep code using the Storage API
///  portable between platforms and Storage implementations and simplify app
///  code.
///
///  Paths with relative directories ('.' and '..') are forbidden by the Storage
///  API.
///
///  All valid Unicode strings (discounting the '/' path separator) are usable
///  for filenames, however, an underlying Storage implementation may not
///  support particularly strange sequences and refuse to create files with
///  those names, etc.
/// </summary>

type
  /// <summary>
  ///  Function interface for TSdlStorage.
  ///
  ///  Apps that want to supply a custom implementation of TSdlStorage will fill
  ///  in all the functions in this record, and then pass it to TSdlStorage.Open
  ///  create a custom TSdlStorage object.
  ///
  ///  It is not usually necessary to do this; SDL provides standard
  ///  implementations for many things you might expect to do with a TSdlStorage.
  ///
  ///  This structure should be initialized using Init.
  ///
  ///  Note that all function pointers uses the "cdecl" calling conventions
  ///  since these are directly using by the SDL C API.
  /// </summary>
  TSdlStorageInterface = record
  public
    Version: Cardinal;

    Close: function(AUserData: Pointer): Boolean; cdecl;

    Ready: function(AUserData: Pointer): Boolean; cdecl;

    Enumerate: function(AUserData: Pointer; const APath: PUTF8Char;
      ACallback: SDL_EnumerateDirectoryCallback; ACallbackUserData: Pointer): Boolean; cdecl;

    Info: function(AUserData: Pointer; const APath: PUTF8Char;
      AInfo: PSDL_PathInfo): Boolean; cdecl;

    ReadFile: function(AUserData: Pointer; const APath: PUTF8Char;
      ADestination: Pointer; ALength: Int64): Boolean; cdecl;

    WriteFile: function(AUserData: Pointer; const APath: PUTF8Char;
      const ASource: Pointer; ALength: Int64): Boolean; cdecl;

    MkDir: function(AUserData: Pointer; const APath: PUTF8Char): Boolean; cdecl;

    Remove: function(AUserData: Pointer; const APath: PUTF8Char): Boolean; cdecl;

    Rename: function(AUserData: Pointer; const AOldPath, ANewPath: PUTF8Char): Boolean; cdecl;

    Copy: function(AUserData: Pointer; const AOldPath, ANewPath: PUTF8Char): Boolean; cdecl;

    SpaceRemaining: function(AUserData: Pointer): Int64; cdecl;
  public
    /// <summary>
    ///  Initializes this interface by setting the Version field and clearing
    ///  all other fields.
    /// </summary>
    procedure Init;
  end;

type
  /// <summary>
  ///  An entry in a directory as returned by TSdlStorage.EnumerateDirectory.
  /// </summary>
  TSdlDirectoryEntry = record
  public
    /// <summary>
    ///  The directory name, ending with a '/'.
    /// </summary>
    Directory: String;

    /// <summary>
    ///  The filename.
    /// </summary>
    Filename: String;
  end;

type
  /// <summary>
  ///  Types of filesystem entries.
  ///  Note that there may be other sorts of items on a filesystem: devices,
  ///  symlinks, named pipes, etc. They are currently reported as Other.
  /// </summary>
  TSdlPathKind = (
    /// <summary>
    ///  Path does not exist.
    /// </summary>
    None      = SDL_PATHTYPE_NONE,

    /// <summary>
    ///  A normal file.
    /// </summary>
    &File     = SDL_PATHTYPE_FILE,

    /// <summary>
    ///  A directory.
    /// </summary>
    Directory = SDL_PATHTYPE_DIRECTORY,

    /// <summary>
    ///  Something completely different like a device node (not a symlink, those
    ///  are always followed)
    /// </summary>
    Other     = SDL_PATHTYPE_OTHER);

type
  /// <summary>
  ///  Information about a path on the filesystem.
  /// </summary>
  /// <seealso cref="TSdlStorage.GetPathInfo"/>
  TSdlPathInfo = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PathInfo;
    function GetKind: TSdlPathKind; inline;
    function GetSize: Int64; inline;
    function GetCreateTime: TDateTime; inline;
    function GetModifyTime: TDateTime; inline;
    function GetAccessTime: TDateTime; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The path type.
    /// </summary>
    property Kind: TSdlPathKind read GetKind;

    /// <summary>
    ///  The file size in bytes.
    /// </summary>
    property Size: Int64 read GetSize;

    /// <summary>
    ///  The time when the path was created.
    /// </summary>
    property CreateTime: TDateTime read GetCreateTime;

    /// <summary>
    ///  The last time the path was modified.
    /// </summary>
    property ModifyTime: TDateTime read GetModifyTime;

    /// <summary>
    ///  The last time the path was read.
    /// </summary>
    property AccessTime: TDateTime read GetAccessTime;
  end;

type
  /// <summary>
  ///  An abstract interface for filesystem access.
  /// </summary>
  TSdlStorage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Storage;
    function GetIsReady: Boolean; inline;
    function GetSpaceRemaining: Int64; inline;
  private
    class function EnumerateDirectoryCallback(AUserData: Pointer;
      const ADirName, AFilename: PUTF8Char): SDL_EnumerationResult; cdecl; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlStorage; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlStorage; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlStorage; inline; static;
  public
    /// <summary>
    ///  Opens up a read-only container for the application's filesystem.
    /// </summary>
    /// <param name="AOverride">(Optional) path to override the backend's default
    ///  title root.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="OpenUser"/>
    /// <seealso cref="ReadFile"/>
    class function OpenTitle(const AOverride: String = ''): TSdlStorage; overload; static;

    /// <summary>
    ///  Opens up a read-only container for the application's filesystem.
    /// </summary>
    /// <param name="AOverride">A path to override the backend's default title root.</param>
    /// <param name="AProps">A property list that may contain backend-specific
    ///  information.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="OpenUser"/>
    /// <seealso cref="ReadFile"/>
    class function OpenTitle(const AOverride: String;
      const AProps: TSdlProperties): TSdlStorage; overload; static;

    /// <summary>
    ///  Opens up a container for a user's unique read/write filesystem.
    ///
    ///  While title storage can generally be kept open throughout runtime, user
    ///  storage should only be opened when the client is ready to read/write files.
    ///  This allows the backend to properly batch file operations and flush them
    ///  when the container has been closed; ensuring safe and optimal save I/O.
    /// </summary>
    /// <param name="AOrg">The name of your organization.</param>
    /// <param name="AApp">The name of your application.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="OpenSystem"/>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="SpaceRemaining"/>
    /// <seealso cref="IsReady"/>
    /// <seealso cref="WriteFile"/>
    class function OpenUser(const AOrg, AApp: String): TSdlStorage; overload; static;

    /// <summary>
    ///  Opens up a container for a user's unique read/write filesystem.
    ///
    ///  While title storage can generally be kept open throughout runtime, user
    ///  storage should only be opened when the client is ready to read/write files.
    ///  This allows the backend to properly batch file operations and flush them
    ///  when the container has been closed; ensuring safe and optimal save I/O.
    /// </summary>
    /// <param name="AOrg">The name of your organization.</param>
    /// <param name="AApp">The name of your application.</param>
    /// <param name="AProps">A property list that may contain backend-specific
    ///  information.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="OpenSystem"/>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="SpaceRemaining"/>
    /// <seealso cref="IsReady"/>
    /// <seealso cref="WriteFile"/>
    class function OpenUser(const AOrg, AApp: String;
      const AProps: TSdlProperties): TSdlStorage; overload; static;

    /// <summary>
    ///  Opens up a container for local filesystem storage.
    ///
    ///  This is provided for development and tools. Portable applications should
    ///  use OpenTitle for access to game data and OpenUser for access to user data.
    /// </summary>
    /// <param name="APath">(Optional) base path prepended to all storage paths.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="SpaceRemaining"/>
    /// <seealso cref="OpenTitle"/>
    /// <seealso cref="OpenUser"/>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="WriteFile"/>
    class function OpenFile(const APath: String = ''): TSdlStorage; static;

    /// <summary>
    ///  Opens up a container using a client-provided storage interface.
    ///
    ///  Applications do not need to use this function unless they are providing
    ///  their own TSdlStorage implementation. If you just need a TSdlStorage, you
    ///  should use the built-in implementations in SDL, like OpenTitle
    ///  or OpenUser.
    /// </summary>
    /// <param name="AInterface">The interface that implements this storage,
    ///  initialized using Init.</param>
    /// <param name="AUserData">The pointer that will be passed to the interface
    ///  functions.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="SpaceRemaining"/>
    /// <seealso cref="OpenTitle"/>
    /// <seealso cref="OpenUser"/>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="WriteFile"/>
    /// <seealso cref="IsReady"/>
    /// <seealso cref="TSdlStorageInterface.Init"/>
    class function OpenCustom(const AInterface: TSdlStorageInterface;
      const AUserData: Pointer): TSdlStorage; static;

    /// <summary>
    ///  Closes and frees the storage container.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="OpenFile"/>
    /// <seealso cref="OpenCustom"/>
    /// <seealso cref="OpenTitle"/>
    /// <seealso cref="OpenUser"/>
    procedure Free; inline;

    /// <summary>
    ///  Alternative to Free.
    /// </summary>
    procedure Close; inline;

    /// <summary>
    ///  Query the size of a file within a storage container.
    /// </summary>
    /// <param name="APath">The relative path of the file to query.</param>
    /// <returns>The file's length.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="IsReady"/>
    function GetFileSize(const APath: String): Int64; inline;

    /// <summary>
    ///  Synchronously read a file from a storage container.
    /// </summary>
    /// <param name="APath">The relative path of the file to read.</param>
    /// <returns>The file's content.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="IsReady"/>
    /// <seealso cref="WriteFile"/>
    function ReadFile(const APath: String): TBytes; overload;

    /// <summary>
    ///  Synchronously read a file from a storage container into a client-provided
    ///  buffer.
    ///
    ///  The value of `ALength` must match the length of the file exactly; call
    ///  GetFileSize to get this value. This behavior may be relaxed in
    ///  a future release.
    /// </summary>
    /// <param name="APath">The relative path of the file to read.</param>
    /// <param name="ADestination">A client-provided buffer to read the file into.</param>
    /// <param name="ALength">The length of the destination buffer.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetFileSize"/>
    /// <seealso cref="IsReady"/>
    /// <seealso cref="WriteFile"/>
    procedure ReadFile(const APath: String; var ADestination;
      const ALength: Int64); overload; inline;

    /// <summary>
    ///  Synchronously write a file from client memory into a storage container.
    /// </summary>
    /// <param name="APath">The relative path of the file to write.</param>
    /// <param name="ASource">A client-provided buffer to write from.</param>
    /// <param name="ALength">The length of the source buffer.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SpaceRemaining"/>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="IsReady"/>
    procedure WriteFile(const APath: String; const ASource;
      const ALength: Int64); overload; inline;

    /// <summary>
    ///  Synchronously write a file.
    /// </summary>
    /// <param name="APath">The relative path of the file to write.</param>
    /// <param name="ASource">The buffer to write from.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SpaceRemaining"/>
    /// <seealso cref="ReadFile"/>
    /// <seealso cref="IsReady"/>
    procedure WriteFile(const APath: String; const ASource: TBytes); overload; inline;

    /// <summary>
    ///  Create a directory in a writable storage container.
    /// </summary>
    /// <param name="APath">The path of the directory to create.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsReady"/>
    procedure CreateDirectory(const APath: String); inline;

    /// <summary>
    ///  Enumerate a directory in the storage container.
    ///
    ///  If `APath` is empty, this is treated as a request to enumerate the root
    ///  of the storage container's tree.
    /// </summary>
    /// <param name="APath">(Optional) path of the directory to enumerate, or
    ///  empty (default) for the root.</param>
    /// <returns>An array of all entries in this directory.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsReady"/>
    function EnumerateDirectory(const APath: String = ''): TArray<TSdlDirectoryEntry>;

    /// <summary>
    ///  Enumerate a directory tree, filtered by pattern, and return a list.
    ///
    ///  Files are filtered out if they don't match the string in `APattern`, which
    ///  may contain wildcard characters '*' (match everything) and '?' (match one
    ///  character). If APattern is empty, no filtering is done and all results are
    ///  returned. Subdirectories are permitted, and are specified with a path
    ///  separator of '/'. Wildcard characters '*' and '?' never match a path
    ///  separator.
    ///
    ///  If `APath` is empty, this is treated as a request to enumerate the root of
    ///  the storage container's tree.
    /// </summary>
    /// <param name="APath">(Optional) path of the directory to enumerate, or
    ///  empty (default) for the root.</param>
    /// <param name="APattern">(Optional) pattern that files in the directory
    ///  must match, or empty to include all results.</param>
    /// <param name="ACaseInsensitive">(Optional) flag whether pattern matching
    ///  is case-insensitive (default False, meaning case-sensitive).</param>
    /// <returns>An array of strings.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread, assuming the storage
    ///  object is thread-safe.
    /// </remarks>
    function GlobDirectory(const APath: String = ''; const APattern: String = '';
      const ACaseInsensitive: Boolean = False): TArray<String>;

    /// <summary>
    ///  Remove a file or an empty directory in a writable storage container.
    /// </summary>
    /// <param name="APath">The path of the file or directory to remove.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsReady"/>
    procedure RemovePath(const APath: String); inline;

    /// <summary>
    ///  Rename a file or directory in a writable storage container.
    /// </summary>
    /// <param name="AOldpath">The old path.</param>
    /// <param name="ANewpath">The new path.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsReady"/>
    procedure RenamePath(const AOldPath, ANewPath: String); inline;

    /// <summary>
    ///  Copy a file in a writable storage container.
    /// </summary>
    /// <param name="AOldPath">The old path.</param>
    /// <param name="ANewPath">The new path.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsReady"/>
    procedure CopyFile(const AOldPath, ANewPath: String); inline;

    /// <summary>
    ///  Checks whether a path in the storage container exists.
    /// </summary>
    /// <param name="APath">The path to query.</param>
    /// <returns>True if the path exists, False otherwise.</returns>
    /// <seealso cref="IsReady"/>
    function PathExists(const APath: String): Boolean; inline;

    /// <summary>
    ///  Get information about a filesystem path in the storage container.
    /// </summary>
    /// <param name="APath">The path to query.</param>
    /// <returns>Information about the path.</returns>
    /// <exception name="ESdlError">Raised on failure (e.g. when the file does
    ///  not exist).</exception>
    /// <seealso cref="IsReady"/>
    function GetPathInfo(const APath: String): TSdlPathInfo; inline;

    /// <summary>
    ///  Whether the storage container is ready to use.
    ///
    ///  This property should be checked at regular intervals until it returns
    ///  True - however, it is not recommended to spinwait on this call, as the
    ///  backend may depend on a synchronous message loop.
    /// </summary>
    property IsReady: Boolean read GetIsReady;

    /// <summary>
    ///  The remaining space in a storage container.
    /// </summary>
    /// <returns>The amount of remaining space, in bytes.</returns>
    /// <seealso cref="IsReady"/>
    /// <seealso cref="WriteFile"/>
    property SpaceRemaining: Int64 read GetSpaceRemaining;
  end;

{$ENDREGION 'Storage Abstraction'}

implementation

uses
  System.Generics.Collections,
  System.DateUtils;

{ TSdlIOStreamInterface }

procedure TSdlIOStreamInterface.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
  Version := SizeOf(Self);
end;

{ TSdlIOStream }

function SdlLoad(const AFilename: String; out ADataSize: NativeInt): Pointer;
begin
  Result := SDL_LoadFile(__ToUtf8(AFilename), @ADataSize);
  SdlCheck(Result);
end;

function SdlLoad(const AFilename: String): Pointer;
begin
  Result := SDL_LoadFile(__ToUtf8(AFilename), nil);
  SdlCheck(Result);
end;

procedure SdlSave(const AFilename: String; const AData: Pointer;
  const ADataSize: NativeInt); inline;
begin
  SdlCheck(SDL_SaveFile(__ToUtf8(AFilename), AData, ADataSize));
end;

constructor TSdlIOStream.Create(const AFilename, AMode: String);
begin
  FHandle := SDL_IOFromFile(__ToUtf8(AFilename), __ToUtf8B(AMode));
  SdlCheck(FHandle);
end;

constructor TSdlIOStream.Create(const AMem: Pointer; const ASize: NativeInt;
  const AReadOnly: Boolean);
begin
  if (AReadOnly) then
    FHandle := SDL_IOFromConstMem(AMem, ASize)
  else
    FHandle := SDL_IOFromMem(AMem, ASize);

  SdlCheck(FHandle);
end;

class function TSdlIOStream.Create: TSdlIOStream;
begin
  Result.FHandle := SDL_IOFromDynamicMem;
  SdlCheck(Result.FHandle);
end;

constructor TSdlIOStream.Create(const AInterface: TSdlIOStreamInterface;
  const AUserData: Pointer);
begin
  FHandle := SDL_OpenIO(@AInterface, AUserData);
  SdlCheck(FHandle);
end;

class operator TSdlIOStream.Equal(const ALeft: TSdlIOStream;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlIOStream.Flush;
begin
  SdlCheck(SDL_FlushIO(FHandle));
end;

procedure TSdlIOStream.Free;
begin
  SdlCheck(SDL_CloseIO(FHandle));
end;

function TSdlIOStream.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetIOProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

function TSdlIOStream.GetSize: Int64;
begin
  Result := SDL_GetIOSize(FHandle);
  if (Result < 0) then
    __HandleError;
end;

function TSdlIOStream.GetStatus: TSdlIOStatus;
begin
  Result := TSdlIOStatus(SDL_GetIOStatus(FHandle));
end;

class operator TSdlIOStream.Implicit(const AValue: Pointer): TSdlIOStream;
begin
  Result.FHandle := THandle(AValue);
end;

function TSdlIOStream.Load(const AClose: Boolean): Pointer;
begin
  Result := SDL_LoadFile_IO(FHandle, nil, AClose);
  SdlCheck(Result);
end;

class operator TSdlIOStream.NotEqual(const ALeft: TSdlIOStream;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

function TSdlIOStream.Load(out ADataSize: NativeInt;
  const AClose: Boolean): Pointer;
begin
  Result := SDL_LoadFile_IO(FHandle, @ADataSize, AClose);
  SdlCheck(Result);
end;

function TSdlIOStream.Read(const APtr: Pointer;
  const ASize: NativeInt): NativeInt;
begin
  Result := SDL_ReadIO(FHandle, APtr, ASize);
  if (Result = 0) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS16BE: Int16;
begin
  if (not SDL_ReadS16BE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS16LE: Int16;
begin
  if (not SDL_ReadS16LE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS32BE: Int32;
begin
  if (not SDL_ReadS32BE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS32LE: Int32;
begin
  if (not SDL_ReadS32LE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS64BE: Int64;
begin
  if (not SDL_ReadS64BE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS64LE: Int64;
begin
  if (not SDL_ReadS64LE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadS8: Int8;
begin
  if (not SDL_ReadS8(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU16BE: UInt16;
begin
  if (not SDL_ReadU16BE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU16LE: UInt16;
begin
  if (not SDL_ReadU16LE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU32BE: UInt32;
begin
  if (not SDL_ReadU32BE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU32LE: UInt32;
begin
  if (not SDL_ReadU32LE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU64BE: UInt64;
begin
  if (not SDL_ReadU64BE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU64LE: UInt64;
begin
  if (not SDL_ReadU64LE(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

function TSdlIOStream.ReadU8: UInt8;
begin
  if (not SDL_ReadU8(FHandle, @Result)) and (SDL_GetIOStatus(FHandle) <> SDL_IO_STATUS_EOF) then
    __HandleError;
end;

procedure TSdlIOStream.Save(const AData: Pointer; const ADataSize: NativeInt;
  const AClose: Boolean);
begin
  SdlCheck(SDL_SaveFile_IO(FHandle, AData, ADataSize, AClose));
end;

function TSdlIOStream.Seek(const AOffset: Int64;
  const AWhence: TSdlIOWhence): Int64;
begin
  Result := SDL_SeekIO(FHandle, AOffset, Ord(AWhence));
  if (Result = -1) then
    __HandleError;
end;

function TSdlIOStream.Tell: Int64;
begin
  Result := SDL_TellIO(FHandle);
end;

function TSdlIOStream.Write(const APtr: Pointer;
  const ASize: NativeInt): NativeInt;
begin
  Result := SDL_WriteIO(FHandle, APtr, ASize);
  if (Result < ASize) then
  begin
    var Status := SDL_GetIOStatus(FHandle);
    if (Status = SDL_IO_STATUS_ERROR) or (Status = SDL_IO_STATUS_READONLY) then
      __HandleError;
  end;
end;

procedure TSdlIOStream.WriteS16BE(const AValue: Int16);
begin
  SdlCheck(SDL_WriteS16BE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteS16LE(const AValue: Int16);
begin
  SdlCheck(SDL_WriteS16LE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteS32BE(const AValue: Int32);
begin
  SdlCheck(SDL_WriteS32BE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteS32LE(const AValue: Int32);
begin
  SdlCheck(SDL_WriteS32LE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteS64BE(const AValue: Int64);
begin
  SdlCheck(SDL_WriteS64BE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteS64LE(const AValue: Int64);
begin
  SdlCheck(SDL_WriteS64LE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteS8(const AValue: Int8);
begin
  SdlCheck(SDL_WriteS8(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU16BE(const AValue: UInt16);
begin
  SdlCheck(SDL_WriteU16BE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU16LE(const AValue: UInt16);
begin
  SdlCheck(SDL_WriteU16LE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU32BE(const AValue: UInt32);
begin
  SdlCheck(SDL_WriteU32BE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU32LE(const AValue: UInt32);
begin
  SdlCheck(SDL_WriteU32LE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU64BE(const AValue: UInt64);
begin
  SdlCheck(SDL_WriteU64BE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU64LE(const AValue: UInt64);
begin
  SdlCheck(SDL_WriteU64LE(FHandle, AValue));
end;

procedure TSdlIOStream.WriteU8(const AValue: UInt8);
begin
  SdlCheck(SDL_WriteU8(FHandle, AValue));
end;

{ TSdlAsyncIO }

constructor TSdlAsyncIO.Create(const AFilename, AMode: String);
begin
  FHandle := SDL_AsyncIOFromFile(__ToUtf8(AFilename), __ToUtf8B(AMode));
  SdlCheck(FHandle);
end;

class operator TSdlAsyncIO.Equal(const ALeft: TSdlAsyncIO;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlAsyncIO.Free(const AFlush: Boolean;
  const AQueue: TSdlAsyncIOQueue; const AUserData: Pointer);
begin
  if (SdlSucceeded(SDL_CloseAsyncIO(FHandle, AFlush, AQueue.FHandle, AUserData))) then
    FHandle := 0;
end;

function TSdlAsyncIO.GetSize: Int64;
begin
  Result := SDL_GetAsyncIOSize(FHandle);
  if (Result < 0) then
    __HandleError;
end;

class operator TSdlAsyncIO.Implicit(const AValue: Pointer): TSdlAsyncIO;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlAsyncIO.NotEqual(const ALeft: TSdlAsyncIO;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlAsyncIO.Read(const APtr: Pointer; const AOffset, ASize: Int64;
  const AQueue: TSdlAsyncIOQueue; const AUserData: Pointer);
begin
  SdlCheck(SDL_ReadAsyncIO(FHandle, APtr, AOffset, ASize, AQueue.FHandle, AUserData));
end;

procedure TSdlAsyncIO.Write(const APtr: Pointer; const AOffset, ASize: Int64;
  const AQueue: TSdlAsyncIOQueue; const AUserData: Pointer);
begin
  SdlCheck(SDL_WriteAsyncIO(FHandle, APtr, AOffset, ASize, AQueue.FHandle, AUserData));
end;

{ TSdlAsyncIOOutcome }

function TSdlAsyncIOOutcome.GetKind: TSdlAsyncIOTaskKind;
begin
  Result := TSdlAsyncIOTaskKind(FHandle.&type);
end;

function TSdlAsyncIOOutcome.GetResult: TSdlAsyncIOResult;
begin
  Result := TSdlAsyncIOResult(FHandle.result);
end;

{ TSdlAsyncIOQueue }

class function TSdlAsyncIOQueue.Create: TSdlAsyncIOQueue;
begin
  Result.FHandle := SDL_CreateAsyncIOQueue;
  SdlCheck(Result.FHandle);
end;

class operator TSdlAsyncIOQueue.Equal(const ALeft: TSdlAsyncIOQueue;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlAsyncIOQueue.Free;
begin
 SDL_DestroyAsyncIOQueue(FHandle);
 FHandle := 0;
end;

function TSdlAsyncIOQueue.GetResult(out AOutcome: TSdlAsyncIOOutcome): Boolean;
begin
  Result := SDL_GetAsyncIOResult(FHandle, @AOutcome.FHandle);
end;

class operator TSdlAsyncIOQueue.Implicit(const AValue: Pointer): TSdlAsyncIOQueue;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlAsyncIOQueue.NotEqual(const ALeft: TSdlAsyncIOQueue;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlAsyncIOQueue.Signal;
begin
  SDL_SignalAsyncIOQueue(FHandle);
end;

function TSdlAsyncIOQueue.WaitResult(out AOutcome: TSdlAsyncIOOutcome;
  const ATimeoutMS: Integer): Boolean;
begin
  Result := SDL_WaitAsyncIOResult(FHandle, @AOutcome.FHandle, ATimeoutMS);
end;

{ _SdlAsyncIOOutcomeHelper }

function _SdlAsyncIOOutcomeHelper.GetAsyncIO: TSdlAsyncIO;
begin
  Result.FHandle := FHandle.asyncio;
end;

procedure SdlLoadAsync(const AFilename: String; const AQueue: TSdlAsyncIOQueue;
  const AUserData: Pointer);
begin
  SdlCheck(SDL_LoadFileAsync(__ToUtf8(AFilename), AQueue.FHandle, AUserData));
end;

{ TSdlStorageInterface }

procedure TSdlStorageInterface.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
  Version := SizeOf(Self);
end;

{ TSdlPathInfo }

function TSdlPathInfo.GetAccessTime: TDateTime;
begin
  Result := UnixToDateTime(FHandle.access_time);
end;

function TSdlPathInfo.GetCreateTime: TDateTime;
begin
  Result := UnixToDateTime(FHandle.create_time);
end;

function TSdlPathInfo.GetKind: TSdlPathKind;
begin
  Result := TSdlPathKind(FHandle.&type);
end;

function TSdlPathInfo.GetModifyTime: TDateTime;
begin
  Result := UnixToDateTime(FHandle.modify_time);
end;

function TSdlPathInfo.GetSize: Int64;
begin
  Result := FHandle.size;
end;

{ TSdlStorage }

procedure TSdlStorage.Close;
begin
  SdlCheck(SDL_CloseStorage(FHandle));
  FHandle := 0;
end;

procedure TSdlStorage.CopyFile(const AOldPath, ANewPath: String);
begin
  SdlCheck(SDL_CopyStorageFile(FHandle, __ToUtf8(AOldPath), __ToUtf8B(ANewPath)));
end;

procedure TSdlStorage.CreateDirectory(const APath: String);
begin
  SdlCheck(SDL_CreateStorageDirectory(FHandle, __ToUtf8(APath)));
end;

function TSdlStorage.EnumerateDirectory(
  const APath: String): TArray<TSdlDirectoryEntry>;
begin
  var Entries := TList<TSdlDirectoryEntry>.Create;
  try
    SdlCheck(SDL_EnumerateStorageDirectory(FHandle, __ToUtf8(APath),
      EnumerateDirectoryCallback, Entries));
    Result := Entries.ToArray;
  finally
    Entries.Free;
  end;
end;

class function TSdlStorage.EnumerateDirectoryCallback(AUserData: Pointer;
  const ADirName, AFilename: PUTF8Char): SDL_EnumerationResult;
var
  Entries: TList<TSdlDirectoryEntry> absolute AUserData;
begin
  Assert(Assigned(AUserData));

  var Entry: TSdlDirectoryEntry;
  Entry.Directory := __ToString(ADirName);
  Entry.Filename := __ToString(AFilename);
  Entries.Add(Entry);

  Result := SDL_ENUM_CONTINUE;
end;

class operator TSdlStorage.Equal(const ALeft: TSdlStorage;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlStorage.Free;
begin
  SdlCheck(SDL_CloseStorage(FHandle));
  FHandle := 0;
end;

function TSdlStorage.GetFileSize(const APath: String): Int64;
begin
  SdlCheck(SDL_GetStorageFileSize(FHandle, __ToUtf8(APath), @Result));
end;

function TSdlStorage.GetIsReady: Boolean;
begin
  Result := SDL_StorageReady(FHandle);
end;

function TSdlStorage.GetPathInfo(const APath: String): TSdlPathInfo;
begin
  SdlCheck(SDL_GetStoragePathInfo(FHandle, __ToUtf8(APath), @Result.FHandle));
end;

function TSdlStorage.GetSpaceRemaining: Int64;
begin
  Result := SDL_GetStorageSpaceRemaining(FHandle);
end;

function TSdlStorage.GlobDirectory(const APath, APattern: String;
  const ACaseInsensitive: Boolean): TArray<String>;
begin
  var Flags: SDL_GlobFlags := 0;
  if (ACaseInsensitive) then
    Flags := SDL_GLOB_CASEINSENSITIVE;

  var Count := 0;
  var Entries := SDL_GlobStorageDirectory(FHandle, __ToUtf8(APath),
    __ToUtf8B(APattern), Flags, @Count);

  if (SdlSucceeded(Entries)) then
  try
    var P := Entries;
    SetLength(Result, Count);
    for var I := 0 to Count - 1 do
    begin
      Result[I] := __ToString(P^);
      Inc(P);
    end;
  finally
    SDL_free(Entries);
  end;
end;

class operator TSdlStorage.Implicit(const AValue: Pointer): TSdlStorage;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlStorage.NotEqual(const ALeft: TSdlStorage;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class function TSdlStorage.OpenCustom(const AInterface: TSdlStorageInterface;
  const AUserData: Pointer): TSdlStorage;
begin
  Result.FHandle := SDL_OpenStorage(@AInterface, AUserData);
  SdlCheck(Result.FHandle);
end;

class function TSdlStorage.OpenFile(const APath: String): TSdlStorage;
begin
  Result.FHandle := SDL_OpenFileStorage(__ToUtf8(APath));
  SdlCheck(Result.FHandle);
end;

class function TSdlStorage.OpenTitle(const AOverride: String;
  const AProps: TSdlProperties): TSdlStorage;
begin
  Result.FHandle := SDL_OpenTitleStorage(__ToUtf8(AOverride), SDL_PropertiesID(AProps));
  SdlCheck(Result.FHandle);
end;

class function TSdlStorage.OpenTitle(const AOverride: String): TSdlStorage;
begin
  Result.FHandle := SDL_OpenTitleStorage(__ToUtf8(AOverride), 0);
  SdlCheck(Result.FHandle);
end;

class function TSdlStorage.OpenUser(const AOrg, AApp: String;
  const AProps: TSdlProperties): TSdlStorage;
begin
  Result.FHandle := SDL_OpenUserStorage(__ToUtf8(AOrg), __ToUtf8B(AApp),
    SDL_PropertiesID(AProps));
  SdlCheck(Result.FHandle);
end;

function TSdlStorage.PathExists(const APath: String): Boolean;
begin
  Result := SDL_GetStoragePathInfo(FHandle, __ToUtf8(APath), nil);
end;

procedure TSdlStorage.ReadFile(const APath: String; var ADestination;
  const ALength: Int64);
begin
  SdlCheck(SDL_ReadStorageFile(FHandle, __ToUtf8(APath), @ADestination, ALength));
end;

procedure TSdlStorage.RemovePath(const APath: String);
begin
  SdlCheck(SDL_RemoveStoragePath(FHandle, __ToUtf8(APath)));
end;

procedure TSdlStorage.RenamePath(const AOldPath, ANewPath: String);
begin
  SdlCheck(SDL_RenameStoragePath(FHandle, __ToUtf8(AOldPath), __ToUtf8B(ANewPath)));
end;

procedure TSdlStorage.WriteFile(const APath: String; const ASource: TBytes);
begin
  SdlCheck(SDL_WriteStorageFile(FHandle, __ToUtf8(APath), Pointer(ASource), Length(ASource)));
end;

procedure TSdlStorage.WriteFile(const APath: String; const ASource;
  const ALength: Int64);
begin
  SdlCheck(SDL_WriteStorageFile(FHandle, __ToUtf8(APath), @ASource, ALength));
end;

function TSdlStorage.ReadFile(const APath: String): TBytes;
begin
  var Path := __ToUtf8(APath);
  var Size: Int64 := 0;
  SdlCheck(SDL_GetStorageFileSize(FHandle, Path, @Size));
  if (Size = 0) then
    Exit(nil);

  SetLength(Result, Size);
  SdlCheck(SDL_ReadStorageFile(FHandle, Path, Pointer(Result), Size));
end;

class function TSdlStorage.OpenUser(const AOrg, AApp: String): TSdlStorage;
begin
  Result.FHandle := SDL_OpenUserStorage(__ToUtf8(AOrg), __ToUtf8B(AApp), 0);
  SdlCheck(Result.FHandle);
end;

end.
