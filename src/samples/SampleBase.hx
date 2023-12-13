package samples;

import com.babylonhx.cameras.Camera;
import com.babylonhx.cameras.WebVRFreeCamera;
import com.babylonhx.cameras.FreeCamera;
import com.babylonhx.lights.HemisphericLight;
import com.babylonhx.materials.StandardMaterial;
import com.babylonhx.materials.textures.Texture;
import com.babylonhx.layer.Layer;
import com.babylonhx.math.Color3;
import com.babylonhx.math.Vector3;
import com.babylonhx.math.Vector2;
import com.babylonhx.math.Space;
import com.babylonhx.mesh.Mesh;
import com.babylonhx.mesh.MeshBuilder;
import com.babylonhx.Scene;
import com.babylonhx.engine.Engine;
import com.babylonhx.mesh.VertexBuffer;

import com.babylonhx.animations.Animation;
import com.babylonhx.actions.ActionEvent;
import com.babylonhx.collisions.PickingInfo;

import com.babylonhx.tools.EventState;
import com.babylonhx.utils.Image;
import com.babylonhx.materials.textures.RawTexture;
import com.babylonhx.materials.textures.procedurals.standard.Plasma;
import com.babylonhx.materials.textures.procedurals.standard.Spiral;
import com.babylonhx.materials.textures.procedurals.standard.Dream;
import com.babylonhx.materials.textures.procedurals.standard.Combustion;
import com.babylonhx.materials.textures.procedurals.standard.Electric;
import com.babylonhx.materials.textures.procedurals.standard.Voronoi;
import com.babylonhx.materials.textures.procedurals.standard.LiquidMetal;
import com.babylonhx.materials.textures.procedurals.standard.DoubleBokeh;

import com.babylonhx.postprocess.NotebookDrawingsPostProcess;
import com.babylonhx.postprocess.WatercolorPostProcess;
import com.babylonhx.postprocess.NoisePostProcess;

/**
    This class gives us a foundation for switching between samples, which lets us activate and deactivate various objects as this sample becomes active or not 
 **/
class SampleBase {

    var _scene:Scene = null;
    var _initialized:Bool = false;

    var _keysHandled:Map<Int, Bool> = new Map();
    var _keysDown:Map<Int, Bool> = new Map();
    private var _elapsedTime:Float = 0;
    private var _active:Bool = false;

    /**
        Activate the current sample 
    **/
    public function activate() {
        if(!_initialized)  {
            init();
        }

        _active = true;
    }

    public function deactivate() {
        _active = false;

        //reset our key state
        _keysHandled = new Map();
        _keysDown = new Map();
    }

    public function init() {

        _scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
            if(this._active) {
                this.onBeforeRender(scene, es);
            }
        });

        _initialized = true;
    }

	public function new(scene:Scene) {
		_scene = scene;	

		_scene.getEngine().runRenderLoop(function () {
            this.onRender();
        });
	}

    public function onRender() {
        _scene.render();
    }

    public function onBeforeRender(scene:Scene, es:Null<EventState>) {

    }
	
}
