package djTui.adaptors.openFL;

import flash.display.Stage;
import djTui.adaptors.IInput;
import openfl.Lib;
import openfl.events.KeyboardEvent;


/**
   Input Interface for OpenFL
**/
 
class InputObj implements IInput 
{

	// Maps event.Keycode to djTui Key ID
	static var keyMap:Map<Int,String> = [	
		8 => "backsp",
		9 => "tab",
		13 => "enter",
		27 => "esc",
		37 => "left",
		38 => "up",
		39 => "right",
		40 => "down",
		32 => "space",
		33 => "pageup",
		34 => "pagedown",
		35 => "end",
		36 => "home",
		45 => "insert",
		46 => "delete",
		112 => "F1",
		113 => "F2",
		114 => "F3",
		115 => "F4",
		116 => "F5",
		117 => "F6",
		118 => "F7",
		119 => "F8",
		120 => "F9"
	];
	
	public function new(?_onkey:String->Void) 
	{
		onKey = _onkey;
	}//---------------------------------------------------;
	
	function keyHandler(e:KeyboardEvent)
	{	
		if (keyMap.exists(e.keyCode))
		{
			//trace(": " + keyMap.get(e.keyCode));
			onKey(keyMap.get(e.keyCode));
		}else
		{
			if (e.charCode > 0)
			{
				//trace(String.fromCharCode(e.charCode));
				onKey(String.fromCharCode(e.charCode));
			}
		}
	}//---------------------------------------------------;
	
	public var onKey:String->Void;
	
	public function start():Void 
	{
		var st:Stage = Lib.current.stage;
		st.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
	}//---------------------------------------------------;
	
	public function stop():Void 
	{
		var st:Stage = Lib.current.stage;
		st.removeEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
	}//---------------------------------------------------;
	
}// --