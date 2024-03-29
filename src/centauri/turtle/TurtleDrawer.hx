package centauri.turtle;

import com.babylonhx.loading.plugins.BabylonFileLoader;
import com.babylonhx.math.Matrix;
import com.babylonhx.math.Quaternion;
import com.babylonhx.engine.EngineCapabilities.WEBGL_compressed_texture_s3tc;
import com.babylonhx.utils.Keycodes;
import com.babylonhx.cameras.FreeCamera;
import haxe.iterators.StringIterator;
import com.babylonhx.states._AlphaState;
import com.babylonhx.math.Space;
import com.babylonhx.math.Angle;
import com.babylonhx.math.Axis;
import com.babylonhx.mesh.TransformNode;
import com.babylonhx.math.Tmp;
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

/**
 * ...
 * @author Clay Larabie
 */

class TurtleTransform {
    public var position:Vector3 = Vector3.Zero();
    public var rotationQuaternion:Quaternion = Quaternion.Identity();

    public function new() {
		//...
	}
}

class TurtleDrawer {

    var _scene:Scene = null;
    var _createMeshes:Bool = true;

    public var _currentTransform: TurtleTransform = null;
    public var _penUpPosition: Vector3 = null;
    public var _currentPoints:Array<Vector3> = [];
    private var _transformsStack:Array<TurtleTransform> = [];
    private var _branchCounter:Int = 1;
    private var _colorsStack:Array<Color3> = [];

    public var _turnRadius:Float = 45;
    public var _distance:Float = 10;
    public var _distanceDiag:Float = 14.14214;
    public var _system:String = "";
    public var _meshes:Array<Mesh> = [];
    public var _points:Array<Array<Vector3>> = [];
    
    private var _penDown:Bool = true;

    private static var _rotationAxisCache:Quaternion = new Quaternion();
    private static var _rotationAxisTemp:Quaternion = new Quaternion();
    private static var _pivotMatrixTemp:Matrix = Matrix.Identity();
    private static var _localWorldTemp:Matrix = Matrix.Zero();
    private static var _invLocalWorldTemp:Matrix = Matrix.Zero();
    private static var _positionLocalTemp:Vector3 = Vector3.Zero();


    public function new(scene:Scene, createMeshes:Bool) {
        _createMeshes = createMeshes;
        _scene = scene;
    }

	inline public function rollClockwise(degrees:Float) {
        rotate(Axis.X, DegreesToRadians(degrees));
    }

    inline public function rollCounterClockwise(degrees:Float) {
        rotate(Axis.X, DegreesToRadians(degrees * -1));
    }

    inline public function pitchUp(degrees:Float) {
        rotate(Axis.Y, DegreesToRadians(degrees));
    }

    inline public function pitchDown(degrees:Float) {
        rotate(Axis.Y, DegreesToRadians(degrees * -1));
    }

    inline public function right(degrees:Float) {
        rotate(Axis.Z, DegreesToRadians(degrees));
    }
	
	inline public function left(degrees:Float) {
        rotate(Axis.Z, DegreesToRadians(degrees * -1));
    }

    inline public function DegreesToRadians(degrees:Float) {
        return Math.PI / 180 * degrees;
    }

    inline public function translate(axis:Vector3, distance:Float) {
        //this was copied out of TransformNode.translate but optimized to remove allocations and extraneous logic

        //axis scaled by distance
        axis.scaleToRef(distance, Tmp.vector3[0]);

        //scale stored in mat[1]
		Matrix.ScalingToRef(1, 1, 1, Tmp.matrix[1]);

        //quaternion to matrix stored in mat[0]
        _currentTransform.rotationQuaternion.toRotationMatrix(Tmp.matrix[0]);
        //translation to matrix stored in mat[2]
        Matrix.TranslationToRef(_currentTransform.position.x, _currentTransform.position.y, _currentTransform.position.z, Tmp.matrix[2]);
        
        //scale multiplied by pivot (identity) - stored in mat[4]
        _pivotMatrixTemp.multiplyToRef(Tmp.matrix[1], Tmp.matrix[4]);

        //pivot+scale multiplied by rotation stored in matrix 5
		Tmp.matrix[4].multiplyToRef(Tmp.matrix[0], Tmp.matrix[5]);
        //pivot+scale+rotation multiplied by position stored in _localWorldTemp
		Tmp.matrix[5].multiplyToRef(Tmp.matrix[2], _localWorldTemp);
        //invert
        _invLocalWorldTemp.copyFrom(_localWorldTemp);
		_invLocalWorldTemp.invert();
        //transform and store in positionLocalTemp
        Vector3.TransformNormalToRef(_currentTransform.position, _invLocalWorldTemp, _positionLocalTemp);
        //add axis vector 
        _positionLocalTemp.addToRef(Tmp.vector3[0], Tmp.vector3[1]);
        //set the position 
        _currentTransform.position = Vector3.TransformNormal(Tmp.vector3[1], _localWorldTemp);      
    }

    public function rotate(axis:Vector3, amount:Float) {
        //this was copied out of TransformNode.rotate 
        //axis.normalize(); //unnecessary since RotationAxiToRef already normalizes
        
        var tempRotationQuaternion:Quaternion = Quaternion.RotationAxisToRef(axis, amount, _rotationAxisCache);
	    _currentTransform.rotationQuaternion.multiplyToRef(tempRotationQuaternion, _currentTransform.rotationQuaternion);
    }

    public function forward(amount:Float) {
        translate(Axis.X, amount);

        if(_penDown) {
            _currentPoints.push(_currentTransform.position);
        }
    }

    inline public function penDown() {
        if(!_penDown) {
            //the position has changed since penup, then create the mesh and reset points
            if(_penUpPosition != null && !_penUpPosition.equals(_currentTransform.position) && _currentPoints.length > 0) {
                if(_createMeshes) {                
                    var mesh = Mesh.CreateLines("line", _currentPoints, _scene, false);
                    mesh.color = Color3.White();
                    _meshes.push(mesh);
                }
                _points.push(_currentPoints);
                _currentPoints = [];
                _currentPoints.push(_currentTransform.position);
            }
        }

        _penDown = true;
    }

    inline public function penUp() {
        if(_penDown && _currentTransform != null) {
            //store the position on penUp
            _penUpPosition = _currentTransform.position.clone();
        }

        _penDown = false;
    }
    
    inline public function beginBranch() {
        //create a copy of current transform
        var tempTfm = new TurtleTransform();
        tempTfm.position = _currentTransform.position.clone();
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion.clone();        
        
        _transformsStack.push(tempTfm); //push our current transform on the stack so we can revert it in endBranch
        _branchCounter++;

        //create a new temp transform, copy position and rotation from current transform and set _tfm 
        tempTfm = new TurtleTransform();
        tempTfm.position = _currentTransform.position.clone();
        tempTfm.rotationQuaternion = _currentTransform.rotationQuaternion.clone();        
        
        _currentTransform = tempTfm;

        var color:Color3 = Color3.White();
        _colorsStack.push(color);
    }

    inline public function endBranch() {
        var mesh:com.babylonhx.mesh.LinesMesh = null;
        var color = _colorsStack.pop();

        if(_createMeshes) {
            mesh = Mesh.CreateLines("branch", _currentPoints, _scene, false);
            mesh.color = color;
        }
        _currentPoints = [];
        _currentTransform = _transformsStack.pop(); //pop the previous position back off the stack

        if(_penDown) {
            _currentPoints.push(_currentTransform.position); //current position as our starting point
        }

        if(_createMeshes) {
            _meshes.push(mesh);
        }
    }

    public function clear() {
        //destroy current mesh and rebuild from scratch
        for(mesh in _meshes) {
            mesh.dispose();
        }

        _meshes = [];
        _currentPoints = [];
        _colorsStack = [];
        _transformsStack = [];
        _points = [];
    }

    public function dispose() {
        clear();
    }

    public function showMeshes() {
        //destroy current mesh and rebuild from scratch
        for(mesh in _meshes) {
            mesh.setEnabled(true);
        }
    }

    public function hideMeshes() {
        //destroy current mesh and rebuild from scratch
        for(mesh in _meshes) {
            mesh.setEnabled(false);
        }
    }

    public function beginMesh() {
        //_currentTransform = new TransformNode("tfm", _scene, true);
        _currentTransform = new TurtleTransform();

        right(90); //starts us pointing up
        
        if(_penDown) {
            _currentPoints.push(_currentTransform.position);
        }
        _colorsStack.push(Color3.White()); //not yet supported but this is for color changing
    }

    public function endMesh() {
        var color = _colorsStack.pop();

        if(_createMeshes) {
            var mesh = Mesh.CreateLines("branch", _currentPoints, _scene, false);
            mesh.color = color;
            _meshes.push(mesh);
        }
    }

    // public function setDistance(distance:Float) {
    //     //change the distance 
    //     _distance = distance;
    //     //change the 45 degree movement distance to match
    //     _distanceDiag = Math.sqrt((distance * distance) + (distance * distance));
    // }

    public function reset() {
        clear();
        penDown();
    }
    
    public function evaluateSystem() {

        // var parameter:Float = 0;
        // var parameterStr:String = "";
        // var skip:Int = 0; //number of characters to skip when we find a parameter
        // var nextClosingBracket:Int = 0;
        // var previousDistance:Float = 0;
        // var previousRotation:Float = 0;

        //todo - do a check that there are an equal number of open and close braces, etc.

        //loop through the characters, does not validate begin and end branches yet
        for(i in 0..._system.length) {
            var item = _system.charAt(i);

            //todo - support parameterized commands like F(10) or +(270)
            //check if the next character is an open bracket "(" and if so it is used to be a parameter to the move, rotate, etc. as a distance or angle 
            //check if we have at least 2 more characters
            // if(i + 2 < _system.length) {
            //     var nextItem = _system.charAt(i + 1);

            //     if(nextItem == "(") {
            //         //this is a parameter, find the next closing bracket starting at i + 1
            //         nextClosingBracket = _system.indexOf(")", i + 1);

            //         if(nextClosingBracket > 0) {
            //             //get the parameter
            //             parameterStr = _system.substr(i + 1, nextClosingBracket);
            //         }
            //     }
            // }

            if(item == "F") {
                forward(_distance);
            } else if(item == "f") {
                //small f is a diagonal movement 
                forward(_distanceDiag);               
            } else if(item == "+") {
                right(_turnRadius);
            } else if(item == "-") {
                left(_turnRadius);
            } else if(item == "/") {
                rollCounterClockwise(_turnRadius);
            } else if(item == "\\") {
                rollClockwise(_turnRadius);
            } else if(item == "&") {
                pitchUp(_turnRadius);
            } else if(item == "^") {
                pitchDown(_turnRadius);
            }
            else if(item == "[") {
                beginBranch();
            }
            else if(item == "]") {
                endBranch();
            }
            else if(item == "X" || item == "A") {
                //no op
            }
            else if(item == "u") {
                penUp();
            }
            else if(item == "j") {
                penDown();
            } else {
                //everything else is interpetted as forward
                forward(_distance);
            }
        }
    }
}
