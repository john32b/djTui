package djTui;
import djTui.BaseElement;
import djTui.Window;

class WindowEvents 
{
	// The window object this is attached to
	var win:Window;
	
	public function new(W:Window)
	{
		win = W;
	}//---------------------------------------------------;
	
	// Trigger
	@:allow(djTui.BaseElement)
	function trig(msg:String, from:BaseElement):Void
	{
		if (from.type == window)
		{
			#if (debug)
			if(WM.flag_debug_trace_events)
			trace('> Event From:(${from.type}):${from.SID}, Msg:$msg');
			#end
			if (msg == "focus" && onFocus != null) onFocus(); else
			if (msg == "unfocus" && onUnfocus != null) onUnfocus(); else
			if (msg == "open" && onOpen != null) onOpen(); else
			if (msg == "close" && onClose != null) onClose();
			
			// TODO: ON ESCAPE ?
			
		}else{
			
			#if (debug)
			if(WM.flag_debug_trace_events)
			trace('> Event From:(${from.type}):${from.SID}, Msg:$msg, Data:"${from.getData()}", Owner:${from.parent.SID}');
			#end
			
			if (onElem != null) onElem(msg, from);
		}
		
		if (onAny != null) onAny(msg, from);
		
		if (WM.winEvents != null) WM.winEvents.trig(msg, from);
	}//---------------------------------------------------;
	
	
	public var onFocus:Void->Void;
	public var onUnfocus:Void->Void;
	public var onOpen:Void->Void;
	public var onClose:Void->Void;
	
	public var onElem:String->BaseElement->Void;
	public var onAny:String->BaseElement->Void;
	
}// --