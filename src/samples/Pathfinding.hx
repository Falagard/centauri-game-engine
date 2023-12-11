package samples;

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
//import hxDaedalus.view.SimpleView;
import hxDaedalus.factories.RectMesh;

/**
 * ...
 * @author Clay Larabie
 */
class Pathfinding extends TurtleBase {

    private var _startPosition:Vector2 = Vector2.Zero();
    private var _endPosition:Vector2 = Vector2.Zero();
    private var _obstacleMesh : Mesh;
    private var _entityAI:EntityAI;
    private var _pathfinder:PathFinder;
    private var _pathSampler:LinearPathSampler;
    private var _path:Array<Float>;
    private var _pathMesh:LinesMesh = null;
        
	public function new(scene:Scene) {

        _scene = scene;

		var camera = new ArcRotateCamera("Camera", 0, 0, 10, new Vector3(0, 0, 0), scene);
        
		camera.setPosition(new Vector3(0, 0, 400));
		camera.attachControl();
		camera.maxZ = 20000;		
		camera.lowerRadiusLimit = 150;
		
		var light = new HemisphericLight("hemi", new Vector3(0, 1, 0), scene);
		light.diffuse = Color3.FromInt(0xf68712);

        //handle inputs
        scene.getEngine().mouseDown.push(function(evt:PointerEvent) {
            return this.onMouseDown(evt);
        });
	
        scene.getEngine().keyDown.push(function(keyCode:Int) {
            return this.onKeyDown(keyCode);
		});

		scene.getEngine().keyUp.push(function(keyCode:Int) {
            return this.onKeyUp(keyCode);
		});

        //register our onBeforeRender callback
        scene.registerBeforeRender(function(scene:Scene, es:Null<EventState>) {
            this.onBeforeRender(scene, es); 
        });

        //a system built using the Turtle sample
        _system = "-FFFF+FFF-FFFF+FFFFFFFF+++++FFFFFFF+FF+FFFFF-FFFF-FFFFFFFF-FF+FFFFFF-FFFFFF-FFFFFF+FF+FFFFFFFF+FFFFFFFFFF+FFFFFF-FF-FFFFFFFFFF+FFFFFFFFFFFFFF+FFFFFFFFFFFFFFFFFFFFFFF+FF+F+F-FFFFFFFFFFFFFFFFFFFFF-FFFFFFFFFF-FF+FF-FFFFFFFF+FF-FFFFFF-FFF-FFF+";

        //we're going to use our turtle code to generate a set of points that we'll pass to hxdaedalus for pathfinding
        beginMesh();
        evaluateSystem();
        endMesh();

        _meshes[0].setEnabled(false); //don't draw it

        //get the extents of _points
        var minPoint:Vector2 = new Vector2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var maxPoint:Vector2 = new Vector2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

        for(point in _points) {
            minPoint.x = Math.min(minPoint.x, point.x);
            minPoint.y = Math.min(minPoint.y, point.y);
            maxPoint.x = Math.max(maxPoint.x, point.x);
            maxPoint.y = Math.max(maxPoint.y, point.y);
        }

        trace(minPoint);
        trace(maxPoint);

        var deltaY:Float = 0 - minPoint.y;
        var deltaX:Float = 0 - minPoint.x;

        var border:Float = 50;

        //let's translate all points into positive and add a bit for a border 
        if(deltaY > 0) {
            for(point in _points) {
                point.y += deltaY + border;
            }
        }

        if(deltaX > 0) {
            for(point in _points) {
                point.x += deltaX + border;
            }
        }

        minPoint = new Vector2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        maxPoint = new Vector2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

        for(point in _points) {
            minPoint.x = Math.min(minPoint.x, point.x);
            minPoint.y = Math.min(minPoint.y, point.y);
            maxPoint.x = Math.max(maxPoint.x, point.x);
            maxPoint.y = Math.max(maxPoint.y, point.y);
        }

        trace(minPoint);
        trace(maxPoint);

        //Now for the pathfinding mesh
        //Add a rectangle border greater than size of current points
        _obstacleMesh = RectMesh.buildRectangle(maxPoint.x + border, maxPoint.y + border);

        //Add a constraint object
        var object:Object = new Object();
        
        object.coordinates = new Array<Float>();

        var prevPoint:Vector3 = null;
        
        //hxdaedalus allows you to insert an object with coordinations of line segments so we'll pass our points in as object.coordinates
        for(point in _points) {
            if(prevPoint == null) {
                prevPoint = point;
                continue;
            }

            object.coordinates.push(prevPoint.x);
            object.coordinates.push(prevPoint.y);
            object.coordinates.push(point.x);
            object.coordinates.push(point.y);

            prevPoint = point;
        }

        _obstacleMesh.insertObject(object);
        
        //now we're going to create a drawable mesh
        var vertsAndEdges = _obstacleMesh.getVerticesAndEdges();

        var edgePoints:Array<Vector3> = [];

        //create meshes from the edges 
        for(edge in vertsAndEdges.edges) {
            
            edgePoints.push(new Vector3(edge.originVertex.pos.x, edge.originVertex.pos.y, 0));
            edgePoints.push(new Vector3(edge.destinationVertex.pos.x, edge.destinationVertex.pos.y, 0));            
            
            var mesh = com.babylonhx.mesh.Mesh.CreateLines("", edgePoints, _scene, false);

            if(edge.isConstrained) {
                mesh.color = Color3.White();
            } else {
                mesh.color = Color3.Blue();
            }

            edgePoints = [];
        }

        // we need an entity
        _entityAI = new EntityAI();
        // set radius as size for your entity
        _entityAI.radius = 4;
        // set a position
        _entityAI.x = 20;
        _entityAI.y = 20;
        
        // now configure the pathfinder
        _pathfinder = new PathFinder();
        _pathfinder.entity = _entityAI;  // set the entity  
        _pathfinder.mesh = _obstacleMesh;

        // we need a vector to store the path
        _path = new Array<Float>();
        
        // then configure the path sampler
        _pathSampler = new LinearPathSampler();
        _pathSampler.entity = _entityAI;
        _pathSampler.samplingDistance = 10;
        _pathSampler.path = _path;
        
		scene.getEngine().runRenderLoop(function () {
            scene.render();
        });
    }
    
    //Perform our updates
    private function onBeforeRender(scene:Scene, es:Null<EventState>) {
            
        _obstacleMesh.updateObjects();

        if(_pathSampler.hasNext) {
            _pathSampler.next();
        }

        var dt = scene.getEngine().getDeltaTime();
        _elapsedTime += dt;

        //if enough time has elapsed, set the _keysHandled to false so they'll re-trigger
        if(_elapsedTime > 300) {
            _keysHandled = new Map();
        }

        if(_keysDown[Keycodes.key_1] && !_keysHandled[Keycodes.key_1]) {
            
            _keysHandled[Keycodes.key_1] = true;
        }
    }

    private function onKeyDown(keyCode:Int) {
        _keysDown[keyCode] = true;
    }

    private function onKeyUp(keyCode:Int) {
        _keysDown[keyCode] = false;
        _keysHandled[keyCode] = false;
    }

    private function onMouseDown(evt:PointerEvent) {
            
        //todo
        //we can't just use evt.x and evt.y because they're in screen space 
        //need to get intersection of screen x,y with plane
        var world = Matrix.Identity();

        var ray = this._scene.createPickingRay(evt.x, evt.y, world);

        var plane:Plane = Plane.FromPositionAndNormal(Vector3.Zero(), Vector3.Forward());

        //intersect a plane 
        var distance = ray.intersectsPlane(plane);
        
        if(distance > Math.NEGATIVE_INFINITY)
        {
            var hitPos = ray.origin.add(ray.direction.multiplyByFloats(distance, distance, distance));
            _pathfinder.findPath(hitPos.x, hitPos.y, _path );

            var pathPoints:Array<Vector3> = [];
    
            var i = 2;
            while (i < _path.length) {
                pathPoints.push(new Vector3(_path[i], _path[i + 1]));
                i += 2;
            }
    
            if(_pathMesh != null) {
                _pathMesh.dispose();
            }
    
            _pathMesh = com.babylonhx.mesh.Mesh.CreateLines("", pathPoints, _scene, false);
            _pathMesh.color = Color3.Red();	
        }
    }
}
