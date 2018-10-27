package;
import djTui.WindowState;

/**
 * Some global static parameters
 */
class REG 
{
	public static var APP_WIDTH:Int = 80;
	public static var APP_HEIGHT:Int = 25;
	
	// Log traces to this file, with realtime updates
	public static var LOG_FILE:String = "a:\\log.txt";
	
	// Present these States in the main menu 
	public static var states:Map<String,Class<WindowState>> = [
			"Misc_01" => State_Misc_01,
			"Button Grid" => State_ButtonGrid,	
			"Buttons" => State_Buttons,
			"Textboxes" => State_Textbox,
			"Labels" => State_Textbox,
			"Window Form" => State_Textbox,
		];
		
		
	//====================================================;
		
	#if debug
	
	// If set, will skip main menu and present this state at first run
	public static var startState:Class<WindowState> = State_Misc_01;
	
	#end
	
}// --