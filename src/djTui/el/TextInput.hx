package djTui.el;

import djTui.BaseElement;

/**
 * ...
 * @author John Dimi
 */
class TextInput extends BaseMenuItem 
{
	
	static var CARET_SYMBOL:String = "_";
	public static var BANK_LETTERS:String = "QAZWSXEDCRFVTGBYHNUJMIKOLPqazwsxedcrfvtgbyhnujmikolp";
	public static var BANK_NUMBERS:String = "1234567890";
	public static var BANK_SYMBOLS:String = " `~!@#$%^&*()_+-=[]{}\\|;:\'\",.<>/?";
	
	// Text entered by the user
	public var text(default, set):String;
	
	// Maximum input length
	private var maxLength:Int = 0;
	
	// Current valid keys user is permited to enter
	private var validKeys:String = null;
	
	/**
	   @param	sid
	   @param	width Visual Width
	   @param	maxL  Max input Length, must be smaller than width
	   @param	type [number,all]
	**/
	
	public function new(?sid:String, _width:Int = 0, _maxl:Int = 0, type:String = "all") 
	{
		super(sid);
		type = "input";
		width = _width;
		maxLength = _maxl;
		if (type == "number") validKeys = BANK_NUMBERS;
		else validKeys = BANK_LETTERS + BANK_NUMBERS;
		text = "";
	}//---------------------------------------------------;
	
	override function onAdded():Void 
	{
		if (maxLength == 0) maxLength = width;
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		if (k == "backsp")
		{
			if (text.length > 0) text = text.substr(0, -1);
			draw();
		}else
		if (k == "enter")
		{
			callbacks("fire", this);
		}else
		if ( k == "space")
		{
			text += " ";
			draw();
		}else
		if (k.length == 1 && validKeys.indexOf(k) >= 0)
		{
			text += k;
			draw();
		}
		
	}//---------------------------------------------------;

	function set_text(val)
	{
		text = val;
		if (text.length > maxLength) text = text.substr(0, maxLength);
		rText = text;
		rText = StrTool.padString(text, width, "left");
		return val;
	}//---------------------------------------------------;
	
	override public function getData():Any 
	{
		return text;
	}
}// --
