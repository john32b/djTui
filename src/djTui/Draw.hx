package djTui;

/**
 * Provide some Extra Drawing Functions
 * ----------------
 * @ SINGLETON, exists in WM.D
 */
class Draw 
{

	
	public function new() 
	{
	}//---------------------------------------------------;

	
	/**
	   Fill a rectangle. Colors from what is already set in WM.T
	   @param	x
	   @param	y
	   @param	width
	   @param	height
	   @param	char Character fill, Defaults to " "
	   @return
	**/
	public function rect(x:Int, y:Int, width:Int, height:Int, char:String = " ")
	{
		var s:String = StringTools.lpad("", char, width);
		
		for (ff in y...y + height) 
		{
			WM.T.move(x, ff).print(s);
		}
	}//---------------------------------------------------;
	
	
	/**
	   Draw a border with current terminal colors
	   @param	x
	   @param	y
	   @param	width
	   @param	height
	   @param	style A border style index (0-2), see `Styles.hx`
	   @return
	**/
	public function border(x:Int, y:Int, width:Int, height:Int, style:Int = 1)
	{
		var bs = Styles.border[style]; // shorthand
		var c = 0;	// loop counter

		// Draw the Top:
		WM.T.move(x, y);
		WM.T.print(
			bs[0] +
			StringTools.lpad("", bs[1], width - 2) +
			bs[2] );
			
		// Draw the Body:
		while (++c < height) 
		{
			WM.T.move(x, y + c).print(bs[6]);
			WM.T.moveR(width - 2, 0).print(bs[7]);
		}
			
		// Draw the bottom:
		WM.T.move(x, y + height - 1);
		WM.T.print(
			bs[3] +
			StringTools.lpad("", bs[4], width - 2) +
			bs[5]);
	}//---------------------------------------------------;
	
	
	/**
	 * Draws an array of strings.
	 * - Useful for printing ASCII fonts
	 */
	public function drawArray(ar:Array<String>, x:Int, y:Int):Void
	{
		for (i in 0...ar.length)
		{
			WM.T.move(x, y + i).print(ar[i]);
		}
	}//---------------------------------------------------;
	
	
}// - end class -