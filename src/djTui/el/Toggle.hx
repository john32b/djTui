package djTui.el;

import djTui.BaseElement;

/**
 * Simple checkbox, switches between two states
 * -----
 * 
 */
class Toggle extends BaseMenuItem 
{
	//  Hold current state
	var data:Bool;
	
	public function new()
	{
		super();
		size(5, 1);
		type = "toggle";
		setData(false);
	}//---------------------------------------------------;
	
	override public function setData(val:Any) 
	{
		data = val;
		if (data) rText = '[ X ]';
		else rText = '[   ]';	
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if (k == "enter" || k == "space")
		{
			setData(!data);
			callbacks("change", this);
			draw();
		}
	}//---------------------------------------------------;
	
}// --