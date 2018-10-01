package;
import djTui.WM;
import djTui.Window;
import djTui.WindowState;
import djTui.win.ButtonGrid;

/**
 * Textbox Demo/Test
 * ...
 */
class State_ButtonGrid extends WindowState
{

	public function new() 
	{
		super("st_btnnav");
	}
	
	override public function open(?data:Dynamic) 
	{
		// -
		var TC:Int = 2;
		var w = new ButtonGrid(null, -2, 13, TC);
		
			w.modifyStyle ({
				bg:"darkblue"
			});
			
			w.setColumnStyle(3, 2, 0);
			w.setButtonStyle(4, 0, 1, 1);
		add(w);
		
		
		for (c in 0...TC)
		for (i in 0...5)
		{
			w.add(c, '12345');
		}
		
		w.add(0, "EXIT", "#main");
		w.pos(3, 4);
		
		// -- Return Window
		super.open(data);
		
	}//---------------------------------------------------;
	
}