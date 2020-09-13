package;
import djTui.*;
import djTui.WM;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.TextBox;
import djTui.win.ButtonGrid;
import djTui.win.WindowLabel;
import djTui.WindowState;
import haxe.Timer;


/**
 * ButtonGrid Demo
 * Demo and Code Usage examples
 */
class State_ButtonGrid extends WindowState
{

	public function new() 
	{
		super("st_buttonGrd");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "red";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";
		
		//
		var h = new WindowLabel(['= ${WM.NAME} - ButtonGrid Demo'], [0, 1, 0], ["black", "yellow"]);	
		
		// -- Test 1
		var g1 = new ButtonGrid(23, 7, 3);
			g1.title = "Numbers";
			g1.setButtonStyle(1, 0, 1, 1);
			g1.add(0, "1");
			g1.add(1, "2");
			g1.add(2, "3");
			g1.add(0, "4");
			g1.add(1, "5");
			g1.add(2, "6");
			g1.add(0, "7");
			g1.add(1, "8");
			g1.add(2, "9");
		
		
		// -- Test 2
		var g2 = new ButtonGrid(30, 14, 2);
			g2.title = "Other";
			g2.setColumnStyle(0, 2, 2);
			g2.add(0,"Btn");
			// Adding elements to the grid, returns button objects, so I can customize them.
			g2.add(0,"Custom Color").colorIdle("yellow","blue").colorFocus("white","darkblue");
			g2.add(0,"Custom Color").colorIdle("red", "black");
			g2.add(1, "Empty");
			g2.add(1, "Empty");
			g2.add(1, "Empty");
			g2.add(1, "Empty");
		
		
		// -- Info Box 0
		var inf = new Window(25, 8, Styles.win.get("magenta.1"));
			inf.flag_focusable = false;
			inf.borderStyle = 3;
			inf.addStack(new Label("From Window :").setColor("yellow","darkmagenta"));
			inf.addStack(new Label().setSID("win"));
			inf.addStack(new Label("Selected SID :").setColor("yellow","darkmagenta"));
			inf.addStack(new Label().setSID("ssid"));
			inf.addStack(new Label("Selected Coords :").setColor("yellow","darkmagenta"));
			inf.addStack(new Label().setSID("coords"));
			
		
		// -- Info Text
		var inf1 = new Window(72, 5, Styles.win.get('gray.1'));
			inf1.flag_focusable = false;
		var tb:TextBox = new TextBox(inf1.inWidth, inf1.inHeight);
			inf1.addStack(tb);
			tb.setData(
			"ButtonGrid presents buttons in a Grid. You can customize the global button style, color, column width, etc. -- Use arrow keys to navigate in the grid. Press [ENTER] to select --"
			);
			
			
		// -- Add listeners
		g1.onPush = function(btn, coords){
			var a1:Label = cast inf.getEl("ssid");
			var a2:Label = cast inf.getEl("coords");
			var a3:Label = cast inf.getEl("win");
			a1.text = btn.SID;
			a2.text = coords;
			a3.text = btn.parent.title;
		};
		
		g2.onPush = g1.onPush;
		
	
		// - Pace windows
		WM.A.screen(inf1, "c", "b", 2);
		WM.A.inLine([g1, g2], 2, "c");
		WM.A.down(inf, g1, -3, 1);
		
		
		// NOTE:
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [h, g1, g2, inf1, inf];
		
	}//---------------------------------------------------;
	
}// --