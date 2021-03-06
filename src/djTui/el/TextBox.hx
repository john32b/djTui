/********************************************************************
 * A TEXTBOX that display lines of text
 *
 * - Scrollable, with an automatic scrollbar
 * - You can set 'color_scrollbar_focus' and 'color_scrollbar_idle' to customize scrollbar
 * - Use `setData()` to set the text
 *
 * DEV NOTE:
 * - If height==0 it will be autocalculated on first data set
 *******************************************************************/

package djTui.el;

import djA.StrT;
import djTui.BaseElement;
import djTui.Styles.PrintColor;
import haxe.ds.Either;

class TextBox extends BaseElement
{
	// Holds the Final Rendered Strings
	var lines:Array<String>;

	// Current scroll multiplier (0 ... 1)
	public var scroll_ratio(default, null):Float;

	// From what index to start displaying lines
	// You can just adjust this whenever and the scroll will be adjusted automatically
	var scroll_offset(default, set):Int;

	// Autocalculated, the index the textbox can scroll to
	var scroll_max:Int;

	// How many slots to display lines
	var slots_count:Int;

	// Will be added to the parent window automatically
	var scrollbar:ScrollBar;

	// Used in cases where a scrollbar is needed but element is not yet added to a window
	var flag_add_scrollbar:Bool = false;

	/** Hide the scrollbar on unfocus. FALSE to always show. TRUE to show when focused. */
	public var flag_scrollbar_autohide:Bool = true;

	/** Are there any lines */
	public var flag_empty(default, null):Bool;

	/** How many lines */
	public var linesCount(get, null):Int;
	
	/** This textbox just scrolled */
	public var onScroll:TextBox->Void;


	/**
	   Create a new TextBox
	   @param	_width Width of the lines
	   @param	_height If 0 will be autocalculated on next setData()
	   @param	sid SID
	**/
	public function new(?sid:String, _width:Int, _height:Int = 0)
	{
		super(sid);
		type = ElementType.textbox;
		size(_width - 1, _height); // NOTE: -1 because of the scrollbar
		slots_count = height;
		reset(); // Init vars

		focus_lock = true; // Custom handle window next and previous element focus
	}//---------------------------------------------------;

	override public function reset()
	{
		lines = [];
		scroll_offset = 0;
		scroll_ratio = 0;
		flag_empty = true;
		if (scrollbar != null)
		{
			parent.removeChild(scrollbar);
			scrollbar.clear();
			scrollbar = null;
		}
		if (visible) draw();
	}//---------------------------------------------------;

	override public function draw():Void
	{
		_readyCol();
		var j:Int = 0;
		do{
			if (lines[j + scroll_offset] != null) {
				drawSlotIndex(j);
			}else{
				// Draw the rest of the textbox BG
				WM.D.rect(x, y + j, width, slots_count - j);
				break;
			}
		}while (++j < slots_count);
	}//---------------------------------------------------;


	/**
	   Add a single line of content at the end of the list
	**/
	public function addLine(line:String)
	{
		#if debug
			if (height == 0) throw "Set height before adding Lines";
		#end

		flag_empty = false; // Just in case

		lines.push(StrT.padString(line, width));

		// Max allowed scroll
		scroll_max = lines.length - slots_count;
		if (scroll_max < 0) scroll_max = 0;
		if (scroll_max > 0)
		{
			addScrollbar();
			scroll_offset = scroll_offset;
		}

		if (visible) draw();
	}//---------------------------------------------------;


	/**
	   Set new data, either a `String` or `array<String>`
	   If <string> will cut it down to multiple lines
	**/
	override public function setData(val:Any):Void
	{
		reset();

		var src:Array<String>;

		if (Std.is(val, String))
		{
			src = StrT.splitToLines(val, width);
		}
		else if (Std.is(val, Array))
		{
			src = val;
		}else
		{
			throw "Unsupported Data Type for Textbox";
		}

		for (i in src)
		{
			lines.push(StrT.padString(i, width));
		}

		// Autocalculate height
		if (height == 0)
		{
			height = src.length;
			slots_count = height;
		}

		// Max allowed scroll
		scroll_max = lines.length - slots_count;
		if (scroll_max < 0) scroll_max = 0;
		if (scroll_max > 0) addScrollbar();

		flag_empty = (lines.length == 0);

		if (visible && !lockDraw)
		{
			draw();
		}
	}//---------------------------------------------------;


	// Move lines down by one, reveal the top
	public function scrollUp():Bool
	{
		if (scroll_offset == 0) return false;
		scroll_offset--; // uses setter will update everything
		return true;
	}//---------------------------------------------------;
	//  Move lines up by one, reveal the bottom
	public function scrollDown():Bool
	{
		if (scroll_offset == scroll_max) return false;
		scroll_offset++;
		return true;
	}//---------------------------------------------------;
	public function scrollPageUp()
	{
		scroll_offset -= Math.floor(slots_count / 2);
	}//---------------------------------------------------;
	public function scrollPageDown()
	{
		scroll_offset += Math.floor(slots_count / 2);
	}//---------------------------------------------------;
	public function scrollTop()
	{
		scroll_offset = 0;
	}//---------------------------------------------------;
	public function scrollBottom()
	{
		scroll_offset = scroll_max;
	}//---------------------------------------------------;


	// Draws a single line (i:Index)
	function drawSlotIndex(i:Int)
	{
		WM.T.move(x, y + i).print(lines[i + scroll_offset]);
	}//---------------------------------------------------;

	// --
	function addScrollbar()
	{
		if (scrollbar != null) return;

		if (parent == null)
		{
			flag_add_scrollbar = true; // Add it later
			return;
		}

		scrollbar = new ScrollBar(height);
		scrollbar.posNext(this);

		parent.addChild(scrollbar);

		focusSetup(isFocused);	// <-- Refresh scrollbar colors

		flag_add_scrollbar = false;
	}//---------------------------------------------------;
	// --
	override function onKey(k:String):String
	{
		// Transform the keys to make parent window focus next/previous
		if (flag_empty)
		{
			if (k == "up") return "left";
			if (k == "down") return "right";
			return k;
		}

		// DEV: All the special nav keys (pagedown,home,etc) are blocked
		//		I guess this is ok

		switch(k)
		{
			case "left": k = "up";		// transform it, make the window focus the previous element
			case "right": k = "down";
			case "up": if (scrollUp()) k = "";	// else pass it to the window
			case "down": if (scrollDown()) k = "";
			case "pagedown": scrollPageDown(); k = "";
			case "pageup": scrollPageUp(); k = "";
			case "home": scrollTop(); k = "";
			case "end": scrollBottom(); k = "";
			default:
		}

		return k;
	}//---------------------------------------------------;

	// --
	override function onAdded():Void
	{
		if (colorFG == null) setColor(parent.style.textbox);

		if (flag_add_scrollbar)
		{
			addScrollbar();
		}

	}//---------------------------------------------------;

	// --
	override function focusSetup(focus:Bool):Void
	{
		if (parent.style.textbox_focus != null)
		{
			if (focus)
			{
				setColor(parent.style.textbox_focus);
			}else{
				setColor(parent.style.textbox);
			}
		}

		if (scrollbar != null)
		{
			// Hack: Don't actually remove the scrollbar,
			//       rather paint it all a single color, it's easier this way
			if (flag_scrollbar_autohide && !focus)
			{
				scrollbar.setColor(colorBG, colorBG);
				scrollbar.draw();
			}else

			if (parent.style.scrollbar_focus != null)
			{
				if (focus)
					scrollbar.setColor(parent.style.scrollbar_focus);
				else
					scrollbar.setColor(parent.style.scrollbar_idle);

				scrollbar.draw(); //<- Must call draw to apply color changes
			}
		}

	}//---------------------------------------------------;
	// GETTER
	function get_linesCount() { return lines.length; }

	// SETTER, autocalculates scroll percent and updates scrollbar
	function set_scroll_offset(val)
	{
		if (val < 0) val = 0;
		if (val > scroll_max) val = scroll_max;

		// This is now off, in order to force recalculate, so don't add in the future
			//if (scroll_offset == val) return val;

		scroll_offset = val;
		scroll_ratio = scroll_offset / scroll_max;

		if (scrollbar != null) scrollbar.scroll_ratio = scroll_ratio; // :: setter draw
		if (visible && !lockDraw) draw();

		if (visible) {
			if (onScroll != null) onScroll(this);
			callback('scroll');
		}

		return val;
	}//---------------------------------------------------;

}// --