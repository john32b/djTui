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
	   Fill a rectangle with current terminal colors
	   @param	x Screen X to start drawing
	   @param	y Screen Y to start drawing
	   @param	width Total Width
	   @param	height Total Height
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
	   @param	x Screen X to start drawing
	   @param	y Screen Y to start drawing
	   @param	width Total Width
	   @param	height Total Height
	   @param	style A border style index (1...n), see `Styles.hx` for available styles
	   @return
	**/
	public function border(x:Int, y:Int, width:Int, height:Int, style:Int = 1)
	{
		var bs:String = Styles.border[style]; // shorthand
		// Top
		lineH(x + 1, y, width - 2, bs.charAt(1));
		// Sides
		lineV(x, y + 1, height - 2, bs.charAt(6));
		lineV(x + width - 1, y + 1, height - 2, bs.charAt(7));
		// Bottom:
		lineH(x + 1, y + height - 1, width - 2, bs.charAt(4));// , bs[3], bs[5]
		// Four corners :
		WM.T.move(x, y).print(bs.charAt(0)).moveR(width - 2, 0).print(bs.charAt(2));
		WM.T.move(x, y + height - 1).print(bs.charAt(3)).moveR(width - 2, 0).print(bs.charAt(5));
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
	
	
	/**
	   Draw a Horizontal Line
	   @param	x Start X pos
	   @param	y Start Y Pos
	   @param	len Line Length
	   @param	sbody Body of line
	**/
	public function lineH(x:Int, y:Int, width:Int, s:String = "-")
	{
		WM.T.move(x, y).print(StringTools.lpad("", s, width));
	}//---------------------------------------------------;
	
	
	/**
	   Draw a Vertical Line
	   @param	x Start X pos
	   @param	y Start Y Pos
	   @param	height Line Length
	   @param	s Body of line
	   @return
	**/
	public function lineV(x:Int, y:Int, height:Int, s:String = "|")
	{
		WM.T.move(x, y);
		var c:Int = 0; while (c < height) {
			WM.T.move(x, y + c++).print(s);
		}
	}//---------------------------------------------------;
	
	
	/**
	   Draws a grid complex
	   NOTES :
		~ Full box width and height is autocalculated from the boxes
		~ Actual Cell width/height will be less than declared, in order to accomodate 
		  for the full box width/height
	   @param	x Outer Border Screen Location X
	   @param	y Outer Border Screen Location Y
	   @param	rows [ "width|width|...|height" , "width|width|...|height" ... ]
				Every string is a row,
				e.g. [ "20|20|3" , "15|25|2" ] (20,20 = width of the 2 cells, height = 3)
	   @param	Sin Style index from global border style in 'Styles.hx' for outer border
	   @param	Sout Style index from global border style in 'Styles.hx' for outer border

	**/
	public function drawGrid(x:Int, y:Int, rows:Array<String>, Sin:Int, Sout:Int)
	{
		// Total Width and Height
		var W:Int = 0;
		var H:Int = 0;
		var boxes:Array<Array<Int>> = [];
		var boxH:Array<Int> = [];

		// First pass, read arguments
		for (r in 0...rows.length){
			boxes[r] = rows[r].split('|').map(function(s){return Std.parseInt(s);});
			boxH[r] = boxes[r].pop();
		}
		for (w in boxes[0]) W += w;
		for (h in boxH) H += h;
		
		// --
		border(x, y, W, H, Sout);
		
		var currentRowTop:Int = y;
	
		// -
		for (r in 0...boxH.length)
		{
			var rowH:Int = boxH[r] - 1;
			if (r == 0) rowH --;
			
			// Draw the vertical bottom line only if not the last row
			if (r != boxH.length - 1)
			{
				lineH(x + 1, currentRowTop + rowH + 1, W - 2,
					 Styles.border[Sin].charAt(1));
					 
				// Draw Intersections with the outer border
				WM.T.move(x, currentRowTop + rowH + 1)
					.print( Styles.connectBorder(Sin, Sout, 2));
				WM.T.moveR(W - 2, 0).print(Styles.connectBorder(Sin, Sout, 3));
				
			}
			
			// Current box right edge X position ( for each box in the loop )
			var cBoxEdge:Int = x;
			
			// Draw Vertical lines for each box
			for (b in 0...boxes[r].length)
			{
				var boxwidth:Int = boxes[r][b] - 1;
				if (b == 0) boxwidth--;
				
				cBoxEdge += boxwidth + 1;
				
				boxes[r][b] = cBoxEdge; // Store it for future use
										// I am storing it in the same array, I don't need it anymore
										
				if (b == boxes[r].length - 1) continue; // No need to draw right edge of last box
				
				// Draw Vertical Line
				lineV(cBoxEdge, currentRowTop + 1, rowH, Styles.border[Sin].charAt(7));
				
				var S0:String = null;
				var S1:String = null;
				
				if (r == 0)
				{
					S0 = Styles.connectBorder(Sin, Sout, 0);
				}else
				{
					// Check if any top row box shares Vertical Line
					// , if it does, draw an intersection Symbol
					for (i in boxes[r - 1])
					{
						// note: (i) is now screen locations of vertical Lines
						if (i == cBoxEdge)
						{
							S0 = Styles.connectBorder(Sin, Sin, 4);
						}
					}
					
					if (S0 == null)
					{
						S0 = Styles.connectBorder(Sin, Sin, 0);
					}
				}
				
				if (r == boxH.length - 1)
				{
					S1 = Styles.connectBorder(Sin, Sout, 1);
				}else
				{
					S1 = Styles.connectBorder(Sin, Sin, 1);
				}
				
				// Draw Top/Down Symbols :
				WM.T.move(cBoxEdge, currentRowTop).print(S0);
				WM.T.move(cBoxEdge, currentRowTop + rowH + 1).print(S1);
				
			}//- boxes end
			
			currentRowTop += rowH + 1;
			
		}//- row end
	
	}//---------------------------------------------------;

	
}// - end class -