package djTui;
import djTui.el.Label;
import djTui.Styles.WMSkin;

/**
 * 
 * Generic Window/Panel
 * ------------
 * - Managed by the WM
 * - Holds and manages baseElements and derivatives
 * - 
 */
class Window extends BaseElement 
{
	
	public var title(default, set):String;
	
	var title_el:Label;
	
	
	// Currently Active Borderstyle
	public var borderStyle:Int;
	
	// Padding at the edges, must accomodate for border
	var padX:Int;
	var padY:Int;
	
	var el_children:Array<BaseElement>;

	var active:BaseElement;
	var active_last:BaseElement;
	
	// --
	var lastAdded:BaseElement; // DEV: Shorthand for el_children.last()
	
	// Is it currently drawn/open
	public var isOpen:Bool = false;
	
	// - Push status updates to Window Manager :
	// --
	// focus	; Window was just focused
	@:allow(djTui.WM)
	var callback_wm:String->Window->Void; // ~ Always Set ~ //
	
	// Every window can have its own skin/style
	// All children will use this
	public var skin:WMSkin;
	
	//====================================================;
	// FLAGS
	// It is best to set flags right after creating this object
	//====================================================;
	
	// DO NOT allow focus to leave from this window
	public var flag_lockFocus:Bool = false;
	
	// Tab will cycle through elements and will try to escape window
	public var flag_enableTab:Bool = true;
	
	// Up and Down cursor keys will choose between elements
	public var flag_enableCursorNav:Bool = true;
	
	//====================================================;

	/**
	   Create a Window
	   @param	border_style Border Style 0,1,2
	**/
	public function new(_border:Int = 1, ?_skin:WMSkin)
	{
		super();
		el_children = [];
		setColors(WM.skin.win_fg, WM.skin.win_bg);
		borderStyle = _border;
		skin = _skin;
		if (skin == null) skin = WM.skin;
		padding(1, 1);
		callbacks = function(_, _){ }; // Make it not crash, because it's going to get called
	}//---------------------------------------------------;
	
	
	public function padding(xx:Int, yy:Int):Window
	{
		padX = xx; padY = yy; return this;
	}//---------------------------------------------------;
	
	/**
	   - Just Add an element to the window, without worrying about positioning
	     and alignments etc
	   - Just call addStacked() or addNext() to add and align an element
	   @param	el
	**/
	public function addChild(el:BaseElement)
	{
		#if debug
		if (width == 0 || height == 0) {
			throw "Window with zero size";
		}
		#end
		
		el_children.push(el);
		el.parent = this;
		el.callbacks = onElementCallback;
		el.onFocusChange();	// setup and colors
		el.onAdded();
		if (isOpen) el.draw();
		lastAdded = el;
	}//---------------------------------------------------;
	
	// --
	public function removeChild(el:BaseElement)
	{
		if (el_children.remove(el))
		{
			if (isOpen) draw();
		}
	}//---------------------------------------------------;

	
	public function addStacked(el:BaseElement, yPad:Int = 0)
	{
		if (lastAdded == null)
		{
			el.x = x + padX;
			el.y = y + padY;
		}else
		{
			el.x = lastAdded.x;
			el.y = lastAdded.y + lastAdded.height + yPad;
		}
		
		addChild(el);
	}//---------------------------------------------------;
	
	
	override public function focus() 
	{
		if (!flag_can_focus) return;
		callback_wm("focus", this);	// << Send this first to unfocus/draw any other windows
		super.focus();
		// Focus the first selectable element :
		if (el_children.length == 0) return;
		BaseElement.focusNext(el_children, null);
	}//---------------------------------------------------;
	
	
	override public function unfocus() 
	{
		if (!isFocused) return;
		if (active != null) active.unfocus();
		active_last = active;
		active = null;
		super.unfocus();
	}//---------------------------------------------------;
	
	
	
	// --
	override public function draw():Void 
	{
		if (lockDraw) return;
		
		_readyCol();
		
		// Draw the window background
		WM.D.rect(x, y, width, height);
		
		// Draw border
		if (borderStyle > 0)
		{
			if (isFocused) {
				WM.T.fg(WM.skin.win_hl);
			}else {
				WM.T.fg(WM.skin.win_fg);
			}
			WM.D.border(x, y, width, height, borderStyle);
		}
		
		// Draw Children
		// -
		for (el in el_children)
		{	
			if (!el.lockDraw) el.draw();
		}
		
	}//---------------------------------------------------;
	
	// Focus next element, will loop through the edges
	@:allow(djTui.WM)
	function focusNext(loop:Bool = true)
	{
		BaseElement.focusNext(el_children, active, loop);
	}//---------------------------------------------------;

	// Focus the previous element, will stop at index 0
	function focusPrev()
	{
		var ind = el_children.indexOf(active);
		if (ind < 1) return;
		while (ind--> 0)
		{
			if (el_children[ind].flag_can_focus)
			{
				el_children[ind].focus(); return;
			}
		}
	}//---------------------------------------------------;
	
	function isLastFocusableElement():Bool
	{
		var ai = el_children.indexOf(active);
		var ni = el_children.length;
		while (ni-->0)
		{
			if (el_children[ni].flag_can_focus) break;
		}
		
		return ai == ni;
	}//---------------------------------------------------;
	
	//====================================================;
	// EVENTS 
	//====================================================;
	
	// Handle keys pushed from the WM
	@:allow(djTui.WM)
	override function onKey(key:String)
	{
		switch(key)
		{
			case 'tab':	
				
				if (!flag_enableTab) return;
				
				if (isLastFocusableElement()) 
				{
					if (flag_lockFocus) return;
					callback_wm("focus_next", this);
				}
				else
				{
					focusNext();
				}
					
			default:
				
				if (flag_enableCursorNav)
				{
					if (key == "up") focusPrev(); else
					if (key == "down") focusNext(false);
				}
				
				if (active != null) active.onKey(key);
				
		}
	}//---------------------------------------------------;
	
	
	function onElementCallback(st:String, el:BaseElement)
	{
		switch(st)
		{
			case "focus":
				if (active != null) active.unfocus();
				active_last = active;
				active = el;
		}
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	// SETTERS
	//====================================================;
	
	function set_title(val)
	{
		title = val;
		
		if (title_el != null) 
		{
			removeChild(title_el);
		}
		
		if (title.length > width - 4) {
			title_el = new Label(title, width - 4);
			// TODO: Animate it
		}else
		{
			title_el = new Label('| ' + title + ' |');
		}
		title_el.setColors(WM.skin.win_hl, colorBG);
		title_el.pos(x +  Std.int((width / 2) - (title_el.width / 2)), y);
		addChild(title_el);
		
		return val;
		
	}//---------------------------------------------------;

}// -- end class --