package djTui;

/**
 * General Use Tools
 */
class Tools 
{

	/**
	 * <IN PLACE> Copy an object's fields into target object. Overwrites the target object's fields. 
	 * Can work with Static Classes as well (as destination)
	 * @param	node The Master object to copy fields from
	 * @param	into The Target object to copy fields to
	 * @return	The resulting object
	 */
	public static function copyFields(from:Dynamic, into:Dynamic):Dynamic
	{
		if (from == null)
		{
			// trace("Warning: No fields to copy from source, returning destination object");
			return into;
		}
		
		if (into == null) 
		{
			trace("Warning: No fields on the target, copying source object");
			into = Reflect.copy(from);
		}else
		{
			for (f in Reflect.fields(from)) {
				if (Reflect.field(from, f) != null)
					Reflect.setField(into, f, Reflect.field(from, f));
			}
		}
		
		return into;
	}//---------------------------------------------------;
	
	
	//--
	public static function isEmpty(str:String):Bool
	{
		return (str==null || str.length==0);
	}//---------------------------------------------------;
	
	
	public static function randAr<T>(ar:Array<T>):T
	{
		return ar[Std.random(ar.length)];
	}
	
}// --