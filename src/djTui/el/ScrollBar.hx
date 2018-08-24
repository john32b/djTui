package djTui.el;
import djTui.BaseElement;
import djTui.Styles.PrintColor;

/**
 * Basic scrollbar
 * KISS, no self-color management
 */
class ScrollBar extends BaseElement
{
	private static var SYMBOL_BAR:String = "│";
	private static var SYMBOL_IND:String = "█";
	
	/** Call this to set and update/draw the ratio (0-1) */
	public var scroll_ratio(default, set):Float = 0;
	
	public function new(_height:Int = 8) 
	{
		super();
		height = _height;
		flag_focusable = false;
	}//---------------------------------------------------;
	
	override function onAdded():Void 
	{
		super.onAdded();
		if (colorFG == null) setColor(parent.style.scrollbar_idle);
	}//---------------------------------------------------;
	
	// -
	function set_scroll_ratio(val)
	{
		if (scroll_ratio == val) return val;
		scroll_ratio = val;
		if (scroll_ratio < 0) scroll_ratio = 0; else
		if (scroll_ratio > 1) scroll_ratio = 1;
		if (visible && !lockDraw) draw();
		return scroll_ratio;
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		_readyCol();
		
		for (i in 0...height)
		{
			WM.T.move(x, y + i).print(SYMBOL_BAR);
		}
		var pos = Math.ceil(height * scroll_ratio) - 1;
		if (pos < 0) pos = 0;
		WM.T.move(x, y + pos).print(SYMBOL_IND);
	}//---------------------------------------------------;
}// --