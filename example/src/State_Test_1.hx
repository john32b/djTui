package;
import djTui.*;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.SliderNum;
import djTui.el.TextBox;
import djTui.el.TextInput;
import djTui.el.Toggle;
import djTui.win.WindowForm;
import djTui.win.WindowLabel;
import haxe.Timer;

/**
 * Test State
 * Demo and Code Usage examples
 * - Mainly things to capture for the README.MD examples
 */
class State_Test_1 extends WindowState
{

	public function new() 
	{
		super("st_test_1");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "darkgray";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";
		
		var win = new Window(30, 10, Styles.win.get('magenta.1'));
		win.title = "Select one";
		win.padding(1, 1);
		win.borderStyle = 5;
		win.addStack(new Button(".1", "Demo_Textbox"));
		win.addStack(new Button(".2", "Demo_Form"));
		WM.A.screen(win);
		
		win.listen(function(a, b){
			if (a == "fire"){
				win.close();
				if (b.SID == ".1") demo_textbox(); else
				if (b.SID == ".2") demo_form();
			}
		});		
			
		// NOTE:	
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [win];
	}//---------------------------------------------------;

	
	// - Create and show a simple textbox
	function demo_textbox()
	{
		var win = new Window(55, 10, Styles.win.get('green.1'));
			win.title = "Random Text";
		var tb = new TextBox(win.inWidth, win.inHeight - 2);
			tb.setData("Lacus venenatis leo aliquet enim semper gravida eu facilisis feugiat, pharetra ut neque ut curae fusce imperdiet placerat lacinia magna, turpis eros tortor pulvinar ultrices rutrum convallis potenti suscipit pharetra libero est cursus bibendum per quis velit, habitant sed aliquam turpis pellentesque molestie integer.\n\nProin dolor mollis non potenti duis mattis dolor malesuada habitant, elit magna in gravida ut vestibulum donec mattis nisi, donec interdum viverra himenaeos eleifend tempor suspendisse ac egestas pulvinar mattis turpis cubilia potenti sem dapibus augue posuere fames.");
			//tb.setData("Lacus venenatis ");
		win.addStack(tb);
		win.addSeparator();
		win.addStackInline([
			new Button(".1", "back", 1).colorIdle('white','darkgray'),
			new Button(".2", "exit", 1).colorIdle('white','darkgray'),
		], 0, 2, "center");
		
		win.listen(function(a, b){
			if (a == "fire") {
				if (b.SID == ".2") {
					WM.popupConfirm(function(){
						win.close();
						WM.STATE.goto("main");
					}, "Are you sure", [b.x - 10 , b.y - 2]);
				}
			}
		});
		
		WM.A.screen(win);
		win.open(true);
	}//---------------------------------------------------;
	
	
	// - Create and show the form demo
	function demo_form()
	{
		
		// Demo Screen 01
		var tt = new Window(30, 1);
			tt.flag_focusable = false;
			tt.borderStyle = 0;
			tt.modifyStyle({
				bg:"darkgray"
			});
			tt.addStack(new Label("-- demo --", tt.inWidth).scroll(250));
		
		var win = new Window(30, 13, Styles.win.get('black.1'));
			win.flag_enter_goto_next = true;
			win.addStack(new Label("Fill the form:").setColor("red"));
			win.addSeparator();
			win.addStack(new Label("Entry Name:").setColor('darkgray'));
			win.addStack(new TextInput(".inp"));
			win.addStack(new Label("Entry Number:").setColor('darkgray'));
			win.addStack(new SliderNum(".slid", 0, 999, 10, 0));
			win.addStack(new Label("Entry Toggle:").setColor('darkgray'));
			win.addStack(new Toggle(".tog", false));
			win.addSeparator();
			win.addStack(new Button(".save", "SAVE", 1).extra('@win2,anim')
				.colorIdle("white", "darkgreen"),0,"center");
			WM.A.screen(win).move( -20, 0);
			WM.A.up(tt, win);
			
		var win2 = new Window('win2', 20, 4, Styles.win.get('green.1'));
			win2.addStack(new Label("Entry Saved OK").blink(200));
			win2.addStack(new Button("", "OK", 3).colorFocus('white', 'darkgreen'),0,"center");
			win2.posNext(win).move( -10, 4);
			win2.listen(function(a, b){
				if (a == "fire") { win2.close(); win.close(); tt.close(); WM.STATE.goto("main"); }	
			});
			
			win.open(true);
			tt.open();
	}//---------------------------------------------------;
	
	
}// --