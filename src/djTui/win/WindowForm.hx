package djTui.win;

import djTui.BaseElement;
import djTui.Styles.PrintColor;
import djTui.adaptors.djNode.InputObj;
import djTui.Styles.WMSkin;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.SliderNum;
import djTui.el.SliderOption;
import djTui.el.TextInput;
import djTui.el.Toggle;

/**
 * A class for easily creating Forms ( LABEL + Menu Element )
 * 
 * - adds menu elements with a label associated with them
 * - easy insertion of elements using Encoded String, use add()
 * - use setAlign(..) to set alignment
 * - use setLabelColors(..); to set label coloring
 * 
 */
class WindowForm extends Window 
{
	// Map element SID to labels, so that they can be highlighted
	// So that they can 
	var labelMap:Map<BaseElement,Label>;

	// Current alignment type for when adding 
	var align:String;
	// If align=="fix". The element divider relative X from window 0,0
	var align_divider:Int;
	// X Padding of the elements
	var align_padx:Int;

	// When an element is focused, colorize the label with this color (fg+bg)
	var colorLabelFocus:PrintColor;
	
	//====================================================;
	
	/**	
	   @param	sid Identifier (optional)
	   @param	_w Width
	   @param	_h Height
	   @param	_borderStyle
	   @param	_skin
	**/
	public function new(?_sid:String, _w:Int = 15, _h:Int = 8, _borderStyle:Int = 1, ?_skin:WMSkin)
	{
		super(_sid, _w, _h, _borderStyle, _skin);

		labelMap = new Map();
		
		align = "none";
		align_padx = 1;
		
		// Default color for when highlighting an element
		setLabelFocusColor(skin.win_hl);
	}//---------------------------------------------------;
	
	
	/**
	   Set the alignment of LABEL + ELEMENT
	   @param	_align [none, fixed, center]
	   @param	_padx X Padding between LABEL + ELEMENT
	   @param	_dividerPos Only valid if type==fixed. Sets the first column (labels) length
							If NEGATIVE it autosize to a ratio of window width
	**/
	public function setAlign(_align:String, _padx:Int = 1, _dividerPos:Int = -2):WindowForm
	{
		align = _align;
		align_padx = _padx;
		align_divider = _dividerPos;

		if (align_divider < 0)
		{
			align_divider = Math.floor(inWidth/ -align_divider);
		}
		
		#if debug
		if (["fixed", "center", "none"].indexOf(align) < 0) {
			throw "Alignment Type Error : " + align;
		}
		#end
		
		trace('> Alignment set align:$align, padX:$align_padx, divider:$align_divider');
		
		return this;
	}//---------------------------------------------------;
	
	
	/**
	   Add an element along with a label.
	**/
	@:access(djTui.el.BaseMenuItem.color_focus)
	public function add(labelText:String, el:BaseElement)
	{
		var l = new Label(labelText);
			l.color_focus = colorLabelFocus;
		labelMap.set(el, l);
		
		switch(align)
		{
			case "none":
				addStack(l);
				el.posNext(l, align_padx);
				addChild(el);
			case "fixed":
				
				addStack(l);
				// TODO RESET_WIDTH
				el.pos(x + align_divider, l.y);
				addChild(el);
				
			case "center":
				addStackCentered([l, el], 0, align_padx);
			default:
		}
	}//---------------------------------------------------;
	
	/**
	   When an element is focused, colorize its label with this color
	   set NULL on both for no color change.
	   ! CALL THIS BEFORE ADDING ANYTHING
	   @param	fg Foreground Color
	   @param	bg Background Color ( can be null )
	**/
	public function setLabelFocusColor(?fg:String, ?bg:String)
	{
		if (fg == null) 
			colorLabelFocus = null;
		else
			colorLabelFocus = {
				fg:fg,
				bg:bg
			};
	}//---------------------------------------------------;
	
	// --
	override function onElementCallback(st:String, el:BaseElement) 
	{
		
		// Capture element focus to handle label coloring
		if (st == "focus")
		{
			var l:Label = labelMap.get(el);
			if (l != null) 
			{
				l.focusSetup(true); l.draw();
			}
		}
		
		else if (st == "unfocus")
		{
			var l:Label = labelMap.get(el);
			if (l != null)
			{
				l.focusSetup(false); l.draw();
			}
		}
		
		super.onElementCallback(st, el);
		
	}//---------------------------------------------------;
	
	
	/**
	   Add an encoded form ( CSV encoded )
	   - label,text
	   - button,sid,text
	   
	   @param	str type,sid,.....
	**/
	public function addEnc2(str:String)
	{
		var b = str.split(',');
		var e:BaseElement = null;
		switch(b[0])
		{
			case 'button':
				e = new Button(b[1], b[2]);
			case 'label':
				e = new Label(b[1], inWidth);
			case 'input':
				e = new TextInput(b[1], inWidth);
			case 'sliderNum':
				e = new SliderNum(b[1], Std.parseInt(b[3]), Std.parseInt(b[4]), Std.parseInt(b[5]));
			case 'sliderOpt':
				e = new SliderOption(b[1], b[2].split('|'));
			case 'popupOpt':
			case 'toggle':
				e = new Toggle(b[1], b[3]=="true");
			default:
				throw "Unsupported";
		}
		addStack(e);
		
	}//---------------------------------------------------;
	
}// --