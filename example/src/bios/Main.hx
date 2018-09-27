package bios;

import djNode.BaseApp;
import djNode.tools.LOG;

import djTui.*;
import djTui.el.*;
import djTui.ext.*;
import djTui.win.ButtonGrid;
import djTui.win.WindowForm;
import djTui.adaptors.djNode.*;


/**
 * Fake Bios Settings Screen
 * Simulate a bios screen to showcase the various elements
 * and functionalities
 * ...
 */
class Main extends BaseApp 
{

	override function init():Void 
	{
		// Initialize Program Information here.
		PROGRAM_INFO.name  = "djTui Bios Settings";
		
		// Initialize Program Arguments here.
		#if debug
		LOG.pipeTrace();
		LOG.setLogFile("a:\\log.txt", true);
		#end
		
		super.init();
	}//---------------------------------------------------;
	
	// --
	// This is the user code entry point :
	override function onStart() 
	{
		// Initialize the Terminal
		T.pageDown();	
		T.clearScreen();
		T.cursorHide();
		//--
		
		// Create/Init the Window Manager
		WM.create(
			new InputObj(), 
			new TerminalObj(), 80, 25
			
		);
		
		WM.setBgColor("blue");
		
		// -- Start Creating the windows
		
		MessageBox.create("Welcome to a djTui, this is a fake bios screen", 0, null, 40);
		
	}//---------------------------------------------------;

	// --
	override function onExit() 
	{
		T.move(0, WM.height);
		super.onExit();
	}//---------------------------------------------------;
	
	// --
	static function main()  {
		new Main();
	}//---------------------------------------------------;

}// --