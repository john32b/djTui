
package djTui;

import djTui.adaptors.*;
import djTui.Styles.WinStyle;
import djTui.WindowState.WindowStateManager;


/**
 * Window Manager
 * --------------
 * - Holds and Manages Windows
 * - Provides some Terminal and Input Interfaces
 * - Provides a Window State Manager
 * - AutoHolds a DataBase of created Windows
 */

class WM 
{
	public inline static var VERSION:String = "0.1";
	
	// A created Terminal Renderer
	public static var T(default, null):ITerminal;

	// Drawing operations objects
	public static var D(default, null):Draw;
	
	// Alignment functions
	public static var A(default, null):Align;

	// A created Input Renderer
	static var I(default, null):IInput;
	
	// A global statemanager
	public static var STATE(default, null):WindowStateManager;
	
	// A simple DataBase that holds ALL static windows
	public static var DB(default, null):Map<String,Window>;
	
	// Current width and height of the WM
	public static var width(default, null):Int;
	public static var height(default, null):Int;
		
	/** Holds all currently open windows */
	public static var win_list(default, null):Array<Window>;
	
	// Pointer to currently active/focused window
	static var active:Window;
	
	// Pointer to the last active window, 
	// It is used to focus the last window when a window closes
	static var active_last:Window;
	
	/// Global Styles :
	
	/** THEME for all windows. Unless overriden in window. */
	public static var global_style_win:WinStyle;
	
	/** THEME for all popups. Unless overriden in window. */
	public static var global_style_pop:WinStyle;
	
	/** You can set the Background Color of the workspace*/
	public static var backgroundColor(default, set):String = "black";
	
	/// Callbacks :
	
	/** Get ALL window element callbacks here ( not windows ) */
	public static var onElementCallback:String->BaseElement->Void = null;

	/** Get global keystrokes. */
	public static var onKey:String->Void = null;
	
	/// FLAGS :
	
	// TAB Capture Level ( 0 = none, 1 = window, 2 = WM ) */
	static var _TAB_LEVEL:Int;
	// Encoded behavior, depends on _TAB_LEVEL */
	@:allow(djTui.Window)
	static var _TAB_TYPE:String;
	
	#if debug
	/** Applies to windows. Will trace all ELEMENT callback messages (not window callbacks)*/
	public static var flag_debug_trace_element_callbacks:Bool = false;
	#end
	
	//====================================================;
	

	
	
	/**
	   Create/Init the Window Manager
	   NOTE: Create the WM before creating any windows
	   @param	i Implementation of an Input Adaptor
	   @param	t Implementation of a Terminal Adaptor
	   @param	_w Max Width to utilize
	   @param	_h Max Height to utilize
	   @param 	styleWin ID of a predefined Window Style
	   @param 	stylePop ID of a predefined Window Popup Style
	**/
	public static function create(i:IInput, t:ITerminal, _w:Int = 0, _h:Int = 0, ?styleWin:String, ?stylePop:String)
	{
		width = _w;  height = _h;
		
		I = i;
		T = t;
		D = new Draw();
		DB = new Map();
		A = new Align();
		STATE = new WindowStateManager();
		
		if (width <= 0) width = T.MAX_WIDTH;
		if (height <= 0) height = T.MAX_HEIGHT;
		
		// TODO: What if viewport bigger than the screen?
		
		Styles.init();
		
		if (styleWin == null) styleWin = "default";
		if (stylePop == null) stylePop = "default_pop";
		
		global_style_win = Reflect.copy(Styles.win.get(styleWin));
		global_style_pop = Reflect.copy(Styles.win.get(stylePop));
		
		// --
		I.onKey = _onKey;
		I.start();
		
		// - Init and ClearBG
		closeAll();
		
		set_TAB_behavior(); // default values
		
		// -
		trace('== Window Manager Created =');
		trace(' - Viewport Width = $width , Height = $height');
	}//---------------------------------------------------;
	
	/**
	   Sets a background color and resets the screen
	   Do this right after new()
	**/
	public static function set_backgroundColor(col:String)
	{
		if (col == backgroundColor) return col;
		backgroundColor = col;
		clearBG();
		return col;
	}//---------------------------------------------------;
	
	
	/**
	   Close all windows and redraw the bg
	   Note : Skips user `close` callback 
	**/
	public static function closeAll()
	{
		win_list = [];
		active = active_last = null;
		for (w in win_list) w.visible = false;
		clearBG();
		STATE.current = null;
	}//---------------------------------------------------;
	
	
	/**
		Clear the WM background
	**/
	static function clearBG()
	{
		T.reset();
		T.bg(backgroundColor);
		D.rect(0, 0, width, height);
	}//---------------------------------------------------;
	
	
	/**
	   Adds a window to the display list. 
	   Alternatively you can call window.open() or .openAnimated()
	   @param	w The window to add
	   @param	autoFocus Focus the window?
	**/
	public static function add(w:Window, autoFocus:Bool = false)
	{
		// Fix Positioning Errors
		if (w.x < 0) w.pos(0, w.y); else
		if (w.x + w.width > width) w.pos(width - w.width, w.y);
		
		if (w.y < 0) w.pos(w.x, 0); else
		if (w.y + w.height > height) w.pos(w.x, height - w.height);
		
		trace('WM -> Adding Window : UID:${w.UID}, SID:${w.SID} | Size: (${w.width},${w.height}) | Pos: ${w.x},${w.y} ');
		
		// --
		if (win_list.indexOf(w) == -1)
		{
			win_list.push(w);
			w.callback_wm = onWindowCallbacks;
		}
		
		w.visible = true; // -> will trigger all children visible
		
		// This is the first time the window is being added to the display list, so draw it.
		w.draw();
		
		if (autoFocus && w.flag_focusable) w.focus();
	}//---------------------------------------------------;
	
	
	/**
	  = Position windows to the viewport with a tiled layout 
	   - WARNING, assumes empty display list
	   - Every batch of windows are added to the same line
	   - Useful to creating multi-paneled views. e.g header/2 columns/footer
	   @param	w_arr Array of windows to add
	   @param	from If set will place the new windows BELOW this one
	   
	**/
	public static function addTiled(w_arr:Array<Window>, ?from:Window)
	{
		var nY = 0;
		if (from != null) nY = from.y + from.height;
		A.inLine(w_arr, nY);
		for ( i in w_arr) add(i);
		
		
		//var ww:Window = from; // Temp
		//var nextX:Int = 0; 
		//var nextY:Int = 0; 
		//
		//if (ww == null && win_list.length > 0)
		//{
			//ww = win_list[win_list.length - 1];
		//}
		//
		//if (ww != null)
		//{
			//nextY = ww.y + ww.height;
		//}
		//
		//var c:Int = 0;
		//do {
			//ww = w_arr[c];
			//ww.pos(nextX, nextY);
			//add(ww, false);
			//nextX = ww.x + ww.width;
		//}while (++c < w_arr.length);
		
	}//---------------------------------------------------;
		
	//====================================================;
	// INTERNAL 
	//====================================================;
	
	/**
	   Focus Next Window on the list ( if any )
	**/
	static function focusNext()
	{
		BaseElement.focusNext(cast win_list, cast active);
	}//---------------------------------------------------;
	
	
	/**
	   - USER should call window.close()
	   - Remove a window from the list
	   - Redraw any windows behind it
	   - Focuses previously focused window
	   @param	w The Window to remove
	**/
	static function closeWindow(win:Window)
	{
		win_list.remove(win);
		
		// Draw a <black> hole where the window was
		T.reset(); T.bg(backgroundColor);
		D.rect(win.x, win.y, win.width, win.height);
		
		// If there are any windows behind it, re-draw them
		for (w in win_list)
		{
			if (w.overlapsWith(win))
			{
				w.draw();
			}
		}
		// If closing active window, focus last one
		if (active == win) 
		{
			active = null;
			
			if (active_last != null && active_last.visible == true) 
			{
				active_last.focus();
			}
		}
		
	}//---------------------------------------------------;
	
	static function windowOverlapsWithAny(win:Window)
	{
		for (w in win_list) 
		{
			if (win == w) continue;
			if (win.overlapsWith(w)) return true;
		}
		return false;
	}//---------------------------------------------------;
	
	
	//====================================================;
	// EVENTS 
	//====================================================;
	// --
	static function _onKey(key:String)
	{
		if (_TAB_LEVEL == 2 && key == "tab")
		{
			// If a window is already locked, don't switch windows
			// just send 'tab' to that window
			if (active != null && active.flag_focus_lock)
			{
				active.onKey('tab');
				return;
			}
			
			if (active != null && _TAB_TYPE == "keep")
			{
				active.flag_return_focus_once = true;
			}
			
			focusNext();
			
		}else
		
		if (active != null)
		{
			active.onKey(key);
		}
		
		// Push to user
		if (onKey!=null) onKey(key);
	}//---------------------------------------------------;
	
	// --
	// Callbacks Windows will push specifically to the WM
	static function onWindowCallbacks(status:String, win:Window)
	{
		switch(status) {
				
			case "focus":
				if (active == win) return;
				if (active != null) active.unfocus();
				active_last = active;
				active = win;
				if (windowOverlapsWithAny(win)) win.draw();
				
			case "focus_next":
				// - Requested to focus next window, because a window reached the end
				// - If there are no more windows left, focus the same one again
				if (!BaseElement.focusNext(cast win_list, cast active))
				{
					win.focusNext();
				}
				
			case "close":
				closeWindow(win);
				
			default:
		}
		
	}//---------------------------------------------------;
	
	
	/**
	   Declare how the Window/Element focus will behave upon [TAB] key. Along with some optional parameters.
	   I am offering this because some application setups require different approaches to UI.
	   
	   @param	level   Where the focus of the [TAB] key should reach | NONE, WM, WINDOW
	   @param	param   WM 	   :  "keep" , remember active element on windows when switching back to them
						WINDOW :  "exit" , exit focus from the window to the next available window ( instead of looping )
	**/
	public static function set_TAB_behavior(level:String = "WINDOW", param:String = "")
	{
		_TAB_TYPE = param;
		_TAB_LEVEL = ["NONE", "WM", "WINDOW"].indexOf(level);
		if (_TAB_LEVEL < 0) {
				throw "set_TAB_behavior invalid level ID";
		}
	}//---------------------------------------------------;
}//- end class-