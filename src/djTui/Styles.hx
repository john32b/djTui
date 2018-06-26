package djTui;

/**
 * Manage everything style related
 * -------------------------------
 * 
 * NOTES :  https://en.wikipedia.org/wiki/Box-drawing_character
 * 
 * ASCII Symbols :
 * 
 * 	■ ▌ ▐ ▀ ▄ █ ▬ ▓ ▒ ░ ☺ ☻
 *  ▼ ▲ ◄ ► » « ◘ ◙ 
 * 
**/



// Global Colors and Properties
typedef WMSkin = 
{
	?tui_bg:String,		// Whole TUI bg color. null to nothing
	win_fg:String, 		// Normal Text color
	win_bg:String,		// Window BG color
	win_hl:String,		// Some highlighted elements on the win, including the border
	disabled_fg:String, 
	accent_fg:String,
	accent_bg:String,
	accent_blur_fg:String,
	accent_blur_bg:String,
}//-



// Helper Type for holding both fg/bg colors
typedef PrintColor = 
{
	 fg:String,
	?bg:String
}//--



/** Static class with some utilities
 */
class Styles 
{
	// Some Inline Defaults:
	public inline static var DEF_WINDOW_SIZE_X:Int = 20;
	public inline static var DEF_WINDOW_SIZE_Y:Int = 8;
	
	// Border Decoration Symbols
	public static var border(default, null):Array<String>;
	
	// Border Connection Symbols, used in Draw.DrawGrid()
	public static var bCon(default, null):Array<String>;
	
	// All skins
	public static var skins(default, null):Array<WMSkin>;
	
	public static function init()
	{
		//-- Default Borders ::
		
		
		// borders : up row, bottom row, left, right
		border = [ 
			'',
			'┌─┐└─┘││', // 1: all thin
			'╔═╗╚═╝║║', // 2: all thick
			'╓─╖╙─╜║║', // 3: thin horizontal
			'╒═╕╘═╛││', // 4: thin vertical
		    '/-\\\\=/||', // 5: simple characters
		    '█▀██▄█▌▐',   // 6: simple blocks
		];
		

		// connections : up, down, left, right, intersection
		bCon = [ 
			'',
			'┬┴├┤┼',
			'╦╩╠╣╬',
			'╤╧╟╢╪', // inner thin,  outer thick
			'╥╨╞╡╫'  // inner thick, outer thin
		];
		
		//-- Default Tui Skins ::
		skins = [];
		
		skins[0] = {
			win_fg :"white",
			win_bg : "green",
			win_hl : "yellow",
			disabled_fg : "gray",
			accent_bg : "red",
			accent_fg : "yellow",
			accent_blur_bg : "cyan",
			accent_blur_fg : "black"
		}
		
		skins[1] = {
			win_fg :"red",
			win_bg : "black",
			win_hl : "green",
			disabled_fg : "gray",
			accent_bg : "magenta",
			accent_fg : "yellow",
			accent_blur_bg : "cyan",
			accent_blur_fg : "black"
		}
	}//---------------------------------------------------;
	
	/**
	   Returns special symbols for connecting the Standard Border Styles
	   WARNING: For Only works with line Borders ( styles 1-4 )
	   @param	from 1 or 2 (inside)
	   @param	to 1 or 2 (border)
	   @param	d up, down, left, right, X ( 0,1,2,3,4)
	   
	**/
	public static function connectBorder(from:Int, to:Int, d:Int):String
	{
		if (from == to)
		{
			return bCon[from].charAt(d);
		}
		
		if (from == 1 && to == 2)
		{
			return bCon[3].charAt(d);
		}
		
		if ( from == 2 && to == 1)
		{
			return bCon[4].charAt(d);
		}
		
		// Default:
		return bCon[from].charAt(d);
	}//---------------------------------------------------;
	
}//--