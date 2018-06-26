package djTui.el;

import djTui.BaseElement;
import djTui.MessageBox;

/**
 * Text Button
 * ----------
 * - Text that can be highlighted and selected
 * - Button style for displaying text inside button like symbols [ ] 
 * - Callbacks "fire" status when selected
 * - Buttons will always be `center` aligned within target width
 */ 
class Button extends BaseMenuItem 
{
	// Button Style Symbols
	static var S = [ "<>", "[]" , "{}" , "()", "«»" ];
	
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
	
	/** Auto Confirmation Parameters. use .confirm() to enable
	 {
		text:String = Custom Question to Present
		center:Bool = True for screen center
	 } */
	var conf:Dynamic = null;
	
	// Defaults for the confirmation
	static var conf_DEFAULTS:Dynamic = {
		text:"Are you Sure?",
		center:false
	};
	
	
	/**
	   Creates a button/clickable text link
	   @param	sid SID
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
	}//---------------------------------------------------;
	
	
	/**
	   Set this button to automatically ask a YES/NO question upon being selected
	   @param	text Optional Custom Question to present
	   @param	center True to center the messagebox on screen
	   @return
	**/
	public function confirm(?text:String, ?center:Bool):Button
	{
		conf = Tools.copyFields({text:text, center:center}, conf_DEFAULTS);
		return this;
	}//---------------------------------------------------;
	
	/**
	   Present the confirmation box and functionality
	**/
	function confirm_do()
	{
		var m = new MessageBox(conf.text, 2, function(res){
			if (res == 0) callbacks("fire", this);			
		});
		
		if (conf.center) 
			m.screenCenter(); 
		else
			m.pos(x, y + 1);
		
		m.openAnimated();
		
	}//---------------------------------------------------;
	
	// --
	override function onKey(k:String):Void 
	{
		if (k == "enter" || k == "space") 
		{
			if (conf != null) {
				confirm_do();
			} else {
				callbacks("fire", this);
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