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
 * - Buttons will always be `center` aligned within target width
 * 
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
	static var S = [ "<>", "[]" , "{}" , "()", "«»" ];
	
	// Confirmation default question
	static var CONF_DEF = "Are you sure?";
	
	/** Global for all buttons, padding between symbol and text, 0 for no space. e.g. [BUTTON]
	    Set this before creating any button */
	public static var SYMBOL_PAD:Int = 1;
	
	/** The source text, ( not the rendered text )
	    You can assign new values to this, ~uses setter~ */
	public var text(default, set):String;
	
	// Enable button symbol mode
	// False for normal link mode
	var flag_btnStyle:Bool;
	
	// Current button symbol index
	var btn_smb:Int;
	
	// Target width for the button. 0 for Autosize
	var targetWidth:Int;
	
	/**
	   Stores extra functionality parameters
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
	
	
	/**
	   Creates a button/clickable text link
	   @param	sid SID You can include SPECIAL functionality here. It's the same as calling extra(..) later
	   @param	Text The text to display
	   @param	BtnStyle IF > 0 Will enable Button Style text with symbol. "1:<>,2:[],3:{},4:(),5:«»"
	   @param   TargetWidth 0 for Autosize
	**/
	public function new(sid:String, Text:String, BtnStyle:Int = 0, TargetWidth:Int = 0)
	{
		super(sid);
		#if debug
			if (BtnStyle > 5) BtnStyle = 5;
		#end
		type = ElementType.button;
		height = 1;
		targetWidth = TargetWidth; // autosize
		btn_smb = BtnStyle;
		flag_btnStyle = BtnStyle > 0;
		text = Text;
		
		// - Capture Tags on SID
		
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
		
		callbacks("fire", this);
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
		
		// NOTE: 
		// right and left keys will not get pushed to this object
		// when inside a <ButtonGrid>
		else if (k == "left") callbacks("focus_prev", this);
		else if (k == "right") callbacks("focus_next", this);
	}//---------------------------------------------------;
	

	/** 
	 * SETTER 
	 - Sets the text of the button */
	function set_text(val)
	{
		/* If for whatever reason you want to rename a button, and the new text is shorter
		   than the old text, clear the space behind it, so the text doesn't overlap */
		if (text != null && targetWidth == 0 && cast(val, String).length < text.length && visible)
		{
			clear();
		}
		
		text = val;
		
		if (flag_btnStyle)
		{
			rText = S[btn_smb].charAt(0);
			if (targetWidth > 0)
			{
				rText += StrTool.padString(text, targetWidth - 2, "center");
			}else
			{
				var pad = StringTools.lpad("", " ", SYMBOL_PAD); 
				rText +=  pad + text + pad;
			}
			rText += S[btn_smb].charAt(1);
		}
		else
		{
			if (targetWidth > 0)
			{
				rText = StringTools.rpad(rText, " ", targetWidth);
			}else
			{
				rText = text;
			}
		}
		
		width = rText.length;
		
		if (visible) draw();
		
		return val;
	}//---------------------------------------------------;
	
}// --
