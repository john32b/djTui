package;
import djTui.WM;
import djTui.Window;
import djTui.WindowState;
import djTui.win.ButtonGrid;

/**
 * ButtonGrid Example
 * ...
 */
class State_ButtonGrid extends WindowState
{

	public function new() 
	{
		super("st_btnnav");
		onEscGoto = "main";
	}//---------------------------------------------------;
	
	override public function open(?data:Dynamic) 
	{
		// -
		var COLUMNS:Int = 2;
		
		// NOTE : -2 = Half the screen width
		var w = new ButtonGrid(null, -2, 13, COLUMNS);
		
		w.modifyStyle ({
			bg:"red",
			text:"yellow" // Yellow separator
		});
		
		
		// Separator style = 3, xPad = 2, Vertical pad = 0
		w.setColumnStyle(3, 2, 0);
		// Button Style = 4
		// Button width = auto
		// Padout, PadIn = 1
		w.setButtonStyle(2, 0, 1, 1);
			
		add(w);
		
		
		for (c in 0...COLUMNS)
		for (i in 0...5)
		{
			w.add(c, 'btn');
		}
		
		w.add(0, "EXIT", "#main");
		
		WM.A.screen(w).move(0, 2);
		
		// ---
		
		// -- Return Window
		super.open(data);
		
	}//---------------------------------------------------;
	
}