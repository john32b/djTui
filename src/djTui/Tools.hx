package djTui;
import haxe.macro.Expr;
import haxe.macro.Context;

/**
 * General Use Tools
 */
class Tools 
{
	
	/**
	   Adds a null check to a function call
	   SafeCall (shortened)
	**/
	macro public static function sCall(cb:Expr,ar:Array<Expr>)
	{
		var e:Expr = {
			expr:ECall(cb, ar),
			pos:Context.currentPos()
		};
		
		return macro { if ($cb != null) $e; };
	}//---------------------------------------------------;
	
	/**
	   Adds a null check to a function, and calls it from a Timer,
	   So it will hop out of the current call stack
	**/
	macro public static function tCall(cb:Expr,ar:Array<Expr>)
	{
		var e:Expr = {
			expr:ECall(cb, ar),
			pos:Context.currentPos()
		};
		
		return macro { if ($cb != null) haxe.Timer.delay(()->$e, 1); };
	}//---------------------------------------------------;
	
	
}// --