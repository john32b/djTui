package;
import djTui.*;
import djTui.el.Button;
import djTui.el.Label;
import djTui.el.TextBox;
import djTui.win.WindowLabel;

/**
 * Labels Example
 * Demo and Code Usage examples
 */
class State_Labels extends WindowState
{
	public function new() 
	{
		super("st_labels");
		
		// Whenever this state comes in, the WM background will change to this color
		bgColor = "darkmagenta";
		 
		// When [ESC] is pressed. This WindowState ID will be called
		onEscGoto = "main";
		var h = new WindowLabel(['= ${WM.NAME} - Labels Demo'], [0, 1, 0], ["black", "gray"]);	
		
		// --
		// Decorative window thingy
		var dec = new Window(15, 2, Styles.win.get('black.1'));
			dec.borderStyle = 0;
			dec.flag_focusable = false;
			dec.addStack(new Label('DjTui Demo ** ', dec.inWidth).scroll(150).setColor("red"));
			dec.addStack(new Label('-+-+==+-+', dec.inWidth).scroll(300));
			WM.A.screen(dec, "r", "b", 1);
			
			
		// -- Main Win
		var win = new Window( 34, 18, Styles.win.get('blue.1'));
			win.addStack(new Label("Normal Label"));
			win.addStack(new Label("Aligned Right", win.inWidth, "r"));
			win.addStack(new Label("Aligned Center", win.inWidth, "c"));
			win.addStack(new Label("Colored 1").setColor("red"));
			win.addStack(new Label("Colored 2").setColor("yellow", "magenta"));			
			win.addSeparator(3);
			win.addStack(new Label("BLINK").blink().setSID("blink").setColor("yellow"));
			win.addSeparator(3);
			win.addStack(new Label("SCROLL --").scroll().setSID("scroll").setColor("yellow"));
			win.addSeparator(3);
			win.addStack(new Button("", "Stop Animations").onPush(function()
			{
				var bl:Label = cast win.getEl("blink");
				var sc:Label = cast win.getEl("scroll");
				bl.stop();
				sc.stop();
			}));
			
			win.addStack(new Button("", "Start Animations").onPush(function()
			{
				var bl:Label = cast win.getEl("blink");
				var sc:Label = cast win.getEl("scroll");
				bl.blink();
				sc.scroll();			
			}));
			win.addSeparator(3);
			
			// Add two elements in a single line
			win.addStackInline([
				new Label("001").setColor("black", "yellow"),
				new Label("002").setColor("yellow", "black"),
				], 0, 1, "center");
				
			win.addSeparator(3);
				
			win.pos(2, 2);
			// Note:
			// Blink and Scroll will repeat forever, until .STOP() is called
		
		
		// -- Information Box
		var info = new Window(30, 18, Styles.win.get('gray.1'));
			info.flag_focusable = false;
		var tb:TextBox = new TextBox(info.inWidth, info.inHeight);
		info.addStack(tb);
		tb.setData("Labels are single line and have customizable colors and alignment. Also there are two built in effects, Blinking and Scrolling.");
		info.posNext(win, 3);
		
		// NOTE:
		// Whatever windows list[] includes, will be opened at once later when the state is opened
		list = [h,dec,win,info];
	}//---------------------------------------------------;
	
}// --