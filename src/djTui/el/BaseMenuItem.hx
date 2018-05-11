package djTui.el;

import djTui.BaseElement;

/**
 * Generic Menu Item,
 * All Controls should extend this 
 * (inputs, buttons, options, etc)
 * ---
 */
class BaseMenuItem extends BaseElement 
{	
	// Actual string being drawn
	var rText:String;
	
	public function new(?sid:String) 
	{
		super(sid);
	}//---------------------------------------------------;
	
	override function onFocusChange():Void 
	{
		if (isFocused) {
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
	
	// @ virtual
	public function setData(val:Any) {}
	
	// @ virtual
	public function getData():Any { return null; }
	
	// @ virtual
	public function reset() {}
	
}//--