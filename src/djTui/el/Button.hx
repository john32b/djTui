package djTui.el;

import djTui.BaseElement;

/**
 * Text Button
 * ----------
 * - Can be clicked
 * - Various styles for displaying
 * - Can have a minimum width
 */ 
class Button extends BaseElement 
{
	// The original Unmodified Text
	var text(default, set):String;
	
	// Minimum width allowed, text will be padded to reach this if smaller
	var minWidth:Int;
	
	// Encapsulated text with a [ ]
	var useStyle:Bool;
	
	//====================================================;
	
	public function new(txt:String, _useStyle:Bool = true, _minWidth:Int = 3)
	{
		super();
		height = 1;
		useStyle = _useStyle;
		minWidth = _minWidth;
		text = txt;	// setter
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
		_readyCol();
		WM.T.move(x, y).print(text);
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if (k == "enter" || k == "space")
		{
			callbacks("fire", this);
		}
	}//---------------------------------------------------;
	
	function set_text(val)
	{
		text = val;
		if (text.length < minWidth) {
			text = StrTool.padString(text, minWidth, "center");
		}
		//width = displayText.length + useStyle?2:0;
		if (useStyle)
		{
			text = '[' + text + ']';
		}
		width = text.length;
		return val;
	}//---------------------------------------------------;
	
	
}// --