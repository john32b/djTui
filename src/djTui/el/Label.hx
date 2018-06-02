package djTui.el;
import djTui.BaseElement;
import haxe.Timer;


/**
 * Text Label
 * ----------
 * - A label is by default not focusable
 * - Set WIDTH==0 to enable autosize
 * - You can change the text after creating the object
 */ 

class Label extends BaseMenuItem
{
	// The original Unmodified Text
	public var text(default, set):String;
	
	// When padding etc, use this alignment
	var align:String;
	
	// Timer used for animations
	var timer:Timer;
	
	// -- HELPERS --
	var anim_blink:Bool; // current blink status, true for on
	var anim_scroll:Int;
	var anim_active_call:Void->Void;
	
	/**
	   Creates a Label Element
		@param	_txt	The Text of the Label
		@param	_width 	You can force a width, it will be padded with " " to reach it
						If string is longer it will be cut
		@param _align   Alignment within the label itself.
	**/
	public function new(_txt:String, _width:Int = 0, _align:String = "left")
	{
		super();
		type = ElementType.label;
		flag_focusable = false;
		align = _align;
		width = _width;
		if (width == 0) width = _txt.length;
		height = 1;
		text = _txt; // -> setter
		anim_blink = false;
		anim_scroll = 0;
	}//---------------------------------------------------;
	
	// NOTE: I need this because I want to get the parent window BG color,
	// 		 and it's not available at new()
	override function onAdded():Void 
	{
		setColors(parent.skin.win_fg);
	}//---------------------------------------------------;
		
	// -- Scroll the label TEXT withing the render Area
	// - Will loop through
	// - call stop() sto stop
	public function scroll(freq:Int = 200):Label
	{
		stop();
		anim_active_call = scroll.bind(freq);
		if (!visible) return this;
		timer = new Timer(freq);
		timer.run = function()
		{
			anim_scroll++; if (anim_scroll >= text.length) anim_scroll = 0;
			var s = 0;
			var ar:Array<String> = [];
			while (s < width) 
			{
				ar[s] = text.charAt((anim_scroll + s) % text.length);
				s++;
			}
			rText = ar.join('');
			draw();
		}
		timer.run();
		return this;
	}//---------------------------------------------------;
	
	// -- Start blinking the label
	// - call stop() to stop
	public function blink(freq:Int = 300):Label
	{
		stop();
		anim_active_call = blink.bind(freq);
		if (!visible) return this;
		
		timer = new Timer(freq);
		timer.run = function()
		{
			anim_blink = !anim_blink;
			if (anim_blink){
				rText = StrTool.padString(text, width);
			}else{
				rText = StrTool.padString("", width);
			}
			draw();
		}
		timer.run();
		
		return this;
	}//---------------------------------------------------;

	// --
	// Stop blinking and set text to empty
	public function blinkOff()
	{
		stop();
		rText = StrTool.padString("", width);
		anim_blink = false;
		draw();
	}//---------------------------------------------------;
	
	// Stop all animations
	public function stop()
	{
		anim_active_call = null;
		if (timer != null) 
		{
			timer.stop(); timer = null;
		}
	}//---------------------------------------------------;
		
	// Stop Any animation and reset text to empty
	override public function reset() 
	{
		text = "";
		stop();
	}//---------------------------------------------------;
	
	override function set_visible(val):Bool
	{
		if (visible == val) return val;
		visible = val;
		if (visible)
		{
			// Start animating
			if (anim_active_call != null) anim_active_call();
		}else
		{
			if (timer != null)  { timer.stop(); timer = null; }
		}
		return val;
	}//---------------------------------------------------;
	
	function set_text(val)
	{
		text = val;
		rText = StrTool.padString(text, width, align);
		// Restart the animation, if any
		if (anim_active_call != null) anim_active_call();
		if (visible) draw();
		return val;
	}//---------------------------------------------------;

	
}//-- end Label --//


