package samples;

import com.babylonhx.materials.Material;
import com.babylonhx.loading.SceneLoader;
import lime.utils.Assets;
import centauri.turtle.TurtleDrawer;
import com.babylonhx.math.Plane;
import com.babylonhx.math.Matrix;
import com.babylonhx.mesh.LinesMesh;
import haxe.display.Display.FindReferencesKind;
import hxDaedalus.ai.trajectory.LinearPathSampler;
import hxDaedalus.ai.PathFinder;
import hxDaedalus.ai.EntityAI;
import com.babylonhx.math.Vector2;
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
import com.babylonhx.events.PointerEvent;
import hxDaedalus.data.ConstraintSegment;
import hxDaedalus.data.ConstraintShape;
import hxDaedalus.data.Mesh;
import hxDaedalus.data.Object;
import hxDaedalus.data.Vertex;
// import hxDaedalus.view.SimpleView;
import hxDaedalus.factories.RectMesh;
import centauri.data.World;

using tweenxcore.Tools;
using Lambda;

/**

 */
class MeshSample1 extends SampleBase {
	private var _mesh:com.babylonhx.mesh.AbstractMesh = null;

	private var _onKeyDown:Int->Void = function(keycode:Int) {};
	private var _onKeyUp:Int->Void = function(keycode:Int) {};
	private var _onMouseDown:PointerEvent->Void = function(evt:PointerEvent) {};

	private var _camera:ArcRotateCamera = null;
	private var _light:HemisphericLight = null;
	private var _rate:Float = 0;

	public function new(scene:Scene) {
		super(scene);
	}

	/**
		We're going to use hxdaedalus and an obstacle that is built using turtle commands and allow an entity to move around using pathfinding 
	**/
	public override function init() {
		super.init();

		_onKeyDown = function(keyCode:Int) {
			return this.onKeyDown(keyCode);
		};

		_onKeyUp = function(keyCode:Int) {
			return this.onKeyUp(keyCode);
		};

		_onMouseDown = function(evt:PointerEvent) {
			return this.onMouseDown(evt);
		}

		_camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), _scene);
		_camera.setPosition(new Vector3(0, 0, 400));
		_camera.maxZ = 20000;
		_camera.lowerRadiusLimit = 150;

		_light = new HemisphericLight("hemi", new Vector3(0, 1, 0), _scene);
		_light.diffuse = Color3.FromInt(0xf68712);

		// the policewoman.babylon mesh was generated using Triposr an image to 3d model tool to generate an .obj file with a baked texture and UV coordinates
		// It is then opened in blender where the Weld Modifier (to fix triangles), Decimate modifier (to reduce poly count), and the Weighted Normal modifier to smooth the normals
		// It is then exported using the BabylonJS exporter and loaded here
		SceneLoader.ImportMesh("", "sample-assets/", "policewoman.babylon", _scene, function(newMeshes, particleSystems, skeletons) {
			_mesh = newMeshes[0];
			// scale the mesh by 100
			_mesh.scaling = new Vector3(100, 100, 100);
			// The exporter currently doesn't export a uScale or vScale for the texture, so we'll set both manually
			// For some reason we need to flip the UV coordinates vertically, so we'll set the vScale to -1
			var standardMat:StandardMaterial = cast(_mesh.material, StandardMaterial);
			standardMat.diffuseTexture.vScale = -1;
			standardMat.diffuseTexture.uScale = 1;
		});
	}

	/**
		Activate our state 
	**/
	public override function activate() {
		super.activate();

		// activate happens after init, so everything is created at this point
		_scene.getEngine().keyDown.push(_onKeyDown);
		_scene.getEngine().keyUp.push(_onKeyUp);
		_scene.getEngine().mouseDown.push(_onMouseDown);

		_light.setEnabled(true);
		_scene.activeCamera = _camera;

		_camera.attachControl();
	}

	/** 
		Deactivate our state, for this sample we'll destroy everything in deactivate
	**/
	public override function deactivate() {
		super.deactivate();

		_mesh.dispose();
		_mesh = null;

		_scene.getEngine().keyDown.remove(_onKeyDown);
		_scene.getEngine().keyUp.remove(_onKeyUp);
		_scene.getEngine().mouseDown.remove(_onMouseDown);

		_light.dispose();
		_light = null;

		_camera.detachControl();
		_camera.dispose();
		_camera = null;

		_initialized = false;
	}

	// Perform our updates
	public override function onBeforeRender(scene:Scene, es:Null<EventState>) {
		var dt = scene.getEngine().getDeltaTime();
		_elapsedTime += dt;

		if (_keysDown[Keycodes.key_a] && !_keysHandled[Keycodes.key_a]) {
			// switch the U by 90 degrees
			var standardMat:StandardMaterial = cast(_mesh.material, StandardMaterial);
			standardMat.diffuseTexture.uAng += 90;
			if (standardMat.diffuseTexture.uAng >= 360)
				standardMat.diffuseTexture.uAng = 0;
			_keysHandled[Keycodes.key_a] = true;
		} else if (_keysDown[Keycodes.key_b] && !_keysHandled[Keycodes.key_b]) {
			// switch the V by 90 degrees
			var standardMat:StandardMaterial = cast(_mesh.material, StandardMaterial);
			standardMat.diffuseTexture.vAng += 90;
			if (standardMat.diffuseTexture.vAng >= 360)
				standardMat.diffuseTexture.vAng = 0;
			_keysHandled[Keycodes.key_b] = true;
		} else if (_keysDown[Keycodes.key_c] && !_keysHandled[Keycodes.key_c]) {
			// switch the w by 90 degrees
			var standardMat:StandardMaterial = cast(_mesh.material, StandardMaterial);
			standardMat.diffuseTexture.wAng += 90;
			if (standardMat.diffuseTexture.wAng >= 360)
				standardMat.diffuseTexture.wAng = 0;
			_keysHandled[Keycodes.key_c] = true;
		} else if (_keysDown[Keycodes.key_d] && !_keysHandled[Keycodes.key_d]) {
			var standardMat:StandardMaterial = cast(_mesh.material, StandardMaterial);
			standardMat.diffuseTexture.vScale = -1;
			_keysHandled[Keycodes.key_d] = true;
		}
	}

	private function onKeyDown(keyCode:Int) {
		_keysDown[keyCode] = true;
	}

	private function onKeyUp(keyCode:Int) {
		_keysDown[keyCode] = false;
		_keysHandled[keyCode] = false;
	}

	private function onMouseDown(evt:PointerEvent) {}
}
