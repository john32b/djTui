/********************************************************************
 * Window Border, Helper Element
 *
 * - Gets added as a child in windows, so that it can use draw();
 * - Draws a border or a grid complex
 * - BETA: In case of grid, you need to set it up manually, and it starts always at the window (0,0)
 *
 *******************************************************************/
package djTui.el;

import djTui.BaseElement;

@:allow(djTui.Window)
class Border extends BaseElement
{
	// Style ID from the Styles.hx border index
	public var style:Int;

	// You can set this manually. If this is set, the grid will be drawn
	var grid:Array<Array<Int>> = null;

	/**
	   Create a border element
	   @param	sid
	   @param	st	Check `styles.hx` currently 0-6
	**/
	public function new(?sid:String,st:Int = 0)
	{
		super(sid);
		flag_focusable = false;
		style = st;
	}//---------------------------------------------------;

	// Draw the top portion only. Used sometimes when drawing the title part of the window
	// Does not draw the corners for convenience
	function drawTop()
	{
		_readyCol();
		WM.D.lineH(x + 1, y, width - 2, Styles.border[style].charAt(1));
	}//---------------------------------------------------;

	/**
	   Draw the whole border
	**/
	override public function draw():Void
	{
		_readyCol();
		if (grid == null)
			WM.D.border(x, y, width, height, style);
		else{
			WM.D.drawGrid(x, y, style, grid);
		}
	}//---------------------------------------------------;

}// --