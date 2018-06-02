package djTui;

import djTui.BaseElement;
import djTui.Styles.WMSkin;
import djTui.el.Button;
import djTui.el.TextBox;




/**
 * A simple messagebox window
 * 
 * - Text + OK / CANCEL / YES / NO
 * - Callbacks
 */
class MessageBox extends Window 
{
	
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

	// Will close the popup when user selects somethig
	public var flag_auto_close:Bool = true;
	
	/**
	   Create a messagabox window. Does not add it to the WM
	   @param	text
	   @param	_type 0:OK | 1:OK,CANCEL | 2:YES,NO
	   @param	_resCallback fn(int) -> index of button clicked
	   @param	_width
	**/
	public function new(text:String, _type:Int, ?_resCallback:Int->Void, _width:Int = 30 ) 
	{
		super(2);
		mbType = _type;
		resultCallback = _resCallback;
		flag_focus_lock = true;
		
		// - Create textbox
		tbox = new TextBox(_width - 2, 0);
		tbox.setData(text);
		tbox.flag_focusable = false;
		
		// - Create Buttons
		
		buttons = [];
		
		switch(mbType)
		{
			case 0: 
				button("OK");
			case 1:
				button("OK");
				button("CANCEL");
			case 2:
				button("YES");
				button("NO");
			default:
		}
		
		
		// - Window
		size(_width, tbox.height + 5);
		addStack(tbox, 1);
		addStackCentered(cast buttons, 1, 3);
	}//---------------------------------------------------;
	
	override function onElementCallback(st:String, el:BaseElement) 
	{
		super.onElementCallback(st, el);
		
		if (st == "fire")
		{
			if (resultCallback != null)
			{
				resultCallback(buttons.indexOf(cast el));
			}
			
			if (flag_auto_close)
			{
				close();
			}
		}
		
	}//---------------------------------------------------;
	
	function button(name:String)
	{
		var b = new Button(null, name, true, 4);
		buttons.push(b);
	}//---------------------------------------------------;
	
}// --