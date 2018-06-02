package djTui;
import djTui.BaseElement;
import djTui.el.Label;
import djTui.Styles.WMSkin;
import haxe.extern.EitherType;

/**
 * 
 * Generic Window/Panel
 * ------------
 * - Managed by the WM
 * - Holds and manages baseElements and derivatives 
 * 
 * User Callbacks via 'callbacks' object :
 * 
 *		escape : Esc key got pressed
 * 		focus  : A new element has been focused
 * 		fire   : Element was activated
 * 		change : Element was changed
 * 		open   : Window was just opened
 * 		close  : Window was just closed
 */
class Window extends BaseElement 
{
	
	//
	public var title(default, set):String;
	
	// The actual Label holding the title
	var title_el:Label;
	
	// Currently Active Borderstyle
	public var borderStyle:Int;
	
	// Padding at the edges, must accomodate for border
	var padX:Int;
	var padY:Int;
	
	// Effective width, inside the window (calculates padding)
	public var inWidth(get, null):Int;
	
	// Holds all the elements that are visible inside the window
	var display_list:Array<BaseElement>;

	// Current Focused Element ( null if none )
	var active:BaseElement;
	
	// Previously Focused element before current one ( null if none)  
	var active_last:BaseElement;
	
	// --
	var lastAdded:BaseElement; // DEV: Shorthand for display_list.last()
	
	// -- Pushes status updates to Window Manager :
	// 			focus	: Window was just focused
	@:allow(djTui.WM)
	var callback_wm:String->Window->Void;
	
	// Every window can have its own skin/style
	// All children will use this
	public var skin:WMSkin;
	
	//====================================================;
	// FLAGS
	// It is best to set flags right after new()
	//====================================================;
	
	// DO NOT allow focus to leave from this window
	public var flag_focus_lock:Bool = false;
	
	// Is this window/panel a subpanel? ( like a popup list )
	public var flag_is_sub:Bool = false;
	
	// If true, when this window gets focus, will try to focus last element focused
	@:allow(djTui.WM)
	var flag_once_focusLast:Bool = false;
	
	//====================================================;

	/**
	   Create a Window.
	   ! IMPORTANT, After creating a window set its size.
	   @param	_borderStyle Border Style 0,1,2 ( none, light, thick )
	   @param	_skin You can set a custom style for this window and its children
	**/
	public function new(_borderStyle:Int = 1, ?_skin:WMSkin)
	{
		display_list = [];	// <- Important to be before super();
		super();
		type = ElementType.window;
		setColors(WM.skin.win_fg, WM.skin.win_bg);
		borderStyle = _borderStyle;
		skin = _skin;
		if (skin == null) skin = WM.skin;
		padding(1, 1);
		callbacks = function(_, _){ }; // Make it not crash, because it's going to get called
	}//---------------------------------------------------;
	
	
	/**
	   Search and return an element with target SID
	   @param	sid the SID of the element 
	   @return
	**/
	public function getSID(sid:String):BaseElement
	{
		// Note, this is faster than an array.filter, because it will not parse all the elements
		for (el in display_list) if (el.SID == sid) return el;
		return null;
	}//---------------------------------------------------;
	
	
	/**
	   Override the basic `move` to also move all of the children
	**/
	override public function move(dx:Int, dy:Int):BaseElement 
	{
		x += dx;
		y += dy;
		for (i in display_list) i.move(dx, dy);
		return this;
	}//---------------------------------------------------;
	
	/**
	   @param	_w If <0 will autosize based on WM WIDTH / value
	   @param	_h If <0 will autosize based on WM WIDTH / value
	   @return
	**/
	override public function size(_w:Int, _h:Int):BaseElement 
	{
		if (_w < 0)
		{
			_w = Math.floor(WM.width / -_w);
		}
		
		if (_h < 0)
		{
			_h = Math.floor(WM.height / -_h);
		}
		
		super.size(_w, _h);
		return this;
	}//---------------------------------------------------;
	

	/**
	   Set padding for the window. Returns self for chaining
	   @param	xx Sides
	   @param	yy Top/Bottom
	   @return
	**/
	public function padding(xx:Int, yy:Int):Window
	{
		padX = xx; padY = yy; return this;
	}//---------------------------------------------------;
	
	/**
	   - Add an element to the window, without worrying about positioning
	   - Call addStacked() to add and align an element (prefered)
	   @param	el
	**/
	public function addChild(el:BaseElement)
	{
		#if debug
		if (width == 0 || height == 0) {
			throw "Window with zero size";
		}
		#end
		
		display_list.push(el);
		el.callbacks = onElementCallback;
		el.parent = this;
		el.onAdded();
		el.visible = visible;
		el.focusSetup(false);	// Setup colors, in supported elements, default to unfocused
		if (visible) el.draw();
	}//---------------------------------------------------;
	
	// --
	public function removeChild(el:BaseElement)
	{
		if (display_list.remove(el))
		{
			el.visible = false;
			if (visible) draw();
		}
	}//---------------------------------------------------;

	/**
	   Add a single element below the previously added element
	   @param	el Add an element to a line
	   @param	yPad Padding form the element above it
	   @param	align left|center|right|none
	**/
	public function addStack(el:BaseElement, yPad:Int = 0, align:String = "left")
	{
		switch(align)
		{
			case "left": el.x = x + padX;	
			case "right": el.x = x + width - el.width;
			case "center": el.x = x + Std.int((width / 2) - (el.width / 2));
			default : // No alignment
		}
		
		if (lastAdded == null)
		{
			el.y = y + padY + yPad;
		}else
		{
			el.y = lastAdded.y + lastAdded.height + yPad;
		}
		
		addChild(el);
		lastAdded = el;
	}//---------------------------------------------------;
	
	/**
	   Add a bunch of elements in a single line, centered to the window X axis
	   @param	el The elements to add
	   @param	yPad From the previously added element
	   @param	xPad In between the elements
	**/
	public function addStackCentered(el:Array<BaseElement>, yPad:Int = 0, xPad:Int = 1)
	{
		// Calculate starting Y
		var yloc:Int = 0;
		if (lastAdded == null) {
			yloc= y + padY;
		}else {
			yloc = lastAdded.y + lastAdded.height + yPad;
		}
		// Calculate total width.etc
		var totalWidth:Int = 0;
		for (i in el) totalWidth += i.width;
		totalWidth += (el.length - 1) * xPad;
		var startX:Int = x + Std.int(width / 2 - totalWidth / 2);
		for (i in 0...el.length)
		{
			el[i].pos(startX, yloc);
			startX = el[i].x + el[i].width + xPad;
			addChild(el[i]);
		}
		lastAdded = el[el.length - 1];
	}//---------------------------------------------------;
	
	/**
	   Close window, does not destroy it
	**/
	public function close()
	{
		visible = false; //-> will trigger children
		callback_wm("close", this);
		callbacks("close", this);	// push to user
	}//---------------------------------------------------;
	
	/**
	   Shorthand to WM.open()
	   @param	autoFocus
	**/
	public function open(autoFocus:Bool = false)
	{
		WM.add(this, autoFocus);
		callbacks("open", this);	// push to user
	}//---------------------------------------------------;
	
	
	/**
		Align this window to the WM Viewport
	**/
	public function screenCenter()
	{
		pos( Std.int(WM.width / 2 - width / 2) ,
			 Std.int(WM.height / 2 - height / 2) );
	}//---------------------------------------------------;
	
	/**
	   - Focus this window
	   - Unfocuses any other focused window
	   - Focuses first focusable element
	**/
	override public function focus() 
	{
		if (!flag_focusable) return;
		callback_wm("focus", this);	// << Send this first to unfocus/draw any other windows
		lockDraw = true;
		super.focus();
		lockDraw = false;
		// Focus an element
		if (display_list.length == 0) return;
		if (flag_once_focusLast && active_last != null)
		{
			active_last.focus();
			flag_once_focusLast = false;
		}else
		{
			// Focus the first selectable element :
			BaseElement.focusNext(display_list, null);
		}
	}//---------------------------------------------------;
	
	/**
	   - Unfocuses the window and all child elements
	**/
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
		for (el in display_list)
		{	
			if (!el.lockDraw) el.draw();
		}
		
	}//---------------------------------------------------;
	
	
	// Focus next element, will loop through the edges
	@:allow(djTui.WM)
	function focusNext(loop:Bool = true)
	{
		BaseElement.focusNext(display_list, active, loop);
	}//---------------------------------------------------;

	// Focus the previous element, will stop at index 0
	function focusPrev()
	{
		var ind = display_list.indexOf(active);
		if (ind < 1) return;
		while (ind--> 0)
		{
			if (display_list[ind].flag_focusable)
			{
				display_list[ind].focus(); return;
			}
		}
	}//---------------------------------------------------;
	
	// Checks if <active> is the last focusable on the window list
	function isLastFocusableElement():Bool
	{
		var ai = display_list.indexOf(active);
		var ni = display_list.length;
		while (ni-->0)
		{
			if (display_list[ni].flag_focusable) break;
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
				
				if (isLastFocusableElement())
				{
					if (flag_focus_lock) focusNext(true); 
					else
					callback_wm("focus_next", this);
				}
				else
				{
					focusNext(true);
				}
					
			case 'esc':
				callbacks('escape', this);
				
			default:
				
				if (key == "up") focusPrev(); else
				if (key == "down") focusNext(false);
				
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
				
			case "focus_prev":
				focusPrev();
				
			case "focus_next":
				focusNext(false);
				
		}
		
		// Pipe callbacks to user
		callbacks(st, el);
		
	}//---------------------------------------------------;
	
	//====================================================;
	// GETTER, SETTERS
	//====================================================;
	
	override function set_visible(val):Bool
	{
		if (visible != val) 
		{
			for (el in display_list) el.visible = val;
		}
		return visible = val;
	}//---------------------------------------------------;
	
	// --
	function get_inWidth()
	{
		return Std.int(width - padX - padX);
	}//---------------------------------------------------;
	
	// --
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