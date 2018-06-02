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
	inline static var SMB_0:String = "<";
	inline static var SMB_1:String = ">";
	
	// The original unmodified Text
	var text(default, set):String;
	
	// Minimum width allowed, text will be padded to reach this if smaller
	var minWidth:Int;
	
	// Encapsulated text with a [ ]
	var flag_btnStyle:Bool;
	
	//====================================================;
	
	public function new(sid:String, txt:String, _btnStyle:Bool = true, _minWidth:Int = 4)
	{
		super(sid);
		type = ElementType.button;
		height = 1;
		flag_btnStyle = _btnStyle;
		minWidth = _minWidth;
		text = txt;	// sets width also
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		if (k == "enter" || k == "space") callbacks("fire", this);
		else if (k == "left") callbacks("focus_prev", this);
		else if (k == "right") callbacks("focus_next", this);
	}//---------------------------------------------------;
	// --
	function set_text(val)
	{
		text = val;
		rText = text;
		if (text.length < minWidth) {
			rText = StrTool.padString(text, minWidth, "center");
		}
		if (flag_btnStyle)
		{
			rText = SMB_0 + text + SMB_1;
		}
		width = rText.length;
		if (visible) draw();
		return val;
	}//---------------------------------------------------;
	
}// --