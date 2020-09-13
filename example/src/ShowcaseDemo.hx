package;

import djTui.*;
import djTui.el.*;
import djTui.win.MenuBar;
import djTui.win.MessageBox;
import djTui.win.WindowLabel;


/**
 * Platform generic -
 * Showcase and code usage for djTUI
 * -----
 * You need to create the WM object before starting the demo
 */
class ShowcaseDemo 
{

	public function new() 
	{
	}
	
	public function start()
	{
		
		WM.set_TAB_behavior("WM", "keep");

		// Set the background color for the whole terminal area
		WM.backgroundColor = "darkblue";
		
		//--------------------------------------------
		//- Draw some stuff that will be visible in all
		
		// : Title Window
		var head = new WindowLabel(['== ${WM.NAME} V ${WM.VERSION} ==', " - Demo and use examples - "], "center", ["black", "cyan"]);
		
		// : Footer
		var foot = new WindowLabel(["[Arrow Keys / TAB] = MOVE | [ENTER] = SELECT | [ESC] = BACK"], "center", [0, 0, 0], ["black", "cyan"]);
			foot.placeBottom();
		WM.add(foot); // <-- Add the footer, this will be visible with all statesb
		
	
		// : Main Menu 
		var menu = new Window( 40, 18);
			menu.addStack(new Label("Select a demo :").setColor("black", "white"));
			menu.addSeparator();
			menu.pos(3, 4);
			
			// Add a button for every state
			for (i in REG.states.keys())
			{
				var b = new Button(i, i, 0, 0);
					b.setSideSymbolPad(2, 0);
					b.onPush(function(){
						menu.flag_return_focus_once = true;
						WM.STATE.open(Type.createInstance(REG.states.get(b.SID), []));
					});
				menu.addStack(b);
			}
			

		// Quit/About Menu
		// --
		var qWin = new MenuBar(menu.width, 2);
			qWin.setItemStyle("center", 0, 1);
			qWin.setPanelStyle("white", "magenta");
			qWin.setItems(["QUIT", "ABOUT"]);
			WM.A.down(qWin, menu);
			qWin.onSelect = function(s){
				if (s == 0) // QUIT
				{
					var a = qWin.active;
					var p = [a.x - 2, a.y - 3];
					WM.popupConfirm(function(){
						#if terminal
						Sys.exit(0);
						#end
					}, "Really Quit", p);
					
				}else // ABOUT
				{	
					var m = new MessageBox("Terminal User Interface, made from scratch.", 0);
						m.flag_close_on_esc = true;
						WM.A.screen(m).move(2, 2);
						qWin.openSub(m, true);
				}
			}
			
			
			
		// TextBox
		var wint = new Window(30, 15, Styles.win.get('gray.1'));
			wint.flag_focusable = false;
			wint.posNext(menu, 2).move(0, 3);
			var tb = new TextBox(wint.inWidth, wint.inHeight);
				tb.setData(
				"DJTui is a render agnostic Terminal Interface. Built with HAXE, it can target many environments. This demo runs on nodeJS on a real terminal.\n\n== Use the arrow keys to navigate. Enter to select , Esc to go back."
				);
			wint.addStack(tb);
		
			
			
		// Dynamically create a state with those 2 windows
		// This way I can open/close these windows quickly
		WM.STATE.create("main", [head, menu, qWin, wint]);

		
		#if debug
		// Skip the main menu and go to a state for quick testing
		if (REG.startState != null) {
			WM.STATE.open(Type.createInstance(REG.startState, []));
			return;
		}
		#end
		
		WM.STATE.goto("main");
		
	}//---------------------------------------------------;
	
}// --