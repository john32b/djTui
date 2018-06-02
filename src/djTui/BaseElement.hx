/** 
 * Base Element
 * ------------------------
 * - Some shared functionality for Windows and Elements
 * 
 * @Author: johndimi <johndimi@outlook.com> @jondimi
 * 
 *****************************************************/

package djTui;

import djTui.WM;


class BaseElement
{
	static var UID_GEN:Int = 1;
	
	// General use UniqueIDs
	public var SID:String;
	public var UID(default, null):Int;
	public var type:ElementType;
	
	public var x:Int = 0;
	public var y:Int = 0;
	
	public var width:Int = 0;	
	public var height:Int = 0;
	
	// General Use color holders
	public var colorFG:String;
	public var colorBG:String;
		
	// Is it currently visible/onscreen
	public var visible(default, set):Bool;
	
	public var isFocused(default, null):Bool = false;
	
	// Push generic status messages
	// ! USER should not read this on elements ( it is managed by a window )
	public var callbacks:String->BaseElement->Void; 
	
	// Must be added to a window
	var parent:Window = null;
	
	// If true will skip draw calls
	// NOTE : Parent checks this, so don't worry about it
	var lockDraw:Bool = false;
	
	// == FLAGS ==
	
	// If false then the element cannot be focused and will be skipped
	public var flag_focusable:Bool = true;
	
	//====================================================;
	
	public function new(?sid:String)
	{
		UID = UID_GEN++;
		SID = sid;
		visible = false;	// everything starts as `not visible` until added to a window/WM
		if (SID == null) SID = 'id_$UID';
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
		if (colorBG == null && parent != null) colorBG = parent.colorBG;
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
		callbacks('focus', this);
		isFocused = true;
		focusSetup(isFocused);
		draw(); 
	}//---------------------------------------------------;
	
	// --
	public function unfocus()
	{
		if (!isFocused) return;
		isFocused = false;
		focusSetup(isFocused);
		draw();
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
	   ~ be sure to check for 'lockDraw` on the implementation
	**/
	public function draw():Void {}
	
	// Might be useful
	public function overlapsWith(el:BaseElement):Bool
	{
		return 	(x + width > el.x) &&
				(x < el.x + el.width) &&
				(y + height > el.y) &&
				(y < el.y + el.height); 
	}//---------------------------------------------------;
	
	// Shorthand function, quickly reset and set colors
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
		' - UID:$UID, x:$x, y:$y, width:$width, height:$height';
	}//---------------------------------------------------;
	
	// @ virtual
	public function setData(val:Any) {}
	
	// @ virtual
	public function getData():Any { return null; }
	
	// @ virtual
	public function reset() {}
	
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
			if (ar[j].flag_focusable && ar[j].visible) break;
		}//-
		
		ar[j].focus();
		return true;
	}//---------------------------------------------------;
	
	
}//-- end BaseDrawable