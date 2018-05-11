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
	// The final text being rendered is in 3 parts
	// <arrow> + <text> + <arrow>
	var rTxt:Array<String> = [];
	
	var data:Float;	// Actual value
	var min:Float;
	var max:Float;
	var inc:Float;	// Increment steps
	var maxW:Int; 	// Max Width the number string can get to
	
	// Hold the current number
	public function new(sid:String, _min:Float, _max:Float, _inc:Float = 1) 
	{
		super(sid);	
		type = "numbersel";
		min = _min;
		max = _max;
		inc = _inc;
		maxW = Std.string(max).length;
		size(maxW + 4, 1);
		setData(min);
	}//---------------------------------------------------;

	override function onKey(k:String):Void 
	{
		if (k == "left")
		{
			if (data == min) return;
			setData(data - inc);
			callbacks("change", this);
			draw();
		}else		
		if (k == "right")
		{
			if (data == max) return;
			setData(data + inc);
			callbacks("change", this);
			draw();
		}
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		_readyCol();
		WM.T.move(x, y);
		WM.T.print(rTxt[0] + rTxt[1] + rTxt[2]);
	}//---------------------------------------------------;
	
	override function setData(val:Any)
	{
		data = val;
		if (data < min) data = min; else 
		if (data > max) data = max;
		
		if (data == min) rTxt[0] = '  '; else rTxt[0] = '< ';
						 rTxt[1] = StrTool.padString('$val', maxW, "left");
		if (data == max) rTxt[2] = '  '; else rTxt[2] = ' >';
		
	}//---------------------------------------------------;
	
	override public function getData():Any 
	{
		return data;
	}//---------------------------------------------------;
	
}// --