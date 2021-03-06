package;

import djNode.BaseApp;
import djNode.tools.LOG;
import djTui.Styles;
import djTui.WM;
import djTui.adaptors.djNode.*;
import djTui.win.MessageBox;

/**
 * DJTui Demo/Showcase
 * - Initializes nodeJS specific code 
 * - Creates the main Demo object
 */
class Main_nodejs extends BaseApp 
{
	
	// Initialize Program Information / Arguments here.
	// --
	override function init():Void 
	{
		PROGRAM_INFO.name  = "djTui development";
		
		#if debug
		LOG.pipeTrace(); // all traces will redirect to LOG object
		LOG.setLogFile(REG.LOG_FILE);
		#end
		super.init();
	}//---------------------------------------------------;
	
	
	// This is the user code entry point :
	// --
	override function onStart() 
	{
		// Initialize the Terminal
		T.pageDown();
		T.clearScreen();
		T.cursorHide();
		T.resizeTerminal(REG.APP_WIDTH, REG.APP_HEIGHT);
		
		// Init the Window Manager and set some parameters :
		WM.create(
			new InputObj(), 
			new TerminalObj(), 
			REG.APP_WIDTH, REG.APP_HEIGHT
		);
		
		// --
		var demo = new ShowcaseDemo();
			demo.start();
	}//---------------------------------------------------;

	// --
	override function onExit(code:Int) 
	{
		if (WM._isInited) T.move(0, WM.height); // Hack for real terminals
		super.onExit(code);
	}//---------------------------------------------------;
	
	
	// --
	// I don't really need this but why not.
	override function exitError(text:String, showHelp:Bool = false):Void 
	{
		if (WM._isInited)
		{
			var m = new MessageBox(
				"CRITICAL ERROR:\n" + text, 0, 
				function(a){Sys.exit(1); }, 
				WM.width - 10, Styles.win.get("red.1")
				);
			WM.A.screen(m);
			m.open(true);		
		}
		else
		{
			super.exitError(text, showHelp);
		}
	}//---------------------------------------------------;
	
	// --
	static function main() {
		new Main_nodejs();
	}//---------------------------------------------------;
	
}// --