package;
import djTui.WM;
import djTui.Window;
import djTui.win.MenuBar;


/**
  - A stage for Tests
  - Unit test like helper class
 
   PRE: 
	- WM has been initialized
**/
class StageTests 
{

	public function new() 
	{
		
	}//---------------------------------------------------;
	
	public function create()
	{
		
	}//---------------------------------------------------;
	
	public function start()
	{
		// -- Test Menubar
		
		var w = get_menubar(false,"red","cyan");
			w.pos(1, 1);
			w.open(true);
		
		var w1:MenuBar = cast get_menubar(true,"yellow","red");
			//w1.pos(w.x, w.y + 4);
			w1.screenCenter();
			w1.open();
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Components
	//====================================================;
	
	
	function get_menubar(thick:Bool,col1:String,col2:String):Window
	{
		var w = new MenuBar();
		w.setPanelStyle(col1, col2, thick, 1);
		w.setItemStyle("left", 0, thick?0:1,3);
		w.set(["FILE", "EDIT", "ABOUT"]);
		return w;
	}//---------------------------------------------------;
	
}//--