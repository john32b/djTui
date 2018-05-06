/** 
 * Base Element
 * ------------------------
 * Base class for all TUI Elements, windows and such
 * ------------------------
 * @Author: johndimi <johndimi@outlook.com> @jondimi
 * 
 *****************************************************/

package djTui;

import djTui.WM;


class BaseElement
{
	static var UID_GEN:Int = 1;
	
	// General use UniqueIDs
	// public var SID:String; // Don't need it
	public var UID(default, null):Int;
	
	public var x:Int = 0;
	public var y:Int = 0;
	
	public var width:Int = 0;	
	public var height:Int = 0;
	
	// General Use color holders
	public var colorFG:String;
	public var colorBG:String;
		
	public var isFocused(default, null):Bool = false;
	
	// public var type:String;	// e.g. label, oneof, etc.
	
	// Status callbacks
	// focus
	@:allow(djTui.Window)
	var callbacks:String->BaseElement->Void; // ~ Always Set, don't check for null ~ //
	
	// --
	// Can be added to a window
	var parent:Window = null;
	
	// If true will skip draw calls
	// devnote: Parent checks this, so don't worry about it
	@:allow(djTui.Window)
	var lockDraw:Bool = false;
	
	// --
	// @userset
	public var flag_can_focus:Bool = true;
	
	//====================================================;
	
	public function new()
	{
		UID = UID_GEN++;
	}//---------------------------------------------------;
	
	// Move Relative
	public function move(dx:Int, dy:Int):BaseElement
	{
		pos(x + dx, y + dy);
		return this;
	}//---------------------------------------------------;
	
	// Move Absolute
	public function pos(_x:Int, _y:Int):BaseElement
	{
		x = _x; y = _y;
		return this;
	}//---------------------------------------------------;
	
	// Place next to another element
	public function posNext(el:BaseElement, pad:Int = 0):BaseElement
	{
		x = el.x + el.width + pad;
		y = el.y;
		return this;
	}//---------------------------------------------------;
	
	// Set the general use colors
	// They are used by some extends
	public function setColors(fg:String, ?bg:String)
	{
		colorFG = fg;
		colorBG = bg;
		//
		if (colorBG == null && parent != null) colorBG = parent.colorBG;
	}//---------------------------------------------------;
	
	// An element may be resized upon being added on a Window
	// So override to initialize further sizing
	public function size(_w:Int, _h:Int):BaseElement
	{ 
		width = _w; height = _h;
		return this;
	}//---------------------------------------------------;
	
	
	public function focus()
	{
		if (isFocused || !flag_can_focus) return;
		callbacks('focus', this);
		isFocused = true;
		onFocusChange();
		draw(); 
	}//---------------------------------------------------;
	
	
	public function unfocus()
	{
		if (!isFocused) return;
		isFocused = false;
		onFocusChange();
		draw();
	}//---------------------------------------------------;
	
	/**
	   @virtual
	   Element was added on a window, so initialize it
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
	   @ALSO called at initialization to setup the initial colors for elements
	         that support focus/unfocus
	**/
	function onFocusChange():Void {}
	
	/**
	   @virtual
	   Called whenever the element needs to be drawn
	   ~ be sure to check for 'lockDraw` on the implementation
	**/
	public function draw():Void {}
	
	
	public function overlapsWith(el:BaseElement):Bool
	{
		return 	(x + width > el.x) &&
				(x < el.x + el.width) &&
				(y + height > el.y) &&
				(y < el.y + el.height); 
	}//---------------------------------------------------;
	
	inline function _readyCol()
	{
		WM.T.reset().fg(colorFG).bg(colorBG);
	}//---------------------------------------------------;
	
	
	//====================================================;
	// STATICS 
	//====================================================;

	
	// Automatically focuses the next element in <ar> next from <active>
	// Loops through the end until it reaches <active> again
	// <active> can be null and it will search from the top
	// @returns: Did it actually focus anything new
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
			if (ar[j].flag_can_focus) break;
		}//-
		
		ar[j].focus();
		return true;
	}//---------------------------------------------------;
	
	public function toString()
	{
		return
		Type.getClassName(Type.getClass(this)) + 
		' - UID:$UID, x:$x, y:$y, width:$width, height:$height';
	}
	
}//-- end BaseDrawable