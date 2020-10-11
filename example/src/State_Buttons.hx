package;
import djTui.*;
import djA.DataT;
import djTui.WM;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.TextBox;
import djTui.win.WindowLabel;
import djTui.WindowState;
import haxe.Timer;

/**
 * Buttons Example
 * Demo and Code Usage examples
 */
class State_Buttons extends WindowState
{
	public function new() 
	{
		super("st_buttons");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "darkmagenta";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";

		//
		var h = new WindowLabel(['= ${WM.NAME} - Buttons Demo'], [0, 1, 0], ["black", "gray"]);	
		
		// Create a bunch of buttons in a window
		var w1 = new Window(34, 12, Styles.win.get("black.1"));
			w1.addStack( new Button("", "Normal Button") );
			w1.addStack( new Button("", "Disabled Button").disable() );
			w1.addStack( new Button("", "Custom Colors").colorIdle("red").colorFocus("red", "magenta"));
			w1.addStack( new Button("", "Confirmation").extra("?Are you sure?"));
			w1.addStack( new Button("", "Custom Length", 0, w1.inWidth).colorIdle("red", "cyan"));
			w1.addStack( new Button("", "Custom Style", 3).setSideSymbolPad(2, 2));
			w1.addStack( new Button("testbtn", "-test button-"));
			w1.addStack( new Button("","Toggle Disable Status ^").onPush( ()->{
					var b:Button = cast w1.getEl("testbtn");
						b.disable(!b.disabled, true);
						b.text = b.disabled?"disabled":"enabled";
				}));
							
				
			w1.addStack( new Button("b_text", "---") );
			w1.addStack( new Button("", "Write Text ^").onPush( ()->{
					var b:Button = cast w1.getEl("b_text");
						b.text = DataT.randAr(["random", "test 01", "other", "hello", "world", "djtui"]);
				}));
				
				
				
		// Info Window
		var w2 = new Window( 60, 4, Styles.win.get("gray.1"));
			w2.focusable = false;
			var tb = new TextBox(w2.inWidth, w2.inHeight);
				tb.setData([
					"Demo and usage on Buttons", "Select with arrow keys and press enter to interact"
				]);
				w2.addStack(tb);
		
				
		// Some info on selected buttons
		var w3 = new Window(w1.width, 10, Styles.win.get("green.1"));
			w3.focusable = false;
			w3.title = "Info";
			// NOTE:
			w3.addStack(new Label("Current Selected SID :"));
			w3.addStack(new Label().setColor("white", "blue"));
			w3.addStack(new Label("Last Pressed SID :"));
			w3.addStack(new Label().setColor("white", "blue"));
			w3.addStack(new Label("Just Pressed :"));
			w3.addStack(new Label().setColor("black"));
			
			
		// - Event listener for the main window
		w1.events.onElem = function(msg, elem)
		{	
			if (msg == "focus" && elem.type == djTui.ElementType.button)
			{
				// NOTE:
				// I am getting elements by their index order, I could get them by SID
				// this is easier. Just make sure you don't change the order afterwards
				// Count starts at 2 (border + title are the first 2 elements)
				var l:Label = cast w3.getElIndex(3);
					l.text = elem.SID;
			}
			
			if (msg == "fire") // Buttons will send `fire` when pressed
			{
				var l1:Label = cast w3.getElIndex(5);
					l1.text = elem.SID;
				var l2:Label = cast w3.getElIndex(7);
					l2.text = "-" + cast (elem, Button).text + "-";
					// Blink the text and erase it after a while
					l2.blink(9,50);
						Timer.delay(()->{
							l2.anim_stop();
							l2.text = "";
						},800);
			}
		}// -- on elem
			
			
		// - Place the windows	
		WM.A.inLine([w1, w3], 3, "c");
		WM.A.screen(w2, "c", "b", 2);
		
		// NOTE:	
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [h, w1, w2, w3];
	}//---------------------------------------------------;
	
}// --