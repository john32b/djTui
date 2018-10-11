package djTui.el;

import djTui.BaseElement;
import djTui.Styles.PrintColor;

/**
 * Generic Menu Item for SINGLE LINE elements
 * -----
 * - General functions for *single line* menu elements
 * - This is meant to be extended into more specific items
 * - Offers Focused/Idle Colors handling
 * - Use setColorFocus() and setColorIdle() to set colors
 * - Automatic Symbol management at string ends, (for buttons, arrows, etc)
 * - Disabled elements, when restored to enabled, will ALWAYS restore to default colors
 */
class BaseMenuItem extends BaseElement 
{	
	// Actual string being drawn
	var rText:String;
	
	// The original Unmodified Text
	public var text(default, set):String;
	
	// Target width for visible text. It will be trimmed if exceeded
	// 0 for Autosize
	var textWidth:Int;
	
	// Self Alignment of the text. Only applies when textWidth>0
	var textAlign:String;
	
	// Whether this control can be interacted with
	public var disabled(default, set):Bool = false;
	
	/** Optional DESCRIPTION text associated with current control **/
	public var desc:String;
	
	// Some elements come with a label, this is the user set name for the control
	public var name:String;
	
	// Menu Elements have pairs of colors. Automatically set on focus/blur
	// Set custom colors right after new()
	var color_idle:PrintColor;
	var color_focus:PrintColor;
	
	// --
	public function new(?sid:String) 
	{
		super(sid);
		textAlign = "center";
		textWidth = 0;	// Autosize
	}//---------------------------------------------------;
	
	/**
	   Quick disable/enable with a chainable function
	   @param V True to Disable, False to Enable
	   @param alsoUnselectable If True and Disabled will make the element unselectable
	**/
	public function disable(V:Bool = true, alsoUnselectable:Bool = false):BaseMenuItem
	{
		disabled = V; 
		if (alsoUnselectable && V) flag_focusable = false;
		else if (!V) flag_focusable = true;
		return this;
	}//---------------------------------------------------;
	/**
	   Just added in a Window
	   Called by Window
	**/
	override function onAdded():Void 
	{
		// DEVNOTE: Check this, in case user has already set custom colors
		
		if (color_idle == null)
		{
			color_idle = parent.style.elem_idle;
		}
		
		if (color_focus == null)
		{
			color_focus = parent.style.elem_focus;
		}
		
		// NOTE: Hacky way to apply disabled colors on the element
		// 		 BUT ONLY if the element is disabled
		if (disabled == true) disabled = true;
	}//---------------------------------------------------;
	
	/**
	   Setup the colors for when the element gets focused/blurred
	**/
	override function focusSetup(focus:Bool):Void 
	{
		if (focus) 
		{
			setColor(color_focus);
		}
		else 
		{
			setColor(color_idle);
		}
	}//---------------------------------------------------;
	
	/** Set the color for when this element is idle */
	public function colorIdle(fg:String, ?bg:String):BaseMenuItem
	{
		color_idle = {fg:fg, bg:bg};
		colorChangeDraw();
		return this;
	}//---------------------------------------------------;
	
	/** Set the color for when this element is focused */
	public function colorFocus(fg:String, ?bg:String):BaseMenuItem
	{
		color_focus = {fg:fg, bg:bg};
		colorChangeDraw();
		return this;
	}//---------------------------------------------------;
	
	// Colors were changed. Check if it can be drawn and draw
	function colorChangeDraw()
	{
		if (parent != null) 
		{
			focusSetup(isFocused);
			if (visible && !lockDraw) draw();
		}		
	}//---------------------------------------------------;
	/**
	   Print the generic 'rText' with the currently active colors
	**/
	override public function draw():Void 
	{
		WM.T.reset().fg(colorFG).bg(colorBG);
		WM.T.move(x, y).print(rText);
	}//---------------------------------------------------;
	
		
	/**
	   Sets the actual display text
	   Will apply any autosize and alignment
	**/
	function set_text(v)
	{
		if (v == null)
		{
			v = "";
		}
		
		text = v;
		
		// If side symbols are set:
		if (s_smb_l != null)
		{
			v = s_smb_l + StrTool.empty(s_padIn) + 
				v +
				StrTool.empty(s_padIn) + s_smb_r;
			
			// DevNote: Why did I need this line, just apply outer pad to all fixed widths
			//if (textWidth == 0) 
		}
		
		// Apply outer pad to all occasions.
		if (s_padOut > 0)
		v = StrTool.empty(s_padOut) + v + StrTool.empty(s_padOut);
		
		/* Upon renaming, if the new text is shorter than the old text
		   clear the space behind it, so the text doesn't overlap */
		if (rText != null && textWidth == 0 && cast(v, String).length < rText.length && visible)
		{
			clear();	
		}
		
		if (textWidth == 0)
		{
			rText = v;
		}else
		{
			rText = StrTool.padString(v, textWidth, textAlign);
		}
		
		width = rText.length; // Either textWidth or whatever text length is
		
		if (visible && !lockDraw)
		{
			draw();
		}
		
		return text;
	}//---------------------------------------------------;
	
	/**
	   Re-Set the width and alignment
	   NOTE: Meant to be used in Labels mostly
	   @param _w Text Width Set 0 for autosize.
	   @param _a Align center,left,right
	**/
	public function setTextWidth(_w:Int, _a:String = "left"):BaseMenuItem
	{
		textWidth = _w;
		textAlign = _a;
		if (text != null) text = text; // Apply and force a redraw
		return this;
	}//---------------------------------------------------;

	
	/**
	   Apply and re-apply disabled status along with COLORS
	   @param	val
	**/
	public function set_disabled(val:Bool)
	{
		disabled = val;
		
		if (!disabled)
		{
			flag_focusable = true;
		}
		
		if (parent != null)
		{
			var s = parent.style;
			if (disabled)
			{
				color_focus = s.elem_disable_f;
				color_idle = s.elem_disable_i;
			}else
			{
				// Reset colors to defaults of the style
				// Will overwrite any custom user colors :-/
				color_idle = s.elem_idle;
				color_focus = s.elem_focus;
			}
			colorChangeDraw();
		}
		return val;
	}//---------------------------------------------------;
	
	
	
	
	//====================================================;
	// Side Symbols
	// Text will be enclosed if the symbols are set
	//====================================================;
	var s_smb_l:String;		// Left Symbol
	var s_smb_r:String;		// Right Symbol
	var s_padIn:Int = 0;	// Padding between symbol and text
	var s_padOut:Int = 0;	// Padding between symbol and outer
	
	/**
	   For elements that use SideDecorations, like buttons and Sliders.
	   Set the padding of the symbols. Call this right after creating an element
	   NOTE: You can also use OuterPadding in buttons with no sideDecorations
	   @param	_in Inner Pad
	   @param	_out Outer Pad
	**/
	public function setSideSymbolPad(_out:Int, _in:Int):BaseMenuItem
	{
		s_padIn = _in;
		s_padOut = _out;
		if (text != null) text = text; // Force a redraw
		return this;
	}//---------------------------------------------------;
	
	/**
	   Set side symbols. Use `null` for empty
	**/
	function setSideSymbols(l:String = " ", r:String = " ")
	{
		s_smb_l = l;
		s_smb_r = r;
	}//---------------------------------------------------;
	
}//--