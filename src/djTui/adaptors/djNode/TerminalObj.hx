package djTui.adaptors.djNode;

import djTui.adaptors.ITerminal;
import djNode.BaseApp;
import djNode.Terminal;

/**
 * Adapter for a real terminal for use with djNode
 * ...
 */
class TerminalObj implements ITerminal
{

	// Report client size:
	public var MAX_WIDTH:Int;
	public var MAX_HEIGHT:Int;
	
	var t:Terminal;
	
	// --
	public function new() 
	{
		t = BaseApp.TERMINAL;
		MAX_WIDTH = t.getWidth();
		MAX_HEIGHT = t.getHeight();
	}
	
	// Save the current cursor position
	public function saveCursor()
	{
		t.savePos();
	}
	
	// Restore the previously saved cursor position
	public function restoreCursor()
	{
		t.restorePos();
	}
	
	// Sets the cursor to be this character. (e.g. "-")
	public function setCursorSymbol(s:String)
	{
		// TODO
	}
	
	// Puts text at current cursor position with currently set FG and BG colors
	public function print(s:String):ITerminal
	{
		Sys.print(s);	// save one call
		return this;
	}
	
	// Move the cursor to X,Y 
	public function move(x:Int, y:Int):ITerminal
	{
		// Terminal starts at (1,1)
		// While djTui starts at (0,0) so :
		t.move(x + 1, y + 1);
		return this;
	}
	
	// Move RELATIVE to where the cursor is now
	public function moveR(x:Int, y:Int):ITerminal
	{
		if (x > 0) t.forward(x); else if (x < 0) t.back( -x);
		if (y > 0) t.down(y); else if (y < 0) t.up( -y);
		return this;
	}
	
	// Set the active foreground color
	public function fg(col:String):ITerminal
	{
		t.fg(col);
		return this;
	}

	// Set the active background color
	public function bg(col:String):ITerminal
	{
		t.bg(col);
		return this;
	}
	
	public function resetFG():ITerminal
	{
		t.resetFg();
		return this;
	}
	
	public function resetBG():ITerminal
	{
		t.resetBg();
		return this;
	}
	
	public function reset():ITerminal
	{
		t.reset();
		return this;
	}
	
	public function bold(state:Bool):ITerminal
	{
		if (state) t.bold(); else t.resetBold(); 
		return this;
	}
	
	public function italics(state:Bool):ITerminal
	{
		// Not supported
		return this;
	}
	
}// -- end class