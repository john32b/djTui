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
	var min:Float;
	var max:Float;
	var inc:Float;	// Increment steps
	var maxW:Int; 	// Max Width the number string can get to
	
	// Arrow enabled status
	var ar_stat:Array<Bool>;
	
	static inline var ARROW_PAD:Int = 2;
	
	/**
	   @param	sid
	   @param	_min Minimum Value
	   @param	_max Maximum Value
	   @param	_inc Increment
	   @param	_st  Starting Index
	**/
	public function new(sid:String, _min:Float, _max:Float, _inc:Float = 1, _st:Float = 0) 
	{
		super(sid);	
		ar_stat = [false, false];
		type = ElementType.number;
		min = _min;
		max = _max;
		inc = _inc;
		maxW = Std.string(max).length;
		size(maxW + ARROW_PAD * 2, 1);
		if (_st == 0) _st = min;
		setData(_st);
	}//---------------------------------------------------;
	
	// --
	// Focused Text is nudged a bit to the right for the arrows to fit
	function renderText()
	{
		if (isFocused)
		{
			rText = StrTool.repeatStr(ARROW_PAD, ' ') + 
					StrTool.padString('$data', width - ARROW_PAD, 'left');
		}else
		{
			rText = ' ' + 
					StrTool.padString('$data', width - 1, 'left');
		}
	}//---------------------------------------------------;
	
	// --
	override function focusSetup(focus:Bool):Void 
	{
		super.focusSetup(focus);
		renderText();
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		switch(k)
		{
			case "left": 	if (data != min) sd(data - inc);
			case "pageup":	if (data != min) sd(min);
			case "right":	if (data != max) sd(data + inc);
			case "pagedown":if (data != max) sd(max);
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
	override public function draw():Void 
	{
		super.draw();
		
		if (isFocused)
		{
			// Assume same colors as normal text
			
			if(ar_stat[0]) WM.T.move(x, y).print("<");
			if(ar_stat[1]) WM.T.move(x + ARROW_PAD + '$data'.length + 1, y).print(">");
		}
	}//---------------------------------------------------;
	
	// --
	override public function setData(val:Any) 
	{
		data = val;
		if (data < min) data = min; else 
		if (data > max) data = max;
		ar_stat[0] = data != min;
		ar_stat[1] = data != max;
		renderText();
		if (visible) draw();
	}//---------------------------------------------------;
	
	// --
	override public function getData():Any 
	{
		return data;
	}//---------------------------------------------------;
	
}// --