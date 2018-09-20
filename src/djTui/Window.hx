package djTui;
import djTui.BaseElement;
import djTui.el.Border;
import djTui.el.Button;
import djTui.el.Label;
import djTui.Styles.WinStyle;
import haxe.Timer;

/**
 * 
 * Generic Window/Panel
 * --------------------
 * - Holds and manages baseElements and derivatives 
 * 
 * - Callback Statuses. Place a callback listener with .listen(..);
 * 
 *		escape : Esc key got pressed
 * 		focus  : Element/Window has been focused ; (check element.type or SID)
 * 		unfocus: Element/Window has been unfocused ; (check element.type or SID)
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
	
	/** This window border index. Defaults to `Style.border` but can be overriden
	 *  NOTES: - Mind the padding when setting this to and from 0 
	 * 		   - Check `styles.hx` for available border styles
	 **/
	public var borderStyle(default, set):Int;

	// The border element responsible for drawing the border
	var border_el:Border;
	
	/**
	   This window style, defaults to `WM.global_style`
	   NOTE: 
		- You can assign a new style to this object and it will be applied with the setter
		- If you want to modify parts of the style call .modifyStyle(), it will apply the changes
	   DEV:
	    - Keep it as a pointer
	**/
	public var style(default, set):WinStyle;
	
	// Padding of elements from the edges
	// Applied to automatic positioning functions like addStack()
	var padX:Int;
	var padY:Int;
	
	// Effective width, inside the window
	public var inWidth(get, null):Int;
	// Effective height, inside the window
	public var inHeight(get, null):Int;
	
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
	//  DEVNOTE: I don't use the `callbacks` pool on purpose. Don't change it.
	@:allow(djTui.WM)
	var callback_wm:String->Window->Void;

	
	/// FLAGS :
	// It is best to set flags right after new()
	
	// DO NOT allow focus to leave from this window
	public var flag_focus_lock:Bool = false;

	/** If true, when this window gets focus, will try to focus last element focused
	 *  ! Will only apply once ! So it's needed to be set every time  */
	public var flag_once_focusLast:Bool = false;
	
	
	/**
	   Create a Window
	   @param	sid Optional String ID. If set then this window will be stored to WM.DB for quick retrieval 
	   @param	_w Window Width ( Negative integers to set to FULLWIDTH/N )
	   @param	_h Window Height ( Negative integers to set to FULLHEIGHT/N )
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
		
		// Create a border element, even in 0 border styles. Easier to maintain.
		border_el = new Border();
		addChild(border_el);
		
		// DevNotes: Setting the style will also set the `borderStyle`
		style = Reflect.copy(WM.global_style_win);
		
		if (borderStyle > 0) 
			padding(2, 2);
			else
			padding(1, 1);

		size(_w, _h);
	}//---------------------------------------------------;
	
	/**
	   Will modify specific fields of the style object. See `Styles.WinStyle` for the fields
	   
	  ! IMPORTANT : Call this before adding child elements.
		e.g. window.modifyStyle( { text:"red",bg:"black"} );
		
	  ! EXPERIMENTAL : You can call this after adding elements, but it is buggy.
		
	   @param	o Object with field names and values conforming to `Styles.WinStyle`
	**/
	public function modifyStyle(o:Dynamic)
	{
		var t = Reflect.copy(style);
		Tools.copyFields(o, t);
		style = t; // Sets and applies
		
		// Experimental: Works but not in all cases
		for (i in display_list) i.focusSetup(i.isFocused);
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
		
		border_el.size(_w, _h);
		
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
		el.listen(onElementCallback);
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
		{
			el.focusSetup(isFocused);	// Setup colors, in supported elements.
		}
		
		if (visible && !lockDraw) el.draw();
		return el;
	}//---------------------------------------------------;
	
	// --
	public function removeChild(el:BaseElement)
	{
		if (display_list.remove(el))
		{
			el.visible = false; // Important to trigger any custom setters
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
	   @param   align center left
	**/
	public function addStackInline(el:Array<BaseElement>, yPad:Int = 0, xPad:Int = 1, align:String = "left")
	{
		// Calculate starting Y
		var yloc:Int = 0;
		if (lastAdded == null) {
			yloc = y + padY;
		}else {
			yloc = lastAdded.y + lastAdded.height + yPad;
		}
		// Calculate total width.etc
		var totalWidth:Int = 0;
		for (i in el) totalWidth += i.width;
		totalWidth += (el.length - 1) * xPad; // Add In-between padding to total width
		
		// Alignment :
		var startX = 0;
		if (align == "center") 
			startX = x + Std.int(width / 2 - totalWidth / 2);
		else
			startX = x + padX;
			
		for (i in 0...el.length)
		{
			el[i].pos(startX, yloc);
			startX = el[i].x + el[i].width + xPad;
			addChild(el[i]);
			// Make buttons be able to exit focus with LEFT/RIGHT automatically
			if (el[i].type  == ElementType.button)
			{
				cast(el[i], Button).flag_leftright_escape = true;
			}
		}
		lastAdded = el[el.length - 1];
	}//---------------------------------------------------;
	
	/**
	   Add a horizontal line separator
	   @param forceStyle Set a border style (0-6)
	**/
	public function addSeparator(forceStyle:Int = 0)
	{
		if (forceStyle == 0) forceStyle = borderStyle;
		var s = StringTools.lpad("", Styles.border[forceStyle].charAt(1), inWidth);
		var l = new Label(s, 0, "center");
		addStack(l);
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
		callback("close");	// push to user
	}//---------------------------------------------------;
	
	/**
	   Shorthand to WM.open()
	   @param	autoFocus
	**/
	public function open(autoFocus:Bool = false)
	{
		WM.add(this, autoFocus);
		callback("open");
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
	   - Does not draw the window again
	   - The WM automatically draws it on "focus" signal and only if it must be drawn fully
	**/
	override public function focus() 
	{
		if (!flag_focusable) return;
		
		if (style.borderColor_focus != null) 
		{
			border_el.setColor(style.borderColor_focus);
			border_el.draw();
		}
		
		if (style.titleColor_focus != null && title_el != null)
		{
			title_el.setColor(style.titleColor_focus);
			title_el.draw();
		}
		
		callback_wm("focus", this);	// << This will unfocus/draw other windows and draw self if needed
		
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
		
		if (style.borderColor_focus != null) 
		{
			border_el.setColor(style.borderColor);
			border_el.draw();
		}
		
		if (style.titleColor_focus != null && title_el != null)
		{
			title_el.setColor(style.titleColor);
			title_el.draw();
		}
		
		if (active != null) active.unfocus();
		active_last = active;
		active = null;
		lockDraw = true;
		super.unfocus();
		lockDraw = false;
	}//---------------------------------------------------;
	
	
	// --
	// Draws the entire window along with children
	override public function draw():Void 
	{
		if (lockDraw || !visible) return;
		
		// Draw the window background
		_readyCol();
		WM.D.rect(x, y, width, height);
		
		for (el in display_list)
		{	
			if (!el.lockDraw) el.draw(); // Todo, also !visible?
		}
		
	}//---------------------------------------------------;
	
	
	// Focus next element, will loop through the edges
	@:allow(djTui.WM)
	@:allow(djTui.BaseElement)
	function focusNext(loop:Bool = true):Bool
	{
		return BaseElement.focusNext(display_list, active, loop);
	}//---------------------------------------------------;

	// Focus the previous element, will stop at index 0
	@:allow(djTui.WM)
	@:allow(djTui.BaseElement)
	function focusPrev():Bool
	{
		var ind = display_list.indexOf(active);
		if (ind < 1) return false;
		while (ind--> 0)
		{
			if (display_list[ind].flag_focusable)
			{
				display_list[ind].focus(); return true;
			}
		}
		return false;
	}//---------------------------------------------------;
	
	// Checks if <active> is the last focusable on the window list
	function activeIsLastFocusable():Bool
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
				
				// On TAB, it on the last element, try to focus the next WINDOW
				// If can't focus next window, focus the first element on this window
				if (activeIsLastFocusable())
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
				callback('escape');
				
			default:
				
				if (active == null) return;
		
				if (!active.flag_lock_focus)
				{
					// [UP]/[DOWN] by default will change focus of elements
					// If it actually focused another element on the window return,
					// else pass the key to the element itself.
					if (key == "up" && focusPrev()) return;	
					if (key == "down" && focusNext(false)) return;	
				}
				
				active.onKey(key);
		}// -
		
	}//---------------------------------------------------;
	
	/**
	   Called when any child element pushes a status
	   @param	st Status Message
	   @param	el The element that fired the status
	**/
	function onElementCallback(st:String, el:BaseElement)
	{
		#if (debug)
		if(WM.flag_debug_trace_element_callbacks)
			trace('> Element Callback : From:${el.SID}, Status:$st, Data:"${el.getData()}", Owner:${el.parent.SID}');
		#end
		
		// Pipe callbacks to the global WM if set
		if (WM.onElementCallback != null) WM.onElementCallback(st, el);
		
		// Handle element special calls :
		if (st == "focus")
		{
			if (active != null) active.unfocus();
			active_last = active;
			active = el;
		}
		
		// Pipe callbacks to user
		callback(st, el);
	}//---------------------------------------------------;
	
	//====================================================;
	// GETTER, SETTERS
	//====================================================;
	
	/**
	   Sets a new window style + border included in the style object
	**/
	function set_style(val):WinStyle
	{
		if (style == val) return val;
		style = val;
		setColor(style.text, style.bg);	 // Sets window fg/bg color, some elements will read this.
		border_el.setColor(style.borderColor);
		borderStyle = style.borderStyle; // setter
		return style;
	}//---------------------------------------------------;
	
	/**
	   If borderstyle index out of bounds, it will be set to the first one
	**/
	function set_borderStyle(val):Int
	{
		if (borderStyle == val) return val;
			borderStyle = val;
	
		if (borderStyle > Styles.border.length - 1) borderStyle = 1;

		border_el.style = borderStyle;
		
		if (visible && !lockDraw)
		{
			border_el.draw();
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
	function get_inHeight()
	{
		return Std.int(height - padY - padY);
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
		
		title_el.setColor(style.titleColor);
		title_el.pos(x +  Std.int((width / 2) - (title_el.width / 2)), y);
		addChild(title_el);
		
		lockDraw = false;
		
		// Experimental :
		// Draw the top border and the title
		if (visible) 
		{
			//_readyCol();
			// NOTE: DO NOT DRAW OVER THE CORNERS!!!
			//WM.D.lineH(x + 1, y, width - 2, Styles.border[borderStyle].charAt(1));
			border_el.drawTop();
			title_el.draw();
		}
		
		return val;
	}//---------------------------------------------------;

	
	
	
}// -- end class --