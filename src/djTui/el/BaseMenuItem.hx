package djTui.el;

import djTui.BaseElement;

/**
 * Generic Menu Item
 * - mostly for coloring
 */
class BaseMenuItem extends BaseElement 
{	
	// Actual string being drawn
	var rText:String;
	
	// Whether this control can be interacted with
	// public var disabled:Bool = false; TODO
	
	// Optional DESCRIPTION text associated with current control
	public var desc:String;
	
	// --
	public function new(?sid:String) 
	{
		super(sid);
	}//---------------------------------------------------;
	
	override function focusSetup(focus:Bool):Void 
	{
		if (focus) {
			setColors(parent.skin.accent_fg, parent.skin.accent_bg);
		}else {
			setColors(parent.skin.accent_blur_fg, null);
		}
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		WM.T.reset().fg(colorFG).bg(colorBG);
		WM.T.move(x, y).print(rText);
	}//---------------------------------------------------;
	
}//--