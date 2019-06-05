## Example Project

A simple project showcasing many components of **djTui**.
djTUI is agnostic and can run into any HAXE target.

#### General Requirements
- Haxe 4.0
- Optional , use HAXEDEVELOP to open the project file `tui_example.hxproj`


### Building for nodeJs

**Requirements**:

- nodeJS setup on system
- https://github.com/johndimi/djNode/releases/tag/v0.4 ( A simple nodeJS helper, get V0.4 )
- https://github.com/HaxeFoundation/hxnodejs ( the nodeJS externs for haxe )

Using a command line, navigate to the `examples` folder and run **`haxe build_nodejs.hxml`**\
This will create `bin/nodejs/app.js`, which can be run with `nodejs`

### Building for openFL

**Requirements**:

- https://github.com/openfl/openfl

You can build to all openFL targets. Running the included **`build_openfl.bat`** will create a flash build of the demo in the `/bin/` folder.


