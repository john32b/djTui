package djTui.ext;

/**
 * 
 * KeyCode IDs :
 * 
 *	 -	up,down,left,right
 * 		enter,back,esc,
 * 		pageup,pagedown,
 * 		tab
 * 
 *	 -	regular key ascii, (e.g. 'k')
 * 
 */
interface IInput 
{

	// Callback with a key pressed
	public var onKey:String->Void;

	// Start capturing keys
	public function start():Void;
	
	// Stop capturing keys
	public function stop():Void;
	
}