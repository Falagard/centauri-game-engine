# Centauri Game Engine

The Centauri Game Engine uses BabylonHx as its rendering engine and adds pathfinding, artificial intelligence systems, tweening, physics (and eventually entity component systems, and more) to create a full game engine. 

To get the engine running, we'll install Haxe (a programming language), Lime (a Haxe library that handles cross platform development), Hashlink (a virtual machine) and Centauri Engine. We'll also install some dependencies and some editing tools. 

While this may seem like a lot of steps to set up a game engine, this is an open source project through and through. There are no hidden steps - everything is in front of you.

# Install Haxe

Haxe is an open source high-level strictly-typed programming language with a fast optimizing cross-compiler.

Haxe is easy to learn and uses a syntax similar to Javascript that cross compiles to other languages such as C++, JavaScript, PHP, C#, Java, Python, and Lua. This means that you you can write code in Haxe and create a game that can run on almost any platform including game consoles (Xbox Series X/S, Playstation 5 and Nintendo Switch - but you'll need the appropriate development toolkits and some customization will be required), Windows, Linux, mobile devices such as Android, iOS and even browsers.

Currently Centauri Game Engine is targeting Windows and game consoles but it should be able to run on all the platforms above with some work. 

To get started you'll need to download and install Haxe from here:

https://haxe.org/download/

The version at the time of this writing is 4.3.3

Choose the defaults while installing. 

This will setup Haxe and tools in C:\HaxeToolkit by default. 

That will also install Haxe library manager "haxelib" which you will use to install dependent libraries.

# Install Git 

If you don't have it already, install git. 

https://git-scm.com/downloads

This will probably meaning clicking the Download for Windows button and 64-bit Git for Windows Setup.

Use the defaults for all options during installation. 

# Visual Studio 2022 Community Edition

To build Lime from source, you'll need to install Visual Studio Community Edition which is free, with the Desktop Development with C++ option. 

https://visualstudio.microsoft.com/vs/community/

Run the installer and choose the "Desktop Development with C++" in the list of options. 

# Setup Lime

Next we'll install Lime, (for more information see https://lime.openfl.org/) which is a framework that includes tools and libraries for building cross platform Haxe applications, including an OpenGL abstraction layer we use for rendering. 

There's a fork of Lime here https://github.com/Falagard/lime and we're going to build Lime from source. The Fork was roughly version was between version 8.1.1 and 8.2 at the time it was forked. 

Open a command prompt by pressing Windows Key + R and type "cmd" and change to a directory where you want to put your source code. 

For example this will move to your C:\ drive and create a directory called "src" where you will put the Centauri Game Engine, Lime and lime-samples repositories. 

`cd c:\`

`md src`

`cd src`

Next we'll install some Haxe libraries that are used by Lime. This can be run from anywhere because these will be installed in C:\HaxeToolkit\haxe\lib

We'll use haxelib to install "format", "hxp", and "hxcpp" libraries. At the time of writing, format 3.7.0, hxp 1.3.0 and hxcpp 4.3.2

haxelib is like a package manager for haxe, similar to Nuget, npm, pip, etc. that are available for other languages. 

`haxelib install format`

If you get an error that says "Error: Failed with error: X509 - Certificate verification failed, e.g. CRL, CA or signature check failed" then run this line: 

curl -sSLf https://lib.haxe.org/p/jQueryExtern/3.2.1/download/ -o /dev/null

`haxelib install hxp`

`haxelib install hxcpp`

Now clone the Lime repository with the following:

`git clone --recursive https://github.com/falagard/lime`

Then enter the following which tells haxelib we want to add the "lime" Haxe library from source in a directory called "lime" 

`haxelib dev lime lime`

Do the same for lime-samples:

`git clone https://github.com/Falagard/lime-samples`

`haxelib dev lime-samples lime-samples`

## Setup Hashlink 

Hashlink is a virtual machine for Haxe (see https://hashlink.haxe.org/ for more information) and was created by the same person who created Haxe, Nicolas Cannasse, who also has a video game company that has created several games.  

Hashlink is the easiest way to quickly develop Haxe games on Windows. This is because compiling to the Hashlink target is faster than compiling to the Windows C++ target when making code changes, and is great for daily development. Then when you're ready you can use compile to HashLink/C code, compiled with a native compiler to a regular executable. 

This mode results in the best performance, so it is suitable for final releases (and can target Game Consoles). See this for more information https://haxe.org/manual/target-hl-c-compilation.html

Run the following commands:

This will rebuild the windows tools used by Lime:

`haxelib run lime rebuild windows`

This will setup lime so it can be run from the command line:

`haxelib run lime setup`

This sets up hashlink: 

`lime setup hashlink`

This rebuilds the version of hashlink used by Lime:

`lime rebuild hashlink`

# Clone the Repository

Open a command prompt by pressing Windows Key + R and type "cmd" 

Then in a directory you want to install Centauri enter the following:

`git clone --recurse-submodules https://github.com/Falagard/centauri-game-engine`

This will bring down the source code of the game engine and any dependent repositories it uses, which include hxDaedalus, BabylonHx, box2d, tweenx, hxbt, castle. 

# Setup Submodules with Haxelib

Next we'll setup BabylonHX (for more information see https://github.com/Falagard/BabylonHx) which is a rendering engine built on top of Lime and is a port of BabylonJS (for more information see https://www.babylonjs.com/). 

BabylonHX handles meshes, lights, materials, shaders, animations and many other parts that are needed by a game engine. 

We've already run the git clone command with the --recurse-submodules argument so BabylonHx should already be in a sub directory where this repository was cloned. 

We still need to tell Haxe where to find this BabylonHX, so change into the directory you cloned earlier by entering at the command line:

`cd centauri-game-engine`

Then enter the following which tells haxelib we want to add the "BabylonHX" Haxe library from source in a directory called "babylonhx" under the "centauri-game-engine" directory. 

`haxelib dev BabylonHX babylonhx`

You should see something that says "Development directory set to C:\users\yourname\centauri-game-engine\babylonhx" or wherever you decided to clone the repository to. 

hxDaedalus is a pathfinding library which can be used to tell AI or players where they can move. 

We'll tell haxelib we want to add the "hxDaedalus" Haxe library from source in a directory called "hxDaedalus" 

`haxelib dev hxDaedalus hxDaedalus`

hxbt is a Behavior Tree library for artificial intelligence. 

`haxelib dev hxbt hxbt`

box2d is a 2d physics library used for ray-casting for line of sight, collisions, etc. 

`haxelib dev box2d box2d`

castle is a structured static database used as a way to read game data. 

`haxelib dev castle castle`

tweenxcore a is a tweening library, which is used for juicy transitions. 

The way tweenxcore is setup, we need to change into the tweenxcore directory before adding it to haxelib:

`cd tweenx\src\`

We should now be in the centuari-game-engine\tweenx\src\ directory. 

`haxelib dev tweenxcore tweenxcore`

## CastleDB 

CastleDB is a structured static database that allows you to edit your game data using an editor that is downloadable from here http://castledb.org/ and provides you with a fast, easy and strictly typed way of accessing your game data. 

Download the CastleDB editor from http://castledb.org/ 

The file should be available at http://castledb.org/file/castledb-1.5-win.zip

If this disappears from the Internet for whatever reason, you can get the source here https://github.com/ncannasse/castle and follow the instructions to build it. If github goes offline, we have bigger problems to worry about. 

# Install Visual Studio Code and Extensions

Visual Studio Code is what we're going to use to write game code in Haxe. (We installed Visual Studio Express just to compile Lime)

Download and install Visual Studio Code, the Lime Extension, and the Hashlink Debugger. 

https://code.visualstudio.com/

https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension

https://marketplace.visualstudio.com/items?itemName=HaxeFoundation.haxe-hl

# Open the Project and run the first sample 

Open the project by clicking Open Folder and browse to the directory where you cloned the repository, for example C:\Src\centauri-game-engine

When asked "Do you trust the authors of the files in this folder?" click "Yes I trust the authors"

In the bottom left of the window, to the right of the word Lime with the settings icon, select the Lime Target Configuration and change it to HashLink. 

## More information about Targets

When you're compiling a Lime application from Visual Studio Code you need to choose a target - HTML5, Android, Windows, etc or Hashlink.

* HTML5 generates JavaScript and runs in a browser. 
* Android generates Java and requires the Android SDK. 
* Windows generates C++ and requires the HXCPP Visual Studio Code Extension to debug. 
* Hashlink generates HL bytecode and is run by hl.exe and requires the Hashlink Debugger Visual Studio Code Extension to debug.  

We suggest using Hashlink as the target on Windows because it compiles fast.

Hit Ctrl + Shift + B to build the Hashlink Debug target. 

Hit F5 to run the sample. If all goes well the first sample will run. 

# Troubleshooting



# What's Next?

See the wiki for more information on how to start working on your first game. 

# How do I uninstall the Centauri Game Engine?

You can delete the directories for the repositories. If you followed the instructions above, these will be:

* C:\src\centauri-game-engine
* C:\src\lime
* C:\src\lime-samples

You can uninstall the Haxe toolkit using the uninstaller in 

C:\HaxeToolkit\Uninstall.exe

You can uninstall Visual Studio Community 2022 and Visual Studio Code from Add or Remove Programs by hitting Windows Key + I then choose Apps then Installed Apps












