package djTui.el;
import djA.StrT;
import djTui.BaseElement;
import haxe.Timer;
import js.lib.Intl;


private typedef LabelAnim = {
	timer:Timer,
	r0:Int,
	tick:Void->Void,
	loops:Int,
	freq:Int
};

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
	var an:LabelAnim;	// Animation parameters. Null for no animation
	
	/**
		Creates a Label Element
		@param	Text			The label text
		@param	TextWidth	 	You can force a width, it will be padded with ' ' to reach it
								If string is longer it will be cut
		@param  Align   		Alignment within the label itself
								Valid only when target width is set
	**/
	public function new(Text:String = "", TextWidth:Int = 0, Align:String = "l")
	{
		super();
		type = ElementType.label;
		focusable = false;
		textWidth = TextWidth;
		textAlign = Align;
		height = 1;
		text = Text; // -> setter
	}//---------------------------------------------------;
	
	/** Stop Any animation and reset text to empty
	 */
	override public function reset()
	{
		text = "";
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
	   Scroll the label text
	   - Will loop/wrap on itself
	   @param	freq Update Frequenct in milliseconds
	*/
	public function scroll(freq:Int = 250):Label
	{
		anim_stop();
		an = {
			timer:null,
			r0:0,
			loops: -1,
			freq:freq,
			tick: ()->{ // It assumes that runs only when visible
				an.r0++; if (an.r0 >= text.length) an.r0 = 0;
				var s = 0;
				var ar:Array<String> = [];
				while (s < width) {
					ar[s] = text.charAt((an.r0 + s) % text.length);
					s++;
				}
				rText = ar.join('');
				draw();
			}
		}
		if (visible) anim_start();
		return this;
	}//---------------------------------------------------;

	
	/**
	   Blinks the label on/off
	   @param	loops How many blinks (-1) for infinite. ODD number to end Visible
	   @param	freq Milliseconds per blink
	   @return 
	**/
	public function blink(loops:Int = -1, freq:Int = 250):Label
	{
		anim_stop(); // Just in case
		
		an = {
			timer:null,
			r0:0,
			loops:loops,
			freq:freq,
			tick: ()->{ // It assumes that runs only when visible
				if (an.r0 == 0) an.r0++; else an.r0 = 0;
				if (an.r0 == 0){
					rText = StrT.padString("", width);
				}else{
					rText = StrT.padString(text, width);
				}
				draw();
			}
		};
		
		if (visible) anim_start();
		
		return this;
	}//---------------------------------------------------;

	
	// - Resumes or Starts the animation
	function anim_start()
	{
		if (an == null) return;
		an.timer = new Timer(an.freq);
		an.timer.run = ()->{
			if (an.loops != 0) {
				an.tick();
				if (an.loops > 0) an.loops--;
			}else{
				anim_stop();
				an = null;
			}
		}
		an.timer.run();
	}//---------------------------------------------------;
	
	// -- Just stop the animation. It can be resumed with `anim_start`
	function anim_stop()
	{
		if (an != null && an.timer != null){
			an.timer.stop();
			an.timer = null;
		}
	}//---------------------------------------------------;
	
	// --
	override function set_visible(val):Bool
	{
		if (visible == val) return val;
		visible = val;
		if (visible) {
			anim_start();	// Will check for active animation, and start it
		}else {
			anim_stop();	// If any animation is on, will stop it
		}
		return val;
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


