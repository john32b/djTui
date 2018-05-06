package;

import djNode.BaseApp;
import djNode.tools.LOG;
import adapter.*;
import djTui.*;
import djTui.el.*;
import djTui.ext.*;

/**
 * ...
 * @author John Dimi
 */
class DevMain extends BaseApp 
{

	override function init():Void 
	{
		// Initialize Program Information here.
		PROGRAM_INFO.name  = "djTui development";
		
		// Initialize Program Arguments here.
		// LOG.setLogFile("file.txt", true);
		
		LOG.pipeTrace();
		LOG.setLogFile("a:\\log.txt", true);
		super.init();
	}//---------------------------------------------------;
	
	// --
	override function onStart() 
	{
		// This is the user code entry point :
		// ..
		
		T.pageDown();	// Need a pagedown for the windows CLI
		T.clearScreen();
		T.cursorHide();
		
		WM.create(
			new InputObj(), 
			new TerminalObj(), 80, 25
		);
		
		var w1 = new Window();
			w1.padding(3, 1).move(3, 3).size(20, 14);
		
		for (i in 0...5)
		{
			var b = new Button("Bnt " + i, i % 3);
			w1.addStacked(b);
				
		}
		
		var a1 = new Label("Label");
		var a2 = new Button(" ... ", false);
		
		var a3 = new Toggle();
		w1.addStacked(a1);
		w1.addStacked(a2);
		w1.addStacked(a3);
		
		
		WM.addWindow(w1, true);
		w1.title = "Main win";
	}//---------------------------------------------------;
	
	
	// --
	override function onExit() 
	{
		T.reset();
		T.move(0, WM.height);
		super.onExit();
	}//---------------------------------------------------;
	
	
	// --
	static function main()  {
		new DevMain();
	}//---------------------------------------------------;

}// --