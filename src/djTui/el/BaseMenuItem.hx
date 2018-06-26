package djTui.el;

import djTui.BaseElement;
import djTui.Styles.PrintColor;

/**
 * Generic Menu Item :
 * 
 * - Offers Focused/Idle Colors handling
 * - Use setColorFocus() and setColorIdle() to set colors
 * 
 */
class BaseMenuItem extends BaseElement 
{	
	// Actual string being drawn
	var rText:String;
	
	// Whether this control can be interacted with
	// public var disabled:Bool = false; TODO
	
	/** Optional DESCRIPTION text associated with current control **/
	public var desc:String;
	
	// Some elements come with a label, this is the user set name for the control
	public var name:String;
	
	// Menu Elements have pairs of colors. Automatically set on focus/blur
	// Set custom colors right after new()
	var color_idle:PrintColor;
	var color_focus:PrintColor;
	
	/** If true will colorize the background on the default colors .
	 *  SET IT before adding to a window */
	public var flag_solid_bg:Bool;
	
	// --
	public function new(?sid:String) 
	{
		super(sid);
	}//---------------------------------------------------;
	
	// --
	override function onAdded():Void 
	{
		if (color_idle == null)
		{
			color_idle = {fg:parent.skin.win_fg};
			if (flag_solid_bg) color_idle.bg = parent.skin.accent_blur_bg;
		}
		
		if (color_focus == null)
		{
			color_focus = {fg:parent.skin.win_bg, bg:parent.skin.accent_fg};
		}
	}//---------------------------------------------------;
	
	/**
	   Setup the colors for when the element gets focused/blurred
	**/
	override function focusSetup(focus:Bool):Void 
	{
		if (focus) 
		{
			setColor(color_focus.fg, color_focus.bg);
		}
		else 
		{
			setColor(color_idle.fg, color_idle.bg);
		}
	}//---------------------------------------------------;
	
	/** Set the color for when this element is idle */
	public function colorIdle(fg:String, ?bg:String):BaseMenuItem
	{
		color_idle = {fg:fg, bg:bg};
		return this;
	}//---------------------------------------------------;
	
	/** Set the color for when this element is focused */
	public function colorFocus(fg:String, ?bg:String):BaseMenuItem
	{
		color_focus = {fg:fg, bg:bg};
		return this;
	}//---------------------------------------------------;
		
	/**
	   Print the generic 'rText' with the currently active colors
	**/
	override public function draw():Void 
	{
		WM.T.reset().fg(colorFG).bg(colorBG);
		WM.T.move(x, y).print(rText);
	}//---------------------------------------------------;
	
	
	#if debug
	override public function toString():String
	{
		return 'Type:${type.getName()}, SID:$SID, x:$x, y:$y';
	}//---------------------------------------------------;
	#end
	
}//--