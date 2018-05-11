package adapter;

import djNode.Keyboard;
import djTui.ext.IInput;

/**
 * Inputs Adaptor
 * ...
 * @author John Dimi
 */
class InputObj implements IInput
{
	// KEYS:
	// up,down,left,right
	// enter,back,esc,
	// pageup,pagedown,
	// tab
	
	// Callback with a key pressed
	public var onKey:String->Void;
	
	
	public function new() 
	{
	}
	
	// Filter and adopt some calls
	function _onKey(k:String)
	{
		var code = Keycode.toKeyCodeID(k);
		
		if (code != null) 
		
			onKey(switch(code) {
				case KeycodeID.esc: "esc";
				case KeycodeID.enter: "enter";
				case KeycodeID.backsp: "backsp";
				case KeycodeID.space: "space";
				case KeycodeID.up: "up";
				case KeycodeID.down: "down";
				case KeycodeID.left: "left";
				case KeycodeID.right: "right";
				case KeycodeID.pagedown: "pagedown";
				case KeycodeID.pageup: "pageup";
				case KeycodeID.tab: "tab";
				default: ""; // Other
			});
		
		else
		
			onKey(k);
		
	}//---------------------------------------------------;
	
	public function start()
	{
		Keyboard.startCapture(true, _onKey);
	}
	
	public function stop()
	{
		Keyboard.stop();
	}
	
}// -- end class --