package djTui.el;

import djTui.BaseElement;
import djTui.el.BaseMenuItem;
import haxe.Timer;

/**
 * Text Input Field
 * ----
 * - Capture Key inputs
 * - Fire Event on `enter` key
 * - Must always have a width set
 */
class TextInput extends BaseMenuItem 
{
	inline static var DEFAULT_SIZE:Int = 12;
	inline static var DEFAULT_CARET:String = "▄";
	inline static var CARET_BLINK_RATE:Int = 200;
	
	public static var BANK_LETTERS:String = "QAZWSXEDCRFVTGBYHNUJMIKOLPqazwsxedcrfvtgbyhnujmikolp";
	public static var BANK_NUMBERS:String = "1234567890";
	public static var BANK_SYMBOLS:String = " `~!@#$%^&*()_+-=[]{}\\|;:\'\",.<>/?";
	
	// Maximum input length
	var maxChars:Int;
	// Current valid keys user is permited to enter
	var validKeys:String = null;
	// Timer used in Caret blinking
	var caret_tim:Timer;
	// Caret currently active
	var caret_on:Bool;
	
	/** Caret symbol to use for blinking, can be changed */
	public var caret_symbol:String;
	
	/**
	   @param	sid --
	   @param	_width Visual Width of the InputBox
	   @param	_maxChars  Max characters input Length 0 For default
	   @param	_allow [number,all] What type of data to allow, numbers or everything
	**/
	
	public function new(sid:String, _maxChars:Int = 0, _allow:String = "all") 
	{
		super(sid);

		type = ElementType.input;
		caret_symbol = DEFAULT_CARET;
		maxChars = _maxChars; if (maxChars < 1) maxChars = DEFAULT_SIZE;
		height = 1;
		
		if (_allow == "number") {
			validKeys = BANK_NUMBERS;
		} else {
			validKeys = BANK_LETTERS + BANK_NUMBERS;
		}
		
		setSideSymbolPad(0, 0);
		setSideSymbols(":", "");
		setTextWidth(maxChars + 1, "left"); //+1 is to accomodate for the blinking cursor
		
		text = "";
	}//---------------------------------------------------;
	
	
	override function onAdded():Void 
	{
		super.onAdded();
		if (maxChars <= 0) maxChars = width - 1; // Leave room for caret
	}//---------------------------------------------------;
	
	override function focusSetup(focus:Bool):Void 
	{
		super.focusSetup(focus);
		if (focus) caret_start(); else caret_stop();
	}//---------------------------------------------------;
	
	override function set_visible(value:Bool):Bool 
	{
		visible = value;
		if (!visible) caret_stop();
		return value;
	}//---------------------------------------------------;
	
	function caret_start()
	{
		caret_stop();
		caret_tim = new Timer(CARET_BLINK_RATE);
		caret_tim.run = function()
		{
			caret_on = ! caret_on;
			_readyCol();
			WM.T.move(x + text.length + s_padOut + s_padIn + s_smb_l.length, y);
			if (caret_on) {
				WM.T.print(caret_symbol);
			}else{
				WM.T.print(" ");
			}
		}
	}//---------------------------------------------------;
	
	/**
	   Stop blinking the caret
	**/
	function caret_stop()
	{
		if (caret_tim != null) { caret_tim.stop(); caret_tim = null; }
		caret_on = false;
	}//---------------------------------------------------;
	

	// --
	override function onKey(k:String):Void 
	{
		switch(k)
		{
			case "backsp":
				if (text.length > 0) text = text.substr(0, -1);
				draw();
			case "enter":
				callbacks("fire", this);
			case "space":
				text += " ";
				draw();
			default:
				if (k.length == 1 && validKeys.indexOf(k) >= 0)
				{
					text += k;
					draw();
				}
		}
	}//---------------------------------------------------;
	
	
	// 
	override function set_text(val)
	{
		if (val != null && cast(val, String).length == maxChars)
		{
			return text;
		}
		
		caret_on = false;
		super.set_text(val);
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
