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
		
		// Init the Window Manager and set some parameters :
		WM.create(
			new InputObj(), 
			new TerminalObj(), REG.APP_WIDTH, REG.APP_HEIGHT
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
		
		// Set the background color for the whole terminal area
		WM.backgroundColor = "blue";
		
		// [TEST] -> misc
		
		//var st1 = new State_Misc_01(); st1.open();
		//return;
		
		
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
		WM.add(head);
		
		
		// : Footer
		var foot = new Window( -1, 1);
			foot.flag_focusable = false;
			foot.padding(0);
			foot.modifyStyle({
				bg:"gray", text:"darkblue", borderStyle:0
			});
			foot.addStack(new Label("[Arrow Keys / TAB] = MOVE    |   [ENTER] = SELECT", foot.inWidth, "center"));
			foot.pos(0, WM.height - foot.height);
		WM.add(foot);
		
		
		// : Demo Selector ::
		
		var states:Map<String,Class<WindowState>> = [
			"Misc_01" => State_Misc_01,
			"Textboxes" => State_Textbox,
			"Buttons" => State_Textbox,
			"Labels" => State_Textbox,
			"Window Form" => State_Textbox,
			"Button Grid" => State_Textbox
		];
		
		// NOTE: -2,-2 = half the screen width, half the screen height
		var menu = new Window( -2, -2);
			menu.addStack(new Label("Select a demo :").setColor("blue", "white"));
			menu.addSeparator();
			
			for (i in states.keys())
			{
				var b = new Button(i, i, 0);
				menu.addStack(b);
			}
			
			menu.listen(function(msg, el){
				if (el.type == ElementType.button && msg == "fire")
				{
					var st = Type.createInstance(states.get(el.SID), []);
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
					Sys.exit(0);
				}else
				{
					var m = new MessageBox("Re-inventing the wheel for no particular reason.", 0);
						WM.A.screen(m);
						m.openAnimated();
				}
			}
			
		// Dynamically create a state with those 2 windows
		// This way I can open/close quickly
		WM.STATE.create("main", [head, menu, qWin]);
		WM.STATE.goto("main");
		return;
		
		// -------------------------------------------------------------
		// -------------------------------------------------------------
		

		WM.onElementCallback = onWindowCallbacks;
		
		var win1 = new Window( -3,15);
			win1.title = "test";
			win1.padding(3, 3);
			win1.pos(0, 1);
			win1.listen(function(a, b){
				trace("window 1", a, b);
			});
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
	
		//- Button window
		var win2 = new Window("win_btn", -3, 15);
			win2.posNext(win1, 2);
			win2.title = "Button Test";
			// add some buttons
			win2.addStack(new Button("cbord", "Change Border",1).colorIdle("black", "white").colorFocus("white", "blue"));
			win2.addStack(new Button("ctitle", "Change Title",2));
			win2.addStack(new Button("l1", "Link with a rather long text", 0 ));
			win2.addStack(new Button("l2", "Modify button", 1 ));
			win2.addStack(new Button("cc", "Confirm", 2 ).confirm(true));
			win2.addStack(new Button("@win_lab,close,anim,center", "Call WINDOW 2", 4 ));
			win2.addStack(new Button("#state2,close,anim,center", "Call STATE  2", 4 ));
			win2.addStack(new Button("", "Close all").onPush(function(){ WM.STATE.close(); }));
			
		WM.STATE.create("state1", [win1, win2]);
		
		// -- Create State 2
		
		var ww = new Window(-3, 7);
		ww.title = "win1";
		ww.pos(1, 3);
		
		var ww2 = new Window( -2, 10);
		ww2.title = "win2";
		ww2.posNext(ww);
		ww2.addStack(new Button("", "Button 1", 1 ));
		ww2.addStack(new Button("#state3", "Goto State Grid", 1 ));
		ww2.addStack(new Button("#state1", "CALL state 1", 4 ));
		
		WM.STATE.create("state2", [ww, ww2]);
		// -- Create State 3 a window button only
		
		var wb = new ButtonGrid(40, 14, 2, 1);
			wb.SID = "bg1";
			wb.size(40, 10).pos(3, 3);
			wb.add(0, "1");
			wb.add(0, "2");
			wb.add(1, "a 1");
			wb.add(1, "b 1");
			
		WM.STATE.create("state3", [wb]);
		
		WM.STATE.onStateOpen = function(st)
		{
			//WM.T.bg("darkblue");
			//WM.D.rect(0, 0, WM.width, WM.height);
			
			trace("->> Just going to state :" +  st.SID);
		};
		
		WM.STATE.goto("state1"); 
		
		// 
		//WM.T.fg("yellow");
		//WM.D.drawGrid(0, 0, [ "40|40|13", "50|30|10"], 1, 2);
	}//---------------------------------------------------;


	function onWindowCallbacks(s:String, el:BaseElement)
	{
		
		
		if (s == "fire") // Only buttons can fire
		{
			if (el.SID == "cbord") // change border
			{
				var w = el.parent;
					w.borderStyle++;
			}
			
			else if (el.SID == "ctitle")
			{
				var w = el.parent;
					w.title = Tools.randAr(['Title1', 'Random Title', 'Hello World', 'No title', 'untitled', '     ']);
			}
			
			else if (el.SID == "l2")
			{
				el.parent.getEl("l1");
				//var btn:Button = cast WM.DB.get("win_btn").getEl("l1");
				// One way or another
				var btn:Button = cast el.parent.getEl("l1");
				btn.text = "random";
			}
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