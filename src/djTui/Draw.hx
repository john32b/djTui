/********************************************************************
 * Provide some Extra Drawing Functions
 * ----------------
 * - SINGLETON, exists in WM.D
 * - Uses `Styles.hx` for reading things
 *
 *******************************************************************/

package djTui;
import djA.StrT;
import djTui.WM;

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
		var bs = Styles.border[style]; // pointer
		// Top, Bottom
		lineH(x + 1, y, width - 2, bs.charAt(1));
		lineH(x + 1, y + height - 1, width - 2, bs.charAt(4));
		// Sides
		lineV(x, y + 1, height - 2, bs.charAt(6));
		lineV(x + width - 1, y + 1, height - 2, bs.charAt(7));
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
		for (i in 0...ar.length) {
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
	   Draws a grid complex. Uses ASCII characters to draw border and intersections.
	   - WARNING : User should check if all cell widths accumulate to the same width + border throughout.
	   @param	x Grid X pos
	   @param	y Grid Y pos
	   @param	borderStyle  Style index from global border style in 'Styles.hx' for the border style | Start at (1)
	   @param	rowsEnc Declare The Rows of the Grid Manually in this format "RowHeight|width(1)|width(2)|...|width(N)"
					- You can use STRING or ARRAY<INT> to define this.
					  e.g. ["3|10|10", "2|14|4|2"] <<==>> [[3,10,10], [2,14,4]]
	**/
	public function drawGrid(x:Int, y:Int, borderStyle:Int, rowsEnc:Array<Dynamic>)
	{
		/** = Example:
			  drawGrid(0, 0, 1, [ [2,1, 8, 5, 2, 1], [1, 10, 8, 1] ]);
			> Produces this:
			┌─┬────────┬─────┬──┬─┐
			│ │        │     │  │ │
			│ │        │     │  │ │
			├─┴────────┼─────┴──┼─┤
			│          │        │ │
			└──────────┴────────┴─┘
			> It is useful for creating button grids or similar UI things
		************************************************************************/

		var bs = Styles.border[borderStyle]; // Pointer to actual border symbols
		var cy = y;	// Keep track of current Y Pos for when printing
		var rowW:Array<Array<Int>> = [];	// Cell Widths of each row
		var rowH:Array<Int> = [];			// Row Height of each row

		// Takes in input rowsEnc, and parses it to proper vars (rowW,rowH)
		for (r in 0...rowsEnc.length){
			if (Std.is(rowsEnc[r], Array)) {
				var _t:Array<Int> = cast rowsEnc[r];
				rowW[r] = _t.copy();
			}else
				rowW[r] = cast(rowsEnc[r], String).split('|').map((s)->Std.parseInt(s));

			rowH[r] = rowW[r].shift();
		}

		// Draw the main body of a row (r is index)
		function drawR0(r:Int){
			WM.T.move(x, cy++).print(bs.charAt(7)); // Draw the first | at the start of the line
			for (i in 0...rowW[r].length) {
				WM.T.moveR(rowW[r][i], 0).print(bs.charAt(7)); // Draw a | at every width
			}
		}

		// Draw the bottom line of a row (r is index)
		function drawR1(r:Int){
			var morerows = (r < rowW.length - 1);
			WM.T.move(x, cy++).print( bs.charAt(morerows?10:3) ); // Draw └ or ├
			// :: Calculate the next row cell stops, so I can draw the intersections
				var ns:Array<Int> = [];  // The next rows border positions, first and last not included.
				var nc = 0;	// next row width accumulator
				if (morerows){
					for (i in rowW[r + 1]) { nc += (i+1); ns.push(nc); }
					ns.pop();	// REMOVE the last one, as it always is the right edge of the grid
				}
			// --
			var s = 0;	// Current cell stop
			for (i in 0...rowW[r].length) {
				var morecells = (i < rowW[r].length - 1);
				s += rowW[r][i] + 1;
				WM.T.print(StrT.rep(rowW[r][i], bs.charAt(1))); // Draw ─
				if (morecells){
					if (ns.indexOf(s) >= 0){ // The cell below has the same border as this cell
						WM.T.print(bs.charAt(12)); // Draw ┼
						ns.remove(s);	// Done with it, remove it so what remains in `ns` are borders that I need to draw later
					}
					else WM.T.print(bs.charAt(9)); // Draw ┴
				}
			}// - end for
			// Last symbol of the line
			WM.T.print(bs.charAt(morerows?11:5)); // Draw ┘ or ┤

			// -- Now I need to draw the remaining next row wall junctions
			for (i in ns) {
				WM.T.move(x + i, cy - 1).print(bs.charAt(8)); // Draws ┬
			}

		}// - end drawR1()

		// Draw the top line border of the first row:
			WM.T.move(x, cy++).print(bs.charAt(0));
			for (i in 0...rowW[0].length) {
				WM.T.print(StrT.rep(rowW[0][i], bs.charAt(1)));
				WM.T.print(bs.charAt(
					(i == rowW[0].length - 1) ? 2 : 8	// ┐ or ┬
				));
			}

		// Draw all the rows, one by one
		for (r in 0...rowW.length) {
			for (j in 0...rowH[r])
			drawR0(r);
			drawR1(r);
		}
	}//---------------------------------------------------;

}// - end class -