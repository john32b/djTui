package;

import djTui.WM;
import djTui.adaptors.openFL.*;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;

/**
 * Showcase and code usage for djTUI
 * --
 * Initialize openFL specific and then start the global demo
 */
class Main_openfl extends Sprite 
{
		
	public function new () 
	{
		super ();
		stage.color = 0xff334455;
		stage.align = StageAlign.TOP_LEFT;
		stage.scaleMode = StageScaleMode.SHOW_ALL;
	
		var term = new TerminalObj();
			term.surface.smoothing = true;
			addChild(term.surface);
		
		WM.create(new InputObj(), term);
		
		var demo = new ShowcaseDemo();
			demo.start();
			
	}//---------------------------------------------------;
	
}// --