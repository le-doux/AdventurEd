import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;

using VectorExtender;
using PolylineExtender;

class Terrain {

	public var points : Array<Vector> = [];
	public var length (get, null) : Float;

	private var geometry : Array<phoenix.geometry.Geometry> = [];

	public function new() {
		//test
		for (i in 0 ... 20) {
			points.push( new Vector(50 + (i * 20), 600));
		}

	}

	public function draw(c : Color) {
		for (i in 1 ... points.length) {
			trace(points[i]);
			var g = Luxe.draw.line({
				p0 : points[i - 1],
				p1 : points[i],
				depth : -100,
				color : c
			});

			geometry.push(g);
		}
	}

	public function clear() {
		for (g in geometry) {
			Luxe.renderer.batcher.remove(g);
		}
	}

	public function redraw(c : Color) {
		clear();
		draw(c);
	}

	function get_length() : Float {
		var l = 0.0;
		for (i in 1 ... points.length) {
			l += points[i-1].distance(points[i]); //TODO: replace with just x length?
		}
		return l;
	}

	public function toJson() : Array<Dynamic> {
		/*
		var json = [];
		for (p in points) {
			json.push( p.toJson() );
		}
		return json;
		*/
		return points.toJson();
	}

	public function fromJson(json : Array<Dynamic>) {
		/*
		points = [];
		for (j in json) {
			points.push( (new Vector()).fromJson(j) );
		}
		*/
		points = points.fromJson(json);
		trace(points);
	}

	public function closestIndexHorizontally(x : Float) : Int {
		var closestIndex = 0;
		for (i in 1 ... points.length) {
			if ( Math.abs(points[i].x - x) < Math.abs(points[closestIndex].x - x) ) {
				closestIndex = i;
			}
		}
		return closestIndex;
	}

	//TODO - redo these functions
	/*
	public function closestIndexToTerrainPos(pos : Float) : Int {
		return cast( Math.min( Math.floor( (pos / length) * (terrainWorldPos.length - 1) ), (terrainWorldPos.length - 2) ), Int );
	}

	public function worldPosFromTerrainPos(pos : Float) : Vector {
		var segIndex = closestIndexToTerrainPos( pos );
		var leftoverDist = (pos - (segIndex * data.segmentLen));
		var leftoverDistPercent = leftoverDist / data.segmentLen;
		var seg0 = terrainWorldPos[segIndex];
		var seg1 = terrainWorldPos[segIndex+1];
		var segDelt = Vector.Subtract(seg1, seg0);
		var segDeltPercent = Vector.Multiply(segDelt, leftoverDistPercent);
		return Vector.Add(seg0, segDeltPercent);
	}

	public function slopeAtPos(pos : Float) : Float {
		var segIndex = closestIndexToTerrainPos( pos );
		var unitVec = Vector.Subtract(terrainWorldPos[segIndex + 1], terrainWorldPos[segIndex]).normalized;
		return Maths.degrees(unitVec.angle2D);
	}
	*/
}