/********************************************************************
 * Menu Bar
 * A Window presenting Buttons / Items in a single strip.
 *
 *
 * EXAMPLE:
 * 	bar = new MenuBar("main",-1,2);
 *  bar.setItems(["one","two"]);
 *
 *******************************************************************/

package djTui.win;

import djA.DataT;
import djTui.BaseElement;
import djTui.Styles.WinStyle;
import djTui.Window;
import djTui.el.Button;

class MenuBar extends Window
{
	// Holds all root level Items
	var items:Array<Button>;

	// Currently selected <index> (0..n)
	var currentIndex:Int;

	/** MenuBar Style parameters */
	var bSt = {
		align:"l",	// Alignment of the whole button strip inside the panel | l,c (left,center)
		bWidth:0,		// Fixed button width. 0 for Auto
		bStyle:0,		// Button style ID. ie Symbol to enclose the text. Check `Button.SMB`
		bPad:[0, 1, 1],	// Symbol PAD L | Symbol PAD R | Pad Between Buttons
		padX:0,			// X Padding for Inner Menu Area
		grid:-1,		// -1:thin,0:thick:1-6 border decoration
	}

	// Grid and Box Style :
	var _gSizes:Array<Int>;	// Helper Array, store a button sizes to push to drawer
	var _gStyle:Int = 0;	// Grid/Panel Thickness Style

	/** callback for when an Item becomes highlighted. Index starts at 0 */
	public var onChange:Int->Void;

	/** callback for when an Item gets selected. Index starts at 0 */
	public var onSelect:Int->Void;

	/**
	   Create a MenuBar
	   @param	Sid Set an SID to have it pushed to the global WM.DB object
	   @param	Width -1 For full screen width. If Size too small for items, it will be resized
	   @param	BarStyle Check `bSt` for details | You can override fields | null for default
	**/
	public function new(?Sid:String, Width:Int = 1, BarStyle:Dynamic = null )
	{
		super(Sid, Width, 1);
		bSt = DataT.copyFields(BarStyle, bSt);
		setBarStyle(style.text, style.bg, bSt.grid);
	}//---------------------------------------------------;


	/**
	 * Setup Panel Styles
	   @ Call this BEFORE setItems(); WHY. Because then button elements can properly setup the colors
	   @param col0 The background color
	   @param col1 The accent color
	   @param Gstyle -1:Thin, 0:Thick, 1-6:Thick with border style  ( Defined in Styles.border object )
	**/
	function setBarStyle(col1:String, col0:String, Gstyle:Int = -1)
	{
		#if debug
		if (Gstyle > 0 && bSt.bPad[2] == 0) {
			trace("Warning: Border Style needs element padding > 0");
			bSt.bPad[2] = 1;
		}
		#end

		_gStyle = Gstyle;

		if (Gstyle == -1) // THIN BORDER ::
		{
			padding(bSt.padX, 0);
			height = 1;
		}
		else			// THICK BORDER ::
		{
			// Force XPadding if borderstyle is set
			if (Gstyle > 0 && bSt.padX == 0)
			{
				bSt.padX == 1;
			}

			padding(bSt.padX, 1);
			height = 3;
		}

		modStyle({
			borderStyle:0,
			bg : col0,
			elem_idle  : {fg:col1},		// This will reflect to all the child buttons
			elem_focus : {fg:col0,bg:col1}
		});

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
			var b = new Button('$i', ar[i], bSt.bStyle, bSt.bWidth);
			b.setSideSymbolPad(bSt.bPad[0], bSt.bPad[1]);
			items.push(b);
			i++;
			_gSizes.push(b.width + bSt.bPad[2]);
			totalW += b.width + bSt.bPad[2];
		}

		// Last INT in drawgrid is cell height
		_gSizes[0]++;
		_gSizes.push(height);
		totalW -= bSt.bPad[2];

		// Re-Adjust width if it's too small
		if (totalW + (padX * 2) > width)
		{
			width = totalW + (padX * 2);
		}

		addStackInline(cast items, 0, bSt.bPad[2], bSt.align);

		return this;
	}//---------------------------------------------------;



	/**
	   - Alternative way to feed data to the Menu
	   - This way requires a CSV string
	   @param	val CSV String , e.g. "one,two,three"
	**/
	override public function setData(val:Any)
	{
		setItems(cast(val, String).split(','));
	}//---------------------------------------------------;
	/**
	   Set the cursor to an index. 0 is the first
	   @param	index
	**/
	public function setIndex(index:Int)
	{
		if (index > items.length - 1) index = items.length - 1;
		if (index == currentIndex || index < 0) return;
		// The index is now sanitized
		currentIndex = index;
		items[currentIndex].focus();
	}//---------------------------------------------------;

	/** Return current selected INDEX */
	public function getIndex():Any
	{
		return currentIndex;
	}//---------------------------------------------------;


	override public function draw():Void
	{
		super.draw();

		if (_gStyle > 0)
		{
			_readyCol();
			// Devnote: - (x-1) because The window already has 1 pad
			//			- copy because drawgrid modifies the array
			WM.D.drawGrid(items[0].x - 1 , y, _gStyle, _gStyle, [ _gSizes.copy() ]);
		}
	}//---------------------------------------------------;


	/**
	  Draw a whitespace BG colored line above/below a button, making it appear """Taller"""
	 */
	function drawTaller(el:BaseElement)
	{
		WM.T.bg(el.colorBG);
		WM.D.rect(el.x, el.y + 1, el.width, 1);
		WM.D.rect(el.x, el.y - 1, el.width, 1);
	}//---------------------------------------------------;


	override function onElementCallback(st:String, el:BaseElement)
	{
		super.onElementCallback(st, el);

		if (st == "fire" && onSelect != null)
		{
			Tools.tCall(onSelect, currentIndex);
		} else

		if (st == "focus")
		{
			currentIndex = Std.parseInt(el.SID);
			if (_gStyle==0) drawTaller( active );

			Tools.sCall(onChange, currentIndex);

		} else

		if (st == "unfocus")
		{
			if (_gStyle==0) drawTaller( items[ Std.parseInt(el.SID) ] );
		}

	}//---------------------------------------------------;

}// --