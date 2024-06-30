package;

import samples.SampleSwitcher;
import lime.ui.MouseWheelMode;
#if cpp
//import hxtelemetry.HxTelemetry;
#end

import lime.app.Application;
import lime.ui.KeyModifier;
import lime.ui.Touch;

import com.babylonhx.engine.Engine;
import com.babylonhx.events.PointerEvent;
import com.babylonhx.events.PointerEventTypes;
import com.babylonhx.Scene;

/**
 * ...
 * @author Krtolica Vujadin
 * @author Clay Larabie
 */
#if cpp
//@:build(haxebullet.MacroUtil.buildAll())
#end
class MainLime extends Application {

	
	
	var scene:Scene;
	var engine:Engine;
	var pointerEvent:PointerEvent;
	
	#if cpp
	//var hxt = new HxTelemetry();
	#end
	
	
	public function new() {
		super();
	}
	
	override public function onWindowCreate() {
		

		var renderContext = lime.graphics.opengl.GL.context;

		engine = new Engine(window, renderContext, true);	
		scene = new Scene(engine);
		
		engine.width = window.width;
		engine.height = window.height;
				
		pointerEvent = new PointerEvent();
	}
	
	override public function onPreloadComplete() {

		//run the sample 
		var switcher = new SampleSwitcher(scene);

	}
	
	override function onMouseDown(x:Float, y:Float, button:Int) {
		for (f in engine.mouseDown) {
			pointerEvent.x = x;
			pointerEvent.y = y;
			pointerEvent.button = button;
			pointerEvent.type = PointerEventTypes.POINTERDOWN;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
		
	}
	
	#if !neko
	override function onMouseUp(x:Float, y:Float, button:Int) {
		for(f in engine.mouseUp) {
			pointerEvent.x = x;
			pointerEvent.y = y;
			pointerEvent.button = button;
			pointerEvent.type = PointerEventTypes.POINTERUP;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	#end
	
	override function onMouseMove(x:Float, y:Float) {
		for(f in engine.mouseMove) {
			pointerEvent.x = x;
			pointerEvent.y = y;
			pointerEvent.type = PointerEventTypes.POINTERMOVE;
			pointerEvent.pointerType = "mouse";
			f(pointerEvent);
		}
	}
	
	override function onMouseWheel(deltaX:Float, deltaY:Float, deltaMode:MouseWheelMode) {
		for (f in engine.mouseWheel) {
			pointerEvent.type = PointerEventTypes.POINTERWHEEL;
			pointerEvent.pointerType = "mouse";
			f(deltaY);
		}
	}
	
	override function onTouchStart(touch:Touch) {
		for (f in engine.touchDown) {
			pointerEvent.x = touch.x;
			pointerEvent.y = touch.y;
			pointerEvent.button = touch.id;
			pointerEvent.type = PointerEventTypes.POINTERDOWN;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
	override function onTouchEnd(touch:Touch) {
		for (f in engine.touchUp) {
			pointerEvent.x = touch.x;
			pointerEvent.y = touch.y;
			pointerEvent.button = touch.id;
			pointerEvent.type = PointerEventTypes.POINTERUP;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}
	
	override function onTouchMove(touch:Touch) {
		for (f in engine.touchMove) {
			pointerEvent.x = touch.x;
			pointerEvent.y = touch.y;
			pointerEvent.button = touch.id;
			pointerEvent.type = PointerEventTypes.POINTERMOVE;
			pointerEvent.pointerType = "touch";
			f(pointerEvent);
		}
	}

	override function onKeyUp(keycode:Int, modifier:KeyModifier) {
		for(f in engine.keyUp) {
			f(keycode);
		}
	}
	
	override function onKeyDown(keycode:Int, modifier:KeyModifier) {
		for(f in engine.keyDown) {
			f(keycode);
		}
	}
	
	override public function onWindowResize(width:Int, height:Int) {
		if (engine != null) {
			engine.width = width;
			engine.height = height;
			for (f in engine.onResize) {
				f();
			}
			engine.resize();
		}
	}
	
	override function update(deltaTime:Int) {
		engine._renderLoop();
	}
	
}
