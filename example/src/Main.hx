package;

import djNode.BaseApp;
import djNode.tools.LOG;
import djTui.*;
import djTui.el.*;
import djTui.adaptors.djNode.*;
import djTui.win.ButtonGrid;
import djTui.win.MenuBar;
import djTui.win.MessageBox;
import djTui.win.WindowForm;
import djTui.win.WindowLabel;
import haxe.CallStack;

/**
 * Test main for djTui
 * ...
 */
class Main extends BaseApp 
{
	
	// Initialize Program Information / Arguments here.
	override function init():Void 
	{
		PROGRAM_INFO.name  = "djTui development";
		
		LOG.pipeTrace(); // all traces will redirect to LOG object
		LOG.setLogFile(REG.LOG_FILE, true);
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
		
		// Init the Window Manager and set some parameters :
		WM.create(
			new InputObj(), 
			new TerminalObj(), 
			REG.APP_WIDTH, REG.APP_HEIGHT	
		);
		
		//WM.flag_debug_trace_element_callbacks = true;
		WM.set_TAB_behavior("WINDOW", "exit");

		// Set the background color for the whole terminal area
		//WM.backgroundColor = "blue";
		
		//WM.backgroundColor = "gray";
		 
		//--------------------------------------------
		//- Draw some stuff that will be visible in all
		
		// : Title Window
		var head = new WindowLabel(["== djTUI  V" + WM.VERSION + " ==" , " - Demo and use examples - "], "center", ["black", "cyan"]);
		// : Footer
		var foot = new WindowLabel(["[Arrow Keys / TAB] = MOVE | [ENTER] = SELECT | [ESC] = SELECT"], "center", [0, 0, 0], ["black", "red"]);
			foot.placeBottom();
		WM.add(foot); // <-- Add the footer, this will be visible with all statesb
		
		
		// : Demo Selector ::
		
	
		// NOTE: -2,-2 = half the screen width, half the screen height
		var menu = new Window( -2, -2);
			menu.addStack(new Label("Select a demo :").setColor("blue", "white"));
			menu.addSeparator();
			
			for (i in REG.states.keys())
			{
				var b = new Button(i,i,1,0);
				menu.addStack(b);
			}
			
			menu.listen(function(msg, el){
				if (el.type == ElementType.button && msg == "fire")
				{
					var st = Type.createInstance(REG.states.get(el.SID), []);
					WM.STATE.open(st);
				}
			});
			
		// Position the menu
		WM.A.screen(menu).move(0, -2);
		
		
		// Quit Menu
		// --
		var qWin = new MenuBar(menu.width, 2);
			qWin.setItemStyle("center", 0, 1);
			qWin.setPanelStyle("white", "darkcyan");
			qWin.setItems(["QUIT", "ABOUT"]);
			WM.A.down(qWin, menu);
			qWin.onSelect = function(s){
				if (s == 0) // QUIT
				{
					var a = qWin.active;
					var p = [a.x - 2, a.y - 2];
					WM.popupConfirm(function(){Sys.exit(0);}, "Really Quit", p);
					
				}else
				{	
					var m = new MessageBox("Re-inventing the wheel for no particular reason.", 0);
						m.flag_close_on_esc = true;
						WM.A.screen(m).move(2, 2);
						qWin.openSub(m, true);
				}
			}
			
		// Dynamically create a state with those 2 windows
		// This way I can open/close quickly
		WM.STATE.create("main", [head, menu, qWin]);

		#if debug
		
		if (REG.startState != null)
		{
			WM.STATE.open(Type.createInstance(REG.startState, []));
			return;
		}
		
		#end
		
		WM.STATE.goto("main");
		
	}//---------------------------------------------------;

	// --
	override function onExit() 
	{
		T.move(0, WM.height); // Hack for real terminals
		super.onExit();
	}//---------------------------------------------------;
	
	override function exitError(text:String, showHelp:Bool = false):Void 
	{
		if (WM._isInited)
		{
			var m = new MessageBox(
				"CRITICAL ERROR:\n" + text, 0, 
				function(a){Sys.exit(1); }, 
				WM.width - 10, Styles.win.get("red.1")
				);
			WM.A.screen(m);
			m.open(true);		
		}
		else
		{
			super.exitError(text, showHelp);
		}
	}//---------------------------------------------------;
	
	// --
	static function main()  {
		new Main();
	}//---------------------------------------------------;

	
}// --