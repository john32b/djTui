package djTui.el;

import djA.StrT;
import djTui.BaseElement;
import djTui.Tools;


/**
 * Text Button
 * ----------
 *
 * - Text that can be highlighted and selected
 * - Button style for displaying text inside button like symbols [ ]
 * - Callbacks "fire" status when selected
 * - You can capture events using Window.Callbacks ( the window owning this button)
 * - You can also call .onPush() to quickly set a callback when the button is pushed
 * - Buttons will always be `center` aligned within target width
 * - You can set a custom Height
 *
 * EXTRA Functionality
 * -------------
 *  You can set some Extra Functionality by calling `extra(..)`
 *   - Auto-open a specified window on click (can customize position)
 *   - Auto-open a WindowState on click
 *   - Auto-Confirmation (YES/NO) on click, (customizable question) use with `.confirm()` or `.extra()`
 *
 * TAGS in SID
 * ---------------
 *
 *   "#" : 	Will go to a STATE, ( must be defined in WM.STATES )
 *   		e.g. "#stateoptions", will goto the state with sid "stateoptions"
 *
 *   "@" :	Will open a WINDOW, ( must be defined in WM.DB )
 * 			e.g. "@details01" will open the window with sid "details01"
 */

class Button extends BaseMenuItem
{
	// Button Style Symbols
	// Index starting at 1
	static var SMB = [ "[]" , "{}" , "()", "<>"];

	// Confirmation default question
	static var CONF_DEF = "Are you sure?";

	/**
	   Stores extra functionality parameters
	   Access and setup with with .extra() function
	**/
	var xtr : {
		?call:Int,		// 0 for State, 1 for Window
		?sid:String,	// Sid of State/Window to go
		?conf:Bool,		// Confirmation Enabled
		?confQ:String,	// Confirmation Question
		?x:Int,			// X pos of the [window] to open
		?y:Int,			// Y pos of the [window] to open
		?anim:Bool,		// open [window] with an animation
		?center:Bool,	// center the new [window] or [confirmation] dialog
		?close:Bool		// close self window upon being selected
	}


	// Extra function called when this button is pushed. Set with onPush()
	var _onPush:Void->Void;

	// DEV: This is autoset to true when buttons are added on a window with addStackInline();
	//		So applies to the MenuBar by default
	/** If true, will request next/previous element focus upon left/right keys
	 *  Useful in cases where you put buttons in a single line */
	public var flag_leftright_escape:Bool = false;

	/**
	   Creates a button/clickable text link
	   @param	sid SID You can include SPECIAL functionality here. It's the same as calling extra(..) later
	   @param	Text The text to display
	   @param	BtnStyle IF > 0 Will enable Button Style text with symbol. Check [static var SMB]
	   @param   Width 0 for Autosize
	   @param   Height Default is (1)
	**/
	public function new(sid:String, Text:String, BtnStyle:Int = 0, Width:Int = 0, Height:Int = 1)
	{
		super(sid);
		#if debug
			if (BtnStyle > SMB.length) {
				BtnStyle = SMB.length;
				trace("WARNING: Button Style Overflow.", this); }
		#end

		type = ElementType.button;
		height = Height;
		textWidth = Width;

		if (BtnStyle > 0)
		{
			var s = BtnStyle - 1;
			setSideSymbolPad(1, 1); // TODO: Parameterize ?
			setSideSymbols(SMB[s].charAt(0), SMB[s].charAt(1));
		}

		text = Text;

		// - In case of special TAGS on the SID, apply them
		if (sid != null)
		{
			if (['#', '@'].indexOf(sid.charAt(0)) >= 0)
			{
				extra(sid); // Initialize # and @
							// For the full functionalities you must call extra() explicitly
			}
		}
	}//---------------------------------------------------;


	override public function draw():Void
	{
		if (height < 2) super.draw();
		else{
			_readyCol();
			var m = Std.int(height * 0.5); // get the index that I will draw
			var empty = StrT.rep(width, " ");
			for (i in 0...height) {
				WM.T.move(x, y + i);
				WM.T.print( i == m ? rText: empty);
			}
		}
	}//---------------------------------------------------;

	/**
	 * Add Extra Functionality that will trigger on click
	 * - Open Another Static Window
	 * - Open A Window State
	 * - Confirm Action
	 *
	 * The data is read from a @CSV string that supports multiple variables
	 *  ------
	 * 	@ + windowSID 	=	Goto a Window with sid==windowSID), the window must be static (existing in WM.DB)
	 *  # + stateSID	=	Goto a WM.STATE with sid==stateSID
	 *  ? + (Question)	=	Present a confirmation popup with a YES/NO, (Question is optional)
	 *  close		=	Close the parent window
	 *  anim		=	Animate Open the Target Window ( valid only if an auto window call is set )
	 * 	center		=	Will screen center the @ Window or the Confirmation Dialog
	 *  x + xpos	=	Place the @ Window at a custom X screen Position (e.g. x10)
	 *  y + ypos	=	Place the @ Window at a custom Y screen Position
	 *  ----
	 * example: "@window2,close,x10,y10,?Really Open?,anim"
	 *  will ask "Really Open?" , if yes will close the parent window and anim open window2 at (10,10)
	 *
	 * @param	tags Separated with comma. Check comments
	 * @return
	**/
	public function extra(tags:String):Button
	{
		var ar = tags.split(',');
		if (xtr == null) xtr = {};

		for (i in ar)
		{
			var c0 = i.charAt(0);
			var c1 = i.substr(1);
			switch(c0){
				case "?":
					xtr.conf = true;
					xtr.confQ = c1;
					if (StrT.isEmpty(xtr.confQ))
					{
						xtr.confQ = CONF_DEF;
					}

				case "#":
					xtr.call = 0;
					xtr.sid = c1;
				case "@":
					xtr.call = 1;
					xtr.sid = c1;
				case "x":
					xtr.x = Std.parseInt(c1);
				case "y":
					xtr.y = Std.parseInt(c1);
				default:

					switch(i)
					{
						case "center":
							xtr.center = true;
						case "close":
							xtr.close = true;
						case "anim":
							xtr.anim = true;
						default:
							trace("Error, Unrecognized Tag", i);
					}
			}
		}

		return this;
	}//---------------------------------------------------;

	/**
	   Set this button to automatically ask a YES/NO question upon being selected
	   @param	text Optional Custom Question to present
	   @param	center True to center the messagebox on screen
	   @return
	**/
	public function confirm(?text:String, ?center:Bool):Button
	{
		var s = "?";
		if (text != null) s += text;
		if (center != null) s += ",center";
		return extra(s);
	}//---------------------------------------------------;


	/**
	   Act what the button is supposed to do,
	   ~ Doesn't check for confirmation, it is done earlier
	**/
	function action()
	{
		if (xtr != null)
		{
			if (xtr.call != null && xtr.call == 0) // GOTO State
			{
				WM.STATE.goto(xtr.sid);
				return;
			}

			if (xtr.close != null)
			{
				parent.close();
			}

			if (xtr.call != null && xtr.call == 1) // GOTO Window
			{
				var win = WM.DB.get(xtr.sid);
				if (win != null)
				{
					if (xtr.x != null && xtr.y != null)
					{
						win.pos(xtr.x, xtr.y);
					}
					else if (xtr.center != null)
					{
						WM.A.screen(win);
					}

					if (xtr.anim != null) {
						win.openAnimated();
					}else {
						win.open(true);
					}
				}else
				{
					trace('WARNING: Button request to goto window SID:"${xtr.sid}" that doesn\'t exist in WM.DB');
				}
			}

		}//- (xtr null check)

		callback("fire");
		Tools.tCall(_onPush);
	}//---------------------------------------------------;

	// --
	override function onKey(k:String)
	{
		if ((k == "enter" || k == "space") && !disabled)
		{
			k = "";
			if (xtr != null && xtr.conf != null)
			{
				WM.popupConfirm(action, xtr.confQ, xtr.center == null?[x, y + 1]:null);
			}else
			{
				action();
			}
		}else

		if (flag_leftright_escape)
		{
			if (k == "left") k = "up"; else
			if (k == "right") k = "down";
		}

		return k;
	}//---------------------------------------------------;


	override public function getData():Any
	{
		return SID;
	}//---------------------------------------------------;

	/**
	   Chain this to quickly add a function to be called when this button is pushed
	**/
	public function onPush(fn:Void->Void):Button
	{
		_onPush = fn;
		return this;
	}//---------------------------------------------------;

}// --
