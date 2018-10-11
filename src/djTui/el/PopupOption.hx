package djTui.el;
import djTui.Window;

/**
 * Select an option from a list of options 
 * - Works Just like <SliderOption> but this has another interaction method
 * - Upon selecting it, it will present a popup window with all the available options
 */
class PopupOption extends BaseMenuItem 
{
	static inline var WIN_MIN_WIDTH:Int = 15;
	
	// The source options 
	var options:Array<String>;
	// Hold the currently selected index
	var index:Int;
	// The popup window
	var win:Window;
	// The list on the window
	var list:VList;
	
	/**
	   @param	sid  --
	   @param	src  Array with choices
	   @param	start Initial Index
	   @param	slots Force this many slots to the popup window list
	**/
	public function new(sid:String, src:Array<String>, slots:Int = 4, start:Int = 0)
	{
		super(sid);
		type = ElementType.option;
		options = src.copy(); // safer this way
		height = 1;
			// -- Calculate the max width of options
			var maxW = options[0].length;
			for (i in 0...options.length){
				if (options[i].length > maxW) maxW = options[i].length;
			}
		createPopup(maxW + 1, slots);
		setSideSymbolPad(0, 1);
		setSideSymbols('[', ']');
		setData(start);
		
	}//---------------------------------------------------;
	
	override function onAdded():Void 
	{
		super.onAdded();
	}//---------------------------------------------------;
	
	
	// --
	function createPopup(_width:Int, slots:Int)
	{		
		if (_width < WIN_MIN_WIDTH) _width = WIN_MIN_WIDTH;
		
		// --
		win = new Window(1);
		win.padding(1, 1).size(_width, slots + 2);
		win.flag_lock_focus = true;
		win.flag_close_on_esc = true;
		
		// --
		list = new VList("list", win.inWidth, win.height - 2);
		list.setData(options);
		
		win.addStack(list);
		win.listen(function(status, elem)
		{
			switch(status) {
				case "fire" :
					setData(elem.getData());
					win.close();
					callback("change");
			}
		});//--
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if ((k == "space" || k == "enter") && !disabled)
		{
			// Open the popup and put it relative to current control.
			list.cursor_to(index);
			win.pos(x + 1, y - Math.floor(win.height / 3));
									  // TODO: Other style?
			win.style = parent.style; // Make sure the popup takes the parent window style
			parent.openSub(win);
		}
	}//---------------------------------------------------;
	
	// --
	// Sets current selected INDEX
	override public function setData(val:Any) 
	{
		index = val;
		text = options[index];
	}//---------------------------------------------------;
	
	// --
	// Read current selected INDEX
	override public function getData():Any 
	{
		return index;
	}//---------------------------------------------------;
}// --