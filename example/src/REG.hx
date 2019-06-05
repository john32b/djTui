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
	public static var LOG_FILE:String = "a:\\djTui_log.txt";
	
	// Present these States in the main menu 
	public static var states:Map<String,Class<WindowState>> = [
			"Labels" => State_Labels,
			"Button Grid" => State_ButtonGrid,	
			"Buttons" => State_Buttons,
			"Textbox" => State_Textbox,
			"VList" => State_VList,
			"Window Form" => State_WinForm,
			"Miscellaneous 1" => State_Test_1
		];
		
	// Random text, used in textboxes	
	public static var longString = "A computer is a device that can be instructed to carry out sequences of arithmetic or logical operations automatically via computer programming. Modern computers have the ability to follow generalized sets of operations, called programs. These programs enable computers to perform an extremely wide range of tasks.Computers are used as control systems for a wide variety of industrial and consumer devices. This includes simple special purpose devices like microwave ovens and remote controls, factory devices such as industrial robots and computer-aided design, and also general purpose devices like personal computers and mobile devices such as smartphones.";
		
	//====================================================;
		
	#if debug
	// If set, will skip main menu and present this state at first run
	public static var startState:Class<WindowState> = State_Test_1;
	#end
	
}// --