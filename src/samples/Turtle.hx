package samples;

import com.babylonhx.engine.EngineCapabilities.WEBGL_compressed_texture_s3tc;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.cameras.FreeCamera;
import haxe.iterators.StringIterator;
import com.babylonhx.states._AlphaState;
import com.babylonhx.math.Space;
import com.babylonhx.math.Angle;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.mesh.simplification.DecimationTriangle;
import com.babylonhx.cameras.ArcRotateCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.CubeTexture;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.layer.Layer;
import com.babylonhx.mesh.VertexBuffer;
import com.babylonhx.Scene;
import com.babylonhx.tools.EventState;
import centauri.turtle.TurtleDrawer;

/**
 * ...
 * @author Clay Larabie
 */
class Turtle extends SampleBase {

    private var _turtleDrawer:TurtleDrawer = null;
    private var _turtlePointer:Mesh = null;

    //our input functions so we can register and unregister them when the sample is activated / deactivated
    private var _onKeyDown:Int->Void = function(keycode:Int) { };
    private var _onKeyUp:Int->Void = function(keycode:Int) { };

    private var _camera:ArcRotateCamera = null;
    private var _light:HemisphericLight = null;

	public function new(scene:Scene) {
        super(scene);
    }

    /**
        Init our state
    **/
    public override function init() {

        super.init();

        _onKeyDown = function(keyCode:Int) {
			_keysDown[keyCode] = true;
		};

		_onKeyUp = function(keyCode:Int) {
            _keysDown[keyCode] = false;
            _keysHandled[keyCode] = false;
		};

        _turtleDrawer = new TurtleDrawer(_scene);

		_camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), _scene);
        _camera.setPosition(new Vector3(0, 0, 400));
		
		_camera.maxZ = 20000;		
		_camera.lowerRadiusLimit = 150;
		
		_light = new HemisphericLight("hemi", new Vector3(0, 1, 0), _scene);
		_light.diffuse = Color3.FromInt(0xf68712);
	
        //draw a pointer mesh for the turtle direction
        _turtleDrawer.penUp();
        _turtleDrawer.beginMesh();
        _turtleDrawer.left(180);
        _turtleDrawer.forward(5);
        _turtleDrawer.right(180);
        _turtleDrawer.penDown();
        _turtleDrawer.forward(10);
        _turtleDrawer.left(120);
        _turtleDrawer.forward(10);
        _turtleDrawer.left(120);
        _turtleDrawer.forward(10);
        _turtleDrawer.left(120);
        _turtleDrawer.forward(10);
        _turtleDrawer.endMesh();

        //grab the current mesh so it doesn't get disposed
        _turtlePointer = _turtleDrawer._meshes[0];
        _turtleDrawer._meshes = [];
    }

    /**
        Activate our state 
    **/
    public override function activate() {

        super.activate();

        //activate happens after init, so everything is created at this point
        //show the pointer and turtle line meshes
        _turtlePointer.setEnabled(true);
        _turtleDrawer.showMeshes();

        _scene.getEngine().keyDown.push(_onKeyDown);
        _scene.getEngine().keyUp.push(_onKeyUp);
        
        _light.setEnabled(true);
        _scene.activeCamera = _camera;

        _camera.attachControl();

    }

    /** 
        Deactivate our state
    **/
    public override function deactivate() {

        super.deactivate();

        _turtlePointer.setEnabled(false);
        _turtleDrawer.hideMeshes();

        _scene.getEngine().keyDown.remove(_onKeyDown);
        _scene.getEngine().keyUp.remove(_onKeyUp);

        _light.setEnabled(false);

        _camera.detachControl();
    }

    /** 
        Our update function - check for input, update the turtle drawer         
    **/
    public override function onBeforeRender(scene:Scene, es:Null<EventState>) {
        
        //check state of keys, update the turtle string
        var anyChanged:Bool = false;

        var dt = scene.getEngine().getDeltaTime();
        _elapsedTime += dt;

        //if enough time has elapsed, set the _keysHandled to false so they'll re-trigger
        if(_elapsedTime > 300) {
            _keysHandled = new Map();
        }

        if(_keysDown[Keycodes.key_w] && !_keysHandled[Keycodes.key_w]) {
            //move forward
            _turtleDrawer._system += "F";
            anyChanged = true;
            _keysHandled[Keycodes.key_w] = true;
        }

        if(_keysDown[Keycodes.key_s] && !_keysHandled[Keycodes.key_s]) {
            //erase last move;
            _turtleDrawer._system = _turtleDrawer._system.substr(0, _turtleDrawer._system.length - 2);
            anyChanged = true;
            _keysHandled[Keycodes.key_s] = true;
        }

        if(_keysDown[Keycodes.key_d] && !_keysHandled[Keycodes.key_d]) {
            _turtleDrawer._system += "+";
            anyChanged = true;
            _keysHandled[Keycodes.key_d] = true;
        }

        if(_keysDown[Keycodes.key_a] && !_keysHandled[Keycodes.key_a]) {
            _turtleDrawer._system += "-";
            anyChanged = true;
            _keysHandled[Keycodes.key_a] = true;
        }

        if(anyChanged) {

            //destroy current meshes
            _turtleDrawer.disposeMeshes();

            _elapsedTime = 0;

            _turtleDrawer.beginMesh();

            _turtleDrawer.evaluateSystem();

            _turtleDrawer.endMesh();   

            _turtlePointer.position = _turtleDrawer._currentTransform.position;
            _turtlePointer.rotationQuaternion = _turtleDrawer._currentTransform.rotationQuaternion;
            
        }
    }
}
