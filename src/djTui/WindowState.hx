package djTui;
import sys.db.Types.SId;

/**
 * A state is a collection of windows
 * 
 * - Open/Close all windows in the state
 * - Can be dynamically created or extended
 * 
 */
@:allow(djTui.WindowStateManager)
class WindowState 
{
	// Holds all the windows of the state.
	var list:Array<Window>;
	
	// A unique identifier/name
	public var SID(default, null):String;
	
	// If set, whenever the [ESC] key is pressed, this state will exit and call [onEscGoto] State
	// #USER SET
	public var onEscGoto:String;
	
	// If set will change the WM background to this color when this state is called
	public var bgColor:String;
	var lastBgColor:String;
	
	/**
	   Create a Window State
	   @param	name Unique Name
	   @param	windows
	**/
	public function new(?sid:String, ?windows:Array<Window>)
	{
		SID = sid;
		if (windows != null) list = windows; else list = [];
	}

	/** Add a window to state
	 */
	public function add(win:Window):Window
	{
		list.push(win);
		return win;
	}
	
	public function addM(wins:Array<Window>)
	{
		for (w in wins) add(w);
	}
	
	/**
	   Search for a window with target SID
	   Note: This is to be used in dynamic states. To quickly get a window
	**/
	public function get(s:String):Window
	{
		for (w in list) if (w.SID == s) return w;
		return null;
	}
	
	/**
	   Close all windows
	**/
	public function close()
	{
		for (w in list) w.close();
		if (lastBgColor != null)
		{
			WM.backgroundColor = lastBgColor;
			lastBgColor = null;
		}
	}
	
	/**
	   Opens all windows and focuses the first window on the list
	   @param data Optional, Handled at extended classes
	**/
	public function open(?data:Dynamic)
	{
		if (bgColor != null) {
			lastBgColor = WM.backgroundColor; 
			WM.backgroundColor = bgColor;
		}
		for (w in list) w.open();
		// Focus first focusable Window
		BaseElement.focusNext(cast list, null);
	}
	
}//---------------------------------------------------;



/**
	WindowState Manager 
	@singleton Accessible from `WM.STATES`
   - Stores and Manages WindowStates
   - Handles switching in and out of WindowStates
   - Will only allow ONE windowstate to be opened at each time
   - Provides some basic callbacks for `onOpen` and `onClose`
**/
@:allow(djTui.WM)
class WindowStateManager
{
	// A pool where it can store states
	var states:Map<String,WindowState>;
	
	/** The currently active state, null for none */
	public var current(default, null):WindowState;

	// --
	public function new()
	{
		clear();
	}//---------------------------------------------------;
	
	/** Store a state for quick retrieval
	 **/
	public function store(w:WindowState):Void
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
	   Create and Append a Window State on the fly.
	   Also return it to user.
	   @param	name The SID of the window state
	   @param	winList Window List. The windows can exist in multiple states
	**/
	public function create(name:String, winList:Array<Window>):WindowState
	{
		var s = new WindowState(name, winList);
			store(s);
			return s;
	}//---------------------------------------------------;
	
	/** Close current state (if any)
	 */
	public function close():Void
	{
		if (current != null)
		{
			current.close();
			onStateClose(current);
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
		
		open(b);
	}//---------------------------------------------------;
	
	/**
	   Open a WindowState Object
	   If you want to open a previously stored state. call `goto()`
	**/
	public function open(st:WindowState)
	{
		close();
		onStateOpen(st);
		st.open();
		current = st;
	}//---------------------------------------------------;
	
	
	/**
	   Called automatically, just before opening a Window State
	   Provided for user customization. e.g. Window positions
	   @param	st The state opened
	*/
	dynamic public function onStateOpen(st:WindowState)
	{
	}//---------------------------------------------------;
		
	/**
	   Called automatically, just before closing a Window State
	   Provided for user customization. e.g. Window positions
	   @param	st The state closing
	*/
	dynamic public function onStateClose(st:WindowState)
	{
	}//---------------------------------------------------;
	
	/**
	   Clears all states from the pool, does not clear any windows
	**/
	public function clear()
	{
		states = new Map();
		current = null;
	}//---------------------------------------------------;
	
	/**
	   Handles ESC key, Returns True if handled
	   @return
	**/
	public function handleESC():Bool
	{
		if (current != null && current.onEscGoto != null)
		{
			goto(current.onEscGoto);
			return true;
		}
		return false;
	}//---------------------------------------------------;
	
	
}//--