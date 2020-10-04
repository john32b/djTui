/********************************************************************
 * WINDOW MANAGER
 * ---------------
 * - Holds and Manages Windows
 * - Provides some Terminal and Input Interfaces
 * - Provides a Window State Manager
 * - AutoHolds a DataBase of created Windows
 *
 *
 *******************************************************************/
package djTui;

import djA.DataT;
import djTui.ElementType;
import djTui.Window;
import djTui.adaptors.IInput;
import djTui.adaptors.ITerminal;
import djTui.Styles.WinStyle;
import djTui.WindowState.WindowStateManager;
import djTui.win.MessageBox;


class WM
{
	public inline static var NAME 	 = "djTui";
	public inline static var VERSION = "0.2";

	// A  Terminal Renderer
	public static var T(default, null):ITerminal;

	// Drawing operations objects
	public static var D(default, null):Draw;

	// Alignment functions
	public static var A(default, null):Align;

	// A Input Renderer
	static var I(default, null):IInput;

	// A simple DataBase that holds ALL static windows
	// - All created windows that are given an SID are automatically added here
	// - Main use to avoid declaring many global window variables
	// - A nice way to use this is to make a shortcut "import djTui.WM.DB as DB;" at the start of your file
	//   and then access windows with `DB['winList']`
	public static var DB(default, null):Map<String,Window>;

	// A global statemanager
	public static var STATE(default, null):WindowStateManager;

	// Current width and height of the WM
	public static var width(default, null):Int;
	public static var height(default, null):Int;

	/** Holds all currently open windows */
	public static var win_list(default, null):Array<Window>;

	// Pointer to currently active/focused window
	public static var active:Window;

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

	/** USER - Will push all window element callbacks ( not the actual window elements ) */
	public static var onElementCallback:String->BaseElement->Void = null;

	/** USER - Will push everytime a window gets focused. */
	public static var onWindowFocus:Window->Void = null;

	/** User handle keystrokes. Processed first,
	 *  Keys can transform so you can cancel it if you want be returning null */
	public static var onKey:String->String = null;

	/// Internal :

	// If there is an active modal/popup. Else null.
	static var activeModal:Window;

	/// FLAGS :

	#if debug
	/** Applies to windows. Will trace all ELEMENT callback messages (not window callbacks)*/
	public static var flag_debug_trace_element_callbacks:Bool = false;
	#end

	// Is the WM created with no problems
	public static var _isInited(default, null):Bool = false;
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

		if (styleWin == null) styleWin = Styles.DEF_STYLE_WIN;
		if (stylePop == null) stylePop = Styles.DEF_STYLE_POP;

		global_style_win = DataT.copyDeep(Styles.win.get(styleWin));
		global_style_pop = DataT.copyDeep(Styles.win.get(stylePop));

		// --
		I.onKey = _onKey;
		I.start();

		// - Init and ClearBG
		closeAll();

		_isInited = true;

		// -
		trace('== Window Manager Created =');
		trace(' - Viewport Width = $width , Height = $height');
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
	   Adds a window to the display list.
	   Alternatively you can call window.open()
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

		 //trace('WM -> Adding Window : UID:${w.UID}, SID:${w.SID} | Size: (${w.width},${w.height}) | Pos: ${w.x},${w.y} ');

		// --
		if (win_list.indexOf(w) == -1)
		{
			win_list.push(w);
		}

		w.visible = true; // -> will trigger all children visible

		// This is the first time the window is being added to the display list, so draw it.
		w.draw();

		if (autoFocus && w.focusable) w.focus();
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
	}//---------------------------------------------------;



	/**
	   Clear all the stored windows. Does not actually destroy the windows
	   DEV: Remember windows are auto-added here when they are created with an SID set
	**/
	public static function clearDB()
	{
		DB = new Map();
	}//---------------------------------------------------;

	//====================================================;
	// INTERNAL
	//====================================================;

	/**
	   Focus Next Window on the list ( if any )
	**/
	static function focusNext():Bool
	{
		if (active == null) return false;
		return BaseElement.focusNext(cast win_list, cast active);
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

	/**
		Clear the WM background
	**/
	static function clearBG()
	{
		T.reset();
		T.bg(backgroundColor);
		D.rect(0, 0, width, height);
	}//---------------------------------------------------;


	//====================================================;
	// MISC
	//====================================================;

	/**
	   Show a YES/NO popup as a modal under current active window. Callbacks the result.
	   @param	callback. Will call this if selected YES
	   @param	Q Custom Question. Default for "Are you Sure"
	   @param	pos [x,y], Null for center
	**/
	public static function popupConfirm(callback:Void->Void, ?Q:String, ?pos:Array<Int>):MessageBox
	{
		var m = new MessageBox(Q, 2, (res)->{
			if (res == 0) callback();
		});

		m.flag_close_on_esc = true;

		if (pos == null)
			A.screen(m);
		else
			m.pos(pos[0], pos[1]);

		if (active != null)
			active.openSub(m, true);
		else
			m.open(true, true);

		return m;
	}//---------------------------------------------------;


	//====================================================;
	// EVENTS
	//====================================================;
	// --

	// - Called by the KeyManager, pushes keystrokes
	// - Sends key to User, then Active Window, then Handles it
	static function _onKey(key:String)
	{
		// Push to user
		if (onKey != null) key = onKey(key);

		// Push to active window
		if (active != null)
		{
			key = active.onKey(key);
		}

		// DEV: Any key that is passed through here, means it was not handled or blocked by any element or window
		//		So, for TAB I will just focus the next window. If a window did not like that to happen, it would
		//		not pass the "tab" key, it would block it. Same thing for "esc"

		if (key == "tab")
		{
			focusNext();

		}else if (key == "esc")
		{
			STATE.handleESC();
		}

		// [X] flag_return_focus_once ?? handles by the window itself
		// [X] focus next window on tab ??

	}//---------------------------------------------------;

	// --
	// Special Events from Windows
	@:allow(djTui.Window)
	static function _onWindowEvent(status:String, win:Window)
	{
		switch(status) {

			case "focus":
				//- Ready the window
				//- Redraw it if it was to, in case it was hidden by other windows
				//- User callback
				if (active == win) return;
				if (active != null) active.unfocus();
				active_last = active;
				active = win;
				if (windowOverlapsWithAny(win)) win.draw();
				if (onWindowFocus != null) onWindowFocus(win);

			case "close":
				//- Remove the window from the list
				//- Redraw any windows behind it
				//- Focuses previously focused window
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

			default:
		}

	}//---------------------------------------------------;

	//====================================================;
	// GET-SET
	//====================================================;

	// Sets a background color and resets the screen
	// Do this right after new()
	public static function set_backgroundColor(col:String)
	{
		if (col == backgroundColor) return col;
		backgroundColor = col;
		clearBG();
		for (i in win_list) i.draw();
		return col;
	}//---------------------------------------------------;
}//- end class-