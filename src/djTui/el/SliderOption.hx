package djTui.el;

import djTui.BaseElement;

/**
 * Inline selector of Strings
 * --
 * - Use LEFT/RIGHT to change selection
 * - Callbacks `change` message when changing elements
 * - 
 */
class SliderOption extends BaseMenuItem
{
	var options:Array<String>;	// The source options 
	var index_max:Int;			// Shorthand for `options.length - 1`
	var index:Int;				// Hold the currently selected index
	var ar_stat:Array<Bool>; 	// Arrow enabled status
	
	/**
	   Index for the arrow styles found in `Styles.arrowsLR' (0-2)
	**/
	public var arrowStyle(default, set):Int = 1;
	function set_arrowStyle(v){ arrowStyle = v; if (visible) updateText(); return v; }	
	
	/**
	   @param	sid  --
	   @param	src  Array with choices
	   @param	start Initial Index
	**/
	public function new(sid:String, src:Array<String>, start:Int = 0)
	{
		super(sid);	
		ar_stat = [false, false];
		type = ElementType.option;
		options = src.copy(); // safer this way
		index_max = options.length - 1;
		height = 1;
		setSideSymbolPad(1, 1);
		setData(start);
	}//---------------------------------------------------;
	
	override function focusSetup(focus:Bool):Void 
	{
		super.focusSetup(focus);
		// DEVNOTE: 
		// Need to updateText, because that function will place any side symbols.
		// Skip drawing since it will be drawn right after this function call
		lockDraw = true;
		updateText();
		lockDraw = false;
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		if (disabled) return;
		
		switch(k)
		{
			case "left": 	if (index != 0) sd(index - 1);
			case "right":	if (index != index_max) sd(index + 1);
			case "home":	if (index != 0) sd(0);
			case "end":		if (index != index_max) sd(index_max);
			default:
		}
	}//---------------------------------------------------;
	
	
	// -- Set Data and callback 'change' in one call
	function sd(d:Int)
	{
		setData(d);
		callback("change");
	}//---------------------------------------------------;
	
	
	// --
	// Focused Text is nudged a bit to the right for the arrows to fit
	function updateText()
	{
		if (isFocused)
		{
			setSideSymbols(	ar_stat[0]?Styles.arrowsLR[arrowStyle].charAt(0):null, 
							ar_stat[1]?Styles.arrowsLR[arrowStyle].charAt(1):null);
			text = options[index];
		}else
		{
			setSideSymbols();
			text = options[index];
		}
	}//---------------------------------------------------;
		
	// --
	// Sets current selected INDEX
	// ! Does not safeguard
	override public function setData(val:Any) 
	{
		index = val;
		ar_stat[0] = index != 0;
		ar_stat[1] = index != index_max;
		updateText();
	}//---------------------------------------------------;
	
	// --
	// Read current selected INDEX
	override public function getData():Any 
	{
		return index;
	}//---------------------------------------------------;
	
}// --