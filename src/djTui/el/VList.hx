package djTui.el;
import djTui.Styles.PrintColor;

/**
 * Vertical List of Strings
 * - Scrolls elements vertically in a list like a textbox
 * - Basically a Textbox with cursor navigation
 * - Sends status callbacks (fire,change)
 * - Useful for selecting an element from many
 * 
 */
class VList extends TextBox 
{
	
	// Currently selected index
	public var index(default, null):Int;
	
	// Current slot the cursor/highlighted element is at
	var index_slot:Int;
	
	// Scroll the view when the cursor is this much from the edge
	public var scrollPad:Int = 1;
	
	// The color the highlighted element gets.
	var color_cursor:PrintColor;
	
	// --
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
		if (isFocused) cursor_draw();
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		switch(k)
		{
			case "up": cursor_up();
			case "down": cursor_down();
			case "pagedown": cursor_pageDown();
			case "pageup": cursor_pageUp();
			case "home": cursor_top();
			case "end": cursor_bottom();
			case "space": callbacks("fire", this);
			case "enter": callbacks("fire", this);
			default:
		}
	}//---------------------------------------------------;
	
	// --
	override public function reset() 
	{
		super.reset();
		index = 0;
		index_slot = 0;
	}//---------------------------------------------------;
	
	// --
	// Return currently selected index
	override public function getData():Any 
	{
		return index;
	}//---------------------------------------------------;
	

	// --
	// Set the currently selected index,
	// moves the cursor.
	// Hacky to way to scroll, it works but it's ugly.
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
	
	// Callback on change for current index
	inline function cbChange()
	{
		callbacks("change", this);
	}//---------------------------------------------------;
	
	// Draw the highlighted element (cursor)
	function cursor_draw()
	{
		WM.T.reset().fg(color_cursor.fg).bg(color_cursor.bg);
		drawSlotIndex(index_slot);
	}//---------------------------------------------------;
	
	// Drawing over the old selected element
	function draw_current_slot_unfocused()
	{
		_readyCol(); drawSlotIndex(index_slot);
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
		
		cbChange();
	}//---------------------------------------------------;
	
	// Move the cursor down by one
	function cursor_down()
	{
		if (index == lines.length - 1) return;

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

		cbChange();
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
		
		cbChange();
	}//---------------------------------------------------;
	
	function cursor_bottom()
	{
		
		if (index == lines.length - 1) return;
		index = lines.length - 1;
			
		// Don't redraw everything if it doesn't have to
		if (scroll_offset == scroll_max)
		{
			draw_current_slot_unfocused();

			// For the occation where not all slots are populated
			if (lines.length < slots_count)
			{
				index_slot = lines.length - 1;
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
		
		cbChange();
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
		
		cbChange();
	}//---------------------------------------------------;
	
	function cursor_pageDown()
	{
		if (index == lines.length - 1) return;
		
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
		
		cbChange();
	}//---------------------------------------------------;
	
}// --