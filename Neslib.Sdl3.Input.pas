unit Neslib.Sdl3.Input;

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
  Neslib.Sdl3.IO,
  Neslib.Sdl3.Basics,
  Neslib.Sdl3.Additional,
  Neslib.Sdl3.Video;

{$REGION 'Keyboard'}
/// <summary>
///  SDL keyboard management.
///
///  Please refer to the <see href="https://wiki.libsdl.org/SDL3/BestKeyboardPractices">Best Keyboard Practices</see>
///  document for details on how best to accept keyboard input in various types of programs.
/// </summary>

type
  /// <summary>
  ///  The SDL keyboard scancode representation.
  ///
  ///  An SDL scancode is the physical representation of a key on the keyboard,
  ///  independent of language and keyboard mapping.
  ///
  ///  Values of this type are used to represent keyboard keys, among other places
  ///  in the `Scancode` property of TSdlKeyboardEvent.
  ///
  ///  The values in this enumeration are based on the 
  ///  <see href="https://usb.org/sites/default/files/hut1_5.pdf">USB usage page standard</see>.
  /// </summary>
  TSdlScancode = (
    Unknown            = SDL_SCANCODE_UNKNOWN,
    A                  = SDL_SCANCODE_A,
    B                  = SDL_SCANCODE_B,
    C                  = SDL_SCANCODE_C,
    D                  = SDL_SCANCODE_D,
    E                  = SDL_SCANCODE_E,
    F                  = SDL_SCANCODE_F,
    G                  = SDL_SCANCODE_G,
    H                  = SDL_SCANCODE_H,
    I                  = SDL_SCANCODE_I,
    J                  = SDL_SCANCODE_J,
    K                  = SDL_SCANCODE_K,
    L                  = SDL_SCANCODE_L,
    M                  = SDL_SCANCODE_M,
    N                  = SDL_SCANCODE_N,
    O                  = SDL_SCANCODE_O,
    P                  = SDL_SCANCODE_P,
    Q                  = SDL_SCANCODE_Q,
    R                  = SDL_SCANCODE_R,
    S                  = SDL_SCANCODE_S,
    T                  = SDL_SCANCODE_T,
    U                  = SDL_SCANCODE_U,
    V                  = SDL_SCANCODE_V,
    W                  = SDL_SCANCODE_W,
    X                  = SDL_SCANCODE_X,
    Y                  = SDL_SCANCODE_Y,
    Z                  = SDL_SCANCODE_Z,
    _1                 = SDL_SCANCODE_1,
    _2                 = SDL_SCANCODE_2,
    _3                 = SDL_SCANCODE_3,
    _4                 = SDL_SCANCODE_4,
    _5                 = SDL_SCANCODE_5,
    _6                 = SDL_SCANCODE_6,
    _7                 = SDL_SCANCODE_7,
    _8                 = SDL_SCANCODE_8,
    _9                 = SDL_SCANCODE_9,
    _0                 = SDL_SCANCODE_0,
    Return             = SDL_SCANCODE_RETURN,
    Escape             = SDL_SCANCODE_ESCAPE,
    Backspace          = SDL_SCANCODE_BACKSPACE,
    Tab                = SDL_SCANCODE_TAB,
    Space              = SDL_SCANCODE_SPACE,
    Minus              = SDL_SCANCODE_MINUS,
    Equals             = SDL_SCANCODE_EQUALS,
    LeftBracket        = SDL_SCANCODE_LEFTBRACKET,
    RightBracket       = SDL_SCANCODE_RIGHTBRACKET,

    /// <summary>Located at the lower left of the return key on ISO keyboards
    ///  and at the right end of the QWERTY row on ANSI keyboards. Produces
    ///  REVERSE SOLIDUS (backslash) and VERTICAL LINE in a US layout, REVERSE
    ///  SOLIDUS and VERTICAL LINE in a UK Mac layout, NUMBER SIGN and TILDE in
    ///  a UK Windows layout, DOLLAR SIGN and POUND SIGN in a Swiss German
    ///  layout, NUMBER SIGN and APOSTROPHE in a German layout, GRAVE ACCENT and
    ///  POUND SIGN in a French Mac layout, and ASTERISK and MICRO SIGN in a
    ///  French Windows layout.
    /// </summary>
    Backslash          = SDL_SCANCODE_BACKSLASH,

    /// <summary>ISO USB keyboards actually use this code instead of 49 for the
    ///  same key, but all OSes I've seen treat the two codes identically. So, as
    ///  an implementor, unless your keyboard generates both of those codes and
    ///  your OS treats them differently, you should generate
    ///  SDL_SCANCODE_BACKSLASH instead of this code. As a user, you should not
    ///  rely on this code because SDL will never generate it with most (all?)
    ///  keyboards.
    /// </summary>
    NonUSHash          = SDL_SCANCODE_NONUSHASH,

    SemiColon          = SDL_SCANCODE_SEMICOLON,
    Apostrophe         = SDL_SCANCODE_APOSTROPHE,

    /// <summary>Located in the top left corner (on both ANSI and ISO keyboards).
    ///  Produces GRAVE ACCENT and TILDE in a US Windows layout and in US and UK
    ///  Mac layouts on ANSI keyboards, GRAVE ACCENT and NOT SIGN in a UK
    ///  Windows layout, SECTION SIGN and PLUS-MINUS SIGN in US and UK Mac
    ///  layouts on ISO keyboards, SECTION SIGN and DEGREE SIGN in a Swiss
    ///  German layout (Mac: only on ISO keyboards), CIRCUMFLEX ACCENT and
    ///  DEGREE SIGN in a German layout (Mac: only on ISO keyboards),
    ///  SUPERSCRIPT TWO and TILDE in a French Windows layout, COMMERCIAL AT and
    ///  NUMBER SIGN in a French Mac layout on ISO keyboards, and LESS-THAN SIGN
    ///  and GREATER-THAN SIGN in a Swiss German, German, or French Mac layout
    ///  on ANSI keyboards.
    /// </summary>
    Grave              = SDL_SCANCODE_GRAVE,

    Comma              = SDL_SCANCODE_COMMA,
    Period             = SDL_SCANCODE_PERIOD,
    Slash              = SDL_SCANCODE_SLASH,
    CapsLock           = SDL_SCANCODE_CAPSLOCK,
    F1                 = SDL_SCANCODE_F1,
    F2                 = SDL_SCANCODE_F2,
    F3                 = SDL_SCANCODE_F3,
    F4                 = SDL_SCANCODE_F4,
    F5                 = SDL_SCANCODE_F5,
    F6                 = SDL_SCANCODE_F6,
    F7                 = SDL_SCANCODE_F7,
    F8                 = SDL_SCANCODE_F8,
    F9                 = SDL_SCANCODE_F9,
    F10                = SDL_SCANCODE_F10,
    F11                = SDL_SCANCODE_F11,
    F12                = SDL_SCANCODE_F12,
    PrintScreen        = SDL_SCANCODE_PRINTSCREEN,
    ScrollLock         = SDL_SCANCODE_SCROLLLOCK,
    Pause              = SDL_SCANCODE_PAUSE,

    /// <summary>Insert on PC, help on some Mac keyboards (but
    ///  does send code 73, not 117)</summary>
    Insert             = SDL_SCANCODE_INSERT,

    Home               = SDL_SCANCODE_HOME,
    PageUp             = SDL_SCANCODE_PAGEUP,
    Delete             = SDL_SCANCODE_DELETE,
    &End               = SDL_SCANCODE_END,
    PageDown           = SDL_SCANCODE_PAGEDOWN,
    Right              = SDL_SCANCODE_RIGHT,
    Left               = SDL_SCANCODE_LEFT,
    Down               = SDL_SCANCODE_DOWN,
    Up                 = SDL_SCANCODE_UP,

    /// <summary>Num lock on PC, clear on Mac keyboards</summary>
    NumLockClear       = SDL_SCANCODE_NUMLOCKCLEAR,

    KPDivide           = SDL_SCANCODE_KP_DIVIDE,
    KPMultiply         = SDL_SCANCODE_KP_MULTIPLY,
    KPMinus            = SDL_SCANCODE_KP_MINUS,
    KPPlus             = SDL_SCANCODE_KP_PLUS,
    KPEnter            = SDL_SCANCODE_KP_ENTER,
    KP1                = SDL_SCANCODE_KP_1,
    KP2                = SDL_SCANCODE_KP_2,
    KP3                = SDL_SCANCODE_KP_3,
    KP4                = SDL_SCANCODE_KP_4,
    KP5                = SDL_SCANCODE_KP_5,
    KP6                = SDL_SCANCODE_KP_6,
    KP7                = SDL_SCANCODE_KP_7,
    KP8                = SDL_SCANCODE_KP_8,
    KP9                = SDL_SCANCODE_KP_9,
    KP0                = SDL_SCANCODE_KP_0,
    KPPeriod           = SDL_SCANCODE_KP_PERIOD,

    /// <summary>This is the additional key that ISO keyboards have over ANSI
    ///  ones, located between left shift and Y. Produces GRAVE ACCENT and TILDE
    ///  in a US or UK Mac layout, REVERSE SOLIDUS (backslash) and VERTICAL LINE
    ///  in a US or UK Windows layout, and LESS-THAN SIGN and GREATER-THAN SIGN
    ///  in a Swiss German, German, or French layout.</summary>
    NonUSBackslash     = SDL_SCANCODE_NONUSBACKSLASH,

    /// <summary>windows contextual menu, compose</summary>
    Application        = SDL_SCANCODE_APPLICATION,

    /// <summary>The USB document says this is a status flag, not a physical
    ///  key - but some Mac keyboards do have a power key.</summary>
    Power              = SDL_SCANCODE_POWER,

    KPEquals           = SDL_SCANCODE_KP_EQUALS,
    F13                = SDL_SCANCODE_F13,
    F14                = SDL_SCANCODE_F14,
    F15                = SDL_SCANCODE_F15,
    F16                = SDL_SCANCODE_F16,
    F17                = SDL_SCANCODE_F17,
    F18                = SDL_SCANCODE_F18,
    F19                = SDL_SCANCODE_F19,
    F20                = SDL_SCANCODE_F20,
    F21                = SDL_SCANCODE_F21,
    F22                = SDL_SCANCODE_F22,
    F23                = SDL_SCANCODE_F23,
    F24                = SDL_SCANCODE_F24,
    EXECUTE            = SDL_SCANCODE_EXECUTE,

    /// <summary>AL Integrated Help Center</summary>
    Help               = SDL_SCANCODE_HELP,

    /// <summary>Menu (show menu)</summary>
    Menu               = SDL_SCANCODE_MENU,

    Select             = SDL_SCANCODE_SELECT,

    /// <summary>AC Stop</summary>
    Stop               = SDL_SCANCODE_STOP,

    /// <summary>AC Redo/Repeat</summary>
    Again              = SDL_SCANCODE_AGAIN,

    /// <summary>AC Undo</summary>
    Undo               = SDL_SCANCODE_UNDO,

    /// <summary>AC Cut</summary>
    Cut                = SDL_SCANCODE_CUT,

    /// <summary>AC Copy</summary>
    Copy               = SDL_SCANCODE_COPY,

    /// <summary>AC Paste</summary>
    Paste              = SDL_SCANCODE_PASTE,

    /// <summary>AC Find</summary>
    Find               = SDL_SCANCODE_FIND,

    Mute               = SDL_SCANCODE_MUTE,
    VolumeUp           = SDL_SCANCODE_VOLUMEUP,
    VolumeDown         = SDL_SCANCODE_VOLUMEDOWN,
    KPComma            = SDL_SCANCODE_KP_COMMA,
    KPEqualsAS400      = SDL_SCANCODE_KP_EQUALSAS400,

    /// <summary>used on Asian keyboards, see footnotes in USB doc</summary>
    International1     = SDL_SCANCODE_INTERNATIONAL1,
    International2     = SDL_SCANCODE_INTERNATIONAL2,

    /// <summary>Yen</summary>
    International3     = SDL_SCANCODE_INTERNATIONAL3,

    International4     = SDL_SCANCODE_INTERNATIONAL4,
    International5     = SDL_SCANCODE_INTERNATIONAL5,
    International6     = SDL_SCANCODE_INTERNATIONAL6,
    International7     = SDL_SCANCODE_INTERNATIONAL7,
    International8     = SDL_SCANCODE_INTERNATIONAL8,
    International9     = SDL_SCANCODE_INTERNATIONAL9,

    /// <summary>Hangul/English toggle</summary>
    Lang1              = SDL_SCANCODE_LANG1,

    /// <summary>Hanja conversion</summary>
    Lang2              = SDL_SCANCODE_LANG2,

    /// <summary>Katakana</summary>
    Lang3              = SDL_SCANCODE_LANG3,

    /// <summary>Hiragana</summary>
    Lang4              = SDL_SCANCODE_LANG4,

    /// <summary>Zenkaku/Hankaku</summary>
    Lang5              = SDL_SCANCODE_LANG5,

    /// <summary>reserved</summary>
    Lang6              = SDL_SCANCODE_LANG6,

    /// <summary>reserved</summary>
    Lang7              = SDL_SCANCODE_LANG7,

    /// <summary>reserved</summary>
    Lang8              = SDL_SCANCODE_LANG8,

    /// <summary>reserved</summary>
    Lang9              = SDL_SCANCODE_LANG9,

    /// <summary>Erase-Eaze</summary>
    AltErase           = SDL_SCANCODE_ALTERASE,

    SysReq             = SDL_SCANCODE_SYSREQ,

    /// <summary>AC Cancel</summary>
    Cancel             = SDL_SCANCODE_CANCEL,

    Clear              = SDL_SCANCODE_CLEAR,
    Prior              = SDL_SCANCODE_PRIOR,
    Return2            = SDL_SCANCODE_RETURN2,
    Separator          = SDL_SCANCODE_SEPARATOR,
    &Out               = SDL_SCANCODE_OUT,
    Oper               = SDL_SCANCODE_OPER,
    ClearAgain         = SDL_SCANCODE_CLEARAGAIN,
    CRSel              = SDL_SCANCODE_CRSEL,
    EXSel              = SDL_SCANCODE_EXSEL,
    KP00               = SDL_SCANCODE_KP_00,
    KP000              = SDL_SCANCODE_KP_000,
    ThousandsSeparator = SDL_SCANCODE_THOUSANDSSEPARATOR,
    DecimalSeparator   = SDL_SCANCODE_DECIMALSEPARATOR,
    CurrencyUnit       = SDL_SCANCODE_CURRENCYUNIT,
    CurrencySubUnit    = SDL_SCANCODE_CURRENCYSUBUNIT,
    KPLeftParen        = SDL_SCANCODE_KP_LEFTPAREN,
    KPRightParen       = SDL_SCANCODE_KP_RIGHTPAREN,
    KPLeftBrace        = SDL_SCANCODE_KP_LEFTBRACE,
    KPRightBrace       = SDL_SCANCODE_KP_RIGHTBRACE,
    KPTab              = SDL_SCANCODE_KP_TAB,
    KPBackspace        = SDL_SCANCODE_KP_BACKSPACE,
    KPA                = SDL_SCANCODE_KP_A,
    KPB                = SDL_SCANCODE_KP_B,
    KPC                = SDL_SCANCODE_KP_C,
    KPD                = SDL_SCANCODE_KP_D,
    KPE                = SDL_SCANCODE_KP_E,
    KPF                = SDL_SCANCODE_KP_F,
    KPXor              = SDL_SCANCODE_KP_XOR,
    KPPower            = SDL_SCANCODE_KP_POWER,
    KPPercent          = SDL_SCANCODE_KP_PERCENT,
    KPLess             = SDL_SCANCODE_KP_LESS,
    KPGreater          = SDL_SCANCODE_KP_GREATER,
    KPAmpersand        = SDL_SCANCODE_KP_AMPERSAND,
    KPDblAmpersand     = SDL_SCANCODE_KP_DBLAMPERSAND,
    KPVerticalBar      = SDL_SCANCODE_KP_VERTICALBAR,
    KPDblVerticalBar   = SDL_SCANCODE_KP_DBLVERTICALBAR,
    KPColon            = SDL_SCANCODE_KP_COLON,
    KPHash             = SDL_SCANCODE_KP_HASH,
    KPSpace            = SDL_SCANCODE_KP_SPACE,
    KPAt               = SDL_SCANCODE_KP_AT,
    KPExclam           = SDL_SCANCODE_KP_EXCLAM,
    KPMemStore         = SDL_SCANCODE_KP_MEMSTORE,
    KPMemRecall        = SDL_SCANCODE_KP_MEMRECALL,
    KPMemClear         = SDL_SCANCODE_KP_MEMCLEAR,
    KPMemAdd           = SDL_SCANCODE_KP_MEMADD,
    KPMemSubtract      = SDL_SCANCODE_KP_MEMSUBTRACT,
    KPMemMultiply      = SDL_SCANCODE_KP_MEMMULTIPLY,
    KPMemDivide        = SDL_SCANCODE_KP_MEMDIVIDE,
    KPPlusMinus        = SDL_SCANCODE_KP_PLUSMINUS,
    KPClear            = SDL_SCANCODE_KP_CLEAR,
    KPClearEntry       = SDL_SCANCODE_KP_CLEARENTRY,
    KPBinary           = SDL_SCANCODE_KP_BINARY,
    KPOctal            = SDL_SCANCODE_KP_OCTAL,
    KPDecimal          = SDL_SCANCODE_KP_DECIMAL,
    KPHexadecimal      = SDL_SCANCODE_KP_HEXADECIMAL,
    LCtrl              = SDL_SCANCODE_LCTRL,
    LShift             = SDL_SCANCODE_LSHIFT,

    /// <summary>Alt, option</summary>
    LAlt               = SDL_SCANCODE_LALT,

    /// <summary>Windows, command (apple), meta</summary>
    LGui               = SDL_SCANCODE_LGUI,

    RCtrl              = SDL_SCANCODE_RCTRL,
    RShift             = SDL_SCANCODE_RSHIFT,

    /// <summary>Alt gr, option</summary>
    RAlt               = SDL_SCANCODE_RALT,

    /// <summary>Windows, command (apple), meta</summary>
    RGui               = SDL_SCANCODE_RGUI,

    /// <summary>I'm not sure if this is really not covered by any of the above,
    ///  but since there's a special SDL_KMOD_MODE for it I'm adding it here
    /// </summary>
    Mode               = SDL_SCANCODE_MODE,

    /// <summary>Sleep</summary>
    Sleep              = SDL_SCANCODE_SLEEP,

    /// <summary>Wake</summary>
    Wake               = SDL_SCANCODE_WAKE,

    /// <summary>Channel Increment</summary>
    ChannelIncrement   = SDL_SCANCODE_CHANNEL_INCREMENT,

    /// <summary>Channel Decrement</summary>
    ChannelDecrement   = SDL_SCANCODE_CHANNEL_DECREMENT,

    /// <summary>Play</summary>
    MediaPlay          = SDL_SCANCODE_MEDIA_PLAY,

    /// <summary>Pause</summary>
    MediaPause         = SDL_SCANCODE_MEDIA_PAUSE,

    /// <summary>Record</summary>
    MediaRecord        = SDL_SCANCODE_MEDIA_RECORD,

    /// <summary>Fast Forward</summary>
    MediaFastForward   = SDL_SCANCODE_MEDIA_FAST_FORWARD,

    /// <summary>Rewind</summary>
    MediaRewind        = SDL_SCANCODE_MEDIA_REWIND,

    /// <summary>Next Track</summary>
    MediaNextTrack     = SDL_SCANCODE_MEDIA_NEXT_TRACK,

    /// <summary>Previous Track</summary>
    MediaPreviousTrack = SDL_SCANCODE_MEDIA_PREVIOUS_TRACK,

    /// <summary>Stop</summary>
    MediaStop          = SDL_SCANCODE_MEDIA_STOP,

    /// <summary>Eject</summary>
    MediaEject         = SDL_SCANCODE_MEDIA_EJECT,

    /// <summary>Play / Pause</summary>
    MediaPlayPause     = SDL_SCANCODE_MEDIA_PLAY_PAUSE,

    MediaSelect        = SDL_SCANCODE_MEDIA_SELECT,

    /// <summary>AC New</summary>
    ACNew              = SDL_SCANCODE_AC_NEW,

    /// <summary>AC Open</summary>
    ACOpen             = SDL_SCANCODE_AC_OPEN,

    /// <summary>AC Close</summary>
    ACClose            = SDL_SCANCODE_AC_CLOSE,

    /// <summary>AC Exit</summary>
    ACExit             = SDL_SCANCODE_AC_EXIT,

    /// <summary>AC Save</summary>
    ACSave             = SDL_SCANCODE_AC_SAVE,

    /// <summary>AC Print</summary>
    ACPrint            = SDL_SCANCODE_AC_PRINT,

    /// <summary>AC Properties</summary>
    ACProperties       = SDL_SCANCODE_AC_PROPERTIES,

    /// <summary>AC Search</summary>
    ACSearch           = SDL_SCANCODE_AC_SEARCH,

    /// <summary>AC Home</summary>
    ACHome             = SDL_SCANCODE_AC_HOME,

    /// <summary>AC Back</summary>
    ACBack             = SDL_SCANCODE_AC_BACK,

    /// <summary>AC Forward</summary>
    ACForward          = SDL_SCANCODE_AC_FORWARD,

    /// <summary>AC Stop</summary>
    ACStop             = SDL_SCANCODE_AC_STOP,

    /// <summary>AC Refresh</summary>
    ACRefresh          = SDL_SCANCODE_AC_REFRESH,

    /// <summary>AC Bookmarks</summary>
    ACBookmarks        = SDL_SCANCODE_AC_BOOKMARKS,

    /// <summary>Usually situated below the display on phones and used as a
    ///  multi-function feature key for selecting a software defined function
    ///  shown on the bottom left of the display.</summary>
    SoftLeft           = SDL_SCANCODE_SOFTLEFT,

    /// <summary>Usually situated below the display on phones and used as a
    ///  multi-function feature key for selecting a software defined function
    ///  shown on the bottom right of the display.</summary>
    SoftRight          = SDL_SCANCODE_SOFTRIGHT,

    /// <summary>Used for accepting phone calls.</summary>
    Call               = SDL_SCANCODE_CALL,

    /// <summary>Used for rejecting phone calls.</summary>
    EndCall            = SDL_SCANCODE_ENDCALL);

type
  /// <summary>
  ///  The SDL virtual key representation.
  ///
  ///  Values of this type are used to represent keyboard keys using the current
  ///  layout of the keyboard. These values include Unicode values representing
  ///  the unmodified character that would be generated by pressing the key, or an
  ///  TSdlKeycode.* value for those keys that do not generate characters.
  ///
  ///  A special exception is the number keys at the top of the keyboard which map
  ///  to TSdlKeycode._0...TSdlKeycode._9 on AZERTY layouts.
  /// </summary>
  TSdlKeycode = (
    Unknown            = SDLK_UNKNOWN,           // 0
    Return             = SDLK_RETURN,            // '\r'
    Escape             = SDLK_ESCAPE,            // '\x1B'
    Backspace          = SDLK_BACKSPACE,         // '\b'
    Tab                = SDLK_TAB,               // '\t'
    Space              = SDLK_SPACE,             // ' '
    Exclaim            = SDLK_EXCLAIM,           // '!'
    DblApostrophe      = SDLK_DBLAPOSTROPHE,     // '"'
    Hash               = SDLK_HASH,              // '#'
    Dollar             = SDLK_DOLLAR,            // '$'
    Percent            = SDLK_PERCENT,           // '%'
    Ampersand          = SDLK_AMPERSAND,         // '&'
    Apostrophe         = SDLK_APOSTROPHE,        // '\'
    LeftParen          = SDLK_LEFTPAREN,         // '('
    RightParen         = SDLK_RIGHTPAREN,        // ')'
    Asterisk           = SDLK_ASTERISK,          // '*'
    Plus               = SDLK_PLUS,              // '+'
    Comma              = SDLK_COMMA,             // ','
    Minus              = SDLK_MINUS,             // '-'
    Period             = SDLK_PERIOD,            // '.'
    Slash              = SDLK_SLASH,             // '/'
    _0                 = SDLK_0,                 // '0'
    _1                 = SDLK_1,                 // '1'
    _2                 = SDLK_2,                 // '2'
    _3                 = SDLK_3,                 // '3'
    _4                 = SDLK_4,                 // '4'
    _5                 = SDLK_5,                 // '5'
    _6                 = SDLK_6,                 // '6'
    _7                 = SDLK_7,                 // '7'
    _8                 = SDLK_8,                 // '8'
    _9                 = SDLK_9,                 // '9'
    Colon              = SDLK_COLON,             // ':'
    SemiColon          = SDLK_SEMICOLON,         // ';'
    Less               = SDLK_LESS,              // '<'
    Equals             = SDLK_EQUALS,            // '='
    Greater            = SDLK_GREATER,           // '>'
    Question           = SDLK_QUESTION,          // '?'
    At                 = SDLK_AT,                // '@'
    LeftBracket        = SDLK_LEFTBRACKET,       // '['
    Backslash          = SDLK_BACKSLASH,         // '\'
    RightBracket       = SDLK_RIGHTBRACKET,      // ']'
    Caret              = SDLK_CARET,             // '^'
    Underscore         = SDLK_UNDERSCORE,        // '_'
    Grave              = SDLK_GRAVE,             // '`'
    A                  = SDLK_A,                 // 'a'
    B                  = SDLK_B,                 // 'b'
    C                  = SDLK_C,                 // 'c'
    D                  = SDLK_D,                 // 'd'
    E                  = SDLK_E,                 // 'e'
    F                  = SDLK_F,                 // 'f'
    G                  = SDLK_G,                 // 'g'
    H                  = SDLK_H,                 // 'h'
    I                  = SDLK_I,                 // 'i'
    J                  = SDLK_J,                 // 'j'
    K                  = SDLK_K,                 // 'k'
    L                  = SDLK_L,                 // 'l'
    M                  = SDLK_M,                 // 'm'
    N                  = SDLK_N,                 // 'n'
    O                  = SDLK_O,                 // 'o'
    P                  = SDLK_P,                 // 'p'
    Q                  = SDLK_Q,                 // 'q'
    R                  = SDLK_R,                 // 'r'
    S                  = SDLK_S,                 // 's'
    T                  = SDLK_T,                 // 't'
    U                  = SDLK_U,                 // 'u'
    V                  = SDLK_V,                 // 'v'
    W                  = SDLK_W,                 // 'w'
    X                  = SDLK_X,                 // 'x'
    Y                  = SDLK_Y,                 // 'y'
    Z                  = SDLK_Z,                 // 'z'
    LeftBrace          = SDLK_LEFTBRACE,         // '{'
    Pipe               = SDLK_PIPE,              // '|'
    RightBrace         = SDLK_RIGHTBRACE,        // '}'
    Tilde              = SDLK_TILDE,             // '~'
    Delete             = SDLK_DELETE,            // '\x7F'
    PlusMinus          = SDLK_PLUSMINUS,         // '\xB1'
    CapsLock           = SDLK_CAPSLOCK,
    F1                 = SDLK_F1,
    F2                 = SDLK_F2,
    F3                 = SDLK_F3,
    F4                 = SDLK_F4,
    F5                 = SDLK_F5,
    F6                 = SDLK_F6,
    F7                 = SDLK_F7,
    F8                 = SDLK_F8,
    F9                 = SDLK_F9,
    F10                = SDLK_F10,
    F11                = SDLK_F11,
    F12                = SDLK_F12,
    PrintScreen        = SDLK_PRINTSCREEN,
    ScrollLock         = SDLK_SCROLLLOCK,
    Pause              = SDLK_PAUSE,
    Insert             = SDLK_INSERT,
    Home               = SDLK_HOME,
    PageUp             = SDLK_PAGEUP,
    &End               = SDLK_END,
    PageDown           = SDLK_PAGEDOWN,
    Right              = SDLK_RIGHT,
    Left               = SDLK_LEFT,
    Down               = SDLK_DOWN,
    Up                 = SDLK_UP,
    NumLockClear       = SDLK_NUMLOCKCLEAR,
    KPDivide           = SDLK_KP_DIVIDE,
    KPMultiply         = SDLK_KP_MULTIPLY,
    KPMinus            = SDLK_KP_MINUS,
    KPPlus             = SDLK_KP_PLUS,
    KPEnter            = SDLK_KP_ENTER,
    KP1                = SDLK_KP_1,
    KP2                = SDLK_KP_2,
    KP3                = SDLK_KP_3,
    KP4                = SDLK_KP_4,
    KP5                = SDLK_KP_5,
    KP6                = SDLK_KP_6,
    KP7                = SDLK_KP_7,
    KP8                = SDLK_KP_8,
    KP9                = SDLK_KP_9,
    KP0                = SDLK_KP_0,
    KPPeriod           = SDLK_KP_PERIOD,
    Application        = SDLK_APPLICATION,
    Power              = SDLK_POWER,
    KPEquals           = SDLK_KP_EQUALS,
    F13                = SDLK_F13,
    F14                = SDLK_F14,
    F15                = SDLK_F15,
    F16                = SDLK_F16,
    F17                = SDLK_F17,
    F18                = SDLK_F18,
    F19                = SDLK_F19,
    F20                = SDLK_F20,
    F21                = SDLK_F21,
    F22                = SDLK_F22,
    F23                = SDLK_F23,
    F24                = SDLK_F24,
    Execute            = SDLK_EXECUTE,
    Help               = SDLK_HELP,
    Menu               = SDLK_MENU,
    Select             = SDLK_SELECT,
    Stop               = SDLK_STOP,
    Again              = SDLK_AGAIN,
    Undo               = SDLK_UNDO,
    Cut                = SDLK_CUT,
    Copy               = SDLK_COPY,
    Paste              = SDLK_PASTE,
    Find               = SDLK_FIND,
    Mute               = SDLK_MUTE,
    VolumeUp           = SDLK_VOLUMEUP,
    VolumeDown         = SDLK_VOLUMEDOWN,
    KPComma            = SDLK_KP_COMMA,
    KPEqualsAS400      = SDLK_KP_EQUALSAS400,
    AltErase           = SDLK_ALTERASE,
    SysReq             = SDLK_SYSREQ,
    Cancel             = SDLK_CANCEL,
    Clear              = SDLK_CLEAR,
    Prior              = SDLK_PRIOR,
    Return2            = SDLK_RETURN2,
    Separator          = SDLK_SEPARATOR,
    &Out               = SDLK_OUT,
    Oper               = SDLK_OPER,
    ClearAgain         = SDLK_CLEARAGAIN,
    CRSel              = SDLK_CRSEL,
    EXSel              = SDLK_EXSEL,
    KP00               = SDLK_KP_00,
    KP000              = SDLK_KP_000,
    ThousandsSeparator = SDLK_THOUSANDSSEPARATOR,
    DecimalSeparator   = SDLK_DECIMALSEPARATOR,
    CurrencyUnit       = SDLK_CURRENCYUNIT,
    CurrencySubUnit    = SDLK_CURRENCYSUBUNIT,
    KPLeftParen        = SDLK_KP_LEFTPAREN,
    KPRightParen       = SDLK_KP_RIGHTPAREN,
    KPLeftBrace        = SDLK_KP_LEFTBRACE,
    KPRightBrace       = SDLK_KP_RIGHTBRACE,
    KPTab              = SDLK_KP_TAB,
    KPBackspace        = SDLK_KP_BACKSPACE,
    KPA                = SDLK_KP_A,
    KPB                = SDLK_KP_B,
    KPC                = SDLK_KP_C,
    KPD                = SDLK_KP_D,
    KPE                = SDLK_KP_E,
    KPF                = SDLK_KP_F,
    KPXor              = SDLK_KP_XOR,
    KPPower            = SDLK_KP_POWER,
    KPPercent          = SDLK_KP_PERCENT,
    KPLess             = SDLK_KP_LESS,
    KPGreater          = SDLK_KP_GREATER,
    KPAmpersand        = SDLK_KP_AMPERSAND,
    KPDblAmpersand     = SDLK_KP_DBLAMPERSAND,
    KPVerticalBar      = SDLK_KP_VERTICALBAR,
    KPDblVerticalBar   = SDLK_KP_DBLVERTICALBAR,
    KPColon            = SDLK_KP_COLON,
    KPHash             = SDLK_KP_HASH,
    KPSpace            = SDLK_KP_SPACE,
    KPAt               = SDLK_KP_AT,
    KPExclam           = SDLK_KP_EXCLAM,
    KPMemStore         = SDLK_KP_MEMSTORE,
    KPMemRecall        = SDLK_KP_MEMRECALL,
    KPMemClear         = SDLK_KP_MEMCLEAR,
    KPMemAdd           = SDLK_KP_MEMADD,
    KPMemSubtract      = SDLK_KP_MEMSUBTRACT,
    KPMemMultiply      = SDLK_KP_MEMMULTIPLY,
    KPMemDivide        = SDLK_KP_MEMDIVIDE,
    KPPlusMinus        = SDLK_KP_PLUSMINUS,
    KPClear            = SDLK_KP_CLEAR,
    KPClearEntry       = SDLK_KP_CLEARENTRY,
    KPBinary           = SDLK_KP_BINARY,
    KP_OCTAL           = SDLK_KP_OCTAL,
    KP_DECIMAL         = SDLK_KP_DECIMAL,
    KP_HEXADECIMAL     = SDLK_KP_HEXADECIMAL,
    LCtrl              = SDLK_LCTRL,
    LShift             = SDLK_LSHIFT,
    LAlt               = SDLK_LALT,
    LGui               = SDLK_LGUI,
    RCtrl              = SDLK_RCTRL,
    RShift             = SDLK_RSHIFT,
    RAlt               = SDLK_RALT,
    RGui               = SDLK_RGUI,
    Mode               = SDLK_MODE,
    Sleep              = SDLK_SLEEP,
    Wake               = SDLK_WAKE,
    ChannelIncremenet  = SDLK_CHANNEL_INCREMENT,
    ChannelDecremenet  = SDLK_CHANNEL_DECREMENT,
    MediaPlay          = SDLK_MEDIA_PLAY,
    MediaPause         = SDLK_MEDIA_PAUSE,
    MediaRecord        = SDLK_MEDIA_RECORD,
    MediaFastForward   = SDLK_MEDIA_FAST_FORWARD,
    MediaRewind        = SDLK_MEDIA_REWIND,
    MediaNextTrack     = SDLK_MEDIA_NEXT_TRACK,
    MediaPreviousTrack = SDLK_MEDIA_PREVIOUS_TRACK,
    MediaStop          = SDLK_MEDIA_STOP,
    MediaEject         = SDLK_MEDIA_EJECT,
    MediaPlayPause     = SDLK_MEDIA_PLAY_PAUSE,
    MediaSelect        = SDLK_MEDIA_SELECT,
    ACNew              = SDLK_AC_NEW,
    ACOpen             = SDLK_AC_OPEN,
    ACClose            = SDLK_AC_CLOSE,
    ACExit             = SDLK_AC_EXIT,
    ACSave             = SDLK_AC_SAVE,
    ACPrint            = SDLK_AC_PRINT,
    ACProperties       = SDLK_AC_PROPERTIES,
    ACSearch           = SDLK_AC_SEARCH,
    ACHome             = SDLK_AC_HOME,
    ACBack             = SDLK_AC_BACK,
    ACForward          = SDLK_AC_FORWARD,
    ACStop             = SDLK_AC_STOP,
    ACRefresh          = SDLK_AC_REFRESH,
    ACBookmarks        = SDLK_AC_BOOKMARKS,
    SoftLeft           = SDLK_SOFTLEFT,
    SoftRight          = SDLK_SOFTRIGHT,
    Call               = SDLK_CALL,
    EndCall            = SDLK_ENDCALL,
    LeftTab            = SDLK_LEFT_TAB,          // Extended key Left Tab
    Level5Shift        = SDLK_LEVEL5_SHIFT,      // Extended key Level 5 Shift
    MultiKeyCompose    = SDLK_MULTI_KEY_COMPOSE, // Extended key Multi-key Compose
    LMeta              = SDLK_LMETA,             // Extended key Left Meta
    RMeta              = SDLK_RMETA,             // Extended key Right Meta
    LHyper             = SDLK_LHYPER,            // Extended key Left Hyper
    RHyper             = SDLK_RHYPER);           // Extended key Right Hyper

type
  /// <summary>
  ///  Valid key modifiers.
  /// </summary>
  TSdlKeyMod = (
    LShift = 0,   // The left Shift key is down.
    RShift = 1,   // The right Shift key is down.
    Level5 = 2,   // The Level 5 Shift key is down.
    LCtrl  = 6,   // The left Ctrl (Control) key is down.
    RCtrl  = 7,   // The right Ctrl (Control) key is down.
    LAtl   = 8,   // The left Alt key is down.
    RAlt   = 9,   // The right Alt key is down.
    LGui   = 10,  // The left GUI key (often the Windows key) is down.
    RGui   = 11,  // The right GUI key (often the Windows key) is down.
    Num    = 12,  // The Num Lock key (may be located on an extended keypad) is down.
    Caps   = 13,  // The Caps Lock key is down.
    Mode   = 14,  // The !AltGr key is down.
    Scroll = 15); // The Scroll Lock key is down.

  /// <summary>
  ///  A set of valid key modifiers.
  /// </summary>
  TSdlKeyMods = set of TSdlKeyMod;

type
  _TSdlKeycodeHelper = record helper for TSdlKeycode
  {$REGION 'Internal Declarations'}
  private
    function GetName: String; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Creates a TSdlKeycode from a TSdlScancode.
    /// </summary>
    /// <param name="AScancode">The scan code to convert.</param>
    /// <returns>The keycode for this scancode.</returns>
    class function FromScancode(const AScancode: TSdlScancode): TSdlKeycode; overload; inline; static;

    /// <summary>
    ///  Get the key code corresponding to the given scancode according to the
    ///  current keyboard layout.
    ///
    ///  If you want to get the keycode as it would be delivered in key events,
    ///  including options specified in TSdlHints.KeycodeOptions, then you should
    ///  pass `AKeyEvent` as True. Otherwise this function simply translates the
    ///  scancode based on the given modifier state.
    /// </summary>
    /// <param name="AScancode">The desired scancode to query.</param>
    /// <param name="AModState">The modifier state to use when translating the
    ///  scancode to a keycode.</param>
    /// <param name="AKeyEvent">True if the keycode will be used in key events.</param>
    /// <returns>The keycode that corresponds to the given scancode.</returns>
    /// <seealso cref="Name"/>
    /// <seealso cref="TSdlScancode.FromKeycode"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    class function FromScancode(const AScancode: TSdlScancode;
      const AModState: TSdlKeymods; const AKeyEvent: Boolean): TSdlKeycode; overload; inline; static;

    /// <summary>
    ///  Get a keycode from a human-readable name.
    /// </summary>
    /// <param name="AName">The human-readable key name.</param>
    /// <returns>The keycode, or `TSdlKeycode.Unknown` if the name wasn't
    ///  recognized.</returns>
    /// <seealso cref="FromScancode"/>
    /// <seealso cref="Name"/>
    /// <seealso cref="TSdlScancode.FromName"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    class function FromName(const AName: String): TSdlKeycode; inline; static;

    /// <summary>
    ///  Get the scancode corresponding to this key code according to the
    ///  current keyboard layout.
    /// </summary>
    /// <returns>The scancode that corresponds to the given keycode.</returns>
    /// <seealso cref="FromScancode"/>
    /// <seealso cref="TSdlScancode.Name"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ToScancode: TSdlScancode; overload; inline;

    /// <summary>
    ///  Get the scancode corresponding to this key code according to the
    ///  current keyboard layout.
    ///
    ///  Note that there may be multiple scancode+modifier states that can generate
    ///  this keycode, this will just return the first one found.
    /// </summary>
    /// <param name="AModState">The modifier state that would be used when the
    ///  scancode generates this key.</param>
    /// <returns>The scancode that corresponds to the given keycode.</returns>
    /// <seealso cref="FromScancode"/>
    /// <seealso cref="TSdlScancode.Name"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ToScancode(const AModState: TSdlKeyMods): TSdlScancode; overload; inline;

    /// <summary>
    ///  A human-readable name for the key.
    ///
    ///  If the key doesn't have a name, this property returns an empty string.
    ///
    ///  Letters will be presented in their uppercase form, if applicable.
    /// </summary>
    /// <seealso cref="FromName"/>
    /// <seealso cref="FromScancode"/>
    /// <seealso cref="TSdlScancode.FromKeycode"/>
    /// <remarks>
    ///  This property is not thread safe.
    /// </remarks>
    property Name: String read GetName;
  end;

type
  _TSdlScancodeHelper = record helper for TSdlScancode
  {$REGION 'Internal Declarations'}
  private
    function GetName: String; inline;
    procedure SetName(const AValue: String); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Converts the scancode to a TSdlKeycode.
    /// </summary>
    /// <returns>The keycode for this scancode.</returns>
    function ToKeycode: TSdlKeycode; overload; inline;

    /// <summary>
    ///  Get the key code corresponding to this scancode according to the
    ///  current keyboard layout.
    ///
    ///  If you want to get the keycode as it would be delivered in key events,
    ///  including options specified in TSdlHints.KeycodeOptions, then you should
    ///  pass `AKeyEvent` as True. Otherwise this function simply translates the
    ///  scancode based on the given modifier state.
    /// </summary>
    /// <param name="AModState">The modifier state to use when translating the
    ///  scancode to a keycode.</param>
    /// <param name="AKeyEvent">True if the keycode will be used in key events.</param>
    /// <returns>The keycode that corresponds to the given scancode.</returns>
    /// <seealso cref="TSdlKeycode.Name"/>
    /// <seealso cref="TSdlScancode.FromKeycode"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    function ToKeycode(const AModState: TSdlKeymods;
      const AKeyEvent: Boolean): TSdlKeycode; overload; inline;

    /// <summary>
    ///  Get the scancode corresponding to the given key code according to the
    ///  current keyboard layout.
    /// </summary>
    /// <param name="AKey">The desired keycode to query.</param>
    /// <returns>The scancode that corresponds to the given keycode.</returns>
    /// <seealso cref="TSdlKeycode.FromScancode"/>
    /// <seealso cref="Name"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    class function FromKeycode(const AKey: TSdlKeycode): TSdlScancode; overload; inline; static;

    /// <summary>
    ///  Get the scancode corresponding to the given key code according to the
    ///  current keyboard layout.
    ///
    ///  Note that there may be multiple scancode+modifier states that can generate
    ///  this keycode, this will just return the first one found.
    /// </summary>
    /// <param name="AKey">The desired keycode to query.</param>
    /// <param name="AModState">The modifier state that would be used when the
    ///  scancode generates this key.</param>
    /// <returns>The scancode that corresponds to the given keycode.</returns>
    /// <seealso cref="TSdlKeycode.FromScancode"/>
    /// <seealso cref="Name"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    class function FromKeycode(const AKey: TSdlKeycode;
      const AModState: TSdlKeyMods): TSdlScancode; overload; inline; static;

    /// <summary>
    ///  Get a scancode from a human-readable name.
    /// </summary>
    /// <param name="AName">The human-readable scancode name.</param>
    /// <returns>The scancode, or `TSdlScancode.Unknown` if the name wasn't
    ///  recognized.</returns>
    /// <seealso cref="TSdlKeycode.FromName"/>
    /// <seealso cref="FromKeycode"/>
    /// <seealso cref="Name"/>
    /// <remarks>
    ///  This method is not thread safe.
    /// </remarks>
    class function FromName(const AName: String): TSdlScancode; inline; static;

    /// <summary>
    ///  A human-readable name for the scancode.
    ///
    ///  **Warning**: The returned name is by design not stable across platforms,
    ///  e.g. the name for `TSdlScancode.LGui` is 'Left GUI' under Linux but 'Left
    ///  Windows' under Microsoft Windows, and some scancodes like
    ///  `TSdlScancode.NonUSBackslash` don't have any name at all. There are even
    ///  scancodes that share names, e.g. `TSdlScancode.Return` and
    ///  `TSdlScancode.Return2` (both called 'Return'). This property is therefore
    ///  unsuitable for creating a stable cross-platform two-way mapping between
    ///  strings and scancodes.
    ///
    ///  You can also set this property to a different name.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="FromKeycode"/>
    /// <seealso cref="FromName"/>
    /// <remarks>
    ///  This property is not thread safe.
    /// </remarks>
    property Name: String read GetName write SetName;
  end;

type
  /// <summary>
  ///  The state of a keyboard.
  /// </summary>
  TSdlKeyboardState = record
  {$REGION 'Internal Declarations'}
  private
    FState: PBoolean;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Whether a key with the given scancode is currently pressed.
    /// </summary>
    /// <param name="AScancode">The scancode to check.</param>
    /// <returns>True if the key is pressed, False otherwise.</returns>
    function IsPressed(const AScancode: TSdlScancode): Boolean; inline;
  end;

type
  /// <summary>
  ///  Represents a keyboard.
  /// </summary>
  TSdlKeyboard = record
  {$REGION 'Internal Declarations'}
  private class var
    FKeyCount: Cardinal;
  private
    FHandle: SDL_KeyboardID;
    function GetName: String; inline;
    class function GetHasKeyboard: Boolean; inline; static;
    class function GetKeyboards: TArray<TSdlKeyboard>; static;
    class function GetFocus: TSdlWindow; inline; static;
    class function GetState: TSdlKeyboardState; inline; static;
    class function GetModState: TSdlKeyMods; inline; static;
    class procedure SetModState(const AValue: TSdlKeyMods); inline; static;
    class function GetHasScreenKeyboardSupport: Boolean; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlKeyboard; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlKeyboard.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlKeyboard): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlKeyboard; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlKeyboard.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlKeyboard): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlKeyboard; inline; static;
  public
    /// <summary>
    ///  Clear the state of the keyboard.
    ///
    ///  This method will generate key up events for all pressed keys.
    /// </summary>
    /// <seealso cref="State"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure Reset; inline; static;

    /// <summary>
    ///  The name of the keyboard.
    ///
    ///  Returns an empty string if the keyboard doesn't have a name.
    /// </summary>
    /// <seealso cref="Keyboards"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  Whether a keyboard is currently connected.
    /// </summary>
    /// <seealso cref="Keyboards"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property HasKeyboard: Boolean read GetHasKeyboard;

    /// <summary>
    ///  A list of currently connected keyboards.
    ///
    ///  Note that this will include any device or virtual driver that includes
    ///  keyboard functionality, including some mice, KVM switches, motherboard
    ///  power buttons, etc. You should wait for input from a device before you
    ///  consider it actively in use.
    /// </summary>
    /// <seealso cref="Name"/>
    /// <seealso cref="HasKeyboard"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Keyboards: TArray<TSdlKeyboard> read GetKeyboards;

    /// <summary>
    ///  The window which currently has keyboard focus.
    /// </summary>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Focus: TSdlWindow read GetFocus;

    /// <summary>
    ///  Get a snapshot of the current state of the keyboard.
    ///
    ///  TSdlEvents.Pump to update the state array.
    ///
    ///  This property gives you the current state after all events have been
    ///  processed, so if a key or button has been pressed and released before you
    ///  process events, then the pressed state will never show up in this property.
    ///
    ///  Note: This property doesn't take into account whether shift has been
    ///  pressed or not.
    /// </summary>
    /// <seealso cref="TSdlEvents.Pump"/>
    /// <seealso cref="Reset"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property State: TSdlKeyboardState read GetState;

    /// <summary>
    ///  The current key modifier state for the keyboard.
    ///
    ///  You can also set this state. This allows you to impose modifier key
    ///  states on your application. This does not change the keyboard state,
    ///  only the key modifier flags that SDL reports.
    /// </summary>
    /// <seealso cref="State"/>
    /// <remarks>
    ///  It is safe to use this property from any thread.
    /// </remarks>
    class property ModState: TSdlKeyMods read GetModState write SetModState;

    /// <summary>
    ///  Whether the platform has screen keyboard support.
    /// </summary>
    /// <seealso cref="TSdlWindow.StartTextInput"/>
    /// <seealso cref="TSdlWindow.IsScreenKeyboardShown"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property HasScreenKeyboardSupport: Boolean read GetHasScreenKeyboardSupport;
  end;
{$ENDREGION 'Keyboard'}

{$REGION 'Mouse'}
/// <summary>
///  Any GUI application has to deal with the mouse, and SDL provides functions
///  to manage mouse input and the displayed cursor.
///
///  Most interactions with the mouse will come through the event subsystem.
///  Moving a mouse generates an TSdlEventKind.MouseMotion event, pushing a button
///  generates TSdlEventKind.MouseButtonDown, etc, but one can also query the
///  current state of the mouse at any time with TSdlMouse.GetState.
///
///  For certain games, it's useful to disassociate the mouse cursor from mouse
///  input. An FPS, for example, would not want the player's motion to stop as
///  the mouse hits the edge of the window. For these scenarios, use
///  TSdlWindow.RelativeMouseMode, which hides the cursor, grabs mouse input
///  to the window, and reads mouse input no matter how far it moves.
///
///  Games that want the system to track the mouse but want to draw their own
///  cursor can use TSdlCursor.Hide and TSdlCursor.Show. It might be more
///  efficient to let the system manage the cursor, if possible, using
///  TSdlCursor.Active with a custom image made through TSdlCursor.Create.
///
///  SDL can, on many platforms, differentiate between multiple connected mice,
///  allowing for interesting input scenarios and multiplayer games. They can be
///  enumerated with TSdlMouse.Mice, and SDL will send TSdlEventKind.MouseAdded and
///  TSdlEventKind.MouseRemoved events as they are connected and unplugged.
///
///  Since many apps only care about basic mouse input, SDL offers a virtual
///  mouse device for touch and pen input, which often can make a desktop
///  application work on a touchscreen phone without any code changes. Apps that
///  care about touch/pen separately from mouse input should filter out events
///  with a `Mouse` field of TSdlMouse.Touch/TSdlMouse.Pen.
/// </summary>

type
  /// <summary>
  ///  Cursor types for TSdlCursor.Create.
  /// </summary>
  TSdlSystemCursor = (
    /// <summary>
    ///  Default cursor. Usually an arrow.
    /// </summary>
    Default    = SDL_SYSTEM_CURSOR_DEFAULT,

    /// <summary>
    ///  Text selection. Usually an I-beam.
    /// </summary>
    Text       = SDL_SYSTEM_CURSOR_TEXT,

    /// <summary>
    ///  Wait. Usually an hourglass or watch or spinning ball.
    /// </summary>
    Wait       = SDL_SYSTEM_CURSOR_WAIT,

    /// <summary>
    ///  Crosshair.
    /// </summary>
    Crosshair  = SDL_SYSTEM_CURSOR_CROSSHAIR,

    /// <summary>
    ///  Program is busy but still interactive. Usually it's WAIT with an arrow.
    /// </summary>
    Progress   = SDL_SYSTEM_CURSOR_PROGRESS,

    /// <summary>
    ///  Double arrow pointing northwest and southeast.
    /// </summary>
    NwseResize = SDL_SYSTEM_CURSOR_NWSE_RESIZE,

    /// <summary>
    ///  Double arrow pointing northeast and southwest.
    /// </summary>
    NeswResize = SDL_SYSTEM_CURSOR_NESW_RESIZE,

    /// <summary>
    ///  Double arrow pointing west and east.
    /// </summary>
    EWResize   = SDL_SYSTEM_CURSOR_EW_RESIZE,

    /// <summary>
    ///  Double arrow pointing north and south.
    /// </summary>
    NSResize   = SDL_SYSTEM_CURSOR_NS_RESIZE,

    /// <summary>
    ///  Four pointed arrow pointing north, south, east, and west.
    /// </summary>
    Move       = SDL_SYSTEM_CURSOR_MOVE,

    /// <summary>
    ///  Not permitted. Usually a slashed circle or crossbones.
    /// </summary>
    NotAllowed = SDL_SYSTEM_CURSOR_NOT_ALLOWED,

    /// <summary>
    ///  Pointer that indicates a link. Usually a pointing hand.
    /// </summary>
    Pointer    = SDL_SYSTEM_CURSOR_POINTER,

    /// <summary>
    ///  Window resize top-left. This may be a single arrow or a double arrow
    ///  like NwseResize.
    /// </summary>
    NWResize   = SDL_SYSTEM_CURSOR_NW_RESIZE,

    /// <summary>
    ///  Window resize top. May be NSResize
    /// </summary>
    NResize    = SDL_SYSTEM_CURSOR_N_RESIZE,

    /// <summary>
    ///  Window resize top-right. May be NeswResize.
    /// </summary>
    NEResize   = SDL_SYSTEM_CURSOR_NE_RESIZE,

    /// <summary>
    ///  Window resize right. May be EWResize.
    /// </summary>
    EResize    = SDL_SYSTEM_CURSOR_E_RESIZE,

    /// <summary>
    ///  Window resize bottom-right. May be NwseResize.
    /// </summary>
    SERezize   = SDL_SYSTEM_CURSOR_SE_RESIZE,

    /// <summary>
    ///  Window resize bottom. May be NSResize.
    /// </summary>
    SResize    = SDL_SYSTEM_CURSOR_S_RESIZE,

    /// <summary>
    ///  Window resize bottom-left. May be NeswResize.
    /// </summary>
    SWResize   = SDL_SYSTEM_CURSOR_SW_RESIZE,

    /// <summary>
    ///  Window resize left. May be EWResize.
    /// </summary>
    WResize    = SDL_SYSTEM_CURSOR_W_RESIZE);

type
  /// <summary>
  ///  The structure used to identify an SDL cursor.
  ///
  ///  This is opaque data.
  /// </summary>
  /// <remarks>
  ///  This struct is available since SDL 3.2.0.
  /// </remarks>
  TSdlCursor = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Cursor;
    class function GetIsVisible: Boolean; inline; static;
    class procedure SetIsVisible(const AValue: Boolean); inline; static;
    class function GetActive: TSdlCursor; inline; static;
    class procedure SetActive(const AValue: TSdlCursor); inline; static;
    class function GetDefault: TSdlCursor; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlCursor; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCursor.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlCursor): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlCursor; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlCursor.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlCursor): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlCursor; inline; static;
  public
    /// <summary>
    ///  Create a cursor using the specified bitmap data and mask (in MSB format).
    ///
    ///  `AMask` has to be in MSB (Most Significant Bit) format.
    ///
    ///  The cursor width (`AW`) must be a multiple of 8 bits.
    ///
    ///  The cursor is created in black and white according to the following:
    ///
    ///  - AData=0, AMask=1: white
    ///  - AData=1, AMask=1: black
    ///  - AData=0, AMask=0: transparent
    ///  - AData=1, AMask=0: inverted color if possible, black if not.
    ///
    ///  Cursors created with this function must be freed with Free.
    ///
    ///  If you want to have a color cursor, or create your cursor from an
    ///  SDL_Surface, you should use another constructor. Alternately, you can
    ///  hide the cursor and draw your own as part of your game's rendering, but it
    ///  will be bound to the framerate.
    ///
    ///  There is also a constructor that creates a system cursor, which provides
    ///  several readily-available system cursors to pick from.
    /// </summary>
    /// <param name="AData">The color value for each pixel of the cursor.</param>
    /// <param name="AMask">The mask value for each pixel of the cursor.</param>
    /// <param name="AW">The width of the cursor.</param>
    /// <param name="AH">The height of the cursor.</param>
    /// <param name="AHotX">The X-axis offset from the left of the cursor image
    ///  to the mouse X position, in the range of 0 to `AW` - 1.</param>
    /// <param name="AHotY">The Y-axis offset from the top of the cursor image
    ///  to the mouse Y position, in the range of 0 to `AH` - 1.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Active"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const AData, AMask: Pointer; const AW, AH, AHotX,
      AHotY: Integer); overload;

    /// <summary>
    ///  Create a color cursor.
    ///
    ///  If this constructor is passed a surface with alternate representations, the
    ///  surface will be interpreted as the content to be used for 100% display
    ///  scale, and the alternate representations will be used for high DPI
    ///  situations. For example, if the original surface is 32x32, then on a 2x
    ///  macOS display or 200% display scale on Windows, a 64x64 version of the
    ///  image will be used, if available. If a matching version of the image isn't
    ///  available, the closest larger size image will be downscaled to the
    ///  appropriate size and be used instead, if available. Otherwise, the closest
    ///  smaller image will be upscaled and be used instead.
    /// </summary>
    /// <param name="ASurface">An SDL surface representing the cursor image.</param>
    /// <param name="AHotX">The X position of the cursor hot spot.</param>
    /// <param name="AHotY">The Y position of the cursor hot spot.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <seealso cref="Active"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const ASurface: TSdlSurface; const AHotX, AHotY: Integer); overload;

    /// <summary>
    ///  Create a system cursor.
    /// </summary>
    /// <param name="ASystemCursor">The TSdlSystemCursor enum value.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Free"/>
    /// <remarks>
    ///  This constructor should only be called on the main thread.
    /// </remarks>
    constructor Create(const ASystemCursor: TSdlSystemCursor); overload;

    /// <summary>
    ///  Free a previously-created cursor.
    /// </summary>
    /// <seealso cref="Create"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure Free; inline;

    /// <summary>
    ///  Show the cursor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsVisible"/>
    /// <seealso cref="Hide"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure Show; inline; static;

    /// <summary>
    ///  Hide the cursor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="IsVisible"/>
    /// <seealso cref="Show"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure Hide; inline; static;

    /// <summary>
    ///  Whether the cursor is currently being shown.
    ///
    ///  Setting this property is equivalent to calling Show or Hide.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Hide"/>
    /// <seealso cref="Show"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property IsVisible: Boolean read GetIsVisible write SetIsVisible;

    /// <summary>
    ///  The active cursor.
    ///
    ///  Allows you to set the currently active cursor to the specified one. If the
    ///  cursor is currently visible, the change will be immediately represented on
    ///  the display. You can set this properyt to nil to force cursor redraw, if
    ///  this is desired for any reason.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Active: TSdlCursor read GetActive write SetActive;

    /// <summary>
    ///  The default cursor.
    ///
    ///  You do not have to call Free on this cursor, but it is safe to do so.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Default: TSdlCursor read GetDefault;
  end;

type
  /// <summary>
  ///  Pressed mouse buttons, as reported by TSdlMouse.GetPressedButtons, etc.
  ///
  ///  - Button 0: Left mouse button
  ///  - Button 1: Middle mouse button
  ///  - Button 2: Right mouse button
  ///  - Button 3: Side mouse button 1
  ///  - Button 4: Side mouse button 2
  /// </summary>
  /// <seealso cref="TSdlMouse.GetState"/>
  /// <seealso cref="TSdlMouse.GetGlobalState"/>
  /// <seealso cref="TSdlMouse.GetRelativeState"/>
  TSdlMouseButton = (
    Left   = SDL_BUTTON_LEFT - 1,
    Middle = SDL_BUTTON_MIDDLE - 1,
    Right  = SDL_BUTTON_RIGHT  - 1,
    X1     = SDL_BUTTON_X1 - 1,
    X2     = SDL_BUTTON_X2 - 1);

  /// <summary>
  ///  A set of mouse buttons.
  /// </summary>
  TSdlMouseButtons = set of TSdlMouseButton;

type
  /// <summary>
  ///  Scroll direction types for the Scroll event
  /// </summary>
  TSdlMouseWheelDirection = (
    /// <summary>The scroll direction is normal</summary>
    Normal  = SDL_MOUSEWHEEL_NORMAL,

    /// <summary>The scroll direction is flipped / natural</summary>
    Flipped = SDL_MOUSEWHEEL_FLIPPED);

type
  /// <summary>
  ///  A mouse
  /// </summary>
  TSdlMouse = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_MouseID;
    function GetName: String; inline;
    class function GetTouch: TSdlMouse; inline; static;
    class function GetPen: TSdlMouse; inline; static;
    class function GetHasMouse: Boolean; inline; static;
    class function GetMice: TArray<TSdlMouse>; static;
    class function GetFocus: TSdlWindow; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlMouse; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlMouse.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlMouse): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlMouse; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlMouse.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlMouse): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlMouse; inline; static;
  public
    /// <summary>
    ///  Query SDL's cache for the synchronous mouse button state and the
    ///  window-relative SDL-cursor position.
    ///
    ///  This method returns the cached synchronous state as SDL understands it
    ///  from the last pump of the event queue.
    ///
    ///  To query the platform for immediate asynchronous state, use
    ///  GetGlobalState.
    ///
    ///  In Relative Mode, the SDL-cursor's position usually contradicts the
    ///  platform-cursor's position as manually calculated from
    ///  GetGlobalState and TSdlWindow.Position.
    /// </summary>
    /// <param name="AX">Is set to the SDL-cursor's X-position from the focused
    ///  window's top left corner.</param>
    /// <param name="AY">Is set to the SDL-cursor's Y-position from the focused
    ///  window's top left corner.</param>
    /// <returns>The mouse buttons that are pressed.</returns>
    /// <seealso cref="GetGlobalState"/>
    /// <seealso cref="GetRelativeState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function GetState(out AX, AY: Single): TSdlMouseButtons; overload; inline;

    /// <summary>
    ///  Query SDL's cache for the synchronous mouse button state and the
    ///  window-relative SDL-cursor position.
    ///
    ///  This method returns the cached synchronous state as SDL understands it
    ///  from the last pump of the event queue.
    ///
    ///  To query the platform for immediate asynchronous state, use
    ///  GetGlobalState.
    ///
    ///  In Relative Mode, the SDL-cursor's position usually contradicts the
    ///  platform-cursor's position as manually calculated from
    ///  GetGlobalState and TSdlWindow.Position.
    /// </summary>
    /// <param name="APosition">Is set to the SDL-cursor's position from the
    ///  focused window's top left corner.</param>
    /// <returns>The mouse buttons that are pressed.</returns>
    /// <seealso cref="GetGlobalState"/>
    /// <seealso cref="GetRelativeState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function GetState(out APosition: TSdlPointF): TSdlMouseButtons; overload; inline;

    /// <summary>
    ///  Query the platform for the asynchronous mouse button state and the
    ///  desktop-relative platform-cursor position.
    ///
    ///  This method immediately queries the platform for the most recent
    ///  asynchronous state, more costly than retrieving SDL's cached state in
    ///  GetState.
    ///
    ///  In Relative Mode, the platform-cursor's position usually contradicts the
    ///  SDL-cursor's position as manually calculated from GetState and
    ///  TSdlWindow.Position.
    ///
    ///  This method can be useful if you need to track the mouse outside of a
    ///  specific window and Capture doesn't fit your needs. For example,
    ///  it could be useful if you need to track the mouse while dragging a window,
    ///  where coordinates relative to a window might not be in sync at all times.
    /// </summary>
    /// <param name="AX">Is set to the platform-cursor's X-position from the
    ///  desktop's top left corner.</param>
    /// <param name="AX">Is set to the platform-cursor's Y-position from the
    ///  desktop's top left corner.</param>
    /// <returns>The mouse buttons that are pressed.</returns>
    /// <seealso cref="Capture"/>
    /// <seealso cref="GetState"/>
    /// <seealso cref="GetRelativeState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function GetGlobalState(out AX, AY: Single): TSdlMouseButtons; overload; inline;

    /// <summary>
    ///  Query the platform for the asynchronous mouse button state and the
    ///  desktop-relative platform-cursor position.
    ///
    ///  This method immediately queries the platform for the most recent
    ///  asynchronous state, more costly than retrieving SDL's cached state in
    ///  GetState.
    ///
    ///  In Relative Mode, the platform-cursor's position usually contradicts the
    ///  SDL-cursor's position as manually calculated from GetState and
    ///  TSdlWindow.Position.
    ///
    ///  This method can be useful if you need to track the mouse outside of a
    ///  specific window and Capture doesn't fit your needs. For example,
    ///  it could be useful if you need to track the mouse while dragging a window,
    ///  where coordinates relative to a window might not be in sync at all times.
    /// </summary>
    /// <param name="APosition">Is set to the platform-cursor's position from the
    ///  desktop's top left corner.</param>
    /// <returns>The mouse buttons that are pressed.</returns>
    /// <seealso cref="Capture"/>
    /// <seealso cref="GetState"/>
    /// <seealso cref="GetRelativeState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function GetGlobalState(out APosition: TSdlPointF): TSdlMouseButtons; overload; inline;

    /// <summary>
    ///  Query SDL's cache for the synchronous mouse button state and accumulated
    ///  mouse delta since last call.
    ///
    ///  This method returns the cached synchronous state as SDL understands it
    ///  from the last pump of the event queue.
    ///
    ///  To query the platform for immediate asynchronous state, use
    ///  GetGlobalState.
    ///
    ///  This method is useful for reducing overhead by processing relative mouse
    ///  inputs in one go per-frame instead of individually per-event, at the
    ///  expense of losing the order between events within the frame (e.g. quickly
    ///  pressing and releasing a button within the same frame).
    /// </summary>
    /// <param name="AX">Is set to the X mouse delta accumulated since last call.</param>
    /// <param name="AY">Is set to the Y mouse delta accumulated since last call.</param>
    /// <returns>The mouse buttons that are pressed.</returns>
    /// <seealso cref="GetState"/>
    /// <seealso cref="GetGlobalState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function GetRelativeState(out AX, AY: Single): TSdlMouseButtons; overload; inline;

    /// <summary>
    ///  Query SDL's cache for the synchronous mouse button state and accumulated
    ///  mouse delta since last call.
    ///
    ///  This method returns the cached synchronous state as SDL understands it
    ///  from the last pump of the event queue.
    ///
    ///  To query the platform for immediate asynchronous state, use
    ///  GetGlobalState.
    ///
    ///  This method is useful for reducing overhead by processing relative mouse
    ///  inputs in one go per-frame instead of individually per-event, at the
    ///  expense of losing the order between events within the frame (e.g. quickly
    ///  pressing and releasing a button within the same frame).
    /// </summary>
    /// <param name="ADelta">Is set to the mouse delta accumulated since last call.</param>
    /// <returns>The mouse buttons that are pressed.</returns>
    /// <seealso cref="GetState"/>
    /// <seealso cref="GetGlobalState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    function GetRelativeState(out ADelta: TSdlPointF): TSdlMouseButtons; overload; inline;

    /// <summary>
    ///  Move the mouse to the given position in global screen space.
    ///
    ///  This method generates a mouse motion event.
    ///
    ///  A failure of this function usually means that it is unsupported by a
    ///  platform.
    ///
    ///  Note that this function will appear to succeed, but not actually move the
    ///  mouse when used over Microsoft Remote Desktop.
    /// </summary>
    /// <param name="AX">The X coordinate.</param>
    /// <param name="AY">The Y coordinate.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlWindow.WarpMouse"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure WarpGlobal(const AX, AY: Single); overload; inline;

    /// <summary>
    ///  Move the mouse to the given position in global screen space.
    ///
    ///  This method generates a mouse motion event.
    ///
    ///  A failure of this function usually means that it is unsupported by a
    ///  platform.
    ///
    ///  Note that this function will appear to succeed, but not actually move the
    ///  mouse when used over Microsoft Remote Desktop.
    /// </summary>
    /// <param name="APosition">The coordinate.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlWindow.WarpMouse"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    procedure WarpGlobal(const APosition: TSdlPointF); overload; inline;

    /// <summary>
    ///  Capture the mouse and to track input outside an SDL window.
    ///
    ///  Capturing enables your app to obtain mouse events globally, instead of just
    ///  within your window. Not all video targets support this function. When
    ///  capturing is enabled, the current window will get all mouse events, but
    ///  unlike relative mode, no change is made to the cursor and it is not
    ///  restrained to your window.
    ///
    ///  This function may also deny mouse input to other windows--both those in
    ///  your application and others on the system--so you should use this function
    ///  sparingly, and in small bursts. For example, you might want to track the
    ///  mouse while the user is dragging something, until the user releases a mouse
    ///  button. It is not recommended that you capture the mouse for long periods
    ///  of time, such as the entire time your app is running. For that, you should
    ///  probably use TSdlWindow.IsRelativeMouseMode or TSdlWindow.MouseGrab,
    ///  depending on your goals.
    ///
    ///  While captured, mouse events still report coordinates relative to the
    ///  current (foreground) window, but those coordinates may be outside the
    ///  bounds of the window (including negative values). Capturing is only allowed
    ///  for the foreground window. If the window loses focus while capturing, the
    ///  capture will be disabled automatically.
    ///
    ///  While capturing is enabled, the current window will have the
    ///  `TSdlWindowFlag.MouseCapture` flag set.
    ///
    ///  Please note that SDL will attempt to "auto capture" the mouse while the
    ///  user is pressing a button; this is to try and make mouse behavior more
    ///  consistent between platforms, and deal with the common case of a user
    ///  dragging the mouse outside of the window. This means that if you are
    ///  calling CaptureMouse only to deal with this situation, you do not
    ///  have to (although it is safe to do so). If this causes problems for your
    ///  app, you can disable auto capture by setting the
    ///  `TSdlHints.MouseAutoCapture` hint to zero.
    /// </summary>
    /// <param name="AEnabled">True to enable capturing, False to disable.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="GetGlobalState"/>
    /// <remarks>
    ///  This method should only be called on the main thread.
    /// </remarks>
    class procedure Capture(const AEnabled: Boolean); inline; static;

    /// <summary>
    ///  Get the name of the mouse.
    ///
    ///  This property returns an empty string if the mouse doesn't have a name.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Mice"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    property Name: String read GetName;

    /// <summary>
    ///  A virtual mouse used for mouse events simulated with touch input.
    /// </summary>
    class property Touch: TSdlMouse read GetTouch;

    /// <summary>
    ///  A virtual mouse used for mouse events simulated with pen input.
    /// </summary>
    class property Pen: TSdlMouse read GetPen;

    /// <summary>
    ///  Whether a mouse is currently connected.
    /// </summary>
    /// <seealso cref="Mice"/>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property HasMouse: Boolean read GetHasMouse;

    /// <summary>
    ///  A list of currently connected mice.
    ///
    ///  Note that this will include any device or virtual driver that includes
    ///  mouse functionality, including some game controllers, KVM switches, etc.
    ///  You should wait for input from a device before you consider it actively in
    ///  use.
    /// </summary>
    /// <seealso cref="Name"/>
    /// <seealso cref="HasMouse"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Mice: TArray<TSdlMouse> read GetMice;

    /// <summary>
    ///  The window which currently has mouse focus.
    /// </summary>
    /// <remarks>
    ///  This property should only be used on the main thread.
    /// </remarks>
    class property Focus: TSdlWindow read GetFocus;
  end;
{$ENDREGION 'Mouse'}

{$REGION 'Touch'}
/// <summary>
///  SDL offers touch input, on platforms that support it. It can manage
///  multiple touch devices and track multiple fingers on those devices.
///
///  Touches are mostly dealt with through the event system, in the
///  TSdlEventKind.FingerDown, TSdlEventKind.FingerMotion, and
///  TSdlEventKind.FingerUp events, but there are also functions to query for
///  hardware details, etc.
///
///  The touch system, by default, will also send virtual mouse events; this can
///  be useful for making a some desktop apps work on a phone without
///  significant changes. For apps that care about mouse and touch input
///  separately, they should ignore mouse events that have a `Mouse` field of
///  TSdlMouse.Touch.
/// </summary>

type
  /// <summary>
  ///  A unique ID for a single finger on a touch device.
  ///
  ///  This ID is valid for the time the finger (stylus, etc) is touching and will
  ///  be unique for all fingers currently in contact, so this ID tracks the
  ///  lifetime of a single continuous touch. This value may represent an index, a
  ///  pointer, or some other unique ID, depending on the platform.
  ///
  ///  The value 0 is an invalid ID.
  /// </summary>
  TSdlFingerID = SDL_FingerID;

type
  /// <summary>
  ///  An enum that describes the type of a touch device.
  /// </summary>
  TSdlTouchDeviceType = (
    /// <summary>
    ///  Invalid
    /// </summary>
    Invalid          = SDL_TOUCH_DEVICE_INVALID,

    /// <summary>
    ///  Touch screen with window-relative coordinates
    /// </summary>
    Direct           = SDL_TOUCH_DEVICE_DIRECT,

    /// <summary>
    ///  Trackpad with absolute device coordinates
    /// </summary>
    IndirectAbsolute = SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE,

    /// <summary>
    ///  Trackpad with screen cursor-relative coordinates
    /// </summary>
    IndirectRelative = SDL_TOUCH_DEVICE_INDIRECT_RELATIVE);

type
  /// <summary>
  ///  Data about a single finger in a multitouch event.
  ///
  ///  Each touch event is a collection of fingers that are simultaneously in
  ///  contact with the touch device (so a "touch" can be a "multitouch," in
  ///  reality), and this struct reports details of the specific fingers.
  /// </summary>
  /// <seealso cref="TSdlTouch.Fingers"/>
  TSdlFinger = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PSDL_Finger;
    function GetID: TSdlFingerID; inline;
    function GetX: Single; inline;
    function GetY: Single; inline;
    function GetPosition: TSdlPointF; inline;
    function GetPressure: Single; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlFinger; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlFinger.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlFinger): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlFinger; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlFinger.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlFinger): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlFinger; inline; static;
  public
    /// <summary>
    ///  The finger ID
    /// </summary>
    property ID: TSdlFingerID read GetID;

    /// <summary>
    ///  The X-axis location of the touch event, normalized (0...1)
    /// </summary>
    property X: Single read GetX;

    /// <summary>
    ///  The Y-axis location of the touch event, normalized (0...1)
    /// </summary>
    property Y: Single read GetY;

    /// <summary>
    ///  The location of the touch event, normalized (0...1, 0...1)
    /// </summary>
    property Position: TSdlPointF read GetPosition;

    /// <summary>
    ///  The quantity of pressure applied, normalized (0...1)
    /// </summary>
    property Pressure: Single read GetPressure;
  end;

type
  /// <summary>
  ///  A touch device
  /// </summary>
  TSdlTouch = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_TouchID;
    function GetName: String; inline;
    function GetDeviceType: TSdlTouchDeviceType; inline;
    function GetFingers: TArray<TSdlFinger>; inline;
    class function GetDevices: TArray<TSdlTouch>; static;
    class function GetMouse: TSdlTouch; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlTouch; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTouch.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlTouch): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlTouch; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlTouch.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlTouch): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlTouch; inline; static;
  public
    /// <summary>
    ///  The touch device name as reported from the driver.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Name: String read GetName;

    /// <summary>
    ///  The type of the given touch device.
    /// </summary>
    property DeviceType: TSdlTouchDeviceType read GetDeviceType;

    /// <summary>
    ///  A list of active fingers for a given touch device.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Fingers: TArray<TSdlFinger> read GetFingers;

    /// <summary>
    ///  A list of registered touch devices.
    ///
    ///  On some platforms SDL first sees the touch device if it was actually used.
    ///  Therefore the returned list might be empty, although devices are available.
    ///  After using all devices at least once the number will be correct.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class property Devices: TArray<TSdlTouch> read GetDevices;

    /// <summary>
    ///  A virtual touch device used for touch events simulated with mouse input.
    /// </summary>
    class property Mouse: TSdlTouch read GetMouse;
  end;
{$ENDREGION 'Touch'}

{$REGION 'Pen'}
/// <summary>
///  SDL pen event handling.
///
///  SDL provides an API for pressure-sensitive pen (stylus and/or eraser)
///  handling, e.g., for input and drawing tablets or suitably equipped mobile /
///  tablet devices.
///
///  To get started with pens, simply handle TSdlEventKind.Pen* events. When a pen
///  starts providing input, SDL will assign it a unique ID, which will
///  remain for the life of the process, as long as the pen stays connected.
///
///  Pens may provide more than simple touch input; they might have other axes,
///  such as pressure, tilt, rotation, etc.
/// </summary>

type
  /// <summary>
  ///  SDL pen instance IDs.
  ///
  ///  Zero is used to signify an invalid/null device.
  ///
  ///  These show up in pen events when SDL sees input from them. They remain
  ///  consistent as long as SDL can recognize a tool to be the same pen; but if a
  ///  pen physically leaves the area and returns, it might get a new ID.
  /// </summary>
  TSdlPenID = SDL_PenID;

type
  /// <summary>
  ///  Pen input flag, as reported by various pen events' `PenState` field.
  /// </summary>
  TSdlPenInputFlag = (
    Down = 0,        // Pen is pressed down
    Button1 = 1,     // Button 1 is pressed
    Button2 = 2,     // Button 2 is pressed
    Button3 = 3,     // Button 3 is pressed
    Button4 = 4,     // Button 4 is pressed
    Button5 = 5,     // Button 5 is pressed
    EraserTip = 30); // Eraser tip is used

  /// <summary>
  ///  Set of pen input flags.
  /// </summary>
  TSdlPenInputFlags = set of TSdlPenInputFlag;

type
  /// <summary>
  ///  Pen axis indices.
  ///
  ///  These are the valid values for the `Axis` field in TSdlPenAxisEvent. All
  ///  axes are either normalised to 0..1 or report a (positive or negative) angle
  ///  in degrees, with 0.0 representing the centre. Not all pens/backends support
  ///  all axes: unsupported axes are always zero.
  ///
  ///  To convert angles for tilt and rotation into vector representation, use
  ///  Sin on the XTilt, YTilt, or Rotation component, for example:
  ///
  ///  `Sin(XTilt * PI / 180)`.
  /// </summary>
  TSdlPenAxis = (
    /// <summary>Pen pressure.
    ///  Unidirectional: 0 to 1.0</summary>
    Presssure          = SDL_PEN_AXIS_PRESSURE,

    /// <summary>Pen horizontal tilt angle.
    ///  Bidirectional: -90.0 to 90.0 (left-to-right).</summary>
    XTilt              = SDL_PEN_AXIS_XTILT,

    /// <summary>Pen vertical tilt angle.
    ///  Bidirectional: -90.0 to 90.0 (top-to-down).</summary>
    YTilt              = SDL_PEN_AXIS_YTILT,

    /// <summary>Pen distance to drawing surface.
    ///  Unidirectional: 0.0 to 1.0</summary>
    Distance           = SDL_PEN_AXIS_DISTANCE,

    /// <summary>Pen barrel rotation.
    ///  Bidirectional: -180 to 179.9 (clockwise, 0 is facing up, -180.0 is facing down).</summary>
    Rotation           = SDL_PEN_AXIS_ROTATION,

    /// <summary>Pen finger wheel or slider (e.g., Airbrush Pen).
    ///  Unidirectional: 0 to 1.0</summary>
    Slider             = SDL_PEN_AXIS_SLIDER,

    /// <summary>Pressure from squeezing the pen ("barrel pressure").</summary>
    TangentialPressure = SDL_PEN_AXIS_TANGENTIAL_PRESSURE);
{$ENDREGION 'Pen'}

{$REGION 'Sensor'}
/// <summary>
///  SDL sensor management.
///
///  These APIs grant access to gyros and accelerometers on various platforms.
///
///  In order to use these functions, SdlInit must have been called with the
///  TSdlInitFlag.Sensor flag. This causes SDL to scan the system for sensors, and
///  load appropriate drivers.
/// </summary>

const
  /// <summary>
  ///  A constant to represent standard gravity for accelerometer sensors.
  ///
  ///  The accelerometer returns the current acceleration in SI meters per second
  ///  squared. This measurement includes the force of gravity, so a device at
  ///  rest will have an value of SDL_STANDARD_GRAVITY away from the center of the
  ///  earth, which is a positive Y value.
  /// </summary>
  SDL_STANDARD_GRAVITY = Neslib.Sdl3.Api.SDL_STANDARD_GRAVITY; // 9.80665 m/s/s;

type
  /// <summary>
  ///  The different sensors defined by SDL.
  ///
  ///  Additional sensors may be available, using platform dependent semantics.
  ///
  ///  Here are the additional 
  ///  <see href="https://developer.android.com/reference/android/hardware/SensorEvent.html#values">Android sensors</see>.
  ///
  ///  Accelerometer sensor notes:
  ///
  ///  The accelerometer returns the current acceleration in SI meters per second
  ///  squared. This measurement includes the force of gravity, so a device at
  ///  rest will have an value of SDL_STANDARD_GRAVITY away from the center of the
  ///  earth, which is a positive Y value.
  ///
  ///  - `Values[0]`: Acceleration on the x axis
  ///  - `Values[1]`: Acceleration on the y axis
  ///  - `Values[2]`: Acceleration on the z axis
  ///
  ///  For phones and tablets held in natural orientation and game controllers
  ///  held in front of you, the axes are defined as follows:
  ///
  ///  - -X ... +X : left ... right
  ///  - -Y ... +Y : bottom ... top
  ///  - -Z ... +Z : farther ... closer
  ///
  ///  The accelerometer axis data is not changed when the device is rotated.
  ///
  ///  Gyroscope sensor notes:
  ///
  ///  The gyroscope returns the current rate of rotation in radians per second.
  ///  The rotation is positive in the counter-clockwise direction. That is, an
  ///  observer looking from a positive location on one of the axes would see
  ///  positive rotation on that axis when it appeared to be rotating
  ///  counter-clockwise.
  ///
  ///  - `Values[0]`: Angular speed around the x axis (pitch)
  ///  - `Values[1]`: Angular speed around the y axis (yaw)
  ///  - `Values[2]`: Angular speed around the z axis (roll)
  ///
  ///  For phones and tablets held in natural orientation and game controllers
  ///  held in front of you, the axes are defined as follows:
  ///
  ///  - -X ... +X : left ... right
  ///  - -Y ... +Y : bottom ... top
  ///  - -Z ... +Z : farther ... closer
  ///
  ///  The gyroscope axis data is not changed when the device is rotated.
  /// </summary>
  /// <seealso cref="TSdlDisplay.CurrentOrientation"/>
  TSdlSensorKind = (
    /// <summary>Returned for an invalid sensor</summary>
    Invalid    = SDL_SENSOR_INVALID,

    /// <summary>Unknown sensor type</summary>
    Unknown    = SDL_SENSOR_UNKNOWN,

    /// <summary>Accelerometer</summary>
    Accel      = SDL_SENSOR_ACCEL,

    /// <summary>Gyroscope</summary>
    Gyro       = SDL_SENSOR_GYRO,

    /// <summary>Accelerometer for left Joy-Con controller and Wii nunchuk</summary>
    AccelLeft  = SDL_SENSOR_ACCEL_L,

    /// <summary>Gyroscope for left Joy-Con controller</summary>
    GyroLeft   = SDL_SENSOR_GYRO_L,

    /// <summary>Accelerometer for right Joy-Con controller</summary>
    AccelRight = SDL_SENSOR_ACCEL_R,

    /// <summary>Gyroscope for right Joy-Con controller</summary>
    GyroRight  = SDL_SENSOR_GYRO_R);

type
  /// <summary>
  ///  This is a unique ID for a sensor for the time it is connected to the
  ///  system, and is never reused for the lifetime of the application.
  /// </summary>
  TSdlSensorID = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_SensorID;
    function GetName: String; inline;
    function GetKind: TSdlSensorKind; inline;
    function GetNonPortableType: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlSensorID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlSensorID.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlSensorID): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlSensorID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlSensorID.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlSensorID): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlSensorID; inline; static;
  public
    /// <summary>
    ///  The implementation dependent name of the sensor.
    ///
    ///  This can be used before any sensors are opened.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Name: String read GetName;

    /// <summary>
    ///  The type of the sensor.
    ///
    ///  This can be used before any sensors are opened.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Kind: TSdlSensorKind read GetKind;

    /// <summary>
    ///  Get the platform dependent type of a sensor,
    ///
    ///  This can be used before any sensors are opened.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NonPortableType: Integer read GetNonPortableType;
  end;

type
  /// <summary>
  ///  An opened SDL sensor.
  /// </summary>
  TSdlSensor = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Sensor;
    function GetName: String; inline;
    function GetKind: TSdlSensorKind; inline;
    function GetNonPortableType: Integer; inline;
    function GetID: TSdlSensorID; inline;
    function GetProperties: TSdlProperties; inline;
    class function GetSensors: TArray<TSdlSensorID>; inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlSensor; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlSensor.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlSensor): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlSensor; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlSensor.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlSensor): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlSensor; inline; static;
  public
    /// <summary>
    ///  Open a sensor for use.
    /// </summary>
    /// <param name="AInstanceID">The sensor instance ID.</param>
    /// <returns>The sensor.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class function Open(const AInstanceID: TSdlSensorID): TSdlSensor; inline; static;

    /// <summary>
    ///  Close the sensor previously opened with Open.
    /// </summary>
    procedure Close; inline;

    /// <summary>
    ///  Return the snsor associated with an opened instance ID.
    /// </summary>
    /// <param name="AInstanceId">The sensor instance ID.</param>
    /// <returns>The sensor.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class function FromID(const AInstanceID: TSdlSensorID): TSdlSensor; inline; static;

    /// <summary>
    ///  Get the current state of the opened sensor.
    ///
    ///  The number of values and interpretation of the data is sensor dependent.
    ///  The length of the AData array is the maximum number of values that will
    ///  be written to the array.
    /// </summary>
    /// <param name="AData">An array filled with the current sensor state.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure GetSensorData(const AData: TArray<Single>); inline;

    /// <summary>
    ///  Update the current state of the open sensors.
    ///
    ///  This is called automatically by the event loop if sensor events are
    ///  enabled.
    ///
    ///  This needs to be called from the thread that initialized the sensor
    ///  subsystem.
    /// </summary>
    class procedure Update; inline; static;

    /// <summary>
    ///  The implementation dependent name of the sensor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Name: String read GetName;

    /// <summary>
    ///  The type of the sensor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Kind: TSdlSensorKind read GetKind;

    /// <summary>
    ///  The platform dependent type of the sensor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NonPortableType: Integer read GetNonPortableType;

    /// <summary>
    ///  The instance ID of the sensor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property ID: TSdlSensorID read GetID;

    /// <summary>
    ///  The properties associated with the sensor.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Properties: TSdlProperties read GetProperties;

    /// <summary>
    ///  A list of currently connected sensors.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class property Sensors: TArray<TSdlSensorID> read GetSensors;
  end;
{$ENDREGION 'Sensor'}

{$REGION 'Gamepad'}
/// <summary>
///  SDL provides a low-level joystick API, which just treats joysticks as an
///  arbitrary pile of buttons, axes, and hat switches. If you're planning to
///  write your own control configuration screen, this can give you a lot of
///  flexibility, but that's a lot of work, and most things that we consider
///  "joysticks" now are actually console-style gamepads. So SDL provides the
///  gamepad API on top of the lower-level joystick functionality.
///
///  The difference between a joystick and a gamepad is that a gamepad tells you
///  _where_ a button or axis is on the device. You don't speak to gamepads in
///  terms of arbitrary numbers like "button 3" or "axis 2" but in standard
///  locations: the d-pad, the shoulder buttons, triggers, A/B/X/Y (or
///  X/O/Square/Triangle, if you will).
///
///  One turns a joystick into a gamepad by providing a magic configuration
///  string, which tells SDL the details of a specific device: when you see this
///  specific hardware, if button 2 gets pressed, this is actually D-Pad Up,
///  etc.
///
///  SDL has many popular controllers configured out of the box, and users can
///  add their own controller details through an environment variable if it's
///  otherwise unknown to SDL.
///
///  In order to use these functions, SdlInit must have been called with the
///  TSdlInitFlag.Gamepad flag. This causes SDL to scan the system for gamepads,
///  and load appropriate drivers.
///
///  If you would like to receive gamepad updates while the application is in
///  the background, you should set the following hint before calling
///  SdlInit: TSdlHints.JoystickAllowBackgroundEvents.
///
///  Gamepads support various optional features such as rumble, color LEDs,
///  touchpad, gyro, etc. The support for these features varies depending on the
///  controller and OS support available. You can check for LED and rumble
///  capabilities at runtime by using TSdlGamepad.Properties and checking
///  the various capability properties. You can check for touchpad by using
///  TSdlGamepad.NumTouchpads and check for gyro and accelerometer by
///  calling TSdlGamepad.HasSensor.
///
///  By default SDL will try to use the most capable driver available, but you
///  can tune which OS drivers to use with the various joystick hints.
///
///  Your application should always support gamepad hotplugging. On some
///  platforms like Xbox, Steam Deck, etc., this is a requirement for
///  certification. On other platforms, like macOS and Windows when using
///  Windows.Gaming.Input, controllers may not be available at startup and will
///  come in at some point after you've started processing events.
/// </summary>

type
  /// <summary>
  ///  The list of buttons available on a gamepad
  ///
  ///  For controllers that use a diamond pattern for the face buttons, the
  ///  south/east/west/north buttons below correspond to the locations in the
  ///  diamond pattern. For Xbox controllers, this would be A/B/X/Y, for Nintendo
  ///  Switch controllers, this would be B/A/Y/X, for PlayStation controllers this
  ///  would be Cross/Circle/Square/Triangle.
  ///
  ///  For controllers that don't use a diamond pattern for the face buttons, the
  ///  south/east/west/north buttons indicate the buttons labeled A, B, C, D, or
  ///  1, 2, 3, 4, or for controllers that aren't labeled, they are the primary,
  ///  secondary, etc. buttons.
  ///
  ///  The activate action is often the south button and the cancel action is
  ///  often the east button, but in some regions this is reversed, so your game
  ///  should allow remapping actions based on user preferences.
  ///
  ///  You can query the labels for the face buttons using
  ///  TSdlGamepad.ButtonLabel.
  /// </summary>
  TSdlGamepadButton = (
    Invalid      = SDL_GAMEPAD_BUTTON_INVALID,

    /// <summary>Bottom face button (e.g. Xbox A button)</summary>
    South        = SDL_GAMEPAD_BUTTON_SOUTH,

    /// <summary>Right face button (e.g. Xbox B button)</summary>
    East         = SDL_GAMEPAD_BUTTON_EAST,

    /// <summary>Left face button (e.g. Xbox X button)</summary>
    West         = SDL_GAMEPAD_BUTTON_WEST,

    /// <summary>Top face button (e.g. Xbox Y button)</summary>
    North        = SDL_GAMEPAD_BUTTON_NORTH,

    Back         = SDL_GAMEPAD_BUTTON_BACK,
    Guide        = SDL_GAMEPAD_BUTTON_GUIDE,
    Start        = SDL_GAMEPAD_BUTTON_START,
    LeftStick    = SDL_GAMEPAD_BUTTON_LEFT_STICK,
    RightStick   = SDL_GAMEPAD_BUTTON_RIGHT_STICK,
    LeftShoulder = SDL_GAMEPAD_BUTTON_LEFT_SHOULDER,
    RightSoulder = SDL_GAMEPAD_BUTTON_RIGHT_SHOULDER,
    DPadUp       = SDL_GAMEPAD_BUTTON_DPAD_UP,
    DPadDown     = SDL_GAMEPAD_BUTTON_DPAD_DOWN,
    DPadLeft     = SDL_GAMEPAD_BUTTON_DPAD_LEFT,
    DPadRight    = SDL_GAMEPAD_BUTTON_DPAD_RIGHT,

    /// <summary>Additional button (e.g. Xbox Series X share button, PS5 microphone button, Nintendo Switch Pro capture button, Amazon Luna microphone button, Google Stadia capture button)</summary>
    Misc1        = SDL_GAMEPAD_BUTTON_MISC1,

    /// <summary>Upper or primary paddle, under your right hand (e.g. Xbox Elite paddle P1)</summary>
    RightPaddle1 = SDL_GAMEPAD_BUTTON_RIGHT_PADDLE1,

    /// <summary>Upper or primary paddle, under your left hand (e.g. Xbox Elite paddle P3)</summary>
    LeftPaddle1  = SDL_GAMEPAD_BUTTON_LEFT_PADDLE1,

    /// <summary>Lower or secondary paddle, under your right hand (e.g. Xbox Elite paddle P2)</summary>
    RightPaddle2 = SDL_GAMEPAD_BUTTON_RIGHT_PADDLE2,

    /// <summary>Lower or secondary paddle, under your left hand (e.g. Xbox Elite paddle P4)</summary>
    LeftPaddle2  = SDL_GAMEPAD_BUTTON_LEFT_PADDLE2,

    /// <summary>PS4/PS5 touchpad button</summary>
    Touchpad     = SDL_GAMEPAD_BUTTON_TOUCHPAD,

    /// <summary>Additional button</summary>
    Misc2        = SDL_GAMEPAD_BUTTON_MISC2,

    /// <summary>Additional button</summary>
    Misc3        = SDL_GAMEPAD_BUTTON_MISC3,

    /// <summary>Additional button</summary>
    Misc4        = SDL_GAMEPAD_BUTTON_MISC4,

    /// <summary>Additional button</summary>
    Misc5        = SDL_GAMEPAD_BUTTON_MISC5,

    /// <summary>Additional button</summary>
    Misc6        = SDL_GAMEPAD_BUTTON_MISC6);

  TSdlBasicGamepadButton = TSdlGamepadButton.South..TSdlGamepadButton.Misc6;
  TSdlGamepadButtons = set of TSdlBasicGamepadButton;

  _TSdlGamepadButtonHelper = record helper for TSdlGamepadButton
  public
    /// <summary>
    ///  Convert a string into a TSdlGamepadButton enum.
    ///
    ///  This method is called internally to translate SDL gamepad mapping strings
    ///  for the underlying joystick device into the consistent SDL gamepad mapping.
    ///  You do not normally need to call this method unless you are parsing
    ///  SDL gamepad mappings in your own code.
    /// </summary>
    /// <param name="AStr">String representing a SDL gamepad button.</param>
    /// <returns>The TSdlGamepadButton enum corresponding to the input string,
    ///  or `Invalid` if no match was found.</returns>
    /// <seealso cref="ToString"/>
    class function FromString(const AStr: String): TSdlGamepadButton; inline; static;

    /// <summary>
    ///  Convert the enum to a string.
    /// </summary>
    /// <returns>A string for the given button, or an empty string if an invalid
    ///  button is specified. The string returned is of the format used by SDL
    ///  gamepad mapping strings.</returns>
    /// <seealso cref="FromString"/>
    function ToString: String; inline;
  end;

type
  /// <summary>
  ///  The set of gamepad button labels
  ///
  ///  This isn't a complete set, just the face buttons to make it easy to show
  ///  button prompts.
  ///
  ///  For a complete set, you should look at the button and gamepad type and have
  ///  a set of symbols that work well with your art style.
  /// </summary>
  TSdlGamepadButtonLabel = (
    Unknown  = SDL_GAMEPAD_BUTTON_LABEL_UNKNOWN,
    A        = SDL_GAMEPAD_BUTTON_LABEL_A,
    B        = SDL_GAMEPAD_BUTTON_LABEL_B,
    X        = SDL_GAMEPAD_BUTTON_LABEL_X,
    Y        = SDL_GAMEPAD_BUTTON_LABEL_Y,
    Cross    = SDL_GAMEPAD_BUTTON_LABEL_CROSS,
    Circle   = SDL_GAMEPAD_BUTTON_LABEL_CIRCLE,
    Square   = SDL_GAMEPAD_BUTTON_LABEL_SQUARE,
    Triangle = SDL_GAMEPAD_BUTTON_LABEL_TRIANGLE);

type
  /// <summary>
  ///  Standard gamepad types.
  ///
  ///  This type does not necessarily map to first-party controllers from
  ///  Microsoft/Sony/Nintendo; in many cases, third-party controllers can report
  ///  as these, either because they were designed for a specific console, or they
  ///  simply most closely match that console's controllers (does it have A/B/X/Y
  ///  buttons or X/O/Square/Triangle? Does it have a touchpad? etc).
  /// </summary>
  TSdlGamepadKind = (
    Unknown           = SDL_GAMEPAD_TYPE_UNKNOWN,
    Standard          = SDL_GAMEPAD_TYPE_STANDARD,
    XBox360           = SDL_GAMEPAD_TYPE_XBOX360,
    XBoxOne           = SDL_GAMEPAD_TYPE_XBOXONE,
    PS3               = SDL_GAMEPAD_TYPE_PS3,
    PS4               = SDL_GAMEPAD_TYPE_PS4,
    PS5               = SDL_GAMEPAD_TYPE_PS5,
    SwitchPro         = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_PRO,
    SwitchJoyConLeft  = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_LEFT,
    SwitchJoyConRight = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT,
    SwitchJoyConPair  = SDL_GAMEPAD_TYPE_NINTENDO_SWITCH_JOYCON_PAIR);

  _SdlGamepadKindHelper = record helper for TSdlGamepadKind
  public
    /// <summary>
    ///  Convert a string into a TSdlGamepadKind enum.
    ///
    ///  This mehtod is called internally to translate SDL gamepad mapping strings
    ///  for the underlying joystick device into the consistent SDL gamepad mapping.
    ///  You do not normally need to call this mehtod unless you are parsing
    ///  SDL gamepad mappings in your own code.
    /// </summary>
    /// <param name="AStr">String representing a TSdlGamepadKind type.</param>
    /// <returns>The TSdlGamepadKind enum corresponding to the input string,
    ///  or `Unknown` if no match was found.</returns>
    /// <seealso cref="ToString"/>
    class function FromString(const AStr: String): TSdlGamepadKind; inline; static;

    /// <summary>
    ///  Convert this enum to a string.
    /// </summary>
    /// <returns>A string for the given type, or an empty string an invalid type
    ///   is specified. The string returned is of the format used by
    ///   SDL gamepad mapping strings.</returns>
    /// <seealso cref="FromString"/>
    function ToString: String; inline;

    /// <summary>
    ///  The label of a button on a gamepad.
    /// </summary>
    /// <param name="AButton">The button.</param>
    /// <returns>The TSdlGamepadButtonLabel enum corresponding to the button label.</returns>
    /// <seealso cref="TSdlGamepad.GetButtonLabel"/>
    function GetButtonLabel(const AButton: TSdlGamepadButton): TSdlGamepadButtonLabel; inline;
  end;

type
  /// <summary>
  ///  The list of axes available on a gamepad
  ///
  ///  Thumbstick axis values range from SDL_JOYSTICK_AXIS_MIN to
  ///  SDL_JOYSTICK_AXIS_MAX, and are centered within ~8000 of zero, though
  ///  advanced UI will allow users to set or autodetect the dead zone, which
  ///  varies between gamepads.
  ///
  ///  Trigger axis values range from 0 (released) to SDL_JOYSTICK_AXIS_MAX (fully
  ///  pressed) when reported by TSdlGamepad.Axis. Note that this is not the
  ///  same range that will be reported by the lower-level TSdlJoystick.Axis.
  /// </summary>
  TSdlGamepadAxis = (
    Invalid      = SDL_GAMEPAD_AXIS_INVALID,
    LeftX        = SDL_GAMEPAD_AXIS_LEFTX,
    LeftY        = SDL_GAMEPAD_AXIS_LEFTY,
    RightX       = SDL_GAMEPAD_AXIS_RIGHTX,
    RightY       = SDL_GAMEPAD_AXIS_RIGHTY,
    LeftTrigger  = SDL_GAMEPAD_AXIS_LEFT_TRIGGER,
    RightTrigger = SDL_GAMEPAD_AXIS_RIGHT_TRIGGER);

  TSdlBasicGamepadAxis = TSdlGamepadAxis.LeftX..TSdlGamepadAxis.RightTrigger;
  TSdlGamepadAxes = set of TSdlBasicGamepadAxis;

  _SdlGamepadAxisHelper = record helper for TSdlGamepadAxis
  public
    /// <summary>
    ///  Convert a string into a TSdlGamepadAxis enum.
    ///
    ///  This method is called internally to translate SDL gamepad mapping strings
    ///  for the underlying joystick device into the consistent SDL gamepad mapping.
    ///  You do not normally need to call this method unless you are parsing
    ///  SDL gamepad mappings in your own code.
    ///
    ///  Note specially that "righttrigger" and "lefttrigger" map to
    ///  `TSdlGamepadAxis.RightTrigger` and `TSdlGamepadAxis.LeftTrigger`,
    ///  respectively.
    /// </summary>
    /// <param name="AStr">String representing a SDL gamepad axis.</param>
    /// <returns>The TSdlGamepadAxis enum corresponding to the input string,
    ///  or `Invalid` if no match was found.</returns>
    /// <seealso cref="ToString"/>
    class function FromString(const AStr: String): TSdlGamepadAxis; inline; static;

    /// <summary>
    ///  Convert the enum to a string.
    /// </summary>
    /// <returns>A string for the axis, or an empty string if an invalid axis is
    ///  specified. The string returned is of the format used by SDL gamepad
    ///  mapping strings.</returns>
    /// <seealso cref="FromString"/>
    function ToString: String; inline;
  end;

type
  /// <summary>
  ///  Possible connection states for a gamepad device.
  ///
  ///  This is used by TSdlGamepad.ConnectionState to report how a device is
  ///  connected to the system.
  /// </summary>
  TSdlGamepadConnectionState = (
    Invalid  = SDL_JOYSTICK_CONNECTION_INVALID,
    Unknown  = SDL_JOYSTICK_CONNECTION_UNKNOWN,
    Wired    = SDL_JOYSTICK_CONNECTION_WIRED,
    Wireless = SDL_JOYSTICK_CONNECTION_WIRELESS);

type
  /// <summary>
  ///  Types of gamepad control bindings.
  ///
  ///  A gamepad is a collection of bindings that map arbitrary joystick buttons,
  ///  axes and hat switches to specific positions on a generic console-style
  ///  gamepad. This enum is used as part of TSdlGamepadBinding to specify those
  ///  mappings.
  /// </summary>
  TSdlGamepadBindingType = (
    None   = SDL_GAMEPAD_BINDTYPE_NONE,
    Button = SDL_GAMEPAD_BINDTYPE_BUTTON,
    Axis   = SDL_GAMEPAD_BINDTYPE_AXIS,
    Hat    = SDL_GAMEPAD_BINDTYPE_HAT);

type
  /// <summary>
  ///  A mapping between one joystick input to a gamepad control.
  ///
  ///  A gamepad has a collection of several bindings, to say, for example, when
  ///  joystick button number 5 is pressed, that should be treated like the
  ///  gamepad's "start" button.
  ///
  ///  SDL has these bindings built-in for many popular controllers, and can add
  ///  more with a simple text string. Those strings are parsed into a collection
  ///  of these structs to make it easier to operate on the data.
  /// </summary>
  /// <seealso cref="TSdlGamepad.Bindings"/>
  TSdlGamepadBinding = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: PSDL_GamepadBinding;
    function GetInputType: TSdlGamepadBindingType; inline;
    function GetInputButtonIndex: Integer; inline;
    function GetInputAxisIndex: Integer; inline;
    function GetInputAxisMin: Integer; inline;
    function GetInputAxisMax: Integer; inline;
    function GetInputHatIndex: Integer; inline;
    function GetInputHatMask: Integer; inline;
    function GetOutputType: TSdlGamepadBindingType; inline;
    function GetOutputButton: TSdlGamepadButton; inline;
    function GetOutputAxis: TSdlGamepadAxis; inline;
    function GetOutputAxisMin: Integer; inline;
    function GetOutputAxisMax: Integer; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGamepadBinding; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGamepadBinding.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGamepadBinding): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGamepadBinding; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGamepadBinding.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGamepadBinding): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGamepadBinding; inline; static;
  public
    /// <summary>
    ///  Input (source) type
    /// </summary>
    property InputType: TSdlGamepadBindingType read GetInputType;

    /// <summary>
    ///  Input button index (for Button types)
    /// </summary>
    property InputButtonIndex: Integer read GetInputButtonIndex;

    /// <summary>
    ///  Input axis index (for Axis types)
    /// </summary>
    property InputAxisIndex: Integer read GetInputAxisIndex;

    /// <summary>
    ///  Input minimum axis value (for Axis types)
    /// </summary>
    property InputAxisMin: Integer read GetInputAxisMin;

    /// <summary>
    ///  Input maximum axis value (for Axis types)
    /// </summary>
    property InputAxisMax: Integer read GetInputAxisMax;

    /// <summary>
    ///  Input hat index (for Hat types)
    /// </summary>
    property InputHatIndex: Integer read GetInputHatIndex;

    /// <summary>
    ///  Input hat mask (for Hat types)
    /// </summary>
    property InputHatMask: Integer read GetInputHatMask;

    /// <summary>
    ///  Output (destination) type
    /// </summary>
    property OutputType: TSdlGamepadBindingType read GetOutputType;

    /// <summary>
    ///  Output button (for Button types)
    /// </summary>
    property OutputButton: TSdlGamepadButton read GetOutputButton;

    /// <summary>
    ///  Output axis (for Axis types)
    /// </summary>
    property OutputAxis: TSdlGamepadAxis read GetOutputAxis;

    /// <summary>
    ///  Output minimum axis value (for Axis types)
    /// </summary>
    property OutputAxisMin: Integer read GetOutputAxisMin;

    /// <summary>
    ///  Output maximum axis value (for Axis types)
    /// </summary>
    property OutputAxisMax: Integer read GetOutputAxisMax;
  end;

type
  /// <summary>
  ///  This is a unique ID for a gamepad for the time it is connected to the
  ///  system, and is never reused for the lifetime of the application.
  ///
  ///  If the gamepad is disconnected and reconnected, it will get a new ID.
  /// </summary>
  TSdlGamepadID = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoystickID;
    function GetName: String; inline;
    function GetPath: String; inline;
    function GetPlayerIndex: Integer; inline;
    function GetGuid: TGuid; inline;
    function GetVendor: Word; inline;
    function GetProduct: Word; inline;
    function GetProductVersion: Word; inline;
    function GetKind: TSdlGamepadKind; inline;
    function GetRealKind: TSdlGamepadKind; inline;
    function GetMapping: String; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGamepadID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGamepadID.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGamepadID): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGamepadID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGamepadID.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGamepadID): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlGamepadID; inline; static;
  public
    /// <summary>
    ///  The implementation dependent name of the gamepad, or an empty string
    ///  if not available.
    ///
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Name"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property Name: String read GetName;

    /// <summary>
    ///  The implementation dependent path of the gamepad, or an empty string
    ///  if not available.
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Path"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property Path: String read GetPath;

    /// <summary>
    ///  The player index of the gamepad, or -1 if not available.
    ///
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="TSdlGamepad.PlayerIndex"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property PlayerIndex: Integer read GetPlayerIndex;

    /// <summary>
    ///  The implementation-dependent GUID of the gamepad.
    ///
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property Guid: TGuid read GetGuid;

    /// <summary>
    ///  The USB vendor ID of the gamepad, if available.
    ///
    ///  This can be used before any gamepads are opened. If the vendor ID isn't
    ///  available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Vendor"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property Vendor: Word read GetVendor;

    /// <summary>
    ///  The USB product ID of the gamepad, if available.
    ///
    ///  This can be used before any gamepads are opened. If the product ID isn't
    ///  available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Product"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property Product: Word read GetProduct;

    /// <summary>
    ///  The product version of the gamepad, if available.
    ///
    ///  This can be used before any gamepads are opened. If the product version
    ///  isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlGamepad.ProductVersion"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    property ProductVersion: Word read GetProductVersion;

    /// <summary>
    ///  The type of the gamepad.
    ///
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Kind"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    /// <seealso cref="RealKind"/>
    property Kind: TSdlGamepadKind read GetKind;

    /// <summary>
    ///  The type of the gamepad, ignoring any mapping override.
    ///
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="Kind"/>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    /// <seealso cref="TSdlGamepad.RealKind"/>
    property RealKind: TSdlGamepadKind read GetRealKind;

    /// <summary>
    ///  The mapping of the gamepad, or an empty string if not available.
    ///
    ///  This can be used before any gamepads are opened.
    /// </summary>
    /// <seealso cref="TSdlGamepad.Gamepads"/>
    /// <seealso cref="TSdlGamepad.Mapping"/>
    property Mapping: String read GetMapping;
  end;

type
  /// <summary>
  ///  An SDL gamepad
  /// </summary>
  TSdlGamepad = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Gamepad;
    function GetMapping: String; inline;
    procedure SetMapping(const AValue: String); inline;
    function GetName: String; inline;
    function GetPath: String; inline;
    function GetKind: TSdlGamepadKind; inline;
    function GetRealKind: TSdlGamepadKind; inline;
    function GetPlayerIndex: Integer; inline;
    procedure SetPlayerIndex(const AValue: Integer); inline;
    function GetVendor: Word; inline;
    function GetProduct: Word; inline;
    function GetProductVersion: Word; inline;
    function GetFirmwareVersion: Word; inline;
    function GetSerial: String; inline;
    function GetSteamHandle: UInt64; inline;
    function GetConnectionState: TSdlGamepadConnectionState; inline;
    function GetIsConnected: Boolean; inline;
    function GetAxis(const AAxis: TSdlGamepadAxis): Smallint; inline;
    function GetButton(const AButton: TSdlGamepadButton): Boolean; inline;
    function GetNumTouchpads: Integer; inline;
    function GetNumTouchpadFingers(const ATouchPad: Integer): Integer; inline;
    function GetSensorEnabled(const AKind: TSdlSensorKind): Boolean; inline;
    procedure SetSensorEnabled(const AKind: TSdlSensorKind;
      const AValue: Boolean); inline;
    function GetSensorDataRate(const AKind: TSdlSensorKind): Single; inline;
    function GetID: TSdlGamepadID; inline;
    function GetProperties: TSdlProperties; inline;
    function GetBindings: TArray<TSdlGamepadBinding>;
    class function GetHasGamepad: Boolean; inline; static;
    class function GetGamepads: TArray<TSdlGamepadID>; static;
    class function GetMappings: TArray<String>; static;
    class function GetEventsEnabled: Boolean; inline; static;
    class procedure SetEventsEnabled(const AValue: Boolean); inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlGamepad; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGamepad.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlGamepad): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlGamepad; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlGamepad.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlGamepad): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlGamepad; inline; static;
  public
    /// <summary>
    ///  Open a gamepad for use.
    /// </summary>
    /// <param name="AInstanceID">The gamepad instance ID.</param>
    /// <returns>The gamepad.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    /// <seealso cref="TSdlJoystickID.IsGamepad"/>
    class function Open(const AInstanceID: TSdlGamepadID): TSdlGamepad; inline; static;

    /// <summary>
    ///  Close the gamepad previously opened with Open.
    /// </summary>
    /// <seealso cref="Open"/>
    procedure Close; inline;

    /// <summary>
    ///  Get the gamepad associated with a gamepad instance ID, if it has been
    ///  opened.
    /// </summary>
    /// <param name="AInstanceID">The gamepad instance ID.</param>
    /// <returns>The gamepad.</returns>
    /// <exception name="ESdlError">Raised on failure (eg. when the gamepad
    ///  has not been opened).</exception>
    class function FromID(const AInstanceID: TSdlGamepadID): TSdlGamepad; inline; static;

    /// <summary>
    ///  Get the gamepad associated with a player index.
    /// </summary>
    /// <param name="APlayerIndex">The player index.</param>
    /// <returns>The gamepad.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PlayerIndex"/>
    class function FromPlayerIndex(const APlayerIndex: Integer): TSdlGamepad; inline; static;

    /// <summary>
    ///  Add support for gamepads that SDL is unaware of or change the binding
    ///  of an existing gamepad.
    ///
    ///  The mapping string has the format 'GUID,Name,Mappings', where:
    ///
    ///  - GUID is the string value from TGuid.ToString, but with curly braces
    ///    and dashes removed. Under Windows there is a reserved GUID of
    ///    'xinput' that covers all XInput devices
    ///  - Name is the human readable string for the device.
    ///  - Mappings are gamepad mappings to joystick ones.
    ///
    /// The mapping format for joystick is:
    ///
    ///  - `bX`: a joystick button, index X
    ///  - `hX.Y`: hat X with value Y
    ///  - `aX`: axis X of the joystick
    ///
    ///  Buttons can be used as a gamepad axes and vice versa.
    ///
    ///  If a device with this GUID is already plugged in, SDL will generate an
    ///  TSdlEventKind.GamepadAdded event.
    ///
    ///  This string shows an example of a valid mapping for a gamepad:
    ///
    ///  ```
    ///  '341a3608000000000000504944564944,Afterglow PS3 Controller,'+
    ///  'a:b1,b:b2,y:b3,x:b0,start:b9,guide:b12,back:b8,dpup:h0.1,dpleft:h0.8,'+
    ///  'dpdown:h0.4,dpright:h0.2,leftshoulder:b4,rightshoulder:b5,'+
    ///  'leftstick:b10,rightstick:b11,leftx:a0,lefty:a1,rightx:a2,righty:a3,'+
    ///  'lefttrigger:b6,righttrigger:b7'
    ///  ```
    /// </summary>
    /// <param name="AMapping">The mapping string.</param>
    /// <returns>True if a new mapping is added, False if an existing mapping is updated.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AddMappings"/>
    /// <seealso cref="Mappings"/>
    /// <seealso cref="MappingForGuid"/>
    /// <seealso cref="TSdlHints.GameControllerConfig"/>
    /// <seealso cref="TSdlHints.GameControllerConfigFile"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function AddMapping(const AMapping: String): Boolean; inline; static;

    /// <summary>
    ///  Load a set of gamepad mappings from a TSdlIOStream.
    ///
    ///  You can call this method several times, if needed, to load different
    ///  database files.
    ///
    ///  If a new mapping is loaded for an already known gamepad GUID, the later
    ///  version will overwrite the one currently loaded.
    ///
    ///  Any new mappings for already plugged in controllers will generate
    ///  TSdlEventKind.GamepadAdded events.
    ///
    ///  Mappings not belonging to the current platform or with no platform field
    ///  specified will be ignored (i.e. mappings for Linux will be ignored in
    ///  Windows, etc).
    ///
    ///  This function will load the text database entirely in memory before
    ///  processing it, so take this into consideration if you are in a memory
    ///  constrained environment.
    /// </summary>
    /// <param name="ASrc">The data stream for the mappings to be added.</param>
    /// <param name="ACloseIO">If true, calls TSdlIOStream.Close on `ASrc`
    ///  before returning, even in the case of an error.</param>
    /// <returns>The number of mappings added.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AddMapping"/>
    /// <seealso cref="Mappings"/>
    /// <seealso cref="MappingForGuid"/>
    /// <seealso cref="TSdlHints.GameControllerConfig"/>
    /// <seealso cref="TSdlHints.GameControllerConfigFile"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function AddMappings(const ASrc: TSdlIOStream;
      const ACloseIO: Boolean): Integer; overload; inline; static;

    /// <summary>
    ///  Load a set of gamepad mappings from a file.
    ///
    ///  You can call this method several times, if needed, to load different
    ///  database files.
    ///
    ///  If a new mapping is loaded for an already known gamepad GUID, the later
    ///  version will overwrite the one currently loaded.
    ///
    ///  Any new mappings for already plugged in controllers will generate
    ///  TSdlEventKind.GamepadAdded events.
    ///
    ///  Mappings not belonging to the current platform or with no platform field
    ///  specified will be ignored (i.e. mappings for Linux will be ignored in
    ///  Windows, etc).
    /// </summary>
    /// <param name="AFilename">The mappings file to load.</param>
    /// <returns>The number of mappings added.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AddMapping"/>
    /// <seealso cref="Mappings"/>
    /// <seealso cref="MappingForGuid"/>
    /// <seealso cref="TSdlHints.GameControllerConfig"/>
    /// <seealso cref="TSdlHints.GameControllerConfigFile"/>
    /// <remarks>
    ///  It is safe to call this method from any thread.
    /// </remarks>
    class function AddMappings(const AFilename: String): Integer; overload; inline; static;

    /// <summary>
    ///  Reinitialize the SDL mapping database to its initial state.
    ///
    ///  This will generate gamepad events as needed if device mappings change.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class procedure ReloadMappings; inline; static;

    /// <summary>
    ///  Get the gamepad mapping string for a given GUID.
    /// </summary>
    /// <param name="AGuid">The GUID for which a mapping is desired.</param>
    /// <returns>The mapping string.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlJoystickID.Guid"/>
    /// <seealso cref="TSdlJoystick.Guid"/>
    class function MappingForGuid(const AGuid: TGuid): String; static;

    /// <summary>
    ///  Manually pump gamepad updates if not using the loop.
    ///
    ///  This method is called automatically by the event loop if events are
    ///  enabled. Under such circumstances, it will not be necessary to call this
    ///  method.
    /// </summary>
    class procedure Update; inline; static;

    /// <summary>
    ///  Get the battery state of the gamepad.
    ///
    ///  You should never take a battery status as absolute truth. Batteries
    ///  (especially failing batteries) are delicate hardware, and the values
    ///  reported here are best estimates based on what that hardware reports. It's
    ///  not uncommon for older batteries to lose stored power much faster than it
    ///  reports, or completely drain when reporting it has 20 percent left, etc.
    /// </summary>
    /// <param name="APercent">Set to the percentage of battery life left,
    ///  between 0 and 100. Will be set to  -1 if we can't determine a value or
    ///  there is no battery.</param>
    /// <returns>The current battery state.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function GetPowerInfo(out APercent: Integer): TSdlPowerState; inline;

    /// <summary>
    ///  Whether the gamepad has a given axis.
    ///
    ///  This merely reports whether the gamepad's mapping defined this axis, as
    ///  that is all the information SDL has about the physical device.
    /// </summary>
    /// <param name="AAxis">The axis enum value.</param>
    /// <returns>True if the gamepad has this axis, False otherwise.</returns>
    /// <seealso cref="HasButton"/>
    /// <seealso cref="Axis"/>
    function HasAxis(const AAxis: TSdlGamepadAxis): Boolean; inline;

    /// <summary>
    ///  Whether the gamepad has a given button.
    ///
    ///  This merely reports whether the gamepad's mapping defined this button, as
    ///  that is all the information SDL has about the physical device.
    /// </summary>
    /// <param name="AButton">The button enum value.</param>
    /// <returns>True if the gamepad has this button, False otherwise.</returns>
    /// <seealso cref="HasAxis"/>
    /// <seealso cref="Button"/>
    function HasButton(const AButton: TSdlGamepadButton): Boolean; inline;

    /// <summary>
    ///  Get the label of a button on the gamepad.
    /// </summary>
    /// <param name="AButton">The button.</param>
    /// <returns>The TSdlGamepadButtonLabel enum corresponding to the button label.</returns>
    /// <seealso cref="TSdlGamepadKind.GetButtonLabel"/>
    function GetButtonLabel(const AButton: TSdlGamepadButton): TSdlGamepadButtonLabel; inline;

    /// <summary>
    ///  Get the current state of a finger on a touchpad on a gamepad.
    /// </summary>
    /// <param name="ATouchpad">The touchpad index.</param>
    /// <param name="AFinger">The finger index.</param>
    /// <param name="AIsDown">Is set to True if the finger is down, False otherwise.</param>
    /// <param name="AX">Is set to the X position, normalized 0 to 1, with the
    ///  origin in the upper left.</param>
    /// <param name="AY">Is set to the Y position, normalized 0 to 1, with the
    ///  origin in the upper left.</param>
    /// <param name="APressure">Is set to the pressure value.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="NumTouchpadFingers"/>
    procedure GetTouchpadFinger(const ATouchpad, AFinger: Integer;
      out AIsDown: Boolean; out AX, AY, APressure: Single); inline;

    /// <summary>
    ///  Whether a gamepad has a particular sensor.
    /// </summary>
    /// <param name="AKind">The type of sensor to query.</param>
    /// <returns>True if the sensor exists, False otherwise.</returns>
    /// <seealso cref="GetSensorData"/>
    /// <seealso cref="SensorDataRate"/>
    /// <seealso cref="SensorEnabled"/>
    /// <remarks>
    ///  This function is available since SDL 3.2.0.
    /// </remarks>
    function HasSensor(const AKind: TSdlSensorKind): Boolean; inline;

    /// <summary>
    ///  Get the current state of the gamepad sensor.
    ///
    ///  The number of values and interpretation of the data is sensor dependent.
    ///  The length of the AData array is the maximum number of values that will
    ///  be written to the array.
    /// </summary>
    /// <param name="AKind">The type of sensor to query.</param>
    /// <param name="AData">An array filled with the current sensor state.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure GetSensorData(const AKind: TSdlSensorKind;
      const AData: TArray<Single>); inline;

    /// <summary>
    ///  Start a rumble effect on the gamepad.
    ///
    ///  Each call to this method cancels any previous rumble effect, and calling
    ///  it with 0 intensity stops any rumbling.
    ///
    ///  This method requires you to process SDL events or call
    ///  TSdlJoysticks.Update to update rumble state.
    /// </summary>
    /// <param name="ALowFrequencyRumble">The intensity of the low frequency
    ///  (left) rumble motor, from 0 to $FFFF.</param>
    /// <param name="AHighFrequencyRumble">The intensity of the high frequency
    ///  (right) rumble motor, from 0 to $FFFF.</param>
    /// <param name="ADurationMs">The duration of the rumble effect, in milliseconds.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure Rumble(const ALowFrequencyRumble, AHighFrequencyRumble: Word;
      const ADurationMs: Integer); inline;

    /// <summary>
    ///  Start a rumble effect in the gamepad's triggers.
    ///
    ///  Each call to this method cancels any previous trigger rumble effect, and
    ///  calling it with 0 intensity stops any rumbling.
    ///
    ///  Note that this is rumbling of the _triggers_ and not the gamepad as a
    ///  whole. This is currently only supported on Xbox One gamepads. If you want
    ///  the (more common) whole-gamepad rumble, use Rumble instead.
    ///
    ///  This method requires you to process SDL events or call
    ///  TSdlJoysticks.Update to update rumble state.
    /// </summary>
    /// <param name="ALeftRumble">The intensity of the left trigger rumble motor,
    ///  from 0 to $FFFF.</param>
    /// <param name="ARightRumble">The intensity of the right trigger rumble motor,
    ///  from 0 to $FFFF.</param>
    /// <param name="ADurationMs">the duration of the rumble effect, in milliseconds.</param>
    /// <seealso cref="Rumble"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure RumbleTriggers(const ALeftRumble, ARightRumble: Word;
      const ADurationMs: Integer); inline;

    /// <summary>
    ///  Update the gamepad's LED color.
    ///
    ///  An example of a joystick LED is the light on the back of a PlayStation 4's
    ///  DualShock 4 controller.
    ///
    ///  For gamepads with a single color LED, the maximum of the RGB values will be
    ///  used as the LED brightness.
    /// </summary>
    /// <param name="ARed">The intensity of the red LED.</param>
    /// <param name="AGreen">The intensity of the green LED.</param>
    /// <param name="ABlue">The intensity of the blue LED.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetLed(const ARed, AGreen, ABlue: Byte); inline;

    /// <summary>
    ///  Send a gamepad specific effect packet.
    /// </summary>
    /// <param name="AData">The data to send to the gamepad.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SendEffect(const AData: TBytes); inline;

    /// <summary>
    ///  The sfSymbolsName for a given button on a gamepad on Apple platforms,
    ///  or an empty string if not found.
    /// </summary>
    /// <param name="AButton">A button on the gamepad.</param>
    function AppleSFSymbolsNameFor(const AButton: TSdlGamepadButton): String; overload; inline;

    /// <summary>
    ///  The sfSymbolsName for a given axis on a gamepad on Apple platforms,
    ///  or an empty string if not found.
    /// </summary>
    /// <param name="AAxis">A button on the gamepad.</param>
    function AppleSFSymbolsNameFor(const AAxis: TSdlGamepadAxis): String; overload; inline;

    /// <summary>
    ///  The implementation-dependent name for this opened gamepad, or an empty
    ///  string if not available.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.Name"/>
    property Name: String read GetName;

    /// <summary>
    ///  The implementation-dependent path for this opened gamepad, or an empty
    ///  string if not available.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.Path"/>
    property Path: String read GetPath;

    /// <summary>
    ///  The type of this opened gamepad.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.Kind"/>
    property Kind: TSdlGamepadKind read GetKind;

    /// <summary>
    ///  The type of this opened gamepad, ignoring any mapping override.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.RealKind"/>
    property RealKind: TSdlGamepadKind read GetRealKind;

    /// <summary>
    ///  The player index of this opened gamepad, or -1 if not available.
    ///
    ///  Set this property to -1 to clear the player index and turn off
    ///  player LEDs.
    ///
    ///  For XInput gamepads this returns the XInput user index.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property PlayerIndex: Integer read GetPlayerIndex write SetPlayerIndex;

    /// <summary>
    ///  The USB vendor ID of this opened gamepad, if available.
    ///
    ///  If the vendor ID isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.Vendor"/>
    property Vendor: Word read GetVendor;

    /// <summary>
    ///  The USB product ID of this opened gamepad, if available.
    ///
    ///  If the product ID isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.Product"/>
    property Product: Word read GetProduct;

    /// <summary>
    ///  The product version of this opened gamepad, if available.
    ///
    ///  If the product version isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlGamepadID.ProductVersion"/>
    property ProductVersion: Word read GetProductVersion;

    /// <summary>
    ///  The firmware version of this opened gamepad, if available.
    ///
    ///  If the firmware version isn't available this property returns 0.
    /// </summary>
    property FirmwareVersion: Word read GetFirmwareVersion;

    /// <summary>
    ///  The serial number of this opened gamepad, or an empty string if
    ///  not available.
    /// </summary>
    property Serial: String read GetSerial;

    /// <summary>
    ///  Get the Steam Input handle of this opened gamepad, or 0 if not available.
    ///
    ///  Returns a handle for the gamepad that can be used with 
    ///  <see href="https://partner.steamgames.com/doc/api/ISteamInput">Steam Input API</see>.
    /// </summary>
    property SteamHandle: UInt64 read GetSteamHandle;

    /// <summary>
    ///  The connection state of a gamepad.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property ConnectionState: TSdlGamepadConnectionState read GetConnectionState;

    /// <summary>
    ///  Whether the gamepad has been opened and is currently connected.
    /// </summary>
    property IsConnected: Boolean read GetIsConnected;

    /// <summary>
    ///  The current state of an axis control on the gamepad.
    ///
    ///  For thumbsticks, the state is a value ranging from -32768 (up/left) to
    ///  32767 (down/right).
    ///
    ///  Triggers range from 0 when released to 32767 when fully pressed, and never
    ///  return a negative value. Note that this differs from the value reported by
    ///  the lower-level TSdlJoystick.Axis, which normally uses the full range.
    /// </summary>
    /// <param name="AAxis">The axis.</param>
    /// <seealso cref="HasAxis"/>
    /// <seealso cref="Button"/>
    property Axis[const AAxis: TSdlGamepadAxis]: Smallint read GetAxis;

    /// <summary>
    ///  The current state of a button on the gamepad.
    ///
    /// <returns>True if the button is pressed, False otherwise.</returns>
    /// </summary>
    /// <param name="AButton">The button.</param>
    /// <seealso cref="HasButton"/>
    /// <seealso cref="Axis"/>
    property Button[const AButton: TSdlGamepadButton]: Boolean read GetButton;

    /// <summary>
    ///  The number of touchpads on the gamepad.
    /// </summary>
    property NumTouchpads: Integer read GetNumTouchpads;

    /// <summary>
    ///  The number of supported simultaneous fingers on a touchpad on a game
    ///  gamepad.
    /// </summary>
    /// <param name="ATouchpad">Touchpad index.</param>
    /// <seealso cref="GetTouchpadFinger"/>
    /// <seealso cref="NumTouchpads"/>
    property NumTouchpadFingers[const ATouchPad: Integer]: Integer read GetNumTouchpadFingers;

    /// <summary>
    ///  Whether data reporting for a gamepad sensor is enabled.
    /// </summary>
    /// <param name="AKind">The type of sensor to enable/disable.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="HasSensor"/>
    property SensorEnabled[const AKind: TSdlSensorKind]: Boolean read GetSensorEnabled write SetSensorEnabled;

    /// <summary>
    ///  The data rate (number of events per second) of a gamepad sensor, or 0.0
    ///  if not available.
    /// </summary>
    /// <param name="AKind">The type of sensor to query.</param>
    property SensorDataRate[const AKind: TSdlSensorKind]: Single read GetSensorDataRate;

    /// <summary>
    ///  The current mapping of this gamepad.
    ///
    ///  Details about mappings are discussed with AddMapping.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="AddMapping"/>
    /// <seealso cref="TSdlGamepadID.Mapping"/>
    /// <seealso cref="MappingForGuid"/>
    property Mapping: String read GetMapping write SetMapping;

    /// <summary>
    ///  Get the SDL joystick layer bindings for a gamepad.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Bindings: TArray<TSdlGamepadBinding> read GetBindings;

    /// <summary>
    ///  The instance ID of this opened gamepad.
    /// </summary>
    /// <param name="AGamepad">a gamepad identifier previously returned by SDL_OpenGamepad().</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property ID: TSdlGamepadID read GetID;

    /// <summary>
    ///  The properties associated with this opened gamepad.
    ///
    ///  These properties are shared with the underlying joystick object.
    ///
    ///  The following read-only properties are provided by SDL:
    ///
    ///  - `TSdlProperty.GamepadCapMonoLed`: True if this gamepad has an LED
    ///    that has adjustable brightness
    ///  - `TSdlProperty.GamepadCapRgbLed`: True if this gamepad has an LED
    ///    that has adjustable color
    ///  - `TSdlProperty.GamepadCapPlayerLed`: True if this gamepad has a
    ///    player LED
    ///  - `TSdlProperty.GamepadCapRumble`: True if this gamepad has
    ///    left/right rumble
    ///  - `TSdlProperty.GamepadCapTriggerRumble`: True if this gamepad has
    ///    simple trigger rumble
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Properties: TSdlProperties read GetProperties;

    /// <summary>
    ///  Whether a gamepad is currently connected.
    /// </summary>
    /// <seealso cref="Gamepads"/>
    class property HasGamepad: Boolean read GetHasGamepad;

    /// <summary>
    ///  A list of currently connected gamepads.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="HasGamepad"/>
    /// <seealso cref="Open"/>
    class property Gamepads: TArray<TSdlGamepadID> read GetGamepads;

    /// <summary>
    ///  The current gamepad mappings.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class property Mappings: TArray<String> read GetMappings;

    /// <summary>
    ///  Set the state of gamepad event processing.
    ///
    ///  If gamepad events are disabled, you must call Update yourself
    ///  and check the state of the gamepad when you want gamepad information.
    /// </summary>
    /// <seealso cref="Update"/>
    class property EventsEnabled: Boolean read GetEventsEnabled write SetEventsEnabled;
  end;
{$ENDREGION 'Gamepad'}

{$REGION 'Joystick'}
/// <summary>
///  SDL joystick support.
///
///  This is the lower-level joystick handling. If you want the simpler option,
///  where what each button does is well-defined, you should use the gamepad API
///  instead.
///
///  The term "InstanceID" is the current instantiation of a joystick device in
///  the system, if the joystick is removed and then re-inserted then it will
///  get a new InstanceID, InstanceID's are monotonically increasing
///  identifiers of a joystick plugged in.
///
///  The term "PlayerIndex" is the number assigned to a player on a specific
///  controller. For XInput controllers this returns the XInput user index. Many
///  joysticks will not be able to supply this information.
///
///  SDL_GUID is used as a stable 128-bit identifier for a joystick device that
///  does not change over time. It identifies class of the device (a X360 wired
///  controller for example). This identifier is platform dependent.
///
///  In order to use these functions, SdlInit must have been called with the
///  TSdlInitFlag.Joystick flag. This causes SDL to scan the system for joysticks,
///  and load appropriate drivers.
///
///  If you would like to receive joystick updates while the application is in
///  the background, you should set the following hint before calling
///  SdlInit: TSdlHints.JoystickAllowBackgroundEvents
/// </summary>

type
  /// <summary>
  ///  An enum of some common joystick types.
  ///
  ///  In some cases, SDL can identify a low-level joystick as being a certain
  ///  type of device, and will report it through TSdlJoystick.Kind.
  ///
  ///  This is by no means a complete list of everything that can be plugged into
  ///  a computer.
  /// </summary>
  TSdlJoystickKind = (
    Unknown     = SDL_JOYSTICK_TYPE_UNKNOWN,
    Gamepad     = SDL_JOYSTICK_TYPE_GAMEPAD,
    Wheel       = SDL_JOYSTICK_TYPE_WHEEL,
    ArcadeStick = SDL_JOYSTICK_TYPE_ARCADE_STICK,
    FlightStick = SDL_JOYSTICK_TYPE_FLIGHT_STICK,
    DancePad    = SDL_JOYSTICK_TYPE_DANCE_PAD,
    Guitar      = SDL_JOYSTICK_TYPE_GUITAR,
    DrumKit     = SDL_JOYSTICK_TYPE_DRUM_KIT,
    ArcadePad   = SDL_JOYSTICK_TYPE_ARCADE_PAD,
    Throttle    = SDL_JOYSTICK_TYPE_THROTTLE);

type
  /// <summary>
  ///  Possible connection states for a joystick device.
  ///
  ///  This is used by TSdlJoystick.ConnectionState to report how a device is
  ///  connected to the system.
  /// </summary>
  TSdlJoystickConnectionState = (
    Invalid  = SDL_JOYSTICK_CONNECTION_INVALID,
    Unknown  = SDL_JOYSTICK_CONNECTION_UNKNOWN,
    Wired    = SDL_JOYSTICK_CONNECTION_WIRED,
    Wireless = SDL_JOYSTICK_CONNECTION_WIRELESS);

const
  /// <summary>
  ///  The largest value an SDL_Joystick's axis can report.
  /// </summary>
  /// <seealso cref="SDL_JOYSTICK_AXIS_MIN"/>
  SDL_JOYSTICK_AXIS_MAX = Neslib.Sdl3.Api.SDL_JOYSTICK_AXIS_MAX; // 32767

const
  /// <summary>
  ///  The smallest value an SDL_Joystick's axis can report.
  ///
  ///  This is a negative number!
  /// </summary>
  /// <seealso cref="SDL_JOYSTICK_AXIS_MAX"/>
  SDL_JOYSTICK_AXIS_MIN = Neslib.Sdl3.Api.SDL_JOYSTICK_AXIS_MIN; // -32768

type
  /// <summary>
  ///  Joystick Hat positions
  /// </summary>
  TSdlHat = (
    Up    = 0,
    Right = 1,
    Down  = 2,
    Left  = 3);

type
  /// <summary>
  ///  A sert of joystick Hat positions
  /// </summary>
  TSdlHats = set of TSdlHat;

type
  /// <summary>
  ///  This is a unique ID for a joystick for the time it is connected to the
  ///  system, and is never reused for the lifetime of the application.
  ///
  ///  If the joystick is disconnected and reconnected, it will get a new ID.
  /// </summary>
  TSdlJoystickID = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_JoystickID;
    function GetName: String; inline;
    function GetPath: String; inline;
    function GetPlayerIndex: Integer; inline;
    function GetGuid: TGuid; inline;
    function GetVendor: Word; inline;
    function GetProduct: Word; inline;
    function GetProductVersion: Word; inline;
    function GetKind: TSdlJoystickKind; inline;
    function GetIsVirtual: Boolean; inline;
    function GetIsGamepad: Boolean; inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator Equal(const ALeft: TSdlJoystickID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlJoystickID.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlJoystickID): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `0`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlJoystickID; const ARight: Cardinal): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlJoystickID.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlJoystickID): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `0`.
    /// </summary>
    class operator Implicit(const AValue: Cardinal): TSdlJoystickID; inline; static;
  public
    /// <summary>
    ///  The implementation dependent name of the joystick or an empty string
    ///  if not available.
    ///
    ///  This can be used before any joysticks are opened.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Name"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property Name: String read GetName;

    /// <summary>
    ///  The implementation dependent path of the joystick or an empty string
    ///  if not available.
    ///
    ///  This can be used before any joysticks are opened.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Path"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property Path: String read GetPath;

    /// <summary>
    ///  Get the player index of the joystick, or -1 of not available.
    ///
    ///  This can be used before any joysticks are opened.
    /// </summary>
    /// <seealso cref="TSdlJoystick.PlayerIndex"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property PlayerIndex: Integer read GetPlayerIndex;

    /// <summary>
    ///  The implementation-dependent GUID of the joystick.
    ///
    ///  This can be used before any joysticks are opened.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Guid"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property Guid: TGuid read GetGuid;

    /// <summary>
    ///  The USB vendor ID of the joystick, if available.
    ///
    ///  This can be used before any joysticks are opened. If the vendor ID isn't
    ///  available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Vendor"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property Vendor: Word read GetVendor;

    /// <summary>
    ///  The USB product ID of the joystick, if available.
    ///
    ///  This can be used before any joysticks are opened. If the product ID isn't
    ///  available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Product"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property Product: Word read GetProduct;

    /// <summary>
    ///  The product version of the joystick, if available.
    ///
    ///  This can be used before any joysticks are opened. If the product version
    ///  isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlJoystick.ProductVersion"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property ProductVersion: Word read GetProductVersion;

    /// <summary>
    ///  The type of a joystick, if available.
    ///
    ///  This can be used before any joysticks are opened.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Kind"/>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    property Kind: TSdlJoystickKind read GetKind;

    /// <summary>
    ///  Whether or not this joystick is virtual.
    /// </summary>
    property IsVirtual: Boolean read GetIsVirtual;

    /// <summary>
    ///  Whether this joystick is supported by the gamepad interface.
    /// </summary>
    /// <seealso cref="TSdlJoystick.Joysticks"/>
    /// <seealso cref="TSdlGamepad.Open"/>
    property IsGamepad: Boolean read GetIsGamepad;

    /// <summary>
    ///  Get the implementation dependent name of a gamepad.
    ///
    ///  This can be called before any gamepads are opened.
    /// </summary>
    /// <param name="AInstanceId">the joystick instance ID.</param>
    /// <returns>the name of the selected gamepad. If no name can be found, this function returns NULL; call SDL_GetError() for more information.</returns>
    /// <seealso cref="SDL_GetGamepadName"/>
    /// <seealso cref="SDL_GetGamepads"/>
    /// <remarks>
    ///  This function is available since SDL 3.2.0.
    /// </remarks>

    /// The ID of the joystick
    property ID: Cardinal read FHandle;
  end;

type
  /// <summary>
  ///  An SDL joystick
  /// </summary>
  TSdlJoystick = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_Joystick;
    function GetName: String; inline;
    function GetPath: String; inline;
    function GetPlayerIndex: Integer; inline;
    procedure SetPlayerIndex(const AValue: Integer); inline;
    function GetGuid: TGuid; inline;
    function GetVendor: Word; inline;
    function GetProduct: Word; inline;
    function GetProductVersion: Word; inline;
    function GetFirmwareVersion: Word; inline;
    function GetSerial: String; inline;
    function GetKind: TSdlJoystickKind; inline;
    function GetIsConnected: Boolean; inline;
    function GetID: TSdlJoystickID; inline;
    function GetNumAxes: Integer; inline;
    function GetAxis(const AAxis: Integer): Smallint; inline;
    function GetNumBalls: Integer; inline;
    function GetBall(const ABall: Integer): TSdlPoint; inline;
    function GetNumHats: Integer; inline;
    function GetHats(const AHat: Integer): TSdlHats; inline;
    function GetNumButtons: Integer; inline;
    function GetButton(const AButton: Integer): Boolean; inline;
    function GetConnectionState: TsdlJoystickConnectionState; inline;
    function GetProperties: TSdlProperties; inline;
    class function GetHasJoystick: Boolean; inline; static;
    class function GetJoysticks: TArray<TSdlJoystickID>; inline; static;
    class function GetEventsEnabled: Boolean; inline; static;
    class procedure SetEventsEnabled(const AValue: Boolean); inline; static;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator Equal(const ALeft: TSdlJoystick; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlJoystick.
    /// </summary>
    class operator Equal(const ALeft, ARight: TSdlJoystick): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against `nil`.
    /// </summary>
    class operator NotEqual(const ALeft: TSdlJoystick; const ARight: Pointer): Boolean; inline; static;

    /// <summary>
    ///  Used to compare against another TSdlJoystick.
    /// </summary>
    class operator NotEqual(const ALeft, ARight: TSdlJoystick): Boolean; inline; static;

    /// <summary>
    ///  Used to set the value to `nil`.
    /// </summary>
    class operator Implicit(const AValue: Pointer): TSdlJoystick; inline; static;
  public
    /// <summary>
    ///  Open a joystick for use.
    ///
    ///  The joystick subsystem must be initialized before a joystick can be opened
    ///  for use.
    /// </summary>
    /// <param name="AIstanceID">The joystick instance ID.</param>
    /// <returns>The opened joystick.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Close"/>
    class function Open(const AInstanceID: TSdlJoystickID): TSdlJoystick; inline; static;

    /// <summary>
    ///  Close a joystick previously opened with Open.
    /// </summary>
    /// <seealso cref="Open"/>
    procedure Close; inline;

    /// <summary>
    ///  Get the joystick associated with an instance ID, if it has been opened.
    /// </summary>
    /// <param name="AInstanceID">The instance ID to get the joystick for.</param>
    /// <returns>The opened joystick.</returns>
    /// <exception name="ESdlError">Raised on failure (eg. when the joystick
    ///  hasn't been opened).</exception>
    class function FromID(const AInstanceID: TSdlJoystickID): TSdlJoystick; inline; static;

    /// <summary>
    ///  Get the joystick associated with a player index.
    /// </summary>
    /// <param name="APlayerIndex">The player index to get the joystick for.</param>
    /// <returns>The opened joystick.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="PlayerIndex"/>
    class function FromPlayerIndex(const APlayerIndex: Integer): TSdlJoystick; inline; static;

    /// <summary>
    ///  Get the underlying joystick from a gamepad.
    ///
    ///  This function will give you a TSdlJoystick object, which allows you to use
    ///  its properties and methods a TSdlGamepad object. This would be useful
    ///  for getting a joystick's position at any given time, even if it hasn't
    ///  moved (moving it would produce an event, which would have the axis' value).
    ///
    ///  The returned joystick is owned by the gamepad. You should not call
    ///  Close on it, for example, since doing so will likely cause SDL to crash.
    /// </summary>
    /// <param name="AGamepad">The gamepad object that you want to get a joystick from.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    class function FromGamepad(const AGamepad: TSdlGamepad): TSdlJoystick; inline; static;

    /// <summary>
    ///  Locking for atomic access to the joystick API.
    ///
    ///  The SDL joystick functions are thread-safe, however you can lock the
    ///  joysticks while processing to guarantee that the joystick list won't change
    ///  and joystick and gamepad events will not be delivered.
    /// </summary>
    class procedure Lock; inline; static;

    /// <summary>
    ///  Unlocking for atomic access to the joystick API.
    /// </summary>
    class procedure Unlock; inline; static;

    /// <summary>
    ///  Update the current state of the open joysticks.
    ///
    ///  This is called automatically by the event loop if any joystick events are
    ///  enabled.
    /// </summary>
    class procedure Update; inline; static;

    /// <summary>
    ///  Set the state of an axis on this opened virtual joystick.
    ///
    ///  Please note that values set here will not be applied until the next call to
    ///  Update, which can either be called directly, or can be called indirectly
    ///  through various other SDL APIs, including, but not limited to
    ///  the following: TSdlEvents.Poll, TSdlEvents.Pump and TSdlEvents.Wait.
    ///
    ///  Note that when sending trigger axes, you should scale the value to the full
    ///  range of Int16. For example, a trigger at rest would have the value of
    ///  `SDL_JOYSTICK_AXIS_MIN`.
    /// </summary>
    /// <param name="AAxis">The index of the axis on the virtual joystick to update.</param>
    /// <param name="AValue">The new value for the specified axis.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetVirtualAxis(const AAxis: Integer; const AValue: Smallint); inline;

    /// <summary>
    ///  Generate ball motion on this opened virtual joystick.
    ///
    ///  Please note that values set here will not be applied until the next call to
    ///  Update, which can either be called directly, or can be called indirectly
    ///  through various other SDL APIs, including, but not limited to
    ///  the following: TSdlEvents.Poll, TSdlEvents.Pump and TSdlEvents.Wait.
    /// </summary>
    /// <param name="ABall">The index of the ball on the virtual joystick to update.</param>
    /// <param name="AXRel">The relative motion on the X axis.</param>
    /// <param name="AYRel">The relative motion on the Y axis.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetVirtualBall(const ABall: Integer; const AXRel, AYRel: Smallint); inline;

    /// <summary>
    ///  Set the state of a button on this opened virtual joystick.
    ///
    ///  Please note that values set here will not be applied until the next call to
    ///  Update, which can either be called directly, or can be called indirectly
    ///  through various other SDL APIs, including, but not limited to
    ///  the following: TSdlEvents.Poll, TSdlEvents.Pump and TSdlEvents.Wait.
    /// </summary>
    /// <param name="AButton">The index of the button on the virtual joystick to update.</param>
    /// <param name="AIsDown">True if the button is pressed, False otherwise.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetVirtualButton(const AButton: Integer; const AIsDown: Boolean); inline;

    /// <summary>
    ///  Set the state of a hat on an opened virtual joystick.
    ///
    ///  Please note that values set here will not be applied until the next call to
    ///  Update, which can either be called directly, or can be called indirectly
    ///  through various other SDL APIs, including, but not limited to
    ///  the following: TSdlEvents.Poll, TSdlEvents.Pump and TSdlEvents.Wait.
    /// </summary>
    /// <param name="AHat">The index of the hat on the virtual joystick to update.</param>
    /// <param name="AValue">The new value for the specified hat.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetVirtualHat(const AHat: Integer; const AValue: Byte); inline;

    /// <summary>
    ///  Set touchpad finger state on an opened virtual joystick.
    ///
    ///  Please note that values set here will not be applied until the next call to
    ///  Update, which can either be called directly, or can be called indirectly
    ///  through various other SDL APIs, including, but not limited to
    ///  the following: TSdlEvents.Poll, TSdlEvents.Pump and TSdlEvents.Wait.
    /// </summary>
    /// <param name="ATouchpad">The index of the touchpad on the virtual joystick to update.</param>
    /// <param name="AFinger">The index of the finger on the touchpad to set.</param>
    /// <param name="AIsDown">True if the finger is pressed, False if the finger is released.</param>
    /// <param name="AX">The X coordinate of the finger on the touchpad,
    ///  normalized 0 to 1, with the origin in the upper left.</param>
    /// <param name="AY">The Y coordinate of the finger on the touchpad,
    ///  normalized 0 to 1, with the origin in the upper left.</param>
    /// <param name="APressure">The pressure of the finger.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetVirtualTouchpad(const ATouchpad, AFinger: Integer;
      const AIsDown: Boolean; const AX, AY, APressure: Single); inline;

    /// <summary>
    ///  Send a sensor update for an opened virtual joystick.
    ///
    ///  Please note that values set here will not be applied until the next call to
    ///  Update, which can either be called directly, or can be called indirectly
    ///  through various other SDL APIs, including, but not limited to
    ///  the following: TSdlEvents.Poll, TSdlEvents.Pump and TSdlEvents.Wait.
    /// </summary>
    /// <param name="AKind">The type of the sensor on the virtual joystick to update.</param>
    /// <param name="ATimestamp">A 64-bit timestamp in nanoseconds associated
    ///  with the sensor reading.</param>
    /// <param name="AData">The data associated with the sensor reading.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetVirtualSensorData(const AKind: TSdlSensorKind;
      const ATimestamp: Int64; const AData: TArray<Single>); inline;

    /// <summary>
    ///  Get the initial state of an axis control on the joystick.
    ///
    ///  The state is a value ranging from -32768 to 32767.
    ///
    ///  The axis indices start at index 0.
    /// </summary>
    /// <param name="AAxis">The axis to query; the axis indices start at index 0.</param>
    /// <param name="AState">Upon return, the initial value is supplied here.</param>
    /// <returns>True if this axis has any initial value, or False if not.</returns>
    function AxisInitialState(const AAxis: Integer; out AState: Smallint): Boolean; inline;

    /// <summary>
    ///  Start a rumble effect.
    ///
    ///  Each call to this method cancels any previous rumble effect, and calling
    ///  it with 0 intensity stops any rumbling.
    ///
    ///  This method requires you to process SDL events or call Update to update
    ///  rumble state.
    /// </summary>
    /// <param name="ALowFrequencyRumble">The intensity of the low frequency
    ///  (left) rumble motor, from 0 to $FFFF.</param>
    /// <param name="AHighFrequencyRumble">The intensity of the high frequency
    ///  (right) rumble motor, from 0 to $FFFF.</param>
    /// <param name="ADurationMs">The duration of the rumble effect, in milliseconds.</param>
    /// <returns>True, or False if rumble isn't supported on this joystick.</returns>
    function Rumble(const ALowFrequencyRumble, AHighFrequencyRumble: Word;
      const ADurationMs: Integer): Boolean; inline;

    /// <summary>
    ///  Start a rumble effect in the joystick's triggers.
    ///
    ///  Each call to this method cancels any previous trigger rumble effect, and
    ///  calling it with 0 intensity stops any rumbling.
    ///
    ///  Note that this is rumbling of the _triggers_ and not the game controller as
    ///  a whole. This is currently only supported on Xbox One controllers. If you
    ///  want the (more common) whole-controller rumble, Rumble instead.
    ///
    ///  This method requires you to process SDL events or call Update to update
    ///  rumble state.
    /// </summary>
    /// <param name="ALeftRumble">The intensity of the left trigger rumble motor,
    ///  from 0 to $FFFF.</param>
    /// <param name="ARightRumble">The intensity of the right trigger rumble motor,
    //   from 0 to $FFFF.</param>
    /// <param name="ADurationMs">The duration of the rumble effect, in milliseconds.</param>
    /// <returns>True, or False if rumble isn't supported on this joystick.</returns>
    /// <seealso cref="Rumble"/>
    function RumbleTriggers(const ALeftRumble, ARightRumble: Word;
      const ADurationMs: Integer): Boolean; inline;

    /// <summary>
    ///  Update the joystick's LED color.
    ///
    ///  An example of a joystick LED is the light on the back of a PlayStation 4's
    ///  DualShock 4 controller.
    ///
    ///  For joysticks with a single color LED, the maximum of the RGB values will
    ///  be used as the LED brightness.
    /// </summary>
    /// <param name="ARed">The intensity of the red LED.</param>
    /// <param name="AGreen">The intensity of the green LED.</param>
    /// <param name="ABlue">The intensity of the blue LED.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SetLed(const ARed, AGreen, ABlue: Byte); inline;

    /// <summary>
    ///  Send a joystick specific effect packet.
    /// </summary>
    /// <param name="AData">The data to send to the joystick.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    procedure SendEffect(const AData: TBytes); inline;


    /// <summary>
    ///  Get the battery state of the joystick.
    ///
    ///  You should never take a battery status as absolute truth. Batteries
    ///  (especially failing batteries) are delicate hardware, and the values
    ///  reported here are best estimates based on what that hardware reports. It's
    ///  not uncommon for older batteries to lose stored power much faster than it
    ///  reports, or completely drain when reporting it has 20 percent left, etc.
    /// </summary>
    /// <param name="APercent">Set to the percentage of battery life left,
    ///  between 0 and 100. Will be set to  -1 if we can't determine a value or
    ///  there is no battery.</param>
    /// <returns>The current battery state.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    function GetPowerInfo(out APercent: Integer): TSdlPowerState; inline;

    /// <summary>
    ///  Get the device information encoded in a joystick GUID structure.
    /// </summary>
    /// <param name="AGuid">The GUID you wish to get info about.</param>
    /// <param name="AVendor">Is set to the device VID, or 0 if not available.</param>
    /// <param name="AProduct">Is set to the device PID, or 0 if not available.</param>
    /// <param name="AVersion">Is set to the device version, or 0 if not available.</param>
    /// <param name="ACrc16">Is set to a CRC used to distinguish different
    ///  products with the same VID/PID, or 0 if not available.</param>
    /// <seealso cref="Guid"/>
    /// <seealso cref="TSdlJoystickID.Guid"/>
    class procedure GuidInfo(const AGuid: TGuid; out AVendor, AProduct,
      AVersion, ACrc16: Word); inline; static;

    /// <summary>
    ///  The implementation dependent name of a joystick or an empty string if
    ///  no name can be found.
    /// </summary>
    /// <seealso cref="TSdlJoystickID.Name"/>
    property Name: String read GetName;

    /// <summary>
    ///  The implementation dependent path of a joystick or an empty string if
    ///  no path can be found.
    /// </summary>
    /// <seealso cref="TSdlJoystickID.Path"/>
    property Path: String read GetPath;

    /// <summary>
    ///  The player index of this opened joystick or -1 if not available.
    ///
    ///  For XInput controllers this returns the XInput user index. Many joysticks
    ///  will not be able to supply this information.
    ///
    ///  Set this property to -1 to clear the player index and turn off
    ///  player LEDs.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlJoystickID.PlayerIndex"/>
    property PlayerIndex: Integer read GetPlayerIndex write SetPlayerIndex;

    /// <summary>
    ///  The implementation-dependent GUID for the joystick.
    ///
    ///  This property requires an open joystick.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="TSdlJoystickID.Guid"/>
    property Guid: TGuid read GetGuid;

    /// <summary>
    ///  The USB vendor ID of this opened joystick, if available.
    ///
    ///  If the vendor ID isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlJoystickID.Vendor"/>
    property Vendor: Word read GetVendor;

    /// <summary>
    ///  The USB product ID of this opened joystick, if available.
    ///
    ///  If the product ID isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlJoystickID.Product"/>
    property Product: Word read GetProduct;

    /// <summary>
    ///  The product version of this opened joystick, if available.
    ///
    ///  If the product version isn't available this property returns 0.
    /// </summary>
    /// <seealso cref="TSdlJoystickID.ProductVersion"/>
    property ProductVersion: Word read GetProductVersion;

    /// <summary>
    ///  The firmware version of this opened joystick, if available.
    ///
    ///  If the firmware version isn't available this property returns 0.
    /// </summary>
    property FirmwareVersion: Word read GetFirmwareVersion;

    /// <summary>
    ///  The serial number of this opened joystick, if available.
    ///
    ///  Returns the serial number of the joystick, or an empty string if it is
    ///  not available.
    /// </summary>
    property Serial: String read GetSerial;

    /// <summary>
    ///  The type of this opened joystick.
    /// </summary>
    /// <seealso cref="TSdlJoystickID.Kind"/>
    property Kind: TSdlJoystickKind read GetKind;

    /// <summary>
    ///  Whether the joystick has been opened and is connected.
    /// </summary>
    property IsConnected: Boolean read GetIsConnected;

    /// <summary>
    ///  The instance ID of this opened joystick.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property ID: TSdlJoystickID read GetID;

    /// <summary>
    ///  The number of general axis controls on this joystick.
    ///
    ///  Often, the directional pad on a game controller will either look like 4
    ///  separate buttons or a POV hat, and not axes, but all of this is up to the
    ///  device and platform.
    /// </summary>
    /// <seealso cref="Axis"/>
    /// <seealso cref="NumBalls"/>
    /// <seealso cref="NumButtons"/>
    /// <seealso cref="NumHats"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NumAxes: Integer read GetNumAxes;

    /// <summary>
    ///  The current state of an axis control on the joystick.
    ///
    ///  SDL makes no promises about what part of the joystick any given axis refers
    ///  to. Your game should have some sort of configuration UI to let users
    ///  specify what each axis should be bound to. Alternately, SDL's higher-level
    ///  Game Controller API makes a great effort to apply order to this lower-level
    ///  interface, so you know that a specific axis is the "left thumb stick," etc.
    ///
    ///  The value is a signed 16-bit integer (-32768 to 32767) representing the
    ///  current position of the axis. It may be necessary to impose certain
    ///  tolerances on these values to account for jitter.
    /// </summary>
    /// <param name="AAxis">The axis to query; the axis indices start at index 0.</param>
    /// <seealso cref="NumAxes"/>
    property Axis[const AAxis: Integer]: Smallint read GetAxis;

    /// <summary>
    ///  The number of trackballs on this joystick.
    ///
    ///  Joystick trackballs have only relative motion events associated with them
    ///  and their state cannot be polled.
    ///
    ///  Most joysticks do not have trackballs.
    /// </summary>
    /// <seealso cref="Ball"/>
    /// <seealso cref="NumAxes"/>
    /// <seealso cref="NumButtons"/>
    /// <seealso cref="NumHats"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NumBalls: Integer read GetNumBalls;

    /// <summary>
    ///  The ball axis change since the last poll.
    ///
    ///  Trackballs can only return relative motion since the last retrieval if
    ///  this property. It returns the difference in axis position since the
    ///  last poll.
    ///
    ///  Most joysticks do not have trackballs.
    /// </summary>
    /// <param name="ABall">The ball index to query; ball indices start at index 0.</param>
    /// <seealso cref="NumBalls"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Ball[const ABall: Integer]: TSdlPoint read GetBall;

    /// <summary>
    ///  The number of POV hats on this joystick.
    /// </summary>
    /// <seealso cref="Hats"/>
    /// <seealso cref="NumAxes"/>
    /// <seealso cref="NumBalls"/>
    /// <seealso cref="NumButtons"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NumHats: Integer read GetNumHats;

    /// <summary>
    ///  The current state of a POV hat on the joystick.
    /// </summary>
    /// <param name="AHat">The hat index to get the state from;
    ///  indices start at index 0.</param>
    /// <seealso cref="NumHats"/>
    property Hats[const AHat: Integer]: TSdlHats read GetHats;

    /// <summary>
    ///  The number of buttons on this joystick.
    /// </summary>
    /// <seealso cref="Button"/>
    /// <seealso cref="NumAxes"/>
    /// <seealso cref="NumBalls"/>
    /// <seealso cref="NumHats"/>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property NumButtons: Integer read GetNumButtons;

    /// <summary>
    ///  The current state of a button on the joystick.
    /// </summary>
    /// <param name="AButton">The button index to get the state from;
    ///  indices start at index 0.</param>
    /// <returns>True if the button is pressed, False otherwise.</returns>
    /// <seealso cref="NumButtons"/>
    property Button[const AButton: Integer]: Boolean read GetButton;

    /// <summary>
    ///  The connection state of the joystick.
    /// </summary>
    property ConnectionState: TsdlJoystickConnectionState read GetConnectionState;

    /// <summary>
    ///  The properties associated with the joystick.
    ///
    ///  The following read-only properties are provided by SDL:
    ///
    ///  - `TSdlProperty.JoystickCapMonoLed`: True if this joystick has an
    ///    LED that has adjustable brightness
    ///  - `TSdlProperty.JoystickCapRgbLed`: True if this joystick has an LED
    ///    that has adjustable color
    ///  - `TSdlProperty.JoystickCapPlayerLed`: True if this joystick has a
    ///    player LED
    ///  - `TSdlProperty.JoystickCapRumble`: True if this joystick has
    ///    left/right rumble
    ///  - `TSdlProperty.JoystickCapTriggerRumble`: True if this joystick has
    ///    simple trigger rumble
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    property Properties: TSdlProperties read GetProperties;

    /// <summary>
    ///  Whether a joystick is currently connected.
    /// </summary>
    /// <seealso cref="Joysticks"/>
    class property HasJoystick: Boolean read GetHasJoystick;

    /// <summary>
    ///  A list of currently connected joysticks.
    /// </summary>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="HasJoystick"/>
    /// <seealso cref="Open"/>
    class property Joysticks: TArray<TSdlJoystickID> read GetJoysticks;

    /// <summary>
    ///  The state of joystick event processing.
    ///
    ///  If joystick events are disabled, you must call Update yourself and
    ///  check the state of the joystick when you want joystick
    ///  information.
    /// </summary>
    /// <seealso cref="Update"/>
    class property EventsEnabled: Boolean read GetEventsEnabled write SetEventsEnabled;
  end;

type
  /// <summary>
  ///  A virtual joystick touchpad.
  /// </summary>
  /// <seealso cref="TSdlVirtualJoystickDesc"/>
  TSdlVirtualJoystickTouchpadDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_VirtualJoystickTouchpadDesc;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The number of simultaneous fingers on this touchpad
    /// </summary>
    property NumFingers: Smallint read FHandle.nfingers write FHandle.nfingers;
  end;

type
  /// <summary>
  ///  A virtual joystick sensor.
  /// </summary>
  /// <seealso cref="TSdlVirtualJoystickDesc"/>
  TSdlVirtualJoystickSensorDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_VirtualJoystickSensorDesc;
    function GetKind: TSdlSensorKind; inline;
    procedure SetKind(const AValue: TSdlSensorKind); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  The type of this sensor
    /// </summary>
    property Kind: TSdlSensorKind read GetKind write SetKind;

    /// <summary>
    ///  The update frequency of this sensor, may be 0.0
    /// </summary>
    property Rate: Single read FHandle.rate write FHandle.rate;
  end;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.Update
  /// </summary>
  TSdlVirtualJoystickUpdate = procedure(AUserData: Pointer); cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.SetPlayerIndex
  /// </summary>
  TSdlVirtualJoystickSetPlayerIndex = procedure(AUserData: Pointer;
    APlayerIndex: Integer); cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.Rumble
  /// </summary>
  TSdlVirtualJoystickRumble = function(AUserData: Pointer;
    ALowFrequencyRumble, AHighFrequencyRumble: Word): Boolean; cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.RumbleTriggers
  /// </summary>
  TSdlVirtualJoystickRumbleTriggers = function(AUserData: Pointer;
    ALeftR, ARightRumble: Word): Boolean; cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.SetLed
  /// </summary>
  TSdlVirtualJoystickSetLed = function(AUserData: Pointer;
    ARed, AGreen, ABlue: Byte): Boolean; cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.SendEffect
  /// </summary>
  TSdlVirtualJoystickSendEffect = function(AUserData: Pointer;
    const AData: Pointer; ASize: Integer): Boolean; cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.SetSensorsEnabled
  /// </summary>
  TSdlVirtualJoystickSetSensorsEnabled = function(AUserData: Pointer;
    AEnabled: Boolean): Boolean; cdecl;

type
  /// <summary>
  ///  Callback type for TSdlVirtualJoystickDesc.Cleanup
  /// </summary>
  TSdlVirtualJoystickCleanup = procedure(AUserData: Pointer); cdecl;

type
  /// <summary>
  ///  A virtual joystick.
  ///
  ///  This record should be initialized using Init.
  ///  All members of this record are optional.
  /// </summary>
  /// <seealso cref="TSdlVirtualJoystickDesc.Attach"/>
  /// <seealso cref="TSdlVirtualJoystickDesc.Init"/>
  /// <seealso cref="TSdlVirtualJoystickSensorDesc"/>
  /// <seealso cref="TSdlVirtualJoystickTouchpadDesc"/>
  TSdlVirtualJoystickDesc = record
  {$REGION 'Internal Declarations'}
  private
    FHandle: SDL_VirtualJoystickDesc;
    FName: String;                                       // To keep alive
    FTouchpads: TArray<TSdlVirtualJoystickTouchpadDesc>; // To keep alive
    FSensors: TArray<TSdlVirtualJoystickSensorDesc>;     // To keep alive
    function GetKind: TSdlJoystickKind; inline;
    procedure SetKind(const AValue: TSdlJoystickKind); inline;
    function GetValidButtons: TSdlGamepadButtons; inline;
    function GetValidAxes: TSdlGamepadAxes; inline;
    procedure SetValidAxes(const AValue: TSdlGamepadAxes); inline;
    procedure SetValidButtons(const AValue: TSdlGamepadButtons); inline;
    procedure SetName(const AValue: String); inline;
    procedure SetTouchpads(const AValue: TArray<TSdlVirtualJoystickTouchpadDesc>); inline;
    procedure SetSensors(const AValue: TArray<TSdlVirtualJoystickSensorDesc>); inline;
    function GetUpdate: TSdlVirtualJoystickUpdate; inline;
    procedure SetUpdate(const AValue: TSdlVirtualJoystickUpdate); inline;
    function GetSetPlayerIndex: TSdlVirtualJoystickSetPlayerIndex; inline;
    procedure SetSetPlayerIndex(const AValue: TSdlVirtualJoystickSetPlayerIndex); inline;
    function GetRumble: TSdlVirtualJoystickRumble; inline;
    procedure SetRumble(const AValue: TSdlVirtualJoystickRumble); inline;
    function GetRumbleTriggers: TSdlVirtualJoystickRumbleTriggers; inline;
    procedure SetRumbleTriggers(const AValue: TSdlVirtualJoystickRumbleTriggers); inline;
    function GetSetLed: TSdlVirtualJoystickSetLed; inline;
    procedure SetSetLed(const AValue: TSdlVirtualJoystickSetLed); inline;
    function GetSendEffect: TSdlVirtualJoystickSendEffect; inline;
    procedure SetSendEffect(const AValue: TSdlVirtualJoystickSendEffect); inline;
    function GetSetSensorsEnabled: TSdlVirtualJoystickSetSensorsEnabled; inline;
    procedure SetSetSensorsEnabled(const AValue: TSdlVirtualJoystickSetSensorsEnabled); inline;
    function GetCleanup: TSdlVirtualJoystickCleanup; inline;
    procedure SetCleanup(const AValue: TSdlVirtualJoystickCleanup); inline;
  {$ENDREGION 'Internal Declarations'}
  public
    /// <summary>
    ///  Initializes this record.
    ///  You *must* call this method before attaching it.
    /// </summary>
    /// <seealso cref="Attach"/>
    procedure Init; inline;

    /// <summary>
    ///  Attach a new virtual joystick.
    /// </summary>
    /// <returns>The joystick instance ID.</returns>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Detach"/>
    function Attach: TSdlJoystickID; inline;

    /// <summary>
    ///  Detach a virtual joystick.
    /// </summary>
    /// <param name="AInstanceID">The joystick instance ID, previously returned
    ///  Attach.</param>
    /// <exception name="ESdlError">Raised on failure.</exception>
    /// <seealso cref="Attach"/>
    class procedure Detach(const AInstanceID: TSdlJoystickID); inline; static;

    /// <summary>
    ///  The joystick type
    /// </summary>
    property Kind: TSdlJoystickKind read GetKind write SetKind;

    /// <summary>
    ///  The USB vendor ID of this joystick
    /// </summary>
    property VendorID: Word read FHandle.vendor_id write FHandle.vendor_id;

    /// <summary>
    ///  The USB product ID of this joystick
    /// </summary>
    property ProductID: Word read FHandle.product_id write FHandle.product_id;

    /// <summary>
    ///  The number of axes on this joystick
    /// </summary>
    property NumAxes: Smallint read FHandle.naxes write FHandle.naxes;

    /// <summary>
    ///  The number of buttons on this joystick
    /// </summary>
    property NumButtons: Smallint read FHandle.nbuttons write FHandle.nbuttons;

    /// <summary>
    ///  The number of balls on this joystick
    /// </summary>
    property NumBalls: Smallint read FHandle.nballs write FHandle.nballs;

    /// <summary>
    ///  The number of hats on this joystick
    /// </summary>
    property NumHats: Smallint read FHandle.nhats write FHandle.nhats;

    /// <summary>
    ///  Set of buttons that are valid for this controller
    /// </summary>
    property ValidButtons: TSdlGamepadButtons read GetValidButtons write SetValidButtons;

    /// <summary>
    ///  A set of axes that are valid for this controller
    /// </summary>
    property ValidAxes: TSdlGamepadAxes read GetValidAxes write SetValidAxes;

    /// <summary>
    ///  The name of the joystick
    /// </summary>
    property Name: String read FName write SetName;

    /// <summary>
    ///  An array of touchpad descriptions
    /// </summary>
    property Touchpads: TArray<TSdlVirtualJoystickTouchpadDesc> read FTouchpads write SetTouchpads;

    /// <summary>
    ///  An array of sensor descriptions
    /// </summary>
    property Sensors: TArray<TSdlVirtualJoystickSensorDesc> read FSensors write SetSensors;

    /// <summary>
    ///  User data pointer passed to callbacks
    /// </summary>
    property UserData: Pointer read FHandle.userdata write FHandle.userdata;

    /// <summary>
    ///  Called when the joystick state should be updated
    /// </summary>
    property Update: TSdlVirtualJoystickUpdate read GetUpdate write SetUpdate;

    /// <summary>
    ///  Called when the player index is set
    /// </summary>
    property SetPlayerIndex: TSdlVirtualJoystickSetPlayerIndex read GetSetPlayerIndex write SetSetPlayerIndex;

    /// <summary>
    ///  Implements TSdlJoystick.Rumble
    /// </summary>
    property Rumble: TSdlVirtualJoystickRumble read GetRumble write SetRumble;

    /// <summary>
    ///  Implements TSdlJoystick.RumbleTriggers
    /// </summary>
    property RumbleTriggers: TSdlVirtualJoystickRumbleTriggers read GetRumbleTriggers write SetRumbleTriggers;

    /// <summary>
    ///  Implements TSdlJoystick.SetLed
    /// </summary>
    property SetLed: TSdlVirtualJoystickSetLed read GetSetLed write SetSetLed;

    /// <summary>
    ///  Implements TSdlJoystick.SendJEffect
    /// </summary>
    property SendEffect: TSdlVirtualJoystickSendEffect read GetSendEffect write SetSendEffect;

    /// <summary>
    ///  Implements TSdlGamepad.SetSensorEnabled
    /// </summary>
    property SetSensorsEnabled: TSdlVirtualJoystickSetSensorsEnabled read GetSetSensorsEnabled write SetSetSensorsEnabled;

    /// <summary>
    ///  Cleans up the userdata when the joystick is detached
    /// </summary>
    property Cleanup: TSdlVirtualJoystickCleanup read GetCleanup write SetCleanup;
  end;
{$ENDREGION 'Joystick'}

implementation

{ _TSdlKeycodeHelper }

class function _TSdlKeycodeHelper.FromScancode(
  const AScancode: TSdlScancode): TSdlKeycode;
begin
  Result := TSdlKeycode(SDL_ScancodeToKeycode(Ord(AScancode)));
end;

class function _TSdlKeycodeHelper.FromName(const AName: String): TSdlKeycode;
begin
  Result := TSdlKeycode(SDL_GetKeyFromName(__ToUtf8(AName)));
end;

class function _TSdlKeycodeHelper.FromScancode(const AScancode: TSdlScancode;
  const AModState: TSdlKeymods; const AKeyEvent: Boolean): TSdlKeycode;
begin
  Result := TSdlKeycode(SDL_GetKeyFromScancode(Ord(AScancode), Word(AModState), AKeyEvent));
end;

function _TSdlKeycodeHelper.GetName: String;
begin
  Result := __ToString(SDL_GetKeyName(Ord(Self)));
end;

function _TSdlKeycodeHelper.ToScancode(
  const AModState: TSdlKeyMods): TSdlScancode;
begin
  Result := TSdlScancode(SDL_GetScancodeFromKey(Ord(Self), @AModState));
end;

function _TSdlKeycodeHelper.ToScancode: TSdlScancode;
begin
  Result := TSdlScancode(SDL_GetScancodeFromKey(Ord(Self), nil));
end;

{ _TSdlScancodeHelper }

function _TSdlScancodeHelper.ToKeycode: TSdlKeycode;
begin
  Result := TSdlKeycode(SDL_ScancodeToKeycode(Ord(Self)));
end;

class function _TSdlScancodeHelper.FromKeycode(const AKey: TSdlKeycode;
  const AModState: TSdlKeyMods): TSdlScancode;
begin
  Result := TSdlScancode(SDL_GetScancodeFromKey(Ord(AKey), @AModState));
end;

class function _TSdlScancodeHelper.FromName(const AName: String): TSdlScancode;
begin
  Result := TSdlScancode(SDL_GetScancodeFromName(__ToUtf8(AName)));
end;

function _TSdlScancodeHelper.GetName: String;
begin
  Result := __ToString(SDL_GetScancodeName(Ord(Self)));
end;

procedure _TSdlScancodeHelper.SetName(const AValue: String);
begin
  SDL_SetScancodeName(Ord(Self), __ToUtf8(AValue));
end;

class function _TSdlScancodeHelper.FromKeycode(
  const AKey: TSdlKeycode): TSdlScancode;
begin
  Result := TSdlScancode(SDL_GetScancodeFromKey(Ord(AKey), nil));
end;

function _TSdlScancodeHelper.ToKeycode(const AModState: TSdlKeymods;
  const AKeyEvent: Boolean): TSdlKeycode;
begin
  Result := TSdlKeycode(SDL_GetKeyFromScancode(Ord(Self), Word(AModState), AKeyEvent));
end;

{ TSdlKeyboardState }

function TSdlKeyboardState.IsPressed(const AScancode: TSdlScancode): Boolean;
begin
  {$POINTERMATH ON}
  if (Cardinal(AScancode) < TSdlKeyboard.FKeyCount) then
    Result := FState[Ord(AScancode)]
  else
    Result := False;
  {$POINTERMATH OFF}
end;

{ TSdlKeyboard }

class operator TSdlKeyboard.Equal(const ALeft: TSdlKeyboard;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = UIntPtr(ARight));
end;

class operator TSdlKeyboard.Equal(const ALeft, ARight: TSdlKeyboard): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlKeyboard.GetFocus: TSdlWindow;
begin
  THandle(Result) := SDL_GetKeyboardFocus;
end;

class function TSdlKeyboard.GetHasKeyboard: Boolean;
begin
  Result := SDL_HasKeyboard;
end;

class function TSdlKeyboard.GetHasScreenKeyboardSupport: Boolean;
begin
  Result := SDL_HasScreenKeyboardSupport;
end;

class function TSdlKeyboard.GetKeyboards: TArray<TSdlKeyboard>;
begin
  var Count := 0;
  var Keyboards := SDL_GetKeyboards(@Count);
  if (SdlSucceeded(Keyboards)) then
  try
    SetLength(Result, Count);
    Move(Keyboards^, Result[0], Count * SizeOf(SDL_KeyboardID));
  finally
    SDL_free(Keyboards);
  end;
end;

class function TSdlKeyboard.GetModState: TSdlKeyMods;
begin
  Word(Result) := SDL_GetModState;
end;

function TSdlKeyboard.GetName: String;
begin
  Result := __ToString(SDL_GetKeyboardNameForID(FHandle));
end;

class function TSdlKeyboard.GetState: TSdlKeyboardState;
begin
  Result.FState := SDL_GetKeyboardState(@FKeyCount);
end;

class operator TSdlKeyboard.Implicit(const AValue: Pointer): TSdlKeyboard;
begin
  Result.FHandle := UIntPtr(AValue);
end;

class operator TSdlKeyboard.NotEqual(const ALeft,
  ARight: TSdlKeyboard): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlKeyboard.NotEqual(const ALeft: TSdlKeyboard;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> UIntPtr(ARight));
end;

class procedure TSdlKeyboard.Reset;
begin
  SDL_ResetKeyboard;
end;

class procedure TSdlKeyboard.SetModState(const AValue: TSdlKeyMods);
begin
  SDL_SetModState(Word(AValue));
end;

{ TSdlCursor }

constructor TSdlCursor.Create(const AData, AMask: Pointer; const AW, AH, AHotX,
  AHotY: Integer);
begin
  FHandle := SDL_CreateCursor(AData, AMask, AW, AH, AHotX, AHotY);
  SdlCheck(FHandle);
end;

constructor TSdlCursor.Create(const ASurface: TSdlSurface; const AHotX,
  AHotY: Integer);
begin
  FHandle := SDL_CreateColorCursor(Pointer(ASurface), AHotX, AHotY);
  SdlCheck(FHandle);
end;

constructor TSdlCursor.Create(const ASystemCursor: TSdlSystemCursor);
begin
  FHandle := SDL_CreateSystemCursor(Ord(ASystemCursor));
  SdlCheck(FHandle);
end;

class operator TSdlCursor.Equal(const ALeft, ARight: TSdlCursor): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlCursor.Equal(const ALeft: TSdlCursor;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

procedure TSdlCursor.Free;
begin
  SDL_DestroyCursor(FHandle);
end;

class function TSdlCursor.GetActive: TSdlCursor;
begin
  Result.FHandle := SDL_GetCursor;
end;

class function TSdlCursor.GetDefault: TSdlCursor;
begin
  Result.FHandle := SDL_GetDefaultCursor;
  SdlCheck(Result.FHandle);
end;

class function TSdlCursor.GetIsVisible: Boolean;
begin
  Result := SDL_CursorVisible;
end;

class procedure TSdlCursor.Hide;
begin
  SdlCheck(SDL_HideCursor);
end;

class operator TSdlCursor.Implicit(const AValue: Pointer): TSdlCursor;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlCursor.NotEqual(const ALeft, ARight: TSdlCursor): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlCursor.NotEqual(const ALeft: TSdlCursor;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class procedure TSdlCursor.SetActive(const AValue: TSdlCursor);
begin
  SdlCheck(SDL_SetCursor(AValue.FHandle));
end;

class procedure TSdlCursor.SetIsVisible(const AValue: Boolean);
begin
  if (AValue) then
    SdlCheck(SDL_ShowCursor)
  else
    SdlCheck(SDL_HideCursor);
end;

class procedure TSdlCursor.Show;
begin
  SdlCheck(SDL_ShowCursor);
end;

{ TSdlMouse }

class procedure TSdlMouse.Capture(const AEnabled: Boolean);
begin
  SdlCheck(SDL_CaptureMouse(AEnabled));
end;

class operator TSdlMouse.Equal(const ALeft: TSdlMouse;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = UIntPtr(ARight));
end;

class operator TSdlMouse.Equal(const ALeft, ARight: TSdlMouse): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlMouse.GetFocus: TSdlWindow;
begin
  THandle(Result) := SDL_GetMouseFocus;
end;

function TSdlMouse.GetGlobalState(out APosition: TSdlPointF): TSdlMouseButtons;
begin
  Byte(Result) := SDL_GetGlobalMouseState(@APosition.X, @APosition.Y);
end;

function TSdlMouse.GetGlobalState(out AX, AY: Single): TSdlMouseButtons;
begin
  Byte(Result) := SDL_GetGlobalMouseState(@AX, @AY);
end;

class function TSdlMouse.GetHasMouse: Boolean;
begin
  Result := SDL_HasMouse;
end;

class function TSdlMouse.GetMice: TArray<TSdlMouse>;
begin
  var Count := 0;
  var Mice := SDL_GetMice(@Count);
  if (SdlSucceeded(Mice)) then
  try
    SetLength(Result, Count);
    Move(Mice^, Result[0], Count * SizeOf(SDL_MouseID));
  finally
    SDL_Free(Mice);
  end;
end;

function TSdlMouse.GetName: String;
begin
  var Name := SDL_GetMouseNameForID(FHandle);
  SdlCheck(Name);
  Result := __ToString(Name);
end;

class function TSdlMouse.GetPen: TSdlMouse;
begin
  Result.FHandle := SDL_MouseID(SDL_PEN_MOUSEID);
end;

function TSdlMouse.GetRelativeState(out ADelta: TSdlPointF): TSdlMouseButtons;
begin
  Byte(Result) := SDL_GetRelativeMouseState(@ADelta.X, @ADelta.Y);
end;

function TSdlMouse.GetRelativeState(out AX, AY: Single): TSdlMouseButtons;
begin
  Byte(Result) := SDL_GetRelativeMouseState(@AX, @AY);
end;

function TSdlMouse.GetState(out APosition: TSdlPointF): TSdlMouseButtons;
begin
  Byte(Result) := SDL_GetMouseState(@APosition.X, @APosition.Y);
end;

function TSdlMouse.GetState(out AX, AY: Single): TSdlMouseButtons;
begin
  Byte(Result) := SDL_GetMouseState(@AX, @AY);
end;

class function TSdlMouse.GetTouch: TSdlMouse;
begin
  Result.FHandle := SDL_MouseID(SDL_TOUCH_MOUSEID);
end;

class operator TSdlMouse.Implicit(const AValue: Pointer): TSdlMouse;
begin
  Result.FHandle := UIntPtr(AValue);
end;

class operator TSdlMouse.NotEqual(const ALeft, ARight: TSdlMouse): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlMouse.NotEqual(const ALeft: TSdlMouse;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> UIntPtr(ARight));
end;

procedure TSdlMouse.WarpGlobal(const APosition: TSdlPointF);
begin
  SdlCheck(SDL_WarpMouseGlobal(APosition.X, APosition.Y));
end;

procedure TSdlMouse.WarpGlobal(const AX, AY: Single);
begin
  SdlCheck(SDL_WarpMouseGlobal(AX, AY));
end;

{ TSdlFinger }

class operator TSdlFinger.Equal(const ALeft: TSdlFinger;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlFinger.Equal(const ALeft, ARight: TSdlFinger): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlFinger.GetID: TSdlFingerID;
begin
  if Assigned(FHandle) then
    Result := FHandle.id
  else
    Result := 0;
end;

function TSdlFinger.GetPosition: TSdlPointF;
begin
  if Assigned(FHandle) then
    Result.Init(FHandle.x, FHandle.y)
  else
    Result.Init(0, 0);
end;

function TSdlFinger.GetPressure: Single;
begin
  if Assigned(FHandle) then
    Result := FHandle.pressure
  else
    Result := 0;
end;

function TSdlFinger.GetX: Single;
begin
  if Assigned(FHandle) then
    Result := FHandle.x
  else
    Result := 0;
end;

function TSdlFinger.GetY: Single;
begin
  if Assigned(FHandle) then
    Result := FHandle.y
  else
    Result := 0;
end;

class operator TSdlFinger.Implicit(const AValue: Pointer): TSdlFinger;
begin
  Result.FHandle := AValue;
end;

class operator TSdlFinger.NotEqual(const ALeft, ARight: TSdlFinger): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlFinger.NotEqual(const ALeft: TSdlFinger;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlTouch }

class operator TSdlTouch.Equal(const ALeft: TSdlTouch;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = UIntPtr(ARight));
end;

class operator TSdlTouch.Equal(const ALeft, ARight: TSdlTouch): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlTouch.GetDevices: TArray<TSdlTouch>;
begin
  var Count := 0;
  var Devices := SDL_GetTouchDevices(@Count);
  if (SdlSucceeded(Devices)) then
  try
    SetLength(Result, Count);
    Move(Devices^, Result[0], Count * SizeOf(SDL_TouchID));
  finally
    SDL_Free(Devices);
  end;
end;

function TSdlTouch.GetDeviceType: TSdlTouchDeviceType;
begin
  Result := TSdlTouchDeviceType(SDL_GetTouchDeviceType(FHandle));
end;

function TSdlTouch.GetFingers: TArray<TSdlFinger>;
begin
  var Count := 0;
  var Fingers := SDL_GetTouchFingers(FHandle, @Count);
  if (SdlSucceeded(Fingers)) then
  try
    SetLength(Result, Count);
    Move(Fingers^, Result[0], Count * SizeOf(PSDL_Finger));
  finally
    SDL_Free(Fingers);
  end;
end;

class function TSdlTouch.GetMouse: TSdlTouch;
begin
  Result.FHandle := THandle(SDL_MOUSE_TOUCHID);
end;

function TSdlTouch.GetName: String;
begin
  var Name := SDL_GetTouchDeviceName(FHandle);
  SdlCheck(Name);
  Result := __ToString(Name);
end;

class operator TSdlTouch.Implicit(const AValue: Pointer): TSdlTouch;
begin
  Result.FHandle := UIntPtr(AValue);
end;

class operator TSdlTouch.NotEqual(const ALeft, ARight: TSdlTouch): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlTouch.NotEqual(const ALeft: TSdlTouch;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> UIntPtr(ARight));
end;

{ TSdlSensorID }

class operator TSdlSensorID.Equal(const ALeft: TSdlSensorID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlSensorID.Equal(const ALeft, ARight: TSdlSensorID): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlSensorID.GetKind: TSdlSensorKind;
begin
  Result := TSdlSensorKind(SDL_GetSensorTypeForID(FHandle));
  if (Result = TSdlSensorKind.Invalid) then
    __HandleError;
end;

function TSdlSensorID.GetName: String;
begin
  var Name := SDL_GetSensorNameForID(FHandle);
  SdlCheck(Name);
  Result := __ToString(Name);
end;

function TSdlSensorID.GetNonPortableType: Integer;
begin
  Result := SDL_GetSensorNonPortableTypeForID(FHandle);
  if (Result = -1) then
    __HandleError;
end;

class operator TSdlSensorID.Implicit(const AValue: Cardinal): TSdlSensorID;
begin
  Result.FHandle := AValue;
end;

class operator TSdlSensorID.NotEqual(const ALeft,
  ARight: TSdlSensorID): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlSensorID.NotEqual(const ALeft: TSdlSensorID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlSensor }

procedure TSdlSensor.Close;
begin
  SDL_CloseSensor(FHandle);
  FHandle := 0;
end;

class operator TSdlSensor.Equal(const ALeft: TSdlSensor;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class operator TSdlSensor.Equal(const ALeft, ARight: TSdlSensor): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class function TSdlSensor.FromID(const AInstanceID: TSdlSensorID): TSdlSensor;
begin
  Result.FHandle := SDL_GetSensorFromID(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlSensor.GetID: TSdlSensorID;
begin
  Result.FHandle := SDL_GetSensorID(FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlSensor.GetKind: TSdlSensorKind;
begin
  Result := TSdlSensorKind(SDL_GetSensorType(FHandle));
  if (Result = TSdlSensorKind.Invalid) then
    __HandleError;
end;

function TSdlSensor.GetName: String;
begin
  var Name := SDL_GetSensorName(FHandle);
  SdlCheck(Name);
  Result := __ToString(Name);
end;

function TSdlSensor.GetNonPortableType: Integer;
begin
  Result := SDL_GetSensorNonPortableType(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlSensor.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetSensorProperties(FHandle);
end;

procedure TSdlSensor.GetSensorData(const AData: TArray<Single>);
begin
  SdlCheck(SDL_GetSensorData(FHandle, Pointer(AData), Length(AData)));
end;

class function TSdlSensor.GetSensors: TArray<TSdlSensorID>;
begin
  var Count := 0;
  var Sensors := SDL_GetSensors(@Count);
  if (SdlSucceeded(Sensors)) then
  try
    SetLength(Result, Count);
    Move(Sensors^, Result[0], Count * SizeOf(SDL_SensorID));
  finally
    SDL_Free(Sensors);
  end;
end;

class operator TSdlSensor.Implicit(const AValue: Pointer): TSdlSensor;
begin
  Result.FHandle := THandle(AValue);
end;

class operator TSdlSensor.NotEqual(const ALeft, ARight: TSdlSensor): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlSensor.NotEqual(const ALeft: TSdlSensor;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class function TSdlSensor.Open(const AInstanceID: TSdlSensorID): TSdlSensor;
begin
  Result.FHandle := SDL_OpenSensor(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

class procedure TSdlSensor.Update;
begin
  SDL_UpdateSensors;
end;

{ _TSdlGamepadButtonHelper }

class function _TSdlGamepadButtonHelper.FromString(
  const AStr: String): TSdlGamepadButton;
begin
  Result := TSdlGamepadButton(SDL_GetGamepadButtonFromString(__ToUtf8(AStr)));
end;

function _TSdlGamepadButtonHelper.ToString: String;
begin
  Result := __ToString(SDL_GetGamepadStringForButton(Ord(Self)));
end;

{ _SdlGamepadKindHelper }

class function _SdlGamepadKindHelper.FromString(
  const AStr: String): TSdlGamepadKind;
begin
  Result := TSdlGamepadKind(SDL_GetGamepadTypeFromString(__ToUtf8(AStr)));
end;

function _SdlGamepadKindHelper.GetButtonLabel(
  const AButton: TSdlGamepadButton): TSdlGamepadButtonLabel;
begin
  Result := TSdlGamepadButtonLabel(SDL_GetGamepadButtonLabelForType(
    Ord(Self), Ord(AButton)));
end;

function _SdlGamepadKindHelper.ToString: String;
begin
  Result := __ToString(SDL_GetGamepadStringForType(Ord(Self)));
end;

{ _SdlGamepadAxisHelper }

class function _SdlGamepadAxisHelper.FromString(
  const AStr: String): TSdlGamepadAxis;
begin
  Result := TSdlGamepadAxis(SDL_GetGamepadAxisFromString(__ToUtf8(AStr)));
end;

function _SdlGamepadAxisHelper.ToString: String;
begin
  Result := __ToString(SDL_GetGamepadStringForAxis(Ord(Self)));
end;

{ TSdlGamepadBinding }

class operator TSdlGamepadBinding.Equal(const ALeft: TSdlGamepadBinding;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlGamepadBinding.Equal(const ALeft,
  ARight: TSdlGamepadBinding): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlGamepadBinding.GetInputAxisIndex: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.input.axis.axis
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetInputAxisMax: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.input.axis.axis_max
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetInputAxisMin: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.input.axis.axis_min
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetInputButtonIndex: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.input.button
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetInputHatIndex: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.input.hat.hat
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetInputHatMask: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.input.hat.hat_mask
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetInputType: TSdlGamepadBindingType;
begin
  if Assigned(FHandle) then
    Result := TSdlGamepadBindingType(FHandle.input_type)
  else
    Result := TSdlGamepadBindingType.None;
end;

function TSdlGamepadBinding.GetOutputAxis: TSdlGamepadAxis;
begin
  if Assigned(FHandle) then
    Result := TSdlGamepadAxis(FHandle.output.axis.axis)
  else
    Result := TSdlGamepadAxis.Invalid;
end;

function TSdlGamepadBinding.GetOutputAxisMax: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.output.axis.axis_max
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetOutputAxisMin: Integer;
begin
  if Assigned(FHandle) then
    Result := FHandle.output.axis.axis_min
  else
    Result := 0;
end;

function TSdlGamepadBinding.GetOutputButton: TSdlGamepadButton;
begin
  if Assigned(FHandle) then
    Result := TSdlGamepadButton(FHandle.output.button)
  else
    Result := TSdlGamepadButton.Invalid;
end;

function TSdlGamepadBinding.GetOutputType: TSdlGamepadBindingType;
begin
  if Assigned(FHandle) then
    Result := TSdlGamepadBindingType(FHandle.output_type)
  else
    Result := TSdlGamepadBindingType.None;
end;

class operator TSdlGamepadBinding.Implicit(const AValue: Pointer): TSdlGamepadBinding;
begin
  Result.FHandle := AValue;
end;

class operator TSdlGamepadBinding.NotEqual(const ALeft,
  ARight: TSdlGamepadBinding): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGamepadBinding.NotEqual(const ALeft: TSdlGamepadBinding;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlGamepadID }

class operator TSdlGamepadID.Equal(const ALeft: TSdlGamepadID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlGamepadID.Equal(const ALeft, ARight: TSdlGamepadID): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlGamepadID.GetGuid: TGuid;
begin
  Result := TGuid(SDL_GetGamepadGUIDForID(FHandle));
end;

function TSdlGamepadID.GetKind: TSdlGamepadKind;
begin
  Result := TSdlGamepadKind(SDL_GetGamepadTypeForID(FHandle));
end;

function TSdlGamepadID.GetMapping: String;
begin
  var Mapping := SDL_GetGamepadMappingForID(FHandle);
  try
    Result := __ToString(Mapping);
  finally
    SDL_free(Mapping);
  end;
end;

function TSdlGamepadID.GetName: String;
begin
  Result := __ToString(SDL_GetGamepadNameForID(FHandle));
end;

function TSdlGamepadID.GetPath: String;
begin
  Result := __ToString(SDL_GetGamepadPathForID(FHandle));
end;

function TSdlGamepadID.GetPlayerIndex: Integer;
begin
  Result := SDL_GetGamepadPlayerIndexForID(FHandle);
end;

function TSdlGamepadID.GetProduct: Word;
begin
  Result := SDL_GetGamepadProductForID(FHandle);
end;

function TSdlGamepadID.GetProductVersion: Word;
begin
  Result := SDL_GetGamepadProductVersionForID(FHandle);
end;

function TSdlGamepadID.GetRealKind: TSdlGamepadKind;
begin
  Result := TSdlGamepadKind(SDL_GetRealGamepadTypeForID(FHandle));
end;

function TSdlGamepadID.GetVendor: Word;
begin
  Result := SDL_GetGamepadVendorForID(FHandle);
end;

class operator TSdlGamepadID.Implicit(const AValue: Cardinal): TSdlGamepadID;
begin
  Result.FHandle := AValue;
end;

class operator TSdlGamepadID.NotEqual(const ALeft,
  ARight: TSdlGamepadID): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGamepadID.NotEqual(const ALeft: TSdlGamepadID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlGamepad }

class function TSdlGamepad.AddMapping(const AMapping: String): Boolean;
begin
  var Res := SDL_AddGamepadMapping(__ToUtf8(AMapping));
  if (Res = -1) then
    __HandleError;

  Result := (Res <> 0);
end;

class function TSdlGamepad.AddMappings(const ASrc: TSdlIOStream;
  const ACloseIO: Boolean): Integer;
begin
  Result := SDL_AddGamepadMappingsFromIO(THandle(ASrc), ACloseIO);
  if (Result = -1) then
    __HandleError;
end;

class function TSdlGamepad.AddMappings(const AFilename: String): Integer;
begin
  Result := SDL_AddGamepadMappingsFromFile(__ToUtf8(AFilename));
  if (Result = -1) then
    __HandleError;
end;

function TSdlGamepad.AppleSFSymbolsNameFor(
  const AAxis: TSdlGamepadAxis): String;
begin
  Result := __ToString(SDL_GetGamepadAppleSFSymbolsNameForAxis(FHandle,
    Ord(AAxis)));
end;

function TSdlGamepad.AppleSFSymbolsNameFor(
  const AButton: TSdlGamepadButton): String;
begin
  Result := __ToString(SDL_GetGamepadAppleSFSymbolsNameForButton(FHandle,
    Ord(AButton)));
end;

procedure TSdlGamepad.Close;
begin
  SDL_CloseGamepad(FHandle);
  FHandle := 0;
end;

class operator TSdlGamepad.Equal(const ALeft, ARight: TSdlGamepad): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlGamepad.Equal(const ALeft: TSdlGamepad;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class function TSdlGamepad.FromID(
  const AInstanceID: TSdlGamepadID): TSdlGamepad;
begin
  Result.FHandle := SDL_GetGamepadFromID(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

class function TSdlGamepad.FromPlayerIndex(
  const APlayerIndex: Integer): TSdlGamepad;
begin
  Result.FHandle := SDL_GetGamepadFromPlayerIndex(APlayerIndex);
  SdlCheck(Result.FHandle);
end;

function TSdlGamepad.GetAxis(const AAxis: TSdlGamepadAxis): Smallint;
begin
  Result := SDL_GetGamepadAxis(FHandle, Ord(AAxis));
end;

function TSdlGamepad.GetBindings: TArray<TSdlGamepadBinding>;
begin
  var Count := 0;
  var Bindings := SDL_GetGamepadBindings(FHandle, @Count);
  if (SdlSucceeded(Bindings)) then
  try
    SetLength(Result, Count);
    Move(Bindings^, Result[0], Count * SizeOf(PSDL_GamepadBinding));
  finally
    SDL_free(Bindings);
  end;
end;

function TSdlGamepad.GetButton(const AButton: TSdlGamepadButton): Boolean;
begin
  Result := SDL_GetGamepadButton(FHandle, Ord(AButton));
end;

function TSdlGamepad.GetButtonLabel(
  const AButton: TSdlGamepadButton): TSdlGamepadButtonLabel;
begin
  Result := TSdlGamepadButtonLabel(SDL_GetGamepadButtonLabel(FHandle, Ord(AButton)));
end;

function TSdlGamepad.GetConnectionState: TSdlGamepadConnectionState;
begin
  Result := TSdlGamepadConnectionState(SDL_GetGamepadConnectionState(FHandle));
  if (Result = TSdlGamepadConnectionState.Invalid) then
    __HandleError;
end;

class function TSdlGamepad.GetEventsEnabled: Boolean;
begin
  Result := SDL_GamepadEventsEnabled;
end;

function TSdlGamepad.GetFirmwareVersion: Word;
begin
  Result := SDL_GetGamepadFirmwareVersion(FHandle);
end;

class function TSdlGamepad.GetGamepads: TArray<TSdlGamepadID>;
begin
  var Count := 0;
  var Gamepads := SDL_GetGamepads(@Count);
  if (SdlSucceeded(Gamepads)) then
  try
    SetLength(Result, Count);
    Move(Gamepads^, Result[0], Count * SizeOf(SDL_JoystickID));
  finally
    SDL_free(Gamepads);
  end;
end;

class function TSdlGamepad.GetHasGamepad: Boolean;
begin
  Result := SDL_HasGamepad;
end;

function TSdlGamepad.GetID: TSdlGamepadID;
begin
  Result.FHandle := SDL_GetGamepadID(FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlGamepad.GetIsConnected: Boolean;
begin
  Result := SDL_GamepadConnected(FHandle);
end;

function TSdlGamepad.GetKind: TSdlGamepadKind;
begin
  Result := TSdlGamepadKind(SDL_GetGamepadType(FHandle));
end;

function TSdlGamepad.GetMapping: String;
begin
  var Mapping := SDL_GetGamepadMapping(FHandle);
  if (SdlSucceeded(Mapping)) then
  try
    Result := __ToString(Mapping);
  finally
    SDL_free(Mapping);
  end;
end;

class function TSdlGamepad.GetMappings: TArray<String>;
begin
  var Count := 0;
  var Mappings := SDL_GetGamepadMappings(@Count);
  if (SdlSucceeded(Mappings)) then
  try
    SetLength(Result, Count);
    var P := Mappings;
    for var I := 0 to Count - 1 do
    begin
      Result[I] := __ToString(P^);
      Inc(P);
    end;
  finally
    SDL_free(Mappings);
  end;
end;

function TSdlGamepad.GetName: String;
begin
  Result := __ToString(SDL_GetGamepadName(FHandle));
end;

function TSdlGamepad.GetNumTouchpadFingers(const ATouchPad: Integer): Integer;
begin
  Result := SDL_GetNumGamepadTouchpadFingers(FHandle, ATouchPad);
end;

function TSdlGamepad.GetNumTouchpads: Integer;
begin
  Result := SDL_GetNumGamepadTouchpads(FHandle);
end;

function TSdlGamepad.GetPath: String;
begin
  Result := __ToString(SDL_GetGamepadPath(FHandle));
end;

function TSdlGamepad.GetPlayerIndex: Integer;
begin
  Result := SDL_GetGamepadPlayerIndex(FHandle);
end;

function TSdlGamepad.GetPowerInfo(out APercent: Integer): TSdlPowerState;
begin
  Result := TSdlPowerState(SDL_GetGamepadPowerInfo(FHandle, @APercent));
  if (Result = TSdlPowerState.Error) then
    __HandleError;
end;

function TSdlGamepad.GetProduct: Word;
begin
  Result := SDL_GetGamepadProduct(FHandle);
end;

function TSdlGamepad.GetProductVersion: Word;
begin
  Result := SDL_GetGamepadProductVersion(FHandle);
end;

function TSdlGamepad.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetGamepadProperties(FHandle);
end;

function TSdlGamepad.GetRealKind: TSdlGamepadKind;
begin
  Result := TSdlGamepadKind(SDL_GetRealGamepadType(FHandle));
end;

procedure TSdlGamepad.GetSensorData(const AKind: TSdlSensorKind;
  const AData: TArray<Single>);
begin
  SdlCheck(SDL_GetGamepadSensorData(FHandle, Ord(AKind), Pointer(AData), Length(AData)));
end;

function TSdlGamepad.GetSensorDataRate(const AKind: TSdlSensorKind): Single;
begin
  Result := SDL_GetGamepadSensorDataRate(FHandle, Ord(AKind));
end;

function TSdlGamepad.GetSensorEnabled(const AKind: TSdlSensorKind): Boolean;
begin
  Result := SDL_GamepadSensorEnabled(FHandle, Ord(AKind));
end;

function TSdlGamepad.GetSerial: String;
begin
  Result := __ToString(SDL_GetGamepadSerial(FHandle));
end;

function TSdlGamepad.GetSteamHandle: UInt64;
begin
  Result := SDL_GetGamepadSteamHandle(FHandle);
end;

procedure TSdlGamepad.GetTouchpadFinger(const ATouchpad, AFinger: Integer;
  out AIsDown: Boolean; out AX, AY, APressure: Single);
begin
  SdlCheck(SDL_GetGamepadTouchpadFinger(FHandle, ATouchpad, AFinger, @AIsDown,
    @AX, @AY, @APressure));
end;

function TSdlGamepad.GetVendor: Word;
begin
  Result := SDL_GetGamepadVendor(FHandle);
end;

function TSdlGamepad.HasAxis(const AAxis: TSdlGamepadAxis): Boolean;
begin
  Result := SDL_GamepadHasAxis(FHandle, Ord(AAxis));
end;

function TSdlGamepad.HasButton(const AButton: TSdlGamepadButton): Boolean;
begin
  Result := SDL_GamepadHasButton(FHandle, Ord(AButton));
end;

function TSdlGamepad.HasSensor(const AKind: TSdlSensorKind): Boolean;
begin
  Result := SDL_GamepadHasSensor(FHandle, Ord(AKind));
end;

class operator TSdlGamepad.Implicit(const AValue: Pointer): TSdlGamepad;
begin
  Result.FHandle := THandle(AValue);
end;

class function TSdlGamepad.MappingForGuid(const AGuid: TGuid): String;
begin
  var Mapping := SDL_GetGamepadMappingForGUID(SDL_GUID(AGuid));
  if (SdlSucceeded(Mapping)) then
  try
    Result := __ToString(Mapping);
  finally
    SDL_Free(Mapping);
  end;
end;

class operator TSdlGamepad.NotEqual(const ALeft, ARight: TSdlGamepad): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlGamepad.NotEqual(const ALeft: TSdlGamepad;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class function TSdlGamepad.Open(const AInstanceID: TSdlGamepadID): TSdlGamepad;
begin
  Result.FHandle := SDL_OpenGamepad(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

class procedure TSdlGamepad.ReloadMappings;
begin
  SdlCheck(SDL_ReloadGamepadMappings);
end;

procedure TSdlGamepad.Rumble(const ALowFrequencyRumble,
  AHighFrequencyRumble: Word; const ADurationMs: Integer);
begin
  SdlCheck(SDL_RumbleGamepad(FHandle, ALowFrequencyRumble, AHighFrequencyRumble,
    ADurationMs));
end;

procedure TSdlGamepad.RumbleTriggers(const ALeftRumble, ARightRumble: Word;
  const ADurationMs: Integer);
begin
  SdlCheck(SDL_RumbleGamepadTriggers(FHandle, ALeftRumble, ARightRumble,
    ADurationMs));
end;

procedure TSdlGamepad.SendEffect(const AData: TBytes);
begin
  SdlCheck(SDL_SendGamepadEffect(FHandle, Pointer(AData), Length(AData)));
end;

class procedure TSdlGamepad.SetEventsEnabled(const AValue: Boolean);
begin
  SDL_SetGamepadEventsEnabled(AValue);
end;

procedure TSdlGamepad.SetLed(const ARed, AGreen, ABlue: Byte);
begin
  SdlCheck(SDL_SetGamepadLED(FHandle, ARed, AGreen, ABlue));
end;

procedure TSdlGamepad.SetMapping(const AValue: String);
begin
  SdlCheck(SDL_SetGamepadMapping(FHandle, __ToUtf8(AValue)));
end;

procedure TSdlGamepad.SetPlayerIndex(const AValue: Integer);
begin
  SdlCheck(SDL_SetGamepadPlayerIndex(FHandle, AValue));
end;

procedure TSdlGamepad.SetSensorEnabled(const AKind: TSdlSensorKind;
  const AValue: Boolean);
begin
  SdlCheck(SDL_SetGamepadSensorEnabled(FHandle, Ord(AKind), AValue));
end;

class procedure TSdlGamepad.Update;
begin
  SDL_UpdateGamepads;
end;

{ TSdlJoystickID }

class operator TSdlJoystickID.Equal(const ALeft: TSdlJoystickID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle = ARight);
end;

class operator TSdlJoystickID.Equal(const ALeft,
  ARight: TSdlJoystickID): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

function TSdlJoystickID.GetGuid: TGuid;
begin
  Result := TGuid(SDL_GetJoystickGUIDForID(FHandle));
end;

function TSdlJoystickID.GetIsGamepad: Boolean;
begin
  Result := SDL_IsGamepad(FHandle);
end;

function TSdlJoystickID.GetIsVirtual: Boolean;
begin
  Result := SDL_IsJoystickVirtual(FHandle);
end;

function TSdlJoystickID.GetKind: TSdlJoystickKind;
begin
  Result := TSdlJoystickKind(SDL_GetJoystickTypeForID(FHandle));
end;

function TSdlJoystickID.GetName: String;
begin
  Result := __ToString(SDL_GetJoystickNameForID(FHandle));
end;

function TSdlJoystickID.GetPath: String;
begin
  Result := __ToString(SDL_GetJoystickPathForID(FHandle));
end;

function TSdlJoystickID.GetPlayerIndex: Integer;
begin
  Result := SDL_GetJoystickPlayerIndexForID(FHandle);
end;

function TSdlJoystickID.GetProduct: Word;
begin
  Result := SDL_GetJoystickProductForID(FHandle);
end;

function TSdlJoystickID.GetProductVersion: Word;
begin
  Result := SDL_GetJoystickProductVersionForID(FHandle);
end;

function TSdlJoystickID.GetVendor: Word;
begin
  Result := SDL_GetJoystickVendorForID(FHandle);
end;

class operator TSdlJoystickID.Implicit(const AValue: Cardinal): TSdlJoystickID;
begin
  Result.FHandle := AValue;
end;

class operator TSdlJoystickID.NotEqual(const ALeft,
  ARight: TSdlJoystickID): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlJoystickID.NotEqual(const ALeft: TSdlJoystickID;
  const ARight: Cardinal): Boolean;
begin
  Result := (ALeft.FHandle <> ARight);
end;

{ TSdlJoystick }

function TSdlJoystick.AxisInitialState(const AAxis: Integer;
  out AState: Smallint): Boolean;
begin
  Result := SDL_GetJoystickAxisInitialState(FHandle, AAxis, @AState);
end;

procedure TSdlJoystick.Close;
begin
  SDL_CloseJoystick(FHandle);
  FHandle := 0;
end;

class operator TSdlJoystick.Equal(const ALeft, ARight: TSdlJoystick): Boolean;
begin
  Result := (ALeft.FHandle = ARight.FHandle);
end;

class operator TSdlJoystick.Equal(const ALeft: TSdlJoystick;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle = THandle(ARight));
end;

class function TSdlJoystick.FromGamepad(
  const AGamepad: TSdlGamepad): TSdlJoystick;
begin
  Result.FHandle := SDL_GetGamepadJoystick(AGamepad.FHandle);
  SdlCheck(Result.FHandle);
end;

class function TSdlJoystick.FromID(
  const AInstanceID: TSdlJoystickID): TSdlJoystick;
begin
  Result.FHandle := SDL_GetJoystickFromID(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

class function TSdlJoystick.FromPlayerIndex(
  const APlayerIndex: Integer): TSdlJoystick;
begin
  Result.FHandle := SDL_GetJoystickFromPlayerIndex(APlayerIndex);
  SdlCheck(Result.FHandle);
end;

function TSdlJoystick.GetAxis(const AAxis: Integer): Smallint;
begin
  Result := SDL_GetJoystickAxis(FHandle, AAxis);
end;

function TSdlJoystick.GetBall(const ABall: Integer): TSdlPoint;
begin
  SdlCheck(SDL_GetJoystickBall(FHandle, ABall, @Result.X, @Result.Y));
end;

function TSdlJoystick.GetButton(const AButton: Integer): Boolean;
begin
  Result := SDL_GetJoystickButton(FHandle, AButton);
end;

function TSdlJoystick.GetConnectionState: TsdlJoystickConnectionState;
begin
  Result := TsdlJoystickConnectionState(SDL_GetJoystickConnectionState(FHandle));
end;

class function TSdlJoystick.GetEventsEnabled: Boolean;
begin
  Result := SDL_JoystickEventsEnabled;
end;

function TSdlJoystick.GetFirmwareVersion: Word;
begin
  Result := SDL_GetJoystickFirmwareVersion(FHandle);
end;

function TSdlJoystick.GetGuid: TGuid;
begin
  Result := TGuid(SDL_GetJoystickGUID(FHandle));
end;

class function TSdlJoystick.GetHasJoystick: Boolean;
begin
  Result := SDL_HasJoystick;
end;

function TSdlJoystick.GetHats(const AHat: Integer): TSdlHats;
begin
  Byte(Result) := SDL_GetJoystickHat(FHandle, AHat);
end;

function TSdlJoystick.GetID: TSdlJoystickID;
begin
  Result.FHandle := SDL_GetJoystickID(FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlJoystick.GetIsConnected: Boolean;
begin
  Result := SDL_JoystickConnected(FHandle);
end;

class function TSdlJoystick.GetJoysticks: TArray<TSdlJoystickID>;
begin
  var Count := 0;
  var Joysticks := SDL_GetJoysticks(@Count);
  if (SdlSucceeded(Joysticks)) then
  try
    SetLength(Result, Count);
    Move(Joysticks^, Result[0], Count * SizeOf(SDL_JoystickID));
  finally
    SDL_Free(Joysticks);
  end;
end;

function TSdlJoystick.GetKind: TSdlJoystickKind;
begin
  Result := TSdlJoystickKind(SDL_GetJoystickType(FHandle));
end;

function TSdlJoystick.GetName: String;
begin
  Result := __ToString(SDL_GetJoystickName(FHandle));
end;

function TSdlJoystick.GetNumAxes: Integer;
begin
  Result := SDL_GetNumJoystickAxes(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlJoystick.GetNumBalls: Integer;
begin
  Result := SDL_GetNumJoystickBalls(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlJoystick.GetNumButtons: Integer;
begin
  Result := SDL_GetNumJoystickButtons(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlJoystick.GetNumHats: Integer;
begin
  Result := SDL_GetNumJoystickHats(FHandle);
  if (Result = -1) then
    __HandleError;
end;

function TSdlJoystick.GetPath: String;
begin
  Result := __ToString(SDL_GetJoystickPath(FHandle));
end;

function TSdlJoystick.GetPlayerIndex: Integer;
begin
  Result := SDL_GetJoystickPlayerIndex(FHandle);
end;

function TSdlJoystick.GetPowerInfo(out APercent: Integer): TSdlPowerState;
begin
  Result := TSdlPowerState(SDL_GetJoystickPowerInfo(FHandle, @APercent));
  if (Result = TSdlPowerState.Error) then
    __HandleError;
end;

function TSdlJoystick.GetProduct: Word;
begin
  Result := SDL_GetJoystickProduct(FHandle);
end;

function TSdlJoystick.GetProductVersion: Word;
begin
  Result := SDL_GetJoystickProductVersion(FHandle);
end;

function TSdlJoystick.GetProperties: TSdlProperties;
begin
  SDL_PropertiesID(Result) := SDL_GetJoystickProperties(FHandle);
end;

function TSdlJoystick.GetSerial: String;
begin
  Result := __ToString(SDL_GetJoystickSerial(FHandle));
end;

function TSdlJoystick.GetVendor: Word;
begin
  Result := SDL_GetJoystickVendor(FHandle);
end;

class procedure TSdlJoystick.GuidInfo(const AGuid: TGuid; out AVendor, AProduct,
  AVersion, ACrc16: Word);
begin
  SDL_GetJoystickGUIDInfo(SDL_GUID(AGuid), @AVendor, @AProduct, @AVersion, @ACrc16);
end;

class operator TSdlJoystick.Implicit(const AValue: Pointer): TSdlJoystick;
begin
  Result.FHandle := THandle(AValue);
end;

class procedure TSdlJoystick.Lock;
begin
  SDL_LockJoysticks;
end;

class operator TSdlJoystick.NotEqual(const ALeft,
  ARight: TSdlJoystick): Boolean;
begin
  Result := (ALeft.FHandle <> ARight.FHandle);
end;

class operator TSdlJoystick.NotEqual(const ALeft: TSdlJoystick;
  const ARight: Pointer): Boolean;
begin
  Result := (ALeft.FHandle <> THandle(ARight));
end;

class function TSdlJoystick.Open(
  const AInstanceID: TSdlJoystickID): TSdlJoystick;
begin
  Result.FHandle := SDL_OpenJoystick(AInstanceID.FHandle);
  SdlCheck(Result.FHandle);
end;

function TSdlJoystick.Rumble(const ALowFrequencyRumble,
  AHighFrequencyRumble: Word; const ADurationMs: Integer): Boolean;
begin
  Result := SDL_RumbleJoystick(FHandle, ALowFrequencyRumble,
    AHighFrequencyRumble, ADurationMs);
end;

function TSdlJoystick.RumbleTriggers(const ALeftRumble, ARightRumble: Word;
  const ADurationMs: Integer): Boolean;
begin
  Result := SDL_RumbleJoystickTriggers(FHandle, ALeftRumble, ARightRumble, ADurationMs);
end;

procedure TSdlJoystick.SendEffect(const AData: TBytes);
begin
  SdlCheck(SDL_SendJoystickEffect(FHandle, Pointer(AData), Length(AData)));
end;

class procedure TSdlJoystick.SetEventsEnabled(const AValue: Boolean);
begin
  SDL_SetJoystickEventsEnabled(AValue);
end;

procedure TSdlJoystick.SetLed(const ARed, AGreen, ABlue: Byte);
begin
  SdlCheck(SDL_SetJoystickLED(FHandle, ARed, AGreen, ABlue));
end;

procedure TSdlJoystick.SetPlayerIndex(const AValue: Integer);
begin
  SdlCheck(SDL_SetJoystickPlayerIndex(FHandle, AValue));
end;

procedure TSdlJoystick.SetVirtualAxis(const AAxis: Integer;
  const AValue: Smallint);
begin
  SdlCheck(SDL_SetJoystickVirtualAxis(FHandle, AAxis, AValue));
end;

procedure TSdlJoystick.SetVirtualBall(const ABall: Integer; const AXRel,
  AYRel: Smallint);
begin
  SdlCheck(SDL_SetJoystickVirtualBall(FHandle, ABall, AXRel, AYRel));
end;

procedure TSdlJoystick.SetVirtualButton(const AButton: Integer;
  const AIsDown: Boolean);
begin
  SdlCheck(SDL_SetJoystickVirtualButton(FHandle, AButton, AIsDown));
end;

procedure TSdlJoystick.SetVirtualHat(const AHat: Integer; const AValue: Byte);
begin
  SdlCheck(SDL_SetJoystickVirtualHat(FHandle, AHat, AValue));
end;

procedure TSdlJoystick.SetVirtualSensorData(const AKind: TSdlSensorKind;
  const ATimestamp: Int64; const AData: TArray<Single>);
begin
  SdlCheck(SDL_SendJoystickVirtualSensorData(FHandle, Ord(AKind), ATimestamp,
    Pointer(AData), Length(AData)));
end;

procedure TSdlJoystick.SetVirtualTouchpad(const ATouchpad, AFinger: Integer;
  const AIsDown: Boolean; const AX, AY, APressure: Single);
begin
  SdlCheck(SDL_SetJoystickVirtualTouchpad(FHandle, ATouchpad, AFinger, AIsDown,
    AX, AY, APressure));
end;

class procedure TSdlJoystick.Unlock;
begin
  SDL_UnlockJoysticks;
end;

class procedure TSdlJoystick.Update;
begin
  SDL_UpdateJoysticks;
end;

{ TSdlVirtualJoystickSensorDesc }

function TSdlVirtualJoystickSensorDesc.GetKind: TSdlSensorKind;
begin
  Result := TSdlSensorKind(FHandle.&type);
end;

procedure TSdlVirtualJoystickSensorDesc.SetKind(const AValue: TSdlSensorKind);
begin
  FHandle.&type := Ord(AValue);
end;

{ TSdlVirtualJoystickDesc }

function TSdlVirtualJoystickDesc.Attach: TSdlJoystickID;
begin
  Result.FHandle := SDL_AttachVirtualJoystick(@FHandle);
  SdlCheck(Result.FHandle);
end;

class procedure TSdlVirtualJoystickDesc.Detach(
  const AInstanceID: TSdlJoystickID);
begin
  SdlCheck(SDL_DetachVirtualJoystick(AInstanceID.FHandle));
end;

function TSdlVirtualJoystickDesc.GetCleanup: TSdlVirtualJoystickCleanup;
begin
  Result := FHandle.Cleanup;
end;

function TSdlVirtualJoystickDesc.GetKind: TSdlJoystickKind;
begin
  Result := TSdlJoystickKind(FHandle.&type);
end;

function TSdlVirtualJoystickDesc.GetRumble: TSdlVirtualJoystickRumble;
begin
  Result := FHandle.Rumble;
end;

function TSdlVirtualJoystickDesc.GetRumbleTriggers: TSdlVirtualJoystickRumbleTriggers;
begin
  Result := FHandle.RumbleTriggers;
end;

function TSdlVirtualJoystickDesc.GetSendEffect: TSdlVirtualJoystickSendEffect;
begin
  Result := FHandle.SendEffect;
end;

function TSdlVirtualJoystickDesc.GetSetLed: TSdlVirtualJoystickSetLed;
begin
  Result := FHandle.SetLed;
end;

function TSdlVirtualJoystickDesc.GetSetPlayerIndex: TSdlVirtualJoystickSetPlayerIndex;
begin
  Result := FHandle.SetPlayerIndex;
end;

function TSdlVirtualJoystickDesc.GetSetSensorsEnabled: TSdlVirtualJoystickSetSensorsEnabled;
begin
  Result := FHandle.SetSensorsEnabled;
end;

function TSdlVirtualJoystickDesc.GetUpdate: TSdlVirtualJoystickUpdate;
begin
  Result := FHandle.Update;
end;

function TSdlVirtualJoystickDesc.GetValidAxes: TSdlGamepadAxes;
begin
  Byte(Result) := FHandle.axis_mask;
end;

function TSdlVirtualJoystickDesc.GetValidButtons: TSdlGamepadButtons;
begin
  Cardinal(Result) := FHandle.button_mask;
end;

procedure TSdlVirtualJoystickDesc.Init;
begin
  FillChar(Self, SizeOf(Self), 0);
  FHandle.version := SizeOf(FHandle);
end;

procedure TSdlVirtualJoystickDesc.SetCleanup(
  const AValue: TSdlVirtualJoystickCleanup);
begin
  FHandle.Cleanup := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetKind(const AValue: TSdlJoystickKind);
begin
  FHandle.&type := Ord(AValue);
end;

procedure TSdlVirtualJoystickDesc.SetName(const AValue: String);
begin
  FName := AValue;
  FHandle.name := __ToUtf8(FName);
end;

procedure TSdlVirtualJoystickDesc.SetRumble(
  const AValue: TSdlVirtualJoystickRumble);
begin
  FHandle.Rumble := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetRumbleTriggers(
  const AValue: TSdlVirtualJoystickRumbleTriggers);
begin
  FHandle.RumbleTriggers := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetSendEffect(
  const AValue: TSdlVirtualJoystickSendEffect);
begin
  FHandle.SendEffect := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetSensors(
  const AValue: TArray<TSdlVirtualJoystickSensorDesc>);
begin
  FSensors := AValue;
  FHandle.nsensors := Length(FSensors);
  FHandle.sensors := Pointer(FSensors);
end;

procedure TSdlVirtualJoystickDesc.SetSetLed(
  const AValue: TSdlVirtualJoystickSetLed);
begin
  FHandle.SetLED := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetSetPlayerIndex(
  const AValue: TSdlVirtualJoystickSetPlayerIndex);
begin
  FHandle.SetPlayerIndex := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetSetSensorsEnabled(
  const AValue: TSdlVirtualJoystickSetSensorsEnabled);
begin
  FHandle.SetSensorsEnabled := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetTouchpads(
  const AValue: TArray<TSdlVirtualJoystickTouchpadDesc>);
begin
  FTouchpads := AValue;
  FHandle.ntouchpads := Length(FTouchpads);
  FHandle.touchpads := Pointer(FTouchpads);
end;

procedure TSdlVirtualJoystickDesc.SetUpdate(
  const AValue: TSdlVirtualJoystickUpdate);
begin
  FHandle.Update := AValue;
end;

procedure TSdlVirtualJoystickDesc.SetValidAxes(const AValue: TSdlGamepadAxes);
begin
  FHandle.axis_mask := Byte(AValue);
end;

procedure TSdlVirtualJoystickDesc.SetValidButtons(
  const AValue: TSdlGamepadButtons);
begin
  FHandle.button_mask := Cardinal(AValue);
end;

end.
