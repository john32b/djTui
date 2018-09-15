package djTui.el;

import djTui.BaseElement;

/**
 * Window Border
 * ...
 */
class Border extends BaseElement 
{
	public var style:Int;

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
		
	/**
	   Draw the top portion only
	**/
	public function drawTop()
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
		WM.D.border(x, y, width, height, style);
	}//---------------------------------------------------;
	
}