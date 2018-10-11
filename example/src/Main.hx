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
		
		// Override some of the default style fields
		Tools.copyFields({
			titleColor_focus:{fg:"blue", bg:"green"},
			borderStyle:1,
			//bg:"darkblue",
			text:"white",
			textbox_focus: { fg:"white" },
			textbox: { fg:"gray" },
			scrollbar_focus:{fg:"white",bg:"red"}
		}, WM.global_style_win);
		
		
		//WM.global_style_win = Styles.createWinStyle("white", "yellow", "black", "darkblue");
		WM.global_style_pop = Styles.win.get("pop_red");
		
		// Set the background color for the whole terminal area
		 //WM.backgroundColor = "blue";
		
		 
		//--------------------------------------------
		//- Draw some stuff that will be visible in all
		
		// : Header
		var head = new Window( -1, 3);
			head.flag_focusable = false;
			// By default all windows use the default `WM.global_style_win`
			head.modifyStyle({
				bg:"cyan", text:"black", borderStyle:2, borderColor:{fg:"darkblue"}
			});
			head.addStack(new Label("djTUI V" + WM.VERSION + " - Demo  "));
		
		// : Footer
		var foot = new Window( -1, 1);
			foot.flag_focusable = false;
			foot.padding(0);
			foot.modifyStyle({
				bg:"gray", text:"darkblue", borderStyle:0
			});
			foot.addStack(new Label("[Arrow Keys / TAB] = MOVE | [ENTER] = SELECT | [ESC] = SELECT", foot.inWidth, "center"));
			foot.pos(0, WM.height - foot.height);
			
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
		
		
		// Quit Menu:
		var qWin = new MenuBar("",menu.width, 1);
			qWin.setItemStyle("center", 0, 1);
			qWin.setPanelStyle("blue", "darkcyan");
			qWin.setItems(["QUIT", "ABOUT"]);
			WM.A.down(qWin, menu);
			qWin.onSelect = function(s){
				if (s == 0)
				{
					var a = qWin.active;
					var p = [a.x - 2, a.y - 2];
					WM.popupConfirm(function(){Sys.exit(0); }, "Really Quit",p);
					
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
				WM.width - 10, Styles.win.get("error")
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