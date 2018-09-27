/** 
 * Base Element
 * ------------------------
 * - Some shared functionality for Windows and Elements
 * 
 *****************************************************/

package djTui;

import djTui.WM;

/**
  Generic displayable/focusable element
  
   - You should set an SID for elements if you want to interact with them
   - If you skip SID it will be autogenerated
 
**/
class BaseElement
{
	// Global UID generator index
	static var UID_GEN:Int = 1;
	
	// General use UniqueIDs
	public var SID:String;
	// This is autogenerated and always unique
	public var UID(default, null):Int;
	// Extended class can set a custom type here for quick retrieval
	public var type:ElementType;
	
	public var x:Int = 0;
	public var y:Int = 0;
	
	public var width:Int = 0;	
	public var height:Int = 0;
	
	// General Use color holders
	// Usually used for current color for printing
	var colorFG:String;	
	var colorBG:String; // The color the background will be filled with
	
	/** Is this element currenty visible/onscreen */
	public var visible(default, set):Bool;
	
	/** Is this element currently focused */
	public var isFocused(default, null):Bool = false;
	
	/** Pushes generic status messages. Is an <Array> so that it can have many listeners
	    - ACCESS with listen(..) */
	var callbacks:Array<String->BaseElement->Void>;
	
	/** All elements have a parent container ( a window ) */
	public var parent(default, null):Window = null;
	
	// Used in cases where you need to skip draw calls
	// - It's a short term flag, so set on/off inside a single function scope only
	var lockDraw:Bool = false;
	
	/// FLAGS ::
	
	/** If false then the element cannot be focused*/
	public var flag_focusable:Bool = true;
	
	// Some Elements like the VLIST and TEXTBOX, handle leaving focus themselves
	@:allow(djTui.Window)
	var flag_lock_focus:Bool = false;
	
	//====================================================;
	
	public function new(?sid:String)
	{
		UID = UID_GEN++;
		SID = sid;
		callbacks = [];
		visible = false;	// everything starts as `not visible` until added to a window/WM
		if (SID == null || SID == "") SID = 'id_$UID';
	}//---------------------------------------------------;
	
	
	// Move Relative
	public function move(dx:Int, dy:Int):BaseElement
	{
		x += dx;
		y += dy;
		return this;
	}//---------------------------------------------------;
	
	// Move Absolute
	public function pos(_x:Int, _y:Int):BaseElement
	{
		move(_x - x, _y - y); // This is to trigger the move() on `Window.hx`
		return this;
	}//---------------------------------------------------;
	
	// Place next to another element
	public function posNext(el:BaseElement, pad:Int = 0):BaseElement
	{
		pos(el.x + el.width + pad , el.y);
		return this;
	}//---------------------------------------------------;
	
	
	/** Set the general use colors for printing.
	    if BG null then it will be the window color 
		- Not guaranteed to work on ALL Menu Items
		- You can either set a ColorPair or ColorString, not both
	*/
	public function setColor(?pair:Styles.PrintColor, ?fg:String, ?bg:String):BaseElement
	{
		if (pair != null) 
		{
			colorFG = pair.fg;
			colorBG = pair.bg;
		}else
		{
			colorFG = fg;
			colorBG = bg;
		}
		if (colorBG == null && parent != null) colorBG = parent.colorBG;
		return this;
	}//---------------------------------------------------;
	
	// An element may be resized upon being added on a Window
	// So override to initialize further sizing
	public function size(_w:Int, _h:Int):BaseElement
	{ 
		width = _w; height = _h;
		return this;
	}//---------------------------------------------------;
	
	// --
	public function focus()
	{
		if (isFocused || !flag_focusable) return;
		isFocused = true;
		focusSetup(isFocused);
		callback('focus');
		draw(); 
	}//---------------------------------------------------;
	
	// --
	public function unfocus()
	{
		if (!isFocused) return;
		isFocused = false;
		focusSetup(isFocused);
		callback('unfocus');
		draw();
	}//---------------------------------------------------;
	
	/**
	   Pushes a callback listener. It will fire on various events
	   @param	fn function( message , Element that sent the message )
	**/
	public function listen(fn:String->BaseElement->Void)
	{
		callbacks.push(fn);
	}//---------------------------------------------------;
	
	/**
	   Fire a message to all listeners
	**/
	function callback(msg:String, caller:BaseElement = null)
	{
		if (caller == null) caller = this;
		for (i in callbacks) i(msg, caller);
	}//---------------------------------------------------;
	
	
	/**
	   @virtual
	   Element was just added on a window
	**/
	@:allow(djTui.Window)
	function onAdded():Void {}
	
	/**
	   @virtual
	   A key was pushed to current element
	   See `interface IInput` for keycode IDs
	**/
	@:allow(djTui.Window)
	function onKey(k:String):Void {}
	
	/**
	   @virtual 
	   Called every time the focus changes
	   Handles focus colors etc
	**/
	function focusSetup(focus:Bool):Void {}
	
	/**
	   @virtual
	   Called whenever the element needs to be drawn
	**/
	dynamic public function draw():Void {}
	
	
	/** Will clear the entire element with the window background color 
	 */
	public function clear():Void
	{
		if (!lockDraw) 
		{
			WM.T.reset().bg(parent.colorBG);
			WM.D.rect(x, y, width, height);
		}
	}//---------------------------------------------------;
	
	// Might be useful
	public function overlapsWith(el:BaseElement):Bool
	{
		return 	(x + width > el.x) &&
				(x < el.x + el.width) &&
				(y + height > el.y) &&
				(y < el.y + el.height); 
	}//---------------------------------------------------;
	
	// Helper, quickly set drawing colors 
	inline function _readyCol()
	{
		WM.T.reset().fg(colorFG).bg(colorBG);
	}//---------------------------------------------------;
	
	//====================================================;
	// DATA, SETTERS, GETTERS
	//====================================================;
	
	function set_visible(val)
	{	
		return visible = val;	
	}//---------------------------------------------------;
	
	// For debugging
	public function toString()
	{
		return
		Type.getClassName(Type.getClass(this)) + 
		': SID:$SID, UID:$UID, pos($x,$y), size($width,$height)';
	}//---------------------------------------------------;
	
	// @ virtual
	public function setData(val:Any) {}
	
	// @ virtual
	public function getData():Any { return null; }
	
	// @ virtual
	// Reset data to default value
	public function reset() {}
	
	//====================================================;
	// STATICS 
	//====================================================;
	
	/**
	   Focuses the next element from <active> in <array>. If <loop> is true, will loop through
	   the end until it reaches <active> again.
	   If <active> is `null` it will search from the top
	   NOTE: This is a generic static because it's being used by the WM to switch windows
	         and by Windows to switch elements.
	   @param	ar Array of BaseElements
	   @param	act Active Element, If Null will search from the beginning
	   @param	loop If true will loop at the end once
	   @return Did it actually focus anything new
	**/
	static public function focusNext(ar:Array<BaseElement>, act:BaseElement, loop:Bool = true):Bool
	{
		if (ar.length == 0) return false;
		
		var ia = ar.indexOf(act);
		
		var j = ia; // counter
		while (true)
		{
			j++;
			if (j >= ar.length)
			{
				// Looped from 0 to end, so no elements found:
				if (ia ==-1) return false;
				
				if (loop)
				{
					// Proceed looping normally:
					j = 0;
				}else
				{
					return false;
				}
			}
			
			if (j == ia) return false; // Nothing found
			if (ar[j].flag_focusable && ar[j].visible) break;
		}//-
		
		ar[j].focus();
		return true;
	}//---------------------------------------------------;
	
	
}//-- end BaseDrawable