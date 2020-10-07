/********************************************************************
 * A Simple MessageBox Window
 *
 * - Text + OK / CANCEL / YES / NO
 * - Callbacks via `onSelect`
 *
 *******************************************************************/

package djTui.win;

import djTui.BaseElement;
import djTui.Styles.WinStyle;
import djTui.WM;
import djTui.Window;
import djTui.el.Button;
import djTui.el.TextBox;


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
	// 1: OK,CANCEL
	// 2: YES,NO
	public var onSelect:Int->Void;

	// Will close the popup when user selects something.
	public var flag_auto_close:Bool = true;

	// Global button style for the buttons
	public static var BUTTON_STYLE:Int = 1;

	// Will always focus the last button added at first
	public static var FOCUS_LAST:Bool = false;

	/**
	   Create a messagebox window
	   @param	text
	   @param	_type 0:OK | 1:OK,CANCEL | 2:YES,NO | 3:NOTHING, CLOSE ON ESC | -1:NOTHING, LOCK KEYS
	   @param	_onSelect fn(int) -> index of button clicked
	   @param	_width
	   @param	_style
	**/
	public function new(text:String, _type:Int, ?_onSelect:Int->Void, _width:Int = 30, ?_style:WinStyle)
	{
		if (_style == null) _style = WM.global_style_pop;
		super(_style);

		mbType = _type;
		onSelect = _onSelect;
		focus_lock = true;
		padding(1, 0);

		// - Create the textbox message
		tbox = new TextBox(_width - 2, 0);	// Note: I can't use inwidth, it is not ready yet
		tbox.setData(text);
		tbox.focusable = false;

		// - Create Buttons
		buttons = [];
		switch (mbType) {
			case -1:
				// Do not close on esc
			case 0:
				add_b("OK");
			case 1:
				add_b("OK");
				add_b("CANCEL");
			case 2:
				add_b("YES");
				add_b("NO");
			default:
				flag_close_on_esc = true;
		}

		// - Window
		size(_width, tbox.height + 5);
		addStack(tbox, 1);
		addStackInline(cast buttons, 1, 3, "c");

		// Focus the last button added ( if any )
		if (FOCUS_LAST && lastAdded != null)
			hack_always_focus_this = lastAdded.SID;

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

			if (onSelect != null)
			{
				onSelect(buttons.indexOf(cast el));
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
	   Quickly create a MessageBox at the center of the screen
	   - DOES NOT OPEN IT !
	   @param	text
	   @param	_type 0:OK | 1:OK,CANCEL | 2:YES,NO
	   @param	_onSelect fn(int) -> index of button clicked
	   @param	_width
	**/
	public static function create(text:String, _type:Int, ?_onSelect:Int->Void, _width:Int = 30, ?_style:WinStyle):Window
	{
		var m = new MessageBox(text, _type, _onSelect, _width, _style);
			WM.A.screen(m);
			return m;
	}//---------------------------------------------------;

}// --