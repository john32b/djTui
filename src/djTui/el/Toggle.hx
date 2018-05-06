package djTui.el;

import djTui.BaseElement;

/**
 * ...
 * @author John Dimi
 */
class Toggle extends BaseElement 
{

	var checked:Bool = false;
	
	// Actual text rendered
	var text:String;

	public function new()
	{
		super();
		setToggle(false);
	}//---------------------------------------------------;
	
	override function onFocusChange():Void
	{
		if (isFocused) {
			setColors(parent.skin.accent_fg, parent.skin.accent_bg);
		}else {
			setColors(parent.skin.accent_blur_fg, null);
		}
	}//---------------------------------------------------;
	
	public function setToggle(b:Bool)
	{
		checked = b;
		if (checked) text = '[ X ]';
		else text = '[   ]';
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if (k == "enter" || k == "space")
		{
			setToggle(!checked);
			draw();
		}
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		_readyCol();
		WM.T.move(x, y).print(text);
	}//---------------------------------------------------;
	
}