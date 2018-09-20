package;

import djNode.BaseApp;
import djNode.tools.LOG;
import djTui.*;
import djTui.el.*;
import djTui.adaptors.djNode.*;
import djTui.win.ButtonGrid;
import djTui.win.WindowForm;

/**
 * Test main for djTui
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
		
		// Init the Window Manager and set some parameters :
		WM.create(
			new InputObj(), 
			new TerminalObj(), 80, 25
		);
		
		WM.flag_debug_trace_element_callbacks = true;
		//WM.flag_tab_switch_windows = true;
		
		// Quickly set many fields of the default WM style, instead of doing them one by one :
		Tools.copyFields({
			titleColor_focus:{fg:"blue", bg:"green"},
			borderStyle:2,
			//bg:"blue",
			text:"gray",
			textbox_focus: { fg:"white" },
			textbox: { fg:"gray" },
			scrollbar_focus:{fg:"white",bg:"red"}
		}, WM.global_style_win);
		
		// The background color is in a separate variable :
		//WM.backgroundColor = "darkblue";
		
		
		var state1 = new StageTests();
			state1.start();
		return;
		
		
		//
		//WM.T.fg("yellow");
		//WM.D.drawGrid(0, 0, [ "40|40|13", "50|30|10"], 1, 2);
		
		//WM.D.drawArray
		// -- Add some things
		
		//create_test_window_1();
		
		WM.flag_tab_switch_windows = true;
		var w1 = getWindowForm_test();
		var w2 = getTextbox_test();
		//var w2 = create_test_window_1();
		var w3 = getWindowNav_test(); 
		var w4 = getWindow_Vlist_test();
		WM.addTiled([w1, w2]);
		WM.addTiled([w3, w4], w1);
		

		return;
		
		// ------------  [ RETURN ] ------------------------------- //
		
		WM.onElementCallback = onWindowCallbacks;
		
		var win1 = new Window( -3, 15);
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
		//win1.addStack(new Button("", "test"));

	
		//- Button window
		var win2 = new Window("win_btn", -3, 15);
			win2.posNext(win1, 2);
			win2.title = "Button Test";
			// add some buttons
			win2.addStack(new Button("cbord", "► Change Border").colorIdle("red", "green").colorFocus("white", "blue"));
			win2.addStack(new Button("ctitle", "► Change Title"));
			win2.addStack(new Button("l1", "Link with a rather long text", 0 ));
			win2.addStack(new Button("l2", "Modify button", 1 ));
			win2.addStack(new Button("cc", "Confirm", 2 ).confirm(true));
			win2.addStack(new Button("@win_lab,close,anim,center", "Call WINDOW 2", 4 ));
			win2.addStack(new Button("#state2,close,anim,center", "Call STATE  2", 4 ));
			
			
		WM.STATE.create("state1", [win1, win2]);
		
		
		// -- Create State 2
		
		var ww = new Window(10, 7);
		
		ww.title = "win1";
		ww.pos(1, 1);
		
		var ww2 = new Window(10, 20);
		ww2.title = "win2";
		ww2.posNext(ww);
		ww2.addStack(new Button("", "Button 1", 1 ));
		ww2.addStack(new Button("#state3", "Goto State Grid", 1 ));
		ww2.addStack(new Button("#state1", "CALL state 1", 4 ));
		
		WM.STATE.create("state2", [ww, ww2]);
		
		// -- Create State 3 a window button only
		
		var wb = new ButtonGrid(40, 10, 2, 1);
			wb.SID = "bg1";
			wb.size(40, 10).pos(3, 3);
			wb.add(0, "1");
			wb.add(0, "2");
			wb.add(1, "a 1");
			wb.add(1, "b 1");
			
		WM.STATE.create("state3", [wb]);
		
		WM.STATE.onStateOpen = function(st)
		{
			WM.T.bg("darkblue");
			WM.D.rect(0, 0, WM.width, WM.height);
			trace("->> Just going to state :" +  st.SID);
		};
		
		WM.STATE.goto("state1"); 
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

	
	
	
	
	
	//====================================================;
	//  TESTS
	//====================================================;bassaas
	
	function getTextbox_test():Window
	{
		var w = new Window( -2, -2);
			w.padding(2, 2);
			//w.style.titleColor = {fg:"white", bg:"red"};
			//w.style.titleColor_focus = {fg:"black", bg:"white"};
			w.modifyStyle({
				titleColor_focus : {fg:"black", bg:"white"}
			});
			
			w.title = "Textbox";
		var t = new TextBox(w.inWidth, w.inHeight);
			t.flag_scrollbar_autohide = false;
			w.addStack(t);		
			t.setData("A computer is a device that can be instructed to carry out sequences of arithmetic or logical operations automatically via computer programming. Modern computers have the ability to follow generalized sets of operations, called programs. These programs enable computers to perform an extremely wide range of tasks.Computers are used as control systems for a wide variety of industrial and consumer devices. This includes simple special purpose devices like microwave ovens and remote controls, factory devices such as industrial robots and computer-aided design, and also general purpose devices like personal computers and mobile devices such as smartphones.");
		return w;
		
		// ^ testing adding before
	}//---------------------------------------------------;
	
	
	function getWindow_Vlist_test():Window
	{
		var w = new Window( -2, -2);
			w.title = "VLIST demo";

		var l = new VList(w.inWidth, w.inHeight-3);
			l.flag_scrollbar_autohide = true;
			l.setData([
				"PopupOption",
				"SliderNum",
				"SliderOption",
				"TextInput",
				"Button",
				"Label",
				"Toggle",
				"SliderNum",
				"SliderOption",
				"TextInput",
				"Button",
				"Label"
			]);
			l.listen (function(a, b)
			{
				if (a == "change")
				{
					trace("New list " + cast(b,VList).getSelectedText() );
				}
			});
		
		
		w.addStack(l);
		w.addSeparator(1);
		w.addStackInline([
			new Button('new', "New", 2).onPush(function(){l.add("New Element " + Std.random(10)); }),
			new Button('new', "Delete All", 2).onPush(function(){l.reset();})
		]);		
		
		// ^ testing adding [data] after
		
		return w;
		
	}//---------------------------------------------------;
	
	function getWindowNav_test():Window
	{
		
		var w = new ButtonGrid("", -2, -2, 2, 1);
			w.setButtonStyle(7, 0, 1, 1 ).enableSeparators();
			w.add(0, "Style 1", "s1");
			w.add(0, "Style 2", "s2");
			w.add(1, "Button 3");
			w.add(1, "Button 4");
			
		w.listen( function(a, b)
		{
			if (a == "focus")
			{
				trace("Cursor POS " + w.getData());
			}
			
			if (a == "fire")
			{
				if (b.SID == "s1")
				{
					// This alters the style for the already open windows
					// It is buggy, It's better to alter the default style and close and recreate all the windows
					for (i in WM.win_list)
					{
						i.modifyStyle(
						{
							bg: Tools.randAr([ "darkgray", "black", "darkred", "darkmagenta", "darkblue", "darkcyan" ]),
							
							borderColor:{
								fg:Tools.randAr([ "darkgray", "black", "darkred", "darkmagenta", "darkblue", "darkcyan" ]),
								bg:Tools.randAr([ "darkgray", "black", "darkred", "darkmagenta", "darkblue", "darkcyan" ])
							}
						});
						i.borderStyle = Std.random(7);
						i.draw();
					}
				}
			}
		});
			
		return w;
		
	}//---------------------------------------------------;
	
	// create and run a form
	function getWindowForm_test():Window
	{
		var w:WindowForm = new WindowForm( -2, -2);
			w.setAlign("fixed");
			w.setLabelFocusColor("yellow", "blue");
		//w.add("Label Text", new Button("b1", "Button",1));
		//w.add("Label Text", new Button("b2", "Another one",1));
		//w.add("This is a really long 1234 line", new Button("b3", "Close", 3));
		//w.add("> Label", new SliderNum("", 0, 10, 1, 143).colorFocus("white", "blue"));
		//w.add("> Label", new PopupOption("", ["one", "two", "three"], 0, 5));
		//w.add("> LBL", new Toggle());
		//w.add("> Select Color", new SliderOption("", ["red", "green", "blue"], 0));
		w.add("! Confirm", new Button("_quit", "Quit").extra("?Are you Sure?").onPush(function(){Sys.exit(0); }));
		w.addQ("+ Input", "input,a0").colorFocus("white", "blue");
		var pp = w.addQ("+ Popup Opt", "popOpt,a3,one|2|two|no|three|four");
		var ww = w.addQ("+ Slider NUM", "slNum,a1,0,1000,100");
			ww.colorFocus("green", "blue");
			ww.setSideSymbolPad(2, 1);
			ww.setTextWidth(0); 
		w.addQ("+ Slider OPT", "slOpt,a2,one|two|three").colorIdle("white", "gray");
		var btn = w.addQ("Quick Button", "button,b1,Button Text,1");
			btn.colorFocus("black", "white").setSideSymbolPad(0, 2);
		w.addQ("Quick Label", "label,Label text,0,right");
		w.addQ("Quick Toggle", "toggle");
		w.title = "WindowForm Test";
		
		return w;
	}//---------------------------------------------------;
	
	
	function create_test_window_1()       
	{
		var w = new Window("win_lab", -2, -2);
		w.title = "Labels";
		w.addStackInline([
				new Label("Label1").setColor("green", "white"), 
				new Label("Label2").setColor("red", "yellow")
		]);
				
		w.addStackInline([
			new Label("one"), 
			new Label("two"), 
			new Label("three"), 
			new Button("", "btn", 2).setSideSymbolPad(1, 1)
		]);

		return w;
			
	}//---------------------------------------------------;
	
}// --