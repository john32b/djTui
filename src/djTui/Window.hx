package djTui;
import djTui.el.Label;
import djTui.Styles.WMSkin;
import haxe.extern.EitherType;

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
	
	// Effective width, inside the window (calculates padding)
	public var inWidth(get, null):Int;
	
	// Holds all the elements that exist inside the window
	var el_children:Array<BaseElement>;

	var active:BaseElement;
	var active_last:BaseElement;
	
	// --
	var lastAdded:BaseElement; // DEV: Shorthand for el_children.last()
	
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
		el_children = [];	// <- Important to be before super();
		super();
		type = "window";
		setColors(WM.skin.win_fg, WM.skin.win_bg);
		borderStyle = _border;
		skin = _skin;
		if (skin == null) skin = WM.skin;
		padding(1, 1);
		callbacks = function(_, _){ }; // Make it not crash, because it's going to get called
	}//---------------------------------------------------;
	
	//public function center
	
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
		el.onFocusChange();	// setup and colors, in supported elements
		el.onAdded();
		el.visible = visible;
		if (visible) el.draw();
		lastAdded = el;
	}//---------------------------------------------------;
	
	// --
	public function removeChild(el:BaseElement)
	{
		if (el_children.remove(el))
		{
			el.visible = false;
			if (visible) draw();
		}
	}//---------------------------------------------------;

	/**
	   Add a single element in a new line on the window
	   @param	el Add an element to a line
	   @param	yPad Padding form the element above it
	   @param	align Align in relation go the window
	**/
	public function addLine(el:BaseElement, align:String = "left", yPad:Int = 0)
	{
		switch(align)
		{
			case "left":
				el.x = x + padX;
			case "right":
				el.x = x + width - padX - el.width;
			case "center":
				el.x = x + Std.int((width / 2) - (el.width / 2));
			case "fill":
				el.width = inWidth;
				el.x = x + padX;
		}
		
		if (lastAdded == null)
		{
			el.y = y + padY;
		}else
		{
			el.y = lastAdded.y + lastAdded.height + yPad;
		}
		
		addChild(el);
	}//---------------------------------------------------;
	
	
	/**
	   Close window, does not destroy it
	**/
	public function close()
	{
		visible = false; //-> will trigger children
		callback_wm("close", this);
	}//---------------------------------------------------;
	
	/**
	   Shorthand to WM.open()
	   @param	autoFocus
	**/
	public function open(autoFocus:Bool = false)
	{
		WM.add(this, autoFocus);
	}//---------------------------------------------------;
	
	
	/**
	   - Focus this window
	   - Unfocuses any other focused window
	   - Focuses first focusable element
	**/
	override public function focus() 
	{
		if (!flag_can_focus) return;
		callback_wm("focus", this);	// << Send this first to unfocus/draw any other windows
		lockDraw = true;
		super.focus();
		lockDraw = false;
		// Focus the first selectable element :
		if (el_children.length == 0) return;
		BaseElement.focusNext(el_children, null);
	}//---------------------------------------------------;
	
	
	override public function unfocus() 
	{
		if (!isFocused) return;
		if (active != null) active.unfocus();
		active_last = active;
		lockDraw = true;
		active = null;
		super.unfocus();
		lockDraw = false;
	}//---------------------------------------------------;
	
	
	
	// --
	override public function draw():Void 
	{
		if (lockDraw || !visible) return;
		
		_readyCol();
		
		// Draw the window background
		WM.D.rect(x, y, width, height);
		
		// Draw Border
		if (borderStyle > 0)
		{
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
	
	// Checks if <active> is the last focusable on the window list
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
	// 
	//====================================================;
	
	
	override function set_visible(val):Bool
	{
		if (visible != val) 
		{
			for (el in el_children) el.visible = val;
		}
		return visible = val;
	}//---------------------------------------------------;
	
	/**
	   Search and return an element with target SID
	   @param	sid the SID of the element 
	   @return
	**/
	public function getSID(sid:String):BaseElement
	{
		// Note, this is faster than an array.filter, because it will not parse all the elements
		for (el in el_children) if (el.SID == sid) return el;
		return null;
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
		
		// Pipe callbacks to user
		callbacks(st, el);
		
	}//---------------------------------------------------;
	
	//====================================================;
	// GETTER, SETTERS
	//====================================================;
	
	
	function get_inWidth()
	{
		return Std.int(width - padX - padX);
	}//---------------------------------------------------;
	
	function set_title(val)
	{
		title = val;
		
		if (title_el != null) 
		{
			removeChild(title_el);
		}
		
		if (title.length > width - 4) {
			title_el = new Label(title, width - 4);
			// TODO: Animate it ??
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