package;
import djTui.*;
import djTui.el.Label;
import djTui.el.TextBox;
import djTui.win.WindowForm;
import djTui.win.WindowLabel;

/**
 * WindowForm
 * Demo and Code Usage examples
 */
class State_WinForm extends WindowState
{

	public function new() 
	{
		super("st_winform");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "cyan";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";
		
		// 
		var h = new WindowLabel(['= ${WM.NAME} - WinForm Demo'], [0, 1, 0], ["black", "gray"]);	
		
		// -- WindowForm
		var wf = new WindowForm( -2, 17, Styles.win.get('blue.1'));
			wf.pos(2, 2);
			wf.setAlign("fixed", 1, -2);
			wf.addQ("Button -", "button,,Button Text,1,1"); // You can skip SID
			wf.addQ("Button -", "button,,Button,2,0");
			wf.addQ("Button -", "button,sid,Btn");
			wf.addSeparator();
			wf.addQ("Toggle", "toggle,togsid,true");
			wf.addQ("Slider Number", "slNum,snum,0,10,1,5");
			wf.addQ("Slider Option", "slOpt,sopt,Option1|Option2|Option3|Other|Test");
			wf.addQ("Popup Option", "popOpt,sidopt,Option1|Option2|Option3|Other|Test,3,0");
			wf.addQ("Label Test", "label,Label Text,1,center");
			wf.addQ("Input field", "input,sidino,0,all");
			wf.addSeparator();
			// - You can also add other elements normally:
			wf.addStack(new Label("On Change:").setColor("black", "white"));
			wf.addStack(new Label().setSID("c01"));
			wf.addStack(new Label("On Select:").setColor("black", "white"));
			wf.addStack(new Label().setSID("c02"));
			
			wf.events.onElem = (a, b)->{
				if (a == "change")
				{
					var ss = cast(wf.getEl("c01"), Label);	
					ss.text = '' + b.getData();
				}else
				if (a == "fire")
				{
					var ss = cast(wf.getEl("c02"), Label);	
					ss.text = '' + b.getData();
				}
				return;
			}
			
		// -- Information Box
		var info = new Window(30, 18, Styles.win.get('gray.1'));
			info.focusable = false;
		var tb:TextBox = new TextBox(info.inWidth, info.inHeight);
		info.addStack(tb);
		tb.setData("A WindowForm extends a Window and allows quickly adding elements in a window along with some descriptive text. Checkout the source code on usage.\n\n==Arrow keys to navigate, Enter to select/interact with elements.");
		info.posNext(wf, 3);
		
		// NOTE:	
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [h, wf, info];	
	}//---------------------------------------------------;
	
}// --