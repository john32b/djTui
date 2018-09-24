package djTui.adaptors;

/**
 * - Generic Adapter interface for Printing Characters 
 *
 * - You must create an object that implements this
 * 	 on your desired target (openfl, nodejs, ..)
 *   and pass it to WM
 * 
 * - Screen coordinates start from (0,0) for top,left
 * 
 * NOTES : ------------------------------
 *
 *  String Color IDs : 
 * 
 * 		black, white, gray, darkgray
 * 		red, darkred, green, darkgreen 
 * 		blue, darkblue, yellow, darkyellow 
 * 		cyan, darkcyan, magenta, darkmagenta
 * 
 */
interface ITerminal
{
	// Report client size:
	public var MAX_WIDTH:Int;
	public var MAX_HEIGHT:Int;

	// Save the current cursor position
	public function saveCursor():Void;
	
	// Restore the previously saved cursor position
	public function restoreCursor():Void;
	
	// Sets the cursor to be this character. (e.g. "-")
	public function setCursorSymbol(s:String):Void;
	
	// Puts text at current cursor position with currently set FG and BG colors
	public function print(s:String):ITerminal;
	
	// Move the cursor to X,Y 
	public function move(x:Int, y:Int):ITerminal;
	
	// Move RELATIVE to where the cursor is now
	public function moveR(x:Int, y:Int):ITerminal;
	
	// Set the active foreground color
	public function fg(col:String):ITerminal;

	// Set the active background color
	public function bg(col:String):ITerminal;
	
	public function resetFG():ITerminal;
	public function resetBG():ITerminal;
	public function reset():ITerminal;
	
	public function bold(state:Bool):ITerminal;
	public function italics(state:Bool):ITerminal;

}// --