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
	
	// Max Width the number string can get to
	var maxW:Int;
	
	// The popup window
	var win:Window;
	
	// The list on the window
	var list:VList;
	
	/**
	   @param	sid  --
	   @param	src  Array with choices
	   @param	init Initial Index
	   @param	slits Force this many slots to the popup window list
	**/
	public function new(sid:String, src:Array<String>, init:Int = 0, slots:Int = 4)
	{
		super(sid);
		type = ElementType.option;
		options = src.copy(); // safer this way
		// -- calculate the max width of options
			maxW = options[0].length;
			for (i in 0...options.length){
				if (options[i].length > maxW) maxW = options[i].length;
			}
		setData(init);
		size(maxW + 2, 1);
		createPopup(maxW, slots);
	}//---------------------------------------------------;
	
	// --
	function createPopup(_width:Int, slots:Int)
	{		
		if (_width < WIN_MIN_WIDTH) _width = WIN_MIN_WIDTH;
		// --
		win = new Window(1);
		win.padding(1, 1).size(_width, slots + 2);
		win.flag_focus_lock = true;
		
		// --
		list = new VList("list", win.inWidth, win.height - 2);
		win.addStack(list);
		list.setData(options);
		
		win.callbacks = function(status, elem)
		{
			switch(status) {
				case "escape" : 
					win.close();
				case "fire" :
					setData(elem.getData());
					win.close();
					callbacks("change", this);
			}
		}// --
	}//---------------------------------------------------;
	
	override function onKey(k:String):Void 
	{
		if (k == "space" || k == "enter")
		{
			win.pos(x + 1, y - Math.floor(win.height / 3));
			list.cursor_to(index);
			parent.flag_once_focusLast = true;
			win.open(true);
		}
	}//---------------------------------------------------;
	
	override public function draw():Void 
	{
		super.draw();
		WM.T.move(x, y).print("[");
		WM.T.move(x + options[index].length + 1, y).print("]");
	}//---------------------------------------------------;
	
	
	// --
	// Sets current selected INDEX
	override public function setData(val:Any) 
	{
		index = val;
		rText = ' ' + 
				StrTool.padString(options[index], maxW + 1, "left");
	}//---------------------------------------------------;
	
	// --
	// Read current selected INDEX
	override public function getData():Any 
	{
		return index;
	}//---------------------------------------------------;
}// --