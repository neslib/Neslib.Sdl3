unit Neslib.Sdl3.Video;

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
  System.Types,
  System.SysUtils,
  System.Generics.Collections,
  Neslib.Sdl3.Api,
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Basics;

{$REGION 'Points and Rectangles'}
/// <summary>
///  Some helper functions for managing rectangles and 2D points, in both
///  integer and floating point versions.
/// </summary>

type
  /// <summary>
  ///  The structure that defines a point (using integers).
  /// </summary>
  TSdlPoint = record
  public
    X: Integer;
    Y: Integer;
  public
    /// <summary>
    ///  Create from X and Y values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AX, AY: Integer); overload;

    /// <summary>
    ///  Create from a TPoint.
    /// </summary>
    /// <param name="APoint">The TPoint.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const APoint: TPoint); overload;

    /// <summary>
    ///  Initialize from X and Y values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AX, AY: Integer); overload; inline;

    /// <summary>
    ///  Initialize from a TPoint.
    /// </summary>
    /// <param name="APoint">The TPoint.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const APoint: TPoint); overload; inline;
  end;
  PSdlPoint = ^TSdlPoint;

/// <summary>
///  Create a TSdlPoint from X and Y values.
/// </summary>
/// <param name="AX">The X value.</param>
/// <param name="AY">The Y value.</param>
/// <returns>The point.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlPoint(const AX, AY: Integer): TSdlPoint; overload; inline;

/// <summary>
///  Create a TSdlPoint from a TPoint.
/// </summary>
/// <param name="APoint">The TPoint.</param>
/// <returns>The point.</returns>
/// <remarks>
///  It is safe to call this constructor from any thread.
/// </remarks>
function SdlPoint(const APoint: TPoint): TSdlPoint; overload; inline;

type
  /// <summary>
  ///  The structure that defines a point (using floating-point values).
  /// </summary>
  TSdlPointF = record
  public
    X: Single;
    Y: Single;
  public
    /// <summary>
    ///  Create from X and Y values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AX, AY: Single); overload;

    /// <summary>
    ///  Create from a TSdlPoint.
    /// </summary>
    /// <param name="APoint">The TSdlPoint.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const APoint: TSdlPoint); overload;

    /// <summary>
    ///  Create from a TPoint.
    /// </summary>
    /// <param name="APoint">The TPoint.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const APoint: TPoint); overload;

    /// <summary>
    ///  Create from a TPointF.
    /// </summary>
    /// <param name="APoint">The TPointF.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const APoint: TPointF); overload;

    /// <summary>
    ///  Initialize from X and Y values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AX, AY: Single); overload; inline;

    /// <summary>
    ///  Initialize from a TSdlPoint.
    /// </summary>
    /// <param name="APoint">The TSdlPoint.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const APoint: TSdlPoint); overload; inline;

    /// <summary>
    ///  Initialize from a TPoint.
    /// </summary>
    /// <param name="APoint">The TPoint.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const APoint: TPoint); overload; inline;

    /// <summary>
    ///  Initialize from a TPointF.
    /// </summary>
    /// <param name="APoint">The TPointF.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const APoint: TPointF); overload; inline;
  end;
  PSdlPointF = ^TSdlPointF;

/// <summary>
///  Create a TSdlPointF from X and Y values.
/// </summary>
/// <param name="AX">The X value.</param>
/// <param name="AY">The Y value.</param>
/// <returns>The point.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlPointF(const AX, AY: Single): TSdlPointF; overload; inline;

/// <summary>
///  Create a TSdlPointF from a TSdlPoint.
/// </summary>
/// <param name="APoint">The TSdlPoint.</param>
/// <returns>The point.</returns>
/// <remarks>
///  It is safe to call this constructor from any thread.
/// </remarks>
function SdlPointF(const APoint: TSdlPoint): TSdlPointF; overload; inline;

/// <summary>
///  Create a TSdlPointF from a TPoint.
/// </summary>
/// <param name="APoint">The TPoint.</param>
/// <returns>The point.</returns>
/// <remarks>
///  It is safe to call this constructor from any thread.
/// </remarks>
function SdlPointF(const APoint: TPoint): TSdlPointF; overload; inline;

/// <summary>
///  Create a TSdlPointF from a TPointF.
/// </summary>
/// <param name="APoint">The TPointF.</param>
/// <returns>The point.</returns>
/// <remarks>
///  It is safe to call this constructor from any thread.
/// </remarks>
function SdlPointF(const APoint: TPointF): TSdlPointF; overload; inline;

type
  /// <summary>
  ///  The structure that defines a size (using integers).
  /// </summary>
  TSdlSize = record
  public
    W: Integer;
    H: Integer;
  public
    /// <summary>
    ///  Create from W and H values.
    /// </summary>
    /// <param name="AW">The W value.</param>
    /// <param name="AH">The H value.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AW, AH: Integer);

    /// <summary>
    ///  Initialize from W and H values.
    /// </summary>
    /// <param name="AW">The W value.</param>
    /// <param name="AH">The H value.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AW, AH: Integer); inline;
  end;
  PSdlSize = ^TSdlSize;

/// <summary>
///  Create a TSdlSize from W and H values.
/// </summary>
/// <param name="AW">The W value.</param>
/// <param name="AH">The H value.</param>
/// <returns>The size.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlSize(const AW, AH: Integer): TSdlSize; inline;

type
  /// <summary>
  ///  The structure that defines a size (using floating-point values).
  /// </summary>
  TSdlSizeF = record
  public
    W: Single;
    H: Single;
  public
    /// <summary>
    ///  Create from W and H values.
    /// </summary>
    /// <param name="AW">The W value.</param>
    /// <param name="AH">The H value.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AW, AH: Single); overload;

    /// <summary>
    ///  Create from a TSdlSize;
    /// </summary>
    /// <param name="ASize">The size.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ASize: TSdlSize); overload;

    /// <summary>
    ///  Initialize from W and H values.
    /// </summary>
    /// <param name="AW">The W value.</param>
    /// <param name="AH">The H value.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AW, AH: Single); overload; inline;

    /// <summary>
    ///  Initialize from a TSdlSize.
    /// </summary>
    /// <param name="ASize">The size.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const ASize: TSdlSize); overload; inline;
  end;
  PSdlSizeF = ^TSdlSizeF;

/// <summary>
///  Create a TSdlSizeF from W and H values.
/// </summary>
/// <param name="AW">The W value.</param>
/// <param name="AH">The H value.</param>
/// <returns>The size.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlSizeF(const AW, AH: Single): TSdlSizeF; overload; inline;

/// <summary>
///  Create a TSdlSizeF from a TSdlSize.
/// </summary>
/// <param name="ASize">The size.</param>
/// <returns>The size.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlSizeF(const ASize: TSdlSize): TSdlSizeF; overload; inline;

type
  PSdlRect = ^TSdlRect;

  /// <summary>
  ///  A rectangle, with the origin at the upper left (using integers).
  /// </summary>
  TSdlRect = record
  {$REGION 'Internal Declarations'}
  private
    function GetIsEmpty: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    X: Integer;
    Y: Integer;
    W: Integer;
    H: Integer;
  public
    /// <summary>
    ///  Determine whether two rectangles are equal.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this operator from any thread.
    /// </remarks>
    class operator Equal(const ALeft, ARight: TSdlRect): Boolean; inline; static;

    /// <summary>
    ///  Determine whether two rectangles are not equal.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this operator from any thread.
    /// </remarks>
    class operator NotEqual(const ALeft, ARight: TSdlRect): Boolean; inline; static;
  public
    /// <summary>
    ///  Create from X, Y, W and H values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <param name="AW">The width.</param>
    /// <param name="AH">The height.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AX, AY, AW, AH: Integer); overload;

    /// <summary>
    ///  Create from a TRect.
    /// </summary>
    /// <param name="ARect">The TRect.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ARect: TRect); overload;

    /// <summary>
    ///  Initialize from X, Y, W and H values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <param name="AW">The width.</param>
    /// <param name="AH">The height.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AX, AY, AW, AH: Integer); overload; inline;

    /// <summary>
    ///  Initialize from a TRect.
    /// </summary>
    /// <param name="ARect">The TRect.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const ARect: TRect); overload; inline;

    /// <summary>
    ///  Calculate a minimal rectangle enclosing a set of points.
    ///
    ///  If `AClip` is not nil then only points inside of the clipping rectangle
    ///  are considered.
    /// </summary>
    /// <param name="APoints">An array of points to be enclosed.</param>
    /// <param name="AClip">(Optional) rect used for clipping or nil to enclose
    ///  all points.</param>
    /// <returns>True if any points were enclosed or False if all the points
    ///  were outside of the clipping rectangle.</returns>
    function InitFromEnclosingPoints(const APoints: TArray<TSdlPoint>;
      const AClip: PSdlRect = nil): Boolean; overload; inline;

    /// <summary>
    ///  Calculate a minimal rectangle enclosing a set of points.
    ///
    ///  If `AClip` is not nil then only points inside of the clipping rectangle
    ///  are considered.
    /// </summary>
    /// <param name="APoints">An array of points to be enclosed.</param>
    /// <param name="AClip">(Optional) rect used for clipping or nil to enclose
    ///  all points.</param>
    /// <returns>True if any points were enclosed or False if all the points
    ///  were outside of the clipping rectangle.</returns>
    function InitFromEnclosingPoints(const APoints: array of TSdlPoint;
      const AClip: PSdlRect = nil): Boolean; overload;

    /// <summary>
    ///  Determine whether a point resides inside the rectangle.
    ///
    ///  A point is considered part of a rectangle if `APP`'s x and y
    ///  coordinates are >= to the rectangle's top left corner,
    ///  and < the rectangle's X+W and Y+H. So a 1x1 rectangle considers point
    ///  (0, 0) as "inside" and (0, 1) as not.
    /// </summary>
    /// <param name="AP">The point to test.</param>
    /// <returns>True if `AP` is contained by this rectangle, False otherwise.</returns>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    function ContainsPoint(const AP: TSdlPoint): Boolean; inline;

    /// <summary>
    ///  Determine whether two rectangles intersect.
    /// </summary>
    /// <param name="AOther">The other rectangle.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    /// <seealso cref="Intersection"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    function Intersects(const AOther: TSdlRect): Boolean; inline;

    /// <summary>
    ///  Calculate the intersection of two rectangles.
    /// </summary>
    /// <param name="AOther">The other rectangle.</param>
    /// <param name="AIntersection">Is set to the intersection of this rectangle
    ///  and AOther.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    /// <seealso cref="Intersects"/>
    function Intersection(const AOther: TSdlRect;
      out AIntersection: TSdlRect): Boolean; inline;

    /// <summary>
    ///  Calculate the union of two rectangles.
    /// </summary>
    /// <param name="AOther">The other rectangle.</param>
    /// <param name="AUnion">Is set to the union this rectangle and AOther.</param>
    procedure Union(const AOther: TSdlRect; out AUnion: TSdlRect); inline;

    /// <summary>
    ///  Calculate the intersection of this rectangle and line segment.
    ///
    ///  This function is used to clip a line segment to a rectangle. A line segment
    ///  contained entirely within the rectangle or that does not intersect will
    ///  remain unchanged. A line segment that crosses the rectangle at either or
    ///  both ends will be clipped to the boundary of the rectangle and the new
    ///  coordinates saved in `AX1`, `AY1`, `AX2`, and/or `AY2` as necessary.
    /// </summary>
    /// <param name="AX1">The starting X-coordinate of the line.</param>
    /// <param name="AY1">The starting Y-coordinate of the line.</param>
    /// <param name="AX2">The ending X-coordinate of the line.</param>
    /// <param name="AY2">The ending Y-coordinate of the line.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    function LineIntersection(var AX1, AY1, AX2, AY2: Integer): Boolean; overload; inline;

    /// <summary>
    ///  Calculate the intersection of this rectangle and line segment.
    ///
    ///  This function is used to clip a line segment to a rectangle. A line segment
    ///  contained entirely within the rectangle or that does not intersect will
    ///  remain unchanged. A line segment that crosses the rectangle at either or
    ///  both ends will be clipped to the boundary of the rectangle and the new
    ///  coordinates saved in `AP1` and/or `AP2` as necessary.
    /// </summary>
    /// <param name="AP1">The starting point of the line.</param>
    /// <param name="AP2">The ending point of the line.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    function LineIntersection(var AP1, AP2: TSdlPoint): Boolean; overload; inline;

    /// <summary>
    ///  Whether the rectangle has no area.
    ///
    ///  A rectangle is considered "empty" for this function if it's width
    ///  and/or height are <= 0.
    /// </summary>
    /// <returns>True if the rectangle is "empty", False otherwise.</returns>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property IsEmpty: Boolean read GetIsEmpty;
  end;

/// <summary>
///  Create a TSdlRect from X, Y, W and H values.
/// </summary>
/// <param name="AX">The X value.</param>
/// <param name="AY">The Y value.</param>
/// <param name="AW">The width.</param>
/// <param name="AH">The height.</param>
/// <returns>The rect.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlRect(const AX, AY, AW, AH: Integer): TSdlRect; overload; inline;

/// <summary>
///  Create a TSdlRect from a TRect.
/// </summary>
/// <param name="ARect">The TRect.</param>
/// <returns>The rect.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlRect(const ARect: TRect): TSdlRect; overload; inline;

type
  PSdlRectF = ^TSdlRectF;

  /// <summary>
  ///  A rectangle, with the origin at the upper left (using floating-point values).
  /// </summary>
  TSdlRectF = record
  {$REGION 'Internal Declarations'}
  private
    function GetIsEmpty: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    X: Single;
    Y: Single;
    W: Single;
    H: Single;
  public
    /// <summary>
    ///  Determine whether two rectangles are equal.
    ///
    ///  Rectangles are considered equal if each of their X, Y, W and Ht are
    ///  within SDL_SINGLE_EPSILON of each other. This is often a reasonable way
    ///  to compare two floating point rectangles and deal with the slight
    ///  precision variations in floating point calculations that tend to pop
    ///  up.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this operator from any thread.
    /// </remarks>
    class operator Equal(const ALeft, ARight: TSdlRectF): Boolean; inline; static;

    /// <summary>
    ///  Determine whether two rectangles are not equal.
    ///
    ///  Rectangles are considered equal if each of their X, Y, W and Ht are
    ///  within SDL_SINGLE_EPSILON of each other. This is often a reasonable way
    ///  to compare two floating point rectangles and deal with the slight
    ///  precision variations in floating point calculations that tend to pop
    ///  up.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this operator from any thread.
    /// </remarks>
    class operator NotEqual(const ALeft, ARight: TSdlRectF): Boolean; inline; static;
  public
    /// <summary>
    ///  Create from X, Y, W and H values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <param name="AW">The width.</param>
    /// <param name="AH">The height.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AX, AY, AW, AH: Single); overload;

    /// <summary>
    ///  Create from a TSdlRect.
    /// </summary>
    /// <param name="ARect">The TSdlRect.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ARect: TSdlRect); overload;

    /// <summary>
    ///  Create from a TRect.
    /// </summary>
    /// <param name="ARect">The TRect.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ARect: TRect); overload;

    /// <summary>
    ///  Create from a TRectF.
    /// </summary>
    /// <param name="ARect">The TRectF.</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ARect: TRectF); overload;

    /// <summary>
    ///  Initialize from X, Y, W and H values.
    /// </summary>
    /// <param name="AX">The X value.</param>
    /// <param name="AY">The Y value.</param>
    /// <param name="AW">The width.</param>
    /// <param name="AH">The height.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AX, AY, AW, AH: Single); overload; inline;

    /// <summary>
    ///  Initialize from a TSdlRect.
    /// </summary>
    /// <param name="ARect">The TSdlRect.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const ARect: TSdlRect); overload; inline;

    /// <summary>
    ///  Initialize from a TRect.
    /// </summary>
    /// <param name="ARect">The TRect.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const ARect: TRect); overload; inline;

    /// <summary>
    ///  Initialize from a TRectF.
    /// </summary>
    /// <param name="ARect">The TRectF.</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const ARect: TRectF); overload; inline;

    /// <summary>
    ///  Calculate a minimal rectangle enclosing a set of points.
    ///
    ///  If `AClip` is not nil then only points inside of the clipping rectangle
    ///  are considered.
    /// </summary>
    /// <param name="APoints">An array of points to be enclosed.</param>
    /// <param name="AClip">(Optional) rect used for clipping or nil to enclose
    ///  all points.</param>
    /// <returns>True if any points were enclosed or False if all the points
    ///  were outside of the clipping rectangle.</returns>
    function InitFromEnclosingPoints(const APoints: TArray<TSdlPointF>;
      const AClip: PSdlRectF = nil): Boolean; overload; inline;

    /// <summary>
    ///  Calculate a minimal rectangle enclosing a set of points.
    ///
    ///  If `AClip` is not nil then only points inside of the clipping rectangle
    ///  are considered.
    /// </summary>
    /// <param name="APoints">An array of points to be enclosed.</param>
    /// <param name="AClip">(Optional) rect used for clipping or nil to enclose
    ///  all points.</param>
    /// <returns>True if any points were enclosed or False if all the points
    ///  were outside of the clipping rectangle.</returns>
    function InitFromEnclosingPoints(const APoints: array of TSdlPointF;
      const AClip: PSdlRectF = nil): Boolean; overload;

    /// <summary>
    ///  Determine whether two floating point rectangles are equal, within some
    ///  given epsilon.
    ///
    ///  Rectangles are considered equal if each of their X, Y, W and H are
    ///  within `AEpsilon` of each other. If you don't know what value to use
    ///  for `AEpsilon`, you should call use the '=' operator.
    /// </summary>
    /// <param name="AOther">The other rectangle to test.</param>
    /// <param name="AEpsilon">The epsilon value for comparison.</param>
    /// <returns>True if the rectangles are equal, False otherwise.</returns>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    function Equals(const AOther: TSdlRectF; const AEpsilon: Single): Boolean; inline;

    /// <summary>
    ///  Determine whether a point resides inside the rectangle.
    ///
    ///  A point is considered part of a rectangle if `APP`'s x and y
    ///  coordinates are >= to the rectangle's top left corner,
    ///  and < the rectangle's X+W and Y+H. So a 1x1 rectangle considers point
    ///  (0, 0) as "inside" and (0, 1) as not.
    /// </summary>
    /// <param name="AP">The point to test.</param>
    /// <returns>True if `AP` is contained by this rectangle, False otherwise.</returns>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    function ContainsPoint(const AP: TSdlPointF): Boolean; inline;

    /// <summary>
    ///  Determine whether two rectangles intersect.
    /// </summary>
    /// <param name="AOther">The other rectangle.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    /// <seealso cref="Intersection"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    function Intersects(const AOther: TSdlRectF): Boolean; inline;

    /// <summary>
    ///  Calculate the intersection of two rectangles.
    /// </summary>
    /// <param name="AOther">The other rectangle.</param>
    /// <param name="AIntersection">Is set to the intersection of this rectangle
    ///  and AOther.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    /// <seealso cref="Intersects"/>
    function Intersection(const AOther: TSdlRectF;
      out AIntersection: TSdlRectF): Boolean; inline;

    /// <summary>
    ///  Calculate the union of two rectangles.
    /// </summary>
    /// <param name="AOther">The other rectangle.</param>
    /// <param name="AUnion">Is set to the union this rectangle and AOther.</param>
    procedure Union(const AOther: TSdlRectF; out AUnion: TSdlRectF); inline;

    /// <summary>
    ///  Calculate the intersection of this rectangle and line segment.
    ///
    ///  This function is used to clip a line segment to a rectangle. A line segment
    ///  contained entirely within the rectangle or that does not intersect will
    ///  remain unchanged. A line segment that crosses the rectangle at either or
    ///  both ends will be clipped to the boundary of the rectangle and the new
    ///  coordinates saved in `AX1`, `AY1`, `AX2`, and/or `AY2` as necessary.
    /// </summary>
    /// <param name="AX1">The starting X-coordinate of the line.</param>
    /// <param name="AY1">The starting Y-coordinate of the line.</param>
    /// <param name="AX2">The ending X-coordinate of the line.</param>
    /// <param name="AY2">The ending Y-coordinate of the line.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    function LineIntersection(var AX1, AY1, AX2, AY2: Single): Boolean; overload; inline;

    /// <summary>
    ///  Calculate the intersection of this rectangle and line segment.
    ///
    ///  This function is used to clip a line segment to a rectangle. A line segment
    ///  contained entirely within the rectangle or that does not intersect will
    ///  remain unchanged. A line segment that crosses the rectangle at either or
    ///  both ends will be clipped to the boundary of the rectangle and the new
    ///  coordinates saved in `AP1` and/or `AP2` as necessary.
    /// </summary>
    /// <param name="AP1">The starting point of the line.</param>
    /// <param name="AP2">The ending point of the line.</param>
    /// <returns>True if there is an intersection, False otherwise.</returns>
    function LineIntersection(var AP1, AP2: TSdlPointF): Boolean; overload; inline;

    /// <summary>
    ///  Whether the rectangle has no area.
    ///
    ///  A rectangle is considered "empty" for this function if it's width
    ///  and/or height are <= 0.
    /// </summary>
    /// <returns>True if the rectangle is "empty", False otherwise.</returns>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property IsEmpty: Boolean read GetIsEmpty;
  end;

/// <summary>
///  Create a TSdlRectF from X, Y, W and H values.
/// </summary>
/// <param name="AX">The X value.</param>
/// <param name="AY">The Y value.</param>
/// <param name="AW">The width.</param>
/// <param name="AH">The height.</param>
/// <returns>The rect.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlRectF(const AX, AY, AW, AH: Single): TSdlRectF; overload; inline;

/// <summary>
///  Create a TSdlRectF from a TSdlRect.
/// </summary>
/// <param name="ARect">The TSdlRect.</param>
/// <returns>The rect.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlRectF(const ARect: TSdlRect): TSdlRectF; overload; inline;

/// <summary>
///  Create a TSdlRectF from a TRect.
/// </summary>
/// <param name="ARect">The TRect.</param>
/// <returns>The rect.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlRectF(const ARect: TRect): TSdlRectF; overload; inline;

/// <summary>
///  Create a TSdlRectF from a TRectF.
/// </summary>
/// <param name="ARect">The TRectF.</param>
/// <returns>The rect.</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlRectF(const ARect: TRectF): TSdlRectF; overload; inline;
{$ENDREGION 'Points and Rectangles'}

{$REGION 'Pixel Formats and Conversion Routines'}
/// <summary>
///  SDL offers facilities for pixel management.
///
///  Largely these facilities deal with pixel _format_: what does this set of
///  bits represent?
///
///  If you mostly want to think of a pixel as some combination of red, green,
///  blue, and maybe alpha intensities, this is all pretty straightforward, and
///  in many cases, is enough information to build a perfectly fine game.
///
///  However, the actual definition of a pixel is more complex than that:
///
///  Pixels are a representation of a color in a particular color space.
///
///  The first characteristic of a color space is the color type. SDL
///  understands two different color types, RGB and YCbCr, or in SDL also
///  referred to as YUV.
///
///  RGB colors consist of red, green, and blue channels of color that are added
///  together to represent the colors we see on the screen.
///
///  See <see href="https://en.wikipedia.org/wiki/RGB_color_model">RGB color model</see>.
///
///  YCbCr colors represent colors as a Y luma brightness component and red and
///  blue chroma color offsets. This color representation takes advantage of the
///  fact that the human eye is more sensitive to brightness than the color in
///  an image. The Cb and Cr components are often compressed and have lower
///  resolution than the luma component.
///
///  See <see href="https://en.wikipedia.org/wiki/YCbCr">YCbCr</see>.
///
///  When the color information in YCbCr is compressed, the Y pixels are left at
///  full resolution and each Cr and Cb pixel represents an average of the color
///  information in a block of Y pixels. The chroma location determines where in
///  that block of pixels the color information is coming from.
///
///  The color range defines how much of the pixel to use when converting a
///  pixel into a color on the display. When the full color range is used, the
///  entire numeric range of the pixel bits is significant. When narrow color
///  range is used, for historical reasons, the pixel uses only a portion of the
///  numeric range to represent colors.
///
///  The color primaries and white point are a definition of the colors in the
///  color space relative to the standard XYZ color space.
///
///  See <see href="https://en.wikipedia.org/wiki/CIE_1931_color_space">CIE 1931 color space</see>.
///
///  The transfer characteristic, or opto-electrical transfer function (OETF),
///  is the way a color is converted from mathematically linear space into a
///  non-linear output signals.
///
///  See <see href="https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics">Rec. 708</see>.
///
///  The matrix coefficients are used to convert between YCbCr and RGB colors.
/// </summary>

const
  /// <summary>
  ///  A fully opaque 8-bit alpha value.
  /// </summary>
  /// <seealso cref="SDL_ALPHA_TRANSPARENT"/>
  SDL_ALPHA_OPAQUE            = 255;

  /// <summary>
  ///  A fully opaque floating point alpha value.
  /// </summary>
  /// <seealso cref="SDL_ALPHA_TRANSPARENT_FLOAT"/>
  SDL_ALPHA_OPAQUE_FLOAT      = 1.0;

  /// <summary>
  ///  A fully transparent 8-bit alpha value.
  /// </summary>
  /// <seealso cref="SDL_ALPHA_OPAQUE"/>
  SDL_ALPHA_TRANSPARENT       = 0;

  /// <summary>
  ///  A fully transparent floating point alpha value.
  /// </summary>
  /// <seealso cref="SDL_ALPHA_OPAQUE_FLOAT"/>
  SDL_ALPHA_TRANSPARENT_FLOAT = 0.0;

type
  /// <summary>
  ///  A structure that represents a color as 8-bit RGBA components.
  ///
  ///  The bits of this structure can be directly reinterpreted as an
  ///  integer-packed color which uses the TSdlPixelFormat.Rgba32 format
  ///  (TSdlPixelFormat.Abgr8888 on little-endian systems and
  ///  TSdlPixelFormat.Rgba8888 on big-endian systems).
  /// </summary>
  TSdlColor = packed record
  public
    R: Byte;
    G: Byte;
    B: Byte;
    A: Byte;
  public
    /// <summary>
    ///  Create a color.
    /// </summary>
    /// <param name="AR">The red value.</param>
    /// <param name="AG">The green value.</param>
    /// <param name="AB">The blue value.</param>
    /// <param name="AA">(Optional) alpha value. Defaults to 255</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AR, AG, AB: Byte; const AA: Byte = 255);

    /// <summary>
    ///  Initializes the a color.
    /// </summary>
    /// <param name="AR">The red value.</param>
    /// <param name="AG">The green value.</param>
    /// <param name="AB">The blue value.</param>
    /// <param name="AA">(Optional) alpha value. Defaults to 255</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AR, AG, AB: Byte; const AA: Byte = 255); inline;
  end;
  {$POINTERMATH ON}
  PSdlColor = ^TSdlColor;
  {$POINTERMATH OFF}

/// <summary>
///  Create a color.
/// </summary>
/// <param name="AR">The red value.</param>
/// <param name="AG">The green value.</param>
/// <param name="AB">The blue value.</param>
/// <param name="AA">(Optional) alpha value. Defaults to 255</param>
/// <returns>The color</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlColor(const AR, AG, AB: Byte; const AA: Byte = 255): TSdlColor; inline;

type
  /// <summary>
  ///  A structure that represents a color as floating-point RGBA components.
  ///
  ///  The bits of this structure can be directly reinterpreted as a float-packed
  ///  color which uses the TSdlPixelFormat.Rgba128Float format.
  /// </summary>
  TSdlColorF = record
  public
    R: Single;
    G: Single;
    B: Single;
    A: Single;
  public
    /// <summary>
    ///  Create a color.
    /// </summary>
    /// <param name="AR">The red value.</param>
    /// <param name="AG">The green value.</param>
    /// <param name="AB">The blue value.</param>
    /// <param name="AA">(Optional) alpha value. Defaults to 1.0</param>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const AR, AG, AB: Single; const AA: Single = 1);

    /// <summary>
    ///  Initializes the a color.
    /// </summary>
    /// <param name="AR">The red value.</param>
    /// <param name="AG">The green value.</param>
    /// <param name="AB">The blue value.</param>
    /// <param name="AA">(Optional) alpha value. Defaults to 1.0</param>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure Init(const AR, AG, AB: Single; const AA: Single = 1); inline;
  end;
  PSdlColorF = ^TSdlColorF;

/// <summary>
///  Create a color.
/// </summary>
/// <param name="AR">The red value.</param>
/// <param name="AG">The green value.</param>
/// <param name="AB">The blue value.</param>
/// <param name="AA">(Optional) alpha value. Defaults to 255</param>
/// <returns>The color</returns>
/// <remarks>
///  It is safe to call this function from any thread.
/// </remarks>
function SdlColorF(const AR, AG, AB: Single; const AA: Single = 1): TSdlColorF; inline;

type
  /// <summary>
  ///  A set of indexed colors representing a palette.
  /// </summary>
  TSdlPalette = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PSDL_Palette;
    function GetNumColors: Integer; inline;
    function GetColors: PSdlColor; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlPalette; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlPalette.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlPalette): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlPalette; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlPalette.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlPalette): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlPalette; inline; static;
  public
    /// <summary>
    ///  Create a palette with the specified number of color entries.
    ///
    ///  The palette entries are initialized to white.
    /// </summary>
    /// <param name="ANumColors">The number of color entries in the color palette.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="SetColors"/>
    /// <seealso cref="TSdlSurface.Palette"/>
    /// <remarks>
    ///  It is safe to call this constructor from any thread.
    /// </remarks>
    constructor Create(const ANumColors: Integer);

    /// <summary>
    ///  Free the palette.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified or destroyed in another thread.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Set a range of colors in a palette.
    /// </summary>
    /// <param name="AColors">A array of TSdlColor record to copy into the palette.</param>
    /// <param name="AFirstColor">(Optional) index of the first palette entry to modify.</param>
    /// <param name="ANumColors">(Optional) number of entries to modify.
    ///  Use 0 (default) to se the length of AColors.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified or destroyed in another thread.
    /// </remarks>
    procedure SetColors(const AColors: TArray<TSdlColor>;
      const AFirstColor: Integer = 0; const ANumColors: Integer = 0); overload; inline;

    /// <summary>
    ///  Set a range of colors in a palette.
    /// </summary>
    /// <param name="AColors">A array of TSdlColor record to copy into the palette.</param>
    /// <param name="AFirstColor">(Optional) index of the first palette entry to modify.</param>
    /// <param name="ANumColors">(Optional) number of entries to modify.
    ///  Use 0 (default) to se the length of AColors.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified or destroyed in another thread.
    /// </remarks>
    procedure SetColors(const AColors: array of TSdlColor;
      const AFirstColor: Integer = 0; const ANumColors: Integer = 0); overload;

    /// <summary>Number of elements in `Colors`.</summary>
    property NumColors: Integer read GetNumColors;

    /// <summary>Pointer to an array of colors, `NumColors` long.</summary>
    property Colors: PSdlColor read GetColors;
  end;

type
  /// <summary>
  ///  Pixel type.
  /// </summary>
  TSdlPixelType = (
    Unknown  = SDL_PIXELTYPE_UNKNOWN,
    Index1   = SDL_PIXELTYPE_INDEX1,
    Index2   = SDL_PIXELTYPE_INDEX2,
    Index4   = SDL_PIXELTYPE_INDEX4,
    Index8   = SDL_PIXELTYPE_INDEX8,
    Packed8  = SDL_PIXELTYPE_PACKED8,
    Packed16 = SDL_PIXELTYPE_PACKED16,
    Packed32 = SDL_PIXELTYPE_PACKED32,
    ArrayU8  = SDL_PIXELTYPE_ARRAYU8,
    ArrayU16 = SDL_PIXELTYPE_ARRAYU16,
    ArrayU32 = SDL_PIXELTYPE_ARRAYU32,
    ArrayF16 = SDL_PIXELTYPE_ARRAYF16,
    ArrayF32 = SDL_PIXELTYPE_ARRAYF32);

type
  /// <summary>
  ///  Bitmap pixel order, high bit -> low bit.
  /// </summary>
  TSdlBitmapOrder = (
    None      = SDL_BITMAPORDER_NONE,
    Order4321 = SDL_BITMAPORDER_4321,
    Order1234 = SDL_BITMAPORDER_1234);

type
  /// <summary>
  ///  Packed component order, high bit -> low bit.
  /// </summary>
  TSdlPackedOrder = (
    None = SDL_PACKEDORDER_NONE,
    Xrgb = SDL_PACKEDORDER_XRGB,
    Rgbx = SDL_PACKEDORDER_RGBX,
    Argb = SDL_PACKEDORDER_ARGB,
    Rgba = SDL_PACKEDORDER_RGBA,
    Xbgr = SDL_PACKEDORDER_XBGR,
    Bgrx = SDL_PACKEDORDER_BGRX,
    Abgr = SDL_PACKEDORDER_ABGR,
    Bgra = SDL_PACKEDORDER_BGRA);

type
  /// <summary>
  ///  Array component order, low byte -> high byte.
  /// </summary>
  TSdlArrayOrder = (
    None = SDL_ARRAYORDER_NONE,
    Rgb  = SDL_ARRAYORDER_RGB,
    Rgba = SDL_ARRAYORDER_RGBA,
    Argb = SDL_ARRAYORDER_ARGB,
    Bgr  = SDL_ARRAYORDER_BGR,
    Bgra = SDL_ARRAYORDER_BGRA,
    Abgr = SDL_ARRAYORDER_ABGR);

type
  /// <summary>
  ///  Packed component layout.
  /// </summary>
  TSdlPackedLayout = (
    None          = SDL_PACKEDLAYOUT_NONE,
    Layout332     = SDL_PACKEDLAYOUT_332,
    Layout4444    = SDL_PACKEDLAYOUT_4444,
    Layout1555    = SDL_PACKEDLAYOUT_1555,
    Layout5551    = SDL_PACKEDLAYOUT_5551,
    Layout565     = SDL_PACKEDLAYOUT_565,
    Layout8888    = SDL_PACKEDLAYOUT_8888,
    Layout2101010 = SDL_PACKEDLAYOUT_2101010,
    Layout1010102 = SDL_PACKEDLAYOUT_1010102);

type
  /// <summary>
  ///  Pixel format.
  ///
  ///  SDL's pixel formats have the following naming convention:
  ///
  ///  - Names with a list of components and a single bit count, such as Rgb24 and
  ///  Abgr32, define a platform-independent encoding into bytes in the order
  ///  specified. For example, in Rgb24 data, each pixel is encoded in 3 bytes
  ///  (red, green, blue) in that order, and in Abgr32 data, each pixel is
  ///  encoded in 4 bytes alpha, blue, green, red) in that order. Use these
  ///  names if the property of a format that is important to you is the order
  ///  of the bytes in memory or on disk.
  ///  - Names with a bit count per component, such as Argb8888 and Xrgb1555, are
  ///  "packed" into an appropriately-sized integer in the platform's native
  ///  endianness. For example, Argb8888 is a sequence of 32-bit integers; in
  ///  each integer, the most significant bits are alpha, and the least
  ///  significant bits are blue. On a little-endian CPU such as x86, the least
  ///  significant bits of each integer are arranged first in memory, but on a
  ///  big-endian CPU such as s390x, the most significant bits are arranged
  ///  first. Use these names if the property of a format that is important to
  ///  you is the meaning of each bit position within a native-endianness
  ///  integer.
  ///  - In indexed formats such as Index4Lsb, each pixel is represented by
  ///  encoding an index into the palette into the indicated number of bits,
  ///  with multiple pixels packed into each byte if appropriate. In Lsb
  ///  formats, the first (leftmost) pixel is stored in the least-significant
  ///  bits of the byte; in Msb formats, it's stored in the most-significant
  ///  bits. Index8 does not need Lsb/Msb variants, because each pixel exactly
  ///  fills one byte.
  ///
  ///  The 32-bit byte-array encodings such as Rgba32 are aliases for the
  ///  appropriate 8888 encoding for the current platform. For example, Rgba32 is
  ///  an alias for Abgr8888 on little-endian CPUs like x86, or an alias for
  ///  Rgba8888 on big-endian CPUs.
  /// </summary>
  TSdlPixelFormat = (
    Unknown      = SDL_PIXELFORMAT_UNKNOWN,
    Index1Lsb    = SDL_PIXELFORMAT_INDEX1LSB,
    Index1Msb    = SDL_PIXELFORMAT_INDEX1MSB,
    Index2Lsb    = SDL_PIXELFORMAT_INDEX2LSB,
    Index2Msb    = SDL_PIXELFORMAT_INDEX2MSB,
    Index4Lsb    = SDL_PIXELFORMAT_INDEX4LSB,
    Index4Msb    = SDL_PIXELFORMAT_INDEX4MSB,
    Index8       = SDL_PIXELFORMAT_INDEX8,
    Rgb332       = SDL_PIXELFORMAT_RGB332,
    Xrgb4444     = SDL_PIXELFORMAT_XRGB4444,
    Xbgr4444     = SDL_PIXELFORMAT_XBGR4444,
    Xrgb1555     = SDL_PIXELFORMAT_XRGB1555,
    Xbgr1555     = SDL_PIXELFORMAT_XBGR1555,
    Argb4444     = SDL_PIXELFORMAT_ARGB4444,
    Rgba4444     = SDL_PIXELFORMAT_RGBA4444,
    Abgr4444     = SDL_PIXELFORMAT_ABGR4444,
    Bgra4444     = SDL_PIXELFORMAT_BGRA4444,
    Argb1555     = SDL_PIXELFORMAT_ARGB1555,
    Rgba5551     = SDL_PIXELFORMAT_RGBA5551,
    Abgr1555     = SDL_PIXELFORMAT_ABGR1555,
    Bgra5551     = SDL_PIXELFORMAT_BGRA5551,
    Rgb565       = SDL_PIXELFORMAT_RGB565,
    Bgr565       = SDL_PIXELFORMAT_BGR565,
    Rgb24        = SDL_PIXELFORMAT_RGB24,
    Bgr24        = SDL_PIXELFORMAT_BGR24,
    Xrgb8888     = SDL_PIXELFORMAT_XRGB8888,
    Rgbx8888     = SDL_PIXELFORMAT_RGBX8888,
    Xbgr8888     = SDL_PIXELFORMAT_XBGR8888,
    Bgrx8888     = SDL_PIXELFORMAT_BGRX8888,
    Argb8888     = SDL_PIXELFORMAT_ARGB8888,
    Rgba8888     = SDL_PIXELFORMAT_RGBA8888,
    Abgr8888     = SDL_PIXELFORMAT_ABGR8888,
    Bgra8888     = SDL_PIXELFORMAT_BGRA8888,
    Xrgb2101010  = SDL_PIXELFORMAT_XRGB2101010,
    Xbgr2101010  = SDL_PIXELFORMAT_XBGR2101010,
    Argb2101010  = SDL_PIXELFORMAT_ARGB2101010,
    Abgr2101010  = SDL_PIXELFORMAT_ABGR2101010,
    Rgb48        = SDL_PIXELFORMAT_RGB48,
    Bgr48        = SDL_PIXELFORMAT_BGR48,
    Rgba64       = SDL_PIXELFORMAT_RGBA64,
    Argb64       = SDL_PIXELFORMAT_ARGB64,
    Bgra64       = SDL_PIXELFORMAT_BGRA64,
    Abgr64       = SDL_PIXELFORMAT_ABGR64,
    Rgb48Float   = SDL_PIXELFORMAT_RGB48_FLOAT,
    Bgr48Float   = SDL_PIXELFORMAT_BGR48_FLOAT,
    Rgba64Float  = SDL_PIXELFORMAT_RGBA64_FLOAT,
    Argb64Float  = SDL_PIXELFORMAT_ARGB64_FLOAT,
    Bgra64Float  = SDL_PIXELFORMAT_BGRA64_FLOAT,
    Abgr64Float  = SDL_PIXELFORMAT_ABGR64_FLOAT,
    Rgb96Float   = SDL_PIXELFORMAT_RGB96_FLOAT,
    Bgr96Float   = SDL_PIXELFORMAT_BGR96_FLOAT,
    Rgba128Float = SDL_PIXELFORMAT_RGBA128_FLOAT,
    Argb128Float = SDL_PIXELFORMAT_ARGB128_FLOAT,
    Bgra128Float = SDL_PIXELFORMAT_BGRA128_FLOAT,
    Abgr128Float = SDL_PIXELFORMAT_ABGR128_FLOAT,

    /// <summary>Planar mode: Y + V + U  (3 planes)</summary>
    Yv12         = SDL_PIXELFORMAT_YV12,

    /// <summary>Planar mode: Y + U + V  (3 planes)</summary>
    Iyuv         = SDL_PIXELFORMAT_IYUV,

    /// <summary>Packed mode: Y0+U0+Y1+V0 (1 plane)</summary>
    Yuy2         = SDL_PIXELFORMAT_YUY2,

    /// <summary>Packed mode: U0+Y0+V0+Y1 (1 plane)</summary>
    Uyvy         = SDL_PIXELFORMAT_UYVY,

    /// <summary>Packed mode: Y0+V0+Y1+U0 (1 plane)</summary>
    Yvyu         = SDL_PIXELFORMAT_YVYU,

    /// <summary>Planar mode: Y + U/V interleaved  (2 planes)</summary>
    Nv12         = SDL_PIXELFORMAT_NV12,

    /// <summary>Planar mode: Y + V/U interleaved  (2 planes)</summary>
    Nv21         = SDL_PIXELFORMAT_NV21,

    /// <summary>Planar mode: Y + U/V interleaved  (2 planes)</summary>
    P010         = SDL_PIXELFORMAT_P010,

    /// <summary>Android video texture format</summary>
    ExternalOes  = SDL_PIXELFORMAT_EXTERNAL_OES,

    Rgba32       = SDL_PIXELFORMAT_RGBA32,
    Argb32       = SDL_PIXELFORMAT_ARGB32,
    Bgra32       = SDL_PIXELFORMAT_BGRA32,
    Abgr32       = SDL_PIXELFORMAT_ABGR32,
    Rgbx32       = SDL_PIXELFORMAT_RGBX32,
    Xrgb32       = SDL_PIXELFORMAT_XRGB32,
    Bgrx32       = SDL_PIXELFORMAT_BGRX32,
    Xbgr32       = SDL_PIXELFORMAT_XBGR32);

type
  /// <summary>
  ///  Details about the format of a pixel.
  /// </summary>
  TSdlPixelFormatDetails = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_PixelFormatDetails;
    function GetFormat: TSdlPixelFormat; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Map an RGB triple to an opaque pixel value for this given pixel format.
    ///
    ///  This function maps the RGB color value to the specified pixel format and
    ///  returns the pixel value best approximating the given RGB color value for
    ///  the given pixel format.
    ///
    ///  If the format has a palette (8-bit) the index of the closest matching color
    ///  in the palette will be returned.
    ///
    ///  If the specified pixel format has an alpha component it will be returned as
    ///  all 1 bits (fully opaque).
    ///
    ///  If the pixel format bpp (color depth) is less than 32-bpp then the unused
    ///  upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    ///  format the return value can be assigned to a UInt16, and similarly a UInt8
    ///  for an 8-bpp format).
    /// </summary>
    /// <param name="APalette">(Optional) palette for indexed formats, may be nil.</param>
    /// <param name="AR">The red component of the pixel in the range 0-255.</param>
    /// <param name="AG">The green component of the pixel in the range 0-255.</param>
    /// <param name="AB">The blue component of the pixel in the range 0-255.</param>
    /// <returns>A pixel value.</returns>
    /// <seealso cref="TSdlPixelFormat.Details"/>
    /// <seealso cref="GetRgb"/>
    /// <seealso cref="MapRgba"/>
    /// <seealso cref="TSdlSurface.MapRgb"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified.
    /// </remarks>
    function MapRgb(const AR, AG, AB: Byte): Cardinal; overload; inline;
    function MapRgb(const APalette: TSdlPalette; const AR, AG, AB: Byte): Cardinal; overload; inline;

    /// <summary>
    ///  Map an RGBA quadruple to a pixel value for this pixel format.
    ///
    ///  This function maps the RGBA color value to the specified pixel format and
    ///  returns the pixel value best approximating the given RGBA color value for
    ///  the given pixel format.
    ///
    ///  If the specified pixel format has no alpha component the alpha value will
    ///  be ignored (as it will be in formats with a palette).
    ///
    ///  If the format has a palette (8-bit) the index of the closest matching color
    ///  in the palette will be returned.
    ///
    ///  If the pixel format bpp (color depth) is less than 32-bpp then the unused
    ///  upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    ///  format the return value can be assigned to a UInt16, and similarly a UInt8
    ///  for an 8-bpp format).
    /// </summary>
    /// <param name="APalette">(Optional) palette for indexed formats, may be nil.</param>
    /// <param name="AR">The red component of the pixel in the range 0-255.</param>
    /// <param name="AG">The green component of the pixel in the range 0-255.</param>
    /// <param name="AB">The blue component of the pixel in the range 0-255.</param>
    /// <param name="AA">The alpha component of the pixel in the range 0-255.</param>
    /// <returns>A pixel value.</returns>
    /// <seealso cref="TSdlPixelFormat.Details"/>
    /// <seealso cref="GetRgba"/>
    /// <seealso cref="MapRgb"/>
    /// <seealso cref="TSdlSurface.MapRgba"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified.
    /// </remarks>
    function MapRgba(const AR, AG, AB, AA: Byte): Cardinal; overload; inline;
    function MapRgba(const APalette: TSdlPalette; const AR, AG, AB, AA: Byte): Cardinal; overload; inline;

    /// <summary>
    ///  Get RGB values from a pixel in this format.
    ///
    ///  This function uses the entire 8-bit [0..255] range when converting color
    ///  components from pixel formats with less than 8-bits per RGB component
    ///  (e.g., a completely white pixel in 16-bit RGB565 format would return
    ///  [$ff, $ff, $ff] not [$f8, $fc, $f8]).
    /// </summary>
    /// <param name="APixel">A pixel value.</param>
    /// <param name="APalette">(Optional) palette for indexed formats, may be nil.</param>
    /// <param name="AR">Is set to the red component.</param>
    /// <param name="AG">Is set to the green component.</param>
    /// <param name="AB">Is set to the blue component.</param>
    /// <seealso cref="TSdlPixelFormat.Details"/>
    /// <seealso cref="GetRgba"/>
    /// <seealso cref="MapRgb"/>
    /// <seealso cref="MapRgba"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified.
    /// </remarks>
    procedure GetRgb(const APixel: Cardinal; out AR, AG, AB: Byte); overload; inline;
    procedure GetRgb(const APixel: Cardinal; const APalette: TSdlPalette;
      out AR, AG, AB: Byte); overload; inline;

    /// <summary>
    ///  Get RGBA values from a pixel in the specified format.
    ///
    ///  This function uses the entire 8-bit [0..255] range when converting color
    ///  components from pixel formats with less than 8-bits per RGB component
    ///  (e.g., a completely white pixel in 16-bit RGB565 format would return
    ///  [$ff, $ff, $ff] not [$f8, $fc, $f8]).
    ///
    ///  If the surface has no alpha component, the alpha will be returned as $ff
    ///  (100% opaque).
    /// </summary>
    /// <param name="APixel">A pixel value.</param>
    /// <param name="APalette">(Optional) palette for indexed formats, may be nil.</param>
    /// <param name="AR">Is set to the red component.</param>
    /// <param name="AG">Is set to the green component.</param>
    /// <param name="AB">Is set to the blue component.</param>
    /// <param name="AA">Is set to the alpha component.</param>
    /// <seealso cref="TSdlPixelFormat.Details"/>
    /// <seealso cref="GetRgb"/>
    /// <seealso cref="MapRgb"/>
    /// <seealso cref="MapRgba"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, as long as the palette
    ///  is not modified.
    /// </remarks>
    procedure GetRgba(const APixel: Cardinal; out AR, AG, AB, AA: Byte); overload; inline;
    procedure GetRgba(const APixel: Cardinal; const APalette: TSdlPalette;
      out AR, AG, AB, AA: Byte); overload; inline;

    property Format: TSdlPixelFormat read GetFormat;
    property BitsPerPixel: Byte read FHandle.bits_per_pixel;
    property BytesPerPixel: Byte read FHandle.bytes_per_pixel;
    property RMask: Cardinal read FHandle.Rmask;
    property GMask: Cardinal read FHandle.Gmask;
    property BMask: Cardinal read FHandle.Bmask;
    property AMask: Cardinal read FHandle.Amask;
    property RBits: Byte read FHandle.Rbits;
    property GBits: Byte read FHandle.Gbits;
    property BBits: Byte read FHandle.Bbits;
    property ABits: Byte read FHandle.Abits;
    property RShift: Byte read FHandle.Rshift;
    property GShift: Byte read FHandle.Gshift;
    property BShift: Byte read FHandle.Bshift;
    property AShift: Byte read FHandle.Ashift;
  end;

type
  _TSdlPixelFormatHelper = record helper for TSdlPixelFormat
  {$REGION 'Internal Declarations'}
  private
    function GetPixelType: TSdlPixelType; inline;
    function GetBitmapOrder: TSdlBitmapOrder; inline;
    function GetPackedOrder: TSdlPackedOrder; inline;
    function GetArrayOrder: TSdlArrayOrder; inline;
    function GetLayout: TSdlPackedLayout; inline;
    function GetBitsPerPixel: Integer; inline;
    function GetBytesPerPixel: Integer; inline;
    function GetIsIndexed: Boolean; inline;
    function GetIsPacked: Boolean; inline;
    function GetIsArray: Boolean; inline;
    function GetIs10Bit: Boolean; inline;
    function GetIsFloat: Boolean; inline;
    function GetHasAlpha: Boolean; inline;
    function GetIsFourCC: Boolean; inline;
    function GetName: String; inline;
    function GetDetails: TSdlPixelFormatDetails; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Define a custom FourCC pixel format.
    ///
    ///  For example, defining TSdlPixelFormat.YV12 looks like this:
    ///
    ///  ```delphi
    ///  var PixelFormat := TSdlPixelFormat.From('Y', 'V', '1', '2')
    ///  ```
    /// </summary>
    /// <param name="AA">The first character of the FourCC code.</param>
    /// <param name="AB">The second character of the FourCC code.</param>
    /// <param name="AC">The third character of the FourCC code.</param>
    /// <param name="AD">The fourth character of the FourCC code.</param>
    /// <returns>The custom pixel format.</returns>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    class function From(const AA, AB, AC, AD: Char): TSdlPixelFormat; overload; inline; static;

    /// <summary>
    ///  Define a custom non-FourCC pixel formats.
    ///
    ///  For example, defining TSdlPixelFormat.Rgba8888 looks like this:
    ///
    ///  ```delphi
    ///  var PixelFormat := TSdlPixelFormat.From(TSdlPixelType.Packed32,
    ///    TSdlPackedOrder.Rgba, TSdlPackedLayout.Layout8888, 32, 4);
    ///  ```
    /// </summary>
    /// <param name="AType">The type of the new format.</param>
    /// <param name="AOrder">The order of the new format (of type TSdlBitmapOrder,
    ///  TSdlPackedOrder or TSdlArrayOrder).</param>
    /// <param name="ALayout">The layout of the new format or None.</param>
    /// <param name="ABits">The number of bits per pixel of the new format.</param>
    /// <param name="ABytes">The number of bytes per pixel of the new format.</param>
    /// <returns>The custom pixel format.</returns>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    class function From(const AType: TSdlPixelType; const AOrder: TSdlBitmapOrder;
      const ALayout: TSdlPackedLayout; const ABits, ABytes: Integer): TSdlPixelFormat; overload; inline; static;
    class function From(const AType: TSdlPixelType; const AOrder: TSdlPackedOrder;
      const ALayout: TSdlPackedLayout; const ABits, ABytes: Integer): TSdlPixelFormat; overload; inline; static;
    class function From(const AType: TSdlPixelType; const AOrder: TSdlArrayOrder;
      const ALayout: TSdlPackedLayout; const ABits, ABytes: Integer): TSdlPixelFormat; overload; inline; static;

    /// <summary>
    ///  Convert a bpp value and RGBA masks to a pixel format.
    ///
    ///  This will return `TSdlPixelFormat.Unknown` if the conversion wasn't
    ///  possible.
    /// </summary>
    /// <param name="ABpp">A bits per pixel value; usually 15, 16, or 32.</param>
    /// <param name="ARMask">The red mask for the format.</param>
    /// <param name="AGMask">The green mask for the format.</param>
    /// <param name="ABMask">The blue mask for the format.</param>
    /// <param name="AAMask">The alpha mask for the format.</param>
    /// <returns>The pixel format corresponding to the format masks, or
    ///  TSdlPixelFormat.Unknown if there isn't a match.</returns>
    /// <seealso cref="GetMasks"/>
    /// <remarks>
    ///  It is safe to call this function method any thread.
    /// </remarks>
    class function FromMasks(const ABpp: Integer; const ARMask, AGMask, ABMask,
      AAMask: Cardinal): TSdlPixelFormat; inline; static;

    /// <summary>
    ///  Convert the pixel formats to a bpp value and RGBA masks.
    /// </summary>
    /// <param name="ABpp">Is set to the bits per pixel value; usually 15, 16, or 32.</param>
    /// <param name="ARMask">Is set to the red mask for the format.</param>
    /// <param name="AGMask">Is set to the green mask for the format.</param>
    /// <param name="ABMask">Is set to the blue mask for the format.</param>
    /// <param name="AAMask">Is set to the alpha mask for the format.</param>
    /// <seealso cref="FromMasks"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure GetMasks(out ABpp: Integer; out ARMask, AGMask, ABMask,
      AAMask: Cardinal); inline;

    /// <summary>
    ///  The pixel type of this pixel format.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property PixelType: TSdlPixelType read GetPixelType;

    /// <summary>
    ///  The bitmap order of this pixel format or None if it isn't applicable.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property BitmapOrder: TSdlBitmapOrder read GetBitmapOrder;

    /// <summary>
    ///  The packed order of this pixel format or None if it isn't applicable.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property PackedOrder: TSdlPackedOrder read GetPackedOrder;

    /// <summary>
    ///  The array order of this pixel format or None if it isn't applicable.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property ArrayOrder: TSdlArrayOrder read GetArrayOrder;

    /// <summary>
    ///  The layout of this pixel format or None if it isn't applicable.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Layout: TSdlPackedLayout read GetLayout;

    /// <summary>
    ///  The format's bits per pixel.
    ///
    ///  FourCC formats will report zero here, as it rarely makes sense to measure
    ///  them per-pixel.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property BitsPerPixel: Integer read GetBitsPerPixel;

    /// <summary>
    ///  The format's bytes per pixel.
    ///
    ///  FourCC formats do their best here, but many of them don't have a meaningful
    ///  measurement of bytes per pixel.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property BytesPerPixel: Integer read GetBytesPerPixel;

    /// <summary>
    ///  Whether this is an indexed format.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsIndexed: Boolean read GetIsIndexed;

    /// <summary>
    ///  Whether this is a packed format.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsPacked: Boolean read GetIsPacked;

    /// <summary>
    ///  Whether this is an array format.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsArray: Boolean read GetIsArray;

    /// <summary>
    ///  Whether this is a 10-bit format.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Is10Bit: Boolean read GetIs10Bit;

    /// <summary>
    ///  Whether this is a floating-point format.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsFloat: Boolean read GetIsFloat;

    /// <summary>
    ///  Whether this format has an alpha channel.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property HasAlpha: Boolean read GetHasAlpha;

    /// <summary>
    ///  Whether this is a "FourCC format.
    ///  This covers custom and other unusual formats.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsFourCC: Boolean read GetIsFourCC;

    /// <summary>
    ///  The human readable name of this pixel format, or
    ///  'SDL_PIXELFORMAT_UNKNOWN' if the format isn't recognized.
    /// </summary>
    /// <param name="AFormat">the pixel format to query.</param>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  The details of this pixel format.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Details: TSdlPixelFormatDetails read GetDetails;
  end;

type
  /// <summary>
  ///  Colorspace color type.
  /// </summary>
  /// <remarks>
  ///  This enum is available since SDL 3.2.0.
  /// </remarks>
  TSdlColorType = (
    Unknown = SDL_COLOR_TYPE_UNKNOWN,
    Rgb     = SDL_COLOR_TYPE_RGB,
    YCbCr   = SDL_COLOR_TYPE_YCBCR);

type
  /// <summary>
  ///  Colorspace color range, as described by
  ///  <see href="https://www.itu.int/rec/R-REC-BT.2100-2-201807-I/en">BT.2100</see>.
  /// </summary>
  TSdlColorRange = (
    Unknown = SDL_COLOR_RANGE_UNKNOWN,

    /// <summary>Narrow range, e.g. 16-235 for 8-bit RGB and luma,
    ///  and 16-240 for 8-bit chroma</summary>
    Limited = SDL_COLOR_RANGE_LIMITED,

    /// <summary>Full range, e.g. 0-255 for 8-bit RGB and luma,
    ///  and 1-255 for 8-bit chroma</summary>
    Full    = SDL_COLOR_RANGE_FULL);

type
  /// <summary>
  ///  Colorspace color primaries, as described by
  ///  <see href="https://www.itu.int/rec/T-REC-H.273-201612-S/en">H.273</see>.
  /// </summary>
  TSdlColorPrimaries = (
    Unknown     = SDL_COLOR_PRIMARIES_UNKNOWN,

    /// <summary>ITU-R BT.709-6</summary>
    BT709       = SDL_COLOR_PRIMARIES_BT709,

    Unspecified = SDL_COLOR_PRIMARIES_UNSPECIFIED,

    /// <summary>ITU-R BT.470-6 System M</summary>
    BT470M      = SDL_COLOR_PRIMARIES_BT470M,

    /// <summary>ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625</summary>
    BT470BG     = SDL_COLOR_PRIMARIES_BT470BG,

    /// <summary>ITU-R BT.601-7 525, SMPTE 170M</summary>
    BT601       = SDL_COLOR_PRIMARIES_BT601,

    /// <summary>SMPTE 240M, functionally the same as SDL_COLOR_PRIMARIES_BT601</summary>
    Smpte240    = SDL_COLOR_PRIMARIES_SMPTE240,

    /// <summary>Generic film (color filters using Illuminant C)</summary>
    GenericFilm = SDL_COLOR_PRIMARIES_GENERIC_FILM,

    /// <summary>ITU-R BT.2020-2 / ITU-R BT.2100-0</summary>
    BT2020      = SDL_COLOR_PRIMARIES_BT2020,

    /// <summary>SMPTE ST 428-1</summary>
    Xyz         = SDL_COLOR_PRIMARIES_XYZ,

    /// <summary>SMPTE RP 431-2</summary>
    Smpte431    = SDL_COLOR_PRIMARIES_SMPTE431,

    /// <summary>SMPTE EG 432-1 / DCI P3</summary>
    Smpte432    = SDL_COLOR_PRIMARIES_SMPTE432,

    /// <summary>EBU Tech. 3213-E</summary>
    Ebu3213     = SDL_COLOR_PRIMARIES_EBU3213,

    Custom      = SDL_COLOR_PRIMARIES_CUSTOM);

type
  /// <summary>
  ///  Colorspace transfer characteristics.
  ///
  ///  These are as described by <see href="https://www.itu.int/rec/T-REC-H.273-201612-S/en">H.273</see>.
  /// </summary>
  TSdlTransferCharacteristics = (
    Unknown      = SDL_TRANSFER_CHARACTERISTICS_UNKNOWN,

    /// <summary>Rec. ITU-R BT.709-6 / ITU-R BT1361</summary>
    BT709        = SDL_TRANSFER_CHARACTERISTICS_BT709,

    Unspecified  = SDL_TRANSFER_CHARACTERISTICS_UNSPECIFIED,

    /// <summary>ITU-R BT.470-6 System M / ITU-R BT1700 625 PAL & SECAM</summary>
    Gamma22      = SDL_TRANSFER_CHARACTERISTICS_GAMMA22,

    /// <summary>ITU-R BT.470-6 System B, G</summary>
    Gamma28      = SDL_TRANSFER_CHARACTERISTICS_GAMMA28,

    /// <summary>SMPTE ST 170M / ITU-R BT.601-7 525 or 625</summary>
    BT601        = SDL_TRANSFER_CHARACTERISTICS_BT601,

    /// <summary>SMPTE ST 240M</summary>
    Smpte240     = SDL_TRANSFER_CHARACTERISTICS_SMPTE240,

    Linear       = SDL_TRANSFER_CHARACTERISTICS_LINEAR,
    Log100       = SDL_TRANSFER_CHARACTERISTICS_LOG100,
    Log100Sqrt10 = SDL_TRANSFER_CHARACTERISTICS_LOG100_SQRT10,

    /// <summary>IEC 61966-2-4</summary>
    Iec61966     = SDL_TRANSFER_CHARACTERISTICS_IEC61966,

    /// <summary>ITU-R BT1361 Extended Colour Gamut</summary>
    BT1361       = SDL_TRANSFER_CHARACTERISTICS_BT1361,

    /// <summary>IEC 61966-2-1 (sRGB or sYCC)</summary>
    Srgb         = SDL_TRANSFER_CHARACTERISTICS_SRGB,

    /// <summary>ITU-R BT2020 for 10-bit system</summary>
    BT2020_10Bit = SDL_TRANSFER_CHARACTERISTICS_BT2020_10BIT,

    /// <summary>ITU-R BT2020 for 12-bit system</summary>
    BT2020_12Bit = SDL_TRANSFER_CHARACTERISTICS_BT2020_12BIT,

    /// <summary>SMPTE ST 2084 for 10-, 12-, 14- and 16-bit systems</summary>
    PQ           = SDL_TRANSFER_CHARACTERISTICS_PQ,

    /// <summary>SMPTE ST 428-1</summary>
    Smpte428     = SDL_TRANSFER_CHARACTERISTICS_SMPTE428,

    /// <summary>ARIB STD-B67, known as "hybrid log-gamma" (HLG)</summary>
    Hlg          = SDL_TRANSFER_CHARACTERISTICS_HLG,

    Custom       = SDL_TRANSFER_CHARACTERISTICS_CUSTOM);

type
  /// <summary>
  ///  Colorspace matrix coefficients.
  ///
  ///  These are as described by <see href="https://www.itu.int/rec/T-REC-H.273-201612-S/en">H.273</see>.
  /// </summary>
  TSdlMatrixCoefficients = (
    Identity         = SDL_MATRIX_COEFFICIENTS_IDENTITY,

    /// <summary>ITU-R BT.709-6</summary>
    BT709            = SDL_MATRIX_COEFFICIENTS_BT709,

    Unspecified      = SDL_MATRIX_COEFFICIENTS_UNSPECIFIED,

    /// <summary>US FCC Title 47</summary>
    Fcc              = SDL_MATRIX_COEFFICIENTS_FCC,

    /// <summary>ITU-R BT.470-6 System B, G / ITU-R BT.601-7 625, functionally the same as SDL_MATRIX_COEFFICIENTS_BT601</summary>
    BT470BG          = SDL_MATRIX_COEFFICIENTS_BT470BG,

    /// <summary>ITU-R BT.601-7 525</summary>
    BT601            = SDL_MATRIX_COEFFICIENTS_BT601,

    /// <summary>SMPTE 240M</summary>
    Smpte240         = SDL_MATRIX_COEFFICIENTS_SMPTE240,

    YCgCo            = SDL_MATRIX_COEFFICIENTS_YCGCO,

    /// <summary>ITU-R BT.2020-2 non-constant luminance</summary>
    BT2020Ncl        = SDL_MATRIX_COEFFICIENTS_BT2020_NCL,

    /// <summary>ITU-R BT.2020-2 constant luminance</summary>
    BT2020CL         = SDL_MATRIX_COEFFICIENTS_BT2020_CL,

    /// <summary>SMPTE ST 2085</summary>
    Smpte2085        = SDL_MATRIX_COEFFICIENTS_SMPTE2085,

    ChromaDerivedNcl = SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_NCL,

    ChromaDerivedCL  = SDL_MATRIX_COEFFICIENTS_CHROMA_DERIVED_CL,

    /// <summary>ITU-R BT.2100-0 ICTCP</summary>
    Ictcp            = SDL_MATRIX_COEFFICIENTS_ICTCP,

    Custom           = SDL_MATRIX_COEFFICIENTS_CUSTOM);

type
  /// <summary>
  ///  Colorspace chroma sample location.
  /// </summary>
  TSdlChromaLocation = (
    /// <summary>RGB, no chroma sampling</summary>
    None    = SDL_CHROMA_LOCATION_NONE,

    /// <summary>In MPEG-2, MPEG-4, and AVC, Cb and Cr are taken on midpoint of
    ///  the left-edge of the 2x2 square. In other words, they have the same
    ///  horizontal location as the top-left pixel, but is shifted one-half
    ///  pixel down vertically.</summary>
    Left    = SDL_CHROMA_LOCATION_LEFT,

    /// <summary>In JPEG/JFIF, H.261, and MPEG-1, Cb and Cr are taken at the
    ///  center of the 2x2 square. In other words, they are offset one-half
    ///  pixel to the right and one-half pixel down compared to the top-left
    ///  pixel.</summary>
    Center  = SDL_CHROMA_LOCATION_CENTER,

    /// <summary>In HEVC for BT.2020 and BT.2100 content (in particular on
    ///  Blu-rays), Cb and Cr are sampled at the same location as the group's
    ///  top-left Y pixel ("co-sited", "co-located").</summary>
    TopLeft = SDL_CHROMA_LOCATION_TOPLEFT);

type
  /// <summary>
  ///  Colorspace definitions.
  ///
  ///  Since similar colorspaces may vary in their details (matrix, transfer
  ///  function, etc.), this is not an exhaustive list, but rather a
  ///  representative sample of the kinds of colorspaces supported in SDL.
  /// </summary>
  /// <seealso cref="TSdlColorPrimaries"/>
  /// <seealso cref="TSdlColorRange"/>
  /// <seealso cref="TSdlColorType"/>
  /// <seealso cref="TSdlMatrixCoefficients"/>
  /// <seealso cref="TSdlTransferCharacteristics"/>
  TSdlColorspace = (
    Unknown       = SDL_COLORSPACE_UNKNOWN,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G22_NONE_P709</summary>
    Srgb          = SDL_COLORSPACE_SRGB,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G10_NONE_P709</summary>
    SrgbLinear    = SDL_COLORSPACE_SRGB_LINEAR,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_RGB_FULL_G2084_NONE_P2020</summary>
    Hdr10         = SDL_COLORSPACE_HDR10,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_NONE_P709_X601</summary>
    Jpeg          = SDL_COLORSPACE_JPEG,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601</summary>
    BT601Limited  = SDL_COLORSPACE_BT601_LIMITED,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P601</summary>
    BT601Full     = SDL_COLORSPACE_BT601_FULL,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709</summary>
    BT709Limited  = SDL_COLORSPACE_BT709_LIMITED,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P709</summary>
    BT709Full     = SDL_COLORSPACE_BT709_FULL,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_STUDIO_G22_LEFT_P2020</summary>
    BT2020Limited = SDL_COLORSPACE_BT2020_LIMITED,

    /// <summary>Equivalent to DXGI_COLOR_SPACE_YCBCR_FULL_G22_LEFT_P2020</summary>
    BT2020Full    = SDL_COLORSPACE_BT2020_FULL,

    /// <summary>The default colorspace for RGB surfaces if no colorspace is specified</summary>
    RgbDefault    = SDL_COLORSPACE_RGB_DEFAULT,

    /// <summary>The default colorspace for YUV surfaces if no colorspace is specified</summary>
    YuvDefault    = SDL_COLORSPACE_YUV_DEFAULT);

  _TSdlColorspaceHelper = record helper for TSdlColorspace
  {$REGION 'Internal Declarations'}
  private
    function GetColorType: TSdlColorType; inline;
    function GetRange: TSdlColorRange; inline;
    function GetChroma: TSdlChromaLocation; inline;
    function GetPrimaries: TSdlColorPrimaries; inline;
    function GetTransfer: TSdlTransferCharacteristics; inline;
    function GetMatrix: TSdlMatrixCoefficients; inline;
    function GetIsMatrixBT601: Boolean; inline;
    function GetIsMatrixBG709: Boolean; inline;
    function GetIsMatrixBT2020Ncl: Boolean; inline;
    function GetHasLimitedRange: Boolean; inline;
    function GetHasFullRange: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Define a custom colorspace.
    ///
    ///  For example, defining TSdlColorspace.Srgb looks like this:
    ///
    ///  ```delphi
    ///  var Colorspace := TSdlColorspace.From(
    ///    TSdlColorType.Rgb,
    ///    TSdlColorRange.Full,
    ///    TSdlColorPrimaries.BT709,
    ///    TSdlTransferCharacteristics.Srgb,
    ///    TSdlMatrixCoefficients.Identity,
    ///    TSdlChromaLocation.None);
    ///  ```
    /// </summary>
    /// <param name="AType">The type of the new format.</param>
    /// <param name="ARange">The range of the new format.</param>
    /// <param name="APrimaries">The primaries of the new format.</param>
    /// <param name="ATransfer">The transfer characteristics of the new format.</param>
    /// <param name="AMatrix">Ththe matrix coefficients of the new format.</param>
    /// <param name="AChroma">The chroma sample location of the new format.</param>
    /// <returns>The custom colorspace.</returns>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    class function From(const AType: TSdlColorType; const ARange: TSdlColorRange;
      const APrimaries: TSdlColorPrimaries; const ATransfer: TSdlTransferCharacteristics;
      const AMatrix: TSdlMatrixCoefficients; const AChroma: TSdlChromaLocation): TSdlColorspace; inline; static;

    /// <summary>
    ///  The color type of the colorspace.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property ColorType: TSdlColorType read GetColorType;

    /// <summary>
    ///  The range of the colorspace.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Range: TSdlColorRange read GetRange;

    /// <summary>
    ///  The chroma sample location of the colorspace.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Chroma: TSdlChromaLocation read GetChroma;

    /// <summary>
    ///  The primaries of the colorspace.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Primaries: TSdlColorPrimaries read GetPrimaries;

    /// <summary>
    ///  The transfer characteristics of the colorspace.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Transfer: TSdlTransferCharacteristics read GetTransfer;

    /// <summary>
    ///  The matrix coefficients of the colorspace.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property Matrix: TSdlMatrixCoefficients read GetMatrix;

    /// <summary>
    ///  Whether this colorspace uses BT601 (or BT470BG) matrix coefficients.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsMatrixBT601: Boolean read GetIsMatrixBT601;

    /// <summary>
    ///  Whether this colorspace uses BT709 matrix coefficients.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsMatrixBG709: Boolean read GetIsMatrixBG709;

    /// <summary>
    ///  Whether this colorspace uses BT2020Ncl matrix coefficients.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property IsMatrixBT2020Ncl: Boolean read GetIsMatrixBT2020Ncl;

    /// <summary>
    ///  Whether this colorspace has a limited range.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property HasLimitedRange: Boolean read GetHasLimitedRange;

    /// <summary>
    ///  Whether this colorspace has a full range.
    /// </summary>
    /// <remarks>
    ///  It is safe to call this from any thread.
    /// </remarks>
    property HasFullRange: Boolean read GetHasFullRange;
  end;
{$ENDREGION 'Pixel Formats and Conversion Routines'}

{$REGION 'Blend Modes'}
/// <summary>
///  Blend modes decide how two colors will mix together. There are both
///  standard modes for basic needs and a means to create custom modes,
///  dictating what sort of math to do on what color components.
/// </summary>

type
  /// <summary>
  ///  The blend operation used when combining source and destination pixel
  ///  components.
  /// </summary>
  TSdlBlendOperation = (
    /// <summary>
    ///  dst + src: supported by all renderers
    /// </summary>
    Add         = SDL_BLENDOPERATION_ADD,

    /// <summary>
    ///  src - dst : supported by D3D, OpenGL, OpenGLES, and Vulkan
    /// </summary>
    Subtract    = SDL_BLENDOPERATION_SUBTRACT,

    /// <summary>
    ///  dst - src : supported by D3D, OpenGL, OpenGLES, and Vulkan
    /// </summary>
    RevSubtract = SDL_BLENDOPERATION_REV_SUBTRACT,

    /// <summary>
    ///  min(dst, src) : supported by D3D, OpenGL, OpenGLES, and Vulkan
    /// </summary>
    Minimum     = SDL_BLENDOPERATION_MINIMUM,

    /// <summary>
    ///  max(dst, src) : supported by D3D, OpenGL, OpenGLES, and Vulkan
    /// </summary>
    Maximum     = SDL_BLENDOPERATION_MAXIMUM);

type
  /// <summary>
  ///  The normalized factor used to multiply pixel components.
  ///
  ///  The blend factors are multiplied with the pixels from a drawing operation
  ///  (src) and the pixels from the render target (dst) before the blend
  ///  operation. The comma-separated factors listed above are always applied in
  ///  the component order red, green, blue, and alpha.
  /// </summary>
  TSdlBlendFactor = (
    /// <summary>
    ///  0, 0, 0, 0
    /// </summary>
    Zero             = SDL_BLENDFACTOR_ZERO,

    /// <summary>
    ///  1, 1, 1, 1
    /// </summary>
    One              = SDL_BLENDFACTOR_ONE,

    /// <summary>
    ///  srcR, srcG, srcB, srcA
    /// </summary>
    SrcColor         = SDL_BLENDFACTOR_SRC_COLOR,

    /// <summary>
    ///  1-srcR, 1-srcG, 1-srcB, 1-srcA
    /// </summary>
    OneMinusSrcColor = SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR,

    /// <summary>
    ///  srcA, srcA, srcA, srcA
    /// </summary>
    SrcAlpha         = SDL_BLENDFACTOR_SRC_ALPHA,

    /// <summary>
    ///  1-srcA, 1-srcA, 1-srcA, 1-srcA
    /// </summary>
    OneMinusSrcAlpha = SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA,

    /// <summary>
    ///  dstR, dstG, dstB, dstA
    /// </summary>
    DstColor         = SDL_BLENDFACTOR_DST_COLOR,

    /// <summary>
    ///  1-dstR, 1-dstG, 1-dstB, 1-dstA
    /// </summary>
    OneMinusDstColor = SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR,

    /// <summary>
    ///  dstA, dstA, dstA, dstA
    /// </summary>
    DstAlpha         = SDL_BLENDFACTOR_DST_ALPHA,

    /// <summary>
    ///  1-dstA, 1-dstA, 1-dstA, 1-dstA
    /// </summary>
    OneMinusDstAlpha = SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA);

type
  /// <summary>
  ///  A set of blend modes used in drawing operations.
  ///
  ///  These predefined blend modes are supported everywhere.
  ///
  ///  Additional values may be obtained from TSdlBlendMode.Compose.
  /// </summary>
  /// <seealso cref="TSdlBlendMode.Compose"/>
  TSdlBlendMode = (
    /// <summary>
    ///  No blending:
    ///   dstRGBA = srcRGBA
    /// </summary>
    None               = SDL_BLENDMODE_NONE,

    /// <summary>
    ///  Alpha blending:
    ///   dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA)),
    ///   dstA = srcA + (dstA * (1-srcA))
    /// </summary>
    Blend              = SDL_BLENDMODE_BLEND,

    /// <summary>
    ///  Pre-multiplied alpha blending:
    ///   dstRGBA = srcRGBA + (dstRGBA * (1-srcA))
    /// </summary>
    BlendPremultiplied = SDL_BLENDMODE_BLEND_PREMULTIPLIED,

    /// <summary>
    ///  Additive blending:
    ///   dstRGB = (srcRGB * srcA) + dstRGB,
    ///   dstA = dstA
    /// </summary>
    Add                = SDL_BLENDMODE_ADD,

    /// <summary>
    ///  Pre-multiplied additive blending:
    ///   dstRGB = srcRGB + dstRGB,
    ///   dstA = dstA
    /// </summary>
    AddPremultiplied   = SDL_BLENDMODE_ADD_PREMULTIPLIED,

    /// <summary>
    ///  Color modulate:
    ///   dstRGB = srcRGB * dstRGB,
    ///   dstA = dstA
    /// </summary>
    Modulate           = SDL_BLENDMODE_MOD,

    /// <summary>
    ///  Color multiply:
    ///   dstRGB = (srcRGB * dstRGB) + (dstRGB * (1-srcA)),
    ///   dstA = dstA
    /// </summary>
    Multiply           = SDL_BLENDMODE_MUL,

    Invalid            = SDL_BLENDMODE_INVALID);

  _TSdlBlendModeHelper = record helper for TSdlBlendMode
  public
    /// <summary>
    ///  Compose a custom blend mode for renderers.
    ///
    ///  The properties TSdlRenderer.DrawBlendMode and TSdlTexture.BlendMode accept
    ///  the TSdlBlendMode returned by this function if the renderer supports it.
    ///
    ///  A blend mode controls how the pixels from a drawing operation (source) get
    ///  combined with the pixels from the render target (destination). First, the
    ///  components of the source and destination pixels get multiplied with their
    ///  blend factors. Then, the blend operation takes the two products and
    ///  calculates the result that will get stored in the render target.
    ///
    ///  Expressed in pseudocode, it would look like this:
    ///
    ///  ```delphi
    ///  DstRgb := ColorOperation(SrcRgb * SrcColorFactor, DstRgb * DstColorFactor);
    ///  DstA := AlphaOperation(SrcA * SrcAlphaFactor, DstA * DstAlphaFactor);
    ///  ```
    ///
    ///  Where the functions `ColorOperation(Src, Dst)` and `AlphaOperation(Src,
    ///  Dst)` can return one of the following:
    ///
    ///  - `Src + Dst`
    ///  - `Src - Dst`
    ///  - `Dst - Src`
    ///  - `Min(Src, Dst)`
    ///  - `Max(Src, Dst)`
    ///
    ///  The red, green, and blue components are always multiplied with the first,
    ///  second, and third components of the TSdlBlendFactor, respectively. The
    ///  fourth component is not used.
    ///
    ///  The alpha component is always multiplied with the fourth component of the
    ///  TSdlBlendFactor. The other components are not used in the alpha
    ///  calculation.
    ///
    ///  Support for these blend modes varies for each renderer. To check if a
    ///  specific TSdlBlendMode is supported, create a renderer and assign it to
    ///  either TSdlRenderer.DrawBlendMode or TSdlTexture.BlendMode. They will
    ///  raise an error if the blend mode is not supported.
    ///
    ///  This list describes the support of custom blend modes for each renderer.
    ///  All renderers support the four blend modes listed in the SDL_BlendMode
    ///  enumeration.
    ///
    ///  - **Direct3D**: Supports all operations with all factors. However, some
    ///    factors produce unexpected results with `TSdlBlendOperation.Minimum`
    ///    and `TSdlBlendOperation.Maximum`.
    ///  - **Direct3D11**: Same as Direct3D 9.
    ///  - **OpenGL**: Supports the `TSdlBlendOperation.Add` operation with all
    ///    factors. OpenGL versions 1.1, 1.2, and 1.3 do not work correctly here.
    ///  - **OpenGL-ES2**: Supports the `TSdlBlendOperation.Add`,
    ///    `TSdlBlendOperation.Subtract`, `TSdlBlendOperation.RevSubtract`
    ///    operations with all factors.
    ///  - **Software**: No custom blend mode support.
    ///
    ///  Some renderers do not provide an alpha component for the default render
    ///  target. The `TSdlBlendFactor.DstAlpha` and
    ///  `TSdlBlendFactor.OneMinusDstAlpha` factors do not have an effect in this
    ///  case.
    /// </summary>
    /// <param name="ASrcColorFactor">The blend factor applied to the red, green,
    ///  and blue components of the source pixels.</param>
    /// <param name="ADstColorFactor">The blend factor applied to the red, green,
    ///  and blue components of the destination pixels.</param>
    /// <param name="AColorOperation">The blend operation used to combine the red,
    ///  green, and blue components of the source and destination pixels.</param>
    /// <param name="ASrcAlphaFactor">The blend factor applied to the alpha
    ///  component of the source pixels.</param>
    /// <param name="ADstAlphaFactor">The blend factor applied to the alpha
    ///  component of the destination pixels.</param>
    /// <param name="AAlphaOperation">The blend operation used to combine the
    ///  alpha component of the source and destination pixels.</param>
    /// <returns>A TSdlBlendMode that represents the chosen factors and operations.</returns>
    /// <seealso cref="TSdlRenderer.DrawBlendMode"/>
    /// <seealso cref="TSdlTexture.BlendMode"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function Compose(
      const ASrcColorFactor, ADstColorFactor: TSdlBlendFactor;
      const AColorOperation: TSdlBlendOperation;
      const ASrcAlphaFactor, ADstAlphaFactor: TSdlBlendFactor;
      const AAlphaOperation: TSdlBlendOperation): TSdlBlendMode; inline; static;
  end;
{$ENDREGION 'Blend Modes'}

{$REGION 'Surfaces'}
/// <summary>
///  SDL surfaces are buffers of pixels in system RAM. These are useful for
///  passing around and manipulating images that are not stored in GPU memory.
///
///  TSdlSurface makes serious efforts to manage images in various formats, and
///  provides a reasonable toolbox for transforming the data, including copying
///  between surfaces, filling rectangles in the image data, etc.
///
///  There is also a simple .bmp loader, TSdlSurface.LoadBmp. SDL itself does not
///  provide loaders for various other file formats, but there are several
///  excellent external libraries that do, including its own satellite library,
///  <see href="https://github.com/libsdl-org/SDL_image">SDL_image</see>.
/// </summary>

type
  /// <summary>
  ///  The flags on a TSdlSurface.
  ///
  ///  These are generally considered read-only.
  /// </summary>
  TSdlSurfaceFlag = (
    /// <summary>
    ///  Surface uses preallocated pixel memory.
    /// </summary>
    Preallocated = 0,

    /// <summary>
    ///  Surface needs to be locked to access pixels.
    /// </summary>
    LockNeeded   = 1,

    /// <summary>
    ///  Surface is currently locked.
    /// </summary>
    IsLocked     = 2,

    /// <summary>
    ///  Surface uses pixel memory allocated with SdlAlignedAlloc.
    /// </summary>
    SimdAligned  = 3);

type
  /// <summary>
  ///  A set of surface flags.
  /// </summary>
  TSdlSurfaceFlags = set of TSdlSurfaceFlag;

type
  /// <summary>
  ///  Scaling mode.
  /// </summary>
  TSdlScaleMode = (
    /// <summary>
    ///  Nearest pixel sampling
    /// </summary>
    Nearest = SDL_SCALEMODE_NEAREST,

    /// <summary>
    ///  Linear filtering
    /// </summary>
    Linear  = SDL_SCALEMODE_LINEAR);

type
  /// <summary>
  ///  Flip mode.
  /// </summary>
  TSdlFlipMode = (
    /// <summary>
    ///  Flip horizontally
    /// </summary>
    Horizontal = 0,

    /// <summary>
    ///  Flip vertically
    /// </summary>
    Vertical   = 1);

type
  /// <summary>
  ///  Flip modes.
  /// </summary>
  TSdlFlipModes = set of TSdlFlipMode;

const
  /// <summary>
  ///  Uses with TSdlSurface.ColorKey to disable the color key.
  /// </summary>
  SDL_NO_COLOR_KEY = Cardinal.MaxValue;

type
  /// <summary>
  ///  A collection of pixels used in software blitting.
  ///
  ///  Pixels are arranged in memory in rows, with the top row first. Each row
  ///  occupies an amount of memory given by the pitch (sometimes known as the row
  ///  stride in non-SDL APIs).
  ///
  ///  Within each row, pixels are arranged from left to right until the width is
  ///  reached. Each pixel occupies a number of bits appropriate for its format,
  ///  with most formats representing each pixel as one or more whole bytes (in
  ///  some indexed formats, instead multiple pixels are packed into each byte),
  ///  and a byte order given by the format. After encoding all pixels, any
  ///  remaining bytes to reach the pitch are used as padding to reach a desired
  ///  alignment, and have undefined contents.
  ///
  ///  When a surface holds YUV format data, the planes are assumed to be
  ///  contiguous without padding between them, e.g. a 32x32 surface in NV12
  ///  format with a pitch of 32 would consist of 32x32 bytes of Y plane followed
  ///  by 32x16 bytes of UV plane.
  /// </summary>
  TSdlSurface = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PSDL_Surface;
    function GetFlags: TSdlSurfaceFlags; inline;
    function GetFormat: TSdlPixelFormat; inline;
    function GetH: Integer; inline;
    function GetPitch: Integer; inline;
    function GetPixels: Pointer; inline;
    procedure SetPixels(const AValue: Pointer); inline;
    function GetW: Integer; inline;
    function GetMustLock: Boolean; inline;
    function GetColorspace: TSdlColorspace; inline;
    procedure SetColorspace(const AValue: TSdlColorspace); inline;
    function GetPalette: TSdlPalette; inline;
    procedure SetPalette(const AValue: TSdlPalette); inline;
    function GetHasAlternateImages: Boolean; inline;
    function GetImages: TArray<TSdlSurface>;
    function GetUseRle: Boolean; inline;
    procedure SetUseRle(const AValue: Boolean); inline;
    function GetColorKey: Cardinal; inline;
    procedure SetColorKey(const AValue: Cardinal); inline;
    function GetHasColorKey: Boolean; inline;
    function GetColorMod: TSdlColor; inline;
    procedure SetColorMod(const AValue: TSdlColor); inline;
    function GetAlphaMod: Byte; inline;
    procedure SetAlphaMod(const AValue: Byte); inline;
    function GetBlendMode: TSdlBlendMode; inline;
    procedure SetBlendMode(const AValue: TSdlBlendMode); inline;
    function GetClipRect: TSdlRect; inline;
    procedure SetClipRect(const AValue: TSdlRect); inline;
    function GetPixel(const AX, AY: Integer): TSdlColor; inline;
    procedure SetPixel(const AX, AY: Integer; const AValue: TSdlColor); inline;
    function GetPixelFloat(const AX, AY: Integer): TSdlColorF; inline;
    procedure SetPixelFloat(const AX, AY: Integer; const AValue: TSdlColorF); inline;
    function GetProperties: TSdlProperties; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlSurface; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlSurface.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlSurface): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlSurface; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlSurface.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlSurface): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlSurface; inline; static;
  public
    /// <summary>
    ///  Create a new surface with a specific pixel format.
    ///
    ///  The pixels of the new surface are initialized to zero.
    /// </summary>
    /// <param name="AWidth">The width of the surface.</param>
    /// <param name="AHeight">The height of the surface.</param>
    /// <param name="AFormat">The pixel format for the new surface.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    constructor Create(const AWidth, AHeight: Integer;
      const AFormat: TSdlPixelFormat); overload;

    /// <summary>
    ///  Create a new surface with a specific pixel format and existing pixel
    ///  data.
    ///
    ///  No copy is made of the pixel data. Pixel data is not managed automatically;
    ///  you must free the surface before you free the pixel data.
    ///
    ///  Pitch is the offset in bytes from one row of pixels to the next, e.g.
    ///  `AWidth * 4` for `TSdlPixelFormat.Rgba8888`.
    ///
    ///  You may pass nil for pixels and 0 for pitch to create a surface that you
    ///  will fill in with valid values later.
    /// </summary>
    /// <param name="AWidth">The width of the surface.</param>
    /// <param name="AHeight">The height of the surface.</param>
    /// <param name="AFormat">The pixel format for the new surface.</param>
    /// <param name="APixels">A pointer to existing pixel data.</param>
    /// <param name="APitch">The number of bytes between each row, including padding.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    constructor Create(const AWidth, AHeight: Integer; const AFormat: TSdlPixelFormat;
      const APixels: Pointer; const APitch: Integer); overload;

    /// <summary>
    ///  Create a surface from a BMP image from a seekable SDL data stream.
    /// </summary>
    /// <param name="ASrc">The data stream for the surface.</param>
    /// <param name="ACloseIO">If True, calls ASrc.Close before returning, even
    ///  in the case of an error.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="SaveBmp"/>
    constructor LoadBmp(const ASrc: TSdlIOStream; const ACloseIO: Boolean); overload;

    /// <summary>
    ///  Create a surface from a BMP image from a file.
    /// </summary>
    /// <param name="AFilename">The name of the BMP file to load.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="SaveBmp"/>
    constructor LoadBmp(const AFilename: String); overload;

    /// <summary>
    ///  Free the surface.
    /// </summary>
    procedure Free; inline;

    /// <summary>
    ///  Create a palette and associate it with this surface.
    ///
    ///  This function creates a palette compatible with the surface. The
    ///  palette is then returned for you to modify, and the surface will
    ///  automatically use the new palette in future operations. You do not need to
    ///  destroy the returned palette, it will be freed when the reference count
    ///  reaches 0, usually when the surface is destroyed.
    ///
    ///  Bitmap surfaces (with format TSdlPixelFormat.Index1Lsb or
    ///  TSdlPixelFormat.Index1Msb) will have the palette initialized with 0 as
    ///  white and 1 as black. Other surfaces will get a palette initialized with
    ///  white in every entry.
    ///
    ///  If this function is called for a surface that already has a palette, a new
    ///  palette will be created to replace it.
    /// </summary>
    /// <returns>A new palette.</returns>
    /// <exception name="ESdlError">Raised on failure (e.g. if the surface
    ///  didn't have an index format).</exception>
    function CreatePalette: TSdlPalette; inline;

    /// <summary>
    ///  Add an alternate version of a surface.
    ///
    ///  This function adds an alternate version of this surface, usually used for
    ///  content with high DPI representations like cursors or icons. The size,
    ///  format, and content do not need to match the original surface, and these
    ///  alternate versions will not be updated when the original surface changes.
    ///
    ///  This function adds a reference to the alternate version, so you should
    ///  call AImage.Free after this call.
    /// </summary>
    /// <param name="AImage">The alternate surface to associate with this surface.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="RemoveAlternateImages"/>
    /// <seealso cref="Images"/>
    /// <seealso cref="HasAlternateImages"/>
    procedure AddAlternateImage(const AImage: TSdlSurface); inline;

    /// <summary>
    ///  Remove all alternate versions of this surface.
    ///
    ///  This function removes a reference from all the alternative versions,
    ///  destroying them if this is the last reference to them.
    /// </summary>
    /// <seealso cref="AddAlternateImage"/>
    /// <seealso cref="Images"/>
    /// <seealso cref="HasAlternateImages"/>
    procedure RemoveAlternateImages; inline;

    /// <summary>
    ///  Set up the surface for directly accessing the pixels.
    ///
    ///  Between calls to Lock / Unlock, you can write to and read from `Pixels`,
    ///  using the pixel format in `Format`. Once you are done accessing the
    ///  surface, you should use Unlock to release it.
    ///
    ///  Not all surfaces require locking. If `MustLock` returns False, then you
    ///  can read and write to the surface at any time, and the pixel format of
    ///  the surface will not change.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MustLock"/>
    /// <seealso cref="Unlock"/>
    procedure Lock; inline;

    /// <summary>
    ///  Release the surface after directly accessing the pixels.
    /// </summary>
    /// <seealso cref="Lock"/>
    procedure Unlock; inline;

    /// <summary>
    ///  Save the surface to a seekable SDL data stream in BMP format.
    ///
    ///  Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
    ///  BMP directly. Other RGB formats with 8-bit or higher get converted to a
    ///  24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
    ///  surface before they are saved. YUV and paletted 1-bit and 4-bit formats are
    ///  not supported.
    /// </summary>
    /// <param name="ADst">A data stream to save to.</param>
    /// <param name="ACloseIO">If true, calls ADst.Close before returning, even
    ///  in the case of an error.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadBmp"/>
    procedure SaveBmp(const ADst: TSdlIOStream; const ACloseIO: Boolean); overload; inline;

    /// <summary>
    ///  Save the surface to a file in BMP format.
    ///
    ///  Surfaces with a 24-bit, 32-bit and paletted 8-bit format get saved in the
    ///  BMP directly. Other RGB formats with 8-bit or higher get converted to a
    ///  24-bit surface or, if they have an alpha mask or a colorkey, to a 32-bit
    ///  surface before they are saved. YUV and paletted 1-bit and 4-bit formats are
    ///  not supported.
    /// </summary>
    /// <param name="AFilename">Name of the file to save to.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="LoadBmp"/>
    procedure SaveBmp(const AFilename: String); overload; inline;

    /// <summary>
    ///  Disables clipping. Set the ClipRect property to enable clipping again.
    /// </summary>
    /// <seealso cref="ClipRect"/>
    procedure DisableClipping; inline;

    /// <summary>
    ///  Flip the surface vertically or horizontally.
    /// </summary>
    /// <param name="AFlip">The direction(s) to flip.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure Flip(const AFlip: TSdlFlipMode); inline;

    /// <summary>
    ///  Creates a new surface identical to the existing surface.
    ///
    ///  If the original surface has alternate images, the new surface will have a
    ///  reference to them as well.
    ///
    ///  The returned surface should be freed with Free.
    /// </summary>
    /// <returns>A copy of the surface.</returns>
    /// <seealso cref="Free"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function Duplicate: TSdlSurface; inline;

    /// <summary>
    ///  Creates a new surface identical to the existing surface, scaled to the
    ///  desired size.
    ///
    ///  The returned surface should be freed with Free.
    /// </summary>
    /// <param name="AWidth">The width of the new surface.</param>
    /// <param name="AHeight">The height of the new surface.</param>
    /// <param name="AScaleMode">The scale mode to be used.</param>
    /// <seealso cref="Free"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function Scale(const AWidth, AHeight: Integer;
      const AScaleMode: TSdlScaleMode): TSdlSurface; inline;

    /// <summary>
    ///  Copy the surface to a new surface of the specified format.
    ///
    ///  This function is used to optimize images for faster *repeat* blitting. This
    ///  is accomplished by converting the original and storing the result as a new
    ///  surface. The new, optimized surface can then be used as the source for
    ///  future blits, making them faster.
    ///
    ///  If the original surface has alternate images, the new surface will have a
    ///  reference to them as well.
    /// </summary>
    /// <param name="AFormat">The new pixel format.</param>
    /// <returns>Thne new SDL surface.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function Convert(const AFormat: TSdlPixelFormat): TSdlSurface; overload; inline;

    /// <summary>
    ///  Copy the existing surface to a new surface of the specified format and
    ///  colorspace.
    ///
    ///  This function converts an existing surface to a new format and colorspace
    ///  and returns the new surface. This will perform any pixel format and
    ///  colorspace conversion needed.
    ///
    ///  If the original surface has alternate images, the new surface will have a
    ///  reference to them as well.
    /// </summary>
    /// <param name="AFormat">The new pixel format.</param>
    /// <param name="AColorspace">The new colorspace.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function Convert(const AFormat: TSdlPixelFormat;
      const AColorspace: TSdlColorspace): TSdlSurface; overload; inline;

    /// <summary>
    ///  Copy the existing surface to a new surface of the specified format and
    ///  colorspace.
    ///
    ///  This function converts an existing surface to a new format and colorspace
    ///  and returns the new surface. This will perform any pixel format and
    ///  colorspace conversion needed.
    ///
    ///  If the original surface has alternate images, the new surface will have a
    ///  reference to them as well.
    /// </summary>
    /// <param name="AFormat">The new pixel format.</param>
    /// <param name="APalette">A palette to use for indexed formats.</param>
    /// <param name="AColorspace">The new colorspace.</param>
    /// <param name="AProps">Additional color properties.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function Convert(const AFormat: TSdlPixelFormat; const APalette: TSdlPalette;
      const AColorspace: TSdlColorspace; const AProps: TSdlProperties): TSdlSurface; overload; inline;

    /// <summary>
    ///  Premultiply the alpha.
    /// </summary>
    /// <param name="ALinear">True to convert from sRGB to linear space for the
    ///  alpha multiplication, False to do multiplication in sRGB space.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure PremultiplyAlpha(const ALinear: Boolean); inline;

    /// <summary>
    ///  Clear the surface with a specific color, with floating point precision.
    ///
    ///  This function handles all surface formats, and ignores any clip rectangle.
    ///
    ///  If the surface is YUV, the color is assumed to be in the sRGB colorspace,
    ///  otherwise the color is assumed to be in the colorspace of the suface.
    /// </summary>
    /// <param name="AR">The red component of the pixel, normally in the range 0-1.</param>
    /// <param name="AG">The green component of the pixel, normally in the range 0-1.</param>
    /// <param name="AB">The blue component of the pixel, normally in the range 0-1.</param>
    /// <param name="AA">(Optional) alpha component of the pixel, normally in the range 0-1.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Fill"/>
    procedure Clear(const AR, AG, AB: Single; const AA: Single = 1); overload; inline;

    /// <summary>
    ///  Clear the surface with a specific color, with floating point precision.
    ///
    ///  This function handles all surface formats, and ignores any clip rectangle.
    ///
    ///  If the surface is YUV, the color is assumed to be in the sRGB colorspace,
    ///  otherwise the color is assumed to be in the colorspace of the suface.
    /// </summary>
    /// <param name="AColor">The color.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Fill"/>
    procedure Clear(const AColor: TSdlColorF); overload; inline;

    /// <summary>
    ///  Perform a fast fill of a rectangle with a specific color.
    ///
    ///  `AColor` should be a pixel of the format used by the surface, and can be
    ///  generated by TSdlPixelFormatDetails.MapRgb or TSdlPixelFormatDetails.MapRgba.
    ///  If the color value contains an alpha component then the destination is
    ///  simply filled with that alpha information, no blending takes place.
    ///
    ///  If there is a clip rectangle set on the destination (set via ClipRect),
    ///  then this function will fill based on the intersection of the clip
    ///  rectangle and `ARect`.
    /// </summary>
    /// <param name="ARect">The rectangle to fill.</param>
    /// <param name="AColor">The color to fill with.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FillRects"/>
    procedure FillRect(const ARect: TSdlRect; const AColor: Cardinal); inline;

    /// <summary>
    ///  Perform a fast fill of the entire surface with a specific color, taking
    ///  the clip rectangle into account.
    ///
    ///  `AColor` should be a pixel of the format used by the surface, and can be
    ///  generated by TSdlPixelFormatDetails.MapRgb or TSdlPixelFormatDetails.MapRgba.
    ///  If the color value contains an alpha component then the destination is
    ///  simply filled with that alpha information, no blending takes place.
    ///
    ///  If there is a clip rectangle set on the destination (set via ClipRect),
    ///  then this function will fill the clip rectangle.
    /// </summary>
    /// <param name="AColor">The color to fill with.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Clear"/>
    /// <seealso cref="FillRects"/>
    procedure Fill(const AColor: Cardinal); inline;

    /// <summary>
    ///  Perform a fast fill of a set of rectangles with a specific color.
    ///
    ///  `AColor` should be a pixel of the format used by the surface, and can be
    ///  generated by TSdlPixelFormatDetails.MapRgb or TSdlPixelFormatDetails.MapRgba.
    ///  If the color value contains an alpha component then the destination is
    ///  simply filled with that alpha information, no blending takes place.
    ///
    ///  If there is a clip rectangle set on the destination (set via ClipRect),
    ///  then this function will fill based on the intersection of the clip
    ///  rectangle and the given rectangles.
    /// </summary>
    /// <param name="ARects">An array rectangles to fill.</param>
    /// <param name="AColor">The color to fill with.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FillRect"/>
    procedure FillRects(const ARects: TArray<TSdlRect>; const AColor: Cardinal); overload; inline;

    /// <summary>
    ///  Perform a fast fill of a set of rectangles with a specific color.
    ///
    ///  `AColor` should be a pixel of the format used by the surface, and can be
    ///  generated by TSdlPixelFormatDetails.MapRgb or TSdlPixelFormatDetails.MapRgba.
    ///  If the color value contains an alpha component then the destination is
    ///  simply filled with that alpha information, no blending takes place.
    ///
    ///  If there is a clip rectangle set on the destination (set via ClipRect),
    ///  then this function will fill based on the intersection of the clip
    ///  rectangle and the given rectangles.
    /// </summary>
    /// <param name="ARects">An array rectangles to fill.</param>
    /// <param name="AColor">The color to fill with.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FillRect"/>
    procedure FillRects(const ARects: array of TSdlRect; const AColor: Cardinal); overload;

    /// <summary>
    ///  Performs a fast blit from this surface to a destination surface
    ///  with clipping.
    ///
    ///  If either `ASrcRect` or `ADstRect` are nil, the entire surface is
    ///  copied while ensuring clipping to `ADst.ClipRect`.
    ///
    ///  The final blit rectangles are saved in `ASrcRect` and `ADstRect` after all
    ///  clipping is performed.
    ///
    ///  The blit function should not be called on a locked surface.
    ///
    ///  The blit semantics for surfaces with and without blending and colorkey are
    ///  defined as follows:
    ///
    ///  RGBA->RGB:
    ///    Source surface blend mode set to TSdlBlendMode.Blend:
    ///      alpha-blend (using the source alpha-channel and per-surface alpha).
    ///      source color key ignored.
    ///    Source surface blend mode set to TSdlBlendMode.None:
    ///      copy RGB.
    ///      if source color key set, only copy the pixels that do not match the
    ///      RGB values of the source color key, ignoring alpha in the comparison.
    ///
    ///  RGB->RGBA:
    ///    Source surface blend mode set to TSdlBlendMode.Blend:
    ///      alpha-blend (using the source per-surface alpha).
    ///    Source surface blend mode set to TSdlBlendMode.None:
    ///      copy RGB, set destination alpha to source per-surface alpha value.
    ///    both:
    ///      if source color key set, only copy the pixels that do not match the
    ///      source color key.
    ///
    ///  RGBA->RGBA:
    ///    Source surface blend mode set to TSdlBlendMode.Blend:
    ///      alpha-blend (using the source alpha-channel and per-surface alpha).
    ///      source color key.
    ///    Source surface blend mode set to TSdlBlendMode.None:
    ///      copy all of RGBA to the destination.
    ///      if source color key set, only copy the pixels that do not match the
    ///      RGB values of the source color key, ignoring alpha in the
    ///      comparison.
    ///
    ///  RGB->RGB:
    ///    Source surface blend mode set to TSdlBlendMode.Blend:
    ///      alpha-blend (using the source per-surface alpha).
    ///    Source surface blend mode set to TSdlBlendMode.None:
    ///      copy RGB.
    ///    both:
    ///      if source color key set, only copy the pixels that do not match the
    ///      source color key.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied, or nil to copy the
    ///  entire surface.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The rectangle representing the X and Y position
    ///  in the destination surface, or nil for (0,0). The width and height are
    ///  ignored, and are copied from `ASrcRect`. If you want a specific width
    ///  and height, you should use BlitScaled.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="BlitScaled"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure Blit(const ASrcRect: PSdlRect; const ADst: TSdlSurface;
      const ADstRect: PSdlRect); inline;

    /// <summary>
    ///  Perform low-level surface blitting only.
    ///
    ///  This is a semi-private blit function and it performs low-level surface
    ///  blitting, assuming the input rectangles have already been clipped.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The target rectangle in the destination surface.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Blit"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure BlitUnchecked(const ASrcRect: TSdlRect; const ADst: TSdlSurface;
      const ADstRect: TSdlRect); inline;

    /// <summary>
    ///  Perform a scaled blit to a destination surface, which may be of a different
    ///  format.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied, or nil to copy the
    ///  entire surface.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The rectangle representing the X and Y position
    ///  in the destination surface, or nil to fill the entire destination surface.</param>
    /// <param name="AScaleMode">The scale mode to be used.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Blit"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure BlitScaled(const ASrcRect: PSdlRect; const ADst: TSdlSurface;
      const ADstRect: PSdlRect; const AScaleMode: TSdlScaleMode); inline;

    /// <summary>
    ///  Perform low-level surface scaled blitting only.
    ///
    ///  This is a semi-private function and it performs low-level surface blitting,
    ///  assuming the input rectangles have already been clipped.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The target rectangle in the destination surface.</param>
    /// <param name="AScaleMode">The TSdlScaleMode to be used.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="BlitScaled"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure BlitScaledUnchecked(const ASrcRect: TSdlRect;
      const ADst: TSdlSurface; const ADstRect: TSdlRect;
      const AScaleMode: TSdlScaleMode); inline;

    /// <summary>
    ///  Perform a stretched pixel copy from this surface surface to another.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The target rectangle in the destination surface.</param>
    /// <param name="AScaleMode">The TSdlScaleMode to be used.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="BlitScaled"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure Stretch(const ASrcRect: TSdlRect;
      const ADst: TSdlSurface; const ADstRect: TSdlRect;
      const AScaleMode: TSdlScaleMode); inline;

    /// <summary>
    ///  Perform a tiled blit to a destination surface, which may be of a different
    ///  format.
    ///
    ///  The pixels in `ASrcRect` will be repeated as many times as needed to
    ///  completely fill `ADstRect`.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied, or nil to copy the
    ///  entire surface.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The target rectangle in the destination surface,
    ///  or nil to fill the entire surface.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Blit"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure BlitTiled(const ASrcRect: PSdlRect; const ADst: TSdlSurface;
      const ADstRect: PSdlRect); overload; inline;

    /// <summary>
    ///  Perform a scaled and tiled blit to a destination surface, which may be of a
    ///  different format.
    ///
    ///  The pixels in `ASrcRect` will be repeated as many times as needed to
    ///  completely fill `ADstRect`.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be copied, or nil to copy the
    ///  entire surface.</param>
    /// <param name="AScale">The scale used to transform ASrcRect into the
    ///  destination rectangle, e.g. a 32x32 texture with a scale of 2 would
    ///  fill 64x64 tiles.</param>
    /// <param name="AScaleMode">Scale algorithm to be used.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The rectangle representing the X and Y position
    ///  in the destination surface, or nil to fill the entire destination surface.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Blit"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure BlitTiled(const ASrcRect: PSdlRect; const AScale: Single;
      const AScaleMode: TSdlScaleMode; const ADst: TSdlSurface;
      const ADstRect: PSdlRect); overload; inline;

    /// <summary>
    ///  Perform a scaled blit using the 9-grid algorithm to a destination surface,
    ///  which may be of a different format.
    ///
    ///  The pixels in the source surface are split into a 3x3 grid, using the
    ///  different corner sizes for each corner, and the sides and center making up
    ///  the remaining pixels. The corners are then scaled using `AScale` and fit
    ///  into the corners of the destination rectangle. The sides and center are
    ///  then stretched into place to cover the remaining destination rectangle.
    /// </summary>
    /// <param name="ASrcRect">The rectangle to be used for the 9-grid, or nil
    ///  to use the entire surface.</param>
    /// <param name="ALeftWidth">The width, in pixels, of the left corners in `ASrcRect`.</param>
    /// <param name="ARightWidth">The width, in pixels, of the right corners in `ASrcRect`.</param>
    /// <param name="ATopHeight">The height, in pixels, of the top corners in `ASrcRect`.</param>
    /// <param name="ABottomHeight">The height, in pixels, of the bottom corners in `ASrcRect`.</param>
    /// <param name="AScale">The scale used to transform the corner of `ASrcRect`
    ///  into the corner of `ADstRect`, or 0.0 for an unscaled blit.</param>
    /// <param name="AScaleMode">Scale algorithm to be used.</param>
    /// <param name="ADst">The blit target surface.</param>
    /// <param name="ADstRect">The target rectangle in the destination surface,
    ///  or nil to fill the entire surface.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Blit"/>
    /// <remarks>
    ///  The same destination surface should not be used from two threads at
    ///  once. It is safe to use the same source surface from multiple threads.
    /// </remarks>
    procedure Blit9Grid(const ASrcRect: PSdlRect; const ALeftWidth, ARightWidth,
      ATopHeight, ABottomHeight: Integer; const AScale: Single;
      const AScaleMode: TSdlScaleMode; const ADst: TSdlSurface;
      const ADstRect: PSdlRect); inline;

    /// <summary>
    ///  Map an RGB triple to an opaque pixel value for the surface.
    ///
    ///  This function maps the RGB color value to the specified pixel format and
    ///  returns the pixel value best approximating the given RGB color value for
    ///  the given pixel format.
    ///
    ///  If the surface has a palette, the index of the closest matching color in
    ///  the palette will be returned.
    ///
    ///  If the surface pixel format has an alpha component it will be returned as
    ///  all 1 bits (fully opaque).
    ///
    ///  If the pixel format bpp (color depth) is less than 32-bpp then the unused
    ///  upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    ///  format the return value can be assigned to a UInt16, and similarly a UInt8
    ///  for an 8-bpp format).
    /// </summary>
    /// <param name="AR">The red component of the pixel in the range 0-255.</param>
    /// <param name="AG">The green component of the pixel in the range 0-255.</param>
    /// <param name="AB">The blue component of the pixel in the range 0-255.</param>
    /// <returns>A pixel value.</returns>
    /// <seealso cref="MapRgba"/>
    function MapRgb(const AR, AG, AB: Byte): Cardinal; inline;

    /// <summary>
    ///  Map an RGBA quadruple to a pixel value for the surface.
    ///
    ///  This function maps the RGBA color value to the specified pixel format and
    ///  returns the pixel value best approximating the given RGBA color value for
    ///  the given pixel format.
    ///
    ///  If the surface pixel format has no alpha component the alpha value will be
    ///  ignored (as it will be in formats with a palette).
    ///
    ///  If the surface has a palette, the index of the closest matching color in
    ///  the palette will be returned.
    ///
    ///  If the pixel format bpp (color depth) is less than 32-bpp then the unused
    ///  upper bits of the return value can safely be ignored (e.g., with a 16-bpp
    ///  format the return value can be assigned to a UInt16, and similarly a UInt8
    ///  for an 8-bpp format).
    /// </summary>
    /// <param name="AR">The red component of the pixel in the range 0-255.</param>
    /// <param name="AG">The green component of the pixel in the range 0-255.</param>
    /// <param name="AB">The blue component of the pixel in the range 0-255.</param>
    /// <param name="AA">The alpha component of the pixel in the range 0-255.</param>
    /// <returns>A pixel value.</returns>
    /// <seealso cref="MapRgb"/>
    function MapRgba(const AR, AG, AB, AA: Byte): Cardinal; inline;

    /// <summary>
    ///  The flags of the surface, read-only
    /// </summary>
    property Flags: TSdlSurfaceFlags read GetFlags;

    /// <summary>
    ///  The format of the surface, read-only
    /// </summary>
    property Format: TSdlPixelFormat read GetFormat;

    /// <summary>
    ///  The width of the surface, read-only.
    /// </summary>
    property W: Integer read GetW;

    /// <summary>
    ///  The height of the surface, read-only.
    /// </summary>
    property H: Integer read GetH;

    /// <summary>
    ///  The distance in bytes between rows of pixels, read-only
    /// </summary>
    property Pitch: Integer read GetPitch;

    /// <summary>
    ///  A pointer to the pixels of the surface, the pixels are
    ///  writeable if non-nil
    /// </summary>
    property Pixels: Pointer read GetPixels write SetPixels;

    /// <summary>
    ///  Whether the surface needs to be locked before access.
    /// </summary>
    property MustLock: Boolean read GetMustLock;

    /// <summary>
    ///  The colorspace used by the surface.
    ///
    ///  The colorspace defaults to TSdlColorspace.SrgbLinear for floating point
    ///  formats, TSdlColorspace.Hdr10 for 10-bit formats, TSdlColorspace.Srgb for
    ///  other RGB surfaces and TSdlColorspace.BT709Full for YUV textures.
    ///
    ///  Setting the colorspace doesn't change the pixels, only how they are
    ///  interpreted in color operations.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Colorspace: TSdlColorspace read GetColorspace write SetColorspace;

    /// <summary>
    ///  The palette used by a surface, or nil if there is no palette used.
    ///
    ///  A single palette can be shared with many surfaces.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Palette: TSdlPalette read GetPalette write SetPalette;

    /// <summary>
    ///  Whether the surface has alternate versions available.
    /// </summary>
    /// <returns>True if alternate versions are available or False otherwise.</returns>
    /// <seealso cref="AddAlternateImage"/>
    /// <seealso cref="RemoveAlternateImages"/>
    /// <seealso cref="Images"/>
    property HasAlternateImages: Boolean read GetHasAlternateImages;

    /// <summary>
    ///  Get an array including all versions of this surface.
    ///
    ///  This returns all versions of a surface, with this surface as
    ///  the first element in the returned array.
    /// </summary>
    /// <returns>An array of surfaces.</returns>
    /// <seealso cref="AddAlternateImage"/>
    /// <seealso cref="RemoveAlternateImages"/>
    /// <seealso cref="HasAlternateImages"/>
    property Images: TArray<TSdlSurface> read GetImages;

    /// <summary>
    ///  Whether to use RLE acceleration for the surface.
    ///
    ///  If RLE is enabled, color key and alpha blending blits are much faster, but
    ///  the surface must be locked before directly accessing the pixels.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Blit"/>
    /// <seealso cref="Lock"/>
    /// <seealso cref="Unlock"/>
    property UseRle: Boolean read GetUseRle write SetUseRle;

    /// <summary>
    ///  The color key (transparent pixel) in the surface.
    ///
    ///  The color key defines a pixel value that will be treated as transparent in
    ///  a blit. For example, one can use this to specify that cyan pixels should be
    ///  considered transparent, and therefore not rendered.
    ///
    ///  It is a pixel of the format used by the surface, as generated by
    ///  TSdlPixelFormatDetails.MapRgb.
    ///
    ///  Set to SDL_NO_COLOR_KEY to disable the color key.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="UseRle"/>
    /// <seealso cref="HasColorKey"/>
    property ColorKey: Cardinal read GetColorKey write SetColorKey;

    /// <summary>
    ///  Whether the surface has a color key.
    /// </summary>
    /// <returns>True if the surface has a color key, False otherwise.</returns>
    /// <seealso cref="ColorKey"/>
    property HasColorKey: Boolean read GetHasColorKey;

    /// <summary>
    ///  An additional color value multiplied into blit operations.
    ///
    ///  When this surface is blitted, during the blit operation each source color
    ///  channel is modulated by the appropriate color value according to the
    ///  following formula:
    ///
    ///  `SrcC := SrcC * (Color div 255)`
    ///
    ///  The Alpha value of the color is ignored. Use AlphaMod for alpha modulation.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AlphaMod"/>
    property ColorMod: TSdlColor read GetColorMod write SetColorMod;

    /// <summary>
    ///  An additional alpha value used in blit operations.
    ///
    ///  When this surface is blitted, during the blit operation the source alpha
    ///  value is modulated by this alpha value according to the following formula:
    ///
    ///  `SrcA = SrcA * (Alpha div 255)`
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ColorMod"/>
    property AlphaMod: Byte read GetAlphaMod write SetAlphaMod;

    /// <summary>
    ///  The blend mode used for blit operations.
    ///
    ///  To copy a surface to another surface (or texture) without blending with the
    ///  existing data, the blendmode of the *source* surface should be set to
    ///  `TSdlBlendMode.None`.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property BlendMode: TSdlBlendMode read GetBlendMode write SetBlendMode;

    /// <summary>
    ///  The clipping rectangle for a surface.
    ///
    ///  When the surface is the destination of a blit, only the area within the
    ///  clip rectangle is drawn into.
    ///
    ///  Note that blits are automatically clipped to the edges of the source and
    ///  destination surfaces.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <param name="ARect">The clipping rectangle.</param>
    /// <seealso cref="DisableClipping"/>
    property ClipRect: TSdlRect read GetClipRect write SetClipRect;

    /// <summary>
    ///  The pixels of the surface.
    ///
    ///  This function prioritizes correctness over speed: it is suitable for unit
    ///  tests, but is not intended for use in a game engine.
    ///
    ///  This uses the entire 0..255 range when converting color components from
    ///  pixel formats with less than 8 bits per RGB component.
    /// </summary>
    /// <param name="AX">The horizontal coordinate, 0 <= AX < Width.</param>
    /// <param name="AY">The vertical coordinate, 0 <= AY < Height.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Pixel[const AX, AY: Integer]: TSdlColor read GetPixel write SetPixel;

    /// <summary>
    ///  The pixels of the surface, as floating-point colors.
    ///
    ///  This function prioritizes correctness over speed: it is suitable for unit
    ///  tests, but is not intended for use in a game engine.
    ///
    ///  This uses the entire 0..1 range when converting color components from
    ///  pixel formats with less than 8 bits per RGB component.
    /// </summary>
    /// <param name="AX">The horizontal coordinate, 0 <= AX < Width.</param>
    /// <param name="AY">The vertical coordinate, 0 <= AY < Height.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property PixelFloat[const AX, AY: Integer]: TSdlColorF read GetPixelFloat write SetPixelFloat;

    /// <summary>
    ///  The properties associated with a surface.
    ///
    ///  The following properties are understood by SDL:
    ///
    ///  - `TSdlProperty.SurfaceSdrWhitePoint`: for HDR10 and floating point
    ///    surfaces, this defines the value of 100% diffuse white, with higher
    ///    values being displayed in the High Dynamic Range headroom. This defaults
    ///    to 203 for HDR10 surfaces and 1.0 for floating point surfaces.
    ///  - `TSdlProperty.SurfaceHdrHeadroom`: for HDR10 and floating point
    ///    surfaces, this defines the maximum dynamic range used by the content, in
    ///    terms of the SDR white point. This defaults to 0.0, which disables tone
    ///    mapping.
    ///  - `TSdlProperty.SurfaceTonemapOperator`: the tone mapping operator
    ///    used when compressing from a surface with high dynamic range to another
    ///    with lower dynamic range. Currently this supports 'chrome', which uses
    ///    the same tone mapping that Chrome uses for HDR content, the form '*=N',
    ///    where N is a floating point scale factor applied in linear space, and
    ///    'none', which disables tone mapping. This defaults to 'chrome'.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Properties: TSdlProperties read GetProperties;
  end;

/// <summary>
///  Copy a block of pixels of one format to another format.
/// </summary>
/// <param name="AWidth">The width of the block to copy, in pixels.</param>
/// <param name="AHeight">The height of the block to copy, in pixels.</param>
/// <param name="ASrcFormat">The pixel format of ASrc.</param>
/// <param name="ASrc">A pointer to the source pixels.</param>
/// <param name="ASrcPitch">The pitch of the source pixels, in bytes.</param>
/// <param name="ADstFormat">The pixel format of ADst.</param>
/// <param name="ADst">A pointer to be filled in with new pixel data.</param>
/// <param name="ADstPitch">The pitch of the destination pixels, in bytes.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlSurface.Convert"/>
procedure SdlConvert(const AWidth, AHeight: Integer; const ASrcFormat: TSdlPixelFormat;
  const ASrc: Pointer; const ASrcPitch: Integer; const ADstFormat: TSdlPixelFormat;
  const ADst: Pointer; const ADstPitch: Integer); overload; inline;

/// <summary>
///  Copy a block of pixels of one format and colorspace to another format and
///  colorspace.
/// </summary>
/// <param name="AWidth">The width of the block to copy, in pixels.</param>
/// <param name="AHeight">The height of the block to copy, in pixels.</param>
/// <param name="ASrcFormat">The pixel format of ASrc.</param>
/// <param name="ASrcColorspace">The colorspace of ASrc.</param>
/// <param name="ASrc">A pointer to the source pixels.</param>
/// <param name="ASrcPitch">The pitch of the source pixels, in bytes.</param>
/// <param name="ADstFormat">The pixel format of ADst.</param>
/// <param name="ADstColorspace">The colorspace of ADst.</param>
/// <param name="ADst">A pointer to be filled in with new pixel data.</param>
/// <param name="ADstPitch">The pitch of the destination pixels, in bytes.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlSurface.Convert"/>
procedure SdlConvert(const AWidth, AHeight: Integer; const ASrcFormat: TSdlPixelFormat;
  const ASrcColorspace: TSdlColorspace; const ASrc: Pointer;
  const ASrcPitch: Integer; const ADstFormat: TSdlPixelFormat;
  const ADstColorspace: TSdlColorspace; const ADst: Pointer;
  const ADstPitch: Integer); overload; inline;

/// <summary>
///  Copy a block of pixels of one format and colorspace to another format and
///  colorspace.
/// </summary>
/// <param name="AWidth">The width of the block to copy, in pixels.</param>
/// <param name="AHeight">The height of the block to copy, in pixels.</param>
/// <param name="ASrcFormat">The pixel format of ASrc.</param>
/// <param name="ASrcColorspace">The colorspace of ASrc.</param>
/// <param name="ASrcProperties">Additional source color properties.</param>
/// <param name="ASrc">A pointer to the source pixels.</param>
/// <param name="ASrcPitch">The pitch of the source pixels, in bytes.</param>
/// <param name="ADstFormat">The pixel format of ADst.</param>
/// <param name="ADstColorspace">The colorspace of ADst.</param>
/// <param name="ADstProperties">Additional destination color properties.</param>
/// <param name="ADst">A pointer to be filled in with new pixel data.</param>
/// <param name="ADstPitch">The pitch of the destination pixels, in bytes.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlSurface.Convert"/>
procedure SdlConvert(const AWidth, AHeight: Integer; const ASrcFormat: TSdlPixelFormat;
  const ASrcColorspace: TSdlColorspace; const ASrcProperties: TSdlProperties;
  const ASrc: Pointer; const ASrcPitch: Integer; const ADstFormat: TSdlPixelFormat;
  const ADstColorspace: TSdlColorspace; const ADstProperties: TSdlProperties;
  const ADst: Pointer; const ADstPitch: Integer); overload; inline;

/// <summary>
///  Premultiply the alpha on a block of pixels.
///
///  This is safe to use with ASrc = ADst, but not for other overlapping areas.
/// </summary>
/// <param name="AWidth">The width of the block to convert, in pixels.</param>
/// <param name="AHeight">The height of the block to convert, in pixels.</param>
/// <param name="ASrcFormat">The pixel format of ASrc.</param>
/// <param name="ASrc">A pointer to the source pixels.</param>
/// <param name="ASrcPitch">The pitch of the source pixels, in bytes.</param>
/// <param name="ADstFormat">The pixel format of ADst.</param>
/// <param name="ADst">A pointer to be filled in with premultiplied pixel data.</param>
/// <param name="ADstPitch">The pitch of the destination pixels, in bytes.</param>
/// <param name="ALinear">True to convert from sRGB to linear space for the
///  alpha multiplication, False to do multiplication in sRGB space.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="TSdlSurface.PremultiplyAlpha"/>
procedure PremultiplyAlpha(const AWidth, AHeight: Integer;
  const ASrcFormat: TSdlPixelFormat; const ASrc: Pointer; const ASrcPitch: Integer;
  const ADstFormat: TSdlPixelFormat; const ADst: Pointer; const ADstPitch: Integer;
  const ALinear: Boolean); inline;
{$ENDREGION 'Surfaces'}

{$REGION 'Display and Window Management'}
/// <summary>
///  SDL's video subsystem is largely interested in abstracting window
///  management from the underlying operating system. You can create windows,
///  manage them in various ways, set them fullscreen, and get events when
///  interesting things happen with them, such as the mouse or keyboard
///  interacting with a window.
///
///  The video subsystem is also interested in abstracting away some
///  platform-specific differences in OpenGL: context creation, swapping
///  buffers, etc. This may be crucial to your app, but also you are not
///  required to use OpenGL at all. In fact, SDL can provide rendering to those
///  windows as well, either with an easy-to-use 2D API or with a more-powerful
///  GPU API. Of course, it can simply get out of your way and give you the window
///  handles you need to use Vulkan, Direct3D, Metal, or whatever else you like
///  directly, too.
///
///  The video subsystem covers a lot of functionality, out of necessity, so it
///  is worth perusing the list of functions just to see what's available, but
///  most apps can get by with simply creating a window and listening for
///  events, so start with TSdlWindow and TSdlApp.Event.
/// </summary>

type
  /// <summary>
  ///  This is a unique ID for a display for the time it is connected to the
  ///  system, and is never reused for the lifetime of the application.
  ///
  ///  If the display is disconnected and reconnected, it will get a new ID.
  ///
  ///  The value 0 is an invalid ID.
  /// </summary>
  TSdlDisplayID = SDL_DisplayID;

type
  /// <summary>
  ///  This is a unique ID for a window.
  ///
  ///  The value 0 is an invalid ID.
  /// </summary>
  TSdlWindowID = SDL_WindowID;

type
  /// <summary>
  ///  System theme.
  /// </summary>
  TSdlSystemTheme = (
    /// <summary>Unknown system theme</summary>
    Unknown = SDL_SYSTEM_THEME_UNKNOWN,

    /// <summary>Light colored system theme</summary>
    Light   = SDL_SYSTEM_THEME_LIGHT,

    /// <summary>Dark colored system theme</summary>
    Dark    = SDL_SYSTEM_THEME_DARK);

  _TSdlSystemThemeHelper = record helper for TSdlSystemTheme
  public
    /// <summary>
    ///  Get the theme from the system.
    /// </summary>
    class function FromSystem: TSdlSystemTheme; inline; static;
  end;

type
  /// <summary>
  ///  Screen saver functionality
  /// </summary>
  TSdlScreenSaver = record
  {$REGION 'Internal Declarations'}
  private
    class function GetEnabled: Boolean; inline; static;
    class procedure SetEnabled(const AValue: Boolean); static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Enable the screen saver.
    ///
    ///  The screen saver is disabled by default.
    ///
    ///  The default can also be changed using TSdlHints.VideoAllowScreenSaver.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Disable"/>
    /// <seealso cref="IsEnabled"/>
    /// <remarks>
    ///  This method should only be used on the main thread.
    /// </remarks>
    class procedure Enable; inline; static;

    /// <summary>
    ///  Disable the screen saver.
    ///
    ///  The screen saver is disabled by default.
    ///
    ///  The default can also be changed using TSdlHints.VideoAllowScreenSaver.
    ///
    ///  If you disable the screensaver, it is automatically re-enabled when SDL
    ///  quits.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Enable"/>
    /// <seealso cref="IsEnabled"/>
    /// <remarks>
    ///  This method should only be used on the main thread.
    /// </remarks>
    class procedure Disable; inline; static;

    /// <summary>
    ///  Whether the screen saver is currently enabled.
    ///
    ///  The screen saver is disabled by default.
    ///
    ///  The default can also be changed using TSdlHints.VideoAllowScreenSaver.
    ///
    ///  If you disable the screensaver, it is automatically re-enabled when SDL
    ///  quits.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Enable"/>
    /// <seealso cref="Disable"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property IsEnabled: Boolean read GetEnabled write SetEnabled;
  end;

type
  /// <summary>
  ///  The record that defines a display mode.
  /// </summary>
  /// <seealso cref="TSdlDisplay.FullscreenModes"/>
  /// <seealso cref="TSdlDisplay.DesktopMode"/>
  /// <seealso cref="TSdlDisplay.CurrentMode"/>
  /// <seealso cref="TSdlWindow.FullscreenMode"/>
  /// <remarks>
  ///  This struct is available since SDL 3.2.0.
  /// </remarks>
  TSdlDisplayMode = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_DisplayMode;
    function GetFormat: TSdlPixelFormat; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>The display this mode is associated with</summary>
    property DisplayID: TSdlDisplayID read FHandle.displayID;

    /// <summary>Pixel format</summary>
    property Format: TSdlPixelFormat read GetFormat;

    /// <summary>Width</summary>
    property W: Integer read FHandle.w;

    /// <summary>Height</summary>
    property H: Integer read FHandle.h;

    /// <summary>Scale converting size to pixels (e.g. a 1920x1080 mode with
    ///  2.0 scale would have 3840x2160 pixels)</summary>
    property PixelDdensity: Single read FHandle.pixel_density;

    /// <summary>Refresh rate (or 0.0f for unspecified)</summary>
    property RefreshRate: Single read FHandle.refresh_rate;

    /// <summary>Precise refresh rate numerator (or 0 for unspecified)</summary>
    property RefreshRateNumerator: Integer read FHandle.refresh_rate_numerator;

    /// <summary>Precise refresh rate denominator</summary>
    property RefreshRateDenominator: Integer read FHandle.refresh_rate_denominator;
  end;
  PSdlDisplayMode = ^TSdlDisplayMode;

type
  /// <summary>
  ///  Display orientation values; the way a display is rotated.
  /// </summary>
  TSdlDisplayOrientation = (
    /// <summary>The display orientation can't be determined</summary>
    Unknown          = SDL_ORIENTATION_UNKNOWN,

    /// <summary>The display is in landscape mode, with the right side up,
    ///  relative to portrait mode</summary>
    Landscape        = SDL_ORIENTATION_LANDSCAPE,

    /// <summary>The display is in landscape mode, with the left side up,
    ///  relative to portrait mode</summary>
    LandscapeFlipped = SDL_ORIENTATION_LANDSCAPE_FLIPPED,

    /// <summary>The display is in portrait mode</summary>
    Portrait         = SDL_ORIENTATION_PORTRAIT,

    /// <summary>The display is in portrait mode, upside down</summary>
    PortraitFlipped  = SDL_ORIENTATION_PORTRAIT_FLIPPED);

type
  /// <summary>
  ///  The flags on a window.
  ///
  ///  These cover a lot of true/false, or on/off, window state. Some of it is
  ///  immutable after being set through TSdlWindow.Create, some of it can be
  ///  changed on existing windows by the app, and some of it might be altered by
  ///  the user or system outside of the app's control.
  /// </summary>
  /// <seealso cref="TSdlWindow.Flags"/>
  TSdlWindowFlag = (
    /// <summary>Window is in fullscreen mode</summary>
    Fullscreen        = 0,

    /// <summary>Window usable with OpenGL context</summary>
    OpenGL            = 1,

    /// <summary>Window is occluded</summary>
    Occluded          = 2,

    /// <summary>Window is neither mapped onto the desktop nor shown in the
    ///  taskbar/dock/window list; TSdlWindow.Show is required for it to become
    ///  visible</summary>
    Hidden            = 3,

    /// <summary>No window decoration</summary>
    Borderless        = 4,

    /// <summary>Window can be resized</summary>
    Resizable         = 5,

    /// <summary>Window is minimized</summary>
    Minimized         = 6,

    /// <summary>Window is maximized</summary>
    Maximized         = 7,

    /// <summary>Window has grabbed mouse input</summary>
    MouseGrabbed      = 8,

    /// <summary>Window has input focus</summary>
    InputFocus        = 9,

    /// <summary>Window has mouse focus</summary>
    MouseFocus        = 10,

    /// <summary>Window not created by SDL</summary>
    External          = 11,

    /// <summary>Window is modal</summary>
    Modal             = 12,

    /// <summary>Window uses high pixel density back buffer if possible</summary>
    HighPixelDensisty = 13,

    /// <summary>Window has mouse captured (unrelated to MouseGrabbed)</summary>
    MouseCapture      = 14,

    /// <summary>Window has relative mode enabled</summary>
    MouseRelativeMode = 15,

    /// <summary>Window should always be above others</summary>
    AlwaysOnTop       = 16,

    /// <summary>Window should be treated as a utility window, not showing in
    ///  the task bar and window list</summary>
    Utility           = 17,

    /// <summary>Window should be treated as a tooltip and does not get mouse or
    ///  keyboard focus, requires a parent window</summary>
    Tooltip           = 18,

    /// <summary>Window should be treated as a popup menu, requires a parent window</summary>
    PopupMenu         = 19,

    /// <summary>Window has grabbed keyboard input</summary>
    KeyboardGrabbed   = 20,

    /// <summary>Window usable for Vulkan surface</summary>
    Vulkan            = 28,

    /// <summary>Window usable for Metal view</summary>
    Metal             = 29,

    /// <summary>Window with transparent buffer</summary>
    Transparent       = 30,

    /// <summary>Window should not be focusable</summary>
    NotFocusable      = 31,

    /// Internal. To make the set 64-bits in size
    __Last            = 63);

  /// <summary>
  ///  A set of window flags.
  /// </summary>
  TSdlWindowFlags = set of TSdlWindowFlag;

type
  /// <summary>
  ///  Horizontal or vertical position of a window.
  ///
  ///  This is a regular integer, but has additional functionality to create a
  ///  centered or undefined window position on a specific display.
  /// </summary>
  TSdlWindowPos = type Integer;

  _SdlWindowPosHelper = record helper for TSdlWindowPos
  public const
    /// <summary>
    ///  Used to indicate that you don't care what the window position/display is.
    ///
    ///  This always uses the primary display.
    /// </summary>
    Undefined = SDL_WINDOWPOS_UNDEFINED;

    /// <summary>
    ///  Used to indicate that the window position should be centered.
    ///
    ///  This always uses the primary display.
    /// </summary>
    Centered  = SDL_WINDOWPOS_CENTERED;
  public
    /// <summary>
    ///  Used to indicate that you don't care what the window position is.
    ///
    ///  If you _really_ don't care, TSdlWindowPos.Undefined is the same, but
    ///  always uses the primary display instead of specifying one.
    /// </summary>
    /// <param name="AID">The TSdlDisplayID of the display to use.</param>
    class function CreateUndefined(const AID: TSdlDisplayID): TSdlWindowPos; inline; static;

    /// <summary>
    ///  Used to indicate that the window position should be centered.
    ///
    ///  TSdlWindowPos.Centered is the same, but always uses the primary display
    ///  instead of specifying one.
    /// </summary>
    /// <param name="AID">The TSdlDisplayID of the display to use.</param>
    class function CreateCentered(const AID: TSdlDisplayID): TSdlWindowPos; inline; static;

    /// <summary>
    ///  If this window position is marked as "undefined."
    /// </summary>
    function IsUndefined: Boolean; inline;

    /// <summary>
    ///  If this window position is marked as "centered."
    /// </summary>
    function IsCentered: Boolean; inline;
  end;

type
  /// <summary>
  ///  Window flash operation.
  /// </summary>
  TSdlFlashOperation = (
    /// <summary>Cancel any window flash state</summary>
    Cancel       = SDL_FLASH_CANCEL,

    /// <summary>Flash the window briefly to get attention</summary>
    Briefly      = SDL_FLASH_BRIEFLY,

    /// <summary>Flash the window until it gets focus</summary>
    UntilFocused = SDL_FLASH_UNTIL_FOCUSED);

type
  /// <summary>
  ///  A video driver.
  /// </summary>
  TSdlVideoDriver = record
  {$REGION 'Internal Declarations'}
  private
    FIndex: Integer;
    function GetName: String; inline;
    class function GetCount: Integer; inline; static;
    class function GetDriver(const AIndex: Integer): TSdlVideoDriver; inline; static;
    class function GetCurrent: String; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The name of the video driver.
    ///
    ///  The names of drivers are all simple, low-ASCII identifiers, like "cocoa",
    ///  "x11" or "windows". These never have Unicode characters, and are not meant
    ///  to be proper names.
    /// </summary>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  The number of video drivers compiled into SDL.
    /// </summary>
    /// <seealso cref="Drivers"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class property Count: Integer read GetCount;

    /// <summary>
    ///  The built in video drivers.
    ///
    ///  The video drivers are presented in the order in which they are normally
    ///  checked during initialization.
    /// </summary>
    /// <param name="AIndex">The index of a video driver.</param>
    /// <seealso cref="Count"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class property Drivers[const AIndex: Integer]: TSdlVideoDriver read GetDriver; default;

    /// <summary>
    ///  The name of the currently initialized video driver or an empty string
    ///  if no driver has been initialized.
    ///
    ///  The names of drivers are all simple, low-ASCII identifiers, like "cocoa",
    ///  "x11" or "windows". These never have Unicode characters, and are not meant
    ///  to be proper names.
    /// </summary>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class property Current: String read GetCurrent;
  end;

type
  /// <summary>
  ///  A display.
  /// </summary>
  TSdlDisplay = record
  {$REGION 'Internal Declarations'}
  private class var
    FDisplays: TArray<TSdlDisplayID>;
  private
    FID: TSdlDisplayID;
    function GetName: String; inline;
    function GetBounds: TSdlRect; inline;
    function GetUsableBounds: TSdlRect; inline;
    function GetNaturalOrientation: TSdlDisplayOrientation; inline;
    function GetCurrentOrientation: TSdlDisplayOrientation; inline;
    function GetContentScale: Single; inline;
    function GetHdrEnabled: Boolean; inline;
    function GetFullScreenModes: TArray<TSdlDisplayMode>;
    function GetDesktopMode: TSdlDisplayMode; inline;
    function GetCurrentMode: TSdlDisplayMode; inline;
    class function GetCount: Integer; inline; static;
    class function GetDisplay(const AIndex: Integer): TSdlDisplay; inline; static;
    class function GetPrimary: TSdlDisplay; inline; static;
  private
    class procedure GetDisplaysIfNeeded; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Get the closest match to the requested display mode.
    ///
    ///  The available display modes are scanned and the closest mode matching
    ///  the requested mode is returned. The mode format and refresh rate
    ///  default to the desktop mode if they are set to 0. The modes are scanned
    ///  with size being first priority, format being second priority, and
    //// finally checking the refresh rate. If all the available modes are too
    ///  small, then false is returned.
    /// </summary>
    /// <param name="AW">The width in pixels of the desired display mode.</param>
    /// <param name="AH">The height in pixels of the desired display mode.</param>
    /// <param name="ARefreshRate">(optional) Refresh rate of the desired
    ///  display mode, or 0.0 (default) for the desktop refresh rate.</param>
    /// <param name="AIncludeHighDensityModes">(optional) Whether to include
    ///  high density modes in the search (default False).</param>
    /// <returns>The closest display mode equal to or larger than the desired mode.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FullscreenModes"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    function GetClosestFullscreenMode(const AW, AH: Integer;
      const ARefreshRate: Single = 0;
      const AIncludeHighDensityModes: Boolean = False): TSdlDisplayMode; inline;

    /// <summary>
    ///  Get the display containing a point.
    /// </summary>
    /// <param name="APoint">the point to query.</param>
    /// <returns>The display containing the point.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Bounds"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class function ForPoint(const APoint: TSdlPoint): TSdlDisplay; inline; static;

    /// <summary>
    ///  Get the display primarily containing a rect.
    /// </summary>
    /// <param name="ARect">the rect to query.</param>
    /// <returns>The display entirely containing the rect or closest to the
    ///  center of the rect on success.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Bounds"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class function ForRect(const ARect: TSdlRect): TSdlDisplay; inline; static;

    /// <summary>
    ///  The name of a display.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  The desktop area represented by the display.
    ///
    ///  The primary display is often located at (0,0), but may be placed at a
    ///  different location depending on monitor layout.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="UsableBounds"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Bounds: TSdlRect read GetBounds;

    /// <summary>
    ///  The usable desktop area represented by the display, in screen
    ///  coordinates.
    ///
    ///  This is the same area as Bounds, but with portions reserved by the
    ///  system removed. For example, on Apple's macOS, this subtracts the area
    ///  occupied by the menu bar and dock.
    ///
    ///  Setting a window to be fullscreen generally bypasses these unusable areas,
    ///  so these are good guidelines for the maximum space available to a
    ///  non-fullscreen window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Bounds"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property UsableBounds: TSdlRect read GetUsableBounds;

    /// <summary>
    ///  The orientation of a display when it is unrotated or
    ///  TSdlDisplayOrientation.Unknown if it isn't available.
    /// </summary>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property NaturalOrientation: TSdlDisplayOrientation read GetNaturalOrientation;

    /// <summary>
    ///  The orientation of a display or TSdlDisplayOrientation.Unknown if it
    ///  isn't available.
    /// </summary>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property CurrentOrientation: TSdlDisplayOrientation read GetCurrentOrientation;

    /// <summary>
    ///  The content scale of a display.
    ///
    ///  The content scale is the expected scale for content based on the DPI
    ///  settings of the display. For example, a 4K display might have a 2.0 (200%)
    ///  display scale, which means that the user expects UI elements to be twice as
    ///  big on this display, to aid in readability.
    ///
    ///  After window creation, TSdlWindow.DisplayScale should be used to query
    ///  the content scale factor for individual windows instead of querying the
    ///  display for a window and using this property, as the per-window content
    ///  scale factor may differ from the base value of the display it is on,
    ///  particularly on high-DPI and/or multi-monitor desktop configurations.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlWindow.DisplayScale"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ContentScale: Single read GetContentScale;

    /// <summary>
    ///  True if the display has HDR headroom above the SDR white point. This is
    ///  for informational and diagnostic purposes only, as not all platforms
    ///  provide this information at the display level.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property HdrEnabled: Boolean read GetHdrEnabled;

    /// <summary>
    ///  An array of fullscreen display modes available on the display.
    ///
    ///  The display modes are sorted in this priority:
    ///
    ///  - W -> largest to smallest
    ///  - H -> largest to smallest
    ///  - Bits per pixel -> more colors to fewer colors
    ///  - Packed pixel layout -> largest to smallest
    ///  - Refresh rate -> highest to lowest
    ///  - Pixel density -> lowest to highest
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property FullScreenModes: TArray<TSdlDisplayMode> read GetFullScreenModes;

    /// <summary>
    ///  Information about the desktop's display mode.
    ///
    ///  There's a difference between this property and CurrentMode when SDL
    ///  runs fullscreen and has changed the resolution. In that case this
    ///  property will return the previous native display mode, and not the
    ///  current display mode.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="CurrentMode"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property DesktopMode: TSdlDisplayMode read GetDesktopMode;

    /// <summary>
    ///  Information about the current display mode.
    ///
    ///  There's a difference between this function and DesktopMode when SDL
    ///  runs fullscreen and has changed the resolution. In that case this
    ///  function will return the current display mode, and not the previous
    ///  native display mode.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DesktopMode"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property CurrentMode: TSdlDisplayMode read GetCurrentMode;

    /// <summary>
    ///  The number of currently connected displays.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Count: Integer read GetCount;

    /// <summary>
    ///  The currently connected displays.
    /// </summary>
    /// <param name="AIndex">The display index, from 0..Count-1.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Displays[const AIndex: Integer]: TSdlDisplay read GetDisplay; default;

    /// <summary>
    ///  The primary display.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class property Primary: TSdlDisplay read GetPrimary;
  end;

type
  /// <summary>
  ///  Window surface vsync values.
  ///
  ///  Use the special value Disabled to disable vsync, or Adaptive for late
  ///  swap tearing (adaptive vsync). Other values represent a vsync interval,
  ///  e.g. 1 to synchronize present with every vertical refresh, 2 to
  ///  synchronize present with every second vertical refresh, etc.
  /// </summary>
  TSdlWindowSurfaceVsync = type Integer;

  _TSdlWindowSurfaceVsync = record helper for TSdlWindowSurfaceVsync
  public const
    /// <summary>
    ///  Disabled vsync
    /// </summary>
    Disabled = SDL_WINDOW_SURFACE_VSYNC_DISABLED;

    /// <summary>
    ///  Use adaptive vsync (late swap tearing)
    /// </summary>
    Adaptive = SDL_WINDOW_SURFACE_VSYNC_ADAPTIVE;
  end;

type
  /// <summary>
  ///  Text input type.
  ///
  ///  These are the valid values for TSdlProperty.TextInputType. Not every
  ///  value is valid on every platform, but where a value isn't supported, a
  ///  reasonable fallback will be used.
  /// </summary>
  /// <seealso cref="TSdlWindow.StartTextInput"/>
  TSdlTextInputType = (
    /// <summary>
    ///  The input is text
    /// </summary>
    Text                  = SDL_TEXTINPUT_TYPE_TEXT,

    /// <summary>
    ///  The input is a person's name
    /// </summary>
    TextName              = SDL_TEXTINPUT_TYPE_TEXT_NAME,

    /// <summary>
    ///  The input is an e-mail address
    /// </summary>
    TextEmail             = SDL_TEXTINPUT_TYPE_TEXT_EMAIL,

    /// <summary>
    ///  The input is a username
    /// </summary>
    TextUsername          = SDL_TEXTINPUT_TYPE_TEXT_USERNAME,

    /// <summary>
    ///  The input is a secure password that is hidden
    /// </summary>
    TextPasswordHidden    = SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_HIDDEN,

    /// <summary>
    ///  The input is a secure password that is visible
    /// </summary>
    TextPasswordVisible   = SDL_TEXTINPUT_TYPE_TEXT_PASSWORD_VISIBLE,

    /// <summary>
    ///  The input is a number
    /// </summary>
    Number                = SDL_TEXTINPUT_TYPE_NUMBER,

    /// <summary>
    ///  The input is a secure PIN that is hidden
    /// </summary>
    NumberPasswordHidden  = SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_HIDDEN,

    /// <summary>
    ///  The input is a secure PIN that is visible
    /// </summary>
    NumberPasswordVisible = SDL_TEXTINPUT_TYPE_NUMBER_PASSWORD_VISIBLE);

type
  /// <summary>
  ///  Auto capitalization type.
  ///
  ///  These are the valid values for TSdlProperty.TextInputCapitalization.
  ///  Not every value is valid on every platform, but where a value isn't
  ///  supported, a reasonable fallback will be used.
  /// </summary>
  /// <seealso cref="TSdlWindow.StartTextInput"/>
  TSdlCapitalization = (
    /// <summary>
    ///  No auto-capitalization will be done
    /// </summary>
    None      = SDL_CAPITALIZE_NONE,

    /// <summary>
    ///  The first letter of sentences will be capitalized
    /// </summary>
    Sentences = SDL_CAPITALIZE_SENTENCES,

    /// <summary>
    ///  The first letter of words will be capitalized
    /// </summary>
    Words     = SDL_CAPITALIZE_WORDS,

    /// <summary>
    ///  All letters will be capitalized
    /// </summary>
    Letters   = SDL_CAPITALIZE_LETTERS);

type
  /// <summary>
  ///  A window.
  /// </summary>
  TSdlWindow = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Window;
    function GetID: TSdlWindowID; inline;
    function GetParent: TSdlWindow; inline;
    procedure SetParent(const AValue: TSdlWindow); inline;
    function GetDisplay: TSdlDisplay; inline;
    function GetPixelDensity: Single; inline;
    function GetDisplayScale: Single; inline;
    function GetFullscreenMode: PSdlDisplayMode; inline;
    procedure SetFullscreenMode(const AValue: PSdlDisplayMode); inline;
    function GetIccProfile: TBytes;
    function GetPixelFormat: TSdlPixelFormat; inline;
    function GetFlags: TSdlWindowFlags; inline;
    function GetTitle: String; inline;
    procedure SetTitle(const AValue: String); inline;
    procedure SetIcon(const AValue: TSdlSurface); inline;
    function GetPositionPoint: TSdlPoint; inline;
    procedure SetPositionPoint(const AValue: TSdlPoint); inline;
    function GetSizeSize: TSdlSize; inline;
    procedure SetSizeSize(const AValue: TSdlSize); inline;
    function GetSizeInPixelsSize: TSdlSize; inline;
    function GetMinimumSizeSize: TSdlSize; inline;
    procedure SetMinimumSizeSize(const AValue: TSdlSize); inline;
    function GetMaximumSizeSize: TSdlSize; inline;
    procedure SetMaximumSizeSize(const AValue: TSdlSize); inline;
    function GetSafeArea: TSdlRect; inline;
    function GetBordered: Boolean; inline;
    procedure SetBordered(const AValue: Boolean); inline;
    function GetResizable: Boolean; inline;
    procedure SetResizable(const AValue: Boolean); inline;
    function GetAlwaysOnTop: Boolean; inline;
    procedure SetAlwaysOnTop(const AValue: Boolean); inline;
    function GetFullscreen: Boolean; inline;
    procedure SetFullscreen(const AValue: Boolean); inline;
    function GetHasSurface: Boolean; inline;
    function GetSurface: TSdlSurface; inline;
    function GetSurfaceVSync: TSdlWindowSurfaceVsync; inline;
    procedure SetSurfaceVSync(const AValue: TSdlWindowSurfaceVsync); inline;
    function GetKeyboardGrab: Boolean; inline;
    procedure SetKeyboardGrab(const AValue: Boolean); inline;
    function GetMouseGrab: Boolean; inline;
    procedure SetMouseGrab(const AValue: Boolean); inline;
    function GetMouseRect: PSdlRect; inline;
    procedure SetMouseRect(const AValue: PSdlRect); inline;
    function GetOpacity: Single; inline;
    procedure SetOpacity(const AValue: Single); inline;
    function GetModal: Boolean; inline;
    procedure SetModal(const AValue: Boolean); inline;
    function GetFocusable: Boolean; inline;
    procedure SetFocusable(const AValue: Boolean); inline;
    function GetShape: TSdlSurface; inline;
    procedure SetShape(const AValue: TSdlSurface); inline;
    function GetTextInputActive: Boolean; inline;
    function GetIsScreenKeyboardShown: Boolean; inline;
    function GetIsRelativeMouseMode: Boolean; inline;
    procedure SetIsRelativeMouseMode(const AValue: Boolean); inline;
    function GetProperties: TSdlProperties; inline;
    class function GetWindows: TArray<TSdlWindow>; static;
    class function GetGrabbedWindow: TSdlWindow; inline; static;
    class function GetWithKeyboardFocus: TSdlWindow; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlWindow; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlWindow.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlWindow): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlWindow; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlWindow.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlWindow): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlWindow; inline; static;
  public
    /// <summary>
    ///  Create a window with the specified dimensions and flags.
    ///
    ///  AFlags may be zero or more of the following:
    ///
    ///  - `TSdlWindowFlag.Fullscreen`: fullscreen window at desktop resolution
    ///  - `TSdlWindowFlag.OpenGL`: window usable with an OpenGL context
    ///  - `TSdlWindowFlag.Occluded`: window partially or completely obscured by
    ///    another window
    ///  - `TSdlWindowFlag.Hidden`: window is not visible
    ///  - `TSdlWindowFlag.Borderless`: no window decoration
    ///  - `TSdlWindowFlag.Resizable`: window can be resized
    ///  - `TSdlWindowFlag.Minimized`: window is minimized
    ///  - `TSdlWindowFlag.Maximized`: window is maximized
    ///  - `TSdlWindowFlag.MouseGrabbed`: window has grabbed mouse focus
    ///  - `TSdlWindowFlag.InputFocus`: window has input focus
    ///  - `TSdlWindowFlag.MouseFocus`: window has mouse focus
    ///  - `TSdlWindowFlag.External`: window not created by SDL
    ///  - `TSdlWindowFlag.Modal`: window is modal
    ///  - `TSdlWindowFlag.HighPixelDensity`: window uses high pixel density
    ///    back buffer if possible
    ///  - `TSdlWindowFlag.MouseCapture`: window has mouse captured (unrelated
    ///    to MouseGrabbed)
    ///  - `TSdlWindowFlag.AlwaysOnTop`: window should always be above others
    ///  - `TSdlWindowFlag.Utility`: window should be treated as a utility
    ///    window, not showing in the task bar and window list
    ///  - `TSdlWindowFlag.Tooltip`: window should be treated as a tooltip and
    ///    does not get mouse or keyboard focus, requires a parent window
    ///  - `TSdlWindowFlag.PopupMenu`: window should be treated as a popup menu,
    ///    requires a parent window
    ///  - `TSdlWindowFlag.KeyboardGrabbed`: window has grabbed keyboard input
    ///  - `TSdlWindowFlag.Vulkan`: window usable with a Vulkan instance
    ///  - `TSdlWindowFlag.Metal`: window usable with a Metal instance
    ///  - `TSdlWindowFlag.Transparent`: window with transparent buffer
    ///  - `TSdlWindowFlag.NotFocusable`: window should not be focusable
    ///
    ///  The window is implicitly shown if TSdlWindowFlag.Hidden is not set.
    ///
    ///  On Apple's macOS, you **must** set the NSHighResolutionCapable Info.plist
    ///  property to YES, otherwise you will not receive a High-DPI OpenGL canvas.
    ///
    ///  The window pixel size may differ from its window coordinate size if the
    ///  window is on a high pixel density display. Use Size to query the client
    ///  area's size in window coordinates, and SizeInPixels or
    ///  TSdlRenderer.OutputSize to query the drawable size in pixels. Note that
    ///  the drawable size can vary after the window is created and should be
    ///  queried again if you get an TSdlEventKind.WindowPixelSizeChanged event.
    ///
    ///  If the window is created with any of the TSdlWindowFlag.OpenGL or
    ///  TSdlWindowFlag.Vulkan flags, then the corresponding LoadLibrary function
    ///  is called and the corresponding UnloadLibrary function is called when
    ///  the window is destroyed.
    ///
    ///  If TSdlWindowFlag.Vulkan is specified and there isn't a working Vulkan
    ///  driver, then this constructor will fail.
    ///
    ///  If TSdlWindowFlag.Metal is specified on an OS that does not support
    ///  Metal, then this constructor will fail.
    ///
    ///  If you intend to use this window with a TSdlRenderer, then you should
    ///  use TSdlRenderer constructor that also creates a window, to avoid
    ///  window flicker.
    ///
    ///  On non-Apple devices, SDL requires you to either not link to the Vulkan
    ///  loader or link to a dynamic library version. This limitation may be removed
    ///  in a future version of SDL.
    /// </summary>
    /// <param name="ATitle">The title of the window.</param>
    /// <param name="AW">The width of the window.</param>
    /// <param name="AH">The height of the window.</param>
    /// <param name="AFlags">Zero or more TSdlWindowFlag's.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="TSdlRenderer"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const ATitle: String; const AW, AH: Integer;
      const AFlags: TSdlWindowFlags); overload;

    /// <summary>
    ///  Create a child popup window of the specified parent window.
    ///
    ///  The AFlags parameter **must** contain at least one of the following:
    ///
    ///  - `TSdlWindowFlag.Tooltip`: The popup window is a tooltip and will not
    ///    pass any input events.
    ///  - `TSdlWindowFlag.PopupMenu`: The popup window is a popup menu. The
    ///    topmost popup menu will implicitly gain the keyboard focus.
    ///
    ///  The following flags are not relevant to popup window creation and will be
    ///  ignored:
    ///
    ///  - `TSdlWindowFlag.Minimized`
    ///  - `TSdlWindowFlag.Maximized`
    ///  - `TSdlWindowFlag.Fullscreen`
    ///  - `TSdlWindowFlag.Borderless`
    ///
    ///  The following flags are incompatible with popup window creation and will
    ///  cause it to fail:
    ///
    ///  - `TSdlWindowFlag.Utility`
    ///  - `TSdlWindowFlag.Modal`
    ///
    ///  The parent parameter **must** be non-null and a valid window. The parent of
    ///  a popup window can be either a regular, toplevel window, or another popup
    ///  window.
    ///
    ///  Popup windows cannot be minimized, maximized, made fullscreen, raised,
    ///  flash, be made a modal window, be the parent of a toplevel window, or grab
    ///  the mouse and/or keyboard. Attempts to do so will fail.
    ///
    ///  Popup windows implicitly do not have a border/decorations and do not appear
    ///  on the taskbar/dock or in lists of windows such as alt-tab menus.
    ///
    ///  If a parent window is hidden or destroyed, any child popup windows will be
    ///  recursively hidden or destroyed as well. Child popup windows not explicitly
    ///  hidden will be restored when the parent is shown.
    /// </summary>
    /// <param name="AParent">The parent of the window.</param>
    /// <param name="AOffsetX">The X position of the popup window relative to
    ///  the origin of the parent.</param>
    /// <param name="AOffsetY">The Y position of the popup window relative to
    ///  the origin of the parent window.</param>
    /// <param name="AW">The width of the window.</param>
    /// <param name="AH">The height of the window.</param>
    /// <param name="AFlags">TSdlWindowFlag.Tooltip or TSdlWindowFlag.PopupMenu,
    ///  and zero or more additional flags.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Parent"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AParent: TSdlWindow; const AOffsetX, AOffsetY,
      AW, AH: Integer; const AFlags: TSdlWindowFlags); overload;

    /// <summary>
    ///  Create a window with the specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlProperty.WindowCreateAlwaysOnTop`: True if the window should be
    ///    always on top
    ///  - `TSdlProperty.WindowCreateBorderless`: True if the window has no
    ///    window decoration
    ///  - `TSdlProperty.WindowCreateExternalGraphicsContext`: True if the
    ///    window will be used with an externally managed graphics context.
    ///  - `TSdlProperty.WindowCreateFocusable`: True if the window should
    ///    accept keyboard input (defaults true)
    ///  - `TSdlProperty.WindowCreateFullscreen`: True if the window should
    ///    start in fullscreen mode at desktop resolution
    ///  - `TSdlProperty.WindowCreateHeight`: The height of the window
    ///  - `TSdlProperty.WindowCreateHidden`: True if the window should start
    ///    hidden
    ///  - `TSdlProperty.WindowCreateHighPixelDensity`: True if the window
    ///    uses a high pixel density buffer if possible
    ///  - `TSdlProperty.WindowCreateMaximized`: True if the window should
    ///    start maximized
    ///  - `TSdlProperty.WindowCreateMenu`: True if the window is a popup menu
    ///  - `TSdlProperty.WindowCreateMetal': True if the window will be used
    ///    with Metal rendering
    ///  - `TSdlProperty.WindowCreateMinimized`: True if the window should
    ///    start minimized
    ///  - `TSdlProperty.WindowCreateModal`: True if the window is modal to
    ///    its parent
    ///  - `TSdlProperty.WindowCreateMouseGrabbed`: True if the window starts
    ///    with grabbed mouse focus
    ///  - `TSdlProperty.WindowCreateOpenGL`: True if the window will be used
    ///    with OpenGL rendering
    ///  - `TSdlProperty.WindowCreateParent`: A TSdlWindow that will be the
    ///    parent of this window, required for windows with the "tooltip",
    ///    "menu", and "modal" properties
    ///  - `TSdlProperty.WindowCreateResizable`: True if the window should be
    ///    resizable
    ///  - `TSdlProperty.WindowCreateTitle`: The title of the window
    ///  - `TSdlProperty.WindowCreateTransparent`: True if the window show
    ///    transparent in the areas with alpha of 0
    ///  - `TSdlProperty.WindowCreateTooltip`: True if the window is a tooltip
    ///  - `TSdlProperty.WindowCreateUtility`: True if the window is a utility
    ///    window, not showing in the task bar and window list
    ///  - `TSdlProperty.WindowCreateVulkan`: True if the window will be used
    ///    with Vulkan rendering
    ///  - `TSdlProperty.WindowCreateWidth`: the width of the window
    ///  - `TSdlProperty.WindowCreateX`: The X position of the window, or
    ///    TSdlWindowPos.Centered. Defaults to TSdlWindowPos.Undefined. This is
    ///    relative to the parent for windows with the "tooltip" or "menu"
    ///    property set.
    ///  - `TSdlProperty.WindowCreateY`: The Y position of the window, or
    ///    TSdlWindowPos.Centered. Defaults to TSdlWindowPos.Undefined. This is
    ///    relative to the parent for windows with the "tooltip" or "menu"
    ///    property set.
    ///
    ///  These are additional supported properties on macOS:
    ///
    ///  - `TSdlProperty.WindowCreateCocoaWindow`: The NSWindow handle
    ///    associated with the window, if you want to wrap an existing window.
    ///  - `TSdlProperty.WindowCreateCocoaView`: The NSView handle associated
    ///    with the window, defaults to `[window contentView]`
    ///
    ///  These are additional supported properties on Windows:
    ///
    ///  - `TSdlProperty.WindowCreateWin32Hwnd`: the HWND associated with the
    ///    window, if you want to wrap an existing window.
    ///  - `TSdlProperty.WindowCreateWin32PixelFormatHwnd`: optional,
    ///    another window to share pixel format with, useful for OpenGL windows
    ///
    ///  The window is implicitly shown if the "hidden" property is not set.
    ///
    ///  Windows with the "tooltip" and "menu" properties are popup windows and have
    ///  the behaviors and guidelines outlined in the constructor that creates
    ///  a popup window.
    ///
    ///  If this window is being created to be used with an TSdlRenderer, you should
    ///  not add a graphics API specific property (`TSdlProperty.WindowCreateOpenGL`,
    ///  etc), as SDL will handle that internally when it chooses a renderer.
    ///  However, SDL might need to recreate your window at that point, which may
    ///  cause the window to appear briefly, and then flicker as it is recreated.
    ///  The correct approach to this is to create the window with the
    ///  `TSdlProperty.WindowCreateHidden` property set to True, then create the
    ///  renderer, then show the window with Show.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlProperty"/>
    /// <seealso cref="TSdlProperties"/>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AProperties: TSdlProperties); overload;

    /// <summary>
    ///  Frees the window.
    ///
    ///  Any child windows owned by the window will be recursively destroyed as
    ///  well.
    ///
    ///  Note that on some platforms, the visible window may not actually be removed
    ///  from the screen until the SDL event loop is pumped again, even though the
    ///  window is no longer valid after this call.
    /// </summary>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Get a window from a stored ID.
    ///
    ///  The numeric ID is what TSdlWindowEvent references, and is necessary to map
    ///  these events to specific TSdlWindow objects.
    /// </summary>
    /// <param name="AId">The ID of the window.</param>
    /// <returns>The window associated with `AId`.</returns>
    /// <exception name="ESdlError">Raised on failure or if the window does not exist.</exception>
    /// <seealso cref="ID"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    class function FromID(const AId: TSdlWindowID): TSdlWindow; inline; static;

    /// <summary>
    ///  Request that the window's position be set.
    ///
    ///  If the window is in an exclusive fullscreen or maximized state, this
    ///  request has no effect.
    ///
    ///  This can be used to reposition fullscreen-desktop windows onto a different
    ///  display, however, as exclusive fullscreen windows are locked to a specific
    ///  display, they can only be repositioned programmatically via
    ///  FullscreenMode.
    ///
    ///  On some windowing systems this request is asynchronous and the new
    ///  coordinates may not have have been applied immediately upon the return of
    ///  this function. If an immediate change is required, call Sync to
    ///  block until the changes have taken effect.
    ///
    ///  When the window position changes, an TSdlEventKind.WindowMoved event will be
    ///  emitted with the window's new coordinates. Note that the new coordinates
    ///  may not match the exact coordinates requested, as some windowing systems
    ///  can restrict the position of the window in certain scenarios (e.g.
    ///  constraining the position so the window is always within desktop bounds).
    ///  Additionally, as this is just a request, it can be denied by the windowing
    ///  system.
    /// </summary>
    /// <param name="AX">The X coordinate of the window, or `TSdlWindowPos.Centered`
    //   or `TSdlWindowPos.Undefined`.</param>
    /// <param name="AY">The Y coordinate of the window, or `TSdlWindowPos.Centered`
    //   or `TSdlWindowPos.Undefined`.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetPosition"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetPosition(const AX, AY: TSdlWindowPos); inline;

    /// <summary>
    ///  Get the position of the window.
    ///
    ///  This is the current position of the window as last reported by the
    ///  windowing system.
    /// </summary>
    /// <param name="AWindow">the window to query.</param>
    /// <param name="AX">Set to the X position of the window.</param>
    /// <param name="AY">Set to the Y position of the window.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetPosition"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetPosition(out AX, AY: TSdlWindowPos); inline;

    /// <summary>
    ///  Request that the size of a window's client area be set.
    ///
    ///  If the window is in a fullscreen or maximized state, this request has no
    ///  effect.
    ///
    ///  To change the exclusive fullscreen mode of a window, use
    ///  FullscreenMode.
    ///
    ///  On some windowing systems, this request is asynchronous and the new window
    ///  size may not have have been applied immediately upon the return of this
    ///  function. If an immediate change is required, call Sync to
    ///  block until the changes have taken effect.
    ///
    ///  When the window size changes, an TSdlEventKind.WindowResized event will be
    ///  emitted with the new window dimensions. Note that the new dimensions may
    ///  not match the exact size requested, as some windowing systems can restrict
    ///  the window size in certain scenarios (e.g. constraining the size of the
    ///  content area to remain within the usable desktop bounds). Additionally, as
    ///  this is just a request, it can be denied by the windowing system.
    /// </summary>
    /// <param name="AW">The width of the window, must be > 0.</param>
    /// <param name="AH">The height of the window, must be > 0.</param>
    /// <returns>True on success, False on failure.</returns>
    /// <seealso cref="GetSize"/>
    /// <seealso cref="FullscreenMode"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function SetSize(const AW, AH: Integer): Boolean; inline;

    /// <summary>
    ///  Get the size of the window's client area.
    ///
    ///  The window pixel size may differ from its window coordinate size if the
    ///  window is on a high pixel density display. Use GetSizeInPixels
    ///  or TSdlRenderer.OutputSize to get the real client area size in pixels.
    /// </summary>
    /// <param name="AW">Is set to the width of the window.</param>
    /// <param name="AH">a pointer filled in with the height of the window, may be NULL.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlRenderer.OutputSize"/>
    /// <seealso cref="GetSizeInPixels"/>
    /// <seealso cref="SetSize"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetSize(out AW, AH: Integer); inline;

    /// <summary>
    ///  Get the size of the window's client area, in pixels.
    /// </summary>
    /// <param name="AW">Is set to the width in pixels.</param>
    /// <param name="AH">Is set to the height in pixels.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Create"/>
    /// <seealso cref="GetSize"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetSizeInPixels(out AW, AH: Integer); inline;

    /// <summary>
    ///  Set the minimum size of the window's client area.
    /// </summary>
    /// <param name="AMinW">The minimum width of the window, or 0 for no limit.</param>
    /// <param name="AMinH">The minimum height of the window, or 0 for no limit.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetMinimumSize"/>
    /// <seealso cref="SetMaximumSize"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetMinimumSize(const AMinW, AMinH: Integer); inline;

    /// <summary>
    ///  Get the minimum size of the window's client area.
    /// </summary>
    /// <param name="AMinW">Is set to the minimum width of the window.</param>
    /// <param name="AMinH">Is set to the minimum height of the window.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetMaximumSize"/>
    /// <seealso cref="SetMinimumSize"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetMinimumSize(out AMinW, AMinH: Integer); inline;

    /// <summary>
    ///  Set the maximum size of the window's client area.
    /// </summary>
    /// <param name="AMaxW">The maximum width of the window, or 0 for no limit.</param>
    /// <param name="AMaxH">The maximum height of the window, or 0 for no limit.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetMaximumSize"/>
    /// <seealso cref="SetMinimumSize"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetMaximumSize(const AMaxW, AMaxH: Integer); inline;

    /// <summary>
    ///  Get the maximum size of the window's client area.
    /// </summary>
    /// <param name="AW">Is set to the maximum width of the window.</param>
    /// <param name="AH">Is set to the maximum height of the window.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetMinimumSize"/>
    /// <seealso cref="SetMaximumSize"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetMaximumSize(out AMaxW, AMaxH: Integer); inline;

    /// <summary>
    ///  Request that the aspect ratio of a window's client area be set.
    ///
    ///  The aspect ratio is the ratio of width divided by height, e.g. 2560x1600
    ///  would be 1.6. Larger aspect ratios are wider and smaller aspect ratios are
    ///  narrower.
    ///
    ///  If, at the time of this request, the window in a fixed-size state, such as
    ///  maximized or fullscreen, the request will be deferred until the window
    ///  exits this state and becomes resizable again.
    ///
    ///  On some windowing systems, this request is asynchronous and the new window
    ///  aspect ratio may not have have been applied immediately upon the return of
    ///  this function. If an immediate change is required, call Sync to
    ///  block until the changes have taken effect.
    ///
    ///  When the window size changes, an TSdlEventKind.WindowResized event will be
    ///  emitted with the new window dimensions. Note that the new dimensions may
    ///  not match the exact aspect ratio requested, as some windowing systems can
    ///  restrict the window size in certain scenarios (e.g. constraining the size
    ///  of the content area to remain within the usable desktop bounds).
    ///  Additionally, as this is just a request, it can be denied by the windowing
    ///  system.
    /// </summary>
    /// <param name="AMinAspect">The minimum aspect ratio of the window,
    ///  or 0.0 for no limit.</param>
    /// <param name="AMaxAspect">The maximum aspect ratio of the window,
    ///  or 0.0 for no limit.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetAspectRatio"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetAspectRatio(const AMinAspect, AMaxAspect: Single); inline;

    /// <summary>
    ///  Get the aspect ratio of the window's client area.
    /// </summary>
    /// <param name="AMinAspect">Is set to the minimum aspect ratio of the window.</param>
    /// <param name="AMaxAspect">Is set to the maximum aspect ratio of the window.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetAspectRatio"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetAspectRatio(out AMinAspect, AMaxAspect: Single); inline;

    /// <summary>
    ///  Show the window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Hide"/>
    /// <seealso cref="RaiseAndFocus"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Show; inline;

    /// <summary>
    ///  Hide the window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Show"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Hide; inline;

    /// <summary>
    ///  Request that a window be raised above other windows and gain the input
    ///  focus.
    ///
    ///  The result of this request is subject to desktop window manager policy,
    ///  particularly if raising the requested window would result in stealing focus
    ///  from another application. If the window is successfully raised and gains
    ///  input focus, an TSdlEventKind.WindowFocusGained event will be emitted, and
    ///  the window will have the TSdlWindowFlag.InputFocus flag set.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure RaiseAndFocus; inline;

    /// <summary>
    ///  Request that the window be made as large as possible.
    ///
    ///  Non-resizable windows can't be maximized. The window must have the
    ///  TSdlWindowFlag.Resizable flag set, or this will have no effect.
    ///
    ///  On some windowing systems this request is asynchronous and the new window
    ///  state may not have have been applied immediately upon the return of this
    ///  function. If an immediate change is required, call Sync to
    ///  block until the changes have taken effect.
    ///
    ///  When the window state changes, an TSdlEventKind.WindowMaximized event will be
    ///  emitted. Note that, as this is just a request, the windowing system can
    ///  deny the state change.
    ///
    ///  When maximizing a window, whether the constraints set via
    ///  SetMaximumSize are honored depends on the policy of the window
    ///  manager. Win32 and macOS enforce the constraints when maximizing.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Minimize"/>
    /// <seealso cref="Restore"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Maximize; inline;

    /// <summary>
    ///  Request that the window be minimized to an iconic representation.
    ///
    ///  If the window is in a fullscreen state, this request has no direct effect.
    ///  It may alter the state the window is returned to when leaving fullscreen.
    ///
    ///  On some windowing systems this request is asynchronous and the new window
    ///  state may not have been applied immediately upon the return of this
    ///  function. If an immediate change is required, call Sync to
    ///  block until the changes have taken effect.
    ///
    ///  When the window state changes, an TSdlEventKind.WindowMinimized event will be
    ///  emitted. Note that, as this is just a request, the windowing system can
    ///  deny the state change.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Maximize"/>
    /// <seealso cref="Restore"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Minimize; inline;

    /// <summary>
    ///  Request that the size and position of a minimized or maximized window be
    ///  restored.
    ///
    ///  If the window is in a fullscreen state, this request has no direct effect.
    ///  It may alter the state the window is returned to when leaving fullscreen.
    ///
    ///  On some windowing systems this request is asynchronous and the new window
    ///  state may not have have been applied immediately upon the return of this
    ///  function. If an immediate change is required, call Sync to
    ///  block until the changes have taken effect.
    ///
    ///  When the window state changes, an TSdlEventKind.WindowRestored event will be
    ///  emitted. Note that, as this is just a request, the windowing system can
    ///  deny the state change.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Maximize"/>
    /// <seealso cref="Minimize"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Restore; inline;

    /// <summary>
    ///  Block until any pending window state is finalized.
    ///
    ///  On asynchronous windowing systems, this acts as a synchronization barrier
    ///  for pending window state. It will attempt to wait until any pending window
    ///  state has been applied and is guaranteed to return within finite time. Note
    ///  that for how long it can potentially block depends on the underlying window
    ///  system, as window state changes may involve somewhat lengthy animations
    ///  that must complete before the window is in its final requested state.
    ///
    ///  On windowing systems where changes are immediate, this does nothing.
    /// </summary>
    /// <returns>True on success or False if the operation timed out before the
    ///  window was in the requested state.</returns>
    /// <seealso cref="SetSize"/>
    /// <seealso cref="SetPosition"/>
    /// <seealso cref="Fullscreen"/>
    /// <seealso cref="Minimize"/>
    /// <seealso cref="Maximize"/>
    /// <seealso cref="Restore"/>
    /// <seealso cref="TSdlHints.VideoSyncWindowOperations"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function Sync: Boolean; inline;

    /// <summary>
    ///  Get the size of the window's borders (decorations) around the client area.
    ///
    ///  Note: This method may fail on systems where the window has not yet been
    ///  decorated by the display server (for example, immediately after calling
    ///  Create). It is recommended that you wait at least until the window has
    ///  been presented and composited, so that the window system has a
    ///  chance to decorate the window and provide the border dimensions to SDL.
    /// </summary>
    /// <param name="ATop">Set to the size of the top border.</param>
    /// <param name="ALeft">Set to size of the left border.</param>
    /// <param name="ABottom">Set to size of the bottom border.</param>
    /// <param name="ARight">Set to size of the right border.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetSize"/>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    procedure GetBordersSize(out ATop, ALeft, ABottom, ARight: Integer); inline;

    /// <summary>
    ///  Copy the window surface to the screen.
    ///
    ///  This is the function you use to reflect any changes to the surface on the
    ///  screen.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Surface"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateSurface; overload; inline;

    /// <summary>
    ///  Copy areas of the window surface to the screen.
    ///
    ///  This is the function you use to reflect changes to portions of the surface
    ///  on the screen.
    ///
    ///  Note that this function will update _at least_ the rectangles specified,
    ///  but this is only intended as an optimization; in practice, this might
    ///  update more of the screen (or all of the screen!), depending on what method
    ///  SDL uses to send pixels to the system.
    /// </summary>
    /// <param name="ARects">An array of TSdlRect records representing areas of
    ///  the surface to copy, in pixels.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Surface"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateSurface(const ARects: TArray<TSdlRect>); overload; inline;

    /// <summary>
    ///  Copy areas of the window surface to the screen.
    ///
    ///  This is the function you use to reflect changes to portions of the surface
    ///  on the screen.
    ///
    ///  Note that this function will update _at least_ the rectangles specified,
    ///  but this is only intended as an optimization; in practice, this might
    ///  update more of the screen (or all of the screen!), depending on what method
    ///  SDL uses to send pixels to the system.
    /// </summary>
    /// <param name="ARects">An array of TSdlRect records representing areas of
    ///  the surface to copy, in pixels.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Surface"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateSurface(const ARects: array of TSdlRect); overload;

    /// <summary>
    ///  Destroy the surface associated with the window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Surface"/>
    /// <seealso cref="HasSurface"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure FreeSurface; inline;

    /// <summary>
    ///  Display the system-level window menu.
    ///
    ///  This default window menu is provided by the system and on some platforms
    ///  provides functionality for setting or changing privileged state on the
    ///  window, such as moving it between workspaces or displays, or toggling the
    ///  always-on-top property.
    ///
    ///  On platforms or desktops where this is unsupported, this function does
    ///  nothing.
    /// </summary>
    /// <param name="AX">The X coordinate of the menu, relative to the origin
    ///  (top-left) of the client area.</param>
    /// <param name="AY">The Y coordinate of the menu, relative to the origin
    ///  (top-left) of the client area.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure ShowSystemMenu(const AX, AY: Integer); inline;

    /// <summary>
    ///  Request a window to demand attention from the user.
    /// </summary>
    /// <param name="AOperation">The operation to perform.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This function should only be called on the main thread.
    /// </remarks>
    procedure Flash(const AOperation: TSdlFlashOperation); inline;

    /// <summary>
    ///  Start accepting Unicode text input events in the window.
    ///
    ///  This function will enable text input (TSdlEventKind.TextInput and
    ///  TSdlEventKind.TextEditing events) in this window. Please use this
    ///  function paired with StopTextInput.
    ///
    ///  Text input events are not received by default.
    ///
    ///  On some platforms using this method shows the screen keyboard and/or
    ///  activates an IME, which can prevent some key press events from being passed
    ///  through.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetTextInputArea"/>
    /// <seealso cref="StopTextInput"/>
    /// <seealso cref="TextInputActive"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure StartTextInput; overload; inline;

    /// <summary>
    ///  Start accepting Unicode text input events in the window, with properties
    ///  describing the input.
    ///
    ///  This function will enable text input (TSdlEventKind.TextInput and
    ///  TSdlEventKind.TextEditing events) in this window. Please use this
    ///  function paired with StopTextInput.
    ///
    ///  Text input events are not received by default.
    ///
    ///  On some platforms using this function shows the screen keyboard and/or
    ///  activates an IME, which can prevent some key press events from being passed
    ///  through.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlProperty.TextInputType` - a TSdlTextInputType value that
    ///    describes text being input, defaults to TSdlTextInputType.Text.
    ///  - `TSdlProperty.TextInputCapitalization` - a TSdlCapitalization value
    ///    that describes how text should be capitalized, defaults to
    ///    TSdlCapitalization.Sentences for normal text entry,
    ///    TSdlCapitalization.Word for TSdlTextInputTYpe.TextName, and
    ///    TSdlCapitalization.None for e-mail addresses, usernames, and passwords.
    ///  - `TSdlProperty.TextInputAutoCorrect` - True to enable auto completion
    ///    and auto correction, defaults to True.
    ///  - `TSdlProperty.TextInputMultiLine` - True if multiple lines of text
    ///    are allowed. This defaults to True if TSdlHints.ReturnKeyHidesIme is
    ///    '0' or is not set, and defaults to False if TSdlHints.ReturnKeyHidesIme
    ///    is '1'.
    ///
    ///  On Android you can directly specify the input type:
    ///
    ///  - `TSdlProperty.TextInputAndroidInputType` - the text input type to
    ///    use, overriding other properties. This is documented at
    ///    <see href="https://developer.android.com/reference/android/text/InputType">InputType</see>.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetTextInputArea"/>
    /// <seealso cref="StopTextInput"/>
    /// <seealso cref="TextInputActive"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure StartTextInput(const AProps: TSdlProperties); overload; inline;

    /// <summary>
    ///  Stop receiving any text input events in the window.
    ///
    ///  If StartTextInput showed the screen keyboard, this function will hide
    ///  it.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="StartTextInput"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure StopTextInput;

    /// <summary>
    ///  Dismiss the composition window/IME without disabling the subsystem.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="StartTextInput"/>
    /// <seealso cref="StopTextInput"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure ClearComposition; inline;

    /// <summary>
    ///  Clear the area used to type Unicode text input.
    ///
    ///  Native input methods may place a window with word suggestions near the
    ///  cursor, without covering the text being entered.
    /// </summary>
    /// <param name="ACursor">The offset of the current cursor location relative
    ///  to left position of the window, in window coordinates.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetTextInputArea"/>
    /// <seealso cref="SetTextInputArea"/>
    /// <seealso cref="StartTextInput"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure ClearTextInputArea(const ACursor: Integer); inline;

    /// <summary>
    ///  Set the area used to type Unicode text input.
    ///
    ///  Native input methods may place a window with word suggestions near the
    ///  cursor, without covering the text being entered.
    /// </summary>
    /// <param name="ARect">The text input area, in window coordinates.</param>
    /// <param name="ACursor">The offset of the current cursor location relative
    ///  to `ARect.X`, in window coordinates.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetTextInputArea"/>
    /// <seealso cref="ClearTextInputArea"/>
    /// <seealso cref="StartTextInput"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetTextInputArea(const ARect: TSdlRect; const ACursor: Integer); inline;

    /// <summary>
    ///  Get the area used to type Unicode text input.
    ///
    ///  This returns the values previously set by SetTextInputArea.
    /// </summary>
    /// <param name="ARect">Is set to the text input area.</param>
    /// <param name="ACursor">Is set to the current cursor location relative to
    ///  `ARect.X`.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetTextInputArea"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetTextInputArea(out ARect: TSdlRect; out ACursor: Integer); inline;

    /// <summary>
    ///  Move the mouse cursor to the given position within the window.
    ///
    ///  This method generates a mouse motion event if relative mode is not
    ///  enabled. If relative mode is enabled, you can force mouse events for the
    ///  warp by setting the TSdlHints.MouseRelativeWarpMotion hint.
    ///
    ///  Note that this function will appear to succeed, but not actually move the
    ///  mouse when used over Microsoft Remote Desktop.
    /// </summary>
    /// <param name="AX">The X coordinate within the window.</param>
    /// <param name="AY">The Y coordinate within the window.</param>
    /// <seealso cref="TSdlMouse.WarpGlobal"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure WarpMouse(const AX, AY: Single); overload; inline;

    /// <summary>
    ///  Move the mouse cursor to the given position within the window.
    ///
    ///  This method generates a mouse motion event if relative mode is not
    ///  enabled. If relative mode is enabled, you can force mouse events for the
    ///  warp by setting the TSdlHints.MouseRelativeWarpMotion hint.
    ///
    ///  Note that this function will appear to succeed, but not actually move the
    ///  mouse when used over Microsoft Remote Desktop.
    /// </summary>
    /// <param name="APosition">The coordinate within the window.</param>
    /// <seealso cref="TSdlMouse.WarpGlobal"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure WarpMouse(const APosition: TSdlPointF); overload; inline;

    /// <summary>
    ///  The numeric ID of the window.
    ///
    ///  The numeric ID is what TSdlWindowEvent references, and is necessary to map
    ///  these events to specific TSdlWindow objects.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FromID"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ID: TSdlWindowID read GetID;

    /// <summary>
    ///  The parent of the window or `nil` if the window has no parent.
    ///
    ///  When setting this property, if the window is already the child of an
    ///  existing window, it will be reparented to the new owner. Setting the
    ///  parent window to `nil` unparents the window and removes child window status.
    ///
    ///  If a parent window is hidden or destroyed, the operation will be
    ///  recursively applied to child windows. Child windows hidden with the parent
    ///  that did not have their hidden status explicitly set will be restored when
    ///  the parent is shown.
    ///
    ///  Attempting to set the parent of a window that is currently in the modal
    ///  state will fail. Use Modal to cancel the modal status before
    ///  attempting to change the parent.
    ///
    ///  Popup windows cannot change parents and attempts to do so will fail.
    ///
    ///  Setting a parent window that is currently the sibling or descendent of the
    ///  child window results in undefined behavior.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Parent: TSdlWindow read GetParent write SetParent;

    /// <summary>
    ///  The display associated with this window (that is, the display
    ///  containing the center of this window).
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlDisplay.Bounds"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Display: TSdlDisplay read GetDisplay;

    /// <summary>
    ///  The pixel density of the window.
    ///
    ///  This is a ratio of pixel size to window size. For example, if the window is
    ///  1920x1080 and it has a high density back buffer of 3840x2160 pixels, it
    ///  would have a pixel density of 2.0.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DisplayScale"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property PixelDensity: Single read GetPixelDensity;

    /// <summary>
    ///  The content display scale relative to a window's pixel size.
    ///
    ///  This is a combination of the window pixel density and the display content
    ///  scale, and is the expected scale for displaying content in this window. For
    ///  example, if a 3840x2160 window had a display scale of 2.0, the user expects
    ///  the content to take twice as many pixels and be the same physical size as
    ///  if it were being displayed in a 1920x1080 window with a display scale of
    ///  1.0.
    ///
    ///  Conceptually this value corresponds to the scale display setting, and is
    ///  updated when that setting is changed, or the window moves to a display with
    ///  a different scale setting.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property DisplayScale: Single read GetDisplayScale;

    /// <summary>
    ///  The display mode to use when a window is visible and fullscreen.
    ///  This is a pointer to the display mode to use, which can be `nil` for
    ///  borderless fullscreen desktop mode, or one of the fullscreen modes
    ///  returned by TSdlDisplay.FullscreenModes for an exclusive fullscreen mode.
    ///
    ///  This only affects the display mode used when the window is fullscreen. To
    ///  change the window size when the window is not fullscreen, use Size.
    ///
    ///  If the window is currently in the fullscreen state, this request is
    ///  asynchronous on some windowing systems and the new mode dimensions may not
    ///  be applied immediately upon the return of this function. If an immediate
    ///  change is required, call Sync to block until the changes have taken effect.
    ///
    ///  When the new mode takes effect, an TSdlEventKind.WindowResized and/or an
    ///  TSdlEventKind.WindowPixelSizeChanged event will be emitted with the new
    ///  mode dimensions.
    /// </summary>
    /// <exception name="ESdlError">Raised when setting the mode failed.</exception>
    /// <seealso cref="Fullscreen"/>
    /// <seealso cref="Sync"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property FullscreenMode: PSdlDisplayMode read GetFullscreenMode write SetFullscreenMode;

    /// <summary>
    ///  The raw ICC profile data for the screen the window is currently on.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property IccProfile: TBytes read GetIccProfile;

    /// <summary>
    ///  The pixel format associated with the window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property PixelFormat: TSdlPixelFormat read GetPixelFormat;

    /// <summary>
    ///  The window flags.
    /// </summary>
    /// <seealso cref="Create"/>
    /// <seealso cref="Hide"/>
    /// <seealso cref="Maximize"/>
    /// <seealso cref="Minimize"/>
    /// <seealso cref="Fullscreen"/>
    /// <seealso cref="MouseGrab"/>
    /// <seealso cref="Show"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Flags: TSdlWindowFlags read GetFlags;

    /// <summary>
    ///  The title of the window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Title: String read GetTitle write SetTitle;

    /// <summary>
    ///  Set the icon for the window.
    ///
    ///  If this property is a surface with alternate representations, the
    ///  surface will be interpreted as the content to be used for 100% display
    ///  scale, and the alternate representations will be used for high DPI
    ///  situations. For example, if the original surface is 32x32, then on a 2x
    ///  macOS display or 200% display scale on Windows, a 64x64 version of the
    ///  image will be used, if available. If a matching version of the image isn't
    ///  available, the closest larger size image will be downscaled to the
    ///  appropriate size and be used instead, if available. Otherwise, the closest
    ///  smaller image will be upscaled and be used instead.
    /// </summary>
    /// <param name="AIcon">A TSdlSurface containing the icon for the window.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Icon: TSdlSurface write SetIcon;

    /// <summary>
    ///  The position of the window. See SetPosition and GetPosition for more
    ///  information.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Position: TSdlPoint read GetPositionPoint write SetPositionPoint;

    /// <summary>
    ///  The size of the window. See SetSize and GetSize for more information.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Size: TSdlSize read GetSizeSize write SetSizeSize;

    /// <summary>
    ///  The size of the window in pixels. See GetSizeInPixels for more information.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property SizeInPixels: TSdlSize read GetSizeInPixelsSize;

    /// <summary>
    ///  The minimum size of the window's client area.
    ///  See GetMinimumSize and SetMinimumSize for more information.
    /// </summary>
    property MinimumSize: TSdlSize read GetMinimumSizeSize write SetMinimumSizeSize;

    /// <summary>
    ///  The maximum size of the window's client area.
    ///  See GetMaximumSize and SetMaximumSize for more information.
    /// </summary>
    property MaximumSize: TSdlSize read GetMaximumSizeSize write SetMaximumSizeSize;

    /// <summary>
    ///  The safe area for this window.
    ///
    ///  Some devices have portions of the screen which are partially obscured or
    ///  not interactive, possibly due to on-screen controls, curved edges, camera
    ///  notches, TV overscan, etc. This function provides the area of the window
    ///  which is safe to have interactable content. You should continue rendering
    ///  into the rest of the window, but it should not contain visually important
    ///  or interactible content.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property SafeArea: TSdlRect read GetSafeArea;

    /// <summary>
    ///  The border state of the window.
    ///
    ///  This will add or remove the window's `TSdlWindowFlag.Borderless` flag
    ///  and add or remove the border from the actual window. This is a no-op if
    ///  the window's border already matches the requested state.
    ///
    ///  You can't change the border state of a fullscreen window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Flags"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Bordered: Boolean read GetBordered write SetBordered;

    /// <summary>
    ///  The user-resizable state of the window.
    ///
    ///  This will add or remove the window's `TSdlWindowFlag.Resizable` flag and
    ///  allow/disallow user resizing of the window. This is a no-op if the window's
    ///  resizable state already matches the requested state.
    ///
    ///  You can't change the resizable state of a fullscreen window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Flags"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Resizable: Boolean read GetResizable write SetResizable;

    /// <summary>
    ///  The window "always on top" state of the window.
    ///
    ///  This will add or remove the window's `TSdlWindowFlag.AlwaysOnTop` flag.
    ///  This will bring the window to the front and keep the window above the rest.
    /// </summary>
    /// <returns>true on success or false on failure; call SDL_GetError() for more information.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Flags"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property AlwaysOnTop: Boolean read GetAlwaysOnTop write SetAlwaysOnTop;

    /// <summary>
    ///  The window's fullscreen state.
    ///
    ///  By default a window in fullscreen state uses borderless fullscreen desktop
    ///  mode, but a specific exclusive display mode can be set using
    ///  FullscreenMode.
    ///
    ///  On some windowing systems setting this property is asynchronous and the new
    ///  fullscreen state may not have have been applied immediately upon the return
    ///  of this function. If an immediate change is required, call Sync
    ///  to block until the changes have taken effect.
    ///
    ///  When the window state changes, an TSdlEventKind.WindowEnterFullscreen or
    ///  TSdlEventKind.WindowLeaveFullscreen event will be emitted. Note that, as this
    ///  is just a request, it can be denied by the windowing system.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FullscreenMode"/>
    /// <seealso cref="Sync"/>
    /// <seealso cref="TSdlWindowFlag"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Fullscreen: Boolean read GetFullscreen write SetFullscreen;

    /// <summary>
    ///  Whether the window has a surface associated with it.
    /// </summary>
    /// <seealso cref="Surface"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property HasSurface: Boolean read GetHasSurface;

    /// <summary>
    ///  The SDL surface associated with the window.
    ///
    ///  A new surface will be created with the optimal format for the window, if
    ///  necessary. This surface will be freed when the window is destroyed. Do not
    ///  free this surface.
    ///
    ///  This surface will be invalidated if the window is resized. After resizing a
    ///  window this function must be called again to return a valid surface.
    ///
    ///  You may not combine this with 3D or the rendering API on this window.
    ///
    ///  This function is affected by `TSdlHints.FramebufferAcceleration`.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FreeSurface"/>
    /// <seealso cref="HasSurface"/>
    /// <seealso cref="UpdateSurface"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Surface: TSdlSurface read GetSurface;

    /// <summary>
    ///  The VSync for the window surface.
    ///
    ///  When a window surface is created, vsync defaults to
    ///  TSdlWindowSurfaceVsync.Disabled.
    ///
    ///  The property can be 1 to synchronize present with every vertical
    ///  refresh, 2 to synchronize present with every second vertical refresh,
    ///  etc., TSdlWindowSurfaceVsync.Adaptive for late swap tearing (adaptive vsync),
    ///  or TSdlWindowSurfaceVsync.Disabled to disable. Not every value is
    ///  supported by every driver, so you should check the return value to see
    ///  whether the requested setting is supported.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property SurfaceVSync: TSdlWindowSurfaceVsync read GetSurfaceVSync write SetSurfaceVSync;

    /// <summary>
    ///  The window's keyboard grab mode.
    ///
    ///  Keyboard grab enables capture of system keyboard shortcuts like Alt+Tab or
    ///  the Meta/Super key. Note that not all system keyboard shortcuts can be
    ///  captured by applications (one example is Ctrl+Alt+Del on Windows).
    ///
    ///  This is primarily intended for specialized applications such as VNC clients
    ///  or VM frontends. Normal games should not use keyboard grab.
    ///
    ///  When keyboard grab is enabled, SDL will continue to handle Alt+Tab when the
    ///  window is full-screen to ensure the user is not trapped in your
    ///  application. If you have a custom keyboard shortcut to exit fullscreen
    ///  mode, you may suppress this behavior with TSdlHints.AllowAltTabWhileGrabbed.
    ///
    ///  If the caller enables a grab while another window is currently grabbed, the
    ///  other window loses its grab in favor of the caller's window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MouseGrab"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property KeyboardGrab: Boolean read GetKeyboardGrab write SetKeyboardGrab;

    /// <summary>
    ///  The window's mouse grab mode.
    ///
    ///  Mouse grab confines the mouse cursor to the window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MouseRect"/>
    /// <seealso cref="KeyboardGrab"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property MouseGrab: Boolean read GetMouseGrab write SetMouseGrab;

    /// <summary>
    ///  The mouse confinement rectange of the window.
    ///
    ///  Note that setting this does NOT grab the cursor, it only defines the
    ///  area a cursor is restricted to when the window has mouse focus.
    ///
    ///  This property is a pointer to a rectangle in window-relative coordinates,
    ///  or nil if there isn't a confinement rectangle.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MouseGrab"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property MouseRect: PSdlRect read GetMouseRect write SetMouseRect;

    /// <summary>
    ///  The opacity of the window, which will be clamped internally between 0.0
    ///  (transparent) and 1.0 (opaque). Will be 1.0 (opaque) on platforms that
    ///  don't support opacity.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Opacity: Single read GetOpacity write SetOpacity;

    /// <summary>
    ///  The modal state of the window.
    ///
    ///  To enable modal status on a window, the window must currently be the child
    ///  window of a parent, or toggling modal status on will fail.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Parent"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Modal: Boolean read GetModal write SetModal;

    /// <summary>
    ///  Whether the window may have input focus.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Focusable: Boolean read GetFocusable write SetFocusable;

    /// <summary>
    ///  The shape of the transparent window, or `nil` if the window has no
    ///  shape (or to remove the shape).
    ///
    ///  This sets the alpha channel of a transparent window and any fully
    ///  transparent areas are also transparent to mouse clicks. If you are using
    ///  something besides the SDL render API, then you are responsible for drawing
    ///  the alpha channel of the window to match the shape alpha channel to get
    ///  consistent cross-platform results.
    ///
    ///  The shape is copied inside this function, so you can free it afterwards. If
    ///  your shape surface changes, you should set this property again to
    ///  update the window. This is an expensive operation, so should be done
    ///  sparingly.
    ///
    ///  The window must have been created with the TSdlWindowFlag.Transparent flag.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Shape: TSdlSurface read GetShape write SetShape;

    /// <summary>
    ///  Whether or not Unicode text input events are enabled for the window.
    /// </summary>
    /// <seealso cref="StartTextInput"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property TextInputActive: Boolean read GetTextInputActive;

    /// <summary>
    ///  Whether the screen keyboard is shown for the window.
    /// </summary>
    /// <seealso cref="TSdlKeyboard.HasScreenKeyboardSupport"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property IsScreenKeyboardShown: Boolean read GetIsScreenKeyboardShown;

    /// <summary>
    ///  Whether relative mouse mode for the window is eneabled.
    ///
    ///  While the window has focus and relative mouse mode is enabled, the cursor
    ///  is hidden, the mouse position is constrained to the window, and SDL will
    ///  report continuous relative mouse motion even if the mouse is at the edge of
    ///  the window.
    ///
    ///  If you'd like to keep the mouse position fixed while in relative mode you
    ///  can use MouseRect. If you'd like the cursor to be at a specific location
    ///  when relative mode ends, you should use WarpMouse before disabling
    ///  relative mode.
    ///
    ///  This method will flush any pending mouse motion for this window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property IsRelativeMouseMode: Boolean read GetIsRelativeMouseMode write SetIsRelativeMouseMode;

    /// <summary>
    ///  The properties associated with a window.
    ///
    ///  The following read-only properties are provided by SDL:
    ///
    ///  - `TSdlProperty.WindowShape`: The surface associated with a shaped
    ///    window
    ///  - `TSdlProperty.WindowHdrEnabled`: True if the window has HDR headroom
    ///    above the SDR white point. This property can change dynamically
    ///    when TSdlEventKind.WindowHdrStateChanged is sent.
    ///  - `TSdlProperty.WindowSdrWhiteLevel`: the value of SDR white in the
    ///    TSdlColorspace.SrgbLinear colorspace. On Windows this corresponds to
    ///    the SDR white level in scRGB colorspace, and on Apple platforms this
    ///    is always 1.0 for EDR content. This property can change dynamically
    ///    when TSdlEventKind.WindowHdrStateChanged is sent.
    ///  - `TSdlProperty.WindowHdrHeadroom`: The additional high dynamic range
    ///    that can be displayed, in terms of the SDR white point. When HDR is not
    ///    enabled, this will be 1.0. This property can change dynamically when
    ///    TSdlEventKind.WindowHdrStateChanged is sent.
    ///
    ///  On Android:
    ///
    ///  - `TSdlProperty.WindowAndroidWindow`: The ANativeWindow associated
    ///    with the window
    ///  - `TSdlProperty.WindowAndroidSurface`: The EGLSurface associated with
    ///    the window
    ///
    ///  On iOS:
    ///
    ///  - `TSdlProperty.WindowUIKitWindow`: The UIWindow handle associated with
    ///    the window
    ///  - `TSdlProperty.WindowUIKitMetalViewTag`: The NSInteger handle tag
    ///    associated with metal views on the window
    ///  - `TSdlProperty.WindowUIKitOpenGLFramebuffer`: The OpenGL view's
    ///    framebuffer object. It must be bound when rendering to the screen using
    ///    OpenGL.
    ///  - `TSdlProperty.WindowUIKitOpenGLRenderbuffer`: the OpenGL view's
    ///    renderbuffer object. It must be bound when TSdlGL.SwapWindow is called.
    ///  - `TSdlProperty.WindowUIKitOpenGLResolveFramebuffer`: the OpenGL
    ///    view's resolve framebuffer, when MSAA is used.
    ///
    ///  On macOS:
    ///
    ///  - `TSdlProperty.WindowCocoaWindow`: The NSWindow handle associated with
    ///    the window
    ///  - `TSdlProperty.WindowCocoaMetalViewTag`: The NSInteger handle tag
    ///    assocated with metal views on the window
    ///
    ///  On Windows:
    ///
    ///  - `TSdlProperty.WindowWin32Hwnd`: the HWND associated with the window
    ///  - `TSdlProperty.WindowWin32Hdc`: the HDC associated with the window
    ///  - `TSdlProperty.WindowWin32Instance`: the HINSTANCE associated with
    ///    the window
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;

    /// <summary>
    ///  A list of valid windows.
    /// </summary>
    /// <exception> name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Windows: TArray<TSdlWindow> read GetWindows;

    /// <summary>
    ///  The window that currently has an input grab enabled, or nil otherwise.
    /// </summary>
    /// <seealso cref="MouseGrab"/>
    /// <seealso cref="KeyboardGrab"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property GrabbedWindow: TSdlWindow read GetGrabbedWindow;

    /// <summary>
    ///  The window which currently has keyboard focus.
    /// </summary>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property WithKeyboardFocus: TSdlWindow read GetWithKeyboardFocus;
  end;

type
  /// <summary>
  ///  Possible return values from the TSdlWindow.SetHitTestCallback.
  /// </summary>
  /// <seealso cref="TSdlHitTestCallback"/>
  /// <remarks>
  ///  This enum is available since SDL 3.2.0.
  ///
  ///  This function should only be called on the main thread.
  /// </remarks>
  TSdlHitTestResult = (
    /// <summary>Region is normal. No special properties.</summary>
    Normal            = SDL_HITTEST_NORMAL,

    /// <summary>Region can drag entire window.</summary>
    Draggable         = SDL_HITTEST_DRAGGABLE,

    /// <summary>Region is the resizable top-left corner border.</summary>
    ResizeTopLeft     = SDL_HITTEST_RESIZE_TOPLEFT,

    /// <summary>Region is the resizable top border.</summary>
    ResizeTop         = SDL_HITTEST_RESIZE_TOP,

    /// <summary>Region is the resizable top-right corner border.</summary>
    ResizeTopRight    = SDL_HITTEST_RESIZE_TOPRIGHT,

    /// <summary>Region is the resizable right border.</summary>
    ResizeRight       = SDL_HITTEST_RESIZE_RIGHT,

    /// <summary>Region is the resizable bottom-right corner border.</summary>
    ResizeBottomRight = SDL_HITTEST_RESIZE_BOTTOMRIGHT,

    /// <summary>Region is the resizable bottom border.</summary>
    ResizeBottom      = SDL_HITTEST_RESIZE_BOTTOM,

    /// <summary>Region is the resizable bottom-left corner border.</summary>
    ResizeBottomLeft  = SDL_HITTEST_RESIZE_BOTTOMLEFT,

    /// <summary>Region is the resizable left border.</summary>
    ResizeLeft        = SDL_HITTEST_RESIZE_LEFT);

type
  /// <summary>
  ///  Callback used for hit-testing.
  /// </summary>
  /// <param name="AWin">The TSdlWindow where hit-testing was set on.</param>
  /// <param name="AArea">A TSdlPoint which should be hit-tested.</param>
  /// <returns>A TSdlHitTestResult value.</returns>
  /// <seealso cref="TSdlWindow.SetHitTestCallback"/>
  TSdlHitTestCallback = function(const AWin: TSdlWindow;
    const AArea: TSdlPoint): TSdlHitTestResult of object;

type
  _TSdlWindowHelper = record helper for TSdlWindow
  {$REGION 'Internal Declarations'}
  private type
    THitTestInfo = class
    public
      Callback: TSdlHitTestCallback;
    end;
  private class var
    FHitTestInfo: TObjectDictionary<SDL_Window, THitTestInfo>;
  private
    class function WindowHitTest(AWin: SDL_Window; const AArea: PSDL_Point;
      AData: Pointer): SDL_HitTestResult; cdecl; inline; static;
  public
    class destructor Destroy;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Provide a callback that decides if a window region has special properties.
    ///
    ///  Normally windows are dragged and resized by decorations provided by the
    ///  system window manager (a title bar, borders, etc), but for some apps, it
    ///  makes sense to drag them from somewhere else inside the window itself; for
    ///  example, one might have a borderless window that wants to be draggable from
    ///  any part, or simulate its own title bar, etc.
    ///
    ///  This function lets the app provide a callback that designates pieces of a
    ///  given window as special. This callback is run during event processing if we
    ///  need to tell the OS to treat a region of the window specially; the use of
    ///  this callback is known as "hit testing."
    ///
    ///  Mouse input may not be delivered to your application if it is within a
    ///  special area; the OS will often apply that input to moving the window or
    ///  resizing the window and not deliver it to the application.
    ///
    ///  Specifying `nil` for a callback disables hit-testing. Hit-testing is
    ///  disabled by default.
    ///
    ///  Platforms that don't support this functionality will return False
    ///  unconditionally, even if you're attempting to disable hit-testing.
    ///
    ///  Your callback may fire at any time, and its firing does not indicate any
    ///  specific behavior (for example, on Windows, this certainly might fire when
    ///  the OS is deciding whether to drag your window, but it fires for lots of
    ///  other reasons, too, some unrelated to anything you probably care about _and
    ///  when the mouse isn't actually at the location it is testing_). Since this
    ///  can fire at any time, you should try to keep your callback efficient,
    ///  devoid of allocations, etc.
    /// </summary>
    /// <param name="ACallback">The function to call when doing a hit-test.</param>
    /// <returns>True on success or False on failure (eg. when the platform does
    ///  not support hit-testing.</returns>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function SetHitTestCallback(const ACallback: TSdlHitTestCallback): Boolean;
  end;
{$ENDREGION 'Display and Window Management'}

{$REGION '2D Accelerated Rendering'}
/// <summary>
///  SDL 2D rendering functions.
///
///  This API supports the following features:
///
///  - single pixel points
///  - single pixel lines
///  - filled rectangles
///  - texture images
///  - 2D polygons
///
///  The primitives may be drawn in opaque, blended, or additive modes.
///
///  The texture images may be drawn in opaque, blended, or additive modes. They
///  can have an additional color tint or alpha modulation applied to them, and
///  may also be stretched with linear interpolation.
///
///  This API is designed to accelerate simple 2D operations. You may want more
///  functionality such as polygons and particle effects and in that case you
///  should use SDL's OpenGL/Direct3D support, the SDL3 GPU API, or one of the
///  many good 3D engines.
///
///  These functions must be called from the main thread. 
///  See <see href="https://github.com/libsdl-org/SDL/issues/986">this bug</see> 
///  for details.
/// </summary>

const
  /// <summary>
  ///  The name of the software renderer.
  /// </summary>
  SDL_SOFTWARE_RENDERER = Neslib.Sdl3.Api.SDL_SOFTWARE_RENDERER;

type
  /// <summary>
  ///  Vertex structure.
  /// </summary>
  TSdlVertex = record
  public
    /// <summary>
    ///  Vertex position, in SDL_Renderer coordinates
    /// </summary>
    Position: TSdlPointF;

    /// <summary>
    ///  Vertex color
    /// </summary>
    Color: TSdlColorF;

    /// <summary>
    ///  Normalized texture coordinates, if needed
    /// </summary>
    TexCoord: TSdlPointF;
  end;
  PSdlVertex = ^TSdlVertex;

type
  /// <summary>
  ///  The access pattern allowed for a texture.
  /// </summary>
  TSdlTextureAccess = (
    /// <summary>
    ///  Changes rarely, not lockable
    /// </summary>
    &Static   = SDL_TEXTUREACCESS_STATIC,

    /// <summary>
    ///  Changes frequently, lockable
    /// </summary>
    Streaming = SDL_TEXTUREACCESS_STREAMING,

    /// <summary>
    ///  Texture can be used as a render target
    /// </summary>
    Target    = SDL_TEXTUREACCESS_TARGET);

type
  /// <summary>
  ///  How the logical size is mapped to the output.
  /// </summary>
  TSdlRendererLogicalPresentation = (
    /// <summary>
    ///  There is no logical size in effect
    /// </summary>
    Disabled     = SDL_LOGICAL_PRESENTATION_DISABLED,

    /// <summary>
    ///  The rendered content is stretched to the output resolution
    /// </summary>
    Stretch      = SDL_LOGICAL_PRESENTATION_STRETCH,

    /// <summary>
    ///  The rendered content is fit to the largest dimension and the other
    ///  dimension is letterboxed with black bars
    /// </summary>
    Letterbox    = SDL_LOGICAL_PRESENTATION_LETTERBOX,

    /// <summary>
    ///  The rendered content is fit to the smallest dimension and the other
    ///  dimension extends beyond the output bounds
    /// </summary>
    Overscan     = SDL_LOGICAL_PRESENTATION_OVERSCAN,

    /// <summary>
    ///  The rendered content is scaled up by integer multiples to fit the
    ///  output resolution
    /// </summary>
    IntegerScale = SDL_LOGICAL_PRESENTATION_INTEGER_SCALE);

type
  /// <summary>
  ///  An efficient driver-specific representation of pixel data.
  ///  To create a texture, use TSdlRenderer.CreateTexture.
  /// </summary>
  TSdlTexture = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PSDL_Texture;
    function GetFormat: TSdlPixelFormat; inline;
    function GetW: Integer; inline;
    function GetH: Integer; inline;
    function GetSize: TSdlSizeF; inline;
    function GetColorMod: TSdlColor; inline;
    procedure SetColorMod(const AValue: TSdlColor); inline;
    function GetColorModFloat: TSdlColorF; inline;
    procedure SetColorModFloat(const AValue: TSdlColorF); inline;
    function GetAlphaMod: Byte; inline;
    procedure SetAlphaMod(const AValue: Byte); inline;
    function GetAlphaModFloat: Single; inline;
    procedure SetAlphaModFloat(const AValue: Single); inline;
    function GetBlendMode: TSdlBlendMode; inline;
    procedure SetBlendMode(const AValue: TSdlBlendMode); inline;
    function GetScaleMode: TSdlScaleMode; inline;
    procedure SetScaleMode(const AValue: TSdlScaleMode); inline;
    function GetProperties: TSdlProperties; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTexture; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTexture.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlTexture): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTexture; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTexture.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlTexture): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTexture; inline; static;
  public
    /// <summary>
    ///  Destroy the texture.
    /// </summary>
    /// <seealso cref="TSdlRenderer.CreateTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Update the entire texture with new pixel data.
    ///
    ///  The pixel data must be in the pixel format of the texture, which can be
    ///  queried using the TSdlProperty.TextureFormat property.
    ///
    ///  This is a fairly slow function, intended for use with static textures that
    ///  do not change often.
    ///
    ///  If the texture is intended to be updated often, it is preferred to create
    ///  the texture as streaming and use the locking functions referenced below.
    ///  While this function will work with streaming textures, for optimization
    ///  reasons you may not get the pixels back if you lock the texture afterward.
    /// </summary>
    /// <param name="APixels">The raw pixel data in the format of the texture.</param>
    /// <param name="APitch">The number of bytes in a row of pixel data,
    ///  including padding between lines.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Lock"/>
    /// <seealso cref="Unlock"/>
    /// <seealso cref="UpdateNV"/>
    /// <seealso cref="UpdateYuv"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Update(const APixels: Pointer; const APitch: Integer); overload;

    /// <summary>
    ///  Update the given texture rectangle with new pixel data.
    ///
    ///  The pixel data must be in the pixel format of the texture, which can be
    ///  queried using the TSdlProperty.TextureFormat property.
    ///
    ///  This is a fairly slow function, intended for use with static textures that
    ///  do not change often.
    ///
    ///  If the texture is intended to be updated often, it is preferred to create
    ///  the texture as streaming and use the locking functions referenced below.
    ///  While this function will work with streaming textures, for optimization
    ///  reasons you may not get the pixels back if you lock the texture afterward.
    /// </summary>
    /// <param name="ARect">The area to update.</param>
    /// <param name="APixels">The raw pixel data in the format of the texture.</param>
    /// <param name="APitch">The number of bytes in a row of pixel data,
    ///  including padding between lines.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Lock"/>
    /// <seealso cref="Unlock"/>
    /// <seealso cref="UpdateNV"/>
    /// <seealso cref="UpdateYuv"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Update(const ARect: TSdlRect; const APixels: Pointer;
      const APitch: Integer); overload;

    /// <summary>
    ///  Update the entire planar YV12 or IYUV texture with new pixel data.
    ///
    ///  You can use Update as long as your pixel data is a contiguous
    ///  block of Y and U/V planes in the proper order, but this function is
    ///  available if your pixel data is not contiguous.
    /// </summary>
    /// <param name="AYPlane">The raw pixel data for the Y plane.</param>
    /// <param name="AYPitch">The number of bytes between rows of pixel data
    ///  for the Y plane.</param>
    /// <param name="AUPlane">The raw pixel data for the U plane.</param>
    /// <param name="AUPitch">The number of bytes between rows of pixel data
    ///  for the U plane.</param>
    /// <param name="AVPlane">The raw pixel data for the V plane.</param>
    /// <param name="AVPitch">The number of bytes between rows of pixel data
    ///  for the V plane.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="UpdateNV"/>
    /// <seealso cref="Update"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateYuv(
      const AYPlane: Pointer; const AYPitch: Integer;
      const AUPlane: Pointer; const AUPitch: Integer;
      const AVPlane: Pointer; const AVPitch: Integer); overload;

    /// <summary>
    ///  Update a rectangle within a planar YV12 or IYUV texture with new pixel
    ///  data.
    ///
    ///  You can use Update as long as your pixel data is a contiguous
    ///  block of Y and U/V planes in the proper order, but this function is
    ///  available if your pixel data is not contiguous.
    /// </summary>
    /// <param name="ARect">The rectangle of pixels to update.</param>
    /// <param name="AYPlane">The raw pixel data for the Y plane.</param>
    /// <param name="AYPitch">The number of bytes between rows of pixel data
    ///  for the Y plane.</param>
    /// <param name="AUPlane">The raw pixel data for the U plane.</param>
    /// <param name="AUPitch">The number of bytes between rows of pixel data
    ///  for the U plane.</param>
    /// <param name="AVPlane">The raw pixel data for the V plane.</param>
    /// <param name="AVPitch">The number of bytes between rows of pixel data
    ///  for the V plane.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="UpdateNV"/>
    /// <seealso cref="Update"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateYuv(const ARect: TSdlRect;
      const AYPlane: Pointer; const AYPitch: Integer;
      const AUPlane: Pointer; const AUPitch: Integer;
      const AVPlane: Pointer; const AVPitch: Integer); overload;

    /// <summary>
    ///  Update the entire planar NV12 or NV21 texture with new pixels.
    ///
    ///  You can use Update as long as your pixel data is a contiguous block of
    ///  NV12/21 planes in the proper order, but this function is available
    ///  if your pixel data is not contiguous.
    /// </summary>
    /// <param name="AYPlane">The raw pixel data for the Y plane.</param>
    /// <param name="AYPitch">The number of bytes between rows of pixel data for
    ///  the Y plane.</param>
    /// <param name="AUVPlane">The raw pixel data for the UV plane.</param>
    /// <param name="AUVPitch">The number of bytes between rows of pixel data
    ///  for the UV plane.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Update"/>
    /// <seealso cref="UpdateYuv"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateNV(const AYPlane: Pointer; const AYPitch: Integer;
      const AUVPlane: Pointer; const AUVPitch: Integer); overload;

    /// <summary>
    ///  Update a rectangle within a planar NV12 or NV21 texture with new pixels.
    ///
    ///  You can use Update as long as your pixel data is a contiguous block of
    ///  NV12/21 planes in the proper order, but this function is available
    ///  if your pixel data is not contiguous.
    /// </summary>
    /// <param name="ARect">The rectangle of pixels to update.</param>
    /// <param name="AYPlane">The raw pixel data for the Y plane.</param>
    /// <param name="AYPitch">The number of bytes between rows of pixel data for
    ///  the Y plane.</param>
    /// <param name="AUVPlane">The raw pixel data for the UV plane.</param>
    /// <param name="AUVPitch">The number of bytes between rows of pixel data
    ///  for the UV plane.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Update"/>
    /// <seealso cref="UpdateYuv"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure UpdateNV(const ARect: TSdlRect;
      const AYPlane: Pointer; const AYPitch: Integer;
      const AUVPlane: Pointer; const AUVPitch: Integer); overload;

    /// <summary>
    ///  Lock the entire texture for **write-only** pixel access.
    ///
    ///  As an optimization, the pixels made available for editing don't necessarily
    ///  contain the old texture data. This is a write-only operation, and if you
    ///  need to keep a copy of the texture data you should do that at the
    ///  application level.
    ///
    ///  You must use Unlock to unlock the pixels and apply any changes.
    /// </summary>
    /// <param name="APixels">This is set to a pointer to the locked pixels,
    ///  appropriately offset by the locked area.</param>
    /// <param name="APitch">This is set to the pitch of the locked pixels;
    ///  the pitch is the length of one row in bytes.</param>
    /// <exception name="ESdlError">Raised on failure (eg. if the texture is not
    ///  valid or was not created with `TSdlTextureAccess.Streaming`.</exception>
    /// <seealso cref="LockToSurface"/>
    /// <seealso cref="Unlock"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Lock(out APixels: Pointer; out APitch: Integer); overload;

    /// <summary>
    ///  Lock a portion of the texture for **write-only** pixel access.
    ///
    ///  As an optimization, the pixels made available for editing don't necessarily
    ///  contain the old texture data. This is a write-only operation, and if you
    ///  need to keep a copy of the texture data you should do that at the
    ///  application level.
    ///
    ///  You must use Unlock to unlock the pixels and apply any changes.
    /// </summary>
    /// <param name="ARect">The area to lock for access.</param>
    /// <param name="APixels">This is set to a pointer to the locked pixels,
    ///  appropriately offset by the locked area.</param>
    /// <param name="APitch">This is set to the pitch of the locked pixels;
    ///  the pitch is the length of one row in bytes.</param>
    /// <exception name="ESdlError">Raised on failure (eg. if the texture is not
    ///  valid or was not created with `TSdlTextureAccess.Streaming`.</exception>
    /// <seealso cref="LockToSurface"/>
    /// <seealso cref="Unlock"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Lock(const ARect: TSdlRect; out APixels: Pointer; out APitch: Integer); overload;

    /// <summary>
    ///  Lock a the entire texture for **write-only** pixel access, and expose
    ///  it as a SDL surface.
    ///
    ///  Besides providing an TSdlSurface instead of raw pixel data, this function
    ///  operates like Lock.
    ///
    ///  As an optimization, the pixels made available for editing don't necessarily
    ///  contain the old texture data. This is a write-only operation, and if you
    ///  need to keep a copy of the texture data you should do that at the
    ///  application level.
    ///
    ///  You must use Unlock to unlock the pixels and apply any changes.
    ///
    ///  The returned surface is freed internally after calling Unlock or when
    ///  freeing the texture. The caller should not free it.
    /// </summary>
    /// <returns>A SDL surface of the same size as this texture.
    ///  Don't assume any specific pixel content.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Lock"/>
    /// <seealso cref="Unlock"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function LockToSurface: TSdlSurface; overload;

    /// <summary>
    ///  Lock a portion of the texture for **write-only** pixel access, and expose
    ///  it as a SDL surface.
    ///
    ///  Besides providing an TSdlSurface instead of raw pixel data, this function
    ///  operates like Lock.
    ///
    ///  As an optimization, the pixels made available for editing don't necessarily
    ///  contain the old texture data. This is a write-only operation, and if you
    ///  need to keep a copy of the texture data you should do that at the
    ///  application level.
    ///
    ///  You must use Unlock to unlock the pixels and apply any changes.
    ///
    ///  The returned surface is freed internally after calling Unlock or when
    ///  freeing the texture. The caller should not free it.
    /// </summary>
    /// <param name="ARect">The rectangle to lock for access.</param>
    /// <returns>A SDL surface of size **ARect**. Don't assume any specific pixel content.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Lock"/>
    /// <seealso cref="Unlock"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function LockToSurface(const ARect: TSdlRect): TSdlSurface; overload;

    /// <summary>
    ///  Unlock the texture, uploading the changes to video memory, if needed.
    ///
    ///  **Warning**: Please note that Lock is intended to be write-only; it
    ///  will not guarantee the previous contents of the texture will be
    ///  provided. You must fully initialize any area of a texture that you lock
    ///  before unlocking it, as the pixels might otherwise be uninitialized memory.
    ///
    ///  Which is to say: locking and immediately unlocking a texture can result in
    ///  corrupted textures, depending on the renderer in use.
    /// </summary>
    /// <seealso cref="Lock"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Unlock; inline;

    /// <summary>
    ///  The format of the texture, read-only
    /// </summary>
    property Format: TSdlPixelFormat read GetFormat;

    /// <summary>
    ///  The width of the texture, read-only.
    /// </summary>
    property W: Integer read GetW;

    /// <summary>
    ///  The height of the texture, read-only.
    /// </summary>
    property H: Integer read GetH;

    /// <summary>
    ///  The size of a texture, as floating point values.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Size: TSdlSizeF read GetSize;

    /// <summary>
    ///  An additional color value multiplied into render copy operations.
    ///
    ///  When this texture is rendered, during the copy operation each source color
    ///  channel is modulated by the appropriate color value according to the
    ///  following formula:
    ///
    ///  `SrcC := SrcC * (Color div 255)`
    ///
    ///  Color modulation is not always supported by the renderer; it will
    ///  raise an error if color modulation is not supported.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AlphaMod"/>
    /// <seealso cref="ColorModFloat"/>
    /// <remarks>
    ///  The Alpha value of the color is ignored (or set to 255).
    ///
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ColorMod: TSdlColor read GetColorMod write SetColorMod;

    /// <summary>
    ///  An additional color value multiplied into render copy operations.
    ///
    ///  When this texture is rendered, during the copy operation each source color
    ///  channel is modulated by the appropriate color value according to the
    ///  following formula:
    ///
    ///  `SrcC := SrcC * Color`
    ///
    ///  Color modulation is not always supported by the renderer; it will
    ///  raise an error if color modulation is not supported.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AlphaModFloat"/>
    /// <seealso cref="ColorMod"/>
    /// <remarks>
    ///  The Alpha value of the color is ignored (or set to 1.0).
    ///
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ColorModFloat: TSdlColorF read GetColorModFloat write SetColorModFloat;

    /// <summary>
    ///  An additional alpha value multiplied into render copy operations.
    ///
    ///  When this texture is rendered, during the copy operation the source alpha
    ///  value is modulated by this alpha value according to the following formula:
    ///
    ///  `SrcA := SrcA * (Alpha div 255)`
    ///
    ///  Alpha modulation is not always supported by the renderer; it will
    ///  raise an error if color modulation is not supported.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AlphaModFloat"/>
    /// <seealso cref="ColorMod"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property AlphaMod: Byte read GetAlphaMod write SetAlphaMod;

    /// <summary>
    ///  An additional alpha value multiplied into render copy operations.
    ///
    ///  When this texture is rendered, during the copy operation the source alpha
    ///  value is modulated by this alpha value according to the following formula:
    ///
    ///  `SrcA := SrcA * Alpha`
    ///
    ///  Alpha modulation is not always supported by the renderer; it will
    ///  raise an error if color modulation is not supported.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AlphaMod"/>
    /// <seealso cref="ColorModFloat"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property AlphaModFloat: Single read GetAlphaModFloat write SetAlphaModFloat;

    /// <summary>
    ///  The blend mode for a texture, used by TSdlRenderer.DrawTexture.
    ///
    ///  If the blend mode is not supported, the closest supported mode is chosen.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property BlendMode: TSdlBlendMode read GetBlendMode write SetBlendMode;

    /// <summary>
    ///  The scale mode used for texture scale operations.
    ///
    ///  The default texture scale mode is TSdlScaleMode.Linear.
    ///
    ///  If the scale mode is not supported, the closest supported mode is chosen.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ScaleMode: TSdlScaleMode read GetScaleMode write SetScaleMode;

    /// <summary>
    ///  The properties associated with a texture.
    ///
    ///  The following read-only properties are provided by SDL:
    ///
    ///  - `TSdlProperty.TextureColorspace`: a TSdlColorspace value describing
    ///    the texture colorspace.
    ///  - `TSdlProperty.TextureFormat`: one of the enumerated values in
    ///    TSdlPixelFormat.
    ///  - `TSdlProperty.TextureAccess`: one of the enumerated values in
    ///    TSdlTextureAccess.
    ///  - `TSdlProperty.TextureWidth`: the width of the texture in pixels.
    ///  - `TSdlProperty.TextureHeight`: the height of the texture in pixels.
    ///  - `TSdlProperty.TextureSdrWhitePoint`: for HDR10 and floating point
    ///    textures, this defines the value of 100% diffuse white, with higher
    ///    values being displayed in the High Dynamic Range headroom. This defaults
    ///    to 100 for HDR10 textures and 1.0 for other textures.
    ///  - `TSdlProperty.TextureHdrHeadroom`: for HDR10 and floating point
    ///    textures, this defines the maximum dynamic range used by the content, in
    ///    terms of the SDR white point. If this is defined, any values outside the
    ///    range supported by the display will be scaled into the available HDR
    ///    headroom, otherwise they are clipped. This defaults to 1.0 for SDR
    ///    textures, 4.0 for HDR10 textures, and no default for floating point
    ///    textures.
    ///
    ///  With the Direct3D11 renderer:
    ///
    ///  - `TSdlProperty.TextureD3D11Texture`: the ID3D11Texture2D associated
    ///    with the texture
    ///  - `TSdlProperty.TextureD3D11TextureU`: the ID3D11Texture2D
    ///    associated with the U plane of a YUV texture
    ///  - `TSdlProperty.TextureD3D11TextureV`: the ID3D11Texture2D
    ///    associated with the V plane of a YUV texture
    ///
    ///  With the Direct3D12 renderer:
    ///
    ///  - `TSdlProperty.TextureD3D12Texture`: the ID3D12Resource associated
    ///    with the texture
    ///  - `TSdlProperty.TextureD3D12TextureU`: the ID3D12Resource associated
    ///    with the U plane of a YUV texture
    ///  - `TSdlProperty.TextureD3D12TextureV`: the ID3D12Resource associated
    ///    with the V plane of a YUV texture
    ///
    ///  With the Vulkan renderer:
    ///
    ///  - `TSdlProperty.TextureVulkanTexture`: the VkImage associated with the
    ///    texture
    ///
    ///  With the OpenGL renderer:
    ///
    ///  - `TSdlProperty.TextureOpenGLTexture`: the GLuint texture associated
    ///    with the texture
    ///  - `TSdlProperty.TextureOpenGLTextureUV`: the GLuint texture
    ///    associated with the UV plane of an NV12 texture
    ///  - `TSdlProperty.TextureOpenGLTextureU`: the GLuint texture associated
    ///    with the U plane of a YUV texture
    ///  - `TSdlProperty.TextureOpenGLTextureV`: the GLuint texture associated
    ///    with the V plane of a YUV texture
    ///  - `TSdlProperty.TextureOpenGLTextureTarget`: the GLenum for the
    ///    texture target (`GL_TEXTURE_2D`, `GL_TEXTURE_RECTANGLE_ARB`, etc)
    ///  - `TSdlProperty.TextureOpenGLTexW`: the texture coordinate width of
    ///    the texture (0.0 - 1.0)
    ///  - `TSdlProperty.TextureOpenGLTexH`: the texture coordinate height of
    ///    the texture (0.0 - 1.0)
    ///
    ///  With the OpenGL-ES2 renderer:
    ///
    ///  - `TSdlProperty.TextureOpenGles2Texture`: the GLuint texture
    ///    associated with the texture
    ///  - `TSdlProperty.TextureOpenGles2TextureUV`: the GLuint texture
    ///    associated with the UV plane of an NV12 texture
    ///  - `TSdlProperty.TextureOpenGles2TextureU`: the GLuint texture
    ///    associated with the U plane of a YUV texture
    ///  - `TSdlProperty.TextureOpenGles2TextureV`: the GLuint texture
    ///    associated with the V plane of a YUV texture
    ///  - `TSdlProperty.TextureOpenGles2TextureTarget`: the GLenum for the
    ///    texture target (`GL_TEXTURE_2D`, `GL_TEXTURE_EXTERNAL_OES`, etc)
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;

type
  /// <summary>
  ///  The type of indices in an index array
  /// </summary>
  TSdlIndexType = (
    /// <summary>
    ///  Each index is an (unsigned) 8-bit byte
    /// </summary>
    Byte = 1,

    /// <summary>
    ///  Each index is an (unsigned) 16-bit word
    /// </summary>
    Word = 2,

    /// <summary>
    ///  Each index is an (unsigned) 32-bit cardinal
    /// </summary>
    Cardinal = 4);

type
  /// <summary>
  ///  Renderer vsync values.
  ///
  ///  Use the special value Disabled to disable vsync, or Adaptive for late
  ///  swap tearing (adaptive vsync). Other values represent a vsync interval,
  ///  e.g. 1 to synchronize present with every vertical refresh, 2 to
  ///  synchronize present with every second vertical refresh, etc.
  /// </summary>
  TSdlRendererVsync = type Integer;

  _TSdlRendererVsync = record helper for TSdlRendererVsync
  public const
    /// <summary>
    ///  Disabled vsync
    /// </summary>
    Disabled = SDL_RENDERER_VSYNC_DISABLED;

    /// <summary>
    ///  Use adaptive vsync (late swap tearing)
    /// </summary>
    Adaptive = SDL_RENDERER_VSYNC_ADAPTIVE;
  end;

const
  /// <summary>
  ///  The size, in pixels, of a single TSdlRenderer.DrawDebugText character.
  ///
  ///  The font is monospaced and square, so this applies to all characters.
  /// </summary>
  /// <seealso cref="TSdlRenderer.DrawDebugText"/>
  SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE = Neslib.Sdl3.Api.SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE; // 8

type
  /// <summary>
  ///  Rendering state
  /// </summary>
  TSdlRenderer = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Renderer;
    function GetDrawColor: TSdlColor; inline;
    procedure SetDrawColor(const AValue: TSdlColor); overload; inline;
    function GetDrawColorFloat: TSdlColorF; inline;
    procedure SetDrawColorFloat(const AValue: TSdlColorF); overload; inline;
    function GetWindow: TSdlWindow; inline;
    function GetName: String; inline;
    function GetOutputSize: TSdlSize; inline;
    function GetCurrentOutputSize: TSdlSize; inline;
    function GetLogicalPresentationRect: TSdlRect; inline;
    function GetTarget: TSdlTexture; inline;
    procedure SetTarget(const AValue: TSdlTexture); inline;
    function GetViewport: TSdlRect; inline;
    procedure SetViewport(const AValue: TSdlRect); inline;
    function GetIsViewportSet: Boolean; inline;
    function GetSafeArea: TSdlRect; inline;
    function GetClipRect: TSdlRect; inline;
    procedure SetClipRect(const AValue: TSdlRect); inline;
    function GetIsClipEnabled: Boolean; inline;
    procedure SetIsClipEnabled(const AValue: Boolean); inline;
    function GetScale: TSdlPointF; inline;
    procedure SetScale(const AValue: TSdlPointF); inline;
    function GetColorScale: Single; inline;
    procedure SetColorScale(const AValue: Single); inline;
    function GetDrawBlendMode: TSdlBlendMode; inline;
    procedure SetDrawBlendMode(const AValue: TSdlBlendMode); inline;
    function GetMetalLayer: Pointer; inline;
    function GetMetalCommandEncoder: Pointer; inline;
    function GetVSync: TSdlRendererVsync; inline;
    procedure SetVSync(const AValue: TSdlRendererVsync); inline;
    function GetProperties: TSdlProperties; inline;
    class function GetDriverCount: Integer; inline; static;
    class function GetDriver(const AIndex: Integer): String; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlRenderer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlRenderer.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlRenderer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlRenderer; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlRenderer.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlRenderer): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlRenderer; inline; static;
  public
    /// <summary>
    ///  Create a default renderer and window.
    /// </summary>
    /// <param name="ATitle">The title of the window.</param>
    /// <param name="AWidth">The width of the window.</param>
    /// <param name="AHeight">The height of the window.</param>
    /// <param name="AWindowFlags">The flags used to create the window
    ///  (see TSdlWindow.Create).</param>
    /// <param name="AWindow">Is set to the newly created window.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlWindow.Create"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const ATitle: String; const AWidth, AHeight: Integer;
      const AWindowFlags: TSdlWindowFlags; out AWindow: TSdlWindow); overload;

    /// <summary>
    ///  Create a 2D rendering context for a window.
    ///
    ///  If you want a specific renderer, you can specify its name here. A list of
    ///  available renderers can be obtained through the RenderDriverCount and
    ///  RenderDrivers properties. If you don't need a specific renderer, don't
    ///  specify a name (or an empty string) and SDL will attempt to choose
    ///  the best option for you, based on what is available on the user's system.
    ///
    ///  If `AName` is a comma-separated list, SDL will try each name, in the order
    ///  listed, until one succeeds or all of them fail.
    ///
    ///  By default the rendering size matches the window size in pixels, but you
    ///  can set LogicalPresentation to change the content size and scaling options.
    /// </summary>
    /// <param name="AWindow">The window where rendering is displayed.</param>
    /// <param name="AName">(Optional) name of the rendering driver to initialize,
    ///  or an empty string to let SDL choose one.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="DriverCount"/>
    /// <seealso cref="Drivers"/>
    /// <seealso cref="Name"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AWindow: TSdlWindow; const AName: String = ''); overload;

    /// <summary>
    ///  Create a 2D rendering context for a window, with the specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlProperty.RendererCreateName`: the name of the rendering driver
    ///    to use, if a specific one is desired
    ///  - `TSdlProperty.RendererCreateWindow`: the window where rendering is
    ///    displayed, required if this isn't a software renderer using a surface
    ///  - `TSdlProperty.RendererCreateSurface`: the surface where rendering
    ///    is displayed, if you want a software renderer without a window
    ///  - `TSdlProperty.RendererCreateOutputColorspace`: a TSdlColorspace
    ///    value describing the colorspace for output to the display, defaults to
    ///    TSdlColorspace.Srgb. The Direct3D11, Direct3D12, and Metal renderers
    ///    support TSdlColorspace.SrgbLinear, which is a linear color space and
    ///    supports HDR output. If you select TSdlColorspace.SrgbLinear, drawing
    ///    still uses the sRGB colorspace, but values can go beyond 1.0 and float
    ///    (linear) format textures can be used for HDR content.
    ///  - `TSdlProperty.RendererCreatePresentVSync`: non-zero if you want
    ///    present synchronized with the refresh rate. This property can take any
    ///    value that is supported by the VSync property for the renderer.
    ///
    ///  With the vulkan renderer:
    ///
    ///  - `TSdlProperty.RendererCreateVulkanInstance`: the VkInstance to use
    ///    with the renderer, optional.
    ///  - `TSdlProperty.RendererCreateVulkanSurface`: the VkSurfaceKHR to use
    ///    with the renderer, optional.
    ///  - `TSdlProperty.RendererCreateVulkanPhysicalDevice`: the
    ///    VkPhysicalDevice to use with the renderer, optional.
    ///  - `TSdlProperty.RendererCreateVulkanDevice`: the VkDevice to use
    ///    with the renderer, optional.
    ///  - `TSdlProperty.RendererCreateVulkanGraphicsQueueFamilyIndex`: the
    ///    queue family index used for rendering.
    ///  - `TSdlProperty.RendererCreateVulkanPresentQueueFamilyIndex`: the
    ///    queue family index used for presentation.
    /// </summary>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlProperties"/>
    /// <seealso cref="Free"/>
    /// <seealso cref="Name"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AProperties: TSdlProperties); overload;

    /// <summary>
    ///  Create a 2D software rendering context for a surface.
    ///
    ///  The other constructors can _also_ create a software renderer, but they
    ///  are intended to be used with a TSdlWindow as the final destination and
    ///  not a TSdlSurface.
    /// </summary>
    /// <param name="ASurface">The srface where rendering is done.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const ASurface: TSdlSurface); overload;

    /// <summary>
    ///  Destroy the rendering context for a window and free all associated
    ///  textures.
    ///
    ///  This should be called before destroying the associated window.
    /// </summary>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Get the renderer associated with a window.
    /// </summary>
    /// <param name="AWindow">The window to query.</param>
    /// <returns>The rendering context.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function ForWindow(const AWindow: TSdlWindow): TSdlRenderer; inline; static;

    /// <summary>
    ///  Create a texture for this rendering context.
    ///
    ///  The contents of a texture when first created are not defined.
    /// </summary>
    /// <param name="AFormat">The pixel format.</param>
    /// <param name="AAccess">Texture access.</param>
    /// <param name="AW">The width of the texture in pixels.</param>
    /// <param name="AH">The height of the texture in pixels.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlTexture.Free"/>
    /// <seealso cref="TSdlTexture.Size"/>
    /// <seealso cref="TSdlTexture.Update"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function CreateTexture(const AFormat: TSdlPixelFormat;
      const AAccess: TSdlTextureAccess; const AW, AH: Integer): TSdlTexture; overload; inline;

    /// <summary>
    ///  Create a texture for this rendering context from an existing surface.
    ///
    ///  The surface is not modified or freed by this function.
    ///
    ///  The TSdlTextureAccess hint for the created texture is
    ///  `TSdlHints.TextureAccessStatic`.
    ///
    ///  The pixel format of the created texture may be different from the pixel
    ///  format of the surface, and can be queried using the
    ///  TSdlProperty.TextureFormat property.
    /// </summary>
    /// <param name="ASurface">The surface containing pixel data used to fill
    ///  the texture.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlTexture.Free"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function CreateTexture(const ASurface: TSdlSurface): TSdlTexture; overload; inline;

    /// <summary>
    ///  Create a texture for this rendering context with the specified properties.
    ///
    ///  These are the supported properties:
    ///
    ///  - `TSdlProperty.TextureCreateColorspace`: a TSdlColorspace value
    ///    describing the texture colorspace, defaults to TSdlColorspace.SrgbLinear
    ///    for floating point textures, TSdlColorspace.Hdr10 for 10-bit textures,
    ///    TSdlColorspace.Srgb for other RGB textures and TSdlColorspace.Jpeg for
    ///    YUV textures.
    ///  - `TSdlProperty.TextureCreateFormat`: one of the enumerated values in
    ///    TSdlPixelFormat, defaults to the best RGBA format for the renderer.
    ///  - `TSdlProperty.TextureCreateAccess`: one of the enumerated values in
    ///    TSdlTextureAccess, defaults to TSdlTextureAccess.Static.
    ///  - `TSdlProperty.TextureCreateWidth`: the width of the texture in
    ///    pixels, required
    ///  - `TSdlProperty.TextureCreateHeight`: the height of the texture in
    ///    pixels, required
    ///  - `TSdlProperty.TextureCreateSdrWhitePoint`: for HDR10 and floating
    ///    point textures, this defines the value of 100% diffuse white, with higher
    ///    values being displayed in the High Dynamic Range headroom. This defaults
    ///    to 100 for HDR10 textures and 1.0 for floating point textures.
    ///  - `TSdlProperty.TextureCreateHdrHeadroom`: for HDR10 and floating
    ///    point textures, this defines the maximum dynamic range used by the
    ///    content, in terms of the SDR white point. This would be equivalent to
    ///    maxCLL / TSdlProperty.TextureCreateSdrWhitePoint for HDR10 content.
    ///    If this is defined, any values outside the range supported by the display
    ///    will be scaled into the available HDR headroom, otherwise they are
    ///    clipped.
    ///
    ///  With the Direct3D11 renderer:
    ///
    ///  - `TSdlProperty.TextureCreateD3D11Texture`: the ID3D11Texture2D
    ///    associated with the texture, if you want to wrap an existing texture.
    ///  - `TSdlProperty.TextureCreateD3D11TextureU`: the ID3D11Texture2D
    ///    associated with the U plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///  - `TSdlProperty.TextureCreateD3D11TextureV`: the ID3D11Texture2D
    ///    associated with the V plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///
    ///  With the Direct3D12 renderer:
    ///
    ///  - `TSdlProperty.TextureCreateD3D12Texture`: the ID3D12Resource
    ///    associated with the texture, if you want to wrap an existing texture.
    ///  - `TSdlProperty.TextureCreateD3D12TextureU`: the ID3D12Resource
    ///    associated with the U plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///  - `TSdlProperty.TextureCreateD3D12TextureV`: the ID3D12Resource
    ///    associated with the V plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///
    ///  With the Metal renderer:
    ///
    ///  - `TSdlProperty.TextureCreateMetalPixelBuffer`: the CVPixelBufferRef
    ///    associated with the texture, if you want to create a texture from an
    ///    existing pixel buffer.
    ///
    ///  With the OpenGL renderer:
    ///
    ///  - `TSdlProperty.TextureCreateOpenGLTexture`: the GLuint texture
    ///    associated with the texture, if you want to wrap an existing texture.
    ///  - `TSdlProperty.TextureCreateOpenGLTextureUV`: the GLuint texture
    ///    associated with the UV plane of an NV12 texture, if you want to wrap an
    ///    existing texture.
    ///  - `TSdlProperty.TextureCreateOpenGLTextureU`: the GLuint texture
    ///    associated with the U plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///  - `TSdlProperty.TextureCreateOpenGLTextureV`: the GLuint texture
    ///    associated with the V plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///
    ///  With the OpenGL-ES2 renderer:
    ///
    ///  - `TSdlProperty.TextureCreateOpenGles2Texture`: the GLuint texture
    ///    associated with the texture, if you want to wrap an existing texture.
    ///  - `TSdlProperty.TextureCreateOpenGles2TextureUV`: the GLuint texture
    ///    associated with the UV plane of an NV12 texture, if you want to wrap an
    ///    existing texture.
    ///  - `TSdlProperty.TextureCreateOpenGles2TextureU`: the GLuint texture
    ///    associated with the U plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///  - `TSdlProperty.TextureCreateOpenGles2TextureV`: the GLuint texture
    ///    associated with the V plane of a YUV texture, if you want to wrap an
    ///    existing texture.
    ///
    ///  With the Vulkan renderer:
    ///
    ///  - `TSdlProperty.TextureCreateVulkanTexture`: the VkImage with layout
    ///    VK_IMAGE_LAYOUT_SHADER_READ_ONLY_OPTIMAL associated with the texture, if
    ///    you want to wrap an existing texture.
    /// </summary>
    /// <param name="ARenderer">The rendering context.</param>
    /// <param name="AProps">The properties to use.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlTexture.Free"/>
    /// <seealso cref="TSdlTexture.Size"/>
    /// <seealso cref="TSdlTexture.Update"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    function CreateTexture(const AProps: TSdlProperties): TSdlTexture; overload; inline;

    /// <summary>
    ///  Clear the current rendering target with the drawing color.
    ///
    ///  This function clears the entire rendering target, ignoring the viewport and
    ///  the clip rectangle. Note, that clearing will also set/fill all pixels of
    ///  the rendering target to current renderer draw color, so make sure to invoke
    ///  SetDrawColor when needed.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetDrawColor"/>
    /// <seealso cref="DrawColor"/>
    /// <seealso cref="DrawColorFloat"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Clear; inline;

    /// <summary>
    ///  Update the screen with any rendering performed since the previous call.
    ///
    ///  SDL's rendering functions operate on a backbuffer; that is, calling a
    ///  rendering function such as DrawLine does not directly put a line on
    ///  the screen, but rather updates the backbuffer. As such, you compose your
    ///  entire scene and *present* the composed backbuffer to the screen as a
    ///  complete picture.
    ///
    ///  Therefore, when using SDL's rendering API, one does all drawing intended
    ///  for the frame, and then calls this function once per frame to present the
    ///  final drawing to the user.
    ///
    ///  The backbuffer should be considered invalidated after each present; do not
    ///  assume that previous contents will exist between frames. You are strongly
    ///  encouraged to call Clear to initialize the backbuffer before starting
    ///  each new frame's drawing, even if you plan to overwrite every pixel.
    ///
    ///  Please note, that in case of rendering to a texture - there is **no need**
    ///  to call `Present` after drawing needed objects to a texture, and
    ///  should not be done; you are only required to change back the rendering
    ///  target to default via `RenderTarget := nil` afterwards, as
    ///  textures by themselves do not have a concept of backbuffers. Calling
    ///  Present while rendering to a texture will still update the screen
    ///  with any current drawing that has been done _to the window itself_.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Clear"/>
    /// <seealso cref="FillRect"/>
    /// <seealso cref="FillRects"/>
    /// <seealso cref="DrawLine"/>
    /// <seealso cref="DrawLines"/>
    /// <seealso cref="DrawPoint"/>
    /// <seealso cref="DrawPoints"/>
    /// <seealso cref="DrawRect"/>
    /// <seealso cref="DrawRects"/>
    /// <seealso cref="DrawBlendMode"/>
    /// <seealso cref="SetDrawColor"/>
    /// <seealso cref="DrawColor"/>
    /// <seealso cref="DrawColorFloat"/>
    /// <remarks>
    ///  This methodn should only be called on the main thread.
    /// </remarks>
    procedure Present; inline;

    /// <summary>
    ///  Set the (integer) color used for drawing operations.
    ///
    ///  Set the color for drawing or filling rectangles, lines, and points, and
    ///  for Clear.
    /// </summary>
    /// <param name="AR">The red value used to draw on the rendering target.</param>
    /// <param name="AG">The green value used to draw on the rendering target.</param>
    /// <param name="AB">The blue value used to draw on the rendering target.</param>
    /// <param name="AA">(Optional)Aalpha value used to draw on the rendering target;
    ///  Defaults to `SDL_ALPHA_OPAQUE` (255). Use DrawBlendMode to specify how
    ///  the alpha channel is used.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawColor"/>
    /// <seealso cref="DrawColorFloat"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetDrawColor(const AR, AG, AB: Byte;
      const AA: Byte = SDL_ALPHA_OPAQUE); overload; inline;

    /// <summary>
    ///  Set the (floating-point) color used for drawing operations.
    ///
    ///  Set the color for drawing or filling rectangles, lines, and points, and
    ///  for Clear.
    /// </summary>
    /// <param name="AR">The red value used to draw on the rendering target.</param>
    /// <param name="AG">The green value used to draw on the rendering target.</param>
    /// <param name="AB">The blue value used to draw on the rendering target.</param>
    /// <param name="AA">(Optional)Aalpha value used to draw on the rendering target;
    ///  Defaults to `SDL_ALPHA_OPAQUE_FLOAT` (1.0). Use DrawBlendMode to specify how
    ///  the alpha channel is used.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawColor"/>
    /// <seealso cref="DrawColorFloat"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetDrawColorFloat(const AR, AG, AB: Single;
      const AA: Single = SDL_ALPHA_OPAQUE_FLOAT); overload; inline;

    /// <summary>
    ///  Set a device independent resolution and presentation mode for rendering.
    ///
    ///  This method sets the width and height of the logical rendering output.
    ///  The renderer will act as if the window is always the requested dimensions,
    ///  scaling to the actual window resolution as necessary.
    ///
    ///  This can be useful for games that expect a fixed size, but would like to
    ///  scale the output to whatever is available, regardless of how a user resizes
    ///  a window, or if the display is high DPI.
    ///
    ///  You can disable logical coordinates by setting the mode to
    ///  TSdlLogicalPresentation.Disabled, and in that case you get the full pixel
    ///  resolution of the output window; it is safe to toggle logical presentation
    ///  during the rendering of a frame: perhaps most of the rendering is done to
    ///  specific dimensions but to make fonts look sharp, the app turns off logical
    ///  presentation while drawing text.
    ///
    ///  Letterboxing will only happen if logical presentation is enabled during
    ///  Present; be sure to reenable it first if you were using it.
    ///
    ///  You can convert coordinates in an event into rendering coordinates using
    ///  TSdlEvent.ConvertToRenderCoordinates.
    /// </summary>
    /// <param name="AW">The width of the logical resolution.</param>
    /// <param name="AH">The height of the logical resolution.</param>
    /// <param name="AMode">The presentation mode used.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlEvent.ConvertToRenderCoordinates"/>
    /// <seealso cref="GetLogicalPresentation"/>
    /// <seealso cref="LogicalPresentationRect"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure SetLogicalPresentation(const AW, AH: Integer;
      const AMode: TSdlRendererLogicalPresentation); inline;

    /// <summary>
    ///  Get device independent resolution and presentation mode for rendering.
    ///
    ///  This method gets the width and height of the logical rendering output, or
    ///  the output size in pixels if a logical resolution is not enabled.
    /// </summary>
    /// <param name="AW">Set to the width.</param>
    /// <param name="AH">Set to the height.</param>
    /// <param name="AMode">Set to the presentation.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetLogicalPresentation"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure GetLogicalPresentation(out AW, AH: Integer;
      out AMode: TSdlRendererLogicalPresentation); inline;

    /// <summary>
    ///  Get a point in render coordinates when given a point in window coordinates.
    ///
    ///  This takes into account several states:
    ///
    ///  - The window dimensions.
    ///  - The logical presentation settings (SetLogicalPresentation)
    ///  - The scale (Scale)
    ///  - The viewport (Viewport)
    /// </summary>
    /// <param name="AWindowX">The X coordinate in window coordinates.</param>
    /// <param name="AWindowY">The Y coordinate in window coordinates.</param>
    /// <returns>The coordinates in render coordinates.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetLogicalPresentation"/>
    /// <seealso cref="Scale"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function RenderCoordinatesFromWindow(const AWindowX, AWindowY: Single): TSdlPointF; inline;

    /// <summary>
    ///  Get a point in window coordinates when given a point in render coordinates.
    ///
    ///  This takes into account several states:
    ///
    ///  - The window dimensions.
    ///  - The logical presentation settings (SetLogicalPresentation)
    ///  - The scale (Scale)
    ///  - The viewport (Viewport)
    /// </summary>
    /// <param name="AX">The X coordinate in render coordinates.</param>
    /// <param name="AY">The Y coordinate in render coordinates.</param>
    /// <returns>The coordinates in window coordinates.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetLogicalPresentation"/>
    /// <seealso cref="Scale"/>
    /// <seealso cref="Viewport"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function RenderCoordinatesToWindow(const AX, AY: Single): TSdlPointF; inline;

    /// <summary>
    ///  Set the viewport to the entire target.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Viewport"/>
    /// <seealso cref="IsViewportSet"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure ResetViewport; inline;

    /// <summary>
    ///  Draw a point on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="AX">The X coordinate of the point.</param>
    /// <param name="AY">the Y coordinate of the point.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawPoints"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawPoint(const AX, AY: Single); overload; inline;

    /// <summary>
    ///  Draw a point on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="AXPoint">The point.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawPoints"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawPoint(const APoint: TSdlPointF); overload; inline;

    /// <summary>
    ///  Draw multiple points on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="APoints">The points to draw.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawPoint"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawPoints(const APoints: TArray<TSdlPointF>); overload; inline;

    /// <summary>
    ///  Draw multiple points on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="APoints">The points to draw.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawPoint"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawPoints(const APoints: array of TSdlPointF); overload;

    /// <summary>
    ///  Draw a line on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="ARenderer">the renderer which should draw a line.</param>
    /// <param name="AX1">The X coordinate of the start point.</param>
    /// <param name="AY1">The Y coordinate of the start point.</param>
    /// <param name="AX2">The X coordinate of the end point.</param>
    /// <param name="AY2">The Y coordinate of the end point.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawLines"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawLine(const AX1, AY1, AX2, AY2: Single); overload; inline;

    /// <summary>
    ///  Draw a line on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="ARenderer">the renderer which should draw a line.</param>
    /// <param name="AP1">The start point.</param>
    /// <param name="AP2">The end point.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawLines"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawLine(const AP1, AP2: TSdlPointF); overload; inline;

    /// <summary>
    ///  Draw a series of connected lines on the current rendering target at
    ///  subpixel precision.
    /// </summary>
    /// <param name="APoints">The points along the lines.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawLine"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawLines(const APoints: TArray<TSdlPointF>); overload; inline;

    /// <summary>
    ///  Draw a series of connected lines on the current rendering target at
    ///  subpixel precision.
    /// </summary>
    /// <param name="APoints">The points along the lines.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawLine"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawLines(const APoints: array of TSdlPointF); overload;

    /// <summary>
    ///  Draw a rectangle on the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="ARect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawRects"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawRect(const ARect: TSdlRectF); inline;

    /// <summary>
    ///  Draw some number of rectangles on the current rendering target at subpixel
    ///  precision.
    /// </summary>
    /// <param name="ARects">Array of destination rectangles.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawRect"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawRects(const ARects: TArray<TSdlRectF>); overload; inline;

    /// <summary>
    ///  Draw some number of rectangles on the current rendering target at subpixel
    ///  precision.
    /// </summary>
    /// <param name="ARects">Array of destination rectangles.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawRect"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawRects(const ARects: array of TSdlRectF); overload;

    /// <summary>
    ///  Fill a rectangle on the current rendering target with the drawing color at
    ///  subpixel precision.
    /// </summary>
    /// <param name="ARect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FillRects"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure FillRect(const ARect: TSdlRectF); inline;

    /// <summary>
    ///  Fill some number of rectangles on the current rendering target with the
    ///  drawing color at subpixel precision.
    /// </summary>
    /// <param name="ARects">Array of destination rectangles.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FillRect"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure FillRects(const ARects: TArray<TSdlRectF>); overload; inline;

    /// <summary>
    ///  Fill some number of rectangles on the current rendering target with the
    ///  drawing color at subpixel precision.
    /// </summary>
    /// <param name="ARects">Array of destination rectangles.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FillRect"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure FillRects(const ARects: array of TSdlRectF); overload;

    /// <summary>
    ///  Copy the texture to fill the entire current rendering target.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTextureRotated"/>
    /// <seealso cref="DrawTextureTiled"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTexture(const ATexture: TSdlTexture); overload; inline;

    /// <summary>
    ///  Copy the texture to the current rendering target at subpixel precision.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTextureRotated"/>
    /// <seealso cref="DrawTextureTiled"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTexture(const ATexture: TSdlTexture;
      const ADstRect: TSdlRectF); overload; inline;

    /// <summary>
    ///  Copy a portion of the texture to the current rendering target at subpixel
    ///  precision.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ASrcRect">The source rectangle.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTextureRotated"/>
    /// <seealso cref="DrawTextureTiled"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTexture(const ATexture: TSdlTexture; const ASrcRect,
      ADstRect: TSdlRectF); overload; inline;

    /// <summary>
    ///  Copy the source texture to the current rendering target, with
    ///  rotation and flipping, at subpixel precision.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <param name="AAngle">An angle in degrees that indicates the rotation
    ///  that will be applied around the center of ADstRect, rotating it in a
    ///  clockwise direction.</param>
    /// <param name="AFlip">(Optional) flipping actions that should be performed
    ///  on the texture. Defaults to [] (none).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureRotated(const ATexture: TSdlTexture;
      const ADstRect: TSdlRectF; const AAngle: Double;
      const AFlip: TSdlFlipModes = []); overload; inline;

    /// <summary>
    ///  Copy the source texture to the current rendering target, with
    ///  rotation and flipping, at subpixel precision.
    ///
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <param name="AAngle">An angle in degrees that indicates the rotation
    ///  that will be applied to ADstRect, rotating it in a clockwise direction.</param>
    /// <param name="ACenter">The point around which ADstRect will be rotated.</param>
    /// <param name="AFlip">(Optional) flipping actions that should be performed
    ///  on the texture. Defaults to [] (none).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureRotated(const ATexture: TSdlTexture;
      const ADstRect: TSdlRectF; const AAngle: Double; const ACenter: TSdlPointF;
      const AFlip: TSdlFlipModes = []); overload; inline;

    /// <summary>
    ///  Copy a portion of the source texture to the current rendering target, with
    ///  rotation and flipping, at subpixel precision.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ASrcRect">The source rectangle.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <param name="AAngle">An angle in degrees that indicates the rotation
    ///  that will be applied around the center of ADstRect, rotating it in a
    ///  clockwise direction.</param>
    /// <param name="AFlip">(Optional) flipping actions that should be performed
    ///  on the texture. Defaults to [] (none).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureRotated(const ATexture: TSdlTexture; const ASrcRect,
      ADstRect: TSdlRectF; const AAngle: Double;
      const AFlip: TSdlFlipModes = []); overload; inline;

    /// <summary>
    ///  Copy a portion of the source texture to the current rendering target, with
    ///  rotation and flipping, at subpixel precision.
    ///
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ASrcRect">The source rectangle.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <param name="AAngle">An angle in degrees that indicates the rotation
    ///  that will be applied to ADstRect, rotating it in a clockwise direction.</param>
    /// <param name="ACenter">The point around which ADstRect will be rotated.</param>
    /// <param name="AFlip">(Optional) flipping actions that should be performed
    ///  on the texture. Defaults to [] (none).</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureRotated(const ATexture: TSdlTexture; const ASrcRect,
      ADstRect: TSdlRectF; const AAngle: Double; const ACenter: TSdlPointF;
      const AFlip: TSdlFlipModes = []); overload; inline;

    /// <summary>
    ///  Copy the source texture to the current rendering target, with
    ///  affine transform, at subpixel precision.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="AOrigin">Where the top-left corner of ASrcRect should be
    ///  mapped to.</param>
    /// <param name="ARight">Where the top-right corner of ASrcRect should be
    ///  mapped to.</param>
    /// <param name="ADown">Where the bottom-left corner of srcrect should be
    ///  mapped to, or NULL for the rendering target's.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureAffine(const ATexture: TSdlTexture;
      const AOrigin, ARight, ADown: TSdlPointF); overload; inline;

    /// <summary>
    ///  Copy a portion of the source texture to the current rendering target, with
    ///  affine transform, at subpixel precision.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ASrcRect">The source rectangle.</param>
    /// <param name="AOrigin">Where the top-left corner of ASrcRect should be
    ///  mapped to.</param>
    /// <param name="ARight">Where the top-right corner of ASrcRect should be
    ///  mapped to.</param>
    /// <param name="ADown">Where the bottom-left corner of srcrect should be
    ///  mapped to, or NULL for the rendering target's.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureAffine(const ATexture: TSdlTexture;
      const ASrcRect: TSdlRectF; const AOrigin, ARight, ADown: TSdlPointF); overload; inline;

    /// <summary>
    ///  Tile the texture to the current rendering target at subpixel
    ///  precision.
    ///
    ///  The pixels in the texture will be repeated as many times as needed to
    ///  completely fill `ADstRect`.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="AScale">The scale used to transform srcrect into the
    ///  destination rectangle, e.g. a 32x32 texture with a scale of 2 would
    ///  fill 64x64 tiles.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureTiled(const ATexture: TSdlTexture;
      const AScale: Single; const ADstRect: TSdlRectF); overload; inline;

    /// <summary>
    ///  Tile a portion of the texture to the current rendering target at subpixel
    ///  precision.
    ///
    ///  The pixels in `ASrcRect` will be repeated as many times as needed to
    ///  completely fill `ADstRect`.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ASrcRect">The source rectangle.</param>
    /// <param name="AScale">The scale used to transform srcrect into the
    ///  destination rectangle, e.g. a 32x32 texture with a scale of 2 would
    ///  fill 64x64 tiles.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTextureTiled(const ATexture: TSdlTexture;
      const ASrcRect: TSdlRectF; const AScale: Single;
      const ADstRect: TSdlRectF); overload; inline;

    /// <summary>
    ///  Perform a scaled copy using the 9-grid algorithm to the current rendering
    ///  target at subpixel precision.
    ///
    ///  The pixels in the texture are split into a 3x3 grid, using the different
    ///  corner sizes for each corner, and the sides and center making up the
    ///  remaining pixels. The corners are then scaled using `AScale` and fit into
    ///  the corners of the destination rectangle. The sides and center are then
    ///  stretched into place to cover the remaining destination rectangle.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ALeftWidth">The width, in pixels, of the left corners.</param>
    /// <param name="ARightWidth">The width, in pixels, of the right corners.</param>
    /// <param name="ATopHeight">The height, in pixels, of the top corners.</param>
    /// <param name="ABottomHeight">The height, in pixels, of the bottom corners.</param>
    /// <param name="AScale">The scale used to transform the corner of the texture
    ///  rectangle into the corner of `ADstRect`, or 0.0 for an unscaled copy.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTexture9Grid(const ATexture: TSdlTexture;
      const ALeftWidth, ARightWidth, ATopHeight, ABottomHeight, AScale: Single;
      const ADstRect: TSdlRectF); overload; inline;

    /// <summary>
    ///  Perform a scaled copy using the 9-grid algorithm to the current rendering
    ///  target at subpixel precision.
    ///
    ///  The pixels in the texture are split into a 3x3 grid, using the different
    ///  corner sizes for each corner, and the sides and center making up the
    ///  remaining pixels. The corners are then scaled using `AScale` and fit into
    ///  the corners of the destination rectangle. The sides and center are then
    ///  stretched into place to cover the remaining destination rectangle.
    /// </summary>
    /// <param name="ATexture">The source texture.</param>
    /// <param name="ASrcRect">The rectangle to be used for the 9-grid</param>
    /// <param name="ALeftWidth">The width, in pixels, of the left corners in `ASrcRect`.</param>
    /// <param name="ARightWidth">The width, in pixels, of the right corners in `ASrcRect`.</param>
    /// <param name="ATopHeight">The height, in pixels, of the top corners in `ASrcRect`.</param>
    /// <param name="ABottomHeight">The height, in pixels, of the bottom corners in `ASrcRect`.</param>
    /// <param name="AScale">The scale used to transform the corner of `ASrcRect`
    ///  into the corner of `ADstRect`, or 0.0 for an unscaled copy.</param>
    /// <param name="ADstRect">The destination rectangle.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="DrawTexture"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawTexture9Grid(const ATexture: TSdlTexture;
      const ASrcRect: TSdlRectF; const ALeftWidth, ARightWidth, ATopHeight,
      ABottomHeight, AScale: Single; const ADstRect: TSdlRectF); overload; inline;

    /// <summary>
    ///  Render a list of triangles, optionally using indices into the
    ///  vertex array. Color and alpha modulation is done per vertex.
    /// </summary>
    /// <param name="AVertices">The vertices.</param>
    /// <param name="AIndices">(Optional) Array of integer indices into the
    ///  'AVertices' array. If nil (default) all vertices will be rendered in
    ///  sequential order.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawGeometry(const AVertices: TArray<TSdlVertex>;
      const AIndices: TArray<Integer> = nil); overload; inline;

    /// <summary>
    ///  Render a list of triangles, optionally using a texture and indices into the
    ///  vertex array. Color and alpha modulation is done per vertex
    ///  (TSdlTexture.ColorMod and TSdlTexture.AlphaMod are ignored).
    /// </summary>
    /// <param name="ATexture">Texture to use.</param>
    /// <param name="AVertices">The vertices.</param>
    /// <param name="AIndices">(Optional) Array of integer indices into the
    ///  'AVertices' array. If nil (default) all vertices will be rendered in
    ///  sequential order.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawGeometry(const ATexture: TSdlTexture;
      const AVertices: TArray<TSdlVertex>;
      const AIndices: TArray<Integer> = nil); overload; inline;

    /// <summary>
    ///  Render a list of triangles, optionally using indices into the
    ///  vertex array. Color and alpha modulation is done per vertex
    ///  (TSdlTexture.ColorMod and TSdlTexture.AlphaMod are ignored).
    /// </summary>
    /// <param name="ARenderer">the rendering context.</param>
    /// <param name="AXY">Vertex positions.</param>
    /// <param name="AXYStride">Byte size to move from one element to the next
    ///  element.</param>
    /// <param name="AColor">Vertex colors.</param>
    /// <param name="AColorStride">Byte size to move from one element to the
    ///  next element.</param>
    /// <param name="AUV">Vertex normalized texture coordinates.</param>
    /// <param name="AUVStride">Byte size to move from one element to the next
    ///  element.</param>
    /// <param name="AIndices">(Optional) Pointer to an array of indices into
    ///  the vertex arrays. If nil (default) all vertices will be rendered in
    ///  sequential order.</param>
    /// <param name="ANumIndices">Number of indices.</param>
    /// <param name="AIndexType">(Optional) type of each index in AIndices.
    ///  Defaults to TSdlIndexType.Word</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawGeometry(
      const AXY: TArray<TSdlPointF>; const AXYStride: Integer;
      const AColor: TArray<TSdlColorF>; const AColorStride: Integer;
      const AUV: TArray<TSdlPointF>; const AUVStride: Integer;
      const AIndices: Pointer = nil; const ANumIndices: Integer = 0;
      const AIndexType: TSdlIndexType = TSdlIndexType.Word); overload; inline;

    /// <summary>
    ///  Render a list of triangles, optionally using a texture and indices into the
    ///  vertex array. Color and alpha modulation is done per vertex
    ///  (TSdlTexture.ColorMod and TSdlTexture.AlphaMod are ignored).
    /// </summary>
    /// <param name="ARenderer">the rendering context.</param>
    /// <param name="ATexture">The texture to use.</param>
    /// <param name="AXY">Vertex positions.</param>
    /// <param name="AXYStride">Byte size to move from one element to the next
    ///  element.</param>
    /// <param name="AColor">Vertex colors.</param>
    /// <param name="AColorStride">Byte size to move from one element to the
    ///  next element.</param>
    /// <param name="AUV">Vertex normalized texture coordinates.</param>
    /// <param name="AUVStride">Byte size to move from one element to the next
    ///  element.</param>
    /// <param name="AIndices">(Optional) Pointer to an array of indices into
    ///  the vertex arrays. If nil (default) all vertices will be rendered in
    ///  sequential order.</param>
    /// <param name="ANumIndices">Number of indices.</param>
    /// <param name="AIndexType">(Optional) type of each index in AIndices.
    ///  Defaults to TSdlIndexType.Word</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawGeometry(const ATexture: TSdlTexture;
      const AXY: TArray<TSdlPointF>; const AXYStride: Integer;
      const AColor: TArray<TSdlColorF>; const AColorStride: Integer;
      const AUV: TArray<TSdlPointF>; const AUVStride: Integer;
      const AIndices: Pointer = nil; const ANumIndices: Integer = 0;
      const AIndexType: TSdlIndexType = TSdlIndexType.Word); overload; inline;

    /// <summary>
    ///  Read pixels from the entire viewport of the current rendering target.
    ///
    ///  The returned surface should be freed.
    ///
    ///  **WARNING**: This is a very slow operation, and should not be used
    ///  frequently. If you're using this on the main rendering target, it should be
    ///  called after rendering and before Present.
    /// </summary>
    /// <returns>A new SDL surface</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function ReadPixels: TSdlSurface; overload; inline;

    /// <summary>
    ///  Read pixels from the current rendering target.
    ///
    ///  The returned surface should be freed.
    ///
    ///  **WARNING**: This is a very slow operation, and should not be used
    ///  frequently. If you're using this on the main rendering target, it should be
    ///  called after rendering and before Present.
    /// </summary>
    /// <param name="ARect">The area to read in pixels relative to the to
    ///  current viewport.</param>
    /// <returns>A new SDL surface</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function ReadPixels(const ARect: TSdlRect): TSdlSurface; overload; inline;

    /// <summary>
    ///  Force the rendering context to flush any pending commands and state.
    ///
    ///  You do not need to (and in fact, shouldn't) call this function unless you
    ///  are planning to call into OpenGL/Direct3D/Metal/whatever directly, in
    ///  addition to using a TSdlRenderer.
    ///
    ///  This is for a very-specific case: if you are using SDL's render API, and
    ///  you plan to make OpenGL/D3D/whatever calls in addition to SDL render API
    ///  calls. If this applies, you should call this function between calls to
    ///  SDL's render API and the low-level API you're using in cooperation.
    ///
    ///  In all other cases, you can ignore this function.
    ///
    ///  This call makes SDL flush any pending rendering work it was queueing up to
    ///  do later in a single batch, and marks any internal cached state as invalid,
    ///  so it'll prepare all its state again later, from scratch.
    ///
    ///  This means you do not need to save state in your rendering code to protect
    ///  the SDL renderer. However, there lots of arbitrary pieces of Direct3D and
    ///  OpenGL state that can confuse things; you should use your best judgment and
    ///  be prepared to make changes if specific state needs to be protected.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Flush; inline;

    /// <summary>
    ///  Add a set of synchronization semaphores for the current frame when
    ///  using Vulkan.
    ///
    ///  The Vulkan renderer will wait for `AWaitSemaphore` before submitting
    ///  rendering commands and signal `ASignalSemaphore` after rendering commands
    ///  are complete for this frame.
    ///
    ///  This should be called each frame that you want semaphore synchronization.
    ///  The Vulkan renderer may have multiple frames in flight on the GPU, so you
    ///  should have multiple semaphores that are used for synchronization. Querying
    ///  TSdlProperty.RendererVulkanSwapChainImageCount will give you the
    ///  maximum number of semaphores you'll need.
    /// </summary>
    /// <param name="AWaitStageMask">The VkPipelineStageFlags for the wait.</param>
    /// <param name="AWaitSemaphore">A VkSempahore to wait on before rendering
    ///  the current frame, or 0 if not needed.</param>
    /// <param name="ASignalSemaphore">A VkSempahore that SDL will signal when
    ///  rendering for the current frame is complete, or 0 if not needed.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is **NOT** safe to call this method from two threads at once.
    /// </remarks>
    procedure AddVulkanSemaphores(const AWaitStageMask: UInt32;
      const AWaitSemaphore, ASignalSemaphore: Int64); inline;

    /// <summary>
    ///  Draw debug text.
    ///
    ///  This function will render a string of text. Note that this is a
    ///  convenience function for debugging, with severe limitations, and
    ///  not intended to be used for production apps and games.
    ///
    ///  Among these limitations:
    ///
    ///  - It will only renders ASCII characters.
    ///  - It has a single, tiny size (8x8 pixels). One can use logical presentation
    ///    or scaling to adjust it, but it will be blurry.
    ///  - It uses a simple, hardcoded bitmap font. It does not allow different font
    ///    selections and it does not support truetype, for proper scaling.
    ///  - It does no word-wrapping and does not treat newline characters as a line
    ///    break. If the text goes out of the window, it's gone.
    ///
    ///  For serious text rendering, there are several good options, such as
    ///  SDL_ttf, stb_truetype, or other external libraries.
    ///
    ///  On first use, this will create an internal texture for rendering glyphs.
    ///  This texture will live until the renderer is destroyed.
    ///
    ///  The text is drawn in the color specified by DrawColor.
    /// </summary>
    /// <param name="AX">The X coordinate where the top-left corner of the text
    ///  will draw.</param>
    /// <param name="AY">the Y coordinate where the top-left corner of the text
    ///  will draw.</param>
    /// <param name="AStr">The string to render.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawDebugText(const AX, AY: Single; const AString: String); overload; inline;

    /// <summary>
    ///  Draw debug text.
    ///
    ///  This function will render a string of text. Note that this is a
    ///  convenience function for debugging, with severe limitations, and
    ///  not intended to be used for production apps and games.
    ///
    ///  Among these limitations:
    ///
    ///  - It will only renders ASCII characters.
    ///  - It has a single, tiny size (8x8 pixels). One can use logical presentation
    ///    or scaling to adjust it, but it will be blurry.
    ///  - It uses a simple, hardcoded bitmap font. It does not allow different font
    ///    selections and it does not support truetype, for proper scaling.
    ///  - It does no word-wrapping and does not treat newline characters as a line
    ///    break. If the text goes out of the window, it's gone.
    ///
    ///  For serious text rendering, there are several good options, such as
    ///  SDL_ttf, stb_truetype, or other external libraries.
    ///
    ///  On first use, this will create an internal texture for rendering glyphs.
    ///  This texture will live until the renderer is destroyed.
    ///
    ///  The text is drawn in the color specified by DrawColor.
    /// </summary>
    /// <param name="APosition">The top-left corner of the text will draw.
    ///  will draw.</param>
    /// <param name="AStr">The string to render.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SDL_DEBUG_TEXT_FONT_CHARACTER_SIZE"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure DrawDebugText(const APosition: TSdlPointF; const AString: String); overload; inline;

    /// <summary>
    ///  The (integer) color used for drawing operations (for drawing or filling
    ///  rectangles, lines, and points, and for Clear).
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetDrawColor"/>
    /// <seealso cref="DrawColorFloat"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property DrawColor: TSdlColor read GetDrawColor write SetDrawColor;

    /// <summary>
    ///  The (floating-point) color used for drawing operations (for drawing or
    ///  filling rectangles, lines, and points, and for Clear).
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetDrawColor"/>
    /// <seealso cref="DrawColor"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property DrawColorFloat: TSdlColorF read GetDrawColorFloat write SetDrawColorFloat;

    /// <summary>
    ///  The window associated with the renderer.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Window: TSdlWindow read GetWindow;

    /// <summary>
    ///  The name of the renderer.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  The output size in pixels of a rendering context.
    ///
    ///  This returns the true output size in pixels, ignoring any render targets or
    ///  logical size and presentation.
    /// </summary>
    /// <param name="ARenderer">the rendering context.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="CurrentOutputSize"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property OutputSize: TSdlSize read GetOutputSize;

    /// <summary>
    ///  The current output size in pixels of a rendering context.
    ///
    ///  If a rendering target is active, this will return the size of the rendering
    ///  target in pixels, otherwise if a logical size is set, it will return the
    ///  logical size, otherwise it will return the value of OutputSize.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="OutputSize"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property CurrentOutputSize: TSdlSize read GetCurrentOutputSize;

    /// <summary>
    ///  Get the final presentation rectangle for rendering.
    ///
    ///  This property returns the calculated rectangle used for logical
    ///  presentation, based on the presentation mode and output size. If logical
    ///  presentation is disabled, it will fill the rectangle with the output size,
    ///  in pixels.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="SetLogicalPresentation"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property LogicalPresentationRect: TSdlRect read GetLogicalPresentationRect;

    /// <summary>
    ///  The current rendering target.
    ///
    ///  The default render target is the window for which the renderer was created.
    ///  To stop rendering to a texture and render to the window again, set this
    ///  property to a nil `texture`.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Target: TSdlTexture read GetTarget write SetTarget;

    /// <summary>
    ///  The drawing area for rendering on the current target.
    ///
    ///  Drawing will clip to this area (separately from any clipping done with
    ///  ClipRect), and the top left of the area will become coordinate (0, 0)
    ///  for future drawing commands.
    ///
    ///  The area's width and height must be >= 0.
    ///
    ///  Call ResetViewport to set the viewport to the entire target.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsViewportSet"/>
    /// <seealso cref="ResetViewport"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Viewport: TSdlRect read GetViewport write SetViewport;

    /// <summary>
    ///  Whether an explicit rectangle was set as the viewport.
    ///
    ///  This is useful if you're saving and restoring the viewport and want to know
    ///  whether you should restore a specific rectangle or reset the viewport.
    ///  Note that the viewport is always reset when changing rendering targets.
    /// </summary>
    /// <seealso cref="Viewport"/>
    /// <seealso cref="ResetViewport"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property IsViewportSet: Boolean read GetIsViewportSet;

    /// <summary>
    ///  The safe area for rendering within the current viewport.
    ///
    ///  Some devices have portions of the screen which are partially obscured or
    ///  not interactive, possibly due to on-screen controls, curved edges, camera
    ///  notches, TV overscan, etc. This function provides the area of the current
    ///  viewport which is safe to have interactible content. You should continue
    ///  rendering into the rest of the render target, but it should not contain
    ///  visually important or interactible content.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property SafeArea: TSdlRect read GetSafeArea;

    /// <summary>
    ///  The clip rectangle for rendering on the specified target, relative to
    ///  the viewport (or an empty rectangle if clipping is disabled).
    ///
    ///  To disable clipping, set IsClipEnabled to False.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsClipEnabled"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ClipRect: TSdlRect read GetClipRect write SetClipRect;

    /// <summary>
    ///  Whether clipping is enabled on the given renderer.
    ///
    ///  Set this property to False to disable clipping.
    ///  To enable clipping, set the ClipRect property.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ClipRect"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property IsClipEnabled: Boolean read GetIsClipEnabled write SetIsClipEnabled;

    /// <summary>
    ///  The drawing scale for rendering on the current target.
    ///
    ///  The drawing coordinates are scaled by the X/Y scaling factors before they
    ///  are used by the renderer. This allows resolution independent drawing with a
    ///  single coordinate system.
    ///
    ///  If this results in scaling or subpixel drawing by the rendering backend, it
    ///  will be handled using the appropriate quality hints. For best results use
    ///  integer scaling factors.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Scale: TSdlPointF read GetScale write SetScale;

    /// <summary>
    ///  Set the color scale used for render operations.
    ///
    ///  The color scale is an additional scale multiplied into the pixel color
    ///  value while rendering. This can be used to adjust the brightness of colors
    ///  during HDR rendering, or changing HDR video brightness when playing on an
    ///  SDR display.
    ///
    ///  The color scale does not affect the alpha channel, only the color
    ///  brightness.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property ColorScale: Single read GetColorScale write SetColorScale;

    /// <summary>
    ///  Set the blend mode used for drawing operations (Fill and Line).
    ///
    ///  If the blend mode is not supported, the closest supported mode is chosen.
    /// </summary>
    /// <returns>true on success or false on failure; call SDL_GetError() for more information.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property DrawBlendMode: TSdlBlendMode read GetDrawBlendMode write SetDrawBlendMode;

    /// <summary>
    ///  The CAMetalLayer associated with the given Metal renderer.
    ///
    ///  This property returns a pointer, so SDL doesn't have to link to Metal,
    ///  but it can be safely cast to a `CAMetalLayer` using `TCAMetalLayer.Wrap()`.
    ///
    ///  Returns nil if the renderer isn't a Metal renderer.
    /// </summary>
    /// <seealso cref="MetalCommandEncoder"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property MetalLayer: Pointer read GetMetalLayer;

    /// <summary>
    ///  Get the Metal command encoder for the current frame.
    ///
    ///  This property returns a pointer, so SDL doesn't have to link to Metal.
    ///
    ///  Returns nil if the renderer isn't a Metal renderer, or if Metal refuses
    ///  to give SDL a drawable to render to, which might happen if the window
    ///  is hidden/minimized/offscreen. This doesn't apply to command encoders
    ///  for render targets, just the window's backbuffer. Check your return values!
    /// </summary>
    /// <seealso cref="MetalLayer"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property MetalCommandEncoder: Pointer read GetMetalCommandEncoder;

    /// <summary>
    ///  The VSync of the renderer.
    ///
    ///  When a renderer is created, vsync defaults to TSdlRendererVSync.Disabled.
    ///
    ///  Can be 1 to synchronize present with every vertical refresh, 2 to
    ///  synchronize present with every second vertical refresh, etc.,
    ///  TSdlRendererVSync.Adaptive for late swap tearing (adaptive vsync), or
    ///  TSdlRendererVSync.Disabled to disable. Not every value is supported by
    ///  every driver, so you should check the return value to see whether the
    ///  requested setting is supported.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property VSync: TSdlRendererVsync read GetVSync write SetVSync;

    /// <summary>
    ///  The properties associated with the renderer.
    ///
    ///  The following read-only properties are provided by SDL:
    ///
    ///  - `TSdlProperty.RendererName`: the name of the rendering driver
    ///  - `TSdlProperty.RendererWindow`: the window where rendering is
    ///    displayed, if any
    ///  - `TSdlProperty.RendererSurface`: the surface where rendering is
    ///    displayed, if this is a software renderer without a window
    ///  - `TSdlProperty.RendererVSync`: the current vsync setting
    ///  - `TSdlProperty.RendererMaxTextureSize`: the maximum texture width
    ///    and height
    ///  - `TSdlProperty.RendererTextureFormats`: a PSdlPixelFormat array of
    ///    pixel formats, terminated with TSdlPixelFormat.Unknown, representing
    ///    the available texture formats for this renderer.
    ///  - `TSdlProperty.RendererOutputColorspace`: a TSdlColorspace value
    ///    describing the colorspace for output to the display, defaults to
    ///    TSdlColorspace.Srgb.
    ///  - `TSdlProperty.RendererHdrEnabled`: True if the output colorspace is
    ///    TSdlColorspace.SrgbLinear and the renderer is showing on a display with
    ///    HDR enabled. This property can change dynamically when
    ///    TSdlEventKind.WindowHdrStateChanged is sent.
    ///  - `TSdlProperty.RendererSdrWhitePoint`: the value of SDR white in the
    ///    TSdlColorspace.SrgbLinear colorspace. When HDR is enabled, this value is
    ///    automatically multiplied into the color scale. This property can change
    ///    dynamically when TSdlEventKind.HdrStateChanged is sent.
    ///  - `TSdlProperty.RendererHdrHeadroom`: the additional high dynamic range
    ///    that can be displayed, in terms of the SDR white point. When HDR is not
    ///    enabled, this will be 1.0. This property can change dynamically when
    ///    TSdlEventKind.HdrStateChanged is sent.
    ///
    ///  With the Direct3D renderer:
    ///
    ///  - `TSdlProperty.RendererD3D9Device`: the IDirect3DDevice9 associated
    ///    with the renderer
    ///
    ///  With the Direct3D11 renderer:
    ///
    ///  - `TSdlProperty.RendererD3D11Device`: the ID3D11Device associated
    ///    with the renderer
    ///  - `TSdlProperty.RendererD3D11SwapChain`: the IDXGISwapChain1
    ///    associated with the renderer. This may change when the window is resized.
    ///
    ///  With the Direct3D12 renderer:
    ///
    ///  - `TSdlProperty.RendererD3D12Device`: the ID3D12Device associated
    ///    with the renderer
    ///  - `TSdlProperty.RendererD3D12SwapChain`: the IDXGISwapChain4
    ///    associated with the renderer.
    ///  - `TSdlProperty.RendererD3D12CommandQueue`: the ID3D12CommandQueue
    ///    associated with the renderer
    ///
    ///  With the vulkan renderer:
    ///
    ///  - `TSdlProperty.RendererVulkanInstance`: the VkInstance associated
    ///    with the renderer
    ///  - `TSdlProperty.RendererVulkanSurface`: the VkSurfaceKHR associated
    ///    with the renderer
    ///  - `TSdlProperty.RendererVulkanPhysicalDevice`: the VkPhysicalDevice
    ///    associated with the renderer
    ///  - `TSdlProperty.RendererVulkanDevice`: the VkDevice associated with
    ///    the renderer
    ///  - `TSdlProperty.RendererVulkanGraphicsQueueFamilyIndex`: the queue
    ///    family index used for rendering
    ///  - `TSdlProperty.RendererVulkanPresentQueueFamilyIndex`: the queue
    ///    family index used for presentation
    ///  - `TSdlProperty.RendererVulkanSwapChainImageCount`: the number of
    ///    swapchain images, or potential frames in flight, used by the Vulkan
    ///    renderer
    ///
    ///  With the GPU renderer:
    ///
    ///  - `TSdlProperty.RendererGpuDevice`: the TSdlGpuDevice associated with
    ///    the renderer
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;

    /// <summary>
    ///  The number of 2D rendering drivers available for the current display.
    ///
    ///  A render driver is a set of code that handles rendering and texture
    ///  management on a particular display. Normally there is only one, but some
    ///  drivers may have several available with different capabilities.
    ///
    ///  There may be none if SDL was compiled without render support.
    /// </summary>
    /// <seealso cref="Drivers"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property DriverCount: Integer read GetDriverCount;

    /// <summary>
    ///  The names of the built in 2D rendering driver (or an empty string if
    ///  an invalid index is given).
    ///
    ///  The list of rendering drivers is given in the order that they are normally
    ///  initialized by default; the drivers that seem more reasonable to choose
    ///  first (as far as the SDL developers believe) are earlier in the list.
    ///
    ///  The names of drivers are all simple, low-ASCII identifiers, like 'opengl',
    ///  'direct3d12' or 'metal'. These never have Unicode characters, and are not
    ///  meant to be proper names.
    /// </summary>
    /// <param name="AIndex">The index of the rendering driver; the value ranges
    ///  from 0 to DriverCount - 1.</param>
    /// <seealso cref="DriverCount"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property Drivers[const AIndex: Integer]: String read GetDriver;
  end;

type
  _TSdlTextureHelper = record helper for TSdlTexture
  {$REGION 'Internal Declarations'}
  private
    function GetRenderer: TSdlRenderer; inline;
  {$ENDREGION 'Internal Declarations'}
  public

    /// <summary>
    ///  The renderer that created the texture.
    /// </summary>
    /// <remarks>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    property Renderer: TSdlRenderer read GetRenderer;
  end;
{$ENDREGION '2D Accelerated Rendering'}

{$REGION 'OpenGL and EGL Support'}
type
  /// <summary>
  ///  An OpenGL context.
  /// </summary>
  TSdlGLContext = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_GLContext;
    class function GetCurrent: TSdlGLContext; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGLContext; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGLContext.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGLContext): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGLContext; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGLContext.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGLContext): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGLContext; inline; static;
  public
    /// <summary>
    ///  Create an OpenGL context for an OpenGL window, and make it current.
    ///
    ///  Windows users new to OpenGL should note that, for historical reasons, GL
    ///  functions added after OpenGL version 1.1 are not available by default.
    ///  Those functions must be loaded at run-time, either with an OpenGL
    ///  extension-handling library or with TSdlGL.GetProcAddress and its related
    ///  functions.
    ///
    /// </summary>
    /// <param name="AWindow">The window to associate with the context.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="MakeCurrent"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AWindow: TSdlWindow);

    /// <summary>
    ///  Free an OpenGL context.
    /// </summary>
    /// <seealso cref="Create"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Set up this OpenGL context for rendering into an OpenGL window.
    ///
    ///  This context must have been created with a compatible window.
    /// </summary>
    /// <param name="AWindow">The window to associate with the context.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure MakeCurrent(const AWindow: TSdlWindow); inline;

    /// <summary>
    ///  The currently active OpenGL context.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="MakeCurrent"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Current: TSdlGLContext read GetCurrent;
  end;

type
  /// <summary>
  ///  An enumeration of OpenGL configuration attributes.
  ///
  ///  While you can set most OpenGL attributes normally, the attributes listed
  ///  above must be known before SDL creates the window that will be used with
  ///  the OpenGL context. These attributes are set and read with
  ///  TSdlGL.Attributes.
  ///
  ///  In some cases, these attributes are minimum requests; the GL does not
  ///  promise to give you exactly what you asked for. It's possible to ask for a
  ///  16-bit depth buffer and get a 24-bit one instead, for example, or to ask
  ///  for no stencil buffer and still have one available. Context creation should
  ///  fail if the GL can't provide your requested attributes at a minimum, but
  ///  you should check to see exactly what you got.
  /// </summary>
  TSdlGLAttr = (
    /// <summary>The minimum number of bits for the red channel of the color
    ///  buffer; defaults to 3.</summary>
    RedSize                  = SDL_GL_RED_SIZE,

    /// <summary>The minimum number of bits for the green channel of the color
    ///  buffer; defaults to 3.</summary>
    GreenSize                = SDL_GL_GREEN_SIZE,

    /// <summary>The minimum number of bits for the blue channel of the color
    ///  buffer; defaults to 2.</summary>
    BlueSize                 = SDL_GL_BLUE_SIZE,

    /// <summary>The minimum number of bits for the alpha channel of the color
    ///  buffer; defaults to 0.</summary>
    AlphaSize                = SDL_GL_ALPHA_SIZE,

    /// <summary>The minimum number of bits for frame buffer size; defaults to 0.</summary>
    BufferSize               = SDL_GL_BUFFER_SIZE,

    /// <summary>Whether the output is single or double buffered; defaults to
    ///  double buffering on.</summary>
    DoubleBuffer             = SDL_GL_DOUBLEBUFFER,

    /// <summary>The minimum number of bits in the depth buffer; defaults to 16.</summary>
    DepthSize                = SDL_GL_DEPTH_SIZE,

    /// <summary>The minimum number of bits in the stencil buffer; defaults to 0.</summary>
    StencilSize              = SDL_GL_STENCIL_SIZE,

    /// <summary>The minimum number of bits for the red channel of the
    ///  accumulation buffer; defaults to 0.</summary>
    AccumRedSize             = SDL_GL_ACCUM_RED_SIZE,

    /// <summary>The minimum number of bits for the green channel of the
    ///  accumulation buffer; defaults to 0.</summary>
    AccumGreenSize           = SDL_GL_ACCUM_GREEN_SIZE,

    /// <summary>The minimum number of bits for the blue channel of the
    ///  accumulation buffer; defaults to 0.</summary>
    AccumBlueSize            = SDL_GL_ACCUM_BLUE_SIZE,

    /// <summary>The minimum number of bits for the alpha channel of the
    ///  accumulation buffer; defaults to 0.</summary>
    AccumAlphaSize           = SDL_GL_ACCUM_ALPHA_SIZE,

    /// <summary>Whether the output is stereo 3D; defaults to off.</summary>
    Stereo                   = SDL_GL_STEREO,

    /// <summary>The number of buffers used for multisample anti-aliasing;
    ///  defaults to 0.</summary>
    MultisampleBuffers       = SDL_GL_MULTISAMPLEBUFFERS,

    /// <summary>The number of samples used around the current pixel used for
    ///  multisample anti-aliasing.</summary>
    MultipsampleSamples      = SDL_GL_MULTISAMPLESAMPLES,

    /// <summary>Set to 1 to require hardware acceleration, set to 0 to force
    ///  software rendering; defaults to allow either.</summary>
    AcceleratedVisual        = SDL_GL_ACCELERATED_VISUAL,

    /// <summary>OpenGL context major version.</summary>
    ContextMajorVersion      = SDL_GL_CONTEXT_MAJOR_VERSION,

    /// <summary>OpenGL context minor version.</summary>
    ContextMinorVersion      = SDL_GL_CONTEXT_MINOR_VERSION,

    /// <summary>Some combination of 0 or more of elements of the
    ///  TSdlGLContextFlag enumeration; defaults to [].</summary>
    ContextFlags             = SDL_GL_CONTEXT_FLAGS,

    /// <summary>Type of GL context (Core, Compatibility, ES). See TSdlGLProfile;
    ///  default value depends on platform.</summary>
    ContextProfileMask       = SDL_GL_CONTEXT_PROFILE_MASK,

    /// <summary>OpenGL context sharing; defaults to 0.</summary>
    ShareWithCurrentContext  = SDL_GL_SHARE_WITH_CURRENT_CONTEXT,

    /// <summary>Requests sRGB capable visual; defaults to 0.</summary>
    FramebufferSrgbCapable   = SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,

    /// <summary>Sets context the release behavior. See TSdlGLContextReleaseFlags;
    ///  defaults to [Flush].</summary>
    ContextReleaseBehavior   = SDL_GL_CONTEXT_RELEASE_BEHAVIOR,

    /// <summary>Set context reset notification. See TSdlGLContextResetNotification;
    ///  defaults to NoNotification.</summary>
    ContextResetNotification = SDL_GL_CONTEXT_RESET_NOTIFICATION,

    ContextNoError           = SDL_GL_CONTEXT_NO_ERROR,
    FloatBuffers             = SDL_GL_FLOATBUFFERS,
    EglPlatform              = SDL_GL_EGL_PLATFORM);

type
  /// <summary>
  ///  Possible values to be set for the TSdlGLAttr.ContextProfileMask attribute.
  /// </summary>
  TSdlGLProfile = (
    /// <summary>OpenGL Core Profile context</summary>
    Core          = SDL_GL_CONTEXT_PROFILE_CORE,

    /// <summary>OpenGL Compatibility Profile context</summary>
    Compatibility = SDL_GL_CONTEXT_PROFILE_COMPATIBILITY,

    /// <summary>GLX_CONTEXT_ES2_PROFILE_BIT_EXT</summary>
    Es            = SDL_GL_CONTEXT_PROFILE_ES);

type
  /// <summary>
  ///  Possible context flags.
  /// </summary>
  TSdlGLContextFlag = (
    Debug             = 0,
    ForwardCompatible = 1,
    RobustAccess      = 2,
    ResetIsolation    = 3);

  /// <summary>
  ///  Set of context flags to be set for the TSdlGLAttr.ContextFlags attribute.
  /// </summary>
  TSdlGLContextFlags = set of TSdlGLContextFlag;

type
  /// <summary>
  ///  Possible context release flags.
  /// </summary>
  TSdlGLContextReleaseFlag = (
    Flush = 0);

type
  /// <summary>
  ///  Possible values to be set for the TSdlGLAttr.ContextReleaseBehavior
  ///  attribute.
  /// </summary>
  TSdlGLContextReleaseFlags = set of TSdlGLContextReleaseFlag;

type
  /// <summary>
  ///  Possible values to be set TSdlGLAttr.ContextReleaseNotification attribute.
  /// </summary>
  TSdlGLContextResetNotification = (
    NoNotification = SDL_GL_CONTEXT_RESET_NO_NOTIFICATION,
    LoseContext    = SDL_GL_CONTEXT_RESET_LOSE_CONTEXT);

type
  /// <summary>
  ///  For working with OpenGL in SDL.
  /// </summary>
  TSdlGL = record
  {$REGION 'Internal Declarations'}
  private
    class function GetAttribute(const AAttr: TSdlGLAttr): Integer; inline; static;
    class procedure SetAttribute(const AAttr: TSdlGLAttr; const AValue: Integer); inline; static;
    class function GetCurrentWindow: TSdlWindow; inline; static;
    class function GetSwapInterval: Integer; inline; static;
    class procedure SetSwapInterval(const AValue: Integer); inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Dynamically load an OpenGL library.
    ///
    ///  This should be done after initializing the video driver, but before
    ///  creating any OpenGL windows. If no OpenGL library is loaded, the default
    ///  library will be loaded upon creation of the first OpenGL window.
    ///
    ///  If you do this, you need to retrieve all of the GL functions used in your
    ///  program from the dynamic library using GetProcAddress.
    /// </summary>
    /// <param name="APath">The platform dependent OpenGL library name, or an
    ///  empty string to open the default OpenGL library.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetProcAddress"/>
    /// <seealso cref="UnloadLibrary"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure LoadLibrary(const APath: String); static;

    /// <summary>
    ///  Get an OpenGL function by name.
    ///
    ///  If the GL library is loaded at runtime with LoadLibrary, then all
    ///  GL functions must be retrieved this way. Usually this is used to retrieve
    ///  function pointers to OpenGL extensions.
    ///
    ///  There are some quirks to looking up OpenGL functions that require some
    ///  extra care from the application. If you code carefully, you can handle
    ///  these quirks without any platform-specific code, though:
    ///
    ///  - On Windows, function pointers are specific to the current GL context;
    ///  this means you need to have created a GL context and made it current
    ///  before calling GetProcAddress. If you recreate your context or
    ///  create a second context, you should assume that any existing function
    ///  pointers aren't valid to use with it. This is (currently) a
    ///  Windows-specific limitation, and in practice lots of drivers don't suffer
    ///  this limitation, but it is still the way the wgl API is documented to
    ///  work and you should expect crashes if you don't respect it. Store a copy
    ///  of the function pointers that comes and goes with context lifespan.
    ///  - Some OpenGL drivers, on all platforms, *will* return `nil` if a function
    ///  isn't supported, but you can't count on this behavior. Check for
    ///  extensions you use, and if you get a `nil` anyway, act as if that
    ///  extension wasn't available. This is probably a bug in the driver, but you
    ///  can code defensively for this scenario anyhow.
    ///  - OpenGL function pointers must be declared `stdcall`, even when not
    ///  running on Windows. This will ensure the proper calling convention is
    ///  followed on platforms where this matters (Win32) thereby avoiding stack
    ///  corruption.
    /// </summary>
    /// <param name="AProc">The name of an OpenGL function.</param>
    /// <returns>A pointer to the named OpenGL function. The returned pointer
    ///  should be cast to the appropriate function signature.</returns>
    /// <seealso cref="IsExtensionSupported"/>
    /// <seealso cref="LoadLibrary"/>
    /// <seealso cref="UnloadLibrary"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class function GetProcAddress(const AProc: String): Pointer; inline; static;

    /// <summary>
    ///  Unload the OpenGL library previously loaded by LoadLibrary.
    /// </summary>
    /// <seealso cref="LoadLibrary"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure UnloadLibrary; inline; static;

    /// <summary>
    ///  Check if an OpenGL extension is supported for the current context.
    ///
    ///  This function operates on the current GL context; you must have created a
    ///  context and it must be current before calling this function. Do not assume
    ///  that all contexts you create will have the same set of extensions
    ///  available, or that recreating an existing context will offer the same
    ///  extensions again.
    ///
    ///  While it's probably not a massive overhead, this function is not an O(1)
    ///  operation. Check the extensions you care about after creating the GL
    ///  context and save that information somewhere instead of calling the function
    ///  every time you need to know.
    /// </summary>
    /// <param name="AExtension">The name of the extension to check.</param>
    /// <returns>True if the extension is supported, False otherwise.</returns>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class function IsExtensionSupported(const AExtension: String): Boolean; inline; static;

    /// <summary>
    ///  Reset all previously set OpenGL context attributes to their default values.
    /// </summary>
    /// <seealso cref="Attributes"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure ResetAttributes; inline; static;

    /// <summary>
    ///  Update a window with OpenGL rendering.
    ///
    ///  This is used with double-buffered OpenGL contexts, which are the default.
    ///
    ///  On macOS, make sure you bind 0 to the draw framebuffer before swapping the
    ///  window, otherwise nothing will happen. If you aren't using
    ///  glBindFramebuffer, this is the default and you won't have to do anything
    ///  extra.
    /// </summary>
    /// <param name="AWindow">The window to change.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure SwapWindow(const AWindow: TSdlWindow); inline; static;

    /// <summary>
    ///  OpenGL window attributes.
    ///
    ///  You should set these before window creation.
    ///
    ///  You shouls get these after creating the OpenGL context, since the
    ///  values obtained can differ from the requested ones.
    /// </summary>
    /// <param name="AAttr">The OpenGL attribute to get or set.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="ResetAttributes"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Attributes[const AAttr: TSdlGLAttr]: Integer read GetAttribute write SetAttribute;

    /// <summary>
    ///  The currently active OpenGL window.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property CurrentWindow: TSdlWindow read GetCurrentWindow;

    /// <summary>
    ///  The swap interval for the current OpenGL context.
    ///
    ///  Some systems allow specifying -1 for the interval, to enable adaptive
    ///  vsync. Adaptive vsync works the same as vsync, but if you've already missed
    ///  the vertical retrace for a given frame, it swaps buffers immediately, which
    ///  might be less jarring for the user during occasional framerate drops. If an
    ///  application requests adaptive vsync and the system does not support it,
    ///  this function will fail and return false. In such a case, you should
    ///  probably retry the call with 1 for the interval.
    ///
    ///  Adaptive vsync is implemented for some glX drivers with
    ///  GLX_EXT_swap_control_tear, and for some Windows drivers with
    ///  WGL_EXT_swap_control_tear.
    ///
    ///  If the system can't determine the swap interval, or there isn't a valid
    ///  current context, this property will return 0 as a safe default.
    ///
    ///  Read more on the
    ///  <see href="https://www.khronos.org/opengl/wiki/Swap_Interval#Adaptive_Vsync">Khronos wiki</see>.
    /// </summary>
    /// <param name="AInterval">0 for immediate updates, 1 for updates
    ///  synchronized with the vertical retrace, -1 for adaptive vsync.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property SwapInterval: Integer read GetSwapInterval write SetSwapInterval;
  end;

type
  /// <summary>
  ///  An EGL display.
  /// </summary>
  TSdlEglDisplay = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_EGLDisplay;
    class function GetCurrent: TSdlEglDisplay; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlEglDisplay; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlEglDisplay.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlEglDisplay): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlEglDisplay; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlEglDisplay.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlEglDisplay): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlEglDisplay; inline; static;
  public
    /// <summary>
    ///  The currently active EGL display.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Current: TSdlEglDisplay read GetCurrent;
  end;

type
  /// <summary>
  ///  An EGL config.
  /// </summary>
  TSdlEglConfig = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_EGLConfig;
    class function GetCurrent: TSdlEglConfig; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlEglConfig; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlEglConfig.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlEglConfig): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlEglConfig; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlEglConfig.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlEglConfig): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlEglConfig; inline; static;
  public
    /// <summary>
    ///  The currently active EGL config.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Current: TSdlEglConfig read GetCurrent;
  end;

type
  /// <summary>
  ///  An EGL surface.
  /// </summary>
  TSdlEglSurface = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_EGLSurface;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlEglSurface; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlEglSurface.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlEglSurface): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlEglSurface; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlEglSurface.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlEglSurface): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlEglSurface; inline; static;
  public
    /// <summary>
    ///  Get the EGL surface associated with the window.
    /// </summary>
    /// <param name="AWindow">The window to query.</param>
    /// <returns>The EGL surface associated with the window.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class function ForWindow(const AWindow: TSdlWindow): TSdlEglSurface; inline; static;
  end;

type
  /// <summary>
  ///  An EGL attribute, used when creating an EGL context.
  /// </summary>
  TSdlEglAttrib = SDL_EGLAttrib;

type
  /// <summary>
  ///  An EGL integer attribute, used when creating an EGL surface.
  /// </summary>
  TSdlEglInt = SDL_EGLint;

type
  /// <summary>
  ///  EGL platform attribute initialization callback.
  ///
  ///  This is called when SDL is attempting to create an EGL context, to let the
  ///  app add extra attributes to its eglGetPlatformDisplay call.
  ///
  ///  The callback should return an array of EGL attributes array. If this
  ///  method returns nil, the TSdlWindow.Create process will fail gracefully.
  ///
  ///  The arrays returned by each callback will be appended to the existing
  ///  attribute arrays defined by SDL.
  /// </summary>
  /// <returns>An array of attributes.</returns>
  /// <seealso cref="TSdlEgl.SetAttributeCallbacks"/>
  TSdlEglAttribArrayCallback = function: TArray<TSdlEglAttrib> of object;

  /// <summary>
  ///  EGL surface/context attribute initialization callback.
  ///
  ///  This is called when SDL is attempting to create an EGL surface, to let the
  ///  app add extra attributes to its eglCreateWindowSurface or
  ///  eglCreateContext calls.
  ///
  ///  For convenience, the TSdlEglDisplay and TSdlEglConfig to use are provided
  ///  to the callback.
  ///
  ///  The callback should return an EGL attribute. If this function returns
  ///  `nil`, the TSdlWindow.Create process will fail gracefully.
  ///
  ///  The arrays returned by each callback will be appended to the existing
  ///  attribute arrays defined by SDL.
  /// <param name="ADisplay">The EGL display to be used.</param>
  /// <param name="AConfig">The EGL config to be used.</param>
  /// <returns>An array of attributes.</returns>
  /// <seealso cref="TSdlEgl.SetAttributeCallbacks"/>
  TSdlEglIntArrayCallback = function(const ADisplay: TSdlEglDisplay;
    const AConfig: TSdlEglConfig): TArray<TSdlEglInt> of object;

type
  /// <summary>
  ///  For working with OpenGL in SDL.
  /// </summary>
  TSdlEgl = record
  {$REGION 'Internal Declarations'}
  private class var
    FPlatformAttribCallback: TSdlEglAttribArrayCallback;
    FSurfaceAttribCallback: TSdlEglIntArrayCallback;
    FContextAttribCallback: TSdlEglIntArrayCallback;
  private
    class function PlatformAttribCallback(AUserdata: Pointer): PSDL_EGLAttrib; cdecl; static;
    class function SurfaceAttribCallback(AUserdata: Pointer;
      ADisplay: SDL_EGLDisplay; AConfig: SDL_EGLConfig): PSDL_EGLint; cdecl; static;
    class function ContextAttribCallback(AUserdata: Pointer;
      ADisplay: SDL_EGLDisplay; AConfig: SDL_EGLConfig): PSDL_EGLint; cdecl; static;
    class function ToIntArray(const AAttribs: TArray<TSdlEglInt>): PSDL_EGLint; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Get an EGL library function by name.
    ///
    ///  If an EGL library is loaded, this function allows applications to get entry
    ///  points for EGL functions. This is useful to provide to an EGL API and
    ///  extension loader.
    /// </summary>
    /// <param name="AProc">The name of an EGL function.</param>
    /// <returns>A pointer to the named EGL function. The returned pointer should
    ///  be cast to the appropriate function signature.</returns>
    /// <seealso cref="TSdlEglDisplay.Current"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class function GetProcAddress(const AProc: String): Pointer; inline; static;

    /// <summary>
    ///  Sets the callbacks for defining custom EGLAttrib arrays for EGL
    ///  initialization.
    ///
    ///  Callbacks that aren't needed can be set to `nil`.
    ///
    ///  NOTE: These callback pointers will be reset after TSdlGL.ResetAttributes.
    /// </summary>
    /// <param name="APlatformAttribCallback">Callback for attributes to pass to
    ///  eglGetPlatformDisplay. May be nil.</param>
    /// <param name="ASurfaceAttribCallback">Callback for attributes to pass to
    ///  eglCreateSurface. May be nil.</param>
    /// <param name="AContextAttribCallback">Callback for attributes to pass to
    ///  eglCreateContext. May be nil.</param>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure SetAttributeCallbacks(
      const APlatformAttribCallback: TSdlEglAttribArrayCallback;
      const ASurfaceAttribCallback, AContextAttribCallback: TSdlEglIntArrayCallback); static;
  end;
{$ENDREGION 'OpenGL and EGL Support'}

{$REGION 'Metal Support'}
/// <summary>
///  Functions to creating Metal layers and views on SDL windows.
///
///  This provides some platform-specific glue for Apple platforms. Most macOS
///  and iOS apps can use SDL without these functions, but this API they can be
///  useful for specific OS-level integration tasks.
/// </summary>

type
  /// <summary>
  ///  A a CAMetalLayer-backed NSView (macOS) or UIView (iOS/tvOS).
  /// </summary>
  TSdlMetalView = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_MetalView;
    function GetView: Pointer; inline;
    function GetLayer: Pointer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlMetalView; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlMetalView.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlMetalView): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlMetalView; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlMetalView.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlMetalView): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlMetalView; inline; static;
  public
    /// <summary>
    ///  Create a CAMetalLayer-backed NSView/UIView and attach it to the specified
    ///  window.
    ///
    ///  On macOS, this does *not* associate a MTLDevice with the CAMetalLayer on
    ///  its own. It is up to user code to do that.
    ///
    ///  The View property can by cast to a NSView (macOS) or UIView (iOS) using
    ///  TNSView.Wrap() or TUIView.Wrap(). To access the backing CAMetalLayer,
    ///  use the Layer property and wrap it using TCAMetalLayer.Wrap().
    /// </summary>
    /// <param name="AWindow">The window.</param>
    /// <seealso cref="Free"/>
    /// <seealso cref="Layer"/>
    constructor Create(const AWindow: TSdlWindow);

    /// <summary>
    ///  Destroy this TSdlMetalView object.
    ///
    ///  This should be called destroying the window, if it was created after the
    ///  window was created..
    /// </summary>
    procedure Free; inline;

    /// <summary>
    ///  The (Objective-C) ID of this metal view. You can use TNSView.Wrap (on
    ///  macOS) or TUIView.Wrap (on IOS) to get the underlying NSView or UIView.
    /// </summary>
    property View: Pointer read GetView;

    /// <summary>
    ///  The (Objective-C) ID of the backing CAMetalLayer for this viuew. You
    ///  can use TCAMetalLayer.Wrap to access this layer.
    /// </summary>
    property Layer: Pointer read GetLayer;
  end;
{$ENDREGION 'Metal Support'}

{$REGION 'Vulkan Support'}
/// <summary>
///  Functions for creating Vulkan surfaces on SDL windows.
///
///  For the most part, Vulkan operates independent of SDL, but it benefits from
///  a little support during setup.
///
///  Use SdlVulkanGetInstanceExtensions to get platform-specific bits for
///  creating a VkInstance, then SdlVulkanGetVkGetInstanceProcAddr to get
///  the appropriate function for querying Vulkan entry points. Then
///  SdlVulkanCreateSurface will get you the final pieces you need to
///  prepare for rendering into an TSdlWindow with Vulkan.
///
///  Unlike OpenGL, most of the details of "context" creation and window buffer
///  swapping are handled by the Vulkan API directly, so SDL doesn't provide
///  Vulkan equivalents of TSdlGL.SwapWindow(), etc; they aren't necessary.
/// </summary>

type
  VkInstance = Pointer;
  VkPhysicalDevice = Pointer;
  VkSurfaceKHR = Pointer;
  PVkAllocationCallbacks = Pointer;

/// <summary>
///  Dynamically load the Vulkan loader library.
///
///  This should be called after initializing the video driver, but before
///  creating any Vulkan windows. If no Vulkan loader library is loaded, the
///  default library will be loaded upon creation of the first Vulkan window.
///
///  SDL keeps a counter of how many times this function has been successfully
///  called, so it is safe to call this function multiple times, so long as it
///  is eventually paired with an equivalent number of calls to
///  SdlVulkanUnloadLibrary. The `APath` argument is ignored unless there is no
///  library currently loaded, and and the library isn't actually unloaded until
///  there have been an equivalent number of calls to SdlVulkanUnloadLibrary.
///
///  It is fairly common for Vulkan applications to link with libvulkan instead
///  of explicitly loading it at run time. This will work with SDL provided the
///  application links to a dynamic library and both it and SDL use the same
///  search path.
///
///  If you specify a non-empty `APath`, an application should retrieve all of the
///  Vulkan functions it uses from the dynamic library using
///  SdlVulkanGetVkGetInstanceProcAddr unless you can guarantee `APath` points
///  to the same vulkan loader library the application linked to.
///
///  On Apple devices, if `APath` is empty, SDL will attempt to find the
///  `vkGetInstanceProcAddr` address within all the Mach-O images of the current
///  process. This is because it is fairly common for Vulkan applications to
///  link with libvulkan (and historically MoltenVK was provided as a static
///  library). If it is not found, on macOS, SDL will attempt to load
///  `vulkan.framework/vulkan`, `libvulkan.1.dylib`,
///  `MoltenVK.framework/MoltenVK`, and `libMoltenVK.dylib`, in that order. On
///  iOS, SDL will attempt to load `libMoltenVK.dylib`. Applications using a
///  dynamic framework or .dylib must ensure it is included in its application
///  bundle.
///
///  On non-Apple devices, application linking with a static libvulkan is not
///  supported. Either do not link to the Vulkan loader or link to a dynamic
///  library version.
/// </summary>
/// <param name="APath">(Optional) platform dependent Vulkan loader library name
///  or empty (default)L.</param>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlVulkanGetVkGetInstanceProcAddr"/>
/// <seealso cref="SdlVulkanUnloadLibrary"/>
/// <remarks>
///  This routine is not thread safe.
/// </remarks>
procedure SdlVulkanLoadLibrary(const APath: String); inline;

/// <summary>
///  Get the address of the `vkGetInstanceProcAddr` function.
///
///  This should be called after either calling SdlVulkanLoadLibrary or
///  creating an SDL_Window with the `TSdlWindowFlag.Vulkan` flag.
/// </summary>
/// <returns>The function pointer for `vkGetInstanceProcAddr`.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
function SdlVulkanGetVkGetInstanceProcAddr: Pointer; inline;

/// <summary>
///  Unload the Vulkan library previously loaded by SdlVulkanLoadLibrary.
///
///  SDL keeps a counter of how many times this function has been called, so it
///  is safe to call this function multiple times, so long as it is paired with
///  an equivalent number of calls to SdlVulkanLoadLibrary. The library isn't
///  actually unloaded until there have been an equivalent number of calls to
///  SdlVulkanUnloadLibrary.
///
///  Once the library has actually been unloaded, if any Vulkan instances
///  remain, they will likely crash the program. Clean up any existing Vulkan
///  resources, and destroy appropriate windows, renderers and GPU devices
///  before calling this function.
/// </summary>
/// <seealso cref="SdlVulkanLoadLibrary"/>
/// <remarks>
///  This routine is not thread safe.
/// </remarks>
procedure SdlVulkanUnloadLibrary; inline;

/// <summary>
///  Get the Vulkan instance extensions needed for vkCreateInstance.
///
///  This should be called after either calling SdlVulkanLoadLibrary or
///  creating a TSdlWindow with the `TSdlWindowFlag.Vulkan` flag.
/// </summary>
/// <returns>An array of extension name strings.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlVulkanCreateSurface"/>
function SdlVulkanGetInstanceExtensions: TArray<String>;

/// <summary>
///  Create a Vulkan rendering surface for a window.
///
///  The `AWindow` must have been created with the `TSdlWindowFlag.Vulkan` flag
///  and `AInstance` must have been created with extensions returned by
///  SdlVulkanGetInstanceExtensions enabled.
///
///  If `AAllocator` is nil, Vulkan will use the system default allocator. This
///  argument is passed directly to Vulkan and isn't used by SDL itself.
/// </summary>
/// <param name="AWindow">The window to which to attach the Vulkan surface.</param>
/// <param name="AInstance">The Vulkan instance handle.</param>
/// <param name="AAllocator">(Optional) VkAllocationCallbacks struct, which lets
///  the app set the allocator that creates the surface. Can be nil.</param>
/// <returns>The newly created surface.</returns>
/// <exception name="ESdlError">Raised on failure.</exception>
/// <seealso cref="SdlVulkanGetInstanceExtensions"/>
/// <seealso cref="SdlVulkanDestroySurface"/>
function SdlVulkanCreateSurface(const AWindow: TSdlWindow;
  const AInstance: VkInstance;
  const AAllocator: PVkAllocationCallbacks = nil): VkSurfaceKHR; inline;

/// <summary>
///  Destroy the Vulkan rendering surface of a window.
///
///  This should be called before destroying the window, if
///  SdlVulkanCreateSurface was called after creating the window.
///
///  The `AInstance` must have been created with extensions returned by
///  SdlVulkanGetInstanceExtensions enabled and `ASurface` must have been
///  created successfully by an SdlVulkanCreateSurface call.
///
///  If `AAllocator` is nil, Vulkan will use the system default allocator. This
///  argument is passed directly to Vulkan and isn't used by SDL itself.
/// </summary>
/// <param name="AInstance">The Vulkan instance handle.</param>
/// <param name="ASurface">The vkSurfaceKHR handle to destroy.</param>
/// <param name="AAllocator">(Optional) VkAllocationCallbacks struct, which lets
///  the app set the allocator that destroys the surface. Can be nil.</param>
/// <seealso cref="SdlVulkanGetInstanceExtensions"/>
/// <seealso cref="SdlVulkanCreateSurface"/>
procedure SdlVulkanDestroySurface(const AInstance: VkInstance;
  const ASurface: VkSurfaceKHR; const AAllocator: PVkAllocationCallbacks = nil); inline;

/// <summary>
///  Query support for presentation via a given physical device and queue
///  family.
///
///  The `AInstance` must have been created with extensions returned by
///  SdlVulkanGetInstanceExtensions enabled.
/// </summary>
/// <param name="AInstance">The Vulkan instance handle.</param>
/// <param name="APhysicalDevice">A valid Vulkan physical device handle.</param>
/// <param name="AQueueFamilyIndex">A valid queue family index for the given
///  physical device.</param>
/// <returns>True if supported, False if unsupported or an error occurred.</returns>
/// <seealso cref="SdlVulkanGetInstanceExtensions"/>
function SdlVulkanGetPresentationSupport(const AInstance: VkInstance;
  const APhysicalDevice: VkPhysicalDevice; const AQueueFamilyIndex: Integer): Boolean; inline;
{$ENDREGION 'Vulkan Support'}

{$REGION 'Camera Support'}
/// <summary>
///  Video capture for the SDL library.
///
///  This API lets apps read input from video sources, like webcams. Camera
///  devices can be enumerated, queried, and opened. Once opened, it will
///  provide TSdlSurface objects as new frames of video come in. These surfaces
///  can be uploaded to an TSdlTexture or processed as pixels in memory.
///
///  Several platforms will alert the user if an app tries to access a camera,
///  and some will present a UI asking the user if your application should be
///  allowed to obtain images at all, which they can deny. A successfully opened
///  camera will not provide images until permission is granted. Applications,
///  after opening a camera device, can see if they were granted access by
///  either polling with the TSdlCamera.PermissionState property, or waiting
///  for an TSdlEventKind.CameraDeviceApproved or TSdlEventKind.CameraDeviceDenied
///  event. Platforms that don't have any user approval process will report
///  approval immediately.
///
///  Note that SDL cameras only provide video as individual frames; they will
///  not provide full-motion video encoded in a movie file format, although an
///  app is free to encode the acquired frames into any format it likes. It also
///  does not provide audio from the camera hardware through this API; not only
///  do many webcams not have microphones at all, many people--from streamers to
///  people on Zoom calls--will want to use a separate microphone regardless of
///  the camera. In any case, recorded audio will be available through SDL's
///  audio API no matter what hardware provides the microphone.
///
///  ## Camera gotchas
///
///  Consumer-level camera hardware tends to take a little while to warm up,
///  once the device has been opened. Generally most camera apps have some sort
///  of UI to take a picture (a button to snap a pic while a preview is showing,
///  some sort of multi-second countdown for the user to pose, like a photo
///  booth), which puts control in the users' hands, or they are intended to
///  stay on for long times (Pokemon Go, etc).
///
///  It's not uncommon that a newly-opened camera will provide a couple of
///  completely black frames, maybe followed by some under-exposed images. If
///  taking a single frame automatically, or recording video from a camera's
///  input without the user initiating it from a preview, it could be wise to
///  drop the first several frames (if not the first several _seconds_ worth of
///  frames!) before using images from a camera.
/// </summary>

type
  /// <summary>
  ///  The details of an output format for a camera device.
  ///
  ///  Cameras often support multiple formats; each one will be encapsulated in
  ///  this struct.
  /// </summary>
  /// <seealso cref="TSdlCameraID.SupportedFormats"/>
  /// <seealso cref="TSdlCamera.Format"/>
  TSdlCameraSpec = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PSDL_CameraSpec;
    function GetFormat: TSdlPixelFormat; inline;
    function GetColorspace: TSdlColorspace; inline;
    function GetWidth: Integer; inline;
    function GetHeight: Integer; inline;
    function GetFrameRateNumerator: Integer; inline;
    function GetFrameRateDenominator: Integer; inline;
    function GetFrameRate: Double; inline;
    function GetFrameDurationMs: Double; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Frame format
    /// </summary>
    property Format: TSdlPixelFormat read GetFormat;

    /// <summary>
    ///  Frame colorspace
    /// </summary>
    property Colorspace: TSdlColorspace read GetColorspace;

    /// <summary>
    ///  Frame width
    /// </summary>
    property Width: Integer read GetWidth;

    /// <summary>
    ///  Frame height
    /// </summary>
    property Height: Integer read GetHeight;

    /// <summary>
    ///  Frame rate numerator.
    ///  ((Num / Denom) = FPS, (Denom / Num) = duration in seconds)
    /// </summary>
    property FrameRateNumerator: Integer read GetFrameRateNumerator;

    /// <summary>
    ///  Frame rate demoninator.
    ///  ((Num / Denom) = FPS, (Denom / Num) = duration in seconds)
    /// </summary>
    property FrameRateDenominator: Integer read GetFrameRateDenominator;

    /// <summary>
    ///  Frame rate (frames per second)
    /// </summary>
    property FrameRate: Double read GetFrameRate;

    /// <summary>
    ///  Frame duration in Ms
    /// </summary>
    property FrameDurationMs: Double read GetFrameDurationMs;
  end;

type
  /// <summary>
  ///  The position of camera in relation to system device.
  /// </summary>
  /// <seealso cref="TSdlCameraID.Position"/>
  TSdlCameraPosition = (
    Unknown     = SDL_CAMERA_POSITION_UNKNOWN,
    FrontFacing = SDL_CAMERA_POSITION_FRONT_FACING,
    BackFacing  = SDL_CAMERA_POSITION_BACK_FACING);

type
  /// <summary>
  ///  This is a unique ID for a camera device for the time it is connected to the
  ///  system, and is never reused for the lifetime of the application.
  ///
  ///  If the device is disconnected and reconnected, it will get a new ID.
  ///
  ///  The value 0 is an invalid ID.
  /// </summary>
  /// <seealso cref="TSdlCameraID.Cameras"/>
  TSdlCameraID = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_CameraID;
    function GetName: String; inline;
    function GetPosition: TSdlCameraPosition; inline;
    function GetSupportedFormats: TArray<TSdlCameraSpec>;
    class function GetCameras: TArray<TSdlCameraID>; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlCameraID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCameraID.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlCameraID): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlCameraID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCameraID.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlCameraID): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlCameraID; inline; static;
  public
    /// <summary>
    ///  The human-readable device name for the camera.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Cameras"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  The position of the camera in relation to the system.
    ///
    ///  Most platforms will report Unknown, but mobile devices, like phones, can
    ///  often make a distinction between cameras on the front of the device (that
    ///  points towards the user, for taking "selfies") and cameras on the back (for
    ///  filming in the direction the user is facing).
    /// </summary>
    /// <seealso cref="Cameras"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Position: TSdlCameraPosition read GetPosition;

    /// <summary>
    ///  The list of native formats/sizes the camera supports.
    ///
    ///  This returns a list of all formats and frame sizes that a specific camera
    ///  can offer. This is useful if your app can accept a variety of image formats
    ///  and sizes and so want to find the optimal spec that doesn't require
    ///  conversion.
    ///
    ///  This property isn't strictly required; if you call TSdlCamera.Open with a
    ///  nil spec, SDL will choose a native format for you, and if you instead
    ///  specify a desired format, it will transparently convert to the requested
    ///  format on your behalf.
    ///
    ///  Note that it's legal for a camera to supply an empty list.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Cameras"/>
    /// <seealso cref="TSdlCamera.Open"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property SupportedFormats: TArray<TSdlCameraSpec> read GetSupportedFormats;

    /// <summary>
    ///  A list of currently connected camera devices.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlCamera.Open"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Cameras: TArray<TSdlCameraID> read GetCameras;
  end;

type
  /// <summary>
  ///  Permission state of a camera.
  /// </summary>
  TSdlCameraPermissionState = (
    /// <summary>
    ///  User denied access to the camera.
    /// </summary>
    Denied   = -1,

    /// <summary>
    ///  No decision has been made yet.
    /// </summary>
    Waiting  = 0,

    /// <summary>
    ///  User approved access to the camera.
    /// </summary>
    Approved = 1);

type
  /// <summary>
  ///  SDL Camera.
  /// </summary>
  TSdlCamera = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Camera;
    function GetID: TSdlCameraID; inline;
    function GetPermissionState: TSdlCameraPermissionState; inline;
    function GetFormat: TSdlCameraSpec; inline;
    function GetProperties: TSdlProperties; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlCamera; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCamera.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlCamera): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlCamera; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCamera.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlCamera): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlCamera; inline; static;
  public
    /// <summary>
    ///  Open a video recording device (a "camera") using its preferred format.
    ///
    ///  This version will choose a format for you (and you can use TSdlSurface's
    ///  conversion/scaling functions directly if necessary).
    ///
    ///  You can use Format to get the actual data format. You can see the exact
    ///  specs a device can support without conversion with
    ///  TSdlCameraID.SupportedFormats.
    ///
    ///  SDL will not attempt to emulate framerate; it will try to set the hardware
    ///  to the rate closest to the requested speed, but it won't attempt to limit
    ///  or duplicate frames artificially; use Format to see the actual framerate
    ///  of the opened the device, and check your timestamps if this is crucial to
    ///  your app!
    ///
    ///  Note that the camera is not usable until the user approves its use! On some
    ///  platforms, the operating system will prompt the user to permit access to
    ///  the camera, and they can choose Yes or No at that point. Until they do, the
    ///  camera will not be usable. The app should either wait for an
    ///  TSdlEventKind.CameraDeviceApproved (or TSdlEventKind.CameraDeviceDenied)
    ///  event, or poll PermissionState occasionally until it returns `Approved` or
    ///  `Denied`. On platforms that don't require explicit user approval (and perhaps
    ///  in places where the user previously permitted access), the approval event
    ///  might come immediately, but it might come seconds, minutes, or hours later!
    /// </summary>
    /// <param name="AInstanceID">The camera device instance ID.</param>
    /// <returns>The opened camera.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlCameraID.Cameras"/>
    /// <seealso cref="Format"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function Open(const AInstanceID: TSdlCameraID): TSdlCamera; overload; inline; static;

    /// <summary>
    ///  Open a video recording device (a "camera").
    ///
    ///  You can open the device with any reasonable spec, and if the hardware can't
    ///  directly support it, it will convert data seamlessly to the requested
    ///  format. This might incur overhead, including scaling of image data.
    ///
    ///  You can see the exact specs a device can support without conversion with
    ///  TSdlCameraID.SupportedFormats.
    ///
    ///  SDL will not attempt to emulate framerate; it will try to set the hardware
    ///  to the rate closest to the requested speed, but it won't attempt to limit
    ///  or duplicate frames artificially; use Format to see the actual framerate
    ///  of the opened the device, and check your timestamps if this is crucial to
    ///  your app!
    ///
    ///  Note that the camera is not usable until the user approves its use! On some
    ///  platforms, the operating system will prompt the user to permit access to
    ///  the camera, and they can choose Yes or No at that point. Until they do, the
    ///  camera will not be usable. The app should either wait for an
    ///  TSdlEventKind.CameraDeviceApproved (or TSdlEventKind.CameraDeviceDenied)
    ///  event, or poll PermissionState occasionally until it returns `Approved` or
    ///  `Denied`. On platforms that don't require explicit user approval (and perhaps
    ///  in places where the user previously permitted access), the approval event
    ///  might come immediately, but it might come seconds, minutes, or hours later!
    /// </summary>
    /// <param name="AInstanceID">The camera device instance ID.</param>
    /// <param name="ASpec">The desired format for data the device will provide.</param>
    /// <returns>The opened camera.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlCameraID.Cameras"/>
    /// <seealso cref="Format"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function Open(const AInstanceID: TSdlCameraID;
      const ASpec: TSdlCameraSpec): TSdlCamera; overload; inline; static;

    /// <summary>
    ///  Shut down camera processing and close the camera device.
    /// </summary>
    /// <seealso cref="Open"/>
    /// <remarks>
    ///  It is safe to call this method from any thread, but no thread may
    ///  reference the device once this method is called.
    /// </remarks>
    procedure Close; inline;

    /// <summary>
    ///  Acquire a frame.
    ///
    ///  The frame is a memory pointer to the image data, whose size and format are
    ///  given by the spec requested when opening the device.
    ///
    ///  This is a non blocking API. If there is a frame available, a non-nil
    ///  surface is returned, and ATimestampNS will be filled with a non-zero value.
    ///
    ///  Note that an error case can also return nil, but a nil by itself is
    ///  normal and just signifies that a new frame is not yet available. Note that
    ///  even if a camera device fails outright (a USB camera is unplugged while in
    ///  use, etc), SDL will send an event separately to notify the app, but
    ///  continue to provide blank frames at ongoing intervals until Close is
    ///  called, so real failure here is almost always an out of memory condition.
    ///
    ///  After use, the frame should be released with ReleaseFrame. If
    ///  you don't do this, the system may stop providing more video!
    ///
    ///  Do not call Free on the returned surface! It must be given back to the
    ///  camera subsystem with ReleaseFrame!
    ///
    ///  If the system is waiting for the user to approve access to the camera, as
    ///  some platforms require, this will return nil (no frames available); you
    ///  should either wait for an TSdlEventKind.CameraDeviceApproved (or
    ///  TSdlEventKind.CameraDeviceDenied) event, or poll PermissionState
    ///  occasionally.
    /// </summary>
    /// <param name="ATimestampNS">Is set to the frame's timestamp.</param>
    /// <returns>A new frame of video on success, nil if none is currently available.</returns>
    /// <seealso cref="ReleaseFrame"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    function AcquireFrame(out ATimestampNS: UInt64): TSdlSurface; inline;

    /// <summary>
    ///  Release a frame of video acquired from the camera.
    ///
    ///  Let the back-end re-use the internal buffer for camera.
    ///
    ///  This method _must_ be called only on surface objects returned by
    ///  AcquireFrame. This method should be called as quickly as possible after
    ///  acquisition, as SDL keeps a small FIFO queue of surfaces for video
    ///  frames; if surfaces aren't released in a timely manner, SDL may drop
    ///  upcoming video frames from the camera.
    ///
    ///  If the app needs to keep the surface for a significant time, they should
    ///  make a copy of it and release the original.
    ///
    ///  The app should not use the surface again after calling this function;
    ///  assume the surface is freed and the pointer is invalid.
    /// </summary>
    /// <param name="AFrame">The video frame surface to release.</param>
    /// <seealso cref="AcquireFrame"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    procedure ReleaseFrame(const AFrame: TSdlSurface); inline;

    /// <summary>
    ///  The instance ID of this opened camera.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Open"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property ID: TSdlCameraID read GetID;

    /// <summary>
    ///  Whether camera access has been approved by the user.
    ///
    ///  Cameras will not function between when the device is opened by the app and
    ///  when the user permits access to the hardware. On some platforms, this
    ///  presents as a popup dialog where the user has to explicitly approve access;
    ///  on others the approval might be implicit and not alert the user at all.
    ///
    ///  This property can be used to check the status of that approval. It will
    ///  return `Waiting` if still waiting for user response, `Approved` if the
    ///  camera is approved for use, and `Denied` if the user denied access.
    ///
    ///  Instead of polling with this property, you can wait for a
    ///  TSdlEventKind.CameraDeviceApproved (or TSdlEventKind.CameraDeviceDenied)
    ///  event in the standard SDL event loop, which is guaranteed to be sent
    ///  once when permission to use the camera is decided.
    ///
    ///  If a camera is declined, there's nothing to be done but call
    ///  Close to dispose of it.
    /// </summary>
    /// <seealso cref="Open"/>
    /// <seealso cref="Close"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property PermissionState: TSdlCameraPermissionState read GetPermissionState;

    /// <summary>
    ///  The spec that a camera is using when generating images.
    ///
    ///  Note that this might not be the native format of the hardware, as SDL might
    ///  be converting to this format behind the scenes.
    ///
    ///  If the system is waiting for the user to approve access to the camera, as
    ///  some platforms require, this will raise an error, but this isn't necessarily
    ///  a fatal error; you should either wait for an
    ///  TSdlEventKind.CameraDeviceApproved (or TSdlEventKind.CameraDeviceDenied)
    ///  event, or poll PermissionState occasionally.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Open"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Format: TSdlCameraSpec read GetFormat;

    /// <summary>
    ///  The properties associated with the opened camera.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    property Properties: TSdlProperties read GetProperties;
  end;

type
  /// <summary>
  ///  Camera driver.
  /// </summary>
  TSdlCameraDriver = record
  {$REGION 'Internal Declarations'}
  private
    FName: String;
    class function GetDriverCount: Integer; inline; static;
    class function GetDriver(const AIndex: Integer): TSdlCameraDriver; inline; static;
    class function GetCurrent: TSdlCameraDriver; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlCameraDriver; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCameraDriver.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlCameraDriver): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlCameraDriver; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCameraDriver.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlCameraDriver): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlCameraDriver; inline; static;
  public
    /// <summary>
    ///  The name of a built in camera driver.
    ///
    ///  The list of camera drivers is given in the order that they are normally
    ///  initialized by default; the drivers that seem more reasonable to choose
    ///  first (as far as the SDL developers believe) are earlier in the list.
    ///
    ///  The names of drivers are all simple, low-ASCII identifiers, like "v4l2",
    ///  "coremedia" or "android". These never have Unicode characters, and are not
    ///  meant to be proper names.
    /// </summary>
    property Name: String read FName;

    /// <summary>
    ///  The number of built-in camera drivers.
    ///
    ///  This property returns a hardcoded number. This never returns a negative
    ///  value; if there are no drivers compiled into this build of SDL, this
    ///  function returns zero. The presence of a driver in this list does not mean
    ///  it will function, it just means SDL is capable of interacting with that
    ///  interface. For example, a build of SDL might have v4l2 support, but if
    ///  there's no kernel support available, SDL's v4l2 driver would fail if used.
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
    ///  The built in camera drivers.
    ///
    ///  The list of camera drivers is given in the order that they are normally
    ///  initialized by default; the drivers that seem more reasonable to choose
    ///  first (as far as the SDL developers believe) are earlier in the list.
    /// </summary>
    /// <param name="AIndex">The index of the camera driver;
    ///  the value ranges from 0 to DriverCount - 1.</param>
    /// <seealso cref="DriverCount"/>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Drivers[const AIndex: Integer]: TSdlCameraDriver read GetDriver;

    /// <summary>
    ///  The current camera driver, or nil if no driver has been initialized..
    /// </summary>
    /// <remarks>
    ///  It is safe to use this property from any thread
    /// </remarks>
    class property Current: TSdlCameraDriver read GetCurrent;
  end;

{$ENDREGION 'Camera Support'}

implementation

const
  EGL_NONE = $3038;

{ TSdlPoint }

function SdlPoint(const AX, AY: Integer): TSdlPoint; overload; inline;
begin
  Result.Init(AX, AY);
end;

function SdlPoint(const APoint: TPoint): TSdlPoint; overload; inline;
begin
  Result.Init(APoint);
end;

constructor TSdlPoint.Create(const APoint: TPoint);
begin
  Init(APoint);
end;

constructor TSdlPoint.Create(const AX, AY: Integer);
begin
  Init(AX, AY);
end;

procedure TSdlPoint.Init(const APoint: TPoint);
begin
  Self := TSdlPoint(APoint);
end;

procedure TSdlPoint.Init(const AX, AY: Integer);
begin
  X := AX;
  Y := AY;
end;

{ TSdlPointF }

function SdlPointF(const AX, AY: Single): TSdlPointF; overload; inline;
begin
  Result.Init(AX, AY);
end;

function SdlPointF(const APoint: TSdlPoint): TSdlPointF; overload; inline;
begin
  Result.Init(APoint);
end;

function SdlPointF(const APoint: TPoint): TSdlPointF; overload; inline;
begin
  Result.Init(APoint);
end;

function SdlPointF(const APoint: TPointF): TSdlPointF; overload; inline;
begin
  Result.Init(APoint);
end;

constructor TSdlPointF.Create(const APoint: TSdlPoint);
begin
  Init(APoint);
end;

constructor TSdlPointF.Create(const APoint: TPoint);
begin
  Init(APoint);
end;

constructor TSdlPointF.Create(const APoint: TPointF);
begin
  Init(APoint);
end;

constructor TSdlPointF.Create(const AX, AY: Single);
begin
  Init(AX, AY);
end;

procedure TSdlPointF.Init(const APoint: TSdlPoint);
begin
  X := APoint.X;
  Y := APoint.Y;
end;

procedure TSdlPointF.Init(const APoint: TPoint);
begin
  X := APoint.X;
  Y := APoint.Y;
end;

procedure TSdlPointF.Init(const APoint: TPointF);
begin
  Self := TSdlPointF(APoint);
end;

procedure TSdlPointF.Init(const AX, AY: Single);
begin
  X := AX;
  Y := AY;
end;

{ TSdlSize }

function SdlSize(const AW, AH: Integer): TSdlSize;
begin
  Result.Init(AW, AH);
end;

constructor TSdlSize.Create(const AW, AH: Integer);
begin
  Init(AW, AH);
end;

procedure TSdlSize.Init(const AW, AH: Integer);
begin
  W := AW;
  H := AH;
end;

{ TSdlSizeF }

function SdlSizeF(const AW, AH: Single): TSdlSizeF;
begin
  Result.Init(AW, AH);
end;

function SdlSizeF(const ASize: TSdlSize): TSdlSizeF;
begin
  Result.Init(ASize);
end;

constructor TSdlSizeF.Create(const AW, AH: Single);
begin
  Init(AW, AH);
end;

constructor TSdlSizeF.Create(const ASize: TSdlSize);
begin
  Init(ASize);
end;

procedure TSdlSizeF.Init(const AW, AH: Single);
begin
  W := AW;
  H := AH;
end;

procedure TSdlSizeF.Init(const ASize: TSdlSize);
begin
  W := ASize.W;
  H := ASize.H;
end;

{ TSdlRect }

function SdlRect(const AX, AY, AW, AH: Integer): TSdlRect; overload; inline;
begin
  Result.Init(AX, AY, AW, AH);
end;

function SdlRect(const ARect: TRect): TSdlRect; overload; inline;
begin
  Result.Init(ARect);
end;

function TSdlRect.ContainsPoint(const AP: TSdlPoint): Boolean;
begin
  Result := SDL_PointInRect(SDL_Point(AP), SDL_Rect(Self));
end;

constructor TSdlRect.Create(const ARect: TRect);
begin
  Init(ARect);
end;

class operator TSdlRect.Equal(const ALeft, ARight: TSdlRect): Boolean;
begin
  Result := SDL_RectsEqual(SDL_Rect(ALeft), SDL_Rect(ARight));
end;

function TSdlRect.GetIsEmpty: Boolean;
begin
  Result := SDL_RectEmpty(SDL_Rect(Self));
end;

constructor TSdlRect.Create(const AX, AY, AW, AH: Integer);
begin
  Init(AX, AY, AW, AH);
end;

procedure TSdlRect.Init(const ARect: TRect);
begin
  X := ARect.Left;
  Y := ARect.Top;
  W := ARect.Width;
  H := ARect.Height;
end;

function TSdlRect.InitFromEnclosingPoints(const APoints: array of TSdlPoint;
  const AClip: PSdlRect): Boolean;
begin
  Result := SDL_GetRectEnclosingPoints(@APoints, Length(APoints),
    Pointer(AClip), @Self);
end;

function TSdlRect.InitFromEnclosingPoints(const APoints: TArray<TSdlPoint>;
  const AClip: PSdlRect): Boolean;
begin
  Result := SDL_GetRectEnclosingPoints(Pointer(APoints), Length(APoints),
    Pointer(AClip), @Self);
end;

function TSdlRect.Intersection(const AOther: TSdlRect;
  out AIntersection: TSdlRect): Boolean;
begin
  Result := SDL_GetRectIntersection(@Self, @AOther, @AIntersection);
end;

function TSdlRect.Intersects(const AOther: TSdlRect): Boolean;
begin
  Result := SDL_HasRectIntersection(@Self, @AOther);
end;

function TSdlRect.LineIntersection(var AP1, AP2: TSdlPoint): Boolean;
begin
  Result := SDL_GetRectAndLineIntersection(@Self, @AP1.X, @AP1.Y, @AP2.X, @AP2.Y);
end;

function TSdlRect.LineIntersection(var AX1, AY1, AX2, AY2: Integer): Boolean;
begin
  Result := SDL_GetRectAndLineIntersection(@Self, @AX1, @AY1, @AX2, @AY2);
end;

class operator TSdlRect.NotEqual(const ALeft, ARight: TSdlRect): Boolean;
begin
  Result := (not SDL_RectsEqual(SDL_Rect(ALeft), SDL_Rect(ARight)));
end;

procedure TSdlRect.Union(const AOther: TSdlRect; out AUnion: TSdlRect);
begin
  SDL_GetRectUnion(@Self, @AOther, @AUnion);
end;

procedure TSdlRect.Init(const AX, AY, AW, AH: Integer);
begin
  X := AX;
  Y := AY;
  W := AW;
  H := AH;
end;

{ TSdlRectF }

function SdlRectF(const AX, AY, AW, AH: Single): TSdlRectF; overload; inline;
begin
  Result.Init(AX, AY, AW, AH);
end;

function SdlRectF(const ARect: TSdlRect): TSdlRectF; overload; inline;
begin
  Result.Init(ARect);
end;

function SdlRectF(const ARect: TRect): TSdlRectF; overload; inline;
begin
  Result.Init(ARect);
end;

function SdlRectF(const ARect: TRectF): TSdlRectF; overload; inline;
begin
  Result.Init(ARect);
end;

constructor TSdlRectF.Create(const ARect: TSdlRect);
begin
  Init(ARect);
end;

constructor TSdlRectF.Create(const ARect: TRect);
begin
  Init(ARect);
end;

function TSdlRectF.ContainsPoint(const AP: TSdlPointF): Boolean;
begin
  Result := SDL_PointInRectFloat(SDL_FPoint(AP), SDL_FRect(Self));
end;

constructor TSdlRectF.Create(const ARect: TRectF);
begin
  Init(ARect);
end;

class operator TSdlRectF.Equal(const ALeft, ARight: TSdlRectF): Boolean;
begin
  Result := SDL_RectsEqualFloat(SDL_FRect(ALeft), SDL_FRect(ARight));
end;

function TSdlRectF.Equals(const AOther: TSdlRectF;
  const AEpsilon: Single): Boolean;
begin
  Result := SDL_RectsEqualEpsilon(SDL_FRect(Self), SDL_FRect(AOther), AEpsilon);
end;

function TSdlRectF.GetIsEmpty: Boolean;
begin
  Result := SDL_RectEmptyFloat(SDL_FRect(Self));
end;

constructor TSdlRectF.Create(const AX, AY, AW, AH: Single);
begin
  Init(AX, AY, AW, AH);
end;

procedure TSdlRectF.Init(const ARect: TSdlRect);
begin
  SDL_RectToFRect(SDL_Rect(ARect), SDL_FRect(Self));
end;

procedure TSdlRectF.Init(const ARect: TRect);
begin
  X := ARect.Left;
  Y := ARect.Top;
  W := ARect.Width;
  H := ARect.Height;
end;

procedure TSdlRectF.Init(const ARect: TRectF);
begin
  X := ARect.Left;
  Y := ARect.Top;
  W := ARect.Width;
  H := ARect.Height;
end;

function TSdlRectF.InitFromEnclosingPoints(const APoints: array of TSdlPointF;
  const AClip: PSdlRectF): Boolean;
begin
  Result := SDL_GetRectEnclosingPointsFloat(@APoints, Length(APoints),
    Pointer(AClip), @Self);
end;

function TSdlRectF.InitFromEnclosingPoints(const APoints: TArray<TSdlPointF>;
  const AClip: PSdlRectF): Boolean;
begin
  Result := SDL_GetRectEnclosingPointsFloat(Pointer(APoints), Length(APoints),
    Pointer(AClip), @Self);
end;

function TSdlRectF.Intersection(const AOther: TSdlRectF;
  out AIntersection: TSdlRectF): Boolean;
begin
  Result := SDL_GetRectIntersectionFloat(@Self, @AOther, @AIntersection);
end;

function TSdlRectF.Intersects(const AOther: TSdlRectF): Boolean;
begin
  Result := SDL_HasRectIntersectionFloat(@Self, @AOther);
end;

function TSdlRectF.LineIntersection(var AP1, AP2: TSdlPointF): Boolean;
begin
  Result := SDL_GetRectAndLineIntersectionFloat(@Self, @AP1.X, @AP1.Y, @AP2.X, @AP2.Y);
end;

function TSdlRectF.LineIntersection(var AX1, AY1, AX2, AY2: Single): Boolean;
begin
  Result := SDL_GetRectAndLineIntersectionFloat(@Self, @AX1, @AY1, @AX2, @AY2);
end;

class operator TSdlRectF.NotEqual(const ALeft, ARight: TSdlRectF): Boolean;
begin
  Result := (not SDL_RectsEqualFloat(SDL_FRect(ALeft), SDL_FRect(ARight)));
end;

procedure TSdlRectF.Union(const AOther: TSdlRectF; out AUnion: TSdlRectF);
begin
  SDL_GetRectUnionFloat(@Self, @AOther, @AUnion);
end;

procedure TSdlRectF.Init(const AX, AY, AW, AH: Single);
begin
  X := AX;
  Y := AY;
  W := AW;
  H := AH;
end;

{ TSdlColor }

function SdlColor(const AR, AG, AB, AA: Byte): TSdlColor;
begin
  Result.Init(AR, AG, AB, AA);
end;

constructor TSdlColor.Create(const AR, AG, AB, AA: Byte);
begin
  Init(AR, AG, AB, AA);
end;

procedure TSdlColor.Init(const AR, AG, AB, AA: Byte);
begin
  R := AR;
  G := AG;
  B := AB;
  A := AA;
end;

{ TSdlColorF }

function SdlColorF(const AR, AG, AB, AA: Single): TSdlColorF;
begin
  Result.Init(AR, AG, AB, AA);
end;

constructor TSdlColorF.Create(const AR, AG, AB, AA: Single);
begin
  Init(AR, AG, AB, AA);
end;

procedure TSdlColorF.Init(const AR, AG, AB, AA: Single);
begin
  R := AR;
  G := AG;
  B := AB;
  A := AA;
end;

{ TSdlPalette }

constructor TSdlPalette.Create(const ANumColors: Integer);
begin
  FHandle := SDL_CreatePalette(ANumColors);
  SdlCheck(FHandle);
end;

class operator TSdlPalette.Equal(const ALeft: TSdlPalette;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlPalette.Equal(const ALeft, ARight: TSdlPalette): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlPalette.Free;
begin
  SDL_DestroyPalette(FHandle);
  FHandle := nil;
end;

function TSdlPalette.GetColors: PSdlColor;
begin
  if Assigned(FHandle) then
    Result := Pointer(FHandle.colors)
  else
    Result := nil;
end;

function TSdlPalette.GetNumColors: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.ncolors
  else
    Result := 0;
end;

class operator TSdlPalette.Implicit(const AValue: Pointer): TSdlPalette;
begin
  Result.FHandle := AValue;
end;

class operator TSdlPalette.NotEqual(const ALeft, ARight: TSdlPalette): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlPalette.NotEqual(const ALeft: TSdlPalette;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

procedure TSdlPalette.SetColors(const AColors: array of TSdlColor;
  const AFirstColor, ANumColors: Integer);
begin
  var NumColors := ANumColors;
  if (NumColors = 0) then
    NumColors := Length(AColors);

  SdlCheck(SDL_SetPaletteColors(FHandle, @AColors, AFirstColor, NumColors));
end;

procedure TSdlPalette.SetColors(const AColors: TArray<TSdlColor>;
  const AFirstColor, ANumColors: Integer);
begin
  var NumColors := ANumColors;
  if (NumColors = 0) then
    NumColors := Length(AColors);

  SdlCheck(SDL_SetPaletteColors(FHandle, Pointer(AColors), AFirstColor, NumColors));
end;

{ TSdlPixelFormatDetails }

function TSdlPixelFormatDetails.GetFormat: TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(FHandle.format);
end;

procedure TSdlPixelFormatDetails.GetRgb(const APixel: Cardinal;
  const APalette: TSdlPalette; out AR, AG, AB: Byte);
begin
  SDL_GetRGB(APixel, @FHandle, APalette.FHandle, @AR, @AG, @AB);
end;

procedure TSdlPixelFormatDetails.GetRgb(const APixel: Cardinal; out AR, AG,
  AB: Byte);
begin
  SDL_GetRGB(APixel, @FHandle, nil, @AR, @AG, @AB);
end;

procedure TSdlPixelFormatDetails.GetRgba(const APixel: Cardinal;
  const APalette: TSdlPalette; out AR, AG, AB, AA: Byte);
begin
  SDL_GetRGBA(APixel, @FHandle, APalette.FHandle, @AR, @AG, @AB, @AA);
end;

procedure TSdlPixelFormatDetails.GetRgba(const APixel: Cardinal; out AR, AG, AB,
  AA: Byte);
begin
  SDL_GetRGBA(APixel, @FHandle, nil, @AR, @AG, @AB, @AA);
end;

function TSdlPixelFormatDetails.MapRgb(const APalette: TSdlPalette; const AR,
  AG, AB: Byte): Cardinal;
begin
  Result := SDL_MapRGB(@FHandle, APalette.FHandle, AR, AG, AB);
end;

function TSdlPixelFormatDetails.MapRgb(const AR, AG, AB: Byte): Cardinal;
begin
  Result := SDL_MapRGB(@FHandle, nil, AR, AG, AB);
end;

function TSdlPixelFormatDetails.MapRgba(const APalette: TSdlPalette; const AR,
  AG, AB, AA: Byte): Cardinal;
begin
  Result := SDL_MapRGBA(@FHandle, APalette.FHandle, AR, AG, AB, AA);
end;

function TSdlPixelFormatDetails.MapRgba(const AR, AG, AB, AA: Byte): Cardinal;
begin
  Result := SDL_MapRGBA(@FHandle, nil, AR, AG, AB, AA);
end;

{ _TSdlPixelFormatHelper }

class function _TSdlPixelFormatHelper.From(const AA, AB, AC,
  AD: Char): TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(SDL_DefinePixelFourCC(Ord(AA), Ord(AB), Ord(AC), Ord(AD)));
end;

class function _TSdlPixelFormatHelper.From(const AType: TSdlPixelType;
  const AOrder: TSdlBitmapOrder; const ALayout: TSdlPackedLayout; const ABits,
  ABytes: Integer): TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(SDL_DefinePixelFormat(Ord(AType), Ord(AOrder),
    Ord(ALayout), ABits, ABytes));
end;

class function _TSdlPixelFormatHelper.From(const AType: TSdlPixelType;
  const AOrder: TSdlPackedOrder; const ALayout: TSdlPackedLayout; const ABits,
  ABytes: Integer): TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(SDL_DefinePixelFormat(Ord(AType), Ord(AOrder),
    Ord(ALayout), ABits, ABytes));
end;

class function _TSdlPixelFormatHelper.From(const AType: TSdlPixelType;
  const AOrder: TSdlArrayOrder; const ALayout: TSdlPackedLayout; const ABits,
  ABytes: Integer): TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(SDL_DefinePixelFormat(Ord(AType), Ord(AOrder),
    Ord(ALayout), ABits, ABytes));
end;

class function _TSdlPixelFormatHelper.FromMasks(const ABpp: Integer;
  const ARMask, AGMask, ABMask, AAMask: Cardinal): TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(SDL_GetPixelFormatForMasks(ABpp, ARMask, AGMask,
    ABMask, AAMask));
end;

function _TSdlPixelFormatHelper.GetArrayOrder: TSdlArrayOrder;
begin
  if SDL_IsPixelFormatArray(SDL_PixelFormat(Self)) then
    Result := TSdlArrayOrder(SDL_GetPixelOrder(SDL_PixelFormat(Self)))
  else
    Result := TSdlArrayOrder.None;
end;

function _TSdlPixelFormatHelper.GetBitmapOrder: TSdlBitmapOrder;
begin
  if SDL_IsPixelFormatIndexed(SDL_PixelFormat(Self)) then
    Result := TSdlBitmapOrder(SDL_GetPixelOrder(SDL_PixelFormat(Self)))
  else
    Result := TSdlBitmapOrder.None;
end;

function _TSdlPixelFormatHelper.GetBitsPerPixel: Integer;
begin
  Result := SDL_GetBitsPerPixel(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetBytesPerPixel: Integer;
begin
  Result := SDL_GetBytesPerPixel(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetDetails: TSdlPixelFormatDetails;
begin
  var Details := SDL_GetPixelFormatDetails(SDL_PixelFormat(Self));
  if (SdlSucceeded(Details)) then
    Result.FHandle := Details^;
end;

function _TSdlPixelFormatHelper.GetHasAlpha: Boolean;
begin
  Result := SDL_IsPixelFormatAlpha(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetIs10Bit: Boolean;
begin
  Result := SDL_IsPixelFormat10Bit(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetIsArray: Boolean;
begin
  Result := SDL_IsPixelFormatArray(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetIsFloat: Boolean;
begin
  Result := SDL_IsPixelFormatFloat(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetIsFourCC: Boolean;
begin
  Result := SDL_IsPixelFormatFourCC(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetIsIndexed: Boolean;
begin
  Result := SDL_IsPixelFormatIndexed(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetIsPacked: Boolean;
begin
  Result := SDL_IsPixelFormatPacked(SDL_PixelFormat(Self));
end;

function _TSdlPixelFormatHelper.GetLayout: TSdlPackedLayout;
begin
  Result := TSdlPackedLayout(SDL_GetPixelLayout(SDL_PixelFormat(Self)));
end;

procedure _TSdlPixelFormatHelper.GetMasks(out ABpp: Integer; out ARMask, AGMask,
  ABMask, AAMask: Cardinal);
begin
  SdlCheck(SDL_GetMasksForPixelFormat(SDL_PixelFormat(Self), @ABpp, @ARMask,
    @AGMask, @ABMask, @AAMask));
end;

function _TSdlPixelFormatHelper.GetName: String;
begin
  Result := __ToString(SDL_GetPixelFormatName(SDL_PixelFormat(Self)));
end;

function _TSdlPixelFormatHelper.GetPackedOrder: TSdlPackedOrder;
begin
  if SDL_IsPixelFormatPacked(SDL_PixelFormat(Self)) then
    Result := TSdlPackedOrder(SDL_GetPixelOrder(SDL_PixelFormat(Self)))
  else
    Result := TSdlPackedOrder.None;
end;

function _TSdlPixelFormatHelper.GetPixelType: TSdlPixelType;
begin
  Result := TSdlPixelType(SDL_GetPixelType(SDL_PixelFormat(Self)));
end;

{ _TSdlColorspaceHelper }

class function _TSdlColorspaceHelper.From(const AType: TSdlColorType;
  const ARange: TSdlColorRange; const APrimaries: TSdlColorPrimaries;
  const ATransfer: TSdlTransferCharacteristics;
  const AMatrix: TSdlMatrixCoefficients;
  const AChroma: TSdlChromaLocation): TSdlColorspace;
begin
  Result := TSdlColorspace(SDL_DefineColorspace(Ord(AType), Ord(ARange),
    Ord(APrimaries), Ord(ATransfer), Ord(AMatrix), Ord(AChroma)));
end;

function _TSdlColorspaceHelper.GetChroma: TSdlChromaLocation;
begin
  Result := TSdlChromaLocation(SDL_GetColorspaceChroma(SDL_Colorspace(Self)));
end;

function _TSdlColorspaceHelper.GetColorType: TSdlColorType;
begin
  Result := TSdlColorType(SDL_GetColorspaceType(SDL_Colorspace(Self)));
end;

function _TSdlColorspaceHelper.GetHasFullRange: Boolean;
begin
  Result := SDL_IsColorspaceFullRange(SDL_Colorspace(Self));
end;

function _TSdlColorspaceHelper.GetHasLimitedRange: Boolean;
begin
  Result := SDL_IsColorspaceLimitedRange(SDL_Colorspace(Self));
end;

function _TSdlColorspaceHelper.GetIsMatrixBG709: Boolean;
begin
  Result := SDL_IsColorspaceMatrixBT709(SDL_Colorspace(Self));
end;

function _TSdlColorspaceHelper.GetIsMatrixBT2020Ncl: Boolean;
begin
  Result := SDL_IsColorspaceMatrixBT2020Ncl(SDL_Colorspace(Self));
end;

function _TSdlColorspaceHelper.GetIsMatrixBT601: Boolean;
begin
  Result := SDL_IsColorspaceMatrixBT601(SDL_Colorspace(Self));
end;

function _TSdlColorspaceHelper.GetMatrix: TSdlMatrixCoefficients;
begin
  Result := TSdlMatrixCoefficients(SDL_GetColorspaceMatrix(SDL_Colorspace(Self)));
end;

function _TSdlColorspaceHelper.GetPrimaries: TSdlColorPrimaries;
begin
  Result := TSdlColorPrimaries(SDL_GetColorspacePrimaries(SDL_Colorspace(Self)));
end;

function _TSdlColorspaceHelper.GetRange: TSdlColorRange;
begin
  Result := TSdlColorRange(SDL_GetColorspaceRange(SDL_Colorspace(Self)));
end;

function _TSdlColorspaceHelper.GetTransfer: TSdlTransferCharacteristics;
begin
  Result := TSdlTransferCharacteristics(SDL_GetColorspaceTransfer(SDL_Colorspace(Self)));
end;

{ _TSdlBlendModeHelper }

class function _TSdlBlendModeHelper.Compose(const ASrcColorFactor,
  ADstColorFactor: TSdlBlendFactor; const AColorOperation: TSdlBlendOperation;
  const ASrcAlphaFactor, ADstAlphaFactor: TSdlBlendFactor;
  const AAlphaOperation: TSdlBlendOperation): TSdlBlendMode;
begin
  Result := TSdlBlendMode(SDL_ComposeCustomBlendMode(Ord(ASrcColorFactor),
    Ord(ADstColorFactor), Ord(AColorOperation), Ord(ASrcAlphaFactor),
    Ord(ADstAlphaFactor), Ord(AAlphaOperation)));
end;

{ TSdlSurface }

procedure SdlConvert(const AWidth, AHeight: Integer; const ASrcFormat: TSdlPixelFormat;
  const ASrc: Pointer; const ASrcPitch: Integer; const ADstFormat: TSdlPixelFormat;
  const ADst: Pointer; const ADstPitch: Integer);
begin
  SdlCheck(SDL_ConvertPixels(AWidth, AHeight, Ord(ASrcFormat), ASrc, ASrcPitch,
    Ord(ADstFormat), ADst, ADstPitch));
end;

procedure SdlConvert(const AWidth, AHeight: Integer; const ASrcFormat: TSdlPixelFormat;
  const ASrcColorspace: TSdlColorspace; const ASrc: Pointer;
  const ASrcPitch: Integer; const ADstFormat: TSdlPixelFormat;
  const ADstColorspace: TSdlColorspace; const ADst: Pointer;
  const ADstPitch: Integer);
begin
  SdlCheck(SDL_ConvertPixelsAndColorspace(AWidth, AHeight, Ord(ASrcFormat),
    Ord(ASrcColorspace), 0, ASrc, ASrcPitch, Ord(ADstFormat),
    Ord(ADstColorspace), 0, ADst, ADstPitch));
end;

procedure SdlConvert(const AWidth, AHeight: Integer; const ASrcFormat: TSdlPixelFormat;
  const ASrcColorspace: TSdlColorspace; const ASrcProperties: TSdlProperties;
  const ASrc: Pointer; const ASrcPitch: Integer; const ADstFormat: TSdlPixelFormat;
  const ADstColorspace: TSdlColorspace; const ADstProperties: TSdlProperties;
  const ADst: Pointer; const ADstPitch: Integer);
begin
  SdlCheck(SDL_ConvertPixelsAndColorspace(AWidth, AHeight, Ord(ASrcFormat),
    Ord(ASrcColorspace), SDL_PropertiesID(ASrcProperties), ASrc, ASrcPitch,
    Ord(ADstFormat), Ord(ADstColorspace), SDL_PropertiesID(ADstProperties), ADst,
    ADstPitch));
end;

procedure PremultiplyAlpha(const AWidth, AHeight: Integer;
  const ASrcFormat: TSdlPixelFormat; const ASrc: Pointer; const ASrcPitch: Integer;
  const ADstFormat: TSdlPixelFormat; const ADst: Pointer; const ADstPitch: Integer;
  const ALinear: Boolean);
begin
  SdlCheck(SDL_PremultiplyAlpha(AWidth, AHeight, Ord(ASrcFormat), ASrc, ASrcPitch,
    Ord(ADstFormat), ADst, ADstPitch, ALinear));
end;

constructor TSdlSurface.Create(const AWidth, AHeight: Integer;
  const AFormat: TSdlPixelFormat);
begin
  FHandle := SDL_CreateSurface(AWidth, AHeight, Ord(AFormat));
  SdlCheck(FHandle);
end;

procedure TSdlSurface.AddAlternateImage(const AImage: TSdlSurface);
begin
  SdlCheck(SDL_AddSurfaceAlternateImage(FHandle, AImage.FHandle));
end;

procedure TSdlSurface.Blit(const ASrcRect: PSdlRect; const ADst: TSdlSurface;
  const ADstRect: PSdlRect);
begin
  SdlCheck(SDL_BlitSurface(FHandle, Pointer(ASrcRect), ADst.FHandle, Pointer(ADstRect)));
end;

procedure TSdlSurface.Blit9Grid(const ASrcRect: PSdlRect; const ALeftWidth,
  ARightWidth, ATopHeight, ABottomHeight: Integer; const AScale: Single;
  const AScaleMode: TSdlScaleMode; const ADst: TSdlSurface;
  const ADstRect: PSdlRect);
begin
  SdlCheck(SDL_BlitSurface9Grid(FHandle, Pointer(ASrcRect), ALeftWidth, ARightWidth,
    ATopHeight, ABottomHeight, AScale, Ord(AScaleMode), ADst.FHandle,
    Pointer(ADstRect)));
end;

procedure TSdlSurface.BlitScaled(const ASrcRect: PSdlRect;
  const ADst: TSdlSurface; const ADstRect: PSdlRect;
  const AScaleMode: TSdlScaleMode);
begin
  SdlCheck(SDL_BlitSurfaceScaled(FHandle, Pointer(ASrcRect), ADst.FHandle,
    Pointer(ADstRect), Ord(AScaleMode)));
end;

procedure TSdlSurface.BlitScaledUnchecked(const ASrcRect: TSdlRect;
  const ADst: TSdlSurface; const ADstRect: TSdlRect;
  const AScaleMode: TSdlScaleMode);
begin
  SdlCheck(SDL_BlitSurfaceUncheckedScaled(FHandle, @ASrcRect, ADst.FHandle,
    @ADstRect, Ord(AScaleMode)));
end;

procedure TSdlSurface.BlitTiled(const ASrcRect: PSdlRect; const AScale: Single;
  const AScaleMode: TSdlScaleMode; const ADst: TSdlSurface;
  const ADstRect: PSdlRect);
begin
  SdlCheck(SDL_BlitSurfaceTiledWithScale(FHandle, Pointer(ASrcRect), AScale,
    Ord(AScaleMode), ADst.FHandle, Pointer(ADstRect)));
end;

procedure TSdlSurface.BlitTiled(const ASrcRect: PSdlRect;
  const ADst: TSdlSurface; const ADstRect: PSdlRect);
begin
  SdlCheck(SDL_BlitSurfaceTiled(FHandle, Pointer(ASrcRect), ADst.FHandle,
    Pointer(ADstRect)));
end;

procedure TSdlSurface.BlitUnchecked(const ASrcRect: TSdlRect;
  const ADst: TSdlSurface; const ADstRect: TSdlRect);
begin
  SdlCheck(SDL_BlitSurfaceUnchecked(FHandle, @ASrcRect, ADst.FHandle, @ADstRect));
end;

procedure TSdlSurface.Clear(const AColor: TSdlColorF);
begin
  SdlCheck(SDL_ClearSurface(FHandle, AColor.R, AColor.G, AColor.B, AColor.A));
end;

procedure TSdlSurface.Clear(const AR, AG, AB, AA: Single);
begin
  SdlCheck(SDL_ClearSurface(FHandle, AR, AG, AB, AA));
end;

function TSdlSurface.Convert(const AFormat: TSdlPixelFormat;
  const APalette: TSdlPalette; const AColorspace: TSdlColorspace;
  const AProps: TSdlProperties): TSdlSurface;
begin
  Result.FHandle := SDL_ConvertSurfaceAndColorspace(FHandle, Ord(AFormat),
    APalette.FHandle, Ord(AColorspace), SDL_PropertiesID(AProps));
  SdlCheck(Result.FHandle);
end;

function TSdlSurface.Convert(const AFormat: TSdlPixelFormat): TSdlSurface;
begin
  Result.FHandle := SDL_ConvertSurface(FHandle, Ord(AFormat));
  SdlCheck(Result.FHandle);
end;

function TSdlSurface.Convert(const AFormat: TSdlPixelFormat;
  const AColorspace: TSdlColorspace): TSdlSurface;
begin
  Result.FHandle := SDL_ConvertSurfaceAndColorspace(FHandle, Ord(AFormat),
    nil, Ord(AColorspace), 0);
  SdlCheck(Result.FHandle);
end;

constructor TSdlSurface.Create(const AWidth, AHeight: Integer;
  const AFormat: TSdlPixelFormat; const APixels: Pointer;
  const APitch: Integer);
begin
  FHandle := SDL_CreateSurfaceFrom(AWidth, AHeight, Ord(AFormat), APixels, APitch);
  SdlCheck(FHandle);
end;

function TSdlSurface.CreatePalette: TSdlPalette;
begin
  Result.FHandle := SDL_CreateSurfacePalette(FHandle);
  SdlCheck(Result.FHandle);
end;

procedure TSdlSurface.DisableClipping;
begin
  SDL_SetSurfaceClipRect(FHandle, nil);
end;

function TSdlSurface.Duplicate: TSdlSurface;
begin
  Result.FHandle := SDL_DuplicateSurface(FHandle);
  SdlCheck(Result.FHandle);
end;

class operator TSdlSurface.Equal(const ALeft, ARight: TSdlSurface): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlSurface.Equal(const ALeft: TSdlSurface;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

procedure TSdlSurface.Fill(const AColor: Cardinal);
begin
  SdlCheck(SDL_FillSurfaceRect(FHandle, nil, AColor));
end;

procedure TSdlSurface.FillRect(const ARect: TSdlRect; const AColor: Cardinal);
begin
  SdlCheck(SDL_FillSurfaceRect(FHandle, @ARect, AColor));
end;

procedure TSdlSurface.FillRects(const ARects: array of TSdlRect;
  const AColor: Cardinal);
begin
  SdlCheck(SDL_FillSurfaceRects(FHandle, @ARects, Length(ARects), AColor));
end;

procedure TSdlSurface.FillRects(const ARects: TArray<TSdlRect>;
  const AColor: Cardinal);
begin
  SdlCheck(SDL_FillSurfaceRects(FHandle, Pointer(ARects), Length(ARects), AColor));
end;

procedure TSdlSurface.Flip(const AFlip: TSdlFlipMode);
begin
  SdlCheck(SDL_FlipSurface(FHandle, Ord(AFlip) + 1));
end;

procedure TSdlSurface.Free;
begin
  SDL_DestroySurface(FHandle);
end;

function TSdlSurface.GetAlphaMod: Byte;
begin
  SdlCheck(SDL_GetSurfaceAlphaMod(FHandle, @Result));
end;

function TSdlSurface.GetBlendMode: TSdlBlendMode;
begin
  SdlCheck(SDL_GetSurfaceBlendMode(FHandle, @Result));
end;

function TSdlSurface.GetClipRect: TSdlRect;
begin
  SdlCheck(SDL_GetSurfaceClipRect(FHandle, @Result));
end;

function TSdlSurface.GetColorKey: Cardinal;
begin
  if (SDL_SurfaceHasColorKey(FHandle)) then
    SdlCheck(SDL_GetSurfaceColorKey(FHandle, @Result))
  else
    Result := SDL_NO_COLOR_KEY;
end;

function TSdlSurface.GetColorMod: TSdlColor;
begin
  SdlCheck(SDL_GetSurfaceColorMod(FHandle, @Result.R, @Result.G, @Result.B));
  Result.A := 255;
end;

function TSdlSurface.GetColorspace: TSdlColorspace;
begin
  Result := TSdlColorspace(SDL_GetSurfaceColorspace(FHandle));
end;

function TSdlSurface.GetFlags: TSdlSurfaceFlags;
begin
  if (FHandle = nil) then
    Result := []
  else
    Byte(Result) := FHandle.flags;
end;

function TSdlSurface.GetFormat: TSdlPixelFormat;
begin
  if (FHandle = nil) then
    Result := TSdlPixelFormat.Unknown
  else
    Result := TSdlPixelFormat(FHandle.format);
end;

function TSdlSurface.GetH: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := FHandle.h;
end;

function TSdlSurface.GetHasAlternateImages: Boolean;
begin
  Result := SDL_SurfaceHasAlternateImages(FHandle);
end;

function TSdlSurface.GetHasColorKey: Boolean;
begin
  Result := SDL_SurfaceHasColorKey(FHandle);
end;

function TSdlSurface.GetImages: TArray<TSdlSurface>;
begin
  var Count := 0;
  var Surfaces := SDL_GetSurfaceImages(FHandle, @Count);
  if (SdlSucceeded(Surfaces)) then
  try
    SetLength(Result, Count);
    Move(Surfaces^, Result[0], Count * SizeOf(PSDL_Surface));
  finally
    SDL_free(Surfaces);
  end;
end;

function TSdlSurface.GetMustLock: Boolean;
begin
  if (FHandle = nil) then
    Result := False
  else
    Result := SDL_MustLock(FHandle^);
end;

function TSdlSurface.GetPalette: TSdlPalette;
begin
  Result.FHandle := SDL_GetSurfacePalette(FHandle);
end;

function TSdlSurface.GetPitch: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := FHandle.pitch;
end;

function TSdlSurface.GetPixel(const AX, AY: Integer): TSdlColor;
begin
  SdlCheck(SDL_ReadSurfacePixel(FHandle, AX, AY, @Result.R, @Result.G, @Result.B, @Result.A));
end;

function TSdlSurface.GetPixelFloat(const AX, AY: Integer): TSdlColorF;
begin
  SdlCheck(SDL_ReadSurfacePixelFloat(FHandle, AX, AY, @Result.R, @Result.G, @Result.B, @Result.A));
end;

function TSdlSurface.GetPixels: Pointer;
begin
  if (FHandle = nil) then
    Result := nil
  else
    Result := FHandle.pixels;
end;

function TSdlSurface.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetSurfaceProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

function TSdlSurface.GetUseRle: Boolean;
begin
  Result := SDL_SurfaceHasRLE(FHandle);
end;

function TSdlSurface.GetW: Integer;
begin
  if (FHandle = nil) then
    Result := 0
  else
    Result := FHandle.w;
end;

class operator TSdlSurface.Implicit(const AValue: Pointer): TSdlSurface;
begin
  Result.FHandle := AValue;
end;

constructor TSdlSurface.LoadBmp(const ASrc: TSdlIOStream;
  const ACloseIO: Boolean);
begin
  FHandle := SDL_LoadBMP_IO(THandle(ASrc), ACloseIO);
  SdlCheck(FHandle);
end;

constructor TSdlSurface.LoadBmp(const AFilename: String);
begin
  FHandle := SDL_LoadBMP(__ToUtf8(AFilename));
  SdlCheck(FHandle);
end;

procedure TSdlSurface.Lock;
begin
  SdlCheck(SDL_LockSurface(FHandle));
end;

function TSdlSurface.MapRgb(const AR, AG, AB: Byte): Cardinal;
begin
  Result := SDL_MapSurfaceRGB(FHandle, AR, AG, AB);
end;

function TSdlSurface.MapRgba(const AR, AG, AB, AA: Byte): Cardinal;
begin
  Result := SDL_MapSurfaceRGBA(FHandle, AR, AG, AB, AA);
end;

class operator TSdlSurface.NotEqual(const ALeft, ARight: TSdlSurface): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlSurface.NotEqual(const ALeft: TSdlSurface;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

procedure TSdlSurface.PremultiplyAlpha(const ALinear: Boolean);
begin
  SdlCheck(SDL_PremultiplySurfaceAlpha(FHandle, ALinear));
end;

procedure TSdlSurface.RemoveAlternateImages;
begin
  SDL_RemoveSurfaceAlternateImages(FHandle);
end;

procedure TSdlSurface.SaveBmp(const ADst: TSdlIOStream;
  const ACloseIO: Boolean);
begin
  SdlCheck(SDL_SaveBMP_IO(FHandle, THandle(ADst), ACloseIO));
end;

procedure TSdlSurface.SaveBmp(const AFilename: String);
begin
  SdlCheck(SDL_SaveBMP(FHandle, __ToUtf8(AFilename)));
end;

function TSdlSurface.Scale(const AWidth, AHeight: Integer;
  const AScaleMode: TSdlScaleMode): TSdlSurface;
begin
  Result.FHandle := SDL_ScaleSurface(FHandle, AWidth, AHeight, Ord(AScaleMode));
  SdlCheck(Result.FHandle);
end;

procedure TSdlSurface.SetAlphaMod(const AValue: Byte);
begin
  SdlCheck(SDL_SetSurfaceAlphaMod(FHandle, AValue));
end;

procedure TSdlSurface.SetBlendMode(const AValue: TSdlBlendMode);
begin
  SdlCheck(SDL_SetSurfaceBlendMode(FHandle, Ord(AValue)));
end;

procedure TSdlSurface.SetClipRect(const AValue: TSdlRect);
begin
  SDL_SetSurfaceClipRect(FHandle, @AValue);
end;

procedure TSdlSurface.SetColorKey(const AValue: Cardinal);
begin
  SdlCheck(SDL_SetSurfaceColorKey(FHandle, (AValue <> SDL_NO_COLOR_KEY), AValue));
end;

procedure TSdlSurface.SetColorMod(const AValue: TSdlColor);
begin
  SdlCheck(SDL_SetSurfaceColorMod(FHandle, AValue.R, AValue.G, AValue.B));
end;

procedure TSdlSurface.SetColorspace(const AValue: TSdlColorspace);
begin
  SdlCheck(SDL_SetSurfaceColorspace(FHandle, Ord(AValue)));
end;

procedure TSdlSurface.SetPalette(const AValue: TSdlPalette);
begin
  SdlCheck(SDL_SetSurfacePalette(FHandle, AValue.FHandle));
end;

procedure TSdlSurface.SetPixel(const AX, AY: Integer; const AValue: TSdlColor);
begin
  SdlCheck(SDL_WriteSurfacePixel(FHandle, AX, AY, AValue.R, AValue.G, AValue.B, AValue.A));
end;

procedure TSdlSurface.SetPixelFloat(const AX, AY: Integer;
  const AValue: TSdlColorF);
begin
  SdlCheck(SDL_WriteSurfacePixelFloat(FHandle, AX, AY, AValue.R, AValue.G, AValue.B, AValue.A));
end;

procedure TSdlSurface.SetPixels(const AValue: Pointer);
begin
  if (FHandle <> nil) then
    FHandle.pixels := AValue;
end;

procedure TSdlSurface.SetUseRle(const AValue: Boolean);
begin
  SdlCheck(SDL_SetSurfaceRLE(FHandle, AValue));
end;

procedure TSdlSurface.Stretch(const ASrcRect: TSdlRect; const ADst: TSdlSurface;
  const ADstRect: TSdlRect; const AScaleMode: TSdlScaleMode);
begin
  SdlCheck(SDL_StretchSurface(FHandle, @ASrcRect, ADst.FHandle,
    @ADstRect, Ord(AScaleMode)));
end;

procedure TSdlSurface.Unlock;
begin
  SDL_UnlockSurface(FHandle);
end;

{ _TSdlSystemThemeHelper }

class function _TSdlSystemThemeHelper.FromSystem: TSdlSystemTheme;
begin
  Result := TSdlSystemTheme(SDL_GetSystemTheme);
end;

{ TSdlScreenSaver }

class procedure TSdlScreenSaver.Disable;
begin
  SdlCheck(SDL_DisableScreenSaver);
end;

class procedure TSdlScreenSaver.Enable;
begin
  SdlCheck(SDL_EnableScreenSaver);
end;

class function TSdlScreenSaver.GetEnabled: Boolean;
begin
  Result := SDL_ScreenSaverEnabled;
end;

class procedure TSdlScreenSaver.SetEnabled(const AValue: Boolean);
begin
  var Res: Boolean;
  if (AValue) then
    Res := SDL_EnableScreenSaver
  else
    Res := SDL_DisableScreenSaver;

  SdlCheck(Res);
end;

{ TSdlDisplayMode }

function TSdlDisplayMode.GetFormat: TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(FHandle.format);
end;

{ _SdlWindowPosHelper }

class function _SdlWindowPosHelper.CreateCentered(
  const AID: TSdlDisplayID): TSdlWindowPos;
begin
  Result := SDL_WindowPosCenteredDisplay(AID);
end;

class function _SdlWindowPosHelper.CreateUndefined(
  const AID: TSdlDisplayID): TSdlWindowPos;
begin
  Result := SDL_WindowPosUndefinedDisplay(AID);
end;

function _SdlWindowPosHelper.IsCentered: Boolean;
begin
  Result := SDL_WindowPosIsCentered(Self);
end;

function _SdlWindowPosHelper.IsUndefined: Boolean;
begin
  Result := SDL_WindowPosIsUndefined(Self);
end;

{ TSdlVideoDriver }

class function TSdlVideoDriver.GetCount: Integer;
begin
  Result := SDL_GetNumVideoDrivers;
end;

class function TSdlVideoDriver.GetCurrent: String;
begin
  Result := __ToString(SDL_GetCurrentVideoDriver);
end;

class function TSdlVideoDriver.GetDriver(
  const AIndex: Integer): TSdlVideoDriver;
begin
  Result.FIndex := AIndex;
end;

function TSdlVideoDriver.GetName: String;
begin
  Result := __ToString(SDL_GetVideoDriver(FIndex));
end;

{ TSdlDisplay }

class function TSdlDisplay.ForPoint(const APoint: TSdlPoint): TSdlDisplay;
begin
  Result.FID := SDL_GetDisplayForPoint(@APoint);
  SdlCheck(Result.FID);
end;

class function TSdlDisplay.ForRect(const ARect: TSdlRect): TSdlDisplay;
begin
  Result.FID := SDL_GetDisplayForRect(@ARect);
  SdlCheck(Result.FID);
end;

function TSdlDisplay.GetBounds: TSdlRect;
begin
  SdlCheck(SDL_GetDisplayBounds(FID, @Result));
end;

function TSdlDisplay.GetClosestFullscreenMode(const AW, AH: Integer;
  const ARefreshRate: Single;
  const AIncludeHighDensityModes: Boolean): TSdlDisplayMode;
begin
  SdlCheck(SDL_GetClosestFullscreenDisplayMode(FID, AW, AH, ARefreshRate,
    AIncludeHighDensityModes, @Result));
end;

function TSdlDisplay.GetContentScale: Single;
begin
  Result := SDL_GetDisplayContentScale(FID);
  if (Result = 0) then
    __HandleError;
end;

class function TSdlDisplay.GetCount: Integer;
begin
  GetDisplaysIfNeeded;
  Result := Length(FDisplays);
end;

function TSdlDisplay.GetCurrentMode: TSdlDisplayMode;
begin
  var Mode := SDL_GetCurrentDisplayMode(FID);
  if (SdlSucceeded(Mode)) then
    Result.FHandle := Mode^;
end;

function TSdlDisplay.GetCurrentOrientation: TSdlDisplayOrientation;
begin
  Result := TSdlDisplayOrientation(SDL_GetCurrentDisplayOrientation(FID));
end;

function TSdlDisplay.GetDesktopMode: TSdlDisplayMode;
begin
  var Mode := SDL_GetDesktopDisplayMode(FID);
  if (SdlSucceeded(Mode)) then
    Result.FHandle := Mode^;
end;

class function TSdlDisplay.GetDisplay(const AIndex: Integer): TSdlDisplay;
begin
  GetDisplaysIfNeeded;
  Assert(Cardinal(AIndex) < Cardinal(Length(FDisplays)));
  if (Cardinal(AIndex) < Cardinal(Length(FDisplays))) then
    Result.FID := FDisplays[AIndex]
  else
    Result.FID := 0;
end;

class procedure TSdlDisplay.GetDisplaysIfNeeded;
begin
  if (FDisplays <> nil) then
    Exit;

  var Count := 0;
  var Displays := SDL_GetDisplays(@Count);
  if (SdlSucceeded(Displays)) then
  try
    SetLength(FDisplays, Count);
    Move(Displays^, FDisplays[0], Count * SizeOf(SDL_DisplayID));
  finally
    SDL_free(Displays)
  end;
end;

function TSdlDisplay.GetFullScreenModes: TArray<TSdlDisplayMode>;
begin
  var Count := 0;
  var Modes := SDL_GetFullscreenDisplayModes(FID, @Count);
  if (SdlSucceeded(Modes)) then
  try
    SetLength(Result, Count);
    var P := Modes;
    for var I := 0 to Count - 1 do
    begin
      Move(P^^, Result[I], SizeOf(TSdlDisplayMode));
      Inc(P);
    end;
  finally
    SDL_free(Modes);
  end;
end;

function TSdlDisplay.GetHdrEnabled: Boolean;
begin
  var Prop := SDL_GetDisplayProperties(FID);
  if (SdlSucceeded(Prop)) then
    Result := SDL_GetBooleanProperty(Prop, SDL_PROP_DISPLAY_HDR_ENABLED_BOOLEAN, False)
  else
    Result := False;
end;

function TSdlDisplay.GetName: String;
begin
  Result := __ToString(SDL_GetDisplayName(FID));
end;

function TSdlDisplay.GetNaturalOrientation: TSdlDisplayOrientation;
begin
  Result := TSdlDisplayOrientation(SDL_GetNaturalDisplayOrientation(FID));
end;

class function TSdlDisplay.GetPrimary: TSdlDisplay;
begin
  Result.FID := SDL_GetPrimaryDisplay;
  SdlCheck(Result.FID);
end;

function TSdlDisplay.GetUsableBounds: TSdlRect;
begin
  SdlCheck(SDL_GetDisplayUsableBounds(FID, @Result));
end;

{ TSdlWindow }

constructor TSdlWindow.Create(const ATitle: String; const AW, AH: Integer;
  const AFlags: TSdlWindowFlags);
begin
  FHandle := SDL_CreateWindow(__ToUtf8(ATitle), AW, AH, UInt64(AFlags));
  SdlCheck(FHandle);
end;

constructor TSdlWindow.Create(const AParent: TSdlWindow; const AOffsetX,
  AOffsetY, AW, AH: Integer; const AFlags: TSdlWindowFlags);
begin
  FHandle := SDL_CreatePopupWindow(AParent.FHandle, AOffsetX, AOffsetY, AW, AH, UInt64(AFlags));
  SdlCheck(FHandle);
end;

procedure TSdlWindow.ClearComposition;
begin
  SdlCheck(SDL_ClearComposition(FHandle));
end;

procedure TSdlWindow.ClearTextInputArea(const ACursor: Integer);
begin
  SdlCheck(SDL_SetTextInputArea(FHandle, nil, ACursor));
end;

constructor TSdlWindow.Create(const AProperties: TSdlProperties);
begin
  FHandle := SDL_CreateWindowWithProperties(SDL_PropertiesID(AProperties));
  SdlCheck(FHandle);
end;

class operator TSdlWindow.Equal(const ALeft, ARight: TSdlWindow): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlWindow.Equal(const ALeft: TSdlWindow;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlWindow.Flash(const AOperation: TSdlFlashOperation);
begin
  SdlCheck(SDL_FlashWindow(FHandle, Ord(AOperation)));
end;

procedure TSdlWindow.Free;
begin
  if Assigned(FHitTestInfo) then
    FHitTestInfo.Remove(FHandle);

  SDL_DestroyWindow(FHandle);
  FHandle := 0;
end;

procedure TSdlWindow.FreeSurface;
begin
  SdlCheck(SDL_DestroyWindowSurface(FHandle));
end;

class function TSdlWindow.FromID(const AId: TSdlWindowID): TSdlWindow;
begin
  Result.FHandle := SDL_GetWindowFromID(AId);
  SdlCheck(Result.FHandle);
end;

function TSdlWindow.GetAlwaysOnTop: Boolean;
begin
  Result := (TSdlWindowFlag.AlwaysOnTop in GetFlags);
end;

procedure TSdlWindow.GetAspectRatio(out AMinAspect, AMaxAspect: Single);
begin
  SdlCheck(SDL_GetWindowAspectRatio(FHandle, @AMinAspect, @AMaxAspect));
end;

function TSdlWindow.GetBordered: Boolean;
begin
  Result := not (TSdlWindowFlag.Borderless in GetFlags);
end;

procedure TSdlWindow.GetBordersSize(out ATop, ALeft, ABottom, ARight: Integer);
begin
  SdlCheck(SDL_GetWindowBordersSize(FHandle, @ATop, @ALeft, @ABottom, @ARight));
end;

function TSdlWindow.GetDisplay: TSdlDisplay;
begin
  Result.FID := SDL_GetDisplayForWindow(FHandle);
  SdlCheck(Result.FID);
end;

function TSdlWindow.GetDisplayScale: Single;
begin
  Result := SDL_GetWindowDisplayScale(FHandle);
  if (Result = 0) then
    __HandleError;
end;

function TSdlWindow.GetFlags: TSdlWindowFlags;
begin
  UInt64(Result) := SDL_GetWindowFlags(FHandle);
end;

function TSdlWindow.GetFocusable: Boolean;
begin
  Result := (not (TSdlWindowFlag.NotFocusable in GetFlags));
end;

function TSdlWindow.GetFullscreen: Boolean;
begin
  Result := (TSdlWindowFlag.Fullscreen in GetFlags);
end;

function TSdlWindow.GetFullscreenMode: PSdlDisplayMode;
begin
  Result := Pointer(SDL_GetWindowFullscreenMode(FHandle));
end;

class function TSdlWindow.GetGrabbedWindow: TSdlWindow;
begin
  Result.FHandle := SDL_GetGrabbedWindow;
end;

function TSdlWindow.GetHasSurface: Boolean;
begin
  Result := SDL_WindowHasSurface(FHandle);
end;

function TSdlWindow.GetIccProfile: TBytes;
begin
  var Size: NativeUInt := 0;
  var Data := SDL_GetWindowICCProfile(FHandle, @Size);
  if (SdlSucceeded(Data)) then
  try
    SetLength(Result, Size);
    Move(Data^, Result[0], Size);
  finally
    SDL_free(Data);
  end;
end;

function TSdlWindow.GetID: TSdlWindowID;
begin
  Result := SDL_GetWindowID(FHandle);
  SdlCheck(Result);
end;

function TSdlWindow.GetIsRelativeMouseMode: Boolean;
begin
  Result := SDL_GetWindowRelativeMouseMode(FHandle);
end;

function TSdlWindow.GetIsScreenKeyboardShown: Boolean;
begin
  Result := SDL_ScreenKeyboardShown(FHandle);
end;

function TSdlWindow.GetKeyboardGrab: Boolean;
begin
  Result := SDL_GetWindowKeyboardGrab(FHandle);
end;

procedure TSdlWindow.GetMaximumSize(out AMaxW, AMaxH: Integer);
begin
  SdlCheck(SDL_GetWindowMaximumSize(FHandle, @AMaxW, @AMaxH));
end;

function TSdlWindow.GetMaximumSizeSize: TSdlSize;
begin
  SdlCheck(SDL_GetWindowMaximumSize(FHandle, @Result.W, @Result.H));
end;

procedure TSdlWindow.GetMinimumSize(out AMinW, AMinH: Integer);
begin
  SdlCheck(SDL_GetWindowMinimumSize(FHandle, @AMinW, @AMinH));
end;

function TSdlWindow.GetMinimumSizeSize: TSdlSize;
begin
  SdlCheck(SDL_GetWindowMinimumSize(FHandle, @Result.W, @Result.H));
end;

function TSdlWindow.GetModal: Boolean;
begin
  Result := (TSdlWindowFlag.Modal in GetFlags);
end;

function TSdlWindow.GetMouseGrab: Boolean;
begin
  Result := SDL_GetWindowMouseGrab(FHandle);
end;

function TSdlWindow.GetMouseRect: PSdlRect;
begin
  Result := Pointer(SDL_GetWindowMouseRect(FHandle));
end;

function TSdlWindow.GetOpacity: Single;
begin
  Result := SDL_GetWindowOpacity(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlWindow.GetParent: TSdlWindow;
begin
  Result.FHandle := SDL_GetWindowParent(FHandle);
end;

function TSdlWindow.GetPixelDensity: Single;
begin
  Result := SDL_GetWindowPixelDensity(FHandle);
  if (Result = 0) then
    __HandleError;
end;

function TSdlWindow.GetPixelFormat: TSdlPixelFormat;
begin
  Result := TSdlPixelFormat(SDL_GetWindowPixelFormat(FHandle));
end;

procedure TSdlWindow.GetPosition(out AX, AY: TSdlWindowPos);
begin
  SdlCheck(SDL_GetWindowPosition(FHandle, @AX, @AY));
end;

function TSdlWindow.GetPositionPoint: TSdlPoint;
begin
  SdlCheck(SDL_GetWindowPosition(FHandle, @Result.X, @Result.Y));
end;

function TSdlWindow.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetWindowProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

function TSdlWindow.GetResizable: Boolean;
begin
  Result := (TSdlWindowFlag.Resizable in GetFlags);
end;

function TSdlWindow.GetSafeArea: TSdlRect;
begin
  SdlCheck(SDL_GetWindowSafeArea(FHandle, @Result));
end;

function TSdlWindow.GetShape: TSdlSurface;
begin
  var Props := GetProperties;
  Result.FHandle := SDL_GetPointerProperty(SDL_PropertiesID(Properties),
    TSdlProperty.WindowShape, nil);
end;

procedure TSdlWindow.GetSize(out AW, AH: Integer);
begin
  SdlCheck(SDL_GetWindowSize(FHandle, @AW, @AH));
end;

procedure TSdlWindow.GetSizeInPixels(out AW, AH: Integer);
begin
  SdlCheck(SDL_GetWindowSizeInPixels(FHandle, @AW, @AH));
end;

function TSdlWindow.GetSizeInPixelsSize: TSdlSize;
begin
  SdlCheck(SDL_GetWindowSizeInPixels(FHandle, @Result.W, @Result.H));
end;

function TSdlWindow.GetSizeSize: TSdlSize;
begin
  SdlCheck(SDL_GetWindowSize(FHandle, @Result.W, @Result.H));
end;

function TSdlWindow.GetSurface: TSdlSurface;
begin
  var Surface := SDL_GetWindowSurface(FHandle);
  SdlCheck(Surface);
  Result.FHandle := Surface;
end;

function TSdlWindow.GetSurfaceVSync: TSdlWindowSurfaceVsync;
begin
  SdlCheck(SDL_GetWindowSurfaceVsync(FHandle, @Result));
end;

function TSdlWindow.GetTextInputActive: Boolean;
begin
  Result := SDL_TextInputActive(FHandle);
end;

procedure TSdlWindow.GetTextInputArea(out ARect: TSdlRect;
  out ACursor: Integer);
begin
  SdlCheck(SDL_GetTextInputArea(FHandle, @ARect, @ACursor));
end;

function TSdlWindow.GetTitle: String;
begin
  Result := __ToString(SDL_GetWindowTitle(FHandle));
end;

class function TSdlWindow.GetWindows: TArray<TSdlWindow>;
begin
  var Count: Integer := 0;
  var Windows := SDL_GetWindows(@Count);
  if (SdlSucceeded(Windows)) then
  try
    SetLength(Result, Count);
    Move(Windows^, Result[0], Count * SizeOf(TSdlWindow));
  finally
    SDL_free(Windows);
  end;
end;

class function TSdlWindow.GetWithKeyboardFocus: TSdlWindow;
begin
  Result.FHandle := SDL_GetKeyboardFocus;
end;

procedure TSdlWindow.Hide;
begin
  SdlCheck(SDL_HideWindow(FHandle));
end;

class operator TSdlWindow.Implicit(const AValue: Pointer): TSdlWindow;
begin
  Result.FHandle := THandle(AValue);
end;

procedure TSdlWindow.Maximize;
begin
  SdlCheck(SDL_MaximizeWindow(FHandle));
end;

procedure TSdlWindow.Minimize;
begin
  SdlCheck(SDL_MinimizeWindow(FHandle));
end;

class operator TSdlWindow.NotEqual(const ALeft, ARight: TSdlWindow): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlWindow.NotEqual(const ALeft: TSdlWindow;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlWindow.RaiseAndFocus;
begin
  SdlCheck(SDL_RaiseWindow(FHandle));
end;

procedure TSdlWindow.Restore;
begin
  SdlCheck(SDL_RestoreWindow(FHandle));
end;

procedure TSdlWindow.SetAlwaysOnTop(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowAlwaysOnTop(FHandle, AValue));
end;

procedure TSdlWindow.SetAspectRatio(const AMinAspect, AMaxAspect: Single);
begin
  SdlCheck(SDL_SetWindowAspectRatio(FHandle, AMinAspect, AMaxAspect));
end;

procedure TSdlWindow.SetBordered(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowBordered(FHandle, AValue));
end;

procedure TSdlWindow.SetFocusable(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowFocusable(FHandle, AValue));
end;

procedure TSdlWindow.SetFullscreen(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowFullscreen(FHandle, AValue));
end;

procedure TSdlWindow.SetFullscreenMode(const AValue: PSdlDisplayMode);
begin
  SdlCheck(SDL_SetWindowFullscreenMode(FHandle, Pointer(AValue)));
end;

procedure TSdlWindow.SetIcon(const AValue: TSdlSurface);
begin
  SdlCheck(SDL_SetWindowIcon(FHandle, @AValue.FHandle));
end;

procedure TSdlWindow.SetIsRelativeMouseMode(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowRelativeMouseMode(FHandle, AValue));
end;

procedure TSdlWindow.SetKeyboardGrab(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowKeyboardGrab(FHandle, AValue));
end;

procedure TSdlWindow.SetMaximumSize(const AMaxW, AMaxH: Integer);
begin
  SdlCheck(SDL_SetWindowMaximumSize(FHandle, AMaxW, AMaxH));
end;

procedure TSdlWindow.SetMaximumSizeSize(const AValue: TSdlSize);
begin
  SdlCheck(SDL_SetWindowMaximumSize(FHandle, AValue.W, AValue.H));
end;

procedure TSdlWindow.SetMinimumSize(const AMinW, AMinH: Integer);
begin
  SdlCheck(SDL_SetWindowMinimumSize(FHandle, AMinW, AMinH));
end;

procedure TSdlWindow.SetMinimumSizeSize(const AValue: TSdlSize);
begin
  SdlCheck(SDL_SetWindowMinimumSize(FHandle, AValue.W, AValue.H));
end;

procedure TSdlWindow.SetModal(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowModal(FHandle, AValue));
end;

procedure TSdlWindow.SetMouseGrab(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowMouseGrab(FHandle, AValue));
end;

procedure TSdlWindow.SetMouseRect(const AValue: PSdlRect);
begin
  SdlCheck(SDL_SetWindowMouseRect(FHandle, Pointer(AValue)));
end;

procedure TSdlWindow.SetOpacity(const AValue: Single);
begin
  SDL_SetWindowOpacity(FHandle, AValue);
end;

procedure TSdlWindow.SetParent(const AValue: TSdlWindow);
begin
  SdlCheck(SDL_SetWindowParent(FHandle, AValue.FHandle));
end;

procedure TSdlWindow.SetPosition(const AX, AY: TSdlWindowPos);
begin
  SdlCheck(SDL_SetWindowPosition(FHandle, AX, AY));
end;

procedure TSdlWindow.SetPositionPoint(const AValue: TSdlPoint);
begin
  SdlCheck(SDL_SetWindowPosition(FHandle, AValue.X, AValue.Y));
end;

procedure TSdlWindow.SetResizable(const AValue: Boolean);
begin
  SdlCheck(SDL_SetWindowResizable(FHandle, AValue));
end;

procedure TSdlWindow.SetShape(const AValue: TSdlSurface);
begin
  SdlCheck(SDL_SetWindowShape(FHandle, AValue.FHandle));
end;

function TSdlWindow.SetSize(const AW, AH: Integer): Boolean;
begin
  Result := SDL_SetWindowSize(FHandle, AW, AH);
end;

procedure TSdlWindow.SetSizeSize(const AValue: TSdlSize);
begin
  SdlCheck(SDL_SetWindowSize(FHandle, AValue.W, AValue.H));
end;

procedure TSdlWindow.SetSurfaceVSync(const AValue: TSdlWindowSurfaceVsync);
begin
  SdlCheck(SDL_SetWindowSurfaceVsync(FHandle, AValue));
end;

procedure TSdlWindow.SetTextInputArea(const ARect: TSdlRect;
  const ACursor: Integer);
begin
  SdlCheck(SDL_SetTextInputArea(FHandle, @ARect, ACursor));
end;

procedure TSdlWindow.SetTitle(const AValue: String);
begin
  SdlCheck(SDL_SetWindowTitle(FHandle, __ToUtf8(AValue)));
end;

procedure TSdlWindow.Show;
begin
  SdlCheck(SDL_ShowWindow(FHandle));
end;

procedure TSdlWindow.ShowSystemMenu(const AX, AY: Integer);
begin
  SdlCheck(SDL_ShowWindowSystemMenu(FHandle, AX, AY));
end;

procedure TSdlWindow.StartTextInput(const AProps: TSdlProperties);
begin
  SdlCheck(SDL_StartTextInputWithProperties(FHandle, SDL_PropertiesID(AProps)));
end;

procedure TSdlWindow.StopTextInput;
begin
  SdlCheck(SDL_StopTextInput(FHandle));
end;

procedure TSdlWindow.StartTextInput;
begin
  SdlCheck(SDL_StartTextInput(FHandle));
end;

function TSdlWindow.Sync: Boolean;
begin
  Result := SDL_SyncWindow(FHandle);
end;

procedure TSdlWindow.UpdateSurface(const ARects: array of TSdlRect);
begin
  SdlCheck(SDL_UpdateWindowSurfaceRects(FHandle, @ARects, Length(ARects)));
end;

procedure TSdlWindow.WarpMouse(const APosition: TSdlPointF);
begin
  SDL_WarpMouseInWindow(FHandle, APosition.X, APosition. Y);
end;

procedure TSdlWindow.WarpMouse(const AX, AY: Single);
begin
  SDL_WarpMouseInWindow(FHandle, AX, AY);
end;

procedure TSdlWindow.UpdateSurface(const ARects: TArray<TSdlRect>);
begin
  SdlCheck(SDL_UpdateWindowSurfaceRects(FHandle, Pointer(ARects), Length(ARects)));
end;

procedure TSdlWindow.UpdateSurface;
begin
  SdlCheck(SDL_UpdateWindowSurface(FHandle));
end;

{ _TSdlWindowHelper }

class destructor _TSdlWindowHelper.Destroy;
begin
  FreeAndNil(FHitTestInfo);
end;

function _TSdlWindowHelper.SetHitTestCallback(
  const ACallback: TSdlHitTestCallback): Boolean;
begin
  if Assigned(ACallback) then
  begin
    if (FHitTestInfo = nil) then
      FHitTestInfo := TObjectDictionary<SDL_Window, THitTestInfo>.Create([doOwnsValues]);

    var Info := THitTestInfo.Create;
    Info.Callback := ACallback;
    FHitTestInfo.AddOrSetValue(FHandle, Info);

    Result := SDL_SetWindowHitTest(FHandle, WindowHitTest, Info);
    if (not Result) then
      FHitTestInfo.Remove(FHandle);
  end
  else
  begin
    if Assigned(FHitTestInfo) then
      FHitTestInfo.Remove(FHandle);

    Result := SDL_SetWindowHitTest(FHandle, nil, nil);
  end;
end;

class function _TSdlWindowHelper.WindowHitTest(AWin: SDL_Window;
  const AArea: PSDL_Point; AData: Pointer): SDL_HitTestResult;
var
  Info: THitTestInfo absolute AData;
begin
  Assert(Assigned(AData));
  Result := Ord(Info.Callback(TSdlWindow(AWin), PSdlPoint(AArea)^));
end;

{ TSdlTexture }

class operator TSdlTexture.Equal(const ALeft: TSdlTexture;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlTexture.Equal(const ALeft, ARight: TSdlTexture): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlTexture.Free;
begin
  if (FHandle <> nil) then
  begin
    SDL_DestroyTexture(FHandle);
    FHandle := nil;
  end;
end;

function TSdlTexture.GetAlphaMod: Byte;
begin
  SdlCheck(SDL_GetTextureAlphaMod(FHandle, @Result));
end;

function TSdlTexture.GetAlphaModFloat: Single;
begin
  SdlCheck(SDL_GetTextureAlphaModFloat(FHandle, @Result));
end;

function TSdlTexture.GetBlendMode: TSdlBlendMode;
begin
  SdlCheck(SDL_GetTextureBlendMode(FHandle, @Result));
end;

function TSdlTexture.GetColorMod: TSdlColor;
begin
  SdlCheck(SDL_GetTextureColorMod(FHandle, @Result.R, @Result.G, @Result.B));
  Result.A := 255;
end;

function TSdlTexture.GetColorModFloat: TSdlColorF;
begin
  SdlCheck(SDL_GetTextureColorModFloat(FHandle, @Result.R, @Result.G, @Result.B));
  Result.A := 1;
end;

function TSdlTexture.GetFormat: TSdlPixelFormat;
begin
  if Assigned(FHandle) then
    Result := TSdlPixelFormat(FHandle.format)
  else
    Result := TSdlPixelFormat.Unknown;
end;

function TSdlTexture.GetH: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.h
  else
    Result := 0;
end;

function TSdlTexture.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetTextureProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

function TSdlTexture.GetScaleMode: TSdlScaleMode;
begin
  SdlCheck(SDL_GetTextureScaleMode(FHandle, @Result));
end;

function TSdlTexture.GetSize: TSdlSizeF;
begin
  SdlCheck(SDL_GetTextureSize(FHandle, @Result.W, @Result.H));
end;

function TSdlTexture.GetW: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.w
  else
    Result := 0;
end;

class operator TSdlTexture.Implicit(const AValue: Pointer): TSdlTexture;
begin
  Result.FHandle := AValue;
end;

procedure TSdlTexture.Lock(const ARect: TSdlRect; out APixels: Pointer;
  out APitch: Integer);
begin
  SdlCheck(SDL_LockTexture(FHandle, @ARect, @APixels, @APitch));
end;

function TSdlTexture.LockToSurface(const ARect: TSdlRect): TSdlSurface;
begin
  SdlCheck(SDL_LockTextureToSurface(FHandle, @ARect, @Result.FHandle));
end;

class operator TSdlTexture.NotEqual(const ALeft, ARight: TSdlTexture): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

function TSdlTexture.LockToSurface: TSdlSurface;
begin
  SdlCheck(SDL_LockTextureToSurface(FHandle, nil, @Result.FHandle));
end;

procedure TSdlTexture.Lock(out APixels: Pointer; out APitch: Integer);
begin
  SdlCheck(SDL_LockTexture(FHandle, nil, @APixels, @APitch));
end;

class operator TSdlTexture.NotEqual(const ALeft: TSdlTexture;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

procedure TSdlTexture.SetAlphaMod(const AValue: Byte);
begin
  SdlCheck(SDL_SetTextureAlphaMod(FHandle, AValue));
end;

procedure TSdlTexture.SetAlphaModFloat(const AValue: Single);
begin
  SdlCheck(SDL_SetTextureAlphaModFloat(FHandle, AValue));
end;

procedure TSdlTexture.SetBlendMode(const AValue: TSdlBlendMode);
begin
  SDL_SetTextureBlendMode(FHandle, Ord(AValue));
end;

procedure TSdlTexture.SetColorMod(const AValue: TSdlColor);
begin
  SdlCheck(SDL_SetTextureColorMod(FHandle, AValue.R, AValue.G, AValue.B));
end;

procedure TSdlTexture.SetColorModFloat(const AValue: TSdlColorF);
begin
  SdlCheck(SDL_SetTextureColorModFloat(FHandle, AValue.R, AValue.G, AValue.B));
end;

procedure TSdlTexture.SetScaleMode(const AValue: TSdlScaleMode);
begin
  SDL_SetTextureScaleMode(FHandle, Ord(AValue));
end;

procedure TSdlTexture.Unlock;
begin
  SDL_UnlockTexture(FHandle);
end;

procedure TSdlTexture.Update(const ARect: TSdlRect; const APixels: Pointer;
  const APitch: Integer);
begin
  SdlCheck(SDL_UpdateTexture(FHandle, @ARect, APixels, APitch));
end;

procedure TSdlTexture.Update(const APixels: Pointer; const APitch: Integer);
begin
  SdlCheck(SDL_UpdateTexture(FHandle, nil, APixels, APitch));
end;

procedure TSdlTexture.UpdateNV(const ARect: TSdlRect; const AYPlane: Pointer;
  const AYPitch: Integer; const AUVPlane: Pointer; const AUVPitch: Integer);
begin
  SdlCheck(SDL_UpdateNVTexture(FHandle, @ARect, AYPlane, AYPitch, AUVPlane, AUVPitch));
end;

procedure TSdlTexture.UpdateNV(const AYPlane: Pointer; const AYPitch: Integer;
  const AUVPlane: Pointer; const AUVPitch: Integer);
begin
  SdlCheck(SDL_UpdateNVTexture(FHandle, nil, AYPlane, AYPitch, AUVPlane, AUVPitch));
end;

procedure TSdlTexture.UpdateYuv(const ARect: TSdlRect; const AYPlane: Pointer;
  const AYPitch: Integer; const AUPlane: Pointer; const AUPitch: Integer;
  const AVPlane: Pointer; const AVPitch: Integer);
begin
  SdlCheck(SDL_UpdateYUVTexture(FHandle, @ARect, AYPlane, AYPitch, AUPlane, AUPitch, AVPlane, AVPitch));
end;

procedure TSdlTexture.UpdateYuv(const AYPlane: Pointer; const AYPitch: Integer;
  const AUPlane: Pointer; const AUPitch: Integer; const AVPlane: Pointer;
  const AVPitch: Integer);
begin
  SdlCheck(SDL_UpdateYUVTexture(FHandle, nil, AYPlane, AYPitch, AUPlane, AUPitch, AVPlane, AVPitch));
end;

{ _TSdlTextureHelper }

function _TSdlTextureHelper.GetRenderer: TSdlRenderer;
begin
  Result.FHandle := SDL_GetRendererFromTexture(FHandle);
  SdlCheck(Result.FHandle);
end;

{ TSdlRenderer }

procedure TSdlRenderer.AddVulkanSemaphores(const AWaitStageMask: UInt32;
  const AWaitSemaphore, ASignalSemaphore: Int64);
begin
  SdlCheck(SDL_AddVulkanRenderSemaphores(FHandle, AWaitStageMask, AWaitSemaphore,
    ASignalSemaphore));
end;

procedure TSdlRenderer.Clear;
begin
  SdlCheck(SDL_RenderClear(FHandle));
end;

constructor TSdlRenderer.Create(const ATitle: String; const AWidth,
  AHeight: Integer; const AWindowFlags: TSdlWindowFlags;
  out AWindow: TSdlWindow);
begin
  SdlCheck(SDL_CreateWindowAndRenderer(__ToUtf8(ATitle), AWidth, AHeight,
    UInt64(AWindowFlags), @AWindow.FHandle, @FHandle));
end;

constructor TSdlRenderer.Create(const AWindow: TSdlWindow; const AName: String);
begin
  FHandle := SDL_CreateRenderer(AWindow.FHandle, __ToUtf8(AName));
  SdlCheck(FHandle);
end;

constructor TSdlRenderer.Create(const AProperties: TSdlProperties);
begin
  FHandle := SDL_CreateRendererWithProperties(SDL_PropertiesID(AProperties));
  SdlCheck(FHandle);
end;

constructor TSdlRenderer.Create(const ASurface: TSdlSurface);
begin
  FHandle := SDL_CreateSoftwareRenderer(ASurface.FHandle);
  SdlCheck(FHandle);
end;

function TSdlRenderer.CreateTexture(const AFormat: TSdlPixelFormat;
  const AAccess: TSdlTextureAccess; const AW, AH: Integer): TSdlTexture;
begin
  Result.FHandle := SDL_CreateTexture(FHandle, Ord(AFormat), Ord(AAccess), AW, AH);
  SdlCheck(Result.FHandle);
end;

function TSdlRenderer.CreateTexture(const ASurface: TSdlSurface): TSdlTexture;
begin
  Result.FHandle := SDL_CreateTextureFromSurface(FHandle, ASurface.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlRenderer.CreateTexture(const AProps: TSdlProperties): TSdlTexture;
begin
  Result.FHandle := SDL_CreateTextureWithProperties(FHandle, SDL_PropertiesID(AProps));
  SdlCheck(Result.FHandle);
end;

procedure TSdlRenderer.DrawLine(const AX1, AY1, AX2, AY2: Single);
begin
  SdlCheck(SDL_RenderLine(FHandle, AX1, AY1, AX2, AY2));
end;

procedure TSdlRenderer.DrawGeometry(const ATexture: TSdlTexture;
  const AVertices: TArray<TSdlVertex>; const AIndices: TArray<Integer>);
begin
  SdlCheck(SDL_RenderGeometry(FHandle, ATexture.FHandle, Pointer(AVertices),
    Length(AVertices), Pointer(AIndices), Length(AIndices)));
end;

procedure TSdlRenderer.DrawGeometry(const AVertices: TArray<TSdlVertex>;
  const AIndices: TArray<Integer>);
begin
  SdlCheck(SDL_RenderGeometry(FHandle, nil, Pointer(AVertices),
    Length(AVertices), Pointer(AIndices), Length(AIndices)));
end;

procedure TSdlRenderer.DrawLine(const AP1, AP2: TSdlPointF);
begin
  SdlCheck(SDL_RenderLine(FHandle, AP1.X, AP1.Y, AP2.X, AP2.Y));
end;

procedure TSdlRenderer.DrawLines(const APoints: array of TSdlPointF);
begin
  SdlCheck(SDL_RenderLines(FHandle, @APoints, Length(APoints)));
end;

procedure TSdlRenderer.DrawLines(const APoints: TArray<TSdlPointF>);
begin
  SdlCheck(SDL_RenderLines(FHandle, Pointer(APoints), Length(APoints)));
end;

procedure TSdlRenderer.DrawPoint(const APoint: TSdlPointF);
begin
  SdlCheck(SDL_RenderPoint(FHandle, APoint.X, APoint.Y));
end;

procedure TSdlRenderer.DrawPoints(const APoints: array of TSdlPointF);
begin
  SdlCheck(SDL_RenderPoints(FHandle, @APoints, Length(APoints)));
end;

procedure TSdlRenderer.DrawPoints(const APoints: TArray<TSdlPointF>);
begin
  SdlCheck(SDL_RenderPoints(FHandle, Pointer(APoints), Length(APoints)));
end;

procedure TSdlRenderer.DrawRect(const ARect: TSdlRectF);
begin
  SdlCheck(SDL_RenderRect(FHandle, @ARect));
end;

procedure TSdlRenderer.DrawRects(const ARects: array of TSdlRectF);
begin
  SdlCheck(SDL_RenderRects(FHandle, @ARects, Length(ARects)));
end;

procedure TSdlRenderer.DrawRects(const ARects: TArray<TSdlRectF>);
begin
  SdlCheck(SDL_RenderRects(FHandle, Pointer(ARects), Length(ARects)));
end;

procedure TSdlRenderer.DrawTexture(const ATexture: TSdlTexture; const ASrcRect,
  ADstRect: TSdlRectF);
begin
  SdlCheck(SDL_RenderTexture(FHandle, ATexture.FHandle, @ASrcRect, @ADstRect));
end;

procedure TSdlRenderer.DrawTexture(const ATexture: TSdlTexture);
begin
  SdlCheck(SDL_RenderTexture(FHandle, ATexture.FHandle, nil, nil));
end;

procedure TSdlRenderer.DrawTexture9Grid(const ATexture: TSdlTexture;
  const ASrcRect: TSdlRectF; const ALeftWidth, ARightWidth, ATopHeight,
  ABottomHeight, AScale: Single; const ADstRect: TSdlRectF);
begin
  SdlCheck(SDL_RenderTexture9Grid(FHandle, ATexture.FHandle, @ASrcRect,
    ALeftWidth, ARightWidth, ATopHeight, ABottomHeight, AScale, @ADstRect));
end;

procedure TSdlRenderer.DrawTexture9Grid(const ATexture: TSdlTexture;
  const ALeftWidth, ARightWidth, ATopHeight, ABottomHeight, AScale: Single;
  const ADstRect: TSdlRectF);
begin
  SdlCheck(SDL_RenderTexture9Grid(FHandle, ATexture.FHandle, nil,
    ALeftWidth, ARightWidth, ATopHeight, ABottomHeight, AScale, @ADstRect));
end;

procedure TSdlRenderer.DrawTextureAffine(const ATexture: TSdlTexture;
  const ASrcRect: TSdlRectF; const AOrigin, ARight, ADown: TSdlPointF);
begin
  SdlCheck(SDL_RenderTextureAffine(FHandle, ATexture.FHandle, @ASrcRect,
    @AOrigin, @ARight, @ADown));
end;

procedure TSdlRenderer.DrawTextureAffine(const ATexture: TSdlTexture;
  const AOrigin, ARight, ADown: TSdlPointF);
begin
  SdlCheck(SDL_RenderTextureAffine(FHandle, ATexture.FHandle, nil,
    @AOrigin, @ARight, @ADown));
end;

procedure TSdlRenderer.DrawTextureRotated(const ATexture: TSdlTexture;
  const ADstRect: TSdlRectF; const AAngle: Double; const AFlip: TSdlFlipModes);
begin
  SdlCheck(SDL_RenderTextureRotated(FHandle, ATexture.FHandle, nil, @ADstRect,
    AAngle, nil, Byte(AFlip)));
end;

procedure TSdlRenderer.DrawTextureRotated(const ATexture: TSdlTexture;
  const ADstRect: TSdlRectF; const AAngle: Double; const ACenter: TSdlPointF;
  const AFlip: TSdlFlipModes);
begin
  SdlCheck(SDL_RenderTextureRotated(FHandle, ATexture.FHandle, nil, @ADstRect,
    AAngle, @ACenter, Byte(AFlip)));
end;

procedure TSdlRenderer.DrawTextureRotated(const ATexture: TSdlTexture;
  const ASrcRect, ADstRect: TSdlRectF; const AAngle: Double;
  const AFlip: TSdlFlipModes);
begin
  SdlCheck(SDL_RenderTextureRotated(FHandle, ATexture.FHandle, @ASrcRect,
    @ADstRect, AAngle, nil, Byte(AFlip)));
end;

procedure TSdlRenderer.DrawTextureRotated(const ATexture: TSdlTexture;
  const ASrcRect, ADstRect: TSdlRectF; const AAngle: Double;
  const ACenter: TSdlPointF; const AFlip: TSdlFlipModes);
begin
  SdlCheck(SDL_RenderTextureRotated(FHandle, ATexture.FHandle, @ASrcRect,
    @ADstRect, AAngle, @ACenter, Byte(AFlip)));
end;

procedure TSdlRenderer.DrawTextureTiled(const ATexture: TSdlTexture;
  const ASrcRect: TSdlRectF; const AScale: Single; const ADstRect: TSdlRectF);
begin
  SdlCheck(SDL_RenderTextureTiled(FHandle, ATexture.FHandle, @ASrcRect,
    AScale, @ADstRect));
end;

class operator TSdlRenderer.Equal(const ALeft, ARight: TSdlRenderer): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlRenderer.DrawTextureTiled(const ATexture: TSdlTexture;
  const AScale: Single; const ADstRect: TSdlRectF);
begin
  SdlCheck(SDL_RenderTextureTiled(FHandle, ATexture.FHandle, nil,
    AScale, @ADstRect));
end;

procedure TSdlRenderer.DrawTexture(const ATexture: TSdlTexture;
  const ADstRect: TSdlRectF);
begin
  SdlCheck(SDL_RenderTexture(FHandle, ATexture.FHandle, nil, @ADstRect));
end;

procedure TSdlRenderer.DrawPoint(const AX, AY: Single);
begin
  SdlCheck(SDL_RenderPoint(FHandle, AX, AY));
end;

class operator TSdlRenderer.Equal(const ALeft: TSdlRenderer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlRenderer.FillRect(const ARect: TSdlRectF);
begin
  SdlCheck(SDL_RenderFillRect(FHandle, @ARect));
end;

procedure TSdlRenderer.FillRects(const ARects: array of TSdlRectF);
begin
  SdlCheck(SDL_RenderFillRects(FHandle, @ARects, Length(ARects)));
end;

procedure TSdlRenderer.FillRects(const ARects: TArray<TSdlRectF>);
begin
  SdlCheck(SDL_RenderFillRects(FHandle, Pointer(ARects), Length(ARects)));
end;

procedure TSdlRenderer.Flush;
begin
  SdlCheck(SDL_FlushRenderer(FHandle));
end;

class function TSdlRenderer.ForWindow(const AWindow: TSdlWindow): TSdlRenderer;
begin
  Result.FHandle := SDL_GetRenderer(AWindow.FHandle);
  SdlCheck(Result.FHandle);
end;

procedure TSdlRenderer.Free;
begin
  SDL_DestroyRenderer(FHandle);
  FHandle := 0;
end;

function TSdlRenderer.GetClipRect: TSdlRect;
begin
  SdlCheck(SDL_GetRenderClipRect(FHandle, @Result));
end;

function TSdlRenderer.GetColorScale: Single;
begin
  SdlCheck(SDL_GetRenderColorScale(FHandle, @Result));
end;

function TSdlRenderer.GetCurrentOutputSize: TSdlSize;
begin
  SdlCheck(SDL_GetCurrentRenderOutputSize(FHandle, @Result.W, @Result.H));
end;

function TSdlRenderer.GetDrawBlendMode: TSdlBlendMode;
begin
  SdlCheck(SDL_GetRenderDrawBlendMode(FHandle, @Result));
end;

function TSdlRenderer.GetDrawColor: TSdlColor;
begin
  SdlCheck(SDL_GetRenderDrawColor(FHandle, @Result.R, @Result.G, @Result.B, @Result.A));
end;

function TSdlRenderer.GetDrawColorFloat: TSdlColorF;
begin
  SdlCheck(SDL_GetRenderDrawColorFloat(FHandle, @Result.R, @Result.G, @Result.B, @Result.A));
end;

function TSdlRenderer.GetIsClipEnabled: Boolean;
begin
  Result := SDL_RenderClipEnabled(FHandle);
end;

function TSdlRenderer.GetIsViewportSet: Boolean;
begin
  Result := SDL_RenderViewportSet(FHandle);
end;

procedure TSdlRenderer.GetLogicalPresentation(out AW, AH: Integer;
  out AMode: TSdlRendererLogicalPresentation);
begin
  SdlCheck(SDL_GetRenderLogicalPresentation(FHandle, @AW, @AH, @AMode));
end;

function TSdlRenderer.GetLogicalPresentationRect: TSdlRect;
begin
  SdlCheck(SDL_GetRenderLogicalPresentationRect(FHandle, @Result));
end;

function TSdlRenderer.GetMetalCommandEncoder: Pointer;
begin
  Result := SDL_GetRenderMetalCommandEncoder(FHandle);
end;

function TSdlRenderer.GetMetalLayer: Pointer;
begin
  Result := SDL_GetRenderMetalLayer(FHandle);
end;

function TSdlRenderer.GetName: String;
begin
  var Name := SDL_GetRendererName(FHandle);
  SdlCheck(Name);

  Result := __ToString(Name);
end;

function TSdlRenderer.GetOutputSize: TSdlSize;
begin
  SdlCheck(SDL_GetRenderOutputSize(FHandle, @Result.W, @Result.H));
end;

function TSdlRenderer.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetRendererProperties(FHandle);
  SdlCheck(SDL_PropertiesID(Result));
end;

class function TSdlRenderer.GetDriver(const AIndex: Integer): String;
begin
  Result := __ToString(SDL_GetRenderDriver(AIndex));
end;

class function TSdlRenderer.GetDriverCount: Integer;
begin
  Result := SDL_GetNumRenderDrivers;
end;

function TSdlRenderer.GetTarget: TSdlTexture;
begin
  Result.FHandle := SDL_GetRenderTarget(FHandle);
end;

function TSdlRenderer.GetSafeArea: TSdlRect;
begin
  SdlCheck(SDL_GetRenderSafeArea(FHandle, @Result));
end;

function TSdlRenderer.GetScale: TSdlPointF;
begin
  SdlCheck(SDL_GetRenderScale(FHandle, @Result.X, @Result.Y));
end;

function TSdlRenderer.GetViewport: TSdlRect;
begin
  SdlCheck(SDL_GetRenderViewport(FHandle, @Result));
end;

function TSdlRenderer.GetVSync: TSdlRendererVsync;
begin
  SdlCheck(SDL_GetRenderVSync(FHandle, @Result));
end;

function TSdlRenderer.GetWindow: TSdlWindow;
begin
  Result.FHandle := SDL_GetRenderWindow(FHandle);
  SdlCheck(Result.FHandle);
end;

class operator TSdlRenderer.Implicit(const AValue: Pointer): TSdlRenderer;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlRenderer.NotEqual(const ALeft,
  ARight: TSdlRenderer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlRenderer.NotEqual(const ALeft: TSdlRenderer;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

procedure TSdlRenderer.Present;
begin
  SdlCheck(SDL_RenderPresent(FHandle));
end;

function TSdlRenderer.ReadPixels(const ARect: TSdlRect): TSdlSurface;
begin
  Result.FHandle := SDL_RenderReadPixels(FHandle, @ARect);
  SdlCheck(Result.FHandle);
end;

function TSdlRenderer.ReadPixels: TSdlSurface;
begin
  Result.FHandle := SDL_RenderReadPixels(FHandle, nil);
  SdlCheck(Result.FHandle);
end;

function TSdlRenderer.RenderCoordinatesFromWindow(const AWindowX,
  AWindowY: Single): TSdlPointF;
begin
  SdlCheck(SDL_RenderCoordinatesFromWindow(FHandle, AWindowX, AWindowY, @Result.X, @Result.Y));
end;

function TSdlRenderer.RenderCoordinatesToWindow(const AX,
  AY: Single): TSdlPointF;
begin
  SdlCheck(SDL_RenderCoordinatesToWindow(FHandle, AX, AY, @Result.X, @Result.Y));
end;

procedure TSdlRenderer.ResetViewport;
begin
  SdlCheck(SDL_SetRenderViewport(FHandle, nil));
end;

procedure TSdlRenderer.SetClipRect(const AValue: TSdlRect);
begin
  SdlCheck(SDL_SetRenderClipRect(FHandle, @AValue));
end;

procedure TSdlRenderer.SetColorScale(const AValue: Single);
begin
  SdlCheck(SDL_SetRenderColorScale(FHandle, AValue));
end;

procedure TSdlRenderer.SetDrawBlendMode(const AValue: TSdlBlendMode);
begin
  SdlCheck(SDL_SetRenderDrawBlendMode(FHandle, Ord(AValue)));
end;

procedure TSdlRenderer.SetDrawColorFloat(const AR, AG, AB, AA: Single);
begin
  SdlCheck(SDL_SetRenderDrawColorFloat(FHandle, AR, AG, AB, AA));
end;

procedure TSdlRenderer.SetDrawColorFloat(const AValue: TSdlColorF);
begin
  SdlCheck(SDL_SetRenderDrawColorFloat(FHandle, AValue.R, AValue.G, AValue.B, AValue.A));
end;

procedure TSdlRenderer.SetIsClipEnabled(const AValue: Boolean);
begin
  if (not AValue) then
    SdlCheck(SDL_SetRenderClipRect(FHandle, nil));
end;

procedure TSdlRenderer.SetLogicalPresentation(const AW, AH: Integer;
  const AMode: TSdlRendererLogicalPresentation);
begin
  SdlCheck(SDL_SetRenderLogicalPresentation(FHandle, AW, AH, Ord(AMode)));
end;

procedure TSdlRenderer.SetTarget(const AValue: TSdlTexture);
begin
  SdlCheck(SDL_SetRenderTarget(FHandle, AValue.FHandle));
end;

procedure TSdlRenderer.SetScale(const AValue: TSdlPointF);
begin
  SdlCheck(SDL_SetRenderScale(FHandle, AValue.X, AValue.Y));
end;

procedure TSdlRenderer.SetViewport(const AValue: TSdlRect);
begin
  SdlCheck(SDL_SetRenderViewport(FHandle, @AValue));
end;

procedure TSdlRenderer.SetVSync(const AValue: TSdlRendererVsync);
begin
  SdlCheck(SDL_SetRenderVSync(FHandle, AValue));
end;

procedure TSdlRenderer.SetDrawColor(const AValue: TSdlColor);
begin
  SdlCheck(SDL_SetRenderDrawColor(FHandle, AValue.R, AValue.G, AValue.B, AValue.A));
end;

procedure TSdlRenderer.SetDrawColor(const AR, AG, AB, AA: Byte);
begin
  SdlCheck(SDL_SetRenderDrawColor(FHandle, AR, AG, AB, AA));
end;

procedure TSdlRenderer.DrawDebugText(const APosition: TSdlPointF;
  const AString: String);
begin
  SdlCheck(SDL_RenderDebugText(FHandle, APosition.X, APosition.Y, __ToUtf8(AString)));
end;

procedure TSdlRenderer.DrawDebugText(const AX, AY: Single;
  const AString: String);
begin
  SdlCheck(SDL_RenderDebugText(FHandle, AX, AY, __ToUtf8(AString)));
end;

procedure TSdlRenderer.DrawGeometry(const ATexture: TSdlTexture;
  const AXY: TArray<TSdlPointF>; const AXYStride: Integer;
  const AColor: TArray<TSdlColorF>; const AColorStride: Integer;
  const AUV: TArray<TSdlPointF>; const AUVStride: Integer;
  const AIndices: Pointer; const ANumIndices: Integer;
  const AIndexType: TSdlIndexType);
begin
  SdlCheck(SDL_RenderGeometryRaw(FHandle, ATexture.FHandle, Pointer(AXY),
    AXYStride, Pointer(AColor), AColorStride, Pointer(AUV), AUVStride,
    Length(AXY), AIndices, ANumIndices, Ord(AIndexType)));
end;

procedure TSdlRenderer.DrawGeometry(const AXY: TArray<TSdlPointF>;
  const AXYStride: Integer; const AColor: TArray<TSdlColorF>;
  const AColorStride: Integer; const AUV: TArray<TSdlPointF>;
  const AUVStride: Integer; const AIndices: Pointer; const ANumIndices: Integer;
  const AIndexType: TSdlIndexType);
begin
  SdlCheck(SDL_RenderGeometryRaw(FHandle, nil, Pointer(AXY),
    AXYStride, Pointer(AColor), AColorStride, Pointer(AUV), AUVStride,
    Length(AXY), AIndices, ANumIndices, Ord(AIndexType)));
end;

{ TSdlGLContext }

constructor TSdlGLContext.Create(const AWindow: TSdlWindow);
begin
  FHandle := SDL_GL_CreateContext(AWindow.FHandle);
  SdlCheck(FHandle);
end;

class operator TSdlGLContext.Equal(const ALeft: TSdlGLContext;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlGLContext.Equal(const ALeft, ARight: TSdlGLContext): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlGLContext.Free;
begin
  SdlCheck(SDL_GL_DestroyContext(FHandle));
  FHandle := 0;
end;

class function TSdlGLContext.GetCurrent: TSdlGLContext;
begin
  Result.FHandle := SDL_GL_GetCurrentContext;
  SdlCheck(Result.FHandle);
end;

class operator TSdlGLContext.Implicit(const AValue: Pointer): TSdlGLContext;
begin
  Result.FHandle := THandle(AValue);
end;

procedure TSdlGLContext.MakeCurrent(const AWindow: TSdlWindow);
begin
  SdlCheck(SDL_GL_MakeCurrent(AWindow.FHandle, FHandle));
end;

class operator TSdlGLContext.NotEqual(const ALeft,
  ARight: TSdlGLContext): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGLContext.NotEqual(const ALeft: TSdlGLContext;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlGL }

class function TSdlGL.GetAttribute(const AAttr: TSdlGLAttr): Integer;
begin
  SdlCheck(SDL_GL_GetAttribute(Ord(AAttr), @Result));
end;

class function TSdlGL.GetCurrentWindow: TSdlWindow;
begin
  Result.FHandle := SDL_GL_GetCurrentWindow;
  SdlCheck(Result.FHandle);
end;

class function TSdlGL.GetProcAddress(const AProc: String): Pointer;
begin
  Result := SDL_GL_GetProcAddress(__ToUtf8(AProc));
end;

class function TSdlGL.GetSwapInterval: Integer;
begin
  SdlCheck(SDL_GL_GetSwapInterval(@Result));
end;

class function TSdlGL.IsExtensionSupported(const AExtension: String): Boolean;
begin
  Result := SDL_GL_ExtensionSupported(__ToUtf8(AExtension));
end;

class procedure TSdlGL.LoadLibrary(const APath: String);
begin
  SdlCheck(SDL_GL_LoadLibrary(__ToUtf8(APath)));
end;

class procedure TSdlGL.ResetAttributes;
begin
  SDL_GL_ResetAttributes;
end;

class procedure TSdlGL.SetAttribute(const AAttr: TSdlGLAttr;
  const AValue: Integer);
begin
  SdlCheck(SDL_GL_SetAttribute(Ord(AAttr), AValue));
end;

class procedure TSdlGL.SetSwapInterval(const AValue: Integer);
begin
  SdlCheck(SDL_GL_SetSwapInterval(AValue));
end;

class procedure TSdlGL.SwapWindow(const AWindow: TSdlWindow);
begin
  SdlCheck(SDL_GL_SwapWindow(AWindow.FHandle));
end;

class procedure TSdlGL.UnloadLibrary;
begin
  SDL_GL_UnloadLibrary;
end;

{ TSdlEglDisplay }

class operator TSdlEglDisplay.Equal(const ALeft: TSdlEglDisplay;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlEglDisplay.Equal(const ALeft,
  ARight: TSdlEglDisplay): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlEglDisplay.GetCurrent: TSdlEglDisplay;
begin
  Result.FHandle := SDL_EGL_GetCurrentDisplay;
  SdlCheck(Result.FHandle);
end;

class operator TSdlEglDisplay.Implicit(const AValue: Pointer): TSdlEglDisplay;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlEglDisplay.NotEqual(const ALeft,
  ARight: TSdlEglDisplay): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlEglDisplay.NotEqual(const ALeft: TSdlEglDisplay;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlEglConfig }

class operator TSdlEglConfig.Equal(const ALeft: TSdlEglConfig;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlEglConfig.Equal(const ALeft, ARight: TSdlEglConfig): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlEglConfig.GetCurrent: TSdlEglConfig;
begin
  Result.FHandle := SDL_EGL_GetCurrentConfig;
  SdlCheck(Result.FHandle);
end;

class operator TSdlEglConfig.Implicit(const AValue: Pointer): TSdlEglConfig;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlEglConfig.NotEqual(const ALeft,
  ARight: TSdlEglConfig): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlEglConfig.NotEqual(const ALeft: TSdlEglConfig;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlEglSurface }

class operator TSdlEglSurface.Equal(const ALeft: TSdlEglSurface;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlEglSurface.Equal(const ALeft,
  ARight: TSdlEglSurface): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlEglSurface.ForWindow(
  const AWindow: TSdlWindow): TSdlEglSurface;
begin
  Result.FHandle := SDL_EGL_GetWindowSurface(AWindow.FHandle);
  SdlCheck(Result.FHandle);
end;

class operator TSdlEglSurface.Implicit(const AValue: Pointer): TSdlEglSurface;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlEglSurface.NotEqual(const ALeft,
  ARight: TSdlEglSurface): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlEglSurface.NotEqual(const ALeft: TSdlEglSurface;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ TSdlEgl }

class function TSdlEgl.ContextAttribCallback(AUserdata: Pointer;
  ADisplay: SDL_EGLDisplay; AConfig: SDL_EGLConfig): PSDL_EGLint;
begin
  Assert(Assigned(FContextAttribCallback));
  var Attribs := FContextAttribCallback(TSdlEglDisplay(ADisplay), TSdlEglConfig(AConfig));
  Result := ToIntArray(Attribs);
end;

class function TSdlEgl.GetProcAddress(const AProc: String): Pointer;
begin
  Result := SDL_EGL_GetProcAddress(__ToUtf8(AProc));
end;

class function TSdlEgl.PlatformAttribCallback(
  AUserdata: Pointer): PSDL_EGLAttrib;
begin
  Assert(Assigned(FPlatformAttribCallback));
  var Attribs := FPlatformAttribCallback();

  var Count := Length(Attribs);
  if (Count = 0) then
    Exit(nil);

  Result := SDL_malloc((Count + 1) * SizeOf(SDL_EGLAttrib));
  Move(Attribs[0], Result^, Count * SizeOf(SDL_EGLAttrib));
  {$POINTERMATH ON}
  Result[Count] := EGL_NONE;
  {$POINTERMATH OFF}
end;

class procedure TSdlEgl.SetAttributeCallbacks(
  const APlatformAttribCallback: TSdlEglAttribArrayCallback;
  const ASurfaceAttribCallback,
  AContextAttribCallback: TSdlEglIntArrayCallback);
begin
  FPlatformAttribCallback := APlatformAttribCallback;
  FSurfaceAttribCallback := ASurfaceAttribCallback;
  FContextAttribCallback := AContextAttribCallback;

  var PC: SDL_EGLAttribArrayCallback := nil;
  var SC: SDL_EGLIntArrayCallback := nil;
  var CC: SDL_EGLIntArrayCallback := nil;

  if Assigned(APlatformAttribCallback) then
    PC := PlatformAttribCallback;

  if Assigned(ASurfaceAttribCallback) then
    SC := SurfaceAttribCallback;

  if Assigned(AContextAttribCallback) then
    CC := ContextAttribCallback;

  SDL_EGL_SetAttributeCallbacks(PC, SC, CC, nil);
end;

class function TSdlEgl.SurfaceAttribCallback(AUserdata: Pointer;
  ADisplay: SDL_EGLDisplay; AConfig: SDL_EGLConfig): PSDL_EGLint;
begin
  Assert(Assigned(FSurfaceAttribCallback));
  var Attribs := FSurfaceAttribCallback(TSdlEglDisplay(ADisplay), TSdlEglConfig(AConfig));
  Result := ToIntArray(Attribs);
end;

class function TSdlEgl.ToIntArray(
  const AAttribs: TArray<TSdlEglInt>): PSDL_EGLint;
begin
  var Count := Length(AAttribs);
  if (Count = 0) then
    Exit(nil);

  Result := SDL_malloc((Count + 1) * SizeOf(SDL_EGLint));
  Move(AAttribs[0], Result^, Count * SizeOf(SDL_EGLint));
  {$POINTERMATH ON}
  Result[Count] := EGL_NONE;
  {$POINTERMATH OFF}
end;

{ TSdlMetalView }

constructor TSdlMetalView.Create(const AWindow: TSdlWindow);
begin
  FHandle := SDL_Metal_CreateView(AWindow.FHandle);
end;

class operator TSdlMetalView.Equal(const ALeft: TSdlMetalView;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlMetalView.Equal(const ALeft, ARight: TSdlMetalView): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

procedure TSdlMetalView.Free;
begin
  SDL_Metal_DestroyView(FHandle);
  FHandle := 0;
end;

function TSdlMetalView.GetLayer: Pointer;
begin
  Result := SDL_Metal_GetLayer(FHandle);
end;

function TSdlMetalView.GetView: Pointer;
begin
  Result := Pointer(FHandle);
end;

class operator TSdlMetalView.Implicit(const AValue: Pointer): TSdlMetalView;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlMetalView.NotEqual(const ALeft,
  ARight: TSdlMetalView): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlMetalView.NotEqual(const ALeft: TSdlMetalView;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

{ Vulkan }

procedure SdlVulkanLoadLibrary(const APath: String);
begin
  SdlCheck(SDL_Vulkan_LoadLibrary(__ToUtf8(APath)));
end;

function SdlVulkanGetVkGetInstanceProcAddr: Pointer;
begin
  Result := SDL_Vulkan_GetVkGetInstanceProcAddr;
  SdlCheck(Result);
end;

procedure SdlVulkanUnloadLibrary;
begin
  SDL_Vulkan_UnloadLibrary;
end;

function SdlVulkanGetInstanceExtensions: TArray<String>;
begin
  var Count := 0;
  var Extensions := SDL_Vulkan_GetInstanceExtensions(@Count);
  if (SdlSucceeded(Extensions)) then
  begin
    SetLength(Result, Count);
    for var I := 0 to Count - 1 do
    begin
      Result[I] := __ToString(Extensions^);
      Inc(Extensions);
    end;
  end;
end;

function SdlVulkanCreateSurface(const AWindow: TSdlWindow;
  const AInstance: VkInstance;
  const AAllocator: PVkAllocationCallbacks = nil): VkSurfaceKHR;
begin
  SdlCheck(SDL_Vulkan_CreateSurface(AWindow.FHandle, AInstance, AAllocator, @Result));
end;

procedure SdlVulkanDestroySurface(const AInstance: VkInstance;
  const ASurface: VkSurfaceKHR; const AAllocator: PVkAllocationCallbacks = nil);
begin
  SDL_Vulkan_DestroySurface(AInstance, ASurface, AAllocator);
end;

function SdlVulkanGetPresentationSupport(const AInstance: VkInstance;
  const APhysicalDevice: VkPhysicalDevice; const AQueueFamilyIndex: Integer): Boolean;
begin
  Result := SDL_Vulkan_GetPresentationSupport(AInstance, APhysicalDevice,
    AQueueFamilyIndex);
end;

{ TSdlCamera }

function TSdlCamera.AcquireFrame(out ATimestampNS: UInt64): TSdlSurface;
begin
  Result.FHandle := SDL_AcquireCameraFrame(FHandle, @ATimestampNS);
end;

procedure TSdlCamera.Close;
begin
  SDL_CloseCamera(FHandle);
  FHandle := 0;
end;

class operator TSdlCamera.Equal(const ALeft, ARight: TSdlCamera): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlCamera.Equal(const ALeft: TSdlCamera;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

function TSdlCamera.GetFormat: TSdlCameraSpec;
begin
  SdlCheck(SDL_GetCameraFormat(FHandle, Result.FHandle));
end;

function TSdlCamera.GetID: TSdlCameraID;
begin
  Result.FHandle := SDL_GetCameraID(FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlCamera.GetPermissionState: TSdlCameraPermissionState;
begin
  Result := TSdlCameraPermissionState(SDL_GetCameraPermissionState(FHandle));
end;

function TSdlCamera.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetCameraProperties(FHandle);
end;

class operator TSdlCamera.Implicit(const AValue: Pointer): TSdlCamera;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlCamera.NotEqual(const ALeft, ARight: TSdlCamera): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlCamera.NotEqual(const ALeft: TSdlCamera;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class function TSdlCamera.Open(const AInstanceID: TSdlCameraID;
  const ASpec: TSdlCameraSpec): TSdlCamera;
begin
  Result.FHandle := SDL_OpenCamera(AInstanceID.FHandle, ASpec.FHandle);
  SdlCheck(Result.FHandle);
end;

procedure TSdlCamera.ReleaseFrame(const AFrame: TSdlSurface);
begin
  SDL_ReleaseCameraFrame(FHandle, AFrame.FHandle);
end;

class function TSdlCamera.Open(const AInstanceID: TSdlCameraID): TSdlCamera;
begin
  Result.FHandle := SDL_OpenCamera(AInstanceID.FHandle, nil);
  SdlCheck(Result.FHandle);
end;

{ TSdlCameraSpec }

function TSdlCameraSpec.GetColorspace: TSdlColorspace;
begin
  if Assigned(FHandle) then
    Result := TSdlColorspace(FHandle.colorspace)
  else
    Result := TSdlColorspace.Unknown;
end;

function TSdlCameraSpec.GetFormat: TSdlPixelFormat;
begin
  if Assigned(FHandle) then
    Result := TSdlPixelFormat(FHandle.format)
  else
    Result := TSdlPixelFormat.Unknown;
end;

function TSdlCameraSpec.GetFrameDurationMs: Double;
begin
  if Assigned(FHandle) then
    Result := (FHandle.framerate_denominator * 1000) / FHandle.framerate_numerator
  else
    Result := 0;
end;

function TSdlCameraSpec.GetFrameRate: Double;
begin
  if Assigned(FHandle) then
    Result := FHandle.framerate_numerator / FHandle.framerate_denominator
  else
    Result := 0;
end;

function TSdlCameraSpec.GetFrameRateDenominator: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.framerate_denominator
  else
    Result := 0;
end;

function TSdlCameraSpec.GetFrameRateNumerator: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.framerate_numerator
  else
    Result := 0;
end;

function TSdlCameraSpec.GetHeight: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.height
  else
    Result := 0;
end;

function TSdlCameraSpec.GetWidth: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.width
  else
    Result := 0;
end;

{ TSdlCameraID }

class operator TSdlCameraID.Equal(const ALeft: TSdlCameraID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlCameraID.Equal(const ALeft, ARight: TSdlCameraID): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlCameraID.GetCameras: TArray<TSdlCameraID>;
begin
  var Count := 0;
  var Cameras := SDL_GetCameras(@Count);
  if (SdlSucceeded(Cameras)) then
  try
    SetLength(Result, Count);
    Move(Cameras^, Result[0], Count * SizeOf(SDL_CameraID));
  finally
    SDL_free(Cameras);
  end;
end;

function TSdlCameraID.GetName: String;
begin
  Result := __ToString(SDL_GetCameraName(FHandle));
end;

function TSdlCameraID.GetPosition: TSdlCameraPosition;
begin
  Result := TSdlCameraPosition(SDL_GetCameraPosition(FHandle));
end;

function TSdlCameraID.GetSupportedFormats: TArray<TSdlCameraSpec>;
begin
  var Count := 0;
  var Formats := SDL_GetCameraSupportedFormats(FHandle, @Count);
  if (SdlSucceeded(Formats)) then
  try
    SetLength(Result, Count);
    Move(Formats^, Result[0], Count * SizeOf(PSDL_CameraSpec));
  finally
    SDL_free(Formats);
  end;
end;

class operator TSdlCameraID.Implicit(const AValue: Cardinal): TSdlCameraID;
begin
  Result.FHandle := AValue;
end;

class operator TSdlCameraID.NotEqual(const ALeft,
  ARight: TSdlCameraID): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlCameraID.NotEqual(const ALeft: TSdlCameraID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlCameraDriver }

class operator TSdlCameraDriver.Equal(const ALeft: TSdlCameraDriver;
  const ARight: Pointer): Boolean;
begin
  Result := (Pointer(ALeft.FName) = ARight);
end;

class operator TSdlCameraDriver.Equal(const ALeft,
  ARight: TSdlCameraDriver): Boolean;
begin
  Result := (ALeft.FName = ARight.FName);
end;

class function TSdlCameraDriver.GetCurrent: TSdlCameraDriver;
begin
  Result.FName := __ToString(SDL_GetCurrentCameraDriver);
end;

class function TSdlCameraDriver.GetDriver(
  const AIndex: Integer): TSdlCameraDriver;
begin
  Result.FName := __ToString(SDL_GetCameraDriver(AIndex));
end;

class function TSdlCameraDriver.GetDriverCount: Integer;
begin
  Result := SDL_GetNumCameraDrivers;
end;

class operator TSdlCameraDriver.Implicit(const AValue: Pointer): TSdlCameraDriver;
begin
  Result.FName := '';
end;

class operator TSdlCameraDriver.NotEqual(const ALeft,
  ARight: TSdlCameraDriver): Boolean;
begin
  Result := (ALeft.FName <> ARight.FName);
end;

class operator TSdlCameraDriver.NotEqual(const ALeft: TSdlCameraDriver;
  const ARight: Pointer): Boolean;
begin
  Result := (Pointer(ALeft.FName) <> ARight);
end;

initialization
  Assert(SizeOf(TSdlWindowFlags) = 8);

end.
