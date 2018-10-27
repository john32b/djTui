package;

import djTui.Tools;
import djTui.WM;
import djTui.Window;
import djTui.WindowState;
import djTui.el.*;
import djTui.win.ButtonGrid;
import djTui.win.WindowForm;

/**
 * ...
 * @author John Dimi
 */
class State_Misc_01 extends WindowState 
{

	public function new() 
	{
		super("state_misc");
		
		onEscGoto = "main";
		
		var w1 = getTextbox_test();
		var w2 = getWindow_Vlist_test();
		var w3 = getWindowNav_test(); // <-- error in releas
		var w4 = getWindowForm_test();
		
		// First row
		WM.A.inLine([w3, w4], 0);
		WM.A.inLine([w1, w2], w1.y + w1.height);
		list = [w1, w2, w3, w4];
		

	}//---------------------------------------------------;
	
	
	/**
	   Default open is to default open the windows.
	   but I am overriding it to customize the position
	**/
	override function open(?data:Dynamic) 
	{
		WM.set_TAB_behavior("WM","keep");
		super.open();
	}//---------------------------------------------------;
	
	
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
		var t = new TextBox(w.inWidth, w.inHeight-1);
			t.flag_scrollbar_autohide = false;
			t.setData("A computer is a device that can be instructed to carry out sequences of arithmetic or logical operations automatically via computer programming. Modern computers have the ability to follow generalized sets of operations, called programs. These programs enable computers to perform an extremely wide range of tasks.Computers are used as control systems for a wide variety of industrial and consumer devices. This includes simple special purpose devices like microwave ovens and remote controls, factory devices such as industrial robots and computer-aided design, and also general purpose devices like personal computers and mobile devices such as smartphones.");
			w.addStack(t);
			w.addStackInline([new Button("", "clear").onPush(function(){ t.reset(); })], 0, 0, "center");
		return w;
		
		// ^ testing adding before
	}//---------------------------------------------------;
	
	
	function getWindow_Vlist_test():Window
	{
		var w = new Window( -2, -2);
			w.title = "VLIST demo";

		var l = new VList(w.inWidth, w.inHeight - 3);
			l.flag_ghost_active = true;
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
		
		var w = new ButtonGrid(null, -3, -2, 2);
			w.setButtonStyle(9, 0, 0, 1 );
			w.setColumnStyle(0, 2, 1);
			w.add(0, "Style", "s1");
			w.add(0, "Exit", "s2");
			w.add(1, "Btn 3");
			w.add(1, "Btn 4");
			//
		//w.listen( function(a, b)
		//{
			//if (a == "focus")
			//{
				//trace("Cursor POS " + w.getData());
			//}
			//
			//if (a == "fire")
			//{
				//if (b.SID == "s1") // Toy around with colors
				//{
					//// This alters the style for the already open windows
					//// It is buggy, It's better to alter the default style and close and recreate all the windows
					//for (i in WM.win_list)
					//{
						//i.modifyStyle(
						//{
							//bg: Tools.randAr([ "darkgray", "black", "darkred", "darkmagenta", "darkblue", "darkcyan" ]),
							//
							//borderColor:{
								//fg:Tools.randAr([ "darkgray", "black", "darkred", "darkmagenta", "darkblue", "darkcyan" ]),
								//bg:Tools.randAr([ "darkgray", "black", "darkred", "darkmagenta", "darkblue", "darkcyan" ])
							//}
						//});
						//i.borderStyle = Std.random(7);
						//i.draw();
					//}
				//}else
				//if (b.SID == "s2")
				//{
					//// Will autoclose this state and goto the main state
					//WM.STATE.goto("main");
				//}
			//}
		//});
			
		return w;
		
	}//---------------------------------------------------;
	
	// create and run a form
	function getWindowForm_test():Window
	{
		var w:WindowForm = new WindowForm( -2, -2);
			w.setAlign("fixed");
			w.setLabelFocusColor("yellow", "blue");
		
		w.addQ("+ Input", "input,a0").colorFocus("white", "blue");
		w.add("! Confirm", new Button("_quit", "Quit").extra("?Are you Sure?").onPush(function(){Sys.exit(0); }));
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
	
}