import luxe.Vector;
import luxe.Color;
import luxe.utils.Maths;

typedef TerrainSaveData = {
	public var x : Float;
	public var y : Float;
	public var segmentLen : Float;
	public var heights : Array<Float>;
};

class Terrain {
	public var data (default, set) : TerrainSaveData;
	public var pos (get, set) : Vector;
	public var length (get, null) : Float;

	private var terrainWorldPos : Array<Vector> = [];
	private var geometry : Array<phoenix.geometry.Geometry> = [];

	public function new(saveData : TerrainSaveData) {
		data = saveData;
	}

	/*
	public function new(pos : Vector, segmentLen : Float, heights : Array<Float>) {
		data = {
			x : pos.x,
			y : pos.y,
			segmentLen : segmentLen,
			heights : heights
		};
	}
	*/

	public function draw(c : Color) {
		for (i in 1 ... terrainWorldPos.length) {
			var l = Luxe.draw.line({
				p0 : terrainWorldPos[i - 1],
				p1 : terrainWorldPos[i],
				depth : -100,
				color : c
			});

			geometry.push(l);
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

	function set_data(d : TerrainSaveData) : TerrainSaveData {
		trace("set data");
		data = d;
		calcTerrainWorldPos();
		return data;
	}

	function calcTerrainWorldPos() {
		terrainWorldPos = [];
		var count = 0;
		for (h in data.heights) {
			terrainWorldPos.push( new Vector(data.x + (count * data.segmentLen), data.y - h) );
			count++;
		}
	}

	function get_pos() : Vector {
		return new Vector(data.x, data.y);
	}

	function set_pos(v : Vector) : Vector {
		data.x = v.x;
		data.y = v.y;
		return v;
	}

	function get_length() : Float {
		return data.segmentLen * (data.heights.length - 1);
	}

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

	public function worldPosToTerrainPos(worldPos : Vector) : Vector {
		return new Vector(worldPos.x - pos.x, pos.y - worldPos.y); //y is reversed because "height" actually goes negative (might be dumb)
	}
}