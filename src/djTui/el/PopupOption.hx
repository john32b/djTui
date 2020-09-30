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

	// popup window max width
	var w_maxW:Int;
	var w_slots:Int;

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

		// -- Calculate the popup window vars
		w_slots = slots;
		w_maxW = options[0].length;
		for (i in 0...options.length){
			if (options[i].length > w_maxW) w_maxW = options[i].length;
		}

		setSideSymbolPad(0, 1);
		setSideSymbols('[', ']');
		setData(start);

	}//---------------------------------------------------;

	override function onAdded():Void
	{
		super.onAdded();
		createPopup(w_maxW + 1, w_slots);
	}//---------------------------------------------------;


	// --
	function createPopup(_width:Int, slots:Int)
	{
		if (_width < WIN_MIN_WIDTH) _width = WIN_MIN_WIDTH;

		// --
		var s = parent.style;
		win = new Window(parent.style);
		win.modifyStyle({
			bg:s.elem_focus.fg,
			vlist_cursor : {fg:s.elem_idle.bg, bg:s.elem_idle.fg}
		});

		win.padding(0,0).size(_width, slots + 2);
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

	override function onKey(k:String):String
	{
		if ((k == "space" || k == "enter") && !disabled)
		{
			// Open the popup and put it relative to current control.
			list.cursor_to(index);
			win.pos(x + 1, y - Math.floor(win.height / 3));
			parent.openSub(win);
			return "";
		}
		return k;
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