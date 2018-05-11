
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
	public static function add(w:Window, autoFocus:Dynamic)
	{
		trace('Adding Window UID:{w.UID}, SID:${w.SID}');
		
		if (win_list.indexOf(w) == -1)
		{
			win_list.push(w);
			w.callback_wm = onWindowCallbacks;
		}
		
		w.visible = true; // -> will trigger all children visible
		
		// This is the first time the window is being added to the display list, so draw it.
		w.draw();
		
		if (autoFocus && w.flag_can_focus) w.focus();
	}//---------------------------------------------------;
	
	
	/**
	   Adds these windows right below to the previous one 
	   Useful to creating multi-paneled views. e.g header/2 columns/footer
	   NOTE: 	Auto resizes windows to <width>.
				leaves <height> intact
	   @param	w Array of windows to add
	**/
	public static function addTiled(w:Array<Window>)
	{
		var lastw = win_list[win_list.length - 1];
		// ---
		//----->>>> TODO
	}//---------------------------------------------------;
	
	
	
	/**
	   Centers a window to the screen/viewport
	**/
	public static function center(w:Window)
	{
		w.x = Std.int(width / 2 - w.width / 2);
		w.y = Std.int(height / 2 - w.height / 2);
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