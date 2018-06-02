package djTui.el;

import djTui.BaseElement;

/**
 * A TEXTBOX that display lines of text
 * 
 * - scrollable
 * - automatic scrollbar
 * - reports custom status callbacks
 * 
 * DEV NOTE:
 * - If height==0 it will be autocalculated on first data set
 */
class TextBox extends BaseElement 
{
	
	// Holds the Final Rendered String
	var lines:Array<String>;
	
	// Current scroll multiplier (0 -> 1)
	public var scroll_ratio(default, null):Float;
	
	// From what index to start displaying lines
	// You can just adjust this whenever and the scroll will be adjusted automatically
	var scroll_offset(default, set):Int;
	
	// Autocalculated, the index the textbox can scroll to
	var scroll_max:Int;
	
	// Will be added to the parent window automatically?
	var scrollbar:ScrollBar;
	
	// How many slots to display lines
	var slots_count:Int;
	
	/**
	   Create a new TextBox
	   
	   @param	_width Width of the lines
	   @param	_height If 0 will be autocalculated on next setData()
	   @param	sid SID
	**/
	public function new(_width:Int, _height:Int = 0, ?sid:String)
	{
		super(sid);
		type = ElementType.textbox;
		size(_width - 1, _height);
		slots_count = height;
		flag_focusable = false;
		reset(); // Init vars
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		switch(k)
		{
			case "up": scrollUp();
			case "down": scrollDown();
			case "pagedown": scrollPageDown();
			case "pageup": scrollPageUp();
			case "home": scrollTop();
			case "end": scrollBottom();
			default:
		}
	}//---------------------------------------------------;
	
	// --
	override function focusSetup(focus:Bool):Void 
	{
		if (focus) 
		{
			setColors(parent.skin.accent_blur_fg, parent.skin.accent_fg);
		}else {
			setColors(parent.skin.accent_blur_fg, parent.skin.accent_blur_bg);
		}
		
		if (scrollbar != null) 
		{
			scrollbar.focusSetup(focus);
			scrollbar.draw(); //<- scrollbar has a separate draw call
		}
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
	
	// --
	// Draws a single line
	// Used in the extended VLIST object
	function drawSlotIndex(i:Int)
	{
		WM.T.move(x, y + i).print(lines[i + scroll_offset]);
	}//---------------------------------------------------;
	
	// --
	// Add a single line of content at the end of the list
	public function addLine(line:String)
	{
		#if debug
			if (height == 0) throw "Set height before adding Lines";
		#end
		
		lines.push(StrTool.padString(line, width));
		
		// Max allowed scroll
		scroll_max = lines.length - slots_count;
		if (scroll_max < 0) scroll_max = 0;
		if (scroll_max > 0) addScrollbar();
		
		if (visible) draw();
	}//---------------------------------------------------;
	
	// --
	function addScrollbar()
	{
		if (scrollbar != null) return;
		scrollbar = new ScrollBar(height);
		scrollbar.posNext(this);
		parent.addChild(scrollbar);
	}//---------------------------------------------------;
	
	/**
	   Set new data, either a `String` or `array<String>`
	   If <string> will cut it down to multiple lines
	**/
	override public function setData(val:Any) 
	{
		reset();
		
		var src:Array<String>;
		
		if (Std.is(val, String))
		{
			src = StrTool.splitToLines(val, width);
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
			lines.push(StrTool.padString(i, width));
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
		
	}//---------------------------------------------------;
	
	// Return the whole bunch of data
	override public function getData():Any 
	{
		return lines;
	}//---------------------------------------------------;
	
	/**
	   SETTER, autocalculates scroll percent and updates scrollbar
	   @param	va
	**/
	function set_scroll_offset(val)
	{ 
		if (val < 0) val = 0;
		if (val > scroll_max) val = scroll_max;
		if (scroll_offset == val) return val;
		// >> New value
		scroll_offset = val;
		scroll_ratio = scroll_offset / scroll_max;

		if (scrollbar != null) scrollbar.scroll_ratio = scroll_ratio; // :: setter draw
		if (visible && !lockDraw) draw();
		
		return val;
	}//---------------------------------------------------;
	
	override public function reset() 
	{
		lines = [];
		scroll_offset = 0;
		scroll_ratio = 0;
		if (visible) draw();
	}//---------------------------------------------------;
	
	// Move lines down by one, reveal the top
	public function scrollUp()
	{
		scroll_offset--; // uses setter will update everything
	}//---------------------------------------------------;
	//  Move lines up by one, reveal the bottom
	public function scrollDown()
	{
		scroll_offset++;
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
	
}// --