# Example Project

A simple project showcasing components of **djTui**.  
Currently it compiles to **nodejs** and **openfl**

#### REQUIREMENTS

- `HAXE 4.1.3` https://haxe.org/download/

- `djA (v0.1)` Library. It is a personal general use library. Install it with haxelib. https://github.com/john32b/djA

- `djNode (v0.6)` Library. For building for **nodejs**. Install it with haxelib. https://github.com/john32b/djNode/

  

#### :warning: NOTES on OPENFL Version

The openfl adaptors for djTui are just a proof of concept. It works, but everything could be better. Font rendering is bad. It can be fixed and achieve results similar to running a real terminal. Perhaps in a later version



##### Building nodeJS

- `haxe example/build_nodejs` will build the binary to `example/bin/nodejs`
- `lime build example/project.xml html5` will build the binaries to `example/bin/html5` folder
- you can also target anything else you want with openfl. Check openfl Documentation
