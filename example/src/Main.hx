package;

import djNode.BaseApp;
import djNode.tools.LOG;

class Main extends BaseApp
{	
	override function init():Void 
	{
		// Initialize Program Information here.
		PROGRAM_INFO.name  = "Template";
		
		// Initialize Program Arguments here.
		// ARGS.requireAction = "false";
		// ARGS.inputRule = "no";
		// ...
		
		
		// Initialize LOG here:
		// LOG.setLogFile("file.txt", true);
		
		super.init();
	}//---------------------------------------------------;
	
	// --
	override function onStart() 
	{
		// This is the user code entry point :
		// ..
		
		printBanner();
	
	}//---------------------------------------------------;
	
	// --
	static function main()  {
		new Main();
	}//---------------------------------------------------;
	
}// --