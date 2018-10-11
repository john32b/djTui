package djTui.el;

import djTui.BaseElement;

/**
 * Simple checkbox, switches between two states
 * ----
 */
class Toggle extends BaseMenuItem 
{
	//  Hold current state
	var data:Bool;
	
	/** This is the symbol that will be printed when the element is checked */
	public var TOGGLE_SYMBOL:String = "■";
	
	/**
	   Creates a Toggle Element
	   @param	sid --
	   @param	current Staring Toggle
	**/
	public function new(?sid:String, current:Bool = false)
	{
		super(sid);
		type = ElementType.toggle;
		height = 1;
		setSideSymbolPad(1, 0);
		setSideSymbols("[", "]");
		setData(current);
	}//---------------------------------------------------;
	
	override public function setData(val:Any) 
	{
		data = val;
		
		if (data)
		{
			text = TOGGLE_SYMBOL;
		}
		else
		{
			text = " ";
		}
	}//---------------------------------------------------;

	override public function getData():Any 
	{
		return data;
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if ((k == "enter" || k == "space") && !disabled)
		{
			setData(!data);
			callback("change");
		}
	}//---------------------------------------------------;
	
}// --