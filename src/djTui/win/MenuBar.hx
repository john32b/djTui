/********************************************************************
 * Menu Bar
 * A Window presenting Buttons / Items in a single strip.
 *
 *
 * EXAMPLE:
 * 	var bar = new MenuBar( 1, {bWidth:18, grid:true });
 *  bar.setData("One,Two,Three");
 *
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

	// MenuBar Style parameters
	var bSt = {
		bs:0,			// BorderStyle (0) for no border (1-6) Border style from Styles.hx
		grid:false,		// If true, will draw a grid. (Border between the buttons).
		align:"l",		// Alignment of the whole button strip inside the panel | l,c (left,center) | Works on a fixed menu width
		bWidth:0,		// Fixed button width. (0) for Auto. (-1) To stretch to MenuBar Width
		bSmb:[0, 0, 0],	// [Button Symbol ID , Symbol Left Pad, Symbol Right Pad ] ; For button ID check `Button.hx:SMB`
		pads:[1, 1],	// [BarWindow Inner X, Between Buttons] !! Works only when grid=false
		colbg:"",
		colfg:""
	}

	/** callback for when an Item becomes highlighted. Index starts at 0 */
	public var onChange:Int->Void;

	/** callback for when an Item gets selected. Index starts at 0 */
	public var onSelect:Int->Void;

	/**
	   Create a MenuBar
	   @param	Sid Set an SID to have it pushed to the global WM.DB object
	   @param	Width (1) to autoexpand. (-1) For full screen width
	   @param	Height Outer Height of the window. Buttons will expand to full inner height. YOU MUST ACCOMODATE FOR BORDER!
	   @param	BarStyle Check `bSt` for details | You can override fields | null for default
	**/
	public function new(?Sid:String, Width:Int = 1, Height:Int = 3, BarStyle:Dynamic = null )
	{
		super(Sid, Width, Height);

		bSt = DataT.copyFields(BarStyle, bSt);

		/// TODO: custom style ?

		var col0 = bSt.colbg==""?style.bg:bSt.colbg;
		var col1 = bSt.colfg==""?style.text:bSt.colfg;

		modStyle({
			borderStyle:bSt.bs,
			bg : col0,
			elem_idle  : {fg:col1},		// These colors will apply to all the child buttons. Because they work with parent.style
			elem_focus : {fg:col0, bg:col1}
		});

		if (bSt.grid) {
			bSt.pads = [0, 1]; // No inner left pad on grid mode
		}

		padding(bSt.pads[0], 0);
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
		if (items != null) {
			lockDraw = true; // prevent re-drawing at every element removal
			for (i in items) removeChild(i);
			lastAdded = null;
			lockDraw = false;
		}

		items = [];
		var totalW:Int = bSt.pads[0] * 2; // Total Width . Left + Right Pad

		// -- Create the buttons
		for(i in 0...ar.length) {
			// Also store the index of the item as the SID
			var b = new Button('$i', ar[i], bSt.bSmb[0], bSt.bWidth >= 0?bSt.bWidth:0);	// if -1, pass 0 to autosize
			b.height = inHeight;
			b.setSideSymbolPad(bSt.bSmb[1], bSt.bSmb[2]);
			totalW += b.width + bSt.pads[1];
			items.push(b);
		}

		// -- Process <Stretchy Buttons>
		//    Just increment the width of each button by (1) until (totalWidth == desired Width)
		if (bSt.bWidth < 0 && width > totalW) {
			var cb = 0; // current button index
			while (totalW < width) {
				items[cb].setTextWidth(items[cb].width + 1);
				if (++cb >= items.length) cb = 0; // Loop through all the items
				totalW++;
			}
		}

		// -- Calculate the grid complex array
		if (bSt.grid) {
			var grd = [inHeight];	// RowHeight is first
			for (i in 0...ar.length) grd.push(items[i].width);
			border_el.grid = [grd];
		}

		// Re-Adjust width if it's too small
		if (totalW > width) {
			size(totalW, height);
		}

		addStackInline(cast items, 0, bSt.pads[1], bSt.align);
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


	/**
	  Draw a whitespace BG colored line above/below a button, making it appear """Taller"""
	 */
	function drawTaller(el:BaseElement)
	{
		WM.T.bg(el.colorBG);
		WM.D.rect(el.x, el.y + 1, el.width, 1);
		WM.D.rect(el.x, el.y - 1, el.width, 1);
	}//---------------------------------------------------;


	override function onChildEvent(st:String, el:BaseElement)
	{
		super.onChildEvent(st, el);

		if (st == "fire" && onSelect != null)
		{
			Tools.tCall(onSelect, currentIndex);
		} else

		if (st == "focus")
		{
			currentIndex = Std.parseInt(el.SID);
			Tools.sCall(onChange, currentIndex);
		}
	}//---------------------------------------------------;

	// Make some tweaks,
	override function onKey(key:String):String
	{
		// DEV: This function will be called from the WM
		// Block the down/up keys so that it will not navigate
		if (key == "down" || key == "up") key = "";
		return super.onKey(key);
	}//---------------------------------------------------;

}// --