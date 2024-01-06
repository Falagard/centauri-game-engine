package centauri.data;

//this generates a wrapper World class at compile time which allows us to access our world data with strict typing 
private typedef Init = haxe.macro.MacroType<[cdb.Module.build("sample-assets/world.cdb")]>;

