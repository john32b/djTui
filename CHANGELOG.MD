# CHANGELOG



### V0.2 (2020-10)

- `Left,Right,Center` -> `l,r,c` for brevity in Align Functions all around
- Window styles will now keep a full deep copy of the style object. For safety and easier modification
- `Draw.DrawGrid()` new code, it makes more sense now
- `Border` element , can now also draw a grid on the window
- `Buttons` can now have a variable height
- Improved KEY handling on Windows + Elements. Key events can now "bubble" up to the WM, so you can modify them
- **NEW** `ControlsHelpBar` Window, helps creating a horizontal strip with Controls Help labels
- **NEW** `Window.removeAll()` removes all child elements on a window
- `Window.addStackLine()`, can now also add elements from the bottom of the window
- `VList.onSelect` will now return the entire vlist object, instead of index
- `Menubar` rewrite.
- `Messagebox`, new mode, modal with no buttons that does not close on ESC key
- Better `Label` animation code and parameters. Like blinking a specific number of times
- `SliderOption` can set Data with either index or String value
- `SliderNum` can set Data with either a Float or a String Float
- `BaseElement` and `Windows` events overhaul. Now all elements interact with a **new** `WindowEvents` object and user interacts with it
- Minor bugfixes

### V0.1 (2018-10)

- First release 
