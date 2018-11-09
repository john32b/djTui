package djTui.adaptors.openFL;

import djTui.adaptors.ITerminal;
import openfl.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.Lib;
import openfl.Vector;
import openfl.display.Stage;
import openfl.geom.Rectangle;

/**
 * Render Interface for OpenFL
 * 
 * 
 */

class TerminalObj implements ITerminal
{
	// Associate Terminal Color codes with Real colors
	static var colorMap:Map<String,Int> = [
		"black" => 0xFF020202,
		"white" => 0xFFFFFFFF,
		"gray" => 0xFFAAAAAA,
		"blue" => 0xFF0000FF,
		"red" => 0xFFFF0000,
		"green" => 0xFF00FF00,
		"cyan" => 0xFF00FFFF,
		"magenta" => 0xFFFF00FF,
		"yellow" => 0xFFFFFF00,
		"darkgray" => 0xFF404040,
		"darkblue" => 0xFF000080,
		"darkred" => 0xFF800000,
		"darkgreen" => 0xFF008000,
		"darkcyan" => 0xFF008080,
		"darkmagenta" => 0xFF800080,
		"darkyellow" => 0xFF808000
	];
	
	static var DEFAULT_COL_BG:String = "black";
	static var DEFAULT_COL_FG:String = "white";
	
	inline static var DEF_FONT = "Fixedsys";
	inline static var DEF_FONT_SIZE = 12;
	inline static var DEF_BL_W = 13;
	inline static var DEF_BL_H = 18;
		
	// Report client size:
	public var MAX_WIDTH:Int;
	public var MAX_HEIGHT:Int;
	
	// The actual surface that the fake terminal will be rendered to
	public var surface:Bitmap;
	
	// Pointer to surface bitmapdata
	var bitmap:BitmapData;	
	
	// --
	var cur_x:Int = 0;
	var cur_y:Int = 0;
	
	var saved_x:Int = 0;
	var saved_y:Int = 0;
	
	var col_fg:String;
	var col_bg:String;
	
	var cur_bold:Bool;
	var cur_italic:Bool;
	
	var font_Size:Int;
	var cur_width:Int;
	var cur_height:Int;
	
	// - Helpers 
	var tf:TextField;
	var mat:Matrix;
	var rect:Rectangle;
	var col_bg_real:Int;
	
	/**
	   
	   @param	_width Render Area, will automatically set MAX_WIDTH
	   @param	_height Render Area, will automatically set MAX_HEIGHT
	   @param	fontName A build in system font
	   @param	fontSize Font Size
	   @param	blWidth Background cell size
	   @param	blHeight Background cell size
	**/
	public function new(_width:Int = 0, _height:Int = 0, 
						fontName:String = DEF_FONT, fontSize:Int = DEF_FONT_SIZE, 
						blWidth:Int = DEF_BL_W, blHeight:Int = DEF_BL_H )
	{
		if (_width == 0) _width = Lib.current.stage.stageWidth;
		if (_height == 0) _height = Lib.current.stage.stageHeight;
	
		cur_width = blWidth;
		cur_height = blHeight;
		
		MAX_WIDTH = Std.int(_width / cur_width);
		MAX_HEIGHT = Std.int(_height / cur_height);
		
		mat = new Matrix();
		rect = new Rectangle(0, 0, cur_width, cur_height);
		
		surface = new Bitmap();
		surface.bitmapData = new BitmapData(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight, true, 0xFF000000);
		bitmap = surface.bitmapData;
		
		var tform = new TextFormat();
			tform.font = fontName;
			tform.size = font_Size;
			tform.blockIndent = 0;
			tform.letterSpacing = 0;
		
		tf = new TextField();
		tf.multiline = false;
		tf.sharpness = 400;
		tf.defaultTextFormat = tform;

		reset();
		
		trace('OpenFL Terminal Interface \n - WIDTH:$MAX_WIDTH, HEIGHT:$MAX_HEIGHT, FONT:$fontName, SIZE:$fontSize');
	}//---------------------------------------------------;
	

	// Save the current cursor position
	public function saveCursor():Void
	{
		saved_x = cur_x;
		saved_y = cur_y;
	}
	
	// Restore the previously saved cursor position
	public function restoreCursor():Void
	{
		cur_x = saved_x;
		cur_y = saved_y;
	}
	
	// Sets the cursor to be this character. (e.g. "-")
	public function setCursorSymbol(s:String):Void
	{
		// TODO
	}
	
	
	function getColor(id:String):Int
	{
		try{
			return colorMap.get(id);
		}catch (e:Dynamic){
			return 0xFF00FFFF;
		}
	}
	
	
	// Puts text at current cursor position with currently set FG and BG colors
	public function print(s:String):ITerminal
	{
		
		for (xx in 0...(s.length))
		{
			// - BG
			rect.x = cur_x * (cur_width);
			rect.y = cur_y * (cur_height);
			bitmap.fillRect(rect, col_bg_real);
			
			// - FG
			if (s.charAt(xx) != " ") 
			{
				tf.text = s.charAt(xx);
				mat.tx = cur_x * cur_width - 1;
				mat.ty = cur_y * cur_height - 1;
				bitmap.draw(tf, mat);
			}
			
			cur_x ++;
		}
		
		return this;
	}//---------------------------------------------------;
	
	
	// Move the cursor to X,Y 
	public function move(x:Int, y:Int):ITerminal
	{
		cur_x = x;
		cur_y = y;
		return this;
	}
	
	// Move RELATIVE to where the cursor is now
	public function moveR(x:Int, y:Int):ITerminal
	{
		cur_x += x;
		cur_y += y;
		return this;
	}
	
	// Set the active foreground color
	public function fg(col:String):ITerminal
	{
		col_fg = col;
		tf.textColor = getColor(col_fg);
		return this;
	}

	// Set the active background color
	public function bg(col:String):ITerminal
	{
		col_bg = col;
		col_bg_real = getColor(col_bg);
		return this;
	}
	
	public function resetFG():ITerminal
	{
		return fg(DEFAULT_COL_FG);
	}
	
	public function resetBG():ITerminal
	{
		return bg(DEFAULT_COL_BG);
	}
	
	public function reset():ITerminal
	{
		resetBG(); resetFG();
		bold(false); italics(false);
		return this;
	}
	
	public function bold(state:Bool):ITerminal
	{
		cur_bold = state;
		return this;
	}
	
	public function italics(state:Bool):ITerminal
	{
		cur_italic = state;
		return this;
	}
	
}