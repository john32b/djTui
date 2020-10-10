/********************************************************************
 * A horizontal bar displaying help on the controls
 *
 * Example:
 *
 * 		var foot = new ControlsHelpBar();
 *			foot.setData('Nav:←↑→↓|Select:Enter|Focus:Tab|Quit:^c');
 *			foot.pos(0, HEIGHT - 1);
 *
 *******************************************************************/

package djTui.win;

import djA.DataT;
import djTui.Styles.WinStyle;
import djTui.Window;
import djTui.el.Label;

class ControlsHelpBar extends Window
{
	// Styling Parameters
	var ST = {
		bg:null,		// Window Background Color. null for WM default window style bg color
		textfg:"white",
		textbg:"darkblue",
		align:"l",		// Alignment of strip in the window (l:lect,c:center)
		pad:1,			// Padding between elements
		smb:"[]"		// Symbols to encapsulate the keys with. (Left,Right characters)
	};

	var labels:Array<Label>;

	/**
	   @param	Width of the strip
	   @param	P Check `ST` for details. You can override fields or null for defaults
	**/
	public function new(Width:Int = -1, P:Dynamic = null)
	{
		super(null, Width, 1);
		focusable = false;
		borderStyle = 0;
		ST = DataT.copyFields(P, ST);
		if (ST.bg != null){
			modStyle({bg:ST.bg});
		}
	}//---------------------------------------------------;

	/**
	   Add help labels in the form of "next:Tab", it will be drawn as `next [Tab]`
	   @param	val Array<String> or <String> separated with "|"
	**/
	override public function setData(val:Any):Void
	{
		var S:Array<String>;
		if (Std.is(val, String)) {
			S = cast(val, String).split('|');
		}else{
			S = cast val; // Assumes it IS Array of strings. Should I check?
		}

		lockDraw = true; // do not draw anything, It will draw at the end

		// -- remove old labels
		if (labels != null) {
			removeAll();
		}
		labels = [];
		for (s in S)
		{
			var p = s.split(":");
			var l = new Label(p[0] + " " + ST.smb.charAt(0) + p[1] + ST.smb.charAt(1));
			l.setColor(ST.textfg, ST.textbg);
			labels.push(l);
		}
		lockDraw = false;
		WM.T.reset().bg(style.bg);
		WM.D.rect(x, y, width, height);
		addStackInline(cast labels, 0, ST.pad, ST.align);
	}//---------------------------------------------------;

}//--