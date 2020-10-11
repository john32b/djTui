package;
import djTui.*;
import djTui.WM;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.TextBox;
import djTui.win.WindowLabel;
import djTui.WindowState;
import haxe.Timer;


/**
 * Textbox Demo
 * Demo and Code Usage examples
 */
class State_Textbox extends WindowState
{

	public function new() 
	{
		super("st_textbox");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "darkgray";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";
		// -
		var h = new WindowLabel(['= ${WM.NAME} - Textbox Demo'], [0, 1, 0], ["black", "yellow"]);
		
		// -- Textbox
		var win1 = new Window(55, 7, Styles.win.get('gray.1'));
			win1.title = "Random text";
		var tb1 = new TextBox("", win1.inWidth, win1.inHeight - 2);
			tb1.flag_scrollbar_autohide = false;
			tb1.setData(REG.longString);
			win1.addStack(tb1);
			win1.addStackInline([new Label("Scroll Percent :").setColor("yellow", "blue"), new Label("").setSID("sp").setColor("yellow", "blue")], 1, 0, "center");
			tb1.onScroll = (t)->{
				var l:Label = cast win1.getEl("sp");
				l.text = '' + Std.int(t.scroll_ratio * 100);
			};
			
		// --
		var win2 = new Window(40, 6, Styles.win.get('cyan.1'));
			win2.title = "Test Textbox";
			win2.focusable = false;
		var tb2 = new TextBox("", win2.inWidth, win2.inHeight);
			tb2.flag_scrollbar_autohide = false;
			tb2.setData("----");
			win2.addStack(tb2);
		
			
		// -- Control
		var ctr = new Window(30, 11, Styles.win.get('blue.1'));
			ctr.title = "controls";
			ctr.addStack(new Label("Textbox 2 :"));
			ctr.addSeparator();
			ctr.addStack(new Label("Scroll :"));
			ctr.addStackInline([new Button("st", "Top", 1) , new Button("sb", "Bottom",1)]);
			ctr.addStackInline([new Button("su", "Up", 1) , new Button("sd", "Down",1)]);
			ctr.addStack(new Button("aline", "Add Line"));
			ctr.addStack(new Button("reset", "Reset"));
			ctr.events.onElem = (a,b)->{
				if (a == "fire"){
					switch(b.SID)
					{
						case "aline": tb2.addLine("- New Line - " + tb2.linesCount); tb2.scrollBottom();
						case "reset": tb2.reset();
						case "st":   tb2.scrollTop();
						case "sb":   tb2.scrollBottom();
						case "su":   tb2.scrollUp();
						case "sd":   tb2.scrollDown();
						default:
					}
				}
			};
			
		//--
		WM.A.screen(win1, "c", "t", 3);
		win2.pos(1, win1.y + win1.height + 2);
		WM.A.right(ctr, win2,1);
		
		// NOTE:	
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [h, win1, win2, ctr];
	}//---------------------------------------------------;
	
}// --