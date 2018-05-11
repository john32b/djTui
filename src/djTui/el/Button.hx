package djTui.el;

import djTui.BaseElement;

/**
 * Text Button
 * ----------
 * - Can be clicked
 * - Various styles for displaying
 * - Can have a minimum width
 */ 
class Button extends BaseMenuItem 
{
	// The original Unmodified Text
	var text(default, set):String;
	
	// Minimum width allowed, text will be padded to reach this if smaller
	var minWidth:Int;
	
	// Encapsulated text with a [ ]
	var btnStyle:Bool;
	
	//====================================================;
	
	public function new(sid:String, txt:String, _btnStyle:Bool = true, _minWidth:Int = 3)
	{
		super(sid);
		type = "button";
		height = 1;
		btnStyle = _btnStyle;
		minWidth = _minWidth;
		text = txt;	// sets width also
	}//---------------------------------------------------;
	
	// --
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
		rText = text;
		if (text.length < minWidth) {
			rText = StrTool.padString(text, minWidth, "center");
		}
		if (btnStyle)
		{
			rText = '[' + text + ']';
		}
		width = rText.length;
		return val;
	}//---------------------------------------------------;
	
	
}// --