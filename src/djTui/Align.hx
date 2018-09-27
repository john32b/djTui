package djTui;

/**
 * Align utilities for windows
 * Singleton class ccessible through `WM.A`
 * 
 */
class Align 
{

	// Test guide winect
	var g:Window = null;
	
	public function new() 
	{
	}//---------------------------------------------------;
	
	
	/**
	 * Align a window using the Terminal Viewport as a guide
	 * @param	win Window to align
	 * @param	alignX left,center,right,none
	 * @param	alignY top,center,bottom,none
	 * @param   padding Apply this much padding 
	 */
	public function screen(win:Window, alignX:String = "center", alignY:String = "center", pad:Int = 0):Window
	{
		var tx:Int = 0;
		var ty:Int = 0;
		
		switch(alignX)
		{
			case "left" : tx = 0 + pad;
			case "right" : tx = WM.width - win.width - pad;
			case "center" : tx = Std.int((WM.width / 2) - (win.width / 2));
			default:
		}
		
		switch(alignY)
		{
			case "top" : ty = 0 + pad;
			case "bottom" : ty = WM.height - win.height - pad;
			case "center" : ty = Std.int((WM.height / 2) - (win.height / 2));
			default: 
		}
		
		win.pos(tx, ty);
		
		return win; // for chaining
	}//---------------------------------------------------;
	
	/**
	   Place A on top of B
	**/
	public function up(A:Window, B:Window, offx:Int = 0, offy:Int = 0):Window
	{
		A.move(B.x + offx, B.y - A.height + offy);
		return A;
	}//---------------------------------------------------;
	
	public function down(A:Window, B:Window, offx:Int = 0, offy:Int = 0):Window
	{
		A.move(B.x + offx , B.y + B.height + offy);
		return A;
	}//---------------------------------------------------;
	
	public function left(A:Window, B:Window, offx:Int = 0, offy:Int = 0):Window
	{
		A.move(B.x - A.width + offx, B.y + offy);
		return A;
	}//---------------------------------------------------;
	
	public function right(A:Window, B:Window, offx:Int = 0, offy:Int = 0):Window
	{
		A.move(B.x + B.width + offx, B.y + offy);
		return A;
	}//---------------------------------------------------;
	
	
	/**
	   Move a collection of windows in the same Line
	   @param	A Array of Windows
	   @param	Y The Y Coordinate Line on the terminal to place the windows
	   @param	align center,left,right
	   @param	p1 Padding between elements
	   @param   p2 Padding from the edges and placement, applies to "left", "right"
	**/
	public function inLine(A:Array<Window>, Y:Int, align:String = "center", p1:Int = 0, p2:Int = 0)
	{
		var sx:Int; 		// start x, when placing
		function getTW() {  // Get total width of elements ( padding included )
			var tw = 0;
			for (w in A)  tw += w.width;
			tw += (A.length - 1) * p1;
			return tw;
		}
		switch(align) {
			case "left":
				sx = p2;
			case "right":
				sx = p2 + WM.width - getTW();
			case "center":
				sx = p2 + Std.int( (WM.width / 2) - (getTW() / 2));
			default:
				throw 'Not supported align type `$align` Typo?';
		}
		
		for (w in A) { w.pos(sx, Y); sx += w.width + p1; }
	}//---------------------------------------------------;
	
	//
	//public static function addTiled(w_arr:Array<Window>, ?from:Window)
	//{
		//var ww:Window = from; // Temp
		//
		//var nextX:Int = 0; 
		//var nextY:Int = 0; 
		//
		//if (ww == null && win_list.length > 0)
		//{
			//ww = win_list[win_list.length - 1];
		//}
		//
		//if (ww != null)
		//{
			//nextY = ww.y + ww.height;
		//}
		//
		//var c:Int = 0;
		//do {
			//ww = w_arr[c];
			//ww.pos(nextX, nextY);
			//add(ww, false);
			//nextX = ww.x + ww.width;
		//}while (++c < w_arr.length);
		//
	//}//---------------------------------------------------;
		//
}// --