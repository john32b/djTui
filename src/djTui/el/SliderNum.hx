package djTui.el;


import djTui.BaseElement;

/**
 * Number Picker/Selector
 * ---
 * - Select a number between a Min-Max
 * - Custom Increments
 * - Fires status updates on change and limit reach
 */

class SliderNum extends BaseMenuItem 
{

	var data:Float;	// Actual value
	var min:Float;	// Min Value
	var max:Float;	// Max Value
	var inc:Float;	// Increment steps
	var ar_stat:Array<Bool>; // Arrow enabled status
	
	/**
	   Index for the arrow styles found in `Styles.arrowsLR' (0-2)
	**/
	public var arrowStyle(default, set):Int = 1;
	function set_arrowStyle(v){ arrowStyle = v; if (visible) updateText(); return v; }
	
	/**
	   @param	sid
	   @param	_min Minimum Value
	   @param	_max Maximum Value
	   @param	_inc Increment
	   @param	_st  Starting Value
	**/
	public function new(?sid:String, _min:Float = 0, _max:Float = 10, _inc:Float = 1, _st:Float = 0) 
	{
		super(sid);	
		ar_stat = [false, false];
		type = ElementType.number;
		min = _min;
		max = _max;
		inc = _inc;
		height = 1;
		setSideSymbolPad(1, 1);
		if (_st == 0) _st = min;
		setData(_st);
	}//---------------------------------------------------;
	
	//
	// Build the final render string
	// Updates the text and also Draws it
	function updateText()
	{
		if (isFocused)
		{
			setSideSymbols(	ar_stat[0]?Styles.arrowsLR[arrowStyle].charAt(0):null, 
							ar_stat[1]?Styles.arrowsLR[arrowStyle].charAt(1):null);
			text = Std.string(data);
		}else
		{
			setSideSymbols();
			text = Std.string(data);
		}
	}//---------------------------------------------------;
	
	// --
	override function focusSetup(focus:Bool):Void 
	{
		super.focusSetup(focus);
		
		// DEVNOTE: Skip drawing since it will be drawn right after this function call
		lockDraw = true;
		updateText();
		lockDraw = false;
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		switch(k)
		{
			case "left": 	if (data != min) sd(data - inc);
			case "right":	if (data != max) sd(data + inc);
			case "home":	if (data != min) sd(min);
			case "end":		if (data != max) sd(max);
			default:
		}
	}//---------------------------------------------------;
	
	// -- Set Data and callback 'change' in one call
	function sd(d:Float)
	{
		setData(d);
		callbacks("change", this);
	}//---------------------------------------------------;
	
	// --
	override public function setData(val:Any) 
	{
		data = val;
		if (data < min) data = min; else 
		if (data > max) data = max;
		ar_stat[0] = data != min;
		ar_stat[1] = data != max;
		updateText();
	}//---------------------------------------------------;
	
	// --
	override public function getData():Any 
	{
		return data;
	}//---------------------------------------------------;
	
}// --