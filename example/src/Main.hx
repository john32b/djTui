package;

import djNode.BaseApp;
import djNode.tools.LOG;
import adapter.*;
import djTui.*;
import djTui.el.*;
import djTui.ext.*;

/**
 * ...
 * @author John Dimi
 */
class Main extends BaseApp 
{

	override function init():Void 
	{
		// Initialize Program Information here.
		PROGRAM_INFO.name  = "djTui development";
		
		// Initialize Program Arguments here.
		// LOG.setLogFile("file.txt", true);
		
		LOG.pipeTrace();
		LOG.setLogFile("a:\\log.txt", true);
		
		super.init();
	}//---------------------------------------------------;
	
	// --
	override function onStart() 
	{
		// This is the user code entry point :
		// ..
		
		T.pageDown();	// Need a pagedown for the windows CLI
		T.clearScreen();
		T.cursorHide();
		
		WM.create(
			new InputObj(), 
			new TerminalObj(), 80, 25
		);
		
		WM.flag_tab_switch_windows = true;
		
		var w1 = new Window();
			w1.size(20, 15);
			WM.center(w1);
			
		var w2 = new Window();
			w2.size(15, 10);
			w2.posNext(w1, 2);
			w2.addLine(new Label("! BLINK !").blink());
			w2.addLine(new Label("---------"));
			w2.addLine(new Label("Scroll_1234_").scroll());
			w2.addLine(new Button("t", "Test"));
			w2.open();
			
		w1.addLine(new Label("Short", 3), "right");
		w1.addLine(new Label("Center Label with a long width", w1.inWidth, "center"));
		w1.addLine(new Button("","Button Link", false));
		w1.addLine(new Button(""," ... ", false));
		w1.addLine(new Label("Toggle :"));
		w1.addLine(new Toggle());
		//w1.addLine(new Label("Number selector :"));
		w1.addLine(new SliderNum("", 1, 10));
		//w1.addLine(new Label("One OF"));
		w1.addLine(new SliderOption('', ['one', 'two', 'three']));
		w1.addLine(new Button("close", "CLOSE"));
		w1.addLine(new Button("open", "OPEN"));
		w1.addLine(new TextInput('',w1.inWidth));
	
		w1.open(true);
		w1.title = "Main win";
		
		w1.callbacks = function(a, b)
		{
			if (a == "fire")
			{
				if (b.SID == "close") w2.close();
				if (b.SID == "open") w2.open();
			}
		}
		
		
		// --
		T.reset();
		T.move(4, WM.height - 2);
		T.print("-- Arrow keys to choose, ENTER to select --");
		T.move(4, WM.height - 1);
		T.print("   -- TAB to switch between windows --");
		
	}//---------------------------------------------------;
	
	
	// --
	override function onExit() 
	{
		T.reset();
		T.move(0, WM.height);
		super.onExit();
	}//---------------------------------------------------;
	
	
	// --
	static function main()  {
		new Main();
	}//---------------------------------------------------;

}// --