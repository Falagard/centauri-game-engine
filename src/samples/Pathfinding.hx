package samples;

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
//import hxDaedalus.view.SimpleView;
import hxDaedalus.factories.RectMesh;

/**
 
*/
class Pathfinding extends SampleBase {

    private var _startPosition:Vector2 = Vector2.Zero();
    private var _endPosition:Vector2 = Vector2.Zero();
    private var _obstacleMesh : Mesh;
    private var _entityAI:EntityAI;
    private var _pathfinder:PathFinder;
    private var _pathSampler:LinearPathSampler;
    private var _path:Array<Float>;
    private var _pathMesh:LinesMesh = null;
    private var _obstacleLineMeshes:Array<LinesMesh>;
    private var _arrowMesh:com.babylonhx.mesh.Mesh = null; 
    private var _turtleDrawer:TurtleDrawer = null;

    private var _onKeyDown:Int->Void = function(keycode:Int) { };
    private var _onKeyUp:Int->Void = function(keycode:Int) { };
    private var _onMouseDown:PointerEvent->Void = function(evt:PointerEvent) { };

    private var _camera:ArcRotateCamera = null;
    private var _light:HemisphericLight = null;

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

        _turtleDrawer = new TurtleDrawer(_scene);

        //make a little triangle we'll use for our entity position
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

        //grab the current mesh so it doesn't get disposed when we call disposeMeshes()
        _arrowMesh = _turtleDrawer._meshes[0];
        _turtleDrawer._meshes = [];

        _turtleDrawer.disposeMeshes();

        //an obstacle using the Turtle commands
        _turtleDrawer._system = "-FFFF+FFF-FFFF+FFFFFFFF+++++FFFFFFF+FF+FFFFF-FFFF-FFFFFFFF-FF+FFFFFF-FFFFFF-FFFFFF+FF+FFFFFFFF+FFFFFFFFFF+FFFFFF-FF-FFFFFFFFFF+FFFFFFFFFFFFFF+FFFFFFFFFFFFFFFFFFFFFFF+FF+F+F-FFFFFFFFFFFFFFFFFFFFF-FFFFFFFFFF-FF+FF-FFFFFFFF+FF-FFFFFF-FFF-FFF+F";

        //we're going to use our turtle code to generate a set of points that we'll pass to hxdaedalus for our obstacle
        _turtleDrawer.beginMesh();
        _turtleDrawer.evaluateSystem();
        _turtleDrawer.endMesh();
        
        _turtleDrawer._meshes[0].setEnabled(false); //don't draw it

        //now we have each turtle position stored in _points, we're going to use this as our obstacle

        //first we need to figure out the boundaries of all points to get a containing rectangle we can use as the outside limits of our pathfinding

        //get the extents of _points
        var minPoint:Vector2 = new Vector2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        var maxPoint:Vector2 = new Vector2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

        for(point in _turtleDrawer._points) {
            minPoint.x = Math.min(minPoint.x, point.x);
            minPoint.y = Math.min(minPoint.y, point.y);
            maxPoint.x = Math.max(maxPoint.x, point.x);
            maxPoint.y = Math.max(maxPoint.y, point.y);
        }

        //let's translate all points into positive and add a bit for a border 

        //find the amount of x and y we need add so all points are positive
        var deltaY:Float = 0 - minPoint.y;
        var deltaX:Float = 0 - minPoint.x;

        var border:Float = 50;

        if(deltaY > 0) {
            for(point in _turtleDrawer._points) {
                point.y += deltaY + border; //move each position by this amount, plus add border 
            }
        }

        if(deltaX > 0) {
            for(point in _turtleDrawer._points) {
                point.x += deltaX + border;
            }
        }

        minPoint = new Vector2(Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY);
        maxPoint = new Vector2(Math.NEGATIVE_INFINITY, Math.NEGATIVE_INFINITY);

        //get our extents so we can pass these to hxdadelus for our obstacle boundaries
        for(point in _turtleDrawer._points) {
            minPoint.x = Math.min(minPoint.x, point.x);
            minPoint.y = Math.min(minPoint.y, point.y);
            maxPoint.x = Math.max(maxPoint.x, point.x);
            maxPoint.y = Math.max(maxPoint.y, point.y);
        }

        //Now for the pathfinding mesh
        //We'll use our extents maxPoint to build our boundary rectangle which starts at 0,0 and goes out to maxPoint.x + border and maxPoint.y + border
        _obstacleMesh = RectMesh.buildRectangle(maxPoint.x + border, maxPoint.y + border);

        //Add a constraint object - this will use our turtle obstacle 
        var object:Object = new Object();
        
        object.coordinates = new Array<Float>();

        var prevPoint:Vector3 = null;
        
        //hxdaedalus allows you to insert an object with line segments so we'll pass our points as 
        //a line segment between every two points

        //for each set of points 
        for(point in _turtleDrawer._points) {
            if(prevPoint == null) {
                prevPoint = point;
                continue;
            }

            //from
            object.coordinates.push(prevPoint.x);
            object.coordinates.push(prevPoint.y);
            //to
            object.coordinates.push(point.x);
            object.coordinates.push(point.y);

            prevPoint = point;
        }

        _obstacleMesh.insertObject(object);
        
        //now we're going to create a mesh that will allow us to visualize the obstacle and walkable paths
        var vertsAndEdges = _obstacleMesh.getVerticesAndEdges();

        var edgePoints:Array<Vector3> = [];

        _obstacleLineMeshes = [];

        //create meshes from the edges 
        for(edge in vertsAndEdges.edges) {
            
            edgePoints.push(new Vector3(edge.originVertex.pos.x, edge.originVertex.pos.y, 0));
            edgePoints.push(new Vector3(edge.destinationVertex.pos.x, edge.destinationVertex.pos.y, 0));            
            
            var mesh = com.babylonhx.mesh.Mesh.CreateLines("", edgePoints, _scene, false);

            //constrained edges are the obstacle edges and not constrained are the walkable edges
            if(edge.isConstrained) {
                mesh.color = Color3.White();
            } else {
                mesh.color = Color3.Blue();
            }

            _obstacleLineMeshes.push(mesh);

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
        
    }

    /**
        Activate our state 
    **/
    public override function activate() {

        super.activate();

        if(_pathMesh != null) {
            _pathMesh.setEnabled(true);
        }

        for(mesh in _obstacleLineMeshes) {
            mesh.setEnabled(true);
        }
        
        _arrowMesh.setEnabled(true);

        //activate happens after init, so everything is created at this point
        _scene.getEngine().keyDown.push(_onKeyDown);
        _scene.getEngine().keyUp.push(_onKeyUp);
        _scene.getEngine().mouseDown.push(_onMouseDown);
        
        _light.setEnabled(true);
        _scene.activeCamera = _camera;

        _camera.attachControl();
    }

    /** 
        Deactivate our state
    **/
    public override function deactivate() {

        super.deactivate();

        if(_pathMesh != null) {
            _pathMesh.setEnabled(false);
        }

        for(mesh in _obstacleLineMeshes) {
            mesh.setEnabled(false);
        }

        _arrowMesh.setEnabled(false);

        _scene.getEngine().keyDown.remove(_onKeyDown);
        _scene.getEngine().keyUp.remove(_onKeyUp);
        _scene.getEngine().mouseDown.remove(_onMouseDown);

        _light.setEnabled(false);

        _camera.detachControl();
    }
    
    //Perform our updates
    public override function onBeforeRender(scene:Scene, es:Null<EventState>) {
            
        _obstacleMesh.updateObjects();

        if(_pathSampler.hasNext) {
            _pathSampler.next();
            _arrowMesh.position.x = _entityAI.x;
            _arrowMesh.position.y = _entityAI.y;
            _arrowMesh.position.z = 0;
        }

        var dt = scene.getEngine().getDeltaTime();
        _elapsedTime += dt;

        //if enough time has elapsed, set the _keysHandled to false so they'll re-trigger
        // if(_elapsedTime > 300) {
        //     _keysHandled = new Map();
        // }

        // if(_keysDown[Keycodes.key_1] && !_keysHandled[Keycodes.key_1]) {
            
        //     _keysHandled[Keycodes.key_1] = true;
        // }
    }

    private function onKeyDown(keyCode:Int) {
        _keysDown[keyCode] = true;
    }

    private function onKeyUp(keyCode:Int) {
        _keysDown[keyCode] = false;
        _keysHandled[keyCode] = false;
    }

    private function onMouseDown(evt:PointerEvent) {
            
        //we can't just use evt.x and evt.y because they're in screen space 
        //need to get intersection of screen x,y with a plane so we can get the world space position
        var world = Matrix.Identity();

        var ray = this._scene.createPickingRay(evt.x, evt.y, world);

        var plane:Plane = Plane.FromPositionAndNormal(Vector3.Zero(), Vector3.Forward());

        //intersect a plane 
        var distance = ray.intersectsPlane(plane);
        
        if(distance > Math.NEGATIVE_INFINITY)
        {
            var hitPos = ray.origin.add(ray.direction.multiplyByFloats(distance, distance, distance));
            _pathfinder.findPath(hitPos.x, hitPos.y, _path );

            _pathSampler.reset();
            
            //now get the path and create some lines to represent it
            var pathPoints:Array<Vector3> = [];
    
            var i = 0;
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
