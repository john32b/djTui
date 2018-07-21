package djTui;
import djTui.BaseElement;
import djTui.el.Button;
import djTui.el.Label;
import djTui.Styles.WMSkin;
import haxe.Timer;

/**
 * 
 * Generic Window/Panel
 * ------------
 * - Managed by the WM
 * - Holds and manages baseElements and derivatives 
 * - Default 'TAB' is to cycle between elements and exit to next window, unless "flag_focus_lock" is set
 * 
 * Callback Statuses via the 'callbacks' object :
 * 
 *		escape : Esc key got pressed
 * 		focus  : Element/Window has been focused ; (check element.type or SID)
 * 		unfocus: Element/Window has been unfocused ; (check element type or SID)
 * 		fire   : Element was activated
 * 		change : Element was changed
 * 		open   : Window was just opened
 * 		close  : Window was just closed
 */
class Window extends BaseElement 
{
	
	// Window title, automatically adds an element
	public var title(default, set):String;
	
	// The actual Label holding the title
	var title_el:Label;
	
	/** This window border index. Defaults to WM.globalBorder 
	 * NOTE: Mind the padding when setting this to and from 0 */
	public var borderStyle(default, set):Int;
	
	/** This window skin, defaults to WM.globalSkin */
	public var skin:WMSkin;
	
	// Padding of elements from the edges
	// Applied to automatic positioning functions like addStack()
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
	//    Will push custom window statuses and
	//    all children element statuses as
	@:allow(djTui.WM)
	var callback_wm:String->Window->Void;

	
	/// FLAGS :
	// It is best to set flags right after new()
	
	// DO NOT allow focus to leave from this window
	public var flag_focus_lock:Bool = false;

	// If true, when this window gets focus, will try to focus last element focused
	// ! Will only apply once ! So it's needed to be set every time 
	public var flag_once_focusLast:Bool = false;
	

	/**
	   Create a Window
	   @param	sid Optional String ID. If set then this window will be stored to WM.DB for quick retrieval 
	   @param	_w Window Width ( Negative integers to set to FULLWIDTH/N )
	   @param	_h Window Height ( Negative integers to set to FULLHEIGH/N )
	**/
	public function new(?sid:String, _w:Int = 5, _h:Int = 5)
	{
		// DEVNOTE: Don't mess with the ordering, it matters
		
		display_list = [];
		
		if (sid != null)
		{
			WM.DB.set(sid, this);
		}
		
		super(sid);
		
		type = ElementType.window; 
		
		// Make it not crash, because it's going to get called
		callbacks = function(_, _){ }; 
				
		setStyle(WM.global_skin, WM.global_border);
		
		if (borderStyle > 0) 
			padding(2, 2);
			else
			padding(1, 1);

		size(_w, _h);
	}//---------------------------------------------------;
	
	/**
	   Sets the Skin and Border for this window. 
	   Both optional parameters so you can just set one of them if you want
	   @param	_skin A skin object -> Currently DOES NOT apply the new skin. So set this first thing first
	   @param	_border Border index from `Styles.border` -> Will also apply the border
	   @return
	**/
	public function setStyle(?_skin:WMSkin, ?_border:Int):Window
	{
		if (_skin != null)
		{
			skin = _skin;
			// DevNote: Color in windows, doesn't do anything?
			setColor(skin.win_fg, skin.win_bg); 
		}
		
		if (_border != null)
		{
			set_borderStyle(_border);
		}
		
		return this;
	}//---------------------------------------------------;
	
	/**
	   Search and return an element with target SID
	   @param	sid the SID of the element 
	   @return
	**/
	public function getEl(sid:String):BaseElement
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
		if (visible) draw();
		return this;
	}//---------------------------------------------------;
	
	/**
	   @param	_w If <0 will autosize based on WM WIDTH / value
	   @param	_h If <0 will autosize based on WM WIDTH / value
	   @return
	**/
	override public function size(_w:Int, _h:Int):BaseElement 
	{
		#if debug
		if (_w == 0 || _h == 0) throw "ERROR, Window size cannot be 0";
		#end
		
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
	   Set padding for the edges of the window. Returns self for chaining
	   @param	xx Sides
	   @param	yy Top/Bottom
	   @return
	**/
	public function padding(xx:Int, yy:Int):Window
	{
		padX = xx; padY = yy; return this;
	}//---------------------------------------------------;
	
	/**
	   - Adds an element to the window
	   - Element should have its size set before adding to a window
	   - Call addStacked() to add and align an element (prefered)
	   @param	el
	**/
	public function addChild(el:BaseElement):BaseElement
	{
		display_list.push(el);
		el.callbacks = onElementCallback;
		el.parent = this;
		
		#if debug 
			// Check Overflows
			if (el.x + el.width > x + width - padX) {
				trace('ERROR: Element sid:${el.SID} width is too large for window.');
			}
			
			if (el.y + el.height >= y + height) {
				trace('ERROR: Element sid:${el.SID} Y pos overflow.');
			}
		#end
		
		el.onAdded();
		el.visible = visible;
		if (el.flag_focusable)
			el.focusSetup(false);	// Setup colors, in supported elements, default to unfocused
		if (visible && !lockDraw) el.draw();
		return el;
	}//---------------------------------------------------;
	
	// --
	public function removeChild(el:BaseElement)
	{
		if (display_list.remove(el))
		{
			el.visible = false;
			if (visible && !lockDraw) draw();
		}
	}//---------------------------------------------------;

	/**
	   Add a single element below the previously added element
	   @param	el Add an element to a line
	   @param	yPad Padding form the element above it
	   @param	align left|center|right|none
	**/
	public function addStack(el:BaseElement, yPad:Int = 0, align:String = "left"):BaseElement
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
		return el;
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
		if (visible == false) return;
		visible = false; //-> will trigger children
		
		// Will unfocus any active element
		unfocus(); 
		
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
	   Open the window with a simple animation
	   AutoFocuses it
	**/
	public function openAnimated()
	{
		var st = [0.3, 0.6];
		var t = new Timer(80);
		var c:Int = 0;
		t.run = function()
		{
			var w:Int = Math.ceil(st[c] * width);
			var h:Int = Math.ceil(st[c] * height);
			var xx:Int = Math.ceil(x + (width - w) / 2);
			var yy:Int = Math.ceil(y + (height - h) / 2);
			
			_readyCol();
			WM.D.rect(xx, yy, w, h);
			if (borderStyle > 0) 
			{
				//WM.T.bg(skin.tui_bg).fg(skin.accent_fg);
				WM.D.border(xx, yy, w, h, borderStyle);
			}
			
			if (++c == st.length) {
				t.stop();
				open(true);
			}
		}
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
		lockDraw = true; // Skip drawing the whole window again
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
		active = null;
		lockDraw = true;
		super.unfocus();
		lockDraw = false;
		callbacks("unfocus", this);
	}//---------------------------------------------------;
	
	
	// --
	// Draws the entire window along with children
	override public function draw():Void 
	{
		if (lockDraw || !visible) return;
		
		_readyCol();
		
		// Draw the window background
		WM.D.rect(x, y, width, height);
		
		// Draw Border
		// DEV : Drawing of the border occurs on borderstyle setter as well
		if (borderStyle > 0)
		{
			WM.D.border(x, y, width, height, borderStyle);
		}
		// Draw Children
		for (el in display_list)
		{	
			if (!el.lockDraw) el.draw(); // Todo, also !visible?
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
					if (flag_focus_lock) 
						focusNext(true); 
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
				
				// TODO: This can cause bugs on windows with VLists + other elements
				if (key == "up") focusPrev(); else
				if (key == "down") focusNext(false);
				
				if (active != null) active.onKey(key);
				
		}
	}//---------------------------------------------------;
	
	/**
	   Called when any child element pushes a status
	   @param	st Status Message
	   @param	el The element that fired the status
	**/
	function onElementCallback(st:String, el:BaseElement)
	{
		#if (debug && true)
		trace('> Element Callback : From:${el.SID}, Status:$st, Data:"${el.getData()}", Owner:${el.parent.SID}');
		#end
		
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
				
			default:	
		}
		
		// Pipe callbacks to user
		callbacks(st, el);
		
		// Pipe callbacks to the global WM if set
		if (WM.onElementCallback != null) WM.onElementCallback(st, el);
	}//---------------------------------------------------;
	
	//====================================================;
	// GETTER, SETTERS
	//====================================================;
	
	/**
	   If borderstyle index out of bounds, it will be set to the first one
	**/
	function set_borderStyle(val):Int
	{
		if (borderStyle == val) return val;
			borderStyle = val;
			
		if (borderStyle > Styles.border.length - 1) borderStyle = 1;
		
		if (visible && !lockDraw)
		{
			_readyCol();
			WM.D.border(x, y, width, height, borderStyle);
			if (title_el != null) title_el.draw();
		}
		
		return val;
	}//---------------------------------------------------;

	// --
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
		
		lockDraw = true;
		
		if (title_el != null) 
		{
			removeChild(title_el);
		}

		title_el = new Label("| " + title + " |");
		
		if (title.length > inWidth - 4)
		{
			title_el.setTextWidth(inWidth - 4, "center");
		}
		
		title_el.setColor(skin.win_hl, colorBG);
		title_el.pos(x +  Std.int((width / 2) - (title_el.width / 2)), y);
		addChild(title_el);
		
		lockDraw = false;
		
		// Experimental :
		// Draw the top border and the title
		if (visible) 
		{
			_readyCol();
			// NOTE: DO NOT DRAW OVER THE CORNERS!!!
			WM.D.lineH(x+1, y, width-2, Styles.border[borderStyle].charAt(1));
			title_el.draw();
		}
		
		return val;
	}//---------------------------------------------------;

}// -- end class --