# Centauri Game Engine

The Centauri Game Engine uses BabylonHx as its rendering engine and adds pathfinding, artificial intelligence systems, entity component systems, and more to create a full game engine. 

To get the engine running, do the following:

If you don't have it already, install git. 

https://git-scm.com/downloads

Open a command prompt by pressing Windows Key + R and type "cmd" 

Then in a directory you want to install Centauri and the following:

`git clone --recurse-submodules https://github.com/Falagard/centauri-game-engine`

This will bring down the source code of the engine and any dependent repositories it uses, which are hxDaedalus and BabylonHx.  

# Install Haxe

Haxe is a language that is easy to learn and uses a syntax similar to Javascript that transpiles to other languages such as C++, Java, Javascript, etc. which means that you you can write code in Haxe and create software that run on almost any platform, including consoles, Windows, Linux, mobile devices such as Android, iOS and even browsers. 

To get started you'll need to download and install Haxe from here:

https://haxe.org/download/

That will also install Haxe library manager "haxelib" which you will use to install necessary libraries/frameworks.

# Install Dependencies

Then you'll have to install runtime files for c++ backend for Haxe - HXCPP, execute from command line:

`haxelib install hxcpp`

Next we'll install Lime, (for more information see https://lime.openfl.org/) which is a framework that includes tools and an libraries for building Haxe applications, including an OpenGL abstraction layer we use for rendering. 

To install Lime execute from cmd line:

`haxelib install lime`

and after that execute:

`haxelib run lime setup`

When Lime is installed and configured you'll have to install dev tools for each platform you wish to build BabylonHx for, so if you want to build for Windows you should run this from cmd line:

`haxelib run lime setup windows`

This will start download process of VisualStudio and it will install and setup everything for you (will it? - needs testing). For every other platform the process is the same but has not been fully tested yet. 

# Setup BabylonHx and hxDaedalus

Next we'll install BabylonHX (for more information see https://github.com/Falagard/BabylonHx) which is a rendering engine built on top of Lime and is a port of BabylonJS (for more information see https://www.babylonjs.com/). 

BabylonHX handles meshes, lights, materials, shaders, animations and many other parts that are needed by a game engine. 

We've already run the git clone command with the --recurse-submodules argument so BabylonHx should already be in a directory where this repository was cloned. 

We still need to tell Haxe where to find this BabylonHX, so change into the directory you cloned earlier by entering at the command line:

`cd centauri-game-engine`

Then enter the follow which tells haxelib it can find the BabylonHX directory in a folder below centauri-game-engine called "babylonhx"

`haxelib dev BabylonHX babylonhx`

You should see something that says "Development directory set to C:\users\yourname\centauri-game-engine\babylonhx" or wherever you decided to clone the repository to. 

hxDaedalus is a pathfinding library which can be used to tell AI or players where they can move. 

We'll tell haxlib it can find the hxDaedalus directory in a folder below centauri-game-engine called "hxDaedalus"

`haxelib dev hxDaedalus hxDaedalus`

# Install Visual Studio Code and Extensions

Download and install Visual Studio Code, the Lime Extension, and the Hashlink Debugger. 

https://code.visualstudio.com/

https://marketplace.visualstudio.com/items?itemName=openfl.lime-vscode-extension

https://marketplace.visualstudio.com/items?itemName=HaxeFoundation.haxe-hl


# Open the Project and run the first sample 

Open the project by opening the location of the centauri-game-engine directory in Visual Studio Code. 

In the bottom left of the window, to the right of the word Lime with the settings icon, select the Lime Target Configuration and change it to HashLink. 

Hit F5 to run the sample.

The sample can be changed by going into MainLime.hx and changing onPreloadComplete 
    new samples.Pathfinding(scene);
