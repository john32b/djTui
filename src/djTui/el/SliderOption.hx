package djTui.el;

import djTui.BaseElement;

/**
 * Choose one between Multiple Strings
 * ---
 * - 
 */
class SliderOption extends BaseMenuItem
{
	var options:Array<String>;	// The source options 
	var index_max:Int;			// Shorthand for `options.length - 1`
	var index:Int;				// Hold the currently selected index
	var maxW:Int;				// Max Width the number string can get to
	
	var ar_stat:Array<Bool>; 	// Arrow enabled status
	
	static inline var ARROW_PAD:Int = 2;
	
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
		// -- calculate the max width of options
			maxW = options[0].length;
			for (i in 0...options.length){
				if (options[i].length > maxW) maxW = options[i].length;
			}
		index_max = options.length - 1;
		size(maxW + ARROW_PAD * 2, 1);
		setData(start);
	}//---------------------------------------------------;
	
	override function focusSetup(focus:Bool):Void 
	{
		super.focusSetup(focus);
		renderText();
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		switch(k)
		{
			case "left": 	if (index != 0) sd(index - 1);
			case "pageup":	if (index != 0) sd(0);
			case "right":	if (index != index_max) sd(index + 1);
			case "pagedown":if (index != index_max) sd(index_max);
			default:
		}
	}//---------------------------------------------------;
	
	
	// -- Set Data and callback 'change' in one call
	function sd(d:Int)
	{
		setData(d);
		callbacks("change", this);
	}//---------------------------------------------------;
	
	
	// --
	// Focused Text is nudged a bit to the right for the arrows to fit
	function renderText()
	{
		if (isFocused)
		{
			rText = StringTools.lpad("", " ", ARROW_PAD) +
					StrTool.padString(options[index], width - ARROW_PAD, 'left');
		}else
		{
			rText = ' ' + 
					StrTool.padString(options[index], width - 1, 'left');
		}
	}//---------------------------------------------------;
	
	// --
	override public function draw():Void 
	{
		super.draw();
		
		if (isFocused)
		{
			// Assume same colors as normal text
			if(ar_stat[0]) WM.T.move(x, y).print("<");
			if(ar_stat[1]) WM.T.move(x + ARROW_PAD + options[index].length + 1, y).print(">");
		}
	}//---------------------------------------------------;
	
	
	// --
	// Sets current selected INDEX
	// ! Does not safeguard
	override public function setData(val:Any) 
	{
		index = val;
		// Assuming index is always correct
		ar_stat[0] = index != 0;
		ar_stat[1] = index != index_max;
		renderText();
		if (visible) draw();
	}//---------------------------------------------------;
	
	// --
	// Read current selected INDEX
	override public function getData():Any 
	{
		return index;
	}//---------------------------------------------------;
	
}// --