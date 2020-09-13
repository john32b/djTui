package djTui.el;
import djA.StrT;
import djTui.BaseElement;
import haxe.Timer;


/**
 * Text Label
 * ----------
 * - A label is by default not focusable
 * - Set WIDTH==0 to enable autosize
 * - You can change the text after creating the object
 * - use setColor() to set colors
 */ 

class Label extends BaseMenuItem
{
	// Timer used for animations
	var timer:Timer;
	
	// -- HELPERS --
	var anim_blink:Bool; // current blink status, true for on
	var anim_scroll:Int;
	var anim_active_call:Void->Void;
	
	/**
	   Creates a Label Element
		@param	Text			The Text of the Label
		@param	TextWidth	 	You can force a width, it will be padded with " " to reach it
								If string is longer it will be cut
		@param  Align   		Alignment within the label itself. Enabled onlt 
								when target width is set
	**/
	public function new(Text:String = "", TextWidth:Int = 0, Align:String = "l")
	{
		super();
		type = ElementType.label;
		flag_focusable = false;
		textWidth = TextWidth;
		textAlign = Align;
		height = 1;
		text = Text; // -> setter
		anim_blink = false;
		anim_scroll = 0;
	}//---------------------------------------------------;
	
	/** Chainable */
	public function setSID(s:String):Label
	{
		SID = s; return this;
	}//---------------------------------------------------;
	
	// NOTE: I need this because I want to get the parent window BG color,
	// 		 and it's not available at new()
	override function onAdded():Void 
	{
		super.onAdded();
		// If not already userset, set a default
		if (colorFG == null) setColor(parent.colorFG); else
		if (colorBG == null) colorBG = parent.colorBG;
	}//---------------------------------------------------;
		
	/**
	   Scroll the label TEXT within the render/width Area
	   - Will loop/wrap on itself
	   @param	freq Update Frequenct in milliseconds
	*/
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
	
	/** Start blinking the label
	 */
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
				rText = StrT.padString(text, width);
			}else{
				rText = StrT.padString("", width);
			}
			draw();
		}
		timer.run();
		
		return this;
	}//---------------------------------------------------;

	/** Stop blinking and set text to empty
	 */
	public function blinkOff()
	{
		stop();
		rText = StrT.padString("", width);
		anim_blink = false;
		draw();
	}//---------------------------------------------------;
	
	/** Stop all animations
	 */
	public function stop()
	{
		anim_active_call = null;
		if (timer != null) 
		{
			timer.stop(); timer = null;
		}
	}//---------------------------------------------------;
		
	/** Stop Any animation and reset text to empty
	 */
	override public function reset() 
	{
		text = "";
		stop();
	}//---------------------------------------------------;
	
	// --
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
	
	override function set_text(val) 
	{
		super.set_text(val);
		if (val == null) return null;
		if (visible)
		{
			if (anim_active_call != null) anim_active_call();
		}
		return text;
	}//---------------------------------------------------;
	
	// --
	override public function setData(val:Any) 
	{
		text = val;
	}//---------------------------------------------------;
	
	override public function getData():Any 
	{
		return text;
	}//---------------------------------------------------;


	
}//-- end class


