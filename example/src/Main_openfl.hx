package;

import djTui.WM;
import djTui.adaptors.openFL.*;
import openfl.display.Sprite;
import openfl.display.StageAlign;
import openfl.display.StageScaleMode;
import openfl.events.Event;

/**
 * - OPENFL version of the djTui Demo
 * - WARNING. THIS IS JUST A PROOF OF CONCEPT
 * -          It works, but it is ugly
 */
class Main_openfl extends Sprite 
{
		
	public function new () 
	{
		super ();
        if (stage != null) start(null);
        else addEventListener(Event.ADDED_TO_STAGE, start);

	}//---------------------------------------------------;
	
	public function start(event:Dynamic)
	{
		removeEventListener(Event.ADDED_TO_STAGE, start);
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