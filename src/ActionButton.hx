import luxe.Color;
import luxe.Vector;
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
	public var startSize : Float;
	var endSizeMult : Float;
	var pullDir : Direction;
	var outro : OutroAnimation;

	public var terrain : Terrain;
	var geo : Array<Geometry> = [];

	public function new() {

	}

	//do I need a dynamic draw too? (especially for the arrows)
	public function draw() {
		var worldPos = terrain.worldPosFromTerrainPos(terrainPos);
		worldPos.y -= height; //height above the terrain
		geo.push(
			Luxe.draw.circle({
				x : worldPos.x, y : worldPos.y,
				r : startSize,
				color : backgroundColor,
				depth : 0
			})
		);

		geo.push(
			Luxe.draw.ring({
				x : worldPos.x, y : worldPos.y,
				r : startSize,
				color : illustrationColor,
				depth : 1
			})
		);

		/*
		//draw final size too
		geo.push(
			Luxe.draw.ring({
				x : worldPos.x, y : worldPos.y,
				r : startSize * endSizeMult,
				color : illustrationColor,
				depth : 1
			})
		);
		*/

		//this is a ridiculous switch statement (remove as soon as possible)
		switch pullDir {
			case Direction.Left:
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x - startSize - 30, worldPos.y),
						p1 : new Vector(worldPos.x - startSize - 10, worldPos.y - 10),
						color : illustrationColor
					})
				);
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x - startSize - 30, worldPos.y),
						p1 : new Vector(worldPos.x - startSize - 10, worldPos.y + 10),
						color : illustrationColor
					})
				);
			case Direction.Right:
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x + startSize + 30, worldPos.y),
						p1 : new Vector(worldPos.x + startSize + 10, worldPos.y - 10),
						color : illustrationColor
					})
				);
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x + startSize + 30, worldPos.y),
						p1 : new Vector(worldPos.x + startSize + 10, worldPos.y + 10),
						color : illustrationColor
					})
				);
			case Direction.Up:
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x, worldPos.y - startSize - 10),
						p1 : new Vector(worldPos.x - 10, worldPos.y - startSize - 30),
						color : illustrationColor
					})
				);
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x, worldPos.y - startSize - 10),
						p1 : new Vector(worldPos.x + 10, worldPos.y - startSize - 30),
						color : illustrationColor
					})
				);
			case Direction.Down:
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x, worldPos.y + startSize + 30),
						p1 : new Vector(worldPos.x - 10, worldPos.y + startSize + 10),
						color : illustrationColor
					})
				);
				geo.push(
					Luxe.draw.line({
						p0 : new Vector(worldPos.x, worldPos.y + startSize + 30),
						p1 : new Vector(worldPos.x + 10, worldPos.y + startSize + 10),
						color : illustrationColor
					})
				);
		}
	}

	public function clear() {
		//Luxe.renderer.batcher.remove(circle);
		for (g in geo) {
			Luxe.renderer.batcher.remove(g);
		}
	}

	//immediate mode drawing
	public function drawUI() {
		var worldPos = terrain.worldPosFromTerrainPos(terrainPos);
		worldPos.y -= height; //height above the terrain

		Luxe.draw.ring({
			x : worldPos.x, y : worldPos.y,
			r : startSize * endSizeMult,
			color : illustrationColor,
			depth : 1,
			immediate : true
		});
	}

	public function toJson() {
		return {
			type : "action",
			backgroundColor : backgroundColor.toJson(),
			illustrationColor : illustrationColor.toJson(),
			terrainPos : terrainPos,
			height : height,
			startSize : startSize,
			endSizeMult : endSizeMult,
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
		endSizeMult = json.endSizeMult;
		pullDir = Direction.createByName(json.pullDir);
		outro = OutroAnimation.createByName(json.outro);

		return this;
	}
}