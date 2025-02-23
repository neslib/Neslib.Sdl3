unit Neslib.Sdl3.Image;

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

{ NOTE: This is a separate SDL satellite library that is different from the main
  SDL library. If you use this unit, then for the Windows platform, you must
  deploy the appropriate SDL3_image.dll (either the 32-bit or 64-bit version)
  with your application. On other platforms, this library will be linked into
  your executable. }

interface

uses
  Neslib.Sdl3.Image.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.IO;

const
  SDL_IMAGE_MAJOR_VERSION = Neslib.Sdl3.Image.Api.SDL_IMAGE_MAJOR_VERSION;
  SDL_IMAGE_MINOR_VERSION = Neslib.Sdl3.Image.Api.SDL_IMAGE_MINOR_VERSION;
  SDL_IMAGE_MICRO_VERSION = Neslib.Sdl3.Image.Api.SDL_IMAGE_MICRO_VERSION;

type
  /// <summary>
  /// Animated image support
  ///
  /// Currently only animated GIFs are supported.
  /// </summary>
  TSdlAnimatedImage = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PIMG_Animation;
    function GetWidth: Integer; inline;
    function GetHeight: Integer; inline;
    function GetCount: Integer; inline;
    function GetDelay(const AIndex: Integer): Integer; inline;
    function GetFrame(const AIndex: Integer): TSdlSurface; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlAnimatedImage; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlAnimatedImage.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlAnimatedImage): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlAnimatedImage; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlAnimatedImage.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlAnimatedImage): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlAnimatedImage; inline; static;
  public
    /// <summary>
    /// Load an animation from a file.
    ///
    /// When done with the animation, the app should dispose of it with a
    /// call to Free.
    /// </summary>
    /// <param name="AFile">Path on the filesystem containing an animated image.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    constructor Create(const AFile: String); overload;

    /// <summary>
    /// Load an animation from an SDL datasource
    ///
    /// Even though this method accepts a file type, SDL_image may still try
    /// other decoders that are capable of detecting file type from the contents of
    /// the image data, but may rely on the caller-provided type string for formats
    /// that it cannot autodetect. If `AType` is empty, SDL_image will rely solely on
    /// its ability to guess the format.
    ///
    /// If `ACloseIO` is True, `ASrc` will be closed before returning, whether this
    /// function succeeds or not. SDL_image reads everything it needs from `ASrc`
    /// during this call in any case.
    ///
    /// When done with the animation, the app should dispose of it with a
    /// call to Free.
    /// </summary>
    /// <param name="ASrc">A TSdlIOStream that data will be read from.</param>
    /// <param name="ACloseIO">True to close/free the TSdlIOStream before returning,
    ///  False to leave it open.</param>
    /// <param name="AType">(Optional) filename extension that represent this
    ///  data ("GIF") or empty (default) to autodetect.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    constructor Create(const ASrc: TSdlIOStream; const ACloseIO: Boolean;
      const AType: String = ''); overload;

    /// <summary>
    /// Load a GIF animation directly.
    ///
    /// If you know you definitely have a GIF image, you can call this function,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use the Create constructor; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">A TSdlIOStream that data will be read from.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    constructor LoadGif(const ASrc: TSdlIOStream);

    /// <summary>
    /// Dispose of the animation and free its resources.
    ///
    /// The animation is not valid once this call returns.
    /// </summary>
    procedure Free; inline;

    /// <summary>
    ///  The width of the frames in the animation.
    /// </summary>
    property Width: Integer read GetWidth;

    /// <summary>
    ///  The height of the frames in the animation.
    /// </summary>
    property Height: Integer read GetHeight;

    /// <summary>
    ///  The number of frames in the animation.
    /// </summary>
    property FrameCount: Integer read GetCount;

    /// <summary>
    ///  The frames in the animation, as SDL surfaces
    /// </summary>
    property Frames[const AIndex: Integer]: TSdlSurface read GetFrame;

    /// <summary>
    ///  The delays after each frame, in milliseconds.
    /// </summary>
    property Delays[const AIndex: Integer]: Integer read GetDelay;
  end;

type
  /// <summary>
  ///  A simple library to load images of various formats as SDL surfaces.
  ///
  ///  The following formats are supported:
  ///
  ///   - BMP (Windows Bitmap Files)
  ///   - ICO (Icon files)
  ///   - CUR (Cursor files)
  ///   - GIF (also supports GIF animations using TSdlAnimatedImage)
  ///   - JPEG
  ///   - LBM (Delux Paint bitmap)
  ///   - PCX (Picture Exchange bitmap)
  ///   - PNG (Portable Network Graphics)
  ///   - PNM (Portable Any Map)
  ///   - SVG (Scalable Vector Graphics. There is a version of LoadSvg where
  ///     you can specify the dimensions to rasterize to)
  ///   - QOI (Quite OK Image format)
  ///   - TGA (Targa image format)
  ///   - XCF (GIMP bitmap)
  ///   - XPM (X Pixmap)
  ///   - XV (Kronos Visualization Image file)
  /// </summary>
  TSdlImage = record
  {$REGION 'Internal Declarations'}
  private
    class function GetVersion: Integer; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    /// Load an image from a filesystem path into a software surface.
    ///
    /// A TSdlSurface is a buffer of pixels in memory accessible by the CPU. Use
    /// this if you plan to hand the data to something else or manipulate it
    /// further in code.
    ///
    /// There are no guarantees about what format the new TSdlSurface data will be;
    /// in many cases, SDL_image will attempt to supply a surface that exactly
    /// matches the provided image, but in others it might have to convert (either
    /// because the image is in a format that SDL doesn't directly support or
    /// because it's compressed data that could reasonably uncompress to various
    /// formats and SDL_image had to pick one). You can inspect an TSdlSurface for
    /// its specifics, and use TSdlSurface.Convert to then migrate to any supported
    /// format.
    ///
    /// If the image format supports a transparent pixel, SDL will set the colorkey
    /// for the surface.
    ///
    /// There is an overloaded version to read files from an TSdlIOStream, if you
    /// need an I/O abstraction to provide data from anywhere instead of a simple
    /// filesystem read.
    ///
    /// If you are using SDL's 2D rendering API, there is an equivalent call to
    /// load images directly into a TSdlTexture for use by the GPU without using a
    /// software surface: call LoadTexture instead.
    ///
    /// When done with the returned surface, the app should dispose of it with a
    /// call to TSdlSurface.Free.
    /// </summary>
    /// <param name="AFile">A path on the filesystem to load an image from.</param>
    /// <returns>A new SDL surface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadTexture"/>
    /// <seealso cref="TSdlSurface.Free"/>
    class function Load(const AFile: String): TSdlSurface; overload; inline; static;

    /// <summary>
    /// Load an image from an SDL data source into a software surface.
    ///
    /// A TSdlSurface is a buffer of pixels in memory accessible by the CPU. Use
    /// this if you plan to hand the data to something else or manipulate it
    /// further in code.
    ///
    /// There are no guarantees about what format the new TSdlSurface data will be;
    /// in many cases, SDL_image will attempt to supply a surface that exactly
    /// matches the provided image, but in others it might have to convert (either
    /// because the image is in a format that SDL doesn't directly support or
    /// because it's compressed data that could reasonably uncompress to various
    /// formats and SDL_image had to pick one). You can inspect an TSdlSurface for
    /// its specifics, and use TSdlSurface.Convert to then migrate to any supported
    /// format.
    ///
    /// If the image format supports a transparent pixel, SDL will set the colorkey
    /// for the surface.
    ///
    /// If `ACloseIO` is True, `ASrc` will be closed before returning, whether this
    /// method succeeds or not. SDL_image reads everything it needs from `ASrc`
    /// during this call in any case.
    ///
    /// Even though this method accepts a file type, SDL_image may still try
    /// other decoders that are capable of detecting file type from the contents of
    /// the image data, but may rely on the caller-provided type string for formats
    /// that it cannot autodetect. If `AType` is empty, SDL_image will rely solely on
    /// its ability to guess the format.
    ///
    /// There is another overloaded method to read files from disk without having
    /// to deal with TSdlIOStream. That verion call this method and manage those
    /// details for you, determining the file type from the filename's extension.
    ///
    /// If you are using SDL's 2D rendering API, there is an equivalent call to
    /// load images directly into a TSdlTexture for use by the GPU without using a
    /// software surface: call LoadTexture instead.
    ///
    /// When done with the returned surface, the app should dispose of it with a
    /// call to TSdlSurface.Free.
    /// </summary>
    /// <param name="ASrc">A TSdlIOStream that data will be read from.</param>
    /// <param name="ACloseIO">True to close/free the TSdlIOStream before
    ///  returning, False to leave it open.</param>
    /// <param name="AType">(Optional) filename extension that represent this
    ///  data ("BMP", "GIF", "PNG", etc) or empty (default) to autodetect.</param>
    /// <returns>A new SDL surface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadTexture"/>
    /// <seealso cref="TSdlSurface.Free"/>
    class function Load(const ASrc: TSdlIOStream; const ACloseIO: Boolean;
      const AType: String = ''): TSdlSurface; overload; inline; static;

    /// <summary>
    /// Load an image from a filesystem path into a GPU texture.
    ///
    /// A TSdlTexture represents an image in GPU memory, usable by SDL's 2D Render
    /// API. This can be significantly more efficient than using a CPU-bound
    /// TSdlSurface if you don't need to manipulate the image directly after
    /// loading it.
    ///
    /// If the loaded image has transparency or a colorkey, a texture with an alpha
    /// channel will be created. Otherwise, SDL_image will attempt to create a
    /// TSdlTexture in the most format that most reasonably represents the image
    /// data (but in many cases, this will just end up being 32-bit RGB or 32-bit
    /// RGBA).
    ///
    /// There is an overloaded version to read files from an TSdlIOStream, if you
    /// need an I/O abstraction to provide data from anywhere instead of a simple
    /// filesystem read.
    ///
    /// If you would rather decode an image to an TSdlSurface (a buffer of pixels
    /// in CPU memory), call Load instead.
    ///
    /// When done with the returned texture, the app should dispose of it with a
    /// call to TSdlTexture.Free.
    /// </summary>
    /// <param name="ARenderer">The TSdlRenderer to use to create the GPU texture.</param>
    /// <param name="AFile">A path on the filesystem to load an image from.</param>
    /// <returns>A new texture.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Load"/>
    /// <seealso cref="TSdlTexture.Free"/>
    class function LoadTexture(const ARenderer: TSdlRenderer;
      const AFile: String): TSdlTexture; overload; inline; static;

    /// <summary>
    /// Load an image from an SDL data source into a GPU texture.
    ///
    /// A TSdlTexture represents an image in GPU memory, usable by SDL's 2D Render
    /// API. This can be significantly more efficient than using a CPU-bound
    /// TSdlSurface if you don't need to manipulate the image directly after
    /// loading it.
    ///
    /// If the loaded image has transparency or a colorkey, a texture with an alpha
    /// channel will be created. Otherwise, SDL_image will attempt to create a
    /// TSdlTexture in the most format that most reasonably represents the image
    /// data (but in many cases, this will just end up being 32-bit RGB or 32-bit
    /// RGBA).
    ///
    /// If `ACloseIO` is True, `ASrc` will be closed before returning, whether this
    /// method succeeds or not. SDL_image reads everything it needs from `ASrc`
    /// during this call in any case.
    ///
    /// Even though this method accepts a file type, SDL_image may still try
    /// other decoders that are capable of detecting file type from the contents of
    /// the image data, but may rely on the caller-provided type string for formats
    /// that it cannot autodetect. If `AType` is empty, SDL_image will rely solely on
    /// its ability to guess the format.
    ///
    /// There is another overloaded method to read files from disk without having
    /// to deal with TSdlIOStream. That verion call this method and manage those
    /// details for you, determining the file type from the filename's extension.
    ///
    /// If you would rather decode an image to an TSdlSurface (a buffer of pixels
    /// in CPU memory), call Load instead.
    ///
    /// When done with the returned texture, the app should dispose of it with a
    /// call to TSdlTexture.Free.
    /// </summary>
    /// <param name="ARenderer">The TSdlRenderer to use to create the GPU texture.</param>
    /// <param name="ASrc">A TSdlIOStream that data will be read from.</param>
    /// <param name="ACloseIO">True to close/free the TSdlIOStream before returning,
    ///  False to leave it open.</param>
    /// <param name="AType">(Optional) filename extension that represent this
    ///  data ("BMP", "GIF", "PNG", etc) or empty (default) to autodetect.</param>
    /// <returns>A new texture.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Load"/>
    /// <seealso cref="TSdlTexture.Free"/>
    class function LoadTexture(const ARenderer: TSdlRenderer;
      const ASrc: TSdlIOStream; const ACloseIO: Boolean;
      const AType: String = ''): TSdlTexture; overload; inline; static;

    /// <summary>
    /// Load a ICO image directly.
    ///
    /// If you know you definitely have a ICO image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadIco(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a CUR image directly.
    ///
    /// If you know you definitely have a CUR image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadCur(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a BMP image directly.
    ///
    /// If you know you definitely have a BMP image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadBmp(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a GIF image directly.
    ///
    /// If you know you definitely have a GIF image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadGif(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a JPG image directly.
    ///
    /// If you know you definitely have a JPG image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadJpg(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a LBM image directly.
    ///
    /// If you know you definitely have a LBM image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadLbm(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a PCX image directly.
    ///
    /// If you know you definitely have a PCX image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadPcx(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a PNG image directly.
    ///
    /// If you know you definitely have a PNG image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadPng(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a PNM image directly.
    ///
    /// If you know you definitely have a PNM image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadPnm(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a AVSVGIF image directly.
    ///
    /// If you know you definitely have a SVG image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadSvg(const ASrc: TSdlIOStream): TSdlSurface; overload; inline; static;

    /// <summary>
    /// Load an SVG image, scaled to a specific size.
    ///
    /// Since SVG files are resolution-independent, you specify the size you would
    /// like the output image to be and it will be generated at those dimensions.
    ///
    /// Either width or height may be 0 and the image will be auto-sized to
    /// preserve aspect ratio.
    ///
    /// When done with the returned surface, the app should dispose of it with a
    /// call to TSdlSurface.Free.
    /// </summary>
    /// <param name="ASrc">A TSdlIOStream to load SVG data from.</param>
    /// <param name="AWidth">Desired width of the generated surface, in pixels.</param>
    /// <param name="AHeight">Desired height of the generated surface, in pixels.</param>
    /// <returns>A new SDL surface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class function LoadSvg(const ASrc: TSdlIOStream;
      const AWidth, AHeight: Integer): TSdlSurface; overload; inline; static;

    /// <summary>
    /// Load a QOI image directly.
    ///
    /// If you know you definitely have a QOI image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadQoi(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a TGA image directly.
    ///
    /// If you know you definitely have a TGA image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadTga(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a XCF image directly.
    ///
    /// If you know you definitely have a XCF image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXpm"/>
    /// <seealso cref="LoadXV"/>
    class function LoadXcf(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Load a XPM image directly.
    ///
    /// If you know you definitely have a XPM image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXV"/>
    class function LoadXpm(const ASrc: TSdlIOStream): TSdlSurface; overload; inline; static;

    /// <summary>
    /// Load an XPM image from a memory array.
    ///
    /// The returned surface will be an 8bpp indexed surface, if possible,
    /// otherwise it will be 32bpp. If you always want 32-bit data, use
    /// LoadXpm32 instead.
    ///
    /// When done with the returned surface, the app should dispose of it with a
    /// call to TSdlSurface.Free.
    /// </summary>
    /// <param name="AXpm">An array of AnsiStrings that comprise XPM data.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadXpm32"/>
    class function LoadXpm(const AXpm: TArray<AnsiString>): TSdlSurface; overload; inline; static;

    /// <summary>
    /// Load an XPM image from a memory array.
    ///
    /// The returned surface will always be a 32-bit RGB surface. If you want 8-bit
    /// indexed colors (and the XPM data allows it), use LoadXpm instead.
    ///
    /// When done with the returned surface, the app should dispose of it with a
    /// call to TSdlSurface.Free.
    /// </summary>
    /// <param name="AXpm">An array of AnsiStrings that comprise XPM data.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadXpm"/>
    class function LoadXpm32(const AXpm: TArray<AnsiString>): TSdlSurface; inline; static;

    /// <summary>
    /// Load a XV image directly.
    ///
    /// If you know you definitely have a XV image, you can call this method,
    /// which will skip SDL_image's file format detection routines. Generally it's
    /// better to use Load or LoadTexture; also, there is only an TSdlIOStream
    /// interface available here.
    /// </summary>
    /// <param name="ASrc">An TSdlIOStream to load image data from.</param>
    /// <returns>A new TSdlSurface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadIco"/>
    /// <seealso cref="LoadCur"/>
    /// <seealso cref="LoadBmp"/>
    /// <seealso cref="LoadGif"/>
    /// <seealso cref="LoadJpg"/>
    /// <seealso cref="LoadLbm"/>
    /// <seealso cref="LoadPcx"/>
    /// <seealso cref="LoadPng"/>
    /// <seealso cref="LoadPnm"/>
    /// <seealso cref="LoadSvg"/>
    /// <seealso cref="LoadQoi"/>
    /// <seealso cref="LoadTga"/>
    /// <seealso cref="LoadXcf"/>
    /// <seealso cref="LoadXpm"/>
    class function LoadXV(const ASrc: TSdlIOStream): TSdlSurface; inline; static;

    /// <summary>
    /// Detect ICO image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is ICO data, False otherwise.</returns>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsIco(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect CUR image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is CUR data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsCur(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect BMP image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is BMP data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsBmp(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect GIF image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is GIF data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsGif(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect JPG image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is JPOG data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsJpg(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect LBM image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is LBM data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsLbm(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect PCX image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is PCX data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsPcx(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect PNG image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is PNG data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsPng(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect PNM image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is PNM data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsPnm(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect SVG image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is SVG data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsSvg(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect QOI image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is QOI data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsQoi(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect XCF image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is XCF data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXpm"/>
    /// <seealso cref="IsXV"/>
    class function IsXcf(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect XPM image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is XPM data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXV"/>
    class function IsXpm(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Detect XV image data on a readable/seekable TSdlIOStream.
    ///
    /// This method attempts to determine if a file is a given filetype, reading
    /// the least amount possible from the TSdlIOStream (usually a few bytes).
    ///
    /// There is no distinction made between "not the filetype in question" and
    /// basic I/O errors.
    ///
    /// This method will always attempt to seek `ASrc` back to where it started
    /// when this method was called, but it will not report any errors in doing
    /// so, but assuming seeking works, this means you can immediately use this
    /// with a different Is* method, or load the image without further seeking.
    ///
    /// You do not need to call this method to load data; SDL_image can work to
    /// determine file type in many cases in its standard load functions.
    /// </summary>
    /// <param name="ASrc">A seekable/readable TSdlIOStream to provide image data.</param>
    /// <returns>True if this is XV data, False otherwise.</returns>
    /// <seealso cref="IsIco"/>
    /// <seealso cref="IsCur"/>
    /// <seealso cref="IsBmp"/>
    /// <seealso cref="IsGif"/>
    /// <seealso cref="IsJpg"/>
    /// <seealso cref="IsLbm"/>
    /// <seealso cref="IsPcx"/>
    /// <seealso cref="IsPng"/>
    /// <seealso cref="IsPnm"/>
    /// <seealso cref="IsSvg"/>
    /// <seealso cref="IsQoi"/>
    /// <seealso cref="IsXcf"/>
    /// <seealso cref="IsXpm"/>
    class function IsXV(const ASrc: TSdlIOStream): Boolean; inline; static;

    /// <summary>
    /// Save a TSdlSurface into a PNG image file.
    ///
    /// If the file already exists, it will be overwritten.
    /// </summary>
    /// <param name="ASurface">The SDL surface to save.</param>
    /// <param name="AFile">Path on the filesystem to write new file to.</param>
    procedure SavePng(const ASurface: TSdlSurface; const AFile: String); overload;

    /// <summary>
    /// Save a TSdlSurface into PNG image data, via an TSdlIOStream.
    ///
    /// If you just want to save to a filename, you can use the other overloaded
    /// version instead.
    ///
    /// If `ACloseIO` is True, `ADst` will be closed before returning, whether this
    /// function succeeds or not.
    /// </summary>
    /// <param name="ASurface">The SDL surface to save.</param>
    /// <param name="ADst">The TSdlIOStream to save the image data to.</param>
    /// <param name="ACloseIO">True to close/free the TSdlIOStream before returning,
    ///  False to leave it open.</param>
    procedure SavePng(const ASurface: TSdlSurface; const ADst: TSdlIOStream;
      const ACloseIO: Boolean); overload;

    /// <summary>
    /// Save a TSdlSurface into a JPEG image file.
    ///
    /// If the file already exists, it will be overwritten.
    /// </summary>
    /// <param name="ASurface">The SDL surface to save.</param>
    /// <param name="AFile">Path on the filesystem to write new file to.</param>
    /// <param name="AQuality">0..33 is Lowest quality, 34..66 is Middle
    ///  quality, 67.100 is Highest quality..</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SaveJpg(const ASurface: TSdlSurface; const AFile: String;
      const AQuality: Integer); overload;

    /// <summary>
    /// Save a TSdlSurface into JPEG image data, via an TSdlIOStream.
    ///
    /// If you just want to save to a filename, you can use the other overloaded
    /// version instead.
    ///
    /// If `ACloseIO` is True, `ADst` will be closed before returning, whether this
    /// function succeeds or not.
    /// </summary>
    /// <param name="ASurface">The SDL surface to save.</param>
    /// <param name="ADst">The TSdlIOStream to save the image data to.</param>
    /// <param name="ACloseIO">True to close/free the TSdlIOStream before returning,
    ///  False to leave it open.</param>
    /// <param name="AQuality">0..33 is Lowest quality, 34..66 is Middle
    ///  quality, 67.100 is Highest quality..</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SaveJpg(const ASurface: TSdlSurface; const ADst: TSdlIOStream;
      const ACloseIO: Boolean; const AQuality: Integer); overload;

    /// <summary>
    ///  The version of the used SDL_image library.
    /// </summary>
    class property Version: Integer read GetVersion;
  end;

implementation

uses
  Neslib.Sdl3.Api;

{ TSdlAnimatedImage }

class operator TSdlAnimatedImage.Equal(const ALeft: TSdlAnimatedImage;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

constructor TSdlAnimatedImage.Create(const ASrc: TSdlIOStream;
  const ACloseIO: Boolean; const AType: String);
begin
  if (AType = '') then
    FHandle := IMG_LoadAnimation_IO(SDL_IOStream(ASrc), ACloseIO)
  else
    FHandle := IMG_LoadAnimationTyped_IO(SDL_IOStream(ASrc), ACloseIO, __ToUtf8(AType));
  SdlCheck(FHandle);
end;

constructor TSdlAnimatedImage.Create(const AFile: String);
begin
  FHandle := IMG_LoadAnimation(__ToUtf8(AFile));
  SdlCheck(FHandle);
end;

class operator TSdlAnimatedImage.Equal(const ALeft,
  ARight: TSdlAnimatedImage): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlAnimatedImage.Free;
begin
  IMG_FreeAnimation(FHandle);
  FHandle := nil;
end;

function TSdlAnimatedImage.GetCount: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.count
  else
    Result := 0;
end;

function TSdlAnimatedImage.GetDelay(const AIndex: Integer): Integer;
begin
  {$POINTERMATH ON}
  if Assigned(FHandle) then
    Result := FHandle.delays[AIndex]
  else
    Result := 0;
  {$POINTERMATH OFF}
end;

function TSdlAnimatedImage.GetFrame(const AIndex: Integer): TSdlSurface;
begin
  {$POINTERMATH ON}
  if Assigned(FHandle) then
    PSDL_Surface(Result) := FHandle.frames[AIndex]
  else
    Result := nil;
  {$POINTERMATH OFF}
end;

function TSdlAnimatedImage.GetHeight: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.h
  else
    Result := 0;
end;

function TSdlAnimatedImage.GetWidth: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.w
  else
    Result := 0;
end;

class operator TSdlAnimatedImage.Implicit(const AValue: Pointer): TSdlAnimatedImage;
begin
  Result.FHandle := AValue;
end;

constructor TSdlAnimatedImage.LoadGif(const ASrc: TSdlIOStream);
begin
  FHandle := IMG_LoadGIFAnimation_IO(SDL_IOStream(ASrc));
  SdlCheck(FHandle);
end;

class operator TSdlAnimatedImage.NotEqual(const ALeft: TSdlAnimatedImage;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

class operator TSdlAnimatedImage.NotEqual(const ALeft,
  ARight: TSdlAnimatedImage): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

{ TSdlImage }

class function TSdlImage.GetVersion: Integer;
begin
  Result := IMG_Version;
end;

class function TSdlImage.IsBmp(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isBMP(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsCur(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isCUR(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsGif(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isGIF(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsIco(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isICO(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsJpg(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isJPG(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsLbm(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isLBM(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsPcx(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isPCX(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsPng(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isPNG(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsPnm(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isPNM(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsQoi(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isQOI(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsSvg(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isSVG(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsXcf(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isXCF(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsXpm(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isXPM(SDL_IOStream(ASrc));
end;

class function TSdlImage.IsXV(const ASrc: TSdlIOStream): Boolean;
begin
  Result := IMG_isXV(SDL_IOStream(ASrc));
end;

class function TSdlImage.Load(const ASrc: TSdlIOStream; const ACloseIO: Boolean;
  const AType: String): TSdlSurface;
begin
  if (AType = '') then
    PSDL_Surface(Result) := IMG_Load_IO(SDL_IOStream(ASrc), ACloseIO)
  else
    PSDL_Surface(Result) := IMG_LoadTyped_IO(SDL_IOStream(ASrc), ACloseIO, __ToUtf8(AType));

  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadBmp(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadBMP_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadCur(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadCUR_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadGif(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadGIF_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadIco(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadICO_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadJpg(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadJPG_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadLbm(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadLBM_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadPcx(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadPCX_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadPng(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadPNG_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadPnm(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadPNM_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadQoi(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadQOI_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadSvg(const ASrc: TSdlIOStream; const AWidth,
  AHeight: Integer): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadSizedSVG_IO(SDL_IOStream(ASrc), AWidth, AHeight);
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadSvg(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadSVG_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadTexture(const ARenderer: TSdlRenderer;
  const ASrc: TSdlIOStream; const ACloseIO: Boolean;
  const AType: String): TSdlTexture;
begin
  if (AType = '') then
  begin
    PSDL_Texture(Result) := IMG_LoadTexture_IO(SDL_Renderer(ARenderer),
      SDL_IOStream(ASrc), ACloseIO);
  end
  else
  begin
    PSDL_Texture(Result) := IMG_LoadTextureTyped_IO(SDL_Renderer(ARenderer),
      SDL_IOStream(ASrc), ACloseIO, __ToUtf8(AType));
  end;
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadTga(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadTGA_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadXcf(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadXCF_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadXpm(const AXpm: TArray<AnsiString>): TSdlSurface;
var
  Data: TArray<PAnsiChar>;
begin
  SetLength(Data, Length(AXpm) + 1);
  for var I := 0 to Length(AXpm) - 1 do
    Data[I] := PAnsiChar(AXpm[I]);

  PSDL_Surface(Result) := IMG_ReadXPMFromArray(Pointer(Data));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadXpm32(const AXpm: TArray<AnsiString>): TSdlSurface;
var
  Data: TArray<PAnsiChar>;
begin
  SetLength(Data, Length(AXpm) + 1);
  for var I := 0 to Length(AXpm) - 1 do
    Data[I] := PAnsiChar(AXpm[I]);

  PSDL_Surface(Result) := IMG_ReadXPMFromArrayToRGB888(Pointer(Data));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadXpm(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadXPM_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadXV(const ASrc: TSdlIOStream): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_LoadXV_IO(SDL_IOStream(ASrc));
  SdlCheck(Pointer(Result));
end;

procedure TSdlImage.SaveJpg(const ASurface: TSdlSurface;
  const ADst: TSdlIOStream; const ACloseIO: Boolean; const AQuality: Integer);
begin
  SdlCheck(IMG_SaveJPG_IO(PSDL_Surface(ASurface), SDL_IOStream(ADst), ACloseIO, AQuality));
end;

procedure TSdlImage.SaveJpg(const ASurface: TSdlSurface; const AFile: String;
  const AQuality: Integer);
begin
  SdlCheck(IMG_SaveJPG(PSDL_Surface(ASurface), __ToUtf8(AFile), AQuality));
end;

procedure TSdlImage.SavePng(const ASurface: TSdlSurface;
  const ADst: TSdlIOStream; const ACloseIO: Boolean);
begin
  SdlCheck(IMG_SavePNG_IO(PSDL_Surface(ASurface), SDL_IOStream(ADst), ACloseIO));
end;

procedure TSdlImage.SavePng(const ASurface: TSdlSurface; const AFile: String);
begin
  SdlCheck(IMG_SavePNG(PSDL_Surface(ASurface), __ToUtf8(AFile)));
end;

class function TSdlImage.Load(const AFile: String): TSdlSurface;
begin
  PSDL_Surface(Result) := IMG_Load(__ToUtf8(AFile));
  SdlCheck(Pointer(Result));
end;

class function TSdlImage.LoadTexture(const ARenderer: TSdlRenderer;
  const AFile: String): TSdlTexture;
begin
  PSDL_Texture(Result) := IMG_LoadTexture(SDL_Renderer(ARenderer),
    __ToUtf8(AFile));
  SdlCheck(Pointer(Result));
end;

end.
