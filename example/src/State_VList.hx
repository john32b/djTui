package;
import djTui.*;
import djTui.WM;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.TextBox;
import djTui.el.VList;
import djTui.win.WindowLabel;
import djTui.WindowState;
import haxe.Timer;


/**
 * VList Demo
 * Demo and Code Usage examples
 */
class State_VList extends WindowState
{

	public function new()   
	{
		super("st_vlist");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "darkcyan";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";
		// -
		var h = new WindowLabel(['= ${WM.NAME} - VList Demo'], [0, 1, 0], ["black", "yellow"]);

		
		// -- Main
		var win = new Window(20, 15);
		var vlist = new VList(win.inWidth, win.inHeight);
		for(i in 0...20)
		{
			vlist.addLine("Entry Line " + i);
		}
			win.addStack(vlist);
			win.pos(3, 2);
			
			
		// -- other list
		var win2 = new Window(30, 7, Styles.win.get('red.1'));
			win2.pos(26, 13);
		var vl2 = new VList(win2.inWidth, win2.inHeight);
			vl2.setData([
			"A. Test letter jumps",
			"B. Press the first letter",
			"C. To quick jump to ",
			"C. an entry",
			"D.", 
			"E. Only works in",
			"F. sorted (a-z)",
			"H. lists"
			]);
			vl2.flag_ghost_active = true;
			vl2.flag_letter_jump = true;
			vl2.flag_scrollbar_autohide = false;
			win2.addStack(vl2);
			
		// -- Information Box
		var info = new Window(44, 10, Styles.win.get('gray.1'));
			info.flag_focusable = false;
		var tb:TextBox = new TextBox(info.inWidth, info.inHeight);
			tb.setData("A Vertical List is just a TextBox with a cursor, which you can control and select elements. It shares all the basic functionality of the Textbox.\n-- Arrow keys, PageUp/Down to navigate , \n[Εnter] to select an element.");
			info.addStack(tb);
			info.posNext(win, 3);
			
		// --
		var info2 = new Window(18, 4, Styles.win.get('cyan.1'));
			info2.flag_focusable = false;
			info2.padding(1,1);
			info2.borderStyle = 0;
			info2.addStack(new Label("Selected Index :").setColor("red"));
			info2.addStack(new Label().setSID("s1"));
			info2.pos(WM.width - info2.width - 3, info.y + info.height + 1);
			
		// --
		vlist.onSelect = function(index) {
			var f:Label = cast info2.getEl("s1");
			f.text = '' + index;
		}
		// copy the listener
		vl2.onSelect = vlist.onSelect;
		
		// NOTE:	
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [h, win, win2, info, info2];
	}//---------------------------------------------------;
	
}// --