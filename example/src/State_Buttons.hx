package;
import djTui.Styles;
import djTui.WM;
import djTui.Window;
import djTui.WindowState;
import djTui.el.Button;
import djTui.win.WindowForm;

/**
 * Buttons Example
 * ...
 */
class State_Buttons extends WindowState
{

	public function new() 
	{
		super("st_textbox");
		onEscGoto = "main";
		

		
		// Create a bunch of buttons in a window
		var w1 = new Window(40, 10);
			w1.padding(3, 2).pos(3, 3);
			w1.style = Styles.win.get("green.1");
		WM.A.screen(w1);
		
		w1.addStack( new Button("b1", "Normal Button") );
		w1.addStack( new Button("b2", "Disabled Button").disable() );
		w1.addStack( new Button("b3", "TEST", 2, 20) );
		w1.addStack( new Button("b4", "^ Toggle Disable Status").onPush( 
			function(){
				var b:Button = cast w1.getEl("b3");
				b.disable(!b.disabled, true);
			}));
		
		// NOTE:
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [w1];
		
	}//---------------------------------------------------;
	
	
	override public function open(?data:Dynamic) 
	{
		super.open(data);
	}//---------------------------------------------------;
	
}// --