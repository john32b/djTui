package djTui.win;

import djTui.BaseElement;
import djTui.Window;
import djTui.el.Button;

/**
 * Menu Bar,
 * A Window presenting Buttons / Items in a single strip.
 * 
 * NOTES: 
 * 
 * 	- Callbacks on `fire` and on `change`
 *  - Currently acts like a TAB Selection with no popup menus
 *  - Customizable
 *  - setPanelStyle(), setItemStyle() for customization
 * 
 * TODO:
 * 	- Popup menus support for items
 * 
 */
class MenuBar extends Window 
{
	// Holds all root level Items
	var items:Array<Button>;
	
	// Currently selected <index> (0..n)
	var currentIndex:Int;
	
	/// Style related:
	
	var menuAlign:String;	// Alignment of Items inside the panel
	
	// Button Styles :
	var _bFixSize:Int = 0;	// Force a fixed size all Elements ( if set )
	var _bStyle:Int = 0;	// Button style ID 
	var _bPad0:Int;			// Button Outer Symbol Pad
	var _bPad1:Int;			// Button Inner Symbol Pad
	var _bPad2:Int;			// Button Padding Between
	
	// Grid and Box Style :
	var _gSizes:Array<Int>;	// Helper Array, store a button sizes to push to drawer
	var _gStyle:Int = 0;	// Grid/Panel Thickness Style
	
	/** Quick callback for when an Item becomes highlighted */
	public var onChange:Int->Void;
	
	/** Quick callback for when an Item gets selected */
	public var onSelect:Int->Void;
		
	
	/**
	   Create a MenuBar
	   Call `setup()` first for styling and then `setItems()` to push data
	   @param	Sid Set an SID to have it pushed to the global WM.DB object
	   @param	Width -1 For full screen width. If Size too small for items, it will be resized
	   @param	Side Window Padding.
	**/
	public function new(?Sid:String, Width:Int = 1, PadX:Int = 0) 
	{
		super(Sid, Width, 1);
		padX = PadX;
		// Setup with the default params
		setPanelStyle(style.text, style.bg);
		setItemStyle();
	}//---------------------------------------------------;
	
	/**
	   Setup the item/button Style
	   ! Call this BEFORE setItems();
	   @param	Align Align inside the panel (left,center)
	   @param	FixedSize Force this size to all items ( Be careful with pad0 and pad1 )
	   @param	SymbolID Side symbol for items, (0..4) | 0 for none 
	   @param	pad0 Symbol Outer Pad
	   @param	pad1 Symbol Inner Pad
	   @param	padBetween Padding Between Items
	**/
	public function setItemStyle(   Align:String = "left", FixedSize:Int = 0,
									SymbolID:Int = 0, pad0:Int = 1, pad1:Int = 1,
								    padBetween:Int = 1 )
	{
		
		menuAlign = Align;
		_bFixSize = FixedSize;
		_bStyle = SymbolID;
		_bPad0 = pad0;
		_bPad1 = pad1;
		_bPad2 = padBetween;
		
		#if debug
		if (_gStyle > 0 && _bPad2 == 0) {
			trace("Warning: Border style needs element padding > 0");
			_bPad2 = 1;
		}
		if (items != null)
		{
			trace("Error: Call this function before adding items");
		}
		#end
	}//---------------------------------------------------;
	
	
	/**
	 * Setup Panel Styles
	   @ Call this BEFORE setItems();
	   @param col0 The background color
	   @param col1 The accent color
	   @param Gstyle -1:Thin, 0:Thick, 1-6:Thick with border style  ( Defined in Styles.border object )
	**/
	public function setPanelStyle(col1:String, col0:String, Gstyle:Int = -1)
	{
		_gStyle = Gstyle;
		
		if (Gstyle ==-1) // THIN BORDER ::
		{
			padY = 0;
			height = 1;
		}
		else	// THICK BORDER ::
		{
			padY = 1;
			height = 3;
			
			// A border needs padding
			if (Gstyle > 0 && padX == 0)
			{
				padX = 1;
			}
		}
		
		modifyStyle({
			borderStyle:0,
			bg : col0,
			elem_idle  : {fg:col1},
			elem_focus : {fg:col0,bg:col1}
		});
		
		#if debug
		if (items != null)
		{
			trace("Error: Call this function before adding items");
		}
		#end
		
	}//---------------------------------------------------;
 	
	/**
	   Sets or Re-Sets the Menu Items
	   Will reset cursor to the first element
	   @param	ar Item Names in an array
	**/
	public function setItems(ar:Array<String>):MenuBar
	{
		if (ar == null) return this;
		
		currentIndex = 0;
		
		// - Clear old items ( if any )
		if (items != null)
		{
			lockDraw = true; // prevent re-drawing at every element removal
			for (i in items) removeChild(i);
			lastAdded = null;
			lockDraw = false;
		}
		
		items = [];
		_gSizes = [];
		
		var totalW:Int = 0;
		
		// Add the new items
		var i = 0;
		while(i < ar.length)
		{
			// Store the index of the item on the SID
			var b = new Button('$i', ar[i], _bStyle, _bFixSize);
			b.setSideSymbolPad(_bPad0, _bPad1);
			items.push(b);
			i++;
			_gSizes.push(b.width + _bPad2);
			totalW += b.width + _bPad2;
		}
		
		// Last INT in drawgrid is cell height
		_gSizes[0]++;
		_gSizes.push(height);
		totalW -= _bPad2;
		
		// Re-Adjust width if it's too small
		if (totalW + (padX * 2) > width)
		{
			width = totalW + (padX * 2);
		}
		
		addStackInline(cast items, 0, _bPad2, menuAlign);
		
		return this;
	}//---------------------------------------------------;
	
	
	override function onElementCallback(st:String, el:BaseElement) 
	{	
		super.onElementCallback(st, el);
		
		if (st == "fire" && onSelect != null)
		{
			onSelect(currentIndex);
		}else
	
		
		if (st == "focus")
		{
			currentIndex = Std.parseInt(el.SID);
			if (_gStyle==0) drawThick( active );
		
			if (onChange != null) onChange(currentIndex);
			
		} else
		
		if (st == "unfocus")
		{
			if (_gStyle==0) drawThick( items[ Std.parseInt(el.SID) ] );
		}
		
	}//---------------------------------------------------;
	
	
	override public function draw():Void 
	{
		super.draw();
	
		if (_gStyle > 0)
		{
			_readyCol();
			// Devnote: - (x-1) because The window already has 1 pad
			//			- copy because drawgrid modifies the array
			WM.D.drawGrid(items[0].x - 1 , y, null, [ _gSizes.copy() ] , _gStyle, _gStyle);
		}
	}//---------------------------------------------------;
	
	
	/**
	  Draw a line above/below a button, making it ""thicker""
	 */
	function drawThick(el:BaseElement)
	{
		WM.T.bg(el.colorBG);
		WM.D.rect(el.x, el.y + 1, el.width, 1);
		WM.D.rect(el.x, el.y - 1, el.width, 1);
	}//---------------------------------------------------;
	
	/**
	   Set the cursor to an index. 0 To select none
	   @param	index
	**/
	public function setCursor(index:Int)
	{
		if (index == currentIndex) return;
		currentIndex = index;
		if (currentIndex > 0)
		{
			items[currentIndex].focus();
		}
	}//---------------------------------------------------;
	
	
	/**
	   Feed with CSV
	   @param	val CSV data, like "one,two,three"
	**/
	override public function setData(val:Any) 
	{
		setItems(cast(val, String).split(','));
	}//---------------------------------------------------;
	
	/** Return current selected INDEX */
	override public function getData():Any 
	{
		return currentIndex;
	}//---------------------------------------------------;
	
	
}// --