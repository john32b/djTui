package djTui;

/**
 * Manage everything style related
 * -------------------------------
 *
 * - Default window styles
 * - Default borders and decorative symbols
 *
 *
 * NOTES :
 * 	- https://en.wikipedia.org/wiki/Box-drawing_character
 *  - Useful ASCII Symbols :
 * 		■ ▌ ▐ ▀ ▄ █ ▬ ▓ ▒ ░ ☺ ☻
 *  	▼ ▲ ◄ ► » « ◘ ◙ ○ ☼ → ← ↔ ↑ ↓ ↨ ∟ ™ ® ©
 *
**/



// Helper Type for holding both fg/bg colors
typedef PrintColor =
{
	 fg:String,
	?bg:String
}//--


// Describe a window style along with some basic menu elements it can hold
typedef WinStyle =
{
	bg:String,			// Window background Color
	text:String,		// Labels Color

	titleColor:PrintColor,
	?titleColor_focus:PrintColor,

	borderStyle:Int,
	borderColor:PrintColor,
	?borderColor_focus:PrintColor,

	elem_focus:PrintColor,
	elem_idle:PrintColor,

	elem_disable_f:PrintColor,	// Disabled Focused
	elem_disable_i:PrintColor,	// Disabled Idle

	scrollbar_idle:PrintColor,
	?scrollbar_focus:PrintColor,

	textbox:PrintColor,			// Also for Vlist
	?textbox_focus:PrintColor,	// Also for Vlist

	vlist_cursor:PrintColor
}// --



/**
 * Static class that holds some global Style parameters and utilities
 */
class Styles
{

	public inline static var DEF_STYLE_WIN = "blue.1";
	public inline static var DEF_STYLE_POP = "red.1";

	// Some Inline Defaults:
	public inline static var DEF_WINDOW_SIZE_X:Int = 20;
	public inline static var DEF_WINDOW_SIZE_Y:Int = 8;

	// Border Decoration Symbols
	public static var border(default, null):Array<String>;

	// Hold some default Window Styles
	public static var win(default, null):Map<String,WinStyle>;

	// Store some LEFT-RIGHT Arrow Styles
	public static var arrowsLR(default, null):Array<String>;

	//====================================================;

	public static function init()
	{
		// -- Some global ARROW Symbols
		arrowsLR = [
			'<>', '◄►', '←→', '«»'
		];

		//-- Default Borders ::

		// borders : up row, bottom row, left, right
		border = [
			'             ', 	// 0: blank
			'┌─┐└─┘││┬┴├┤┼', 	// 1: all thin
			'╔═╗╚═╝║║╦╩╠╣╬', 	// 2: all thick
			'╓─╖╙─╜║║╥╨╞╡╫', 	// 3: thin horizontal
			'╒═╕╘═╛││╤╧╟╢╪', 	// 4: thin vertical
		    '/-\\\\=/||--||T', 	// 5: simple characters
		    '█▀██▄█▌▐█▄▌▐█',   	// 6: simple blocks
		];


		//-- Create some predefined styles
		win = new Map();

		win.set("blue.1", 	createWinStyle("yellow", "magenta", "white", "blue", "darkblue"));
		win.set("green.1", 	createWinStyle("yellow", "red", 	"white", "darkgreen", "darkgray"));
		win.set("red.1",	createWinStyle("yellow", "magenta", "white", "red", "darkred"));
		win.set("magenta.1",createWinStyle("black", "cyan", "black", "magenta", "darkcyan"));
		win.set("black.1",	createWinStyle("yellow", "red", "white", "black", "gray"));
		win.set("cyan.1",	createWinStyle("black", "magenta", "black", "cyan", "gray"));
		win.set("gray.1",	createWinStyle("white", "blue", "black", "gray", "darkgray"));

	}//---------------------------------------------------;


	/**
	   Quickly Create a Window By using 4 colors as a guide
	   @param A Accent FG
	   @param B Accent BG
	   @param C Foreground
	   @param D Background
	   @param E Disabled Color
	**/
	public static function createWinStyle(A:String, B:String, C:String, D:String, E:String, BorderStyle:Int = 1):WinStyle
	{
		// No bg color converts to Window BG color
		var s:WinStyle =
		{
			bg : D,
			text : C,

			titleColor : { fg : A },

			borderStyle : BorderStyle,
			borderColor : { fg : C },

			elem_focus    : { fg : B, bg : A },
			elem_idle     : { fg : C },

			elem_disable_f  : { fg : D, bg : E },
			elem_disable_i  : { fg : E },

			scrollbar_idle  : { fg : C },
			scrollbar_focus : { fg : A, bg : B},

			textbox : { fg : C },
			vlist_cursor : { fg : D, bg : A }
		}

		return s;
	}//---------------------------------------------------;

}//--