package centauri.tween;

//import box2D.box2D.collision.B2AABB;
import com.babylonhx.math.Vector2;
import hxbt.Behavior;
import box2D.collision.B2AABB;
using tweenxcore.Tools;

/**
 * Static extension of point on XY coordinates. For example, Bezier curve. It can be used not only for the Point class in Flash, but also for Point types in various libraries.
 */
class Vector2Tools {

     // =================================================
     // Polyline
     // =================================================
    public static inline function polyline(outputPoint:Vector2, rate:Float, points:Array<Float>):Void {
        var xs = [];
        var ys = [];

        var flip = false;
        
        for (p in points) {
            if(!flip)
                xs.push(p);
            else
               ys.push(p);

            flip = !flip;
        }
        
        outputPoint.x = rate.polyline(xs);
        outputPoint.y = rate.polyline(ys);
    }
}    

//     // =================================================
//     // Bézier Curve
//     // =================================================
//     /** Quadratic Bernstein polynomial  */
//     public static inline function bezier2(outputPoint:Point, rate:Float, from:Point, control:Point, to:Point):Void {
//         outputPoint.x = rate.bezier2(from.x, control.x, from.x);
//         outputPoint.y = rate.bezier2(from.y, control.y, from.y);
//     }

//     /** Cubic Bernstein polynomial  */
//     public static inline function bezier3(outputPoint:Point, rate:Float, from:Point, control1:Point, control2:Point, to:Point):Void {
//         outputPoint.x = rate.bezier3(from.x, control1.x, control2.x, from.x);
//         outputPoint.y = rate.bezier3(from.y, control1.y, control2.y, from.y);
//     }
//     /** Bernstein polynomial, which is the mathematical basis for Bézier curve */
//     public static inline function bezier(outputPoint:Point, rate:Float, points:Iterable<Point>):Void {
//         var xs = [];
//         var ys = [];
//         for (p in points) {
//             xs.push(p.x);
//             ys.push(p.y);
//         }
//         outputPoint.x = rate.bezier(xs);
//         outputPoint.y = rate.bezier(ys);
//     }
    
//     // =================================================
//     // B-spline Curve
//     // =================================================
//     /** Uniform Quadratic B-spline */
//     public static inline function uniformQuadraticBSpline(outputPoint:Point, rate:Float, points:Iterable<Point>):Void {
//         var xs = [];
//         var ys = [];
//         for (p in points) {
//             xs.push(p.x);
//             ys.push(p.y);
//         }
//         outputPoint.x = rate.uniformQuadraticBSpline(xs);
//         outputPoint.y = rate.uniformQuadraticBSpline(ys);
//     }
// }
