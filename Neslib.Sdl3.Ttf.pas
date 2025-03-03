unit Neslib.Sdl3.Ttf;

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
  deploy the appropriate SDL3_ttf.dll (either the 32-bit or 64-bit version)
  with your application. On other platforms, this library will be linked into
  your executable. }

interface

uses
  System.SysUtils,
  System.Generics.Collections,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.Ttf.Api,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Video,
  Neslib.Sdl3.Gpu,
  Neslib.Sdl3.IO;

const
  SDL_TTF_MAJOR_VERSION = Neslib.Sdl3.Ttf.Api.SDL_TTF_MAJOR_VERSION;
  SDL_TTF_MINOR_VERSION = Neslib.Sdl3.Ttf.Api.SDL_TTF_MINOR_VERSION;
  SDL_TTF_MICRO_VERSION = Neslib.Sdl3.Ttf.Api.SDL_TTF_MICRO_VERSION;

/// <summary>
///  Initialize SDL_ttf.
///
///  You must successfully call this routine before it is safe to call any
///  other function in this library.
///
///  It is safe to call this more than once, and each successful SdlTtfInit call
///  should be paired with a matching SdlTtfQuit call.
/// </summary>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlTtfQuit"/>
procedure SdlTtfInit; inline;

/// <summary>
///  Deinitialize SDL_ttf.
///
///  You must call this when done with the library, to free internal resources.
///  It is safe to call this when the library isn't initialized, as it will just
///  return immediately.
///
///  Once you have as many quit calls as you have had successful calls to
///  SdlTtfInit, the library will actually deinitialize.
///
///  Please note that this does not automatically close any fonts that are still
///  open at the time of deinitialization, and it is possibly not safe to close
///  them afterwards, as parts of the library will no longer be initialized to
///  deal with it. A well-written program should call TSdlTtfFont.Free on any
///  open fonts before calling this routine!
/// </summary>
/// <seealso cref="SdlTtfInit"/>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlTtfQuit; inline;

/// <summary>
///  Check if SDL_ttf is initialized.
///
///  This reports the number of times the library has been initialized by a call
///  to SdlTtfInit, without a paired deinitialization request from SdlTtfQuit.
///
///  In short: if it's greater than zero, the library is currently initialized
///  and ready to work. If zero, it is not initialized.
/// </summary>
/// <returns>The current number of initialization calls, that need to eventually
///  be paired with this many calls to SdlTtfQuit.</returns>
/// <seealso cref="SdlTtfInit"/>
/// <seealso cref="SdlTtfQuit"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlTtfWasInit: Integer; inline;

/// <summary>
///  The version of the linked SDL_ttf library.
/// </summary>
/// <remarks>
///  It is safe to use this function from any thread.
/// </remarks>
function SdlTtfGetVersion: Integer; inline;

/// <summary>
///  Query the version of the FreeType library in use.
///
///  SdlTtfInit should be called before calling this method.
/// </summary>
/// <param name="AMajor">To be filled in with the major version number.</param>
/// <param name="AMinor">To be filled in with the minor version number.</param>
/// <param name="APatch">To be filled in with the param version number.</param>
/// <seealso cref="SdlTtfInit"/>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlTtfGetFreeTypeVersion(out AMajor, AMinor, APatch: Integer); inline;

/// <summary>
///  Query the version of the HarfBuzz library in use.
///
///  If HarfBuzz is not available, the version reported is 0.0.0.
/// </summary>
/// <param name="AMajor">To be filled in with the major version number.</param>
/// <param name="AMinor">To be filled in with the minor version number.</param>
/// <param name="APatch">To be filled in with the param version number.</param>
/// <remarks>
///  It is safe to call this routine from any thread.
/// </remarks>
procedure SdlTtfGetHarfBuzzVersion(out AMajor, AMinor, APatch: Integer); inline;

/// <summary>
///  Convert from a 4 character string to a 32-bit tag.
/// </summary>
/// <param name="AString">The 4 character string to convert.</param>
/// <returns>The 32-bit representation of the string.</returns>
/// <seealso cref="SdlTtfTagToString"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlTtfStringToTag(const AString: String): Cardinal; inline;

/// <summary>
///  Convert from a 32-bit tag to a 4 character string.
/// </summary>
/// <param name="ATag">The 32-bit tag to convert.</param>
/// <returns>The 4 character representation of the tag.</param>
/// <seealso cref="SdlTtfStringToTag"/>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlTtfTagToString(const ATag: Cardinal): String; inline;

/// <summary>
///  Get the script used by a 32-bit codepoint.
/// </summary>
/// <param name="ACodepoint">The character code (codepoint) to check.</param>
/// <returns>An [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html).</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlTtfTagToString"/>
/// <remarks>
///  This function is thread-safe.
/// </remarks>
function SdlTtfGetGlyphScript(const ACodepoint: UCS4Char): Cardinal; inline;

type
  /// <summary>
  ///  These values determine how the end of opened sub-paths are rendered in
  ///  a stroke.
  /// </summary>
  TSdlTtfLineCap = (
    /// <summary>
    ///  The end of lines is rendered as a full stop on the last point itself.
    /// </summary>
    Butt   = 0,

    /// <summary>
    ///  The end of lines is rendered as a half-circle around the last point.
    /// </summary>
    Round  = 1,

    /// <summary>
    ///  The end of lines is rendered as a square around the last point.
    /// </summary>
    Square = 2);

type
  /// <summary>
  ///  These values determine how two joining lines are rendered in a stroker.
  /// </summary>
  TSdlTtfLineJoin = (
    /// <summary>
    ///  Used to render rounded line joins. Circular arcs are used to join two
    ///  lines smoothly.
    /// </summary>
    Round = 0,

    /// <summary>
    ///  Used to render beveled line joins.  The outer corner of the joined
    ///  lines is filled by enclosing the triangular region of the corner with a
    ///  straight line between the outer corners of each stroke.
    /// </summary>
    Bevel = 1,

    /// <summary>
    ///  Used to render mitered line joins, with variable bevels if the miter
    ///  limit is exceeded. The intersection of the strokes is clipped
    ///  perpendicularly to the bisector, at a distance corresponding to the
    ///  miter limit. This prevents long spikes being created.
    /// </summary>
    Miter = 2,

    /// <summary>
    ///  Used to render mitered line joins, with fixed bevels if the miter limit
    ///  is exceeded. The outer edges of the strokes for the two segments are
    ///  extended until they meet at an angle. A bevel join (see above) is used
    ///  if the segments meet at too sharp an angle and the outer edges meet
    ///  beyond a distance corresponding to the miter limit. This prevents long
    ///  spikes being created.
    /// </summary>
    Fixed = 3);

type
  /// <summary>
  ///  Font style flags for TSdlTtfFont
  ///
  ///  These are the flags which can be used to set the style of a font in
  ///  SDL_ttf.
  /// </summary>
  /// <seealso cref="TSdlTtfFont.Style"/>
  TSdlTtfFontStyle = (
    Bold,
    Italic,
    Underline,
    StrikeThrough);

  /// <summary>
  ///  A set of font style flags for TSdlTtfFont
  /// </summary>
  TSdlTtfFontStyles = set of TSdlTtfFontStyle;

type
  /// <summary>
  ///  The horizontal alignment used when rendering wrapped text.
  /// </summary>
  TSdlTtfHorizontalAlignment = (
    Invalid = TTF_HORIZONTAL_ALIGN_INVALID,
    Left    = TTF_HORIZONTAL_ALIGN_LEFT,
    Center  = TTF_HORIZONTAL_ALIGN_CENTER,
    Right   = TTF_HORIZONTAL_ALIGN_RIGHT);

type
  /// <summary>
  ///  Hinting options for TTF (TrueType Fonts)
  ///
  ///  This enum specifies the level of hinting to be applied to the font
  ///  rendering. The hinting level determines how much the font's outlines are
  ///  adjusted for better alignment on the pixel grid.
  /// </summary>
  /// <seealso cref="TSdlTtfFont.Hinting"/>
  TSdlTtfHinting = (
    /// <summary>
    ///  Normal hinting applies standard grid-fitting.
    /// </summary>
    Normal        = TTF_HINTING_NORMAL,

    /// <summary>
    ///  Light hinting applies subtle adjustments to improve rendering.
    /// </summary>
    Light         = TTF_HINTING_LIGHT,

    /// <summary>
    ///  Monochrome hinting adjusts the font for better rendering at lower resolutions.
    /// </summary>
    Mono          = TTF_HINTING_MONO,

    /// <summary>
    ///  No hinting, the font is rendered without any grid-fitting.
    /// </summary>
    None          = TTF_HINTING_NONE,

    /// <summary>
    ///  Light hinting with subpixel rendering for more precise font edges.
    /// </summary>
    LightSubpixel = TTF_HINTING_LIGHT_SUBPIXEL);

type
  /// <summary>
  ///  Direction values
  ///
  ///  The values here are chosen to match
  ///  [hb_direction_t](https://harfbuzz.github.io/harfbuzz-hb-common.html#hb-direction-t).
  /// </summary>
  /// <seealso cref="TSdlTtfFont.Direction"/>
  TSdlTtfDirection = (
    Invalid     = TTF_DIRECTION_INVALID,

    /// <summary>
    ///  Left to Right
    /// </summary>
    LeftToRight = TTF_DIRECTION_LTR,

    /// <summary>
    ///  Right to Left
    /// </summary>
    RightToLeft = TTF_DIRECTION_RTL,

    /// <summary>
    ///  Top to Bottom
    /// </summary>
    TopToBottom = TTF_DIRECTION_TTB,

    /// <summary>
    ///  Bottom to Top
    /// </summary>
    BottomToTop = TTF_DIRECTION_BTT);

type
  /// <summary>
  ///  The type of data in a glyph image
  /// </summary>
  TSdlTtfImageType = (
    Invalid = TTF_IMAGE_INVALID,

    /// <summary>
    ///  The color channels are white
    /// </summary>
    Alpha   = TTF_IMAGE_ALPHA,

    /// <summary>
    ///  The color channels have image data
    /// </summary>
    Color   = TTF_IMAGE_COLOR,

    /// <summary>
    ///  The alpha channel has signed distance field information
    /// </summary>
    Sdf     = TTF_IMAGE_SDF);

type
  /// <summary>
  ///  The winding order of the vertices returned by TSdlTtfText.GetGpuDrawData.
  /// </summary>
  TSdlTtfGpuTextEngineWinding = (
    Invalid          = TTF_GPU_TEXTENGINE_WINDING_INVALID,
    Clockwise        = TTF_GPU_TEXTENGINE_WINDING_CLOCKWISE,
    CounterClockwise = TTF_GPU_TEXTENGINE_WINDING_COUNTER_CLOCKWISE);

type
  /// <summary>
  ///  Flags for TSdlTtfSubString
  /// </summary>
  /// <seealso cref="TSdlTtfSubString"/>
  TSdlTtfSubStringFlag = (
    _Invalid  = 0,
    TextStart = 8,
    LineStart = 9,
    LineEnd   = 10,
    TextEnd   = 11);

type
  /// <summary>
  ///  S set of flags for TSdlTtfSubString
  /// </summary>
  /// <seealso cref="TSdlTtfSubString"/>
  TSdlTtfSubStringFlags = set of TSdlTtfSubStringFlag;

type
  /// <summary>
  ///  Modes for rendering text and character glyphs.
  /// </summary>
  /// <seealso cref="TSdlTtfFont.RenderText"/>
  /// <seealso cref="TSdlTtfFont.RenderGlyph"/>
  TSdlTtfRenderMode = (
    /// <summary>
    ///  Fast rendering to an 8-bit surface with a given foreground color.
    ///  This doesn't perform any anti-aliasing so the edges may look jagged on
    ///  low-DPI displays.
    /// </summary>
    Fast,

    /// <summary>
    ///  Anti-aliased rendering to an 8-bit palettized surface, which results
    ///  in smoother edges. Text is rendered using the given foreground and
    ///  background colors. The edges are rendered by blending various amounts
    ///  of the foreground and background color.
    /// </summary>
    AntiAliasedPalette,

    /// <summary>
    ///  Anti-aliased rendering to a 32-bit ARGB surface, which results in
    ///  smoother edges. Text is rendered using the given foreground color.
    ///  The edges are rendered using various degrees of transparency (eg.
    ///  alpha values).
    /// </summary>
    AntiAliasedAlpha,

    /// <summary>
    ///  Subpixel rendering to a 32-bit ARGB surface (aka ClearType on Windows),
    ///  which results in sharper and better looking text on LCD displays. The
    ///  resulting surface should not be scaled or rotated, since this results
    ///  in bad quality.
    /// </summary>
    Subpixel);

type
  /// <summary>
  ///  Standard SDL TTF properties
  /// </summary>
  TSdlTtfProperty = record
  public const
    (** Font creation **)

    // String
    FontCreateFilename          = TTF_PROP_FONT_CREATE_FILENAME_STRING;

    // Pointer/handle
    FontCreateIOStream          = TTF_PROP_FONT_CREATE_IOSTREAM_POINTER;

    // Number
    FontCreateIOStreamOffset    = TTF_PROP_FONT_CREATE_IOSTREAM_OFFSET_NUMBER;

    // Boolean
    FontCreateIOStreamAutoClose = TTF_PROP_FONT_CREATE_IOSTREAM_AUTOCLOSE_BOOLEAN;

    // Float
    FontCreateSize              = TTF_PROP_FONT_CREATE_SIZE_FLOAT;

    // Number
    FontCreateFace              = TTF_PROP_FONT_CREATE_FACE_NUMBER;

    // Number
    FontCreateHorizontalDpi     = TTF_PROP_FONT_CREATE_HORIZONTAL_DPI_NUMBER;

    // Number
    FontCreateVerticalDpi       = TTF_PROP_FONT_CREATE_VERTICAL_DPI_NUMBER;

    // Pointer/handle
    FontCreateExistingFont      = TTF_PROP_FONT_CREATE_EXISTING_FONT;
  public const
    (** Font outlines **)

    // Number
    FontOutlineLineCap    = TTF_PROP_FONT_OUTLINE_LINE_CAP_NUMBER;

    // Number
    FontOutlineJoin       = TTF_PROP_FONT_OUTLINE_LINE_JOIN_NUMBER;

    // Number
    FontOutlineMiterLimit = TTF_PROP_FONT_OUTLINE_MITER_LIMIT_NUMBER;

  public const
    (** Text engine creation **)

    // Pointer/handle
    RendererTextEngineRenderer         = TTF_PROP_RENDERER_TEXT_ENGINE_RENDERER;

    // Number
    RendererTextEngineAtlasTextureSize = TTF_PROP_RENDERER_TEXT_ENGINE_ATLAS_TEXTURE_SIZE;

    // Pointer/handle
    GpuTextEngineDevice                = TTF_PROP_GPU_TEXT_ENGINE_DEVICE;

    // Number
    GpuTextEngineAtlasTextureSize      = TTF_PROP_GPU_TEXT_ENGINE_ATLAS_TEXTURE_SIZE;
  end;

type
  /// <summary>
  ///  A TTF Font.
  /// </summary>
  TSdlTtfFont = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: TTF_Font;
    function GetProperties: TSdlProperties; inline;
    function GetGeneration: Cardinal; inline;
    function GetFamilyName: String; inline;
    function GetStyleName: String; inline;
    function GetSize: Single; inline;
    procedure SetSize(const AValue: Single); inline;
    function GetStyle: TSdlTtfFontStyles; inline;
    procedure SetStyle(const AValue: TSdlTtfFontStyles); inline;
    function GetOutline: Integer; inline;
    procedure SetOutline(const AValue: Integer); inline;
    function GetHinting: TSdlTtfHinting; inline;
    procedure SetHinting(const AValue: TSdlTtfHinting); inline;
    function GetWrapAlignment: TSdlTtfHorizontalAlignment; inline;
    procedure SetWrapAlignment(const AValue: TSdlTtfHorizontalAlignment); inline;
    function GetDirection: TSdlTtfDirection; inline;
    procedure SetDirection(const AValue: TSdlTtfDirection); inline;
    function GetLineSkip: Integer; inline;
    procedure SetLineSkip(const AValue: Integer); inline;
    function GetScript: Cardinal; inline;
    procedure SetScript(const AValue: Cardinal); inline;
    procedure SetLanguage(const AValue: String); inline;
    function GetIsKerningEnabled: Boolean; inline;
    procedure SetIsKerningEnabled(const AValue: Boolean); inline;
    function GetIsSdfEnabled: Boolean; inline;
    procedure SetIsSdfEnabled(const AValue: Boolean); inline;
    function GetHeight: Integer; inline;
    function GetAscent: Integer; inline;
    function GetDescent: Integer; inline;
    function GetIsFixedWidth: Boolean; inline;
    function GetIsScalable: Boolean; inline;
    function GetNumFaces: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTtfFont; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTtfFont.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlTtfFont): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTtfFont; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTtfFont.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlTtfFont): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTtfFont; inline; static;
  public
    /// <summary>
    ///  Create a font from a file, using a specified point size.
    ///
    ///  Some .fon fonts will have several sizes embedded in the file, so the point
    ///  size becomes the index of choosing which size. If the value is too high,
    ///  the last indexed size will be the default.
    ///
    ///  When done with the font, use Free to dispose of it.
    /// </summary>
    /// <param name="AFile">Path to font file.</param>
    /// <param name="APtSize">Point size to use for the newly-opened font.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AFile: String; const APtSize: Single); overload;

    /// <summary>
    ///  Create a font from a TSdlIOStream, using a specified point size.
    ///
    ///  Some .fon fonts will have several sizes embedded in the file, so the point
    ///  size becomes the index of choosing which size. If the value is too high,
    ///  the last indexed size will be the default.
    ///
    ///  If `ACloseIO` is True, `ASrc` will be automatically closed once the font is
    ///  freed. Otherwise you should close `ASrc` yourself after freeing the font.
    ///  The stream *must* stay alive while the font is in use.
    ///
    ///  When done with the font, use Free to dispose of it.
    /// </summary>
    /// <param name="ASrc">A TSdlIOStream to provide a font file's data.</param>
    /// <param name="ACloseIO">True to close `ASrc` when the font is freed,
    ///  False to leave it open.</param>
    /// <param name="APtSize">Point size to use for the newly-opened font.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ASrc: TSdlIOStream; const ACloseIO: Boolean;
      const APtSize: Single); overload;

    /// <summary>
    ///  Create a font with the specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlTtfProperty.FontCreateFilename`: the font file to open, if a
    ///    TSdlIOStream isn't being used. This is required if
    ///    `TSdlTtfProperty.FontCreateIOStream` and
    ///    `TSdlTtfProperty.FontCreateExistingFont` aren't set.
    ///  - `TSdlTtfProperty.FontCreateIOStream`: a TSdlIOStream containing the
    ///    font to be opened. This should not be closed until the font is closed.
    ///    This is required if `TSdlTtfProperty.FontCreateFilename` and
    ///    `TSdlTtfProperty.FontCreateExistingFont` aren't set.
    ///  - `TSdlTtfProperty.FontCreateIOStreamOffset`: the offset in the iostream
    ///    for the beginning of the font, defaults to 0.
    ///  - `TSdlTtfProperty.FontCreateIOStreamAutoClose`: True if closing the
    ///    font should also close the associated TSdlIOStream.
    ///  - `TSdlTtfProperty.FontCreateSize`: the point size of the font. Some .fon
    ///    fonts will have several sizes embedded in the file, so the point size
    ///    becomes the index of choosing which size. If the value is too high, the
    ///    last indexed size will be the default.
    ///  - `TSdlTtfProperty.FontCreateFace`: the face index of the font, if the
    ///    font contains multiple font faces.
    ///  - `TSdlTtfProperty.FontCreateHorizontalDpi`: the horizontal DPI to use
    ///    for font rendering, defaults to `TSdlTtfProperty.FontCreateVerticalDpi`
    ///    if set, or 72 otherwise.
    ///  - `TSdlTtfProperty.FontCreateVerticalDpi`: the vertical DPI to use for
    ///    font rendering, defaults to `TSdlTtfProperty.FontCreateHorizontalDpi`
    ///    if set, or 72 otherwise.
    ///  - `TSdlTtfProperty.FontCreateExistingFont`: an optional TSdlTtfFont that,
    ///    if set, will be used as the font data source and the initial size and
    ///    style of the new font.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AProps: TSdlProperties); overload;

    /// <summary>
    ///  Disposes of the font.
    ///
    ///  Call this when done with a font. This method will free any resources
    ///  associated with it. It is safe to call this function on nil.
    ///
    ///  The font is not valid after being passed to this method.
    /// </summary>
    /// <remarks>
    ///  This method should not be called while any other thread is using the font.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Create a copy of this font.
    ///
    ///  The copy will be distinct from the original, but will share the font file
    ///  and have the same size and style as the original.
    ///
    ///  When done with the returned font, use Free to dispose of it.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This method should be called on the thread that created the original font.
    /// </remarks>
    function Clone: TSdlTtfFont; inline;

    /// <summary>
    ///  Add a fallback font.
    ///
    ///  Add a font that will be used for glyphs that are not in this font.
    ///  The fallback font should have the same size and style as this font.
    ///
    ///  If there are multiple fallback fonts, they are used in the order added.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <param name="AFallback">The font to add as a fallback.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ClearFallbacks"/>
    /// <seealso cref="RemoveFallback"/>
    /// <remarks>
    ///  This method should be called on the thread that created both fonts.
    /// </remarks>
    procedure AddFallback(const AFallback: TSdlTtfFont); inline;

    /// <summary>
    ///  Remove a fallback font.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <param name="AFallback">The font to remove as a fallback.</param>
    /// <seealso cref="AddFallback"/>
    /// <seealso cref="ClearFallbacks"/>
    /// <remarks>
    ///  This method should be called on the thread that created both fonts.
    /// </remarks>
    procedure RemoveFallback(const AFallback: TSdlTtfFont); inline;

    /// <summary>
    ///  Remove all fallback fonts.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <seealso cref="AddFallback"/>
    /// <seealso cref="RemoveFallback"/>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    procedure ClearFallbacks;

    /// <summary>
    ///  Set font size dynamically with target resolutions, in dots per inch.
    ///
    ///  This updates any TSdlTtdText objects using this font, and clears
    ///  already-generated glyphs, if any, from the cache.
    /// </summary>
    /// <param name="APtSize">the new point size.</param>
    /// <param name="AHDpi">The target horizontal DPI.</param>
    /// <param name="AVDpi">The target vertical DPI.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Size"/>
    /// <seealso cref="GetDPI"/>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    procedure SetSizeDpi(const APtSize: Single; const AHDpi, AVDpi: Integer); inline;

    /// <summary>
    ///  Get font target resolutions, in dots per inch.
    /// </summary>
    /// <param name="AHDpi">Set to the target horizontal DPI.</param>
    /// <param name="AVDpi">Set to the target vertical DPI.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Size"/>
    /// <seealso cref=SetSizeDpi"/>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    procedure GetDpi(out AHDpi, AVDpi: Integer); inline;

    /// <summary>
    ///  Check whether a glyph is provided by the font for a Unicode codepoint.
    /// </summary>
    /// <param name="ACodepoint">The codepoint to check.</param>
    /// <returns>True if the font provides a glyph for this character, False if not.</returns>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function HasGlyph(const ACodepoint: UCS4Char): Boolean; inline;

    /// <summary>
    ///  Get the pixel image for a Unicode codepoint.
    /// </summary>
    /// <param name="ACodepoint">The codepoint to check.</param>
    /// <returns>A TSdlSurface containing the glyph.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetGlyphImage(const ACodepoint: UCS4Char): TSdlSurface; overload; inline;

    /// <summary>
    ///  Get the pixel image for a Unicode codepoint.
    /// </summary>
    /// <param name="ACodepoint">The codepoint to check.</param>
    /// <param name="AImageType">Is set to the glyph image type.</param>
    /// <returns>A TSdlSurface containing the glyph.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetGlyphImage(const ACodepoint: UCS4Char;
      out AImageType: TSdlTtfImageType): TSdlSurface; overload; inline;

    /// <summary>
    ///  Get the pixel image for a character index.
    ///
    ///  This is useful for text engine implementations, which can call this with
    ///  the `GlyphIndex` in a TSdlTtfCopyOperation.
    /// </summary>
    /// <param name="AGlyphIndex">The index of the glyph to return.</param>
    /// <returns>A TSdlSurface containing the glyph.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetGlyphImageForIndex(const AGlyphIndex: Integer): TSdlSurface; overload; inline;

    /// <summary>
    ///  Get the pixel image for a character index.
    ///
    ///  This is useful for text engine implementations, which can call this with
    ///  the `GlyphIndex` in a TSdlTtfCopyOperation.
    /// </summary>
    /// <param name="AGlyphIndex">The index of the glyph to return.</param>
    /// <param name="AImageType">Is set to the glyph image type.</param>
    /// <returns>A TSdlSurface containing the glyph.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetGlyphImageForIndex(const AGlyphIndex: Integer;
      out AImageType: TSdlTtfImageType): TSdlSurface; overload; inline;

    /// <summary>
    ///  Query the metrics (dimensions) of a font's glyph for a Unicode codepoint.
    ///
    ///  To understand what these metrics mean, here is a useful link:
    ///
    ///  https://freetype.sourceforge.net/freetype2/docs/tutorial/step2.html
    /// </summary>
    /// <param name="ACodepoint">The codepoint to check.</param>
    /// <param name="AMinX">Is set to the minimum x coordinate of the glyph from
    ///  the left edge of its bounding box. This value may be negative.</param>
    /// <param name="AMaxX">Is set to the maximum x coordinate of the glyph from
    ///  the left edge of its bounding box.</param>
    /// <param name="AMinY">Is set to the minimum y coordinate of the glyph from
    //   the bottom edge of its bounding box. This value may be negative.</param>
    /// <param name="AMaxY">Is set to the maximum y coordinate of the glyph from
    ///  the bottom edge of its bounding box.</param>
    /// <param name="AAdvance">Is set to the distance to the next glyph from the
    ///  left edge of this glyph's bounding box.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    procedure GetGlyphMetrics(const ACodepoint: UCS4Char; out AMinX, AMaxX,
      AMinY, AMaxY, AAdvance: Integer); inline;

    /// <summary>
    ///  Query the kerning size between the glyphs of two Unicode codepoints.
    /// </summary>
    /// <param name="APrevious">The previous codepoint.</param>
    /// <param name="ACurrent">The current codepoint.</param>
    /// <returns>The kerning size between the two glyphs, in pixels.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetGlyphKerning(const APrevious, ACurrent: UCS4Char): Integer; inline;

    /// <summary>
    ///  Calculate the dimensions of a rendered string of Unicode text.
    ///
    ///  This will report the width and height, in pixels, of the space that the
    ///  specified string will take to fully render.
    /// </summary>
    /// <param name="AText">Text to calculate</param>
    /// <returns>The size in pixels.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetTextSize(const AText: String): TSdlSize; overload; inline;

    /// <summary>
    ///  Calculate the dimensions of a rendered string of Unicode text.
    ///
    ///  This will report the width and height, in pixels, of the space that the
    ///  specified string will take to fully render.
    ///
    ///  Text is wrapped to multiple lines on line endings and on word boundaries
    ///  if it extends beyond `AWrapWidth` in pixels.
    ///
    ///  If AWrapWidth is 0, this function will only wrap on newline characters.
    /// </summary>
    /// <param name="AText">Text to calculate.</param>
    /// <param name="AWrapWidth">The maximum width or 0 to wrap on newline characters.</param>
    /// <returns>The size in pixels.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function GetTextSize(const AText: String;
      const AWrapWidth: Integer): TSdlSize; overload; inline;

    /// <summary>
    ///  Calculate how much of a Unicode string will fit in a given width.
    ///
    ///  This reports the number of characters that can be rendered before reaching
    ///  `AMaxWidth`.
    ///
    ///  This does not need to render the string to do this calculation.
    /// </summary>
    /// <param name="AText">Text to calculate.</param>
    /// <param name="AMaxWidth">(Optional) maximum width, in pixels, available
    ///  for the string, or 0 (default) for unbounded width.</param>
    /// <returns>The length of the string that will fit.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function MeasureText(const AText: String; const AMaxWidth: Integer = 0): Integer; overload;

    /// <summary>
    ///  Calculate how much of a Unicode string will fit in a given width.
    ///
    ///  This reports the number of characters that can be rendered before reaching
    ///  `AMaxWidth`.
    ///
    ///  This does not need to render the string to do this calculation.
    /// </summary>
    /// <param name="AText">Text to calculate.</param>
    /// <param name="AMaxWidth">Maximum width, in pixels, available for the
    ///  string, or 0 for unbounded width.</param>
    /// <param name="AMeasuredWidth">Is set to the width, in pixels, of the
    ///  string that will fit.</param>
    /// <returns>The length of the string that will fit.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function MeasureText(const AText: String; const AMaxWidth: Integer;
      out AMeasuredWidth: Integer): Integer; overload;

    /// <summary>
    ///  Render Unicode text to a new surface, optionally wrapping the text.
    ///
    ///  This method will allocate a new 8-bit or 32-bit surface, depending on
    ///  AMode:
    ///
    ///   * TSdlTtfRenderMode.Fast: creates an 8-bit palettized surface where
    ///     palette index 0 is transparent, and palette index 1 is set to the
    ///     given AForegroundColor. ABackgroundColor is not used.
    ///   * TSdlTtfRenderMode.AntiAliasedPalette: creates an 8-bit palettized
    ///     surface where palette index 0 is set to the given ABackgroundColor
    ///     and the remainder of the palette contains a color gradient/ramp that
    ///     goes from ABackgroundColor to AForegroundColor.
    ///   * TSdlTtfRenderMode.AntiAliasedAlpha: creates a 32-bit ARGB surface
    ///     where the Alpha values are used for anti-aliasing. ABackgroundColor
    ///     is not used.
    ///   * TSdlTtfRenderMode.Subpixel: creates a 32-bit ARGB surface that used
    ///     both alpha-blending and subpixel blending with ABackgroundColor to
    ///     create sharp looking text for LCD displays.
    ///
    ///  You can optionally wrap the text based on the `AWrapLength` parameter:
    ///
    ///   * If `AWrapLength` < 0 (default), then text will not be wrapped (not
    ///     even on newline characters). You'll get a surface with a single line
    ///     of text, as long as the string requires.
    ///   * If `AWrapLength` = 0, then text will only be wrapped on newline
    ///     characters.
    ///   * If `AWrapLength` > 0, then text will be wrapped on newline characters
    ///     and on word boundaries if it extends beyond `AWrapLength` in pixels.
    /// </summary>
    /// <param name="AText">Text to render.</param>
    /// <param name="AMode">The render mode.</param>
    /// <param name="AForegroundColor">The foreground color for the text.</param>
    /// <param name="ABackgroundColor">(Optional) background color for the text.
    ///  Is only used (and must be specified) for
    ///  TSdlTtfRenderMode.AntiAliasedPalette and TSdlTtfRenderMode.Subpixel.</param>
    /// <param name="AWrapLength">(Optional) maximum width of the text surface.</param>
    /// <returns>A new surface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function RenderText(const AText: String; const AMode: TSdlTtfRenderMode;
      const AForegroundColor: TSdlColor;
      const AWrapLength: Integer = -1): TSdlSurface; overload; inline;
    function RenderText(const AText: String; const AMode: TSdlTtfRenderMode;
      const AForegroundColor, ABackgroundColor: TSdlColor;
      const AWrapLength: Integer = -1): TSdlSurface; overload;

    /// <summary>
    ///  Render a single 32-bit codepoint a new surface.
    ///
    ///  This method will allocate a new 8-bit or 32-bit surface, depending on
    ///  AMode:
    ///
    ///   * TSdlTtfRenderMode.Fast: creates an 8-bit palettized surface where
    ///     palette index 0 is transparent, and palette index 1 is set to the
    ///     given AForegroundColor. ABackgroundColor is not used.
    ///   * TSdlTtfRenderMode.AntiAliasedPalette: creates an 8-bit palettized
    ///     surface where palette index 0 is set to the given ABackgroundColor
    ///     and the remainder of the palette contains a color gradient/ramp that
    ///     goes from ABackgroundColor to AForegroundColor.
    ///   * TSdlTtfRenderMode.AntiAliasedAlpha: creates a 32-bit ARGB surface
    ///     where the Alpha values are used for anti-aliasing. ABackgroundColor
    ///     is not used.
    ///   * TSdlTtfRenderMode.Subpixel: creates a 32-bit ARGB surface that used
    ///     both alpha-blending and subpixel blending with ABackgroundColor to
    ///     create sharp looking text for LCD displays.
    ///
    ///  The glyph is rendered without any padding or centering in the X direction,
    ///  and aligned normally in the Y direction.
    /// </summary>
    /// <param name="ACodepoint">The Unicode codepoint of the character to render.</param>
    /// <param name="AMode">The render mode.</param>
    /// <param name="AForegroundColor">The foreground color for the text.</param>
    /// <param name="ABackgroundColor">(Optional) background color for the text.
    ///  Is only used (and must be specified) for
    ///  TSdlTtfRenderMode.AntiAliasedPalette and TSdlTtfRenderMode.Subpixel.</param>
    /// <returns>A new surface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the font.
    /// </remarks>
    function RenderGlyph(const ACodepoint: UCS4Char; const AMode: TSdlTtfRenderMode;
      const AForegroundColor: TSdlColor): TSdlSurface; overload; inline;
    function RenderGlyph(const ACodepoint: UCS4Char; const AMode: TSdlTtfRenderMode;
      const AForegroundColor, ABackgroundColor: TSdlColor): TSdlSurface; overload;

    /// <summary>
    ///  The font generation.
    ///
    ///  The generation is incremented each time font properties change that require
    ///  rebuilding glyphs, such as style, size, etc.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Generation: Cardinal read GetGeneration;

    /// <summary>
    ///  The font's family name.
    ///
    ///  This string is dictated by the contents of the font file.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property FamilyName: String read GetFamilyName;

    /// <summary>
    ///  The font's style name.
    ///
    ///  This string is dictated by the contents of the font file.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property StyleName: String read GetStyleName;

    /// <summary>
    ///  The font's size in points.
    ///
    ///  Changing this updates any TSdlTtfText objects using this font, and clears
    ///  already-generated glyphs, if any, from the cache.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetDpi"/>
    /// <seealso cref="SetSizeDpi"/>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Size: Single read GetSize write SetSize;

    /// <summary>
    ///  The font's current style.
    ///
    ///  Setting this updates any TSdlTtfText objects using this font, and clears
    ///  already-generated glyphs, if any, from the cache.
    /// </summary>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Style: TSdlTtfFontStyles read GetStyle write SetStyle;

    /// <summary>
    ///  The font's current outline.
    ///
    ///  This uses the font properties `TSdlTtfProperty.FontOutlineLineCap`,
    ///  `TSdlTtfProperty.FontOutlineLineJoin`, and
    ///  `TSdlTtfProperty.FontOutlineMiterLimit` when setting the font outline.
    ///
    ///  This updates any TSdlTtfText objects using this font, and clears
    ///  already-generated glyphs, if any, from the cache.
    ///
    ///  Set to 0 to use the default value.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Outline: Integer read GetOutline write SetOutline;

    /// <summary>
    ///  The font's current hinter setting.
    ///
    ///  This updates any TSdlTtfText objects using this font, and clears
    ///  already-generated glyphs, if any, from the cache.
    /// </summary>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Hinting: TSdlTtfHinting read GetHinting write SetHinting;

    /// <summary>
    ///  The font's current wrap alignment option.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property WrapAlignment: TSdlTtfHorizontalAlignment read GetWrapAlignment write SetWrapAlignment;

    /// <summary>
    ///  The direction to be used for text shaping by the font.
    ///
    ///  This function only supports left-to-right text shaping if SDL_ttf was not
    ///  built with HarfBuzz support.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    ///
    ///  Returns TSdlTtfDirection.Invalid if it hasn't been set.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Direction: TSdlTtfDirection read GetDirection write SetDirection;

    /// <summary>
    ///  The spacing between lines of text for a font.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property LineSkip: Integer read GetLineSkip write SetLineSkip;

    /// <summary>
    ///  The script to be used for text shaping by the font.
    ///  This is an [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html).
    ///
    ///  This method fails if SDL_ttf isn't built with HarfBuzz support.
    ///  Returns 0 if a script hasn't been set.
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SdlTtfStringToTag"/>
    /// <seealso cref="SdlTtfTagToString"/>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Script: Cardinal read GetScript write SetScript;

    /// <summary>
    ///  The language to be used for text shaping by the font, as a BCP47
    ///  language code. Set to an empty string to reset the value.
    ///
    ///  This method fails if SDL_ttf isn't built with HarfBuzz support.
    ///
    ///  This updates any TTF_Text objects using this font.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property Language: String write SetLanguage;

    /// <summary>
    ///  Whether kerning is enabled for the font.
    ///
    ///  Newly-opened fonts default to allowing kerning. This is generally a good
    ///  policy unless you have a strong reason to disable it, as it tends to
    ///  produce better rendering (with kerning disabled, some fonts might render
    ///  the word `kerning` as something that looks like `keming` for example).
    ///
    ///  This updates any TSdlTtfText objects using this font.
    /// </summary>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property IsKerningEnabled: Boolean read GetIsKerningEnabled write SetIsKerningEnabled;

    /// <summary>
    ///  Whether Signed Distance Field rendering for the font is enabled.
    ///
    ///  SDF is a technique that helps fonts look sharp even when scaling and
    ///  rotating, and requires special shader support for display.
    ///
    ///  This works with Blended APIs, and generates the raw signed distance values
    ///  in the alpha channel of the resulting texture.
    ///
    ///  This updates any TSdlTtfText objects using this font, and clears
    ///  already-generated glyphs, if any, from the cache.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the font.
    /// </remarks>
    property IsSdfEnabled: Boolean read GetIsSdfEnabled write SetIsSdfEnabled;

    /// <summary>
    ///  The total height of a font.
    ///
    ///  This is usually equal to point size.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Height: Integer read GetHeight;

    /// <summary>
    ///  The offset from the baseline to the top of a font.
    ///
    ///  This is a positive value, relative to the baseline.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Ascent: Integer read GetAscent;

    /// <summary>
    ///  The offset from the baseline to the bottom of a font.
    ///
    ///  This is a negative value, relative to the baseline.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Descent: Integer read GetDescent;

    /// <summary>
    ///  Whether the font is fixed-width.
    ///
    ///  A "fixed-width" font means all glyphs are the same width across; a
    ///  lowercase 'i' will be the same size across as a capital 'W', for example.
    ///  This is common for terminals and text editors, and other apps that treat
    ///  text as a grid. Most other things (WYSIWYG word processors, web pages, etc)
    ///  are more likely to not be fixed-width in most cases.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property IsFixedWidth: Boolean read GetIsFixedWidth;

    /// <summary>
    ///  Query whether a font is scalable or not.
    ///
    ///  Scalability lets us distinguish between outline and bitmap fonts.
    /// </summary>
    /// <seealso cref="IsSdfEnabled"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property IsScalable: Boolean read GetIsScalable;

    /// <summary>
    ///  The number of faces of the font.
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property NumFaces: Integer read GetNumFaces;

    /// <summary>
    ///  The properties associated with the font.
    ///
    ///  The following read-write properties are provided by SDL:
    ///
    ///  - `TSdlTtfProperty.FontOutlineLineCap`: The TSdlTtfLineCap value
    ///    used when setting the font outline, defaults to
    ///    `TSdlTtfLineCap.Round`.
    ///  - `TSdlTtfProperty.FontOutlineLineJoin`: The TSdlTtfLineJoin value
    ///    used when setting the font outline, defaults to
    ///    `TSdlTtfLineJoin.Round`.
    ///  - `TSdlTtfProperty.FontMiterLimit`: The miter limit used when setting
    ///    the font outline, defaults to 0. This is a 16.16 integer fixed point
    ///    value, meaning should should divide by 65,536 to get the floating-
    ///    point equivalent.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;

type
  /// <summary>
  ///  Draw sequence returned by TSdlTtfText.GetGpuDrawData
  /// </summary>
  /// <seealso cref="TSdlTtfText.GetGpuDrawData"/>
  TSdlTtfGpuAtlasDrawSequence = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PTTF_GPUAtlasDrawSequence;
    function GetAtlasTexture: TSdlGpuTexture; inline;
    function GetNumVertices: Integer; inline;
    function GetXY: PSdlPointF; inline;
    function GetUV: PSdlPointF; inline;
    function GetNumIndices: Integer; inline;
    function GetIndices: PInteger; inline;
    function GetImageType: TSdlTtfImageType; inline;
    function GetNext: TSdlTtfGpuAtlasDrawSequence; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTtfGpuAtlasDrawSequence; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTtfGpuAtlasDrawSequence.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlTtfGpuAtlasDrawSequence): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTtfGpuAtlasDrawSequence; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTtfGpuAtlasDrawSequence.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlTtfGpuAtlasDrawSequence): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTtfGpuAtlasDrawSequence; inline; static;
  public
    /// <summary>
    ///  Texture atlas that stores the glyphs
    /// </summary>
    property AtlasTexture: TSdlGpuTexture read GetAtlasTexture;

    /// <summary>
    ///  Number of vertices
    /// </summary>
    property NumVertices: Integer read GetNumVertices;

    /// <summary>
    ///  An array of vertex positions
    /// </summary>
    property XY: PSdlPointF read GetXY;

    /// <summary>
    ///  An array of normalized texture coordinates for each vertex
    /// </summary>
    property UV: PSdlPointF read GetUV;

    /// <summary>
    ///  Number of indices
    /// </summary>
    property NumIndices: Integer read GetNumIndices;

    /// <summary>
    ///  An array of indices into the 'vertices' arrays
    /// </summary>
    property Indices: PInteger read GetIndices;

    /// <summary>
    ///  The image type of this draw sequence
    /// </summary>
    property ImageType: TSdlTtfImageType read GetImageType;

    /// <summary>
    ///  The next sequence (will be nil in case of the last sequence)
    /// </summary>
    property Next: TSdlTtfGpuAtlasDrawSequence read GetNext;
  end;

type
  /// <summary>
  ///  The representation of a substring within text.
  /// </summary>
  /// <seealso cref="TSdlTtfText.NextSubString"/>
  /// <seealso cref="TSdlTtfText.PreviousSubString"/>
  /// <seealso cref="TSdlTtfText.SubString"/>
  /// <seealso cref="TSdlTtfText.SubStringForLine"/>
  /// <seealso cref="TSdlTtfText.SubStringForPoint"/>
  /// <seealso cref="TSdlTtfText.SubStringsForRange"/>
  TSdlTtfSubString = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: TTF_SubString;
    function GetFlags: TSdlTtfSubStringFlags; inline;
    function GetRect: TSdlRect; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The flags for this substring
    /// </summary>
    property Flags: TSdlTtfSubStringFlags read GetFlags;

    /// <summary>
    ///  The byte offset from the beginning of the text
    /// </summary>
    property Offset: Integer read FHandle.Offset;

    /// <summary>
    ///  The byte length starting at the offset
    /// </summary>
    property Length: Integer read FHandle.length;

    /// <summary>
    ///  The index of the line that contains this substring
    /// </summary>
    property LineIndex: Integer read FHandle.line_index;

    /// <summary>
    ///  The internal cluster index, used for quickly iterating
    /// </summary>
    property CluserIndex: Integer read FHandle.cluster_index;

    /// <summary>
    ///  The rectangle, relative to the top left of the text, containing the substring
    /// </summary>
    property Rect: TSdlRect read GetRect;
  end;

type
  TSdlTtfTextEngine = class;

  /// <summary>
  ///  A text string to render with a TTF text engine.
  ///  Note that this object works with 8-bit UTF-8 strings instead of
  ///  16-bit Unicode strings.
  /// </summary>
  TSdlTtfText = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PTTF_Text;
    function GetText: UTF8String; inline;
    procedure SetText(const AValue: UTF8String); inline;
    function GetNumLines: Integer; inline;
    function GetEngine: TSdlTtfTextEngine; inline;
    procedure SetEngine(const AValue: TSdlTtfTextEngine); inline;
    function GetFont: TSdlTtfFont; inline;
    procedure SetFont(const AValue: TSdlTtfFont); inline;
    function GetDirection: TSdlTtfDirection; inline;
    procedure SetDirection(const AValue: TSdlTtfDirection); inline;
    function GetScript: Cardinal; inline;
    procedure SetScript(const AValue: Cardinal); inline;
    function GetColor: TSdlColor; inline;
    procedure SetColor(const AValue: TSdlColor); overload; inline;
    function GetColorFloat: TSdlColorF; inline;
    procedure SetColorFloat(const AValue: TSdlColorF); overload; inline;
    function GetPosition: TSdlPoint; inline;
    procedure SetPosition(const AValue: TSdlPoint); overload; inline;
    function GetWrapWidth: Integer; inline;
    procedure SetWrapWidth(const AValue: Integer); inline;
    function GetIsWrapWhitespaceVisible: Boolean; inline;
    procedure SetIsWrapWhitespaceVisible(const AValue: Boolean); inline;
    function GetSize: TSdlSize; inline;
    function GetProperties: TSdlProperties; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTtfText; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTtfText.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlTtfText): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTtfText; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTtfText.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlTtfText): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTtfText; inline; static;
  public
    /// <summary>
    ///  Destroy this text object.
    /// </summary>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Get the geometry data needed for drawing the text.
    ///
    ///  This text must have been created using a TSdlTtfGpuTextEngine.
    ///
    ///  The positive X-axis is taken towards the right and the positive Y-axis is
    ///  taken upwards for both the vertex and the texture coordinates, i.e, it
    ///  follows the same convention used by the SDL_GPU API. If you want to use a
    ///  different coordinate system you will need to transform the vertices
    ///  yourself.
    ///
    ///  If the text looks blocky use linear filtering.
    /// </summary>
    /// <returns>A nil terminated linked list of TSdlTtfGpuAtlasDrawSequence
    ///  or nil if the passed text is empty.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function GetGpuDrawData: TSdlTtfGpuAtlasDrawSequence; inline;

    /// <summary>
    ///  Set the color of the text object.
    ///
    ///  The default text color is white (255, 255, 255, 255).
    /// </summary>
    /// <param name="AR">The red color value in the range of 0-255.</param>
    /// <param name="AG">The green color value in the range of 0-255.</param>
    /// <param name="AB">The blue color value in the range of 0-255.</param>
    /// <param name="AA">(Optional) alpha value in the range of 0-255.
    ///  Defaults to 255.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Color"/>
    /// <seealso cref="SetColorFloat"/>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure SetColor(const AR, AG, AB: Byte; const AA: Byte = 255); overload; inline;

    /// <summary>
    ///  Set the color of the text object.
    ///
    ///  The default text color is white (1.0, 1.0, 1.0, 1.0).
    /// </summary>
    /// <param name="AR">The red color value, normally in the range of 0-1.</param>
    /// <param name="AG">The green color value, normally in the range of 0-1.</param>
    /// <param name="AB">The blue color value, normally in the range of 0-1.</param>
    /// <param name="AA">(Optional) alpha value in the range of 0-1. Defaults to 1.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ColorFloat"/>
    /// <seealso cref="SetColor"/>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure SetColorFloat(const AR, AG, AB: Single; const AA: Single = 1); overload; inline;

    /// <summary>
    ///  Set the position of the text object.
    ///
    ///  This can be used to position multiple text objects within a single wrapping
    ///  text area.
    ///
    ///  This method may cause the internal text representation to be rebuilt.
    /// </summary>
    /// <param name="AX">The x offset of the upper left corner of this text in pixels.</param>
    /// <param name="AY">The y offset of the upper left corner of this text in pixels.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Position"/>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure SetPosition(const AX, AY: Integer); overload; inline;

    /// <summary>
    ///  Insert text into the text object.
    ///
    ///  This method may cause the internal text representation to be rebuilt.
    /// </summary>
    /// <param name="AOffset">Offset, in bytes (8-bit UTF-8 characters), from
    ///  the beginning of the string if >= 0, the offset from the end of the
    ///  string if < 0.</param>
    /// <param name="AString">The text to insert.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Append"/>
    /// <seealso cref="Delete"/>
    /// <seealso cref="Text"/>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure Insert(const AOffset: Integer; const AString: UTF8String); inline;

    /// <summary>
    ///  Append text to the text object.
    ///
    ///  This method may cause the internal text representation to be rebuilt.
    /// </summary>
    /// <param name="AString">The text to insert.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Delete"/>
    /// <seealso cref="Insert"/>
    /// <seealso cref="Text"/>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure Append(const AString: UTF8String); inline;

    /// <summary>
    ///  Delete text from the text object.
    ///
    ///  This method may cause the internal text representation to be rebuilt.
    /// </summary>
    /// <param name="AOffset">The offset, in bytes (8-bit UTF-8 characters),
    ///  from the beginning of the string if >= 0, the offset from the end of
    ///  the string if < 0.</param>
    /// <param name="ALength">The length of text to delete, in bytes, or -1
    ///  for the remainder of the string.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Append"/>
    /// <seealso cref="Insert"/>
    /// <seealso cref="Text"/>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure Delete(const AOffset, ALength: Integer); inline;

    /// <summary>
    ///  Get the substring of the text object that surrounds a text offset.
    ///
    ///  If `AOffset` is less than 0, this will return a zero length substring
    ///  at the beginning of the text with the TSdlTtfSubStringFlag.TextStart
    ///  flag set. If `AOffset` is greater than or equal to the length of the
    ///  text string, this will return a zero length substring at the end of the
    ///  text with the TSdlTtfSubStringFlag.TextEnd flag set.
    /// </summary>
    /// <param name="AOffset">A byte offset into the text string.</param>
    /// <returns>The substring containing the offset.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function SubString(const AOffset: Integer): TSdlTtfSubString; inline;

    /// <summary>
    ///  Get the substring of the text object that contains the given line.
    ///
    ///  If `ALine` is less than 0, this will return a zero length substring at
    ///  the beginning of the text with the TSdlTtfSubStringFlag.TextStart flag
    ///  set. If `ALine` is greater than or equal to `NumLines` this will return
    ///  a zero length substring at the end of the text with the
    ///  TSdlTtfSubStringFlag.TextEnd flag set.
    /// </summary>
    /// <param name="ALine">A zero-based line index, in the range [0..NumLines-1].</param>
    /// <returns>The substring containing the line.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function SubStringForLine(const ALine: Integer): TSdlTtfSubString; inline;

    /// <summary>
    ///  Get the substrings of a text object that contain a range of text.
    /// </summary>
    /// <param name="AOffset">A byte offset into the text string.</param>
    /// <param name="ALength">The length of the range being queried, in bytes,
    ///  or -1 for the remainder of the string.</param>
    /// <returns>An array of substrings.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function SubStringsForRange(const AOffset, ALength: Integer): TArray<TSdlTtfSubString>;

    /// <summary>
    ///  Get the portion of a text string that is closest to a point.
    ///
    ///  This will return the closest substring of text to the given point.
    /// </summary>
    /// <param name="AX">The x coordinate relative to the left side of the text,
    ///  may be outside the bounds of the text area.</param>
    /// <param name="AY">The y coordinate relative to the top side of the text,
    ///  may be outside the bounds of the text area.</param>
    /// <returns>The closest substring of text to the given point.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function SubStringForPoint(const AX, AY: Integer): TSdlTtfSubString; overload;

    /// <summary>
    ///  Get the portion of a text string that is closest to a point.
    ///
    ///  This will return the closest substring of text to the given point.
    /// </summary>
    /// <param name="APoint">The coordinate relative to the top-left side of the
    ///  text, may be outside the bounds of the text area.</param>
    /// <returns>The closest substring of text to the given point.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function SubStringForPoint(const APoint: TSdlPoint): TSdlTtfSubString; overload;

    /// <summary>
    ///  Get the previous substring in the text object
    ///
    ///  If called at the start of the text, this will return a zero length
    ///  substring with the TSdlTtfSubStringFlag.TextStart flag set.
    /// </summary>
    /// <param name="ASubString">The substring to query.</param>
    /// <returns>The substring before ASubString.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function PreviousSubString(const ASubString: TSdlTtfSubString): TSdlTtfSubString; inline;

    /// <summary>
    ///  Get the next substring in the text object
    ///
    ///  If called at the end of the text, this will return a zero length
    ///  substring with the TSdlTtfSubStringFlag.TextEnd flag set.
    /// </summary>
    /// <param name="ASubString">The substring to query.</param>
    /// <returns>The substring after ASubString.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    function NextSubString(const ASubString: TSdlTtfSubString): TSdlTtfSubString; inline;

    /// <summary>
    ///  Update the layout of a text object.
    ///
    ///  This is automatically done when the layout is requested or the text is
    ///  rendered, but you can call this if you need more control over the timing of
    ///  when the layout and text engine representation are updated.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should be called on the thread that created the text.
    /// </remarks>
    procedure Update; inline;

    /// <summary>
    ///  The text this object represents, useful for layout, debugging and
    ///  retrieving substring text. This is updated when the text object is
    ///  modified.
    ///
    ///  Updating this property may cause the internal text representation to be
    ///  rebuilt.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Append"/>
    /// <seealso cref="Delete"/>
    /// <seealso cref="Insert"/>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Text: UTF8String read GetText write SetText;

    /// <summary>
    ///  The number of lines in the text, 0 if it's empty
    /// </summary>
    property NumLines: Integer read GetNumLines;

    /// <summary>
    ///  The text engine used by this text object.
    ///
    ///  Updating this property may cause the internal text representation to be
    ///  rebuilt.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Engine: TSdlTtfTextEngine read GetEngine write SetEngine;

    /// <summary>
    ///  The font used by the text object.
    ///
    ///  When a text object has a font, any changes to the font will automatically
    ///  regenerate the text. If you set the font to nil, the text will continue to
    ///  render but changes to the font will no longer affect the text.
    ///
    ///  Updating this property may cause the internal text representation to be
    ///  rebuilt.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Font: TSdlTtfFont read GetFont write SetFont;

    /// <summary>
    ///  The direction to be used for text shaping this text object.
    ///
    ///  This defaults to the direction of the font used by the text object.
    ///
    ///  This property only supports left-to-right text shaping if SDL_ttf was not
    ///  built with HarfBuzz support.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Direction: TSdlTtfDirection read GetDirection write SetDirection;

    /// <summary>
    ///  The script to be used for text shaping the text object, as an
    ///  [ISO 15924 code](https://unicode.org/iso15924/iso15924-codes.html).
    ///
    ///  This defaults to the script of the font used by the text object.
    ///  Returns 0 if a script hasn't been set on either the text object or
    ///  the font.
    ///
    ///  Fails if SDL_ttf isn't built with HarfBuzz support.
    /// </summary>
    /// <param name="AText">the text to modify.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SdlTtfStringToTag"/>
    /// <seealso cref="SdlTtfTagToString"/>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Script: Cardinal read GetScript write SetScript;

    /// <summary>
    ///  The color of the text object.
    ///
    ///  The default text color is white (255, 255, 255, 255).
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ColorFloat"/>
    /// <seealso cref="SetColor"/>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Color: TSdlColor read GetColor write SetColor;

    /// <summary>
    ///  The color of the text object.
    ///
    ///  The default text color is white (1.0, 1.0, 1.0, 1.0).
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Color"/>
    /// <seealso cref="SetColorFloat"/>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property ColorFloat: TSdlColorF read GetColorFloat write SetColorFloat;

    /// <summary>
    ///  The position of the text object.
    ///
    ///  This can be used to position multiple text objects within a single wrapping
    ///  text area.
    ///
    ///  Updating this property may cause the internal text representation to be
    ///  rebuilt.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetPosition"/>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Position: TSdlPoint read GetPosition write SetPosition;

    /// <summary>
    ///  Controls wrapping for this text object.
    ///
    ///  Set to 0 to wrap on newline characters only, or a value > 0 to set the
    ///  maximum width in pixels.
    ///
    ///  Updating this property may cause the internal text representation to be
    ///  rebuilt.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property WrapWidth: Integer read GetWrapWidth write SetWrapWidth;

    /// <summary>
    ///  Whether whitespace should be visible when wrapping the text object.
    ///
    ///  If the whitespace is visible, it will take up space for purposes of
    ///  alignment and wrapping. This is good for editing, but looks better when
    ///  centered or aligned if whitespace around line wrapping is hidden. This
    ///  defaults False.
    ///
    ///  Updating this property may cause the internal text representation to be
    ///  rebuilt.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property IsWrapWhitespaceVisible: Boolean read GetIsWrapWhitespaceVisible write SetIsWrapWhitespaceVisible;

    /// <summary>
    ///  The size of a text object, in pixels.
    ///
    ///  The size of the text may change when the font or font style and size
    ///  change.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Size: TSdlSize read GetSize;

    /// <summary>
    ///  The properties associated with this text object.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the text.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;

  /// <summary>
  ///  Abstract base text engine. Use one of the following implementations:
  ///
  ///   * TSdlTtfSurfaceTextEngine
  ///   * TSdlTtfRendererTextEngine
  ///   * TSdlTtfGpuTextEngine
  /// </summary>
  /// <seealso cref="TSdlTtfSurfaceTextEngine"/>
  /// <seealso cref="TSdlTtfRendererTextEngine"/>
  /// <seealso cref="TSdlTtfGpuTextEngine"/>
  TSdlTtfTextEngine = class abstract
  {$REGION 'Internal Declarations'}
  private class var
    FInstances: TDictionary<PTTF_TextEngine, TSdlTtfTextEngine>;
  protected
    FHandle: PTTF_TextEngine;
  protected
    procedure DestroyHandle; virtual; abstract;
  public
    class constructor Create;
    class destructor Destroy;
    procedure AfterConstruction; override;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Destructor.
    ///
    ///  All text created by this engine should be destroyed before calling this
    ///  destructor.
    /// </summary>
    /// <remarks>
    ///  This destructor should be called on the thread that created the engine.
    /// </remarks>
    destructor Destroy; override;

    /// <summary>
    ///  Create a text object for use with this engine.
    /// </summary>
    /// <param name="AFont">The font to render with.</param>
    /// <param name="AText">The text to use.</param>
    /// <returns>A TSdlTtfText object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlTtfText.Free"/>
    /// <remarks>
    ///  This method should be called on the thread that created the font and
    ///  text engine.
    /// </remarks>
    function CreateText(const AFont: TSdlTtfFont;
      const AText: UTF8String): TSdlTtfText; overload; inline;

    /// <summary>
    ///  Create a text object for use with this engine.
    /// </summary>
    /// <param name="AFont">The font to render with.</param>
    /// <param name="AText">The text to use.</param>
    /// <returns>A TSdlTtfText object.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlTtfText.Free"/>
    /// <remarks>
    ///  This method should be called on the thread that created the font and
    ///  text engine.
    /// </remarks>
    function CreateText(const AFont: TSdlTtfFont;
      const AText: String): TSdlTtfText; overload; inline;
  end;

type
  /// <summary>
  ///  A text engine for drawing text on SDL surfaces.
  /// </summary>
  /// <seealso cref="TSdlTtfRendererTextEngine"/>
  /// <seealso cref="TSdlTtfGpuTextEngine"/>
  TSdlTtfSurfaceTextEngine = class(TSdlTtfTextEngine)
  {$REGION 'Internal Declarations'}
  protected
    procedure DestroyHandle; override;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create a text engine for drawing text on SDL surfaces.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create;

    /// <summary>
    ///  Draw text to an SDL surface.
    ///
    ///  `AText` must have been created using TSdlTtfSurfaceTextEngine.
    /// </summary>
    /// <param name="AText">The text to draw.</param>
    /// <param name="AX">The x coordinate in pixels, positive from the left edge
    ///  towards the right.</param>
    /// <param name="AY">The y coordinate in pixels, positive from the top edge
    ///  towards the bottom.</param>
    /// <param name="ASurface">The surface to draw on.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function should be called on the thread that created the text.
    /// </remarks>
    procedure Draw(const AText: TSdlTtfText; const AX, AY: Integer;
      const ASurface: TSdlSurface); overload; inline;

    /// <summary>
    ///  Draw text to an SDL surface.
    ///
    ///  `AText` must have been created using TSdlTtfSurfaceTextEngine.
    /// </summary>
    /// <param name="AText">The text to draw.</param>
    /// <param name="APosition">The coordinate in pixels, positive from the
    ///  top-left edge towards the bottom-right.</param>
    /// <param name="ASurface">The surface to draw on.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function should be called on the thread that created the text.
    /// </remarks>
    procedure Draw(const AText: TSdlTtfText; const APosition: TSdlPoint;
      const ASurface: TSdlSurface); overload; inline;
  end;

type
  /// <summary>
  ///  A text engine for drawing text on an SDL renderer.
  /// </summary>
  /// <seealso cref="TSdlTtfSurfaceTextEngine"/>
  /// <seealso cref="TSdlTtfGpuTextEngine"/>
  TSdlTtfRendererTextEngine = class(TSdlTtfTextEngine)
  {$REGION 'Internal Declarations'}
  protected
    procedure DestroyHandle; override;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create a text engine for drawing text on an SDL renderer.
    /// </summary>
    /// <param name="ARenderer">The renderer to use for creating textures and
    ///  drawing text.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This constructor should be called on the thread that created the renderer.
    /// </remarks>
    constructor Create(const ARenderer: TSdlRenderer); overload;

    /// <summary>
    ///  Create a text engine for drawing text on an SDL renderer, with the
    ///  specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlTtfProperty.RendererTextEngineRenderer`: the renderer to use for
    ///    creating textures and drawing text
    ///  - `TSdlTtfProperty.RendererTextAtlasTextureSize`: the size of the
    ///    texture atlas
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This constructor should be called on the thread that created the renderer.
    /// </remarks>
    constructor Create(const AProps: TSdlProperties); overload;

    /// <summary>
    ///  Draw text to an SDL renderer.
    ///
    ///  `AText` must have been created using TSdlTtfRendererTextEngine and will
    ///  draw using the renderer passed to its constructor.
    /// </summary>
    /// <param name="AText">The text to draw.</param>
    /// <param name="AX">The x coordinate in pixels, positive from the left edge
    ///  towards the right.</param>
    /// <param name="AY">The y coordinate in pixels, positive from the top edge
    ///  towards the bottom.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function should be called on the thread that created the text.
    /// </remarks>
    procedure Draw(const AText: TSdlTtfText; const AX, AY: Single); overload; inline;

    /// <summary>
    ///  Draw text to an SDL renderer.
    ///
    ///  `AText` must have been created using TSdlTtfRendererTextEngine and will
    ///  draw using the renderer passed to its constructor.
    /// </summary>
    /// <param name="AText">The text to draw.</param>
    /// <param name="APosition">The coordinate in pixels, positive from the
    ///  top-left edge towards the bottom-right.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function should be called on the thread that created the text.
    /// </remarks>
    procedure Draw(const AText: TSdlTtfText; const APosition: TSdlPointF); overload; inline;
  end;

type
  /// <summary>
  ///  A text engine for drawing text with the SDL GPU API.
  /// </summary>
  /// <seealso cref="TSdlTtfSurfaceTextEngine"/>
  /// <seealso cref="TSdlTtfRendererTextEngine"/>
  TSdlTtfGpuTextEngine = class(TSdlTtfTextEngine)
  {$REGION 'Internal Declarations'}
  private
    function GetWinding: TSdlTtfGpuTextEngineWinding; inline;
    procedure SetWinding(const AValue: TSdlTtfGpuTextEngineWinding); inline;
  protected
    procedure DestroyHandle; override;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Create a text engine for drawing text with the SDL GPU API.
    /// </summary>
    /// <param name="ADevice">The GPU device to use for creating textures and
    ///  drawing text.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This constructor should be called on the thread that created the device.
    /// </remarks>
    constructor Create(const ADevice: TSdlGpuDevice); overload;

    /// <summary>
    ///  Create a text engine for drawing text with the SDL GPU API, with the
    ///  specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlTtfProperty.GpuTextEngineDevice`: the TSdlGpuDevice to use for
    ///    creating textures and drawing text.
    ///  - `TSdlTtfProperty.GpuTextEngineAtlasTextureSize`: the size of the
    ///    texture atlas
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This constructor should be called on the thread that created the device.
    /// </remarks>
    constructor Create(const AProps: TSdlProperties); overload;

    /// <summary>
    ///  The winding order of the vertices returned by TSdlTtfText.GetGpuDrawData.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should be used on the thread that created the engine.
    /// </remarks>
    property Winding: TSdlTtfGpuTextEngineWinding read GetWinding write SetWinding;
  end;

implementation

procedure SdlTtfInit; inline;
begin
  SdlCheck(TTF_Init);
end;

procedure SdlTtfQuit; inline;
begin
  TTF_Quit;
end;

function SdlTtfWasInit: Integer; inline;
begin
  Result := TTF_WasInit;
end;

function SdlTtfGetVersion: Integer; inline;
begin
  Result := TTF_Version;
end;

procedure SdlTtfGetFreeTypeVersion(out AMajor, AMinor, APatch: Integer); inline;
begin
  TTF_GetFreeTypeVersion(@AMajor, @AMinor, @APatch);
end;

procedure SdlTtfGetHarfBuzzVersion(out AMajor, AMinor, APatch: Integer); inline;
begin
  TTF_GetHarfBuzzVersion(@AMajor, @AMinor, @APatch);
end;

function SdlTtfStringToTag(const AString: String): Cardinal; inline;
begin
  Result := TTF_StringToTag(__ToUtf8(AString));
end;

function SdlTtfTagToString(const ATag: Cardinal): String; inline;
var
  Buf: array [0..4] of UTF8Char;
begin
  TTF_TagToString(ATag, @Buf, SizeOf(Buf));
  Buf[4] := #0;
  Result := __ToString(@Buf);
end;

function SdlTtfGetGlyphScript(const ACodepoint: UCS4Char): Cardinal; inline;
begin
  Result := TTF_GetGlyphScript(ACodepoint);
  SdlCheck(Result);
end;

{ TSdlTtfFont }

class operator TSdlTtfFont.Equal(const ALeft: TSdlTtfFont;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

constructor TSdlTtfFont.Create(const AFile: String; const APtSize: Single);
begin
  FHandle := TTF_OpenFont(__ToUtf8(AFile), APtSize);
  SdlCheck(FHandle);
end;

constructor TSdlTtfFont.Create(const ASrc: TSdlIOStream;
  const ACloseIO: Boolean; const APtSize: Single);
begin
  FHandle := TTF_OpenFontIO(SDL_IOStream(ASrc), ACloseIO, APtSize);
  SdlCheck(FHandle);
end;

procedure TSdlTtfFont.AddFallback(const AFallback: TSdlTtfFont);
begin
  SdlCheck(TTF_AddFallbackFont(FHandle, AFallback.FHandle));
end;

procedure TSdlTtfFont.ClearFallbacks;
begin
  TTF_ClearFallbackFonts(FHandle);
end;

function TSdlTtfFont.Clone: TSdlTtfFont;
begin
  Result.FHandle := TTF_CopyFont(FHandle);
  SdlCheck(Result.FHandle);
end;

constructor TSdlTtfFont.Create(const AProps: TSdlProperties);
begin
  FHandle := TTF_OpenFontWithProperties(SDL_PropertiesID(AProps));
  SdlCheck(FHandle);
end;

class operator TSdlTtfFont.Equal(const ALeft, ARight: TSdlTtfFont): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlTtfFont.Free;
begin
  TTF_CloseFont(FHandle);
  FHandle := 0;
end;

function TSdlTtfFont.GetAscent: Integer;
begin
  Result := TTF_GetFontAscent(FHandle);
end;

function TSdlTtfFont.GetDescent: Integer;
begin
  Result := TTF_GetFontDescent(FHandle);
end;

function TSdlTtfFont.GetDirection: TSdlTtfDirection;
begin
  Result := TSdlTtfDirection(TTF_GetFontDirection(FHandle));
end;

procedure TSdlTtfFont.GetDpi(out AHDpi, AVDpi: Integer);
begin
  SdlCheck(TTF_GetFontDPI(FHandle, @AHDpi, @AVDpi));
end;

function TSdlTtfFont.GetFamilyName: String;
begin
  Result := __ToString(TTF_GetFontFamilyName(FHandle));
end;

function TSdlTtfFont.GetGeneration: Cardinal;
begin
  Result := TTF_GetFontGeneration(FHandle);
  SdlCheck(Result);
end;

function TSdlTtfFont.GetGlyphImage(const ACodepoint: UCS4Char): TSdlSurface;
begin
  PSDL_Surface(Result) := TTF_GetGlyphImage(FHandle, ACodepoint, nil);
  SdlCheck(Pointer(Result));
end;

function TSdlTtfFont.GetGlyphImage(const ACodepoint: UCS4Char;
  out AImageType: TSdlTtfImageType): TSdlSurface;
begin
  PSDL_Surface(Result) := TTF_GetGlyphImage(FHandle, ACodepoint, @AImageType);
  SdlCheck(Pointer(Result));
end;

function TSdlTtfFont.GetGlyphImageForIndex(
  const AGlyphIndex: Integer): TSdlSurface;
begin
  PSDL_Surface(Result) := TTF_GetGlyphImageForIndex(FHandle, AGlyphIndex, nil);
  SdlCheck(Pointer(Result));
end;

function TSdlTtfFont.GetGlyphImageForIndex(const AGlyphIndex: Integer;
  out AImageType: TSdlTtfImageType): TSdlSurface;
begin
  PSDL_Surface(Result) := TTF_GetGlyphImageForIndex(FHandle, AGlyphIndex, @AImageType);
  SdlCheck(Pointer(Result));
end;

function TSdlTtfFont.GetGlyphKerning(const APrevious,
  ACurrent: UCS4Char): Integer;
begin
  SdlCheck(TTF_GetGlyphKerning(FHandle, APrevious, ACurrent, @Result));
end;

procedure TSdlTtfFont.GetGlyphMetrics(const ACodepoint: UCS4Char; out AMinX,
  AMaxX, AMinY, AMaxY, AAdvance: Integer);
begin
  SdlCheck(TTF_GetGlyphMetrics(FHandle, ACodepoint, @AMinX, @AMaxX, @AMinY,
    @AMaxY, @AAdvance));
end;

function TSdlTtfFont.GetHeight: Integer;
begin
  Result := TTF_GetFontHeight(FHandle);
end;

function TSdlTtfFont.GetHinting: TSdlTtfHinting;
begin
  Result := TSdlTtfHinting(TTF_GetFontHinting(FHandle));
end;

function TSdlTtfFont.GetIsFixedWidth: Boolean;
begin
  Result := TTF_FontIsFixedWidth(FHandle);
end;

function TSdlTtfFont.GetIsKerningEnabled: Boolean;
begin
  Result := TTF_GetFontKerning(FHandle);
end;

function TSdlTtfFont.GetIsScalable: Boolean;
begin
  Result := TTF_FontIsScalable(FHandle);
end;

function TSdlTtfFont.GetIsSdfEnabled: Boolean;
begin
  Result := TTF_GetFontSDF(FHandle);
end;

function TSdlTtfFont.GetLineSkip: Integer;
begin
  Result := TTF_GetFontLineSkip(FHandle);
end;

function TSdlTtfFont.GetNumFaces: Integer;
begin
  Result := TTF_GetNumFontFaces(FHandle);
end;

function TSdlTtfFont.GetOutline: Integer;
begin
  Result := TTF_GetFontOutline(FHandle);
end;

function TSdlTtfFont.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := TTF_GetFontProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

function TSdlTtfFont.GetScript: Cardinal;
begin
  Result := TTF_GetFontScript(FHandle);
end;

function TSdlTtfFont.GetSize: Single;
begin
  Result := TTF_GetFontSize(FHandle);
  if (Result = 0) then
    __HandleError;
end;

function TSdlTtfFont.GetStyle: TSdlTtfFontStyles;
begin
  Byte(Result) := TTF_GetFontStyle(FHandle);
end;

function TSdlTtfFont.GetStyleName: String;
begin
  Result := __ToString(TTF_GetFontStyleName(FHandle));
end;

function TSdlTtfFont.GetTextSize(const AText: String;
  const AWrapWidth: Integer): TSdlSize;
begin
  SdlCheck(TTF_GetStringSizeWrapped(FHandle, __ToUtf8(AText), 0, AWrapWidth,
    @Result.W, @Result.H));
end;

function TSdlTtfFont.GetTextSize(const AText: String): TSdlSize;
begin
  SdlCheck(TTF_GetStringSize(FHandle, __ToUtf8(AText), 0, @Result.W, @Result.H));
end;

function TSdlTtfFont.GetWrapAlignment: TSdlTtfHorizontalAlignment;
begin
  Result := TSdlTtfHorizontalAlignment(TTF_GetFontWrapAlignment(FHandle));
end;

function TSdlTtfFont.HasGlyph(const ACodepoint: UCS4Char): Boolean;
begin
  Result := TTF_FontHasGlyph(FHandle, ACodepoint);
end;

class operator TSdlTtfFont.Implicit(const AValue: Pointer): TSdlTtfFont;
begin
  Result.FHandle := THandle(AValue);
end;

function TSdlTtfFont.MeasureText(const AText: String;
  const AMaxWidth: Integer): Integer;
begin
  var Utf8Len: Integer;
  var Utf8 := __ToUtf8(AText, Utf8Len);
  var MeasuredLen: NativeInt;
  SdlCheck(TTF_MeasureString(FHandle, PUTF8Char(Utf8), Utf8Len, AMaxWidth,
    nil, @MeasuredLen));
  if (MeasuredLen = Utf8Len) then
    Result := Length(AText)
  else
    Result := Length(__ToString(Utf8, Utf8Len));
end;

function TSdlTtfFont.MeasureText(const AText: String; const AMaxWidth: Integer;
  out AMeasuredWidth: Integer): Integer;
begin
  var Utf8Len: Integer;
  var Utf8 := __ToUtf8(AText, Utf8Len);
  var MeasuredLen: NativeInt;
  SdlCheck(TTF_MeasureString(FHandle, PUTF8Char(Utf8), Utf8Len, AMaxWidth,
    @AMeasuredWidth, @MeasuredLen));
  if (MeasuredLen = Utf8Len) then
    Result := Length(AText)
  else
    Result := Length(__ToString(Utf8, Utf8Len));
end;

class operator TSdlTtfFont.NotEqual(const ALeft: TSdlTtfFont;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class operator TSdlTtfFont.NotEqual(const ALeft, ARight: TSdlTtfFont): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

procedure TSdlTtfFont.RemoveFallback(const AFallback: TSdlTtfFont);
begin
  TTF_RemoveFallbackFont(FHandle, AFallback.FHandle);
end;

function TSdlTtfFont.RenderGlyph(const ACodepoint: UCS4Char;
  const AMode: TSdlTtfRenderMode; const AForegroundColor,
  ABackgroundColor: TSdlColor): TSdlSurface;
begin
  var Surface: PSDL_Surface := nil;
  case AMode of
    TSdlTtfRenderMode.Fast:
      Surface := TTF_RenderGlyph_Solid(FHandle, ACodepoint, SDL_Color(AForegroundColor));

    TSdlTtfRenderMode.AntiAliasedPalette:
      Surface := TTF_RenderGlyph_Shaded(FHandle, ACodepoint, SDL_Color(AForegroundColor), SDL_Color(AForegroundColor));

    TSdlTtfRenderMode.AntiAliasedAlpha:
      Surface := TTF_RenderGlyph_Blended(FHandle, ACodepoint, SDL_Color(AForegroundColor));

    TSdlTtfRenderMode.Subpixel:
      Surface := TTF_RenderGlyph_LCD(FHandle, ACodepoint, SDL_Color(AForegroundColor), SDL_Color(AForegroundColor));
  end;

  SdlCheck(Surface);
  PSDL_Surface(Result) := Surface;
end;

function TSdlTtfFont.RenderGlyph(const ACodepoint: UCS4Char;
  const AMode: TSdlTtfRenderMode;
  const AForegroundColor: TSdlColor): TSdlSurface;
begin
  Result := RenderGlyph(ACodepoint, AMode, AForegroundColor, TSdlColor.Null);
end;

function TSdlTtfFont.RenderText(const AText: String;
  const AMode: TSdlTtfRenderMode; const AForegroundColor,
  ABackgroundColor: TSdlColor; const AWrapLength: Integer): TSdlSurface;
begin
  var Utf8Len: Integer;
  var Utf8 := __ToUtf8(AText, Utf8Len);

  var Surface: PSDL_Surface := nil;
  if (AWrapLength < 0) then
  begin
    case AMode of
      TSdlTtfRenderMode.Fast:
        Surface := TTF_RenderText_Solid(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor));

      TSdlTtfRenderMode.AntiAliasedPalette:
        Surface := TTF_RenderText_Shaded(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor), SDL_Color(ABackgroundColor));

      TSdlTtfRenderMode.AntiAliasedAlpha:
        Surface := TTF_RenderText_Blended(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor));

      TSdlTtfRenderMode.Subpixel:
        Surface := TTF_RenderText_LCD(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor), SDL_Color(ABackgroundColor));
    end;
  end
  else
  begin
    case AMode of
      TSdlTtfRenderMode.Fast:
        Surface := TTF_RenderText_Solid_Wrapped(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor), AWrapLength);

      TSdlTtfRenderMode.AntiAliasedPalette:
        Surface := TTF_RenderText_Shaded_Wrapped(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor), SDL_Color(ABackgroundColor), AWrapLength);

      TSdlTtfRenderMode.AntiAliasedAlpha:
        Surface := TTF_RenderText_Blended_Wrapped(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor), AWrapLength);

      TSdlTtfRenderMode.Subpixel:
        Surface := TTF_RenderText_LCD_Wrapped(FHandle, Utf8, Utf8Len, SDL_Color(AForegroundColor), SDL_Color(ABackgroundColor), AWrapLength);
    end;
  end;

  SdlCheck(Surface);
  PSDL_Surface(Result) := Surface;
end;

function TSdlTtfFont.RenderText(const AText: String;
  const AMode: TSdlTtfRenderMode; const AForegroundColor: TSdlColor;
  const AWrapLength: Integer): TSdlSurface;
begin
  Result := RenderText(AText, AMode, AForegroundColor, TSdlColor.Null, AWrapLength);
end;

procedure TSdlTtfFont.SetDirection(const AValue: TSdlTtfDirection);
begin
  SdlCheck(TTF_SetFontDirection(FHandle, Ord(AValue)));
end;

procedure TSdlTtfFont.SetHinting(const AValue: TSdlTtfHinting);
begin
  TTF_SetFontHinting(FHandle, Ord(AValue));
end;

procedure TSdlTtfFont.SetIsKerningEnabled(const AValue: Boolean);
begin
  TTF_SetFontKerning(FHandle, AValue);
end;

procedure TSdlTtfFont.SetIsSdfEnabled(const AValue: Boolean);
begin
  SdlCheck(TTF_SetFontSDF(FHandle, AValue));
end;

procedure TSdlTtfFont.SetLanguage(const AValue: String);
begin
  SdlCheck(TTF_SetFontLanguage(FHandle, __ToUtf8(AValue)));
end;

procedure TSdlTtfFont.SetLineSkip(const AValue: Integer);
begin
  TTF_SetFontLineSkip(FHandle, AValue);
end;

procedure TSdlTtfFont.SetOutline(const AValue: Integer);
begin
  SdlCheck(TTF_SetFontOutline(FHandle, AValue));
end;

procedure TSdlTtfFont.SetScript(const AValue: Cardinal);
begin
  SdlCheck(TTF_SetFontScript(FHandle, AValue));
end;

procedure TSdlTtfFont.SetSize(const AValue: Single);
begin
  SdlCheck(TTF_SetFontSize(FHandle, AValue));
end;

procedure TSdlTtfFont.SetSizeDpi(const APtSize: Single; const AHDpi,
  AVDpi: Integer);
begin
  SdlCheck(TTF_SetFontSizeDPI(FHandle, APtSize, AHDpi, AVDpi));
end;

procedure TSdlTtfFont.SetStyle(const AValue: TSdlTtfFontStyles);
begin
  TTF_SetFontStyle(FHandle, Byte(AValue));
end;

procedure TSdlTtfFont.SetWrapAlignment(
  const AValue: TSdlTtfHorizontalAlignment);
begin
  TTF_SetFontWrapAlignment(FHandle, Ord(AValue));
end;

{ TSdlTtfGpuAtlasDrawSequence }

class operator TSdlTtfGpuAtlasDrawSequence.Equal(
  const ALeft: TSdlTtfGpuAtlasDrawSequence; const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlTtfGpuAtlasDrawSequence.Equal(const ALeft,
  ARight: TSdlTtfGpuAtlasDrawSequence): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlTtfGpuAtlasDrawSequence.GetAtlasTexture: TSdlGpuTexture;
begin
  if Assigned(FHandle) then
    SDL_GPUTexture(Result) := FHandle.atlas_texture
  else
    SDL_GPUTexture(Result) := 0;
end;

function TSdlTtfGpuAtlasDrawSequence.GetImageType: TSdlTtfImageType;
begin
  if Assigned(FHandle) then
    Result := TSdlTtfImageType(FHandle.image_type)
  else
    Result := TSdlTtfImageType.Invalid;
end;

function TSdlTtfGpuAtlasDrawSequence.GetIndices: PInteger;
begin
  if Assigned(FHandle) then
    Result := FHandle.indices
  else
    Result := nil;
end;

function TSdlTtfGpuAtlasDrawSequence.GetNext: TSdlTtfGpuAtlasDrawSequence;
begin
  if Assigned(FHandle) then
    Result.FHandle := FHandle.next
  else
    Result.FHandle := nil;
end;

function TSdlTtfGpuAtlasDrawSequence.GetNumIndices: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.num_indices
  else
    Result := 0;
end;

function TSdlTtfGpuAtlasDrawSequence.GetNumVertices: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.num_vertices
  else
    Result := 0;
end;

function TSdlTtfGpuAtlasDrawSequence.GetUV: PSdlPointF;
begin
  if Assigned(FHandle) then
    Result := PSdlPointF(FHandle.uv)
  else
    Result := nil;
end;

function TSdlTtfGpuAtlasDrawSequence.GetXY: PSdlPointF;
begin
  if Assigned(FHandle) then
    Result := PSdlPointF(FHandle.xy)
  else
    Result := nil;
end;

class operator TSdlTtfGpuAtlasDrawSequence.Implicit(
  const AValue: Pointer): TSdlTtfGpuAtlasDrawSequence;
begin
  Result.FHandle := AValue;
end;

class operator TSdlTtfGpuAtlasDrawSequence.NotEqual(
  const ALeft: TSdlTtfGpuAtlasDrawSequence; const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

class operator TSdlTtfGpuAtlasDrawSequence.NotEqual(const ALeft,
  ARight: TSdlTtfGpuAtlasDrawSequence): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

{ TSdlTtfSubString }

function TSdlTtfSubString.GetFlags: TSdlTtfSubStringFlags;
begin
  Word(Result) := FHandle.flags;
end;

function TSdlTtfSubString.GetRect: TSdlRect;
begin
  Result := TSdlRect(FHandle.rect);
end;

{ TSdlTtfText }

class operator TSdlTtfText.Equal(const ALeft: TSdlTtfText;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

procedure TSdlTtfText.Append(const AString: UTF8String);
begin
  SdlCheck(TTF_AppendTextString(FHandle, Pointer(AString), Length(AString)));
end;

procedure TSdlTtfText.Delete(const AOffset, ALength: Integer);
begin
  TTF_DeleteTextString(FHandle, AOffset, ALength);
end;

class operator TSdlTtfText.Equal(const ALeft, ARight: TSdlTtfText): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlTtfText.Free;
begin
  TTF_DestroyText(FHandle);
  FHandle := nil;
end;

function TSdlTtfText.GetDirection: TSdlTtfDirection;
begin
  Result := TSdlTtfDirection(TTF_GetTextDirection(FHandle));
end;

function TSdlTtfText.GetEngine: TSdlTtfTextEngine;
begin
  var Engine := TTF_GetTextEngine(FHandle);
  if SdlSucceeded(Engine) and Assigned(TSdlTtfTextEngine.FInstances) then
    TSdlTtfTextEngine.FInstances.TryGetValue(Engine, Result)
  else
    Result := nil;

  SdlCheck(Result);
end;

function TSdlTtfText.GetFont: TSdlTtfFont;
begin
  Result.FHandle := TTF_GetTextFont(FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlTtfText.GetGpuDrawData: TSdlTtfGpuAtlasDrawSequence;
begin
  if (FHandle = nil) or (FHandle.text = nil) then
    Result.FHandle := nil
  else
  begin
    Result.FHandle := TTF_GetGPUTextDrawData(FHandle);
    SdlCheck(Result.FHandle);
  end;
end;

function TSdlTtfText.GetIsWrapWhitespaceVisible: Boolean;
begin
  Result := TTF_TextWrapWhitespaceVisible(FHandle);
end;

function TSdlTtfText.GetNumLines: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.num_lines
  else
    Result := 0;
end;

function TSdlTtfText.GetPosition: TSdlPoint;
begin
  SdlCheck(TTF_GetTextPosition(FHandle, @Result.X, @Result.Y));
end;

function TSdlTtfText.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := TTF_GetTextProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

function TSdlTtfText.GetScript: Cardinal;
begin
  Result := TTF_GetTextScript(FHandle);
end;

function TSdlTtfText.GetSize: TSdlSize;
begin
  SdlCheck(TTF_GetTextSize(FHandle, @Result.W, @Result.H));
end;

function TSdlTtfText.GetText: UTF8String;
begin
  SetLength(Result, Length(FHandle.text));
  Move(FHandle.text^, Result[Low(UTF8String)], Length(Result));
end;

function TSdlTtfText.GetWrapWidth: Integer;
begin
  SdlCheck(TTF_GetTextWrapWidth(FHandle, @Result));
end;

function TSdlTtfText.GetColor: TSdlColor;
begin
  SdlCheck(TTF_GetTextColor(FHandle, @Result.R, @Result.G, @Result.B, @Result.A));
end;

function TSdlTtfText.GetColorFloat: TSdlColorF;
begin
  SdlCheck(TTF_GetTextColorFloat(FHandle, @Result.R, @Result.G, @Result.B, @Result.A));
end;

class operator TSdlTtfText.Implicit(const AValue: Pointer): TSdlTtfText;
begin
  Result.FHandle := AValue;
end;

procedure TSdlTtfText.Insert(const AOffset: Integer; const AString: UTF8String);
begin
  SdlCheck(TTF_InsertTextString(FHandle, AOffset, Pointer(AString), Length(AString)));
end;

class operator TSdlTtfText.NotEqual(const ALeft: TSdlTtfText;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

function TSdlTtfText.NextSubString(
  const ASubString: TSdlTtfSubString): TSdlTtfSubString;
begin
  SdlCheck(TTF_GetNextTextSubString(FHandle, @ASubString.FHandle, @Result.FHandle));
end;

class operator TSdlTtfText.NotEqual(const ALeft, ARight: TSdlTtfText): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

function TSdlTtfText.PreviousSubString(
  const ASubString: TSdlTtfSubString): TSdlTtfSubString;
begin
  SdlCheck(TTF_GetPreviousTextSubString(FHandle, @ASubString.FHandle, @Result.FHandle));
end;

procedure TSdlTtfText.SetDirection(const AValue: TSdlTtfDirection);
begin
  SdlCheck(TTF_SetTextDirection(FHandle, Ord(AValue)));
end;

procedure TSdlTtfText.SetEngine(const AValue: TSdlTtfTextEngine);
begin
  if Assigned(AValue) then
    SdlCheck(TTF_SetTextEngine(FHandle, AValue.FHandle))
  else
    SdlCheck(TTF_SetTextEngine(FHandle, nil));
end;

procedure TSdlTtfText.SetFont(const AValue: TSdlTtfFont);
begin
  SdlCheck(TTF_SetTextFont(FHandle, AValue.FHandle));
end;

procedure TSdlTtfText.SetIsWrapWhitespaceVisible(const AValue: Boolean);
begin
  SdlCheck(TTF_SetTextWrapWhitespaceVisible(FHandle, AValue));
end;

procedure TSdlTtfText.SetPosition(const AValue: TSdlPoint);
begin
  SdlCheck(TTF_SetTextPosition(FHandle, AValue.X, AValue.Y));
end;

procedure TSdlTtfText.SetPosition(const AX, AY: Integer);
begin
  SdlCheck(TTF_SetTextPosition(FHandle, AX, AY));
end;

procedure TSdlTtfText.SetScript(const AValue: Cardinal);
begin
  SdlCheck(TTF_SetTextScript(FHandle, AValue));
end;

procedure TSdlTtfText.SetText(const AValue: UTF8String);
begin
  SdlCheck(TTF_SetTextString(FHandle, Pointer(AValue), Length(AValue)));
end;

procedure TSdlTtfText.SetWrapWidth(const AValue: Integer);
begin
  SdlCheck(TTF_SetTextWrapWidth(FHandle, AValue));
end;

function TSdlTtfText.SubString(const AOffset: Integer): TSdlTtfSubString;
begin
  SdlCheck(TTF_GetTextSubString(FHandle, AOffset, @Result.FHandle));
end;

function TSdlTtfText.SubStringForLine(const ALine: Integer): TSdlTtfSubString;
begin
  SdlCheck(TTF_GetTextSubStringForLine(FHandle, ALine, @Result.FHandle));
end;

function TSdlTtfText.SubStringForPoint(
  const APoint: TSdlPoint): TSdlTtfSubString;
begin
  SdlCheck(TTF_GetTextSubStringForPoint(FHandle, APoint.X, APoint.Y, @Result.FHandle));
end;

function TSdlTtfText.SubStringForPoint(const AX, AY: Integer): TSdlTtfSubString;
begin
  SdlCheck(TTF_GetTextSubStringForPoint(FHandle, AX, AY, @Result.FHandle));
end;

function TSdlTtfText.SubStringsForRange(const AOffset,
  ALength: Integer): TArray<TSdlTtfSubString>;
begin
  var Count := 0;
  var Substrings := TTF_GetTextSubStringsForRange(FHandle, AOffset, ALength, @Count);
  if (SdlSucceeded(Substrings)) then
  try
    SetLength(Result, Count);
    var P := Substrings;
    for var I := 0 to Count - 1 do
    begin
      Result[I].FHandle := P^^;
      Inc(P);
    end;
  finally
    SDL_free(Substrings);
  end;
end;

procedure TSdlTtfText.Update;
begin
  SdlCheck(TTF_UpdateText(FHandle));
end;

procedure TSdlTtfText.SetColor(const AR, AG, AB, AA: Byte);
begin
  SdlCheck(TTF_SetTextColor(FHandle, AR, AG, AB, AA));
end;

procedure TSdlTtfText.SetColorFloat(const AValue: TSdlColorF);
begin
  SdlCheck(TTF_SetTextColorFloat(FHandle, AValue.R, AValue.G, AValue.B, AValue.A));
end;

procedure TSdlTtfText.SetColor(const AValue: TSdlColor);
begin
  SdlCheck(TTF_SetTextColor(FHandle, AValue.R, AValue.G, AValue.B, AValue.A));
end;

procedure TSdlTtfText.SetColorFloat(const AR, AG, AB, AA: Single);
begin
  SdlCheck(TTF_SetTextColorFloat(FHandle, AR, AG, AB, AA));
end;

{ TSdlTtfTextEngine }

procedure TSdlTtfTextEngine.AfterConstruction;
begin
  inherited;
  if (FHandle <> nil) then
  begin
    if (FInstances = nil) then
      FInstances := TDictionary<PTTF_TextEngine, TSdlTtfTextEngine>.Create;

    FInstances.AddOrSetValue(FHandle, Self);
  end;
end;

class constructor TSdlTtfTextEngine.Create;
begin
  FInstances := nil;
end;

function TSdlTtfTextEngine.CreateText(const AFont: TSdlTtfFont;
  const AText: String): TSdlTtfText;
begin
  var Utf8Len: Integer;
  var Utf8 := __ToUtf8(AText, Utf8Len);
  Result.FHandle := TTF_CreateText(FHandle, AFont.FHandle, Utf8, Utf8Len);
  SdlCheck(Result.FHandle);
end;

function TSdlTtfTextEngine.CreateText(const AFont: TSdlTtfFont;
  const AText: UTF8String): TSdlTtfText;
begin
  Result.FHandle := TTF_CreateText(FHandle, AFont.FHandle, Pointer(AText), Length(AText));
  SdlCheck(Result.FHandle);
end;

destructor TSdlTtfTextEngine.Destroy;
begin
  if (FHandle <> nil) then
  begin
    if (FInstances <> nil) then
      FInstances.Remove(FHandle);

    DestroyHandle;
  end;
  inherited;
end;

class destructor TSdlTtfTextEngine.Destroy;
begin
  FInstances.Free;
end;

{ TSdlTtfSurfaceTextEngine }

constructor TSdlTtfSurfaceTextEngine.Create;
begin
  inherited;
  FHandle := TTF_CreateSurfaceTextEngine;
  SdlCheck(FHandle);
end;

procedure TSdlTtfSurfaceTextEngine.DestroyHandle;
begin
  TTF_DestroySurfaceTextEngine(FHandle);
end;

procedure TSdlTtfSurfaceTextEngine.Draw(const AText: TSdlTtfText;
  const APosition: TSdlPoint; const ASurface: TSdlSurface);
begin
  SdlCheck(TTF_DrawSurfaceText(AText.FHandle, APosition.X, APosition.Y,
    PSDL_Surface(ASurface)));
end;

procedure TSdlTtfSurfaceTextEngine.Draw(const AText: TSdlTtfText; const AX,
  AY: Integer; const ASurface: TSdlSurface);
begin
  SdlCheck(TTF_DrawSurfaceText(AText.FHandle, AX, AY, PSDL_Surface(ASurface)));
end;

{ TSdlTtfRendererTextEngine }

constructor TSdlTtfRendererTextEngine.Create(const ARenderer: TSdlRenderer);
begin
  inherited Create;
  FHandle := TTF_CreateRendererTextEngine(SDL_Renderer(ARenderer));
  SdlCheck(FHandle);
end;

constructor TSdlTtfRendererTextEngine.Create(const AProps: TSdlProperties);
begin
  inherited Create;
  FHandle := TTF_CreateRendererTextEngineWithProperties(SDL_PropertiesID(AProps));
  SdlCheck(FHandle);
end;

procedure TSdlTtfRendererTextEngine.DestroyHandle;
begin
  TTF_DestroyRendererTextEngine(FHandle);
end;

procedure TSdlTtfRendererTextEngine.Draw(const AText: TSdlTtfText;
  const APosition: TSdlPointF);
begin
  SdlCheck(TTF_DrawRendererText(AText.FHandle, APosition.X, APosition.Y));
end;

procedure TSdlTtfRendererTextEngine.Draw(const AText: TSdlTtfText; const AX,
  AY: Single);
begin
  SdlCheck(TTF_DrawRendererText(AText.FHandle, AX, AY));
end;

{ TSdlTtfGpuTextEngine }

constructor TSdlTtfGpuTextEngine.Create(const ADevice: TSdlGpuDevice);
begin
  inherited Create;
  FHandle := TTF_CreateGPUTextEngine(SDL_GPUDevice(ADevice));
  SdlCheck(FHandle);
end;

constructor TSdlTtfGpuTextEngine.Create(const AProps: TSdlProperties);
begin
  inherited Create;
  FHandle := TTF_CreateGPUTextEngineWithProperties(SDL_PropertiesID(AProps));
  SdlCheck(FHandle);
end;

procedure TSdlTtfGpuTextEngine.DestroyHandle;
begin
  TTF_DestroyGPUTextEngine(FHandle);
end;

function TSdlTtfGpuTextEngine.GetWinding: TSdlTtfGpuTextEngineWinding;
begin
  Result := TSdlTtfGpuTextEngineWinding(TTF_GetGPUTextEngineWinding(FHandle));
  if (Result = TSdlTtfGpuTextEngineWinding.Invalid) then
    __HandleError;
end;

procedure TSdlTtfGpuTextEngine.SetWinding(
  const AValue: TSdlTtfGpuTextEngineWinding);
begin
  TTF_SetGPUTextEngineWinding(FHandle, Ord(AValue));
end;

end.
