package djTui.el;

import djTui.BaseElement;
import haxe.Timer;

/**
 * ...
 * @author John Dimi
 */
class TextInput extends BaseMenuItem 
{
	
	static var CARET_SYMBOL:String = "█";
	public static var BANK_LETTERS:String = "QAZWSXEDCRFVTGBYHNUJMIKOLPqazwsxedcrfvtgbyhnujmikolp";
	public static var BANK_NUMBERS:String = "1234567890";
	public static var BANK_SYMBOLS:String = " `~!@#$%^&*()_+-=[]{}\\|;:\'\",.<>/?";
	
	// Text entered by the user
	public var text(default, set):String;
	
	// Maximum input length
	var maxLength:Int = 0;
	
	// Current valid keys user is permited to enter
	var validKeys:String = null;
	
	// Timer used in Caret blinking
	var timer:Timer;
	
	// Caret currently active
	var caret_t:Bool;
	
	/**
	   @param	sid
	   @param	_width Visual Width of the InputBox
	   @param	_maxl  Max characters input Length, ( Must be smaller than width )
	   @param	_allow [number,all] What type of data to allow, numbers or everything
	**/
	
	public function new(?sid:String, _width:Int = 8, _maxl:Int = 0, _allow:String = "all") 
	{
		super(sid);
		type = ElementType.input;
		width = _width;
		maxLength = _maxl - 1;
		if (_allow == "number") validKeys = BANK_NUMBERS;
		else validKeys = BANK_LETTERS + BANK_NUMBERS;
		text = "";
	}//---------------------------------------------------;
	
	override function focusSetup(focus:Bool):Void 
	{
		if (focus) {
			setColor(parent.skin.accent_blur_fg, parent.skin.accent_fg);
		}else {
			setColor(parent.skin.accent_blur_fg, parent.skin.accent_blur_bg);
		}
		if (focus) caret_start(); else caret_stop();
	}//---------------------------------------------------;
	
	//@:setter(visible)
	override function set_visible(value:Bool):Bool 
	{
		visible = value;
		if (!visible) caret_stop();
		return value;
	}//---------------------------------------------------;
	
	function caret_start()
	{
		caret_stop();
		timer = new Timer(200);
		timer.run = function()
		{
			caret_t = ! caret_t;
			_readyCol();
			WM.T.move(x + text.length, y);
			if (caret_t) {
				WM.T.print(CARET_SYMBOL);
			}else{
				WM.T.print(" ");
			}
		}
	}//---------------------------------------------------;
	
	function caret_stop()
	{
		if (timer != null) { timer.stop(); timer = null; }
		caret_t = false;
	}//---------------------------------------------------;
	
	override function onAdded():Void 
	{
		if (maxLength <= 0) maxLength = width - 1; // Leave room for carret
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
		caret_t = false;
		return val;
	}//---------------------------------------------------;
	
	override public function getData():Any 
	{
		return text;
	}//---------------------------------------------------;
	
	override public function setData(val:Any) 
	{
		text = val;
	}//---------------------------------------------------;
	
}// --
