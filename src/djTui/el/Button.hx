package djTui.el;

import djTui.BaseElement;
import djTui.MessageBox;
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
 * 
 * EXTRA Functionality 
 * -------------
 *  You can set some Extra Functionality by calling extra(...)
 *   - Auto-open a specified window on click (can customize position)
 *   - Auto-open a WindowState on click
 *   - Auto-Confirmation (YES/NO) on click, (customizable question)
 * 
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
	
	
	// Extra function called when this button is pushed
	var extra_onPush:Void->Void;
	
	
	/** If true, will request next/previous element focus upon left/right keys
	 *  Useful in cases where you put buttons in a single line */
	public var flag_leftright_escape:Bool = false;
	
	/**
	   Creates a button/clickable text link
	   @param	sid SID You can include SPECIAL functionality here. It's the same as calling extra(..) later
	   @param	Text The text to display
	   @param	BtnStyle IF > 0 Will enable Button Style text with symbol. "1:<>,2:[],3:{},4:(),5:«»"
	   @param   textWidth 0 for Autosize
	**/
	public function new(sid:String, Text:String, BtnStyle:Int = 0, Width:Int = 0)
	{
		super(sid);
		#if debug
			if (BtnStyle > SMB.length) BtnStyle = SMB.length;
		#end
		type = ElementType.button;
		height = 1;
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
					if (Tools.isEmpty(xtr.confQ))
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
	   Present the confirmation box and functionality
	**/
	function confirm_action()
	{
		parent.flag_once_focusLast = true;
		
		var m = new MessageBox(xtr.confQ, 2, function(res){
			if (res == 0) action();
		});
		
		if (xtr.center != null)
			m.screenCenter(); 
		else
			m.pos(x, y + 1);
		
		m.openAnimated();
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
						win.screenCenter();
					}
				
					if (xtr.anim != null) {
						win.openAnimated();
					}else {
						win.open(true);
					}
				}
			}
			
		}//- (xtr null check)
		
		callback("fire");
		if (extra_onPush != null) extra_onPush();
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		if (k == "enter" || k == "space") 
		{
			if (xtr != null && xtr.conf != null)
			{
				confirm_action(); // will call action() from there
			}else
			{
				action();
			}
		}
		
		if (flag_leftright_escape)
		{
			if (k == "left") parent.focusPrev();
				else if (k == "right") parent.focusNext(false);
		}

	}//---------------------------------------------------;
	
	/**
	   Chain this to quickly add a function to be called when this button is pushed
	**/
	public function onPush(fn:Void->Void):Button
	{
		extra_onPush = fn;
		return this;
	}//---------------------------------------------------;
	
}// --
