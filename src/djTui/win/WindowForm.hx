package djTui.win;

import djTui.adaptors.djNode.InputObj;
import djTui.Styles.WMSkin;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.SliderNum;
import djTui.el.SliderOption;
import djTui.el.TextInput;
import djTui.el.Toggle;

/**
 * A class for easily creating Forms
 * - can get/set data of entire object
 * - Automatic labels
 * 
 * 
 * NOTES:
 * 
 * 
 *   ►
 *   ◄
 *   ↕
 * ▬
 */
class WindowForm extends Window 
{
	// --
	var labels:Array<Label>;
	
	public function new(_borderStyle:Int=1, ?_skin:WMSkin)
	{
		super(_borderStyle, _skin);
	}//---------------------------------------------------;
	
	
	/**
	   Call this right after new() to enable simple labels before elements
	   Labels are placed on the Left
	   @param	w Width of the labels
	**/
	public function enableLabels(w:Int = 20)
	{
		labels = [];
	}//---------------------------------------------------;
	
	
	/**
	   Add an encoded form ( CSV encoded )
	   - label,text
	   - button,sid,text
	   
	   @param	str type,sid,.....
	**/
	public function addEnc(str:String)
	{
		var b = str.split(',');
		var e:BaseElement = null;
		switch(b[0])
		{
			case 'button':
				e = new Button(b[1], b[2]);
			case 'label':
				e = new Label(b[1], inWidth);
			case 'input':
				e = new TextInput(b[1], inWidth);
			case 'sliderNum':
				e = new SliderNum(b[1], Std.parseInt(b[3]), Std.parseInt(b[4]), Std.parseInt(b[5]));
			case 'sliderOpt':
				e = new SliderOption(b[1], b[2].split('|'));
			case 'popupOpt':
			case 'toggle':
				e = new Toggle(b[1], b[3]=="true");
			default:
				throw "Unsupported";
		}
		addStack(e);
		
	}//---------------------------------------------------;
	
}// --