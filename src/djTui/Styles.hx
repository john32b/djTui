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
	public static var border(default, null):Array<Array<String>>;
	// All skins
	public static var skins(default, null):Array<WMSkin>;
	
	public static function init()
	{
		//-- Set Border styles here
		
		border = [];
		border[1] = [ "┌", "─", "┐", "└", "─", "┘", "│", "│" ];
		border[2] = [ "╔", "═", "╗", "╚", "═", "╝", "║", "║" ];
		
		//-- Set Default Tui Skins
		
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
	
}//--