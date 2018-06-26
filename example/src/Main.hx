package;

import djNode.BaseApp;
import djNode.tools.LOG;
import djTui.*;
import djTui.el.*;
import djTui.adaptors.djNode.*;

/**
 * ...
 * @author John Dimi
 */
class Main extends BaseApp 
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
	// This is the user code entry point :
	override function onStart() 
	{
		
		// Initialize the Terminal
		T.pageDown();	
		T.clearScreen();
		T.cursorHide();
		//--
		
		// Create/Init the Window Manager
		WM.create(
			new InputObj(), 
			new TerminalObj(), 80, 25, 1
		);
		
		WM.T.fg("yellow");
		WM.D.drawGrid(0, 0, [ "40|40|13", "50|30|10"], 1, 2);
		
		// -- Add some things
		
		WM.globalWindowCallbacks = onWindowCallbacks;
		
		var win1 = new Window( -3, 15, 2);
			win1.padding(3, 3);
			win1.pos(0, 3);
		var list = new VList("l1", win1.inWidth, 4);
			list.setData([
			"Labels >",
			"Buttons >",
			"Toggles -",
			"Options -",
			"Options -",
			"Options -",
			"Quit +"
			]);
		win1.addStack(list);
		win1.addStack(new Button("", "test"));

	
		//- Button window
		var win2 = new Window("win_btn", -3, 15);
			win2.posNext(win1, 2);
			win2.title = "Button Test";
			// add some buttons
			win2.addStack(new Button("", "Link", 0 ).colorIdle("red", "green").colorFocus("white", "blue"));
			win2.addStack(new Button("l1", "Link with a rather long text", 0 ));
			win2.addStack(new Button("rl", "Reset Link", 1 ));
			win2.addStack(new Button("cc", "Confirm", 2 ).confirm(true));
			win2.addStack(new Button("tolab", "Goto Other WIN >>", 3 ));
			win2.addStack(new Button("", "4", 4, win2.inWidth ));
			
		//- Labels Window
		var win3 = new Window("win_lab", -3, 15);
			win3.posNext(win1, 2);
			win3.flag_focusable = true;
			win3.title = "Labels";
			win3.addStackCentered([
			new Label("Label1"), new Label("Label2").setColor("red", "yellow")]);
			win3.addStackCentered([
			new Label("one"), new Label("two"), new Label("three"), new Button("t","ttt")]);

			
		WM.STATE.create("main", [win1, win2]);
		WM.STATE.goto("main");
		
	}//---------------------------------------------------;


	function onWindowCallbacks(s:String, el:BaseElement)
	{
		if (s == "fire") // Only buttons can fire
		{
			if (el.SID == "rl")
			{
				trace("Reset Link Graphic");
				el.parent.getEl("l1");
				//var btn:Button = cast WM.DB.get("win_btn").getEl("l1");
				// One way or another
				var btn:Button = cast el.parent.getEl("l1");
				btn.text = "random";
			}
			else if (el.SID == "tolab")
			{
				el.parent.close();
				WM.DB.get("win_lab").openAnimated();
			}
		}
		if ( s == "unfocus")
		{
			trace("Window Unfocus");
		}
	}//---------------------------------------------------;

	// --
	override function onExit() 
	{
		T.move(0, WM.height); // Hack for real terminals
		super.onExit();
	}//---------------------------------------------------;
	
	// --
	static function main()  {
		new Main();
	}//---------------------------------------------------;

}// --