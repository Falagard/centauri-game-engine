package samples;

import com.babylonhx.utils.Keycodes;
import com.babylonhx.tools.EventState;
import com.babylonhx.Scene;

class SampleSwitcher {

    private var _samples:Array<SampleBase>;
    private var _currentSample:SampleBase = null;
    var _keysHandled:Map<Int, Bool> = new Map();
    var _keysDown:Map<Int, Bool> = new Map();
    var _scene:Scene = null;
    private var _elapsedTime:Float = 0;

    public function new(scene:Scene) {

        _scene = scene;

        _samples = new Array<SampleBase>();
        _samples.push(new Turtle(scene));
        _samples.push(new Pathfinding(scene));
        _samples.push(new Tween(scene));
        _samples.push(new MeshSample1(scene));
        //_samples.push(new SVG1(scene));
        _currentSample = _samples[0];
        _currentSample.activate();
        
        _scene.getEngine().keyDown.push(function(keyCode:Int) {
            _keysDown[keyCode] = true;
		});

        _scene.getEngine().keyUp.push(function(keyCode:Int) {
            _keysDown[keyCode] = false;
            _keysHandled[keyCode] = false;
		});

        _scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
            var dt = scene.getEngine().getDeltaTime();
            _elapsedTime += dt;

            //check for num samples up to 0 if the keys are down
            //we'll have a better way to do this soon hopefully using 
            for(i in 0...9) {
                if(_keysDown[Keycodes.key_1 + i] && !_keysDown[Keycodes.lshift] && !_keysHandled[Keycodes.key_1 + i]) {
                    if(i > _samples.length - 1) {
                       break; 
                    }
                    changeSample(i);
                    _keysHandled[Keycodes.key_1 + i] = true;
                }
            }           
        });
    }

    public function changeSample(sampleIdx:Int) {
        if(sampleIdx < _samples.length) {
            _currentSample.deactivate();
            _currentSample = _samples[sampleIdx];
            _currentSample.activate();
        }
    }
}