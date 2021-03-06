/********************************************************************
 *
 * Inline selector of Strings
 *
 * - Use LEFT/RIGHT to change selection
 * - Callbacks `change` when changing elements
 *
 *******************************************************************/
package djTui.el;

import djTui.BaseElement;

/**
 * Inline selector of Strings
 * --
 * - Use LEFT/RIGHT to change selection
 * - Callbacks `change` message when changing elements
 */
class SliderOption extends BaseMenuItem
{
	public var options(default, null):Array<String>;	// The source options
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
	override function onKey(k:String):String
	{
		if (disabled) return k;

		// DEV: Every key is consumed. No parent navigation here

		switch(k)
		{
			case "left": 	if (index != 0) sd(index - 1); k = "";
			case "right":	if (index != index_max) sd(index + 1); k = "";
			case "home":	if (index != 0) sd(0); k = "";
			case "end":		if (index != index_max) sd(index_max); k = "";
			case "enter":
				callback("fire");
				if (parent.flag_enter_goto_next) k = "down"; else k = "";
			default:
		}

		return k;
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

	// ! NO Safeguard !
	// you can use <INT> for index
	// or <STRING> of an existing elements text
	override public function setData(val:Any)
	{
		var ind = 0; 
		if (Std.is(val, String))
		{
			ind = options.indexOf(cast val);
			if (ind ==-1) return;	// Nothing found
		}else{
			ind = val;
		}
		
		index = ind;
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
	
	/** Get currently selected option as TEXT */
	public function getSelected():String
	{
		return options[index];
	}//---------------------------------------------------;

}// --