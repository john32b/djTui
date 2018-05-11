/**--------------------------------------------------------
 * StrTool.hx
 * @author: johndimi, <johndimi@outlook.com> , @jondmt
 * --------------------------------------------------------
 * @Description
 * -------
 * General purpose StringTools
 * 
 * @Notes
 * ------
 * 
 ========================================================*/

package djTui;

/** 
 * Singleton Global helper for various string operations
 */
class StrTool
{
	
	/**
	 * Converts bytes to megabytes. Useful for creating readable filesizes.
	 * 
	 * @param	bytes Number of bytes to convert
	 * @return  The converted bytes to string format.
	 */
	public static function bytesToMBStr(bytes:Int):String {
		return Std.string( Math.ceil( bytes / (1024 * 1024)));
	}//---------------------------------------------------;
	
	
	/**
	 * Pads a string with spaces to reach a target length.
	 * If string is larger than length, the string is cut.
	 * 
	 * @param	str	String to pad
	 * @param	length Target length
	 * @param	align Optional alignment, [left|right|center]
	 * @return  the padded string.
	 */
	public static function padString(str:String, length:Int, align:String = "left"):String
	{
		var b:Int = length - str.length;
		
		// String already in target length
		if (b == 0) return str;
		
		// The string needs to be cut
		if (b < 0) {
			return str.substring(0, length - 1) + "~";
		}	
		
		// The string needs to be padded
		switch (align) 
		{
			case "left":
				str = StringTools.rpad(str, " ", length);
			
			case "right":
				str = StringTools.lpad(str, " ", length);
			
			case "center":
				var _l = Math.ceil(b / 2);
				var _r = Math.floor(b / 2);
				str = 	StringTools.rpad("", " ", _l ) +
						str +
						StringTools.rpad("", " ", _r );
		}
		
		return str;
	}//---------------------------------------------------;
	
	
	

	/**
	 * Cut a string in words creating lines of target width, pushes
	 * those lines to a new array.
	 * 
	 * e.g. 
	 *   wordFillArray("hello world this is a test",7) =
	 *                [ "hello","world","this is","a test" ]
	 * 
	 * @param	str The string to be sliced
	 * @param	width Target width of the lines
	 * @return  The created Array
	 */
	
	public static function splitToLines(str:String, width:Int):Array<String>
	{
		// Replace /n with the custom placeholder string #nl#
		str = ~/(\n)/g.replace(str, " #nl# ");
		// Replace any whitespace with ' ' for safeguarding
		str = ~/(\s|\t)/g.replace(str, " ");
		
		// Break string to an array, for easy traversing	
		var ar = str.split(" ");
	
		var result:Array<String> = [];
		
		// Helper vars
		var f = 0;
		var fmax = ar.length;
		var clen = 0;	// current temp line length
		var line = "";  // temp line
		var _ll = 0;
		
		// Reduce redundancy by creating this internal function
		var ___ffpush = function(s:String) {
			result.push(s);
			clen = 0; line = "";
		};
		
		// Start processing all words in the array
		do {
			
			// if word is a new line, add a blank line to the array
			if (ar[f] == '#nl#') {
				___ffpush(line);
				continue;
			}
			
			// Store current word length, don't calculate it each time
			_ll = ar[f].length;
			
			// if line length is less than target width, it fits ok.
			if ((_ll + clen) < width)
			{
				line += ar[f] + " ";
				clen += _ll + 1;
			}
			else if ((_ll + clen) > width)	// Longer than what line can fit
			{
				// Push current line, add the word that didn't fit to next line
				if (clen > 0)
				{
					result.push(line);
					line = ar[f] + " ";
					clen = _ll + 1;
				}else
				{
					// if a word is TOO BIG and can't fit, trim it.
					line = ar[f].substring(0, width - 1) + "~";
					___ffpush(line);
				}
			}
			else // line is equal to target width, just add it with no blank space afterwards
			{
				___ffpush(line + ar[f]);
			}

		}while (++f < fmax); //-- end loop --//
		
		// post-loop check for any unprocessed data
		if (clen > 0) ___ffpush(line);
		
		return result;
	}//---------------------------------------------------;
	


	/**
	 * Creates a new string filled with a character X many times.
	 * @deprecated You can use StringTools.lpad instead.
	 * 
	 * @param	width How many times the char will be repeated in the string.
	 * @param	char Character to be repeated.
	 */
	public static function repeatStr(length:Int,char:String):String
	{
		var ar = new Array<String>();
		while (length-->0)
			ar.push(char);
		return ar.join("");
	}//---------------------------------------------------;
	
	
	/**
	 * Loops a string to itself, useful for scrolling effects
	 * 
	 * @param	source The string to be looped
	 * @param	length The length which the source will be wrapped to
	 * @param	offset Offset for scrolling. no limit at the int.
	 * @return
	 */
	public static function loopString(source:String, length:Int, offset:Int):String
	{
		var str:String = "";
		var _loopCounter = 0;
		
		while (_loopCounter < length) {
			// I use Modulo to stay in bounds of the source string
			str += source.charAt((_loopCounter + offset) % source.length);
			_loopCounter++;
		}
		
		return str;
	}//---------------------------------------------------;
	
	
}//-- end --//
