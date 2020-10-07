package djTui.win;

import djTui.Styles.WinStyle;
import djTui.Window;
import djTui.el.Label;

/**
 * Quickly create windows for use as headers/footers
 * 
 * - Width is always SCREENWIDTH
 */
class WindowLabel extends Window
{

	/**

	   @param text
	   @param _style
	   @param _pb  Quick Set of [borderStyle, PadX, PadY]
	   @param _col Quick Set of [FgColor, BgColor]
	**/
	public function new(texts:Array<String>, align:String = "l", ?_style:WinStyle, ?_pb:Array<Int>, ?_col:Array<String>)
	{
		super(null, 10, 10, _style);

		if (_pb != null)
		{
			borderStyle = _pb[0];
			padding(_pb[1], _pb[2]);
		}

		if (_col != null)
		{
			modifyStyle({
				text:_col[0], bg:_col[1], borderColor:{fg:_col[0],bg:_col[1]}
			});
		}

		size( -1, texts.length + padY * 2);
		focusable = false;
		for (t in texts) {
			var l = new Label(t, inWidth, align);
			addStack(l);
		}
	}//---------------------------------------------------;

	public function placeBottom():WindowLabel
	{
		pos(0, WM.height - this.height);
		return this;
	}
}