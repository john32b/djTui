/********************************************************************
 * Generic Window/Panel
 * --------------------
 * - Holds and manages baseElements and derivatives
 *
 * - Callback Statuses. Place a callback listener with .listen(..);
 *
 *		escape : Esc key got pressed
 * 		focus  : An element/this Window has been focused   ; (check element.type or SID)
 * 		unfocus: An element/this Window has been unfocused ; (check element.type or SID)
 * 		fire   : A child Element was activated
 * 		change : A child Element was changed
 * 		open   : Window was just opened
 * 		close  : Window was just closed
 *
 * DEV NOTES:
 * - All child elements push callbacks to `onElementCallback()`
 * - When you listen() to a window events. ALL events will go there, including child elements and self window events.
 *
 *******************************************************************/

package djTui;
import djA.DataT;
import djTui.BaseElement;
import djTui.el.Border;
import djTui.el.Button;
import djTui.el.Label;
import djTui.Styles.WinStyle;
import haxe.Timer;

import djTui.WM.handleWindowEvents as WM_EVENTS;

class Window extends BaseElement
{
	public static var windowAnimationTick:Int = 90;

	/** Sets the window title drawn at the top. Can be changed whenever */
	public var title(default, set):String;

	// The actual Label holding the title
	var title_el:Label;

	/** This window border style index. Can be changed whenever
	 *  NOTES: - Mind the padding when setting this to and from 0
	 * 		   - Check `styles.hx` for available border styles
	 **/
	public var borderStyle(default, set):Int = 0;

	// The border element responsible for drawing the border
	var border_el:Border;

	/**
	   This window style, defaults to `WM.global_style`
	   - Apply a new style with `setStyle()`
	   - If you want to modify parts of the style call .modifyStyle(), it will apply the changes
	   - This will always be a separate copy, so you can modify it freely
	**/
	public var style(default, null):WinStyle;

	// Padding of elements from the edges
	// Applied to automatic positioning functions like addStack()
	// This is the real pad from window (0,0)
	// It is better to set padding with the padding() function
	var padX:Int = 0;
	var padY:Int = 0;

	// Requested User pad. From the border. I need to keep this
	var rPadX:Int = 0;
	var rPadY:Int = 0;

	/** Inner Width. Window width minus paddings */
	public var inWidth(get, null):Int;
	/** Inner Height. Window height minus paddings */
	public var inHeight(get, null):Int;

	// Holds all the elements that are visible inside the window
	var display_list:Array<BaseElement>;

	// Current Focused Element ( null if none )
	public var active(default, null):BaseElement;

	// Previously Focused element before current one ( null if none)
	var active_last:BaseElement;

	// Quick access to the displayList Last element
	var lastAdded:BaseElement;

	/** If true, will close this window on `Escape` key. */
	public var flag_close_on_esc:Bool = false;

	/** If true, will close this window on `BackSpace` key. */
	public var flag_close_on_bksp:Bool = false;

	/** If true, on form elements, enter will jump to the next one */
	public var flag_enter_goto_next:Bool = false;

	/** If true, when this window gets focus, will try to focus last element focused
	 *  ! Will only apply once ! So it's needed to be set every time  */
	public var flag_return_focus_once:Bool = false;

	/** If set, will always focus this element on window focus */
	public var hack_always_focus_this:String;

	//====================================================;

	/**
	   Create a Window
	   @param	sid Optional String ID. If set then this window will be stored to WM.DB for quick retrieval
	   @param	_w Window Width ( Negative integers to set to FULLWIDTH/N )
	   @param	_h Window Height ( Negative integers to set to FULLHEIGHT/N )
	   @param	_style Force a custom style to this window. WILL COPY IT
	**/
	public function new(?sid:String, ?_width:Int = 5, ?_height:Int = 5, _style:WinStyle = null)
	{
		// DEVNOTE: Don't mess with the ordering, it matters
		display_list = [];

		if (sid != null)
		{
			if (!WM.DB.exists(sid))
			{
				WM.DB.set(sid, this);
			}else
			{
				trace('WARNING: A window with sid:"$sid" already exists in WM.DB.');
			}
		}

		super(sid);

		type = ElementType.window;

		// Create a border element, even in 0 border styles. Easier to maintain.
		border_el = new Border();
		addChild(border_el);

		// DEVNOTE: Setting the style will also set the `borderStyle`
		if (_style != null)
			setStyle(_style);
		else
			setStyle(WM.global_style_win);

		size(_width, _height);
	}//---------------------------------------------------;

	/**
	   Sets a new window style + border included in the style object
	**/
	public function setStyle(val:WinStyle)
	{
		// In case this is set to re-apply changes to the same style
		if (style != val) style = DataT.copyDeep(val);
		setColor(style.text, style.bg);	 // Sets window fg/bg color, some child elements will read this directly
		border_el.setColor(style.borderColor);
		borderStyle = style.borderStyle; // Activates setter
	}//---------------------------------------------------;

	/**
	   Will modify specific fields of the style object.
	   See `Styles.WinStyle` for the fields
		e.g. window.modifyStyle( { text:"red",bg:"black"} );
	  ! Better to modify before opening a window
	   @param	o Object with field names and values conforming to `Styles.WinStyle`
	**/
	public function modStyle(o:Dynamic,forceDraw:Bool = false)
	{
		setStyle(DataT.copyFields(o, style));
		if (forceDraw) draw();
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
	   Return the element with index.
	   Note : Index 0 is always the border, so start at 1
	**/
	public function getElIndex(ind:Int):BaseElement
	{
		if (display_list.length > ind) return display_list[ind]; return null;
	}//---------------------------------------------------;


	/**
	   Override the basic `move` to also move all of the children
	   - NOTE: Does not redraw over old area
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
	   Set padding for content. Counts from the border (if any)
	   NOTE: - You can call padding(X) and it will apply padding(X,X);
			 - Call this before adding any elements to the window
	   @param	xx Sides
	   @param	yy Top/Bottom
	   @return  self for chaining.
	**/
	public function padding(xx:Int, yy:Int = -1):Window
	{
		if (yy ==-1) yy = xx;
		rPadX = xx; rPadY = yy;
		padX = xx; padY = yy;

		// All border styles have a 1 thickness, so add 1
		if (borderStyle > 0) {
			padX++; padY++;
		}
		return this;
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
				trace('WARNING: Element type: "${el.type}" with "sid:${el.SID}" width overflow.');
			}

			if (el.y + el.height > y + height) {
				trace('WARNING: Element sid:${el.SID} Y pos overflow.');
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
	   @param	align l|c|r|none (left center right, any for none)
	**/
	public function addStack(el:BaseElement, yPad:Int = 0, align:String = "l"):BaseElement
	{
		switch(align)
		{
			case "l": el.x = x + padX;
			case "r": el.x = x + width - el.width;
			case "c": el.x = x + Std.int((width / 2) - (el.width / 2));
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
	   @param   align l|c (left,center)
	**/
	public function addStackInline(el:Array<BaseElement>, yPad:Int = 0, xPad:Int = 1, align:String = "l")
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
		if (align == "c")
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
	   Set control behavior to be popup-like
	   - Close on ESC, BACKSPACE
	   - Do not leave focus
	**/
	public function setPopupBehavior()
	{
		flag_close_on_esc = true;
		flag_close_on_bksp = true;
		flag_lock_focus = true;
	}//---------------------------------------------------;

	/**
	   Add a horizontal line separator. ( A quick label element )
	   @param forceStyle Set a border style (0-6) - Default to same style as the window border
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
	   WM will try to focus the last focused window
	**/
	public function close()
	{
		if (visible == false) return;
		visible = false; //-> will trigger children

		// Will unfocus any active element
		unfocus();

		WM_EVENTS("close", this);
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
		if (WM.active != null)
		{
			WM.active.unfocus();
		}

		var st = [0.3, 0.6];
		var t = new Timer(windowAnimationTick);
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
	   Open a SubWindow as MODAL. Meaning, lockfocus the new window
	   and return focus to this window when the new window closes
	   @param w The window to open as subwindow
	   @param anim Animate the window to open
	**/
	public function openSub(w:Window, anim:Bool = false)
	{
		flag_return_focus_once = true;

		if (anim)
			w.openAnimated();
		else
			w.open(true);
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

		WM_EVENTS("focus", this); // << This will unfocus/draw other windows and draw self if needed

		lockDraw = true; // Skip drawing the whole window again
		super.focus();	 // This will push also push the 'focus' event to listeners
		lockDraw = false;
		// Focus an element
		if (display_list.length == 0) return;

			if (hack_always_focus_this!=null) {
				var e = getEl(hack_always_focus_this); if (e != null) e.focus();
				return;
			}

		if (flag_return_focus_once && active_last != null)
		{
			active_last.focus();
			flag_return_focus_once = false;
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
			if (!el.lockDraw) el.draw();
		}

	}//---------------------------------------------------;


	/**
	   The index of the selected element
	   @return
	**/
	public function getActiveIndex():Int
	{
		if (active != null)
			for (i in 0...display_list.length)
				if (display_list[i] == active) return i;
		return -1;
	}//---------------------------------------------------;



	// Focus next element, will loop through the edges
	@:allow(djTui.WM)
	@:allow(djTui.BaseElement)
	function focusNext(loop:Bool = false):Bool
	{
		return BaseElement.focusNext(display_list, active, loop);
	}//---------------------------------------------------;

	// Focus the previous element, will stop at index 0
	@:allow(djTui.WM)
	@:allow(djTui.BaseElement)
	function focusPrev():Bool
	{
		return BaseElement.focusPrev(display_list, active, false);
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

				if (WM._TAB_LEVEL == 0) return;

				if (activeIsLastFocusable())
				{
					if (flag_lock_focus)
						focusNext(true);
					else
					{
						if(WM._TAB_TYPE == "exit")
							WM_EVENTS("focus_next", this);
						else
							focusNext(true);
					}
				}
				else
				{
					focusNext(true);
				}

			case 'esc':
					// DEVNOTE: Esc FLAG is handled by the WM
					// 			It then pushes ESC here if flag is off
					callback('escape');

			default:

				if (active == null) return;

				// Do not pass cursor movement keys to locked elements (textboxes, lists)
				if (!active.flag_lock_focus)
				{
					if (key == "up" && focusPrev()) return;
					if (key == "down" && focusNext()) return;
					if (key == "home" || key == "pageup") {
						BaseElement.focusNext(display_list, null, false);
						return;
					}
					if (key == "end" || key == "pagedown") {
						BaseElement.focusPrev(display_list, null, false);
						return;
					}

				}//- end if

				if (key == 'backsp' && flag_close_on_bksp)
				{
					close();
					return;
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
	   If borderstyle index out of bounds, it will be set to the first one
	**/
	function set_borderStyle(val):Int
	{
		if (borderStyle == val) return val;
			borderStyle = val;

		if (borderStyle > Styles.border.length - 1) borderStyle = 1;	// Safeguard

		border_el.style = borderStyle;

		// DEV: The border will not get drawn at object constructor
		if (visible && !lockDraw)
		{
			border_el.draw();
			if (title_el != null) title_el.draw();
		}

		// Force the padding values to be recalculated
		padding(rPadX, rPadY);

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