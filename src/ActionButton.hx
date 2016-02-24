import luxe.Color;
import phoenix.geometry.*;
using ColorExtender;

enum Direction {
	Left;
	Right;
	Up;
	Down;
}

enum OutroAnimation {
	Disapear;
	FillScreen;
	Emphasize;
}

class ActionButton {
	//saveable data (extract into its own struct-like object?)
	var backgroundColor : Color;
	var illustrationColor : Color;
	public var terrainPos : Float;
	public var height : Float;
	var startSize : Float;
	var endSize : Float;
	var pullDir : Direction;
	var outro : OutroAnimation;

	public var terrain : Terrain;
	var circle : Geometry;

	public function new() {

	}

	public function draw() {
		var worldPos = terrain.worldPosFromTerrainPos(terrainPos);
		worldPos.y -= height; //height above the terrain
		circle = Luxe.draw.circle({
			x : worldPos.x, y : worldPos.y,
			r : startSize,
			color : backgroundColor
		});
	}

	public function clear() {
		Luxe.renderer.batcher.remove(circle);
	}

	public function toJson() {
		return {
			type : "action",
			backgroundColor : backgroundColor.toJson(),
			illustrationColor : illustrationColor.toJson(),
			terrainPos : terrainPos,
			height : height,
			startSize : startSize,
			endSize : endSize,
			pullDir : pullDir.getName(),
			outro : outro.getName()
		};
	}

	public function fromJson(json : Dynamic) : ActionButton {
		backgroundColor = (new Color()).fromJson(json.backgroundColor);
		illustrationColor = (new Color()).fromJson(json.illustrationColor);
		terrainPos = json.terrainPos;
		height = json.height;
		startSize = json.startSize;
		endSize = json.endSize;
		pullDir = Direction.createByName(json.pullDir);
		outro = OutroAnimation.createByName(json.outro);

		return this;
	}
}