package djTui.el;
import djTui.BaseElement;


/**
 * Text Label
 * ----------
 * - A label is by default not focusable
 * - Set WIDTH==0 to enable autosize
 * - Alignment is then WIDTH>0
 * - You can change the text after creating the object
 */ 

class Label extends BaseElement
{
	// The original Unmodified Text
	public var text(default, set):String;
	
	// Actual string being displayed
	var displayText:String;
	
	// When padding etc, use this alignment
	var align:String;
	
	// -
	var autoSize:Bool;
	
	/**
	   Creates a Label Element
		@param	_txt	The Text of the Label
		@param	_width 	You can force a width, it will be padded with " " to reach it
						If string is longer it will be cut
	**/
	public function new(_txt:String, _width:Int = 0, _align:String = "left")
	{
		super();
		flag_can_focus = false;
		height = 1;
		width = _width;
		autoSize = (width == 0);
		align = _align;
		text = _txt;
		
	}//---------------------------------------------------;
	
	
	override function onAdded():Void 
	{
		setColors(parent.skin.win_fg);
	}//---------------------------------------------------;
	
	
	override public function draw():Void 
	{
		_readyCol();
		WM.T.move(x,y).print(displayText);
	}//---------------------------------------------------;
	
	
	// - Special occation, when a label needs to be highlighted
	// - This isn't the same as focus(), focus is still disabled()
	public function highlight(on:Bool = true)
	{
		if (on) setColors(parent.skin.accent_bg); 
		else setColors(parent.skin.win_fg);
		draw();
	}//---------------------------------------------------;
	
	function set_text(val)
	{
		text = val;
		displayText = val;
		if (!autoSize) 
			displayText = StrTool.padString(text, width, align);
		else 
			width = displayText.length;
		return val;
	}//---------------------------------------------------;
	
}//-- end Label --//