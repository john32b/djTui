package djTui.win;

import djTui.BaseElement;
import djTui.Styles.PrintColor;
import djTui.Styles.WinStyle;
import djTui.el.BaseMenuItem;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.PopupOption;
import djTui.el.SliderNum;
import djTui.el.SliderOption;
import djTui.el.TextInput;
import djTui.el.Toggle;

/**
 * A class for easily creating Forms ( single line | LABEL + Menu Element | )
 * 
 * - adds menu elements with a label associated with them
 * - use setAlign(..) to set alignment
 * - use setLabelColors(..); to set label colorin
 * - use add(..); to add element + Label
 * - use addQ(..); to quickly add an element + Label
 * 
 * NOTE: 
 * - Setting the style doesn't alter the focused label color, you have to set it separately
 */
class WindowForm extends Window 
{
	// Map element SID to labels, so that they can be highlighted
	// So that they can 
	var labelMap:Map<BaseElement,Label>;
	// Current alignment type for when adding 
	var align:String;
	// If align=="fixed". The element divider relative X from window 0,0
	var align_fix_start:Int;
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
	**/
	public function new(?_sid:String, _w:Int = -2, _h:Int = -2, _style:WinStyle = null)
	{
		super(_sid, _w, _h, _style);
		
		labelMap = new Map();
		
		align = "none";
		align_padx = 1;
		
		// Default color for when highlighting an element
		setLabelFocusColor(style.elem_focus.bg, style.elem_focus.fg);
	}//---------------------------------------------------;
	
	/**
	   Set the alignment of LABEL + ELEMENT
	   @param	_align [none, fixed, center]
	   @param	_padx X Padding between LABEL + ELEMENT
	   @param	_fixedStart Only valid if type==fixed. Sets the first column (labels) length
							If NEGATIVE it autosize to a ratio of window width
	**/
	public function setAlign(_align:String, _padx:Int = 1, _fixedStart:Int = -2):WindowForm
	{
		align = _align;
		align_padx = _padx;
		align_fix_start = _fixedStart;

		if (align_fix_start < 0)
		{
			align_fix_start = Math.floor(inWidth/ -align_fix_start);
		}
		
		#if debug
		if (["fixed", "center", "none"].indexOf(align) < 0) {
			trace('Alignment Mode "$_align" not valid.');
			throw "WindowForm.SetAlign()";
		}
		#end
		
		trace('> Alignment set align:$align, padX:$align_padx, divider:$align_fix_start');
		
		return this;
	}//---------------------------------------------------;
	
	
	/**
	   Add an element along with a label.
	**/
	@:access(djTui.el.BaseMenuItem.color_focus)
	public function add(labelText:String, el:BaseElement)
	{
		#if debug // Check for overflow
			if (lastAdded != null && lastAdded.y == y + height - padY - 1)
			{
				trace("ERROR: WindowForm can't fit anymore elements");
				throw "WindowForm.add() overflow";
			}
		
		#end
		
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
				l.setTextWidth(align_fix_start - padX - align_padx);
				addStack(l);
				el.pos(x + align_fix_start, l.y);
				addChild(el);
				
			case "center":
				addStackInline([l, el], 0, align_padx, "center");
			default:
		}
	}//---------------------------------------------------;
	
	/**
	   When an element is focused, colorize its label with this color
	   set NULL on both for no color change.
	   ! CALL THIS BEFORE ADDING ANYTHING !
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
	
	/**
	   Override standard callbacks to add label highlight
	**/
	override function onChildEvent(st:String, el:BaseElement) 
	{
		// Capture element focus to handle label coloring
		if (st == "focus")
		{
			var l = labelMap.get(el);
			if (l != null) {
				l.focusSetup(true); l.draw();
			}
		}
		
		else if (st == "unfocus")
		{
			var l = labelMap.get(el);
			if (l != null) {
				l.focusSetup(false); l.draw();
			}
		}
		
		super.onChildEvent(st, el);
	}//---------------------------------------------------;
	
	
	/**
	   Quickly add a menu item using a special encoded string
		- input,sid,maxChars,type(number,all)
		- button,sid,text,btnStyle,fullwidth(1:0)
		- label,text,fullWidth(1:0),alignMode
		- toggle,sid,start(bool)
		- slNum,sid,min,max,inc,startValue
		- slOpt,sid,el1|el2|...,startIndex
		- popOpt,sid,el1|el2|...,slots,startIndex
		
	   @param label The Text of the label that preceeds the menu item
	   @param enc The encoded string  "type,sid,Class Conscructor Parameters"
			e.g. "button,sid01,2,10" // is like calling new button("sid01,2,10");
	**/
	public function addQ(labelText:String, enc:String):BaseMenuItem
	{
		var e:BaseMenuItem = null;
		var s:Array<String> = enc.split(',');
		var i = function(n:Int){return Std.parseInt(s[n]); };
		var w2 = width - align_fix_start - padX;
		
		switch(s[0])
		{
			case 'button':
				e = new Button(s[1], s[2], i(3), i(4) == 1?w2:0);
			case 'label':
				e = new Label(s[1], i(2) == 1?w2:0, s[3]);
			case 'input':
				e = new TextInput(s[1], align == "fixed"?w2-1:0, s[2]);
			case 'toggle':
				e = new Toggle(s[1], s[2] == "true");
			case 'slNum':
				e = new SliderNum(s[1], i(2), i(3), i(4));
			case 'slOpt':
				e = new SliderOption(s[1], s[2].split('|'), i(3));
			case 'popOpt':
				e = new PopupOption(s[1], s[2].split('|'), i(3), i(4));
			default:
				throw "Unsupported";
		}
		add(labelText, e);
		return e;
	}//---------------------------------------------------;
	
	
}// --