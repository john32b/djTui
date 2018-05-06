
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
	
	// Pointer to the last active window
	static var active_last:Window;
	
	// Pointer to currently active/focused window
	static var active:Window;
	
	
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
		
		win_list = [];
		
		I.onKey = onKey;
		I.start();
		
		// --
		
		if (skin.tui_bg != null)
		{
			T.bg(skin.tui_bg);
			D.rect(0, 0, width, height);
		}
	}//---------------------------------------------------;
	
	
	
	public static function addWindow(w:Window, autoFocus:Dynamic = true)
	{
		trace('Added Window UID:{w.UID}');
		win_list.push(w);
		w.callback_wm = onWindowCallbacks;
		
		w.isOpen = true;
		
		if (autoFocus) w.focus(); else w.draw();
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
	
	
	static function onWindowCallbacks(status:String, win:Window)
	{
		switch(status)
		{
			case "focus":
				if (active == win) return;
				if (active != null) active.unfocus();
				active_last = active;
				active = win;
				
			case "focus_next":
				// - Requested to focus next window, because a window reached the end
				//   if its scroll list
				// - If there are no more windows left, focus the same one again
				if (!BaseElement.focusNext(cast win_list, cast active))
				{
					win.focusNext();
				}
				
			case "open":
				
			case "close":
			
			default:
		}
	}//---------------------------------------------------;
}//- end class-