package djTui;
import sys.db.Types.SId;

/**
 * A state is a collection of windows
 * 
 * - All windows can quickly open/close
 * - A global WindowState Manager is provided through the WM.BANK object
 * 
 */
@:allow(djTui.WindowStateManager)
class WindowState 
{
	// Holds all the windows of the state.
	var list:Array<Window>;
	
	// A unique identifier/name
	public var SID(default, null):String;
	
	/**
	   Create a Window State
	   @param	name Unique Name
	   @param	windows
	**/
	public function new(sid:String, ?windows:Array<Window>)
	{
		SID = sid;
		if (windows != null) list = windows; else list = [];
	}

	/** Add a window to state
	 */
	public function add(win:Window)
	{
		list.push(win);
	}
	
	/**
	   Search for a window with target SID
	**/
	public function get(s:String):Window
	{
		for (w in list) if (w.SID == s) return w;
		return null;
	}
	
	/**
	   Close all windows
	**/
	function close()
	{
		for (w in list) w.close();
	}
	
	/**
	   Opens all windows and focuses the first window on the list
	   -- Will autofocus the first window --
	   @param data Optional, Handled at extended classes
	**/
	function open(?data:Dynamic)
	{
		for (w in list) w.open();
		list[0].focus();
	}
	
}//---------------------------------------------------;



/**
   @singleton Access it with "WM.BANK"
   - Stores WindowStates
   - Handles switching in and out of WindowStates
**/
@:allow(djTui.WM)
class WindowStateManager
{
	// All states
	var states:Map<String,WindowState>;
	
	public var current(default, null):WindowState;

	// --
	public function new()
	{
		clear();
	}//---------------------------------------------------;
	
	/** Add a Window State to hold
	 */
	public function add(w:WindowState):Void
	{
		if (states.exists(w.SID))
		{
			trace('ERROR: Window State "${w.SID}" already exists');
			return;
		}
		
		#if debug
		if (w.list.length == 0)
		{
			trace('ERROR: Window State "${w.SID}" contains no windows');
			return;
		}
		#end
		
		states.set(w.SID, w);
	}//---------------------------------------------------;
	
	/**
	   Create and Append a Window State on the fly
	   Also return it to user.
	   @param	name The SID of the window state
	   @param	winList Window List. The windows can exist in multiple states
	**/
	public function create(name:String, winList:Array<Window>):WindowState
	{
		var s = new WindowState(name, winList);
			add(s);
			return s;
	}//---------------------------------------------------;
	
	/** Close current state (if any)
	 */
	public function close():Void
	{
		if (current != null)
		{
			current.close();
			current = null;
		}
	}//---------------------------------------------------;
	
	/**
	   Goto a State, Closes current state
	   @param stateSID the SID of a state to open
	   @param data Optional object to 
	**/
	public function goto(stateSID:String, ?data:Dynamic):Void
	{
		// Find state in stored states
		var b = states.get(stateSID);
		
		if (b == null)
		{
			trace('ERROR: Window State with SID "${stateSID}" does not exist');
			return;
		}
		
		close();
		onStateOpen(b);
		b.open();
		current = b;
	}//---------------------------------------------------;
	
	
	/**
	   Called automatically, just before opening the State Windows.
	   Provided for user customization. e.g. Window positions
	   @param	st The state opened
	*/
	dynamic public function onStateOpen(st:WindowState)
	{
	}//---------------------------------------------------;
	
	
	/**
	   Clears all states, does not clear any windows
	**/
	public function clear()
	{
		states = new Map();
		current = null;
	}//---------------------------------------------------;
	
	
}//--