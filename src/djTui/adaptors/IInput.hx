package djTui.adaptors;

/**
 * - Generic Adapter interface for Getting Input
 * 
 * - You MUST create an object that implements this 
 *   interface and passit to WM
 * 
 * NOTES : ------------------------------
 * 
 * KeyCode IDs :
 * 
 *	 -	up,down,left,right
 * 		enter,backsp,esc,
 * 		pageup,pagedown,
 * 		tab,
 * 		home,end
 * 
 *   - Fkeys :  F1, F2, ...., F12
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