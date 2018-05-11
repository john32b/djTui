package djTui.el;

import djTui.BaseElement;

/**
 * Choose one between Multiple Strings
 * ---
 * - 
 */
class SliderOption extends BaseMenuItem
{
	// Hold the currently selected index
	var data:Int;
	
	// Shorthand for `options.length - 1`
	var max:Int;
	
	// The source options 
	var options:Array<String>;

	// The final text being rendered is in 3 parts
	// <arrow> + <text> + <arrow>
	var rTxt:Array<String> = [];
	
	var maxW:Int; 	// Max Width the number string can get to
	
	/**
	   
	   @param	sid  --
	   @param	src  Array with choices
	   @param	init Initial Index
	**/
	public function new(sid:String, src:Array<String>, init:Int = 0)
	{
		super(sid);	
		type = "oneof";
		options = src.copy(); // safer this way
		// -- calculate the max width of options
			maxW = options[0].length;
			for (i in 0...options.length){
				if (options[i].length > maxW) maxW = options[i].length;
			}
		max = options.length - 1;
		setData(init);
		size(rTxt[1].length + 4, 1);
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		_readyCol();
		WM.T.move(x, y);
		WM.T.print(rTxt[0] + rTxt[1] + rTxt[2]);
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if (k == "left")
		{
			if (data == 0) return;
			setData(data - 1);
			callbacks("change", this);
			draw();
		}else		
		if (k == "right")
		{
			if (data == max) return;
			setData(data + 1);
			callbacks("change", this);
			draw();
		}
	}//---------------------------------------------------;
	
	override public function setData(val:Any) 
	{
		data = val;
		if (data == 0) 	 rTxt[0] = '  '; else rTxt[0] = '< ';
						 rTxt[1] = StrTool.padString(options[data], maxW, "left");
		if (data == max) rTxt[2] = '  '; else rTxt[2] = ' >';
	}//---------------------------------------------------;
	
	override public function getData():Any 
	{
		return data;
	}//---------------------------------------------------;
	
	
}// --