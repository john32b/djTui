package djTui.el;
import djTui.Styles.PrintColor;

/**
 * Vertical List of Strings
 * - Scrolls elements vertically in a list like a textbox
 * - Basically a Textbox with cursor navigation
 * - Sends status callbacks (fire,change)
 * - Useful for selecting an element from many
 * - Can add elements on the fly
 * 
 */
class VList extends TextBox 
{
	
	/** Currently selected element index. Starting at 0 for the first one */
	public var index(default, null):Int;
	
	// Current slot the cursor/highlighted element is at
	var index_slot:Int;
	
	/* USERSET -  Scroll the view when the cursor is this much from the edge */
	public var scrollPad:Int = 1;

	// The maximum index the cursor can get ( the number of elements )
	var index_max(get, null):Int;

	// The color the highlighted element gets.
	var color_cursor:PrintColor;
	
	/** Quickly get a callback for selected elements fn(index) */
	public var onSelect:Int->Void;
	
	/** Jump to letters on keystrokes. Works best on sorted lists */
	public var flag_letter_jump:Bool = false;
	
	/** If true, the active index will be highlighted when element is unfocused */
	public var flag_ghost_active:Bool = false;
	
	//====================================================;
	public function new(?sid:String, _width:Int, _slots:Int)
	{
		super(sid, _width, _slots);
		type = ElementType.vlist;
		flag_focusable = true;
	}//---------------------------------------------------;
	
	
	// - safeguards and colors
	override function onAdded():Void 
	{
		super.onAdded();
		
		if (scrollPad > Math.floor(slots_count / 2) - 1) {
			scrollPad = Math.floor(slots_count / 2) - 1;
		}
		
		if (color_cursor == null) {
			color_cursor = parent.style.vlist_cursor;
		}
		
	}//---------------------------------------------------;
	
	/** Set the highlighted element color */
	public function setColorCursor(fg:String, bg:String)
	{
		color_cursor = {fg:fg, bg:bg};
	}//---------------------------------------------------;
	
	// --
	override public function draw():Void 
	{
		super.draw();
		
		if (isFocused && !flag_empty) cursor_draw();
		
		if (!isFocused && flag_ghost_active)
		{
			WM.T.reset().fg(parent.style.elem_disable_f.fg).bg(parent.style.elem_disable_f.bg);
			drawSlotIndex(index_slot);	
		}
	}//---------------------------------------------------;
	
	/**
	   Send a fire event for the currently selected index
	**/
	function fire()
	{
		callback("fire");
		Tools.tCall(onSelect, index);
		//if (onSelect != null) {
			//haxe.Timer.delay(onSelect.bind(index), 1);
		//}
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		if (flag_empty) 
		{
			// Let textbox handle focusing other elements
			super.onKey(k);
			return;
		}
		
		switch(k)
		{
			case "up": if (index == 0) parent.focusPrev(); else cursor_up();
			case "down": if (index == index_max) parent.focusNext(); else cursor_down();
			case "left": parent.focusPrev();
			case "right":parent.focusNext();
			case "pagedown": cursor_pageDown();
			case "pageup": cursor_pageUp();
			case "home": cursor_top();
			case "end": cursor_bottom();
			case "space" | "enter": fire();
			default:
			// Check for letter jumps:
			if (!flag_letter_jump) return;
			
				k = k.toUpperCase();

				// Cycle through same letter on multiple presses :
				if (lines[index].charAt(0).toUpperCase() == k)
				{
					if (lines[index + 1] != null && lines[index + 1].charAt(0).toUpperCase() == k)
					{
						cursor_down(); return;
					}
				}
			
				// Force go to the start of a letter :
				var x = 0;
				do {
					if (lines[x].charAt(0).toUpperCase() == k) {
						cursor_to(x);
						return;	
					}
				}while (++x < lines.length);
		}
	}//---------------------------------------------------;
	
	// --
	override public function reset() 
	{
		super.reset();
		index = 0;
		index_slot = 0;
	}//---------------------------------------------------;
	
	/**
	   Return currently selected index
	**/
	override public function getData():Any 
	{
		return index;
	}//---------------------------------------------------;
	
	/**
	   Add a single element at the bottom of the list
	   @return Returns the index of the new element
	**/
	public function add(name:String):Int
	{
		addLine(name);
		return index_max;
	}//---------------------------------------------------;
	
	/**
	   Quickly get the currently selected text
	**/
	public function getSelectedText():String
	{
		if (lines[index] != null) return lines[index]; return "";
	}//---------------------------------------------------;
	

	/**
	   Move the cursor to target index.
	   NOTE: Hacky to way to scroll, it works but it's ugly
			 ( It scrolls one by one from the top until it reaches the element 
			   but at least it will not draw at every cursor jump, just once )
	   @param	val Index to scroll to. Starts at 0
	**/
	public function cursor_to(val:Int)
	{
		if (val == index) return;

		if (scrollbar != null)
		{
			scrollbar.lockDraw = true;
		}
		
		lockDraw = true;
		cursor_top();
		while (index < val) cursor_down();
		lockDraw = false;
		if (visible) draw();
		
		if (scrollbar != null)
		{
			scrollbar.lockDraw = false;
			if(visible) scrollbar.draw();
		}
		
	}//---------------------------------------------------;
	
	
	//====================================================;
	// Quick Calls 
	//====================================================;
	

	// Draw the highlighted element (cursor)
	function cursor_draw()
	{
		if (!lockDraw) {
			WM.T.reset().fg(color_cursor.fg).bg(color_cursor.bg);
			drawSlotIndex(index_slot);
		}
	}//---------------------------------------------------;
	
	// Drawing over the old selected element
	function draw_current_slot_unfocused()
	{
		if (!lockDraw) {
			_readyCol(); drawSlotIndex(index_slot);
		}
	}//---------------------------------------------------;
	
	
	//====================================================;
	// CURSOR MANIPULATION
	//====================================================;
	
	// Move the cursor up by one
	function cursor_up()
	{
		if (index == 0) return;
		
		index--;
		
		if (index_slot <= scrollPad && scroll_offset > 0)
		{
			scrollUp();
			cursor_draw();
		}else
		{
			draw_current_slot_unfocused();
			index_slot--;
			cursor_draw();
		}
		
		callback("change");
	}//---------------------------------------------------;
	
	// Move the cursor down by one
	function cursor_down()
	{
		if (index == index_max) return;

		index++;
		
		if ((index_slot >= slots_count - scrollPad - 1) && scroll_offset < scroll_max)
		{
			scrollDown();
			cursor_draw();
		}else
		{
			draw_current_slot_unfocused();
			index_slot++;
			cursor_draw();
		}

		callback("change");
	}//---------------------------------------------------;
	
	function cursor_top()
	{
		if (index == 0) return;
		
		index = 0;
		
		// Don't redraw everything if it doesn't have to
		if (scroll_offset == 0) 
		{
			draw_current_slot_unfocused();
			index_slot = 0;
			cursor_draw();
			
		}else
		{
			index_slot = 0;
			scrollTop(); // > don't forget, it will automatically call draw()
		}
		
		callback("change");
	}//---------------------------------------------------;
	
	function cursor_bottom()
	{
	
		if (index == index_max) return;
		index = index_max;
			
		// Don't redraw everything if it doesn't have to
		if (scroll_offset == scroll_max)
		{
			draw_current_slot_unfocused();

			// For the occation where not all slots are populated
			if (lines.length < slots_count)
			{
				index_slot = index_max;
			}else
			{
				index_slot = slots_count - 1;
			}
			
			cursor_draw();
			
		}else
		{
			index_slot = slots_count - 1;
			scrollBottom();
		}
		
		callback("change");
	}//---------------------------------------------------;
	
	function cursor_pageUp()
	{
		if (index == 0) return;
		
		// Just Put the cursor on the top most position
		if (index_slot > scrollPad && scroll_offset > 0)
		{
			draw_current_slot_unfocused();
			index_slot = scrollPad;
			index = scroll_offset + index_slot;
			cursor_draw();
		}
		// The cursor is already at the top, scroll the view
		else
		{
			// No scroll is needed, just put the cursor at the very top
			if (scroll_offset == 0)
			{
				cursor_top();
				return;
			}
			
			// Setting this now, because it will be drawn with pagescroll()
			index_slot = scrollPad;
			scrollPageUp();
			index = scroll_offset + index_slot;
		}
		
		callback("change");
	}//---------------------------------------------------;
	
	function cursor_pageDown()
	{
		if (index == index_max) return;
		
		// Just Put the cursor on the bottom
		if (index_slot < slots_count - scrollPad - 1 && scroll_offset < scroll_max)
		{
			draw_current_slot_unfocused();
			index_slot = slots_count - scrollPad - 1;
			index = scroll_offset + index_slot;
			cursor_draw();
		}
		// The cursor is already at the bottom, scroll the view
		else
		{
			// No scroll is needed, just put the cursor at the very bottom
			if (scroll_offset == scroll_max)
			{
				cursor_bottom();
				return;
			}
			
			index_slot = slots_count - 1 - scrollPad;
			scrollPageDown();
			index = scroll_offset + index_slot;
		}
		
		callback("change");
	}//---------------------------------------------------;
	
	function get_index_max()
	{
		return lines.length - 1;
	}//---------------------------------------------------;
	
}// --