package djTui.win;

import djTui.BaseElement;
import djTui.Styles.WinStyle;
import djTui.Window;
import djTui.el.Button;
import djTui.el.TextBox;


/**
 * A simple messagebox window
 * 
 * - Text + OK / CANCEL / YES / NO
 * - Callbacks via `resultCallback`
 */
class MessageBox extends Window 
{
	// MessageBox Type
	// 0 - OK
	// 1 - OK - CANCEL
	// 2 - YES - NO
	var mbType:Int;
	
	// Main text goes here
	var tbox:TextBox;
	
	// Buttons are variable and depend on "type"
	var buttons:Array<Button>;
	
	// 0: OK,YES
	// 1: NO,CANCEL
	public var resultCallback:Int->Void;

	/** Will close the popup when user selects something */
	public var flag_auto_close:Bool = true;
	
	// Global button style for the buttons
	public static var BUTTON_STYLE:Int = 2;
	
	/**
	   Create a messagebox window.
	   @param	text
	   @param	_type 0:OK | 1:OK,CANCEL | 2:YES,NO | 3:NOTHING
	   @param	_resCallback fn(int) -> index of button clicked
	   @param	_width
	**/
	public function new(text:String, _type:Int, ?_resCallback:Int->Void, _width:Int = 30, ?_style:WinStyle) 
	{
		if (_style == null) _style = WM.global_style_pop;
		super(_style);
		
		mbType = _type;
		resultCallback = _resCallback;
		flag_lock_focus = true;
		padding(1, 0);
		
		// - Create the textbox
		tbox = new TextBox(_width - padX * 2, 0);
		tbox.setData(text);
		tbox.flag_focusable = false;
		
		// - Create Buttons
		buttons = [];
		
		switch(mbType)
		{
			case 0: 
				add_b("OK");
			case 1:
				add_b("OK");
				add_b("CANCEL");
			case 2:
				add_b("YES");
				add_b("NO");
			case 3:
				
			default:
		}
		
		// - Window
		size(_width, tbox.height + 5);
		addStack(tbox, 1);
		addStackInline(cast buttons, 1, 3, "center");
		
		// In case of no buttons, there is no last added
		if (lastAdded != null) hack_always_focus_this = lastAdded.SID;
	}//---------------------------------------------------;
	
	override function onElementCallback(st:String, el:BaseElement) 
	{
		super.onElementCallback(st, el);
		
		if (st == "fire")
		{
			if (flag_auto_close)
			{
				close();
			}
						
			if (resultCallback != null)
			{
				resultCallback(buttons.indexOf(cast el));
			}

		}
		
	}//---------------------------------------------------;
	
	// Quickly add a button
	function add_b(name:String)
	{
		var b = new Button(null, name, BUTTON_STYLE);
		b.flag_leftright_escape = true;
		buttons.push(b);
	}//---------------------------------------------------;
	
	
	/**
	   Quickly create and open a MessageBox at the center of the screen
	   This is the same as creating and opening
	   @param	text
	   @param	_type 0:OK | 1:OK,CANCEL | 2:YES,NO
	   @param	_resCallback fn(int) -> index of button clicked
	   @param	_width
	**/
	public static function create(text:String, _type:Int, ?_resCallback:Int->Void, _width:Int = 30, ?_style:WinStyle, animated:Bool = false ):Window
	{
		var m = new MessageBox(text, _type, _resCallback, _width,_style);
			WM.A.screen(m);
			if (animated) m.openAnimated(); else m.open(true);
			return m;
	}//---------------------------------------------------;
	
}// --