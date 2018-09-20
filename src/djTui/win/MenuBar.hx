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
	var _gStyle:Int = 0;	// Grid Style both outer and inner
	var _thick:Bool;		// Thickness Flag True for 3 line height. False for single line
	var _fl_drawthick:Bool; // Determines whether to draw a line above and below the current element
	
	/** Quick callback for when an Item becomes highlighted */
	public var onChange:Int->Void;
	
	/** Quick callback for when an Item gets selected */
	public var onSelect:Int->Void;
	
	
	/**
	   Create a MenuBar
	   Call `setup()` first for styling and then `set()` to push data
	   @param	Sid Set an SID to have it pushed to the global WM.DB object
	   @param	Width -1 For full screen width, 0 For Automatic Based on elements
	**/
	public function new(?Sid:String, Width:Int = -1) 
	{
		super(Sid, Width, 1);
		padX = 1;
		
		// Setup with the default params
		setPanelStyle(style.text, style.bg);
		setItemStyle();
		
	}//---------------------------------------------------;
	
	/**
	   Setup the item/button Style
	   ! Call this BEFORE set();
	   @param	Align Align inside the panel (left,center)
	   @param	FixedSize Force this size to all items ( Be careful with pad0 and pad1 )
	   @param	SymbolID Side symbol for items, (0..4) | 0 for none 
	   @param	pad0 Symbol Outer Pad
	   @param	pad1 Symbol Inner Pad
	   @param	padBetween Padding Between Items
	**/
	public function setItemStyle(   Align:String = "left", FixedSize:Int = 0,
									SymbolID:Int = 0, pad0:Int = 1, pad1:Int = 1,
								    padBetween:Int = 2 )
	{
		menuAlign = Align;
		_bFixSize = FixedSize;
		_bStyle = SymbolID;
		_bPad0 = pad0;
		_bPad1 = pad1;
		_bPad2 = padBetween;
	}//---------------------------------------------------;
	
	
	/**
	 * Setup Panel Styles
	   @ Call this BEFORE set();
	   @param col0 The background color
	   @param col1 The accent color
	   @param thick True to have it be 3 lines tall
	   @param GStyle Border Style 0 for no style (1-6) for other styles. ( Defined in Styles.border object )
	**/
	public function setPanelStyle(col1:String, col0:String, Thick:Bool = false, GStyle:Int = 0)
	{
		_gStyle = GStyle;
		_thick = Thick;
		
		if (_thick)
		{
			padY = 1;
			height = 3;
		}else
		{
			padY = 0;
			height = 1;
			_gStyle = 0; // safeguard
		}
		
		_fl_drawthick = _thick && _gStyle == 0;
		
		modifyStyle({
			borderStyle:0,
			bg : col0,
			elem_idle  : {fg:col1},
			elem_focus : {fg:col0,bg:col1}
		});
		
	}//---------------------------------------------------;
 	
	/**
	   Sets or Re-Sets the Menu Items
	   Will reset cursor to the first element
	   @param	ar Item Names in an array
	**/
	public function set(ar:Array<String>):MenuBar
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
		}
		
		// Last INT in drawgrid is cell height
		_gSizes[0]++;
		_gSizes.push(height);
		
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
			if (_fl_drawthick) drawThick( active );
		
			if (onChange != null) onChange(currentIndex);
			
		} else
		
		if (st == "unfocus")
		{
			if (_fl_drawthick) drawThick( items[ Std.parseInt(el.SID) ] );
		}
		
	}//---------------------------------------------------;
	
	
	override public function draw():Void 
	{
		super.draw();
	
		if (_gStyle > 0)
		{
			_readyCol();
			WM.D.drawGrid(x + items[0].x - 1 , y, null, [ _gSizes.copy() ] , _gStyle, _gStyle);
		}
	}//---------------------------------------------------;
	
	
	/**
	  Draw a line and below a button, to make it appear thicker
	  -- Checks for flag so you can call this regardless of thickness --
	 */
	function drawThick(el:BaseElement)
	{
		WM.T.bg(el.colorBG);
		WM.D.rect(el.x, el.y + 1, el.width, 1);
		WM.D.rect(el.x, el.y-1, el.width, 1);
	}//---------------------------------------------------;
	
	
	/**
	   Feed with CSV
	   @param	val CSV data, like "one,two,three"
	**/
	override public function setData(val:Any) 
	{
		set(cast(val, String).split(','));
	}//---------------------------------------------------;
	
	/** Return current selected INDEX */
	override public function getData():Any 
	{
		return currentIndex;
	}//---------------------------------------------------;
	
	
}// --