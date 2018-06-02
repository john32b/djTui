
package djTui;

import djTui.ext.IInput;
import djTui.ext.ITerminal;
import djTui.Styles.WMSkin;


/**
 * Window Manager
 * --------------
 * - Holds and Manages Windows
 * - Add windows with .addWindow()
 */

class WM 
{
	
	public inline static var VERSION:String = "0.1";
	
	// A created Terminal Renderer
	public static var T:ITerminal;

	// Drawing operations objects
	public static var D:Draw;

	// A created Input Renderer
	static var I:IInput;
	
	// Current width and height of the WM
	public static var width(default, null):Int;
	public static var height(default, null):Int;
	
	// Currently Active Skin
	public static var skin:WMSkin;
	
	// Holds all the windows currently on the desktop/TUI
	static var win_list:Array<Window>;
	
	// Pointer to currently active/focused window
	static var active:Window;
	
	// Pointer to the last active window, useful to have when closing windows
	static var active_last:Window;
	
	// If true, pressing tab will switch between windows
	public static var flag_tab_switch_windows:Bool = false;
	
	//====================================================;
	
	/**
	   Create/Init the Window Manager
	   NOTE: Create the WM before creating any windows
	   @param	r
	   @param	width Max Width to utilize
	   @param	height Max Height to utilize
	**/
	public static function create(i:IInput, t:ITerminal, _w:Int = 0, _h:Int = 0)
	{
		width = _w;  height = _h;
		
		I = i;
		T = t;
		D = new Draw();
		
		if (width <= 0) width = T.MAX_WIDTH;
		if (height <= 0) height = T.MAX_HEIGHT;
		
		// TODO: What if viewport bigger than the screen?
		
		Styles.init();
		
		skin = Styles.skins[0];	// Default Skin
		
		// --
		
		I.onKey = onKey;
		I.start();
		
		// - Init and ClearBG
		closeAll();
		
		// -
		trace('== Window Manager Created =');
		trace(' - Viewport Width = $width , Height = $height');
	}//---------------------------------------------------;
	
	
	/**
	   Close all windows and redraw the bg
	**/
	public static function closeAll()
	{
		win_list = [];
		active = active_last = null;
		for (w in win_list) w.visible = false;
		clearBG();
	}//---------------------------------------------------;
	
	
	/**
		Clear the WM background
	**/
	static function clearBG()
	{
		T.reset();
		if (skin.tui_bg != null) T.bg(skin.tui_bg);
		D.rect(0, 0, width, height);
	}//---------------------------------------------------;
	
	
	/**
	   Adds a window to the display list
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
		
		trace('Adding Window UID:{w.UID}, SID:${w.SID}');
		trace(' - Size: ${w.width} | ${w.height} ');
		trace(' - Pos: ${w.x} | ${w.y} ');
		
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
		var ww:Window = from; // Temp
		
		var nextX:Int = 0; // Always start at 1
		var nextY:Int = 0; // Either 1 or next window's Y+height
		
		if (ww == null && win_list.length > 0)
		{
			ww = win_list[win_list.length - 1];
		}
		
		if (ww != null)
		{
			nextY = ww.y + ww.height;
		}
		
		var c:Int = 0;
		do {
			ww = w_arr[c];
			ww.pos(nextX, nextY);
			add(ww, false);
			nextX = ww.x + ww.width;
		}while (++c < w_arr.length);
		
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
		T.reset(); if (skin.tui_bg != null) T.bg(skin.tui_bg);
		D.rect(win.x, win.y, win.width, win.height);
		
		// If there are any windows behind it, re-draw them
		for (w in win_list)
		{
			if (w.overlapsWith(win))
			{
				w.draw();
			}
		}
		
		if (active == win) 
		{
			active = null;
			
			if (active_last != null) 
			{
				if (win.flag_is_sub) active_last.flag_once_focusLast = true;
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
	static function onKey(key:String)
	{
		if (flag_tab_switch_windows && key == "tab")
		{
			// Send tab to modal windows
			if (active != null && active.flag_focus_lock)
			{
				active.onKey('tab');
				return;
			}
			
			focusNext();
			
		}else
		
		if (active != null)
		{
			active.onKey(key);
		}
	}//---------------------------------------------------;
	
	// --
	static function onWindowCallbacks(status:String, win:Window)
	{
		switch(status)
		{
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
}//- end class-