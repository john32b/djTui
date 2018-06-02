package djTui;


/**
 * Manage everything style related
 * ---------------------------
 * 
 * BORDER STYLES:
 * 		0 = None
 *	 	1 = Thick
 *  	2 = Thin
 * 
**/


// Styling Colors and Properties

@:structInit
@:publicFields
class WMSkin
{
	public function new(){}
	
	var tui_bg:String;	// Whole TUI bg color. null to nothing
	
	var win_fg:String; 	// Normal Text color
	var win_bg:String;	// Window BG color
	var win_hl:String;	// Some highlighted elements on the win, including the border

	var disabled_fg:String; // Grayed out
	
	var accent_fg:String;	
	var accent_bg:String;
	
	var accent_blur_fg:String;
	var accent_blur_bg:String;
	
	
}//-


class Styles 
{
	
	// Some Inline Defaults:
	public inline static var DEF_WINDOW_SIZE_X:Int = 20;
	public inline static var DEF_WINDOW_SIZE_Y:Int = 8;
	
	
	// Border Decorations
	public static var border(default, null):Array<String>;
	// Border Connections
	public static var bCon(default, null):Array<String>;
	
	// All skins
	public static var skins(default, null):Array<WMSkin>;
	
	public static function init()
	{
		//-- Default Borders ::
		// Notes : https://en.wikipedia.org/wiki/Box-drawing_character
		
		// borders : up row, bottom row, left, right
		border = [ 
			'',
			'┌─┐└─┘││', // 1: all thin
			'╔═╗╚═╝║║', // 2: all thick
			'╓─╖╙─╜║║', // 3: thin horizontal
			'╒═╕╘═╛││'  // 4: thin vertical
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
		
		var s = new WMSkin();
			s.win_fg = "white";
			s.win_bg = "blue";
			s.win_hl = "yellow";
			s.disabled_fg = "gray";
			s.accent_bg = "red";
			s.accent_fg = "yellow";
			s.accent_blur_bg = "cyan";
			s.accent_blur_fg = "black";
			
		skins = [];
		skins[0] = s;
		
	}//---------------------------------------------------;
	
	/**
	   Returns special symbols for connecting the Standard Border Styles
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