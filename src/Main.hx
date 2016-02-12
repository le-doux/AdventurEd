import luxe.Input;
import luxe.Color;
import luxe.Vector;

import sys.io.File;
import sys.io.FileOutput;
import sys.io.FileInput;

import haxe.Json;

using TerrainEditor;
using ColorExtender;
using PolylineExtender;

/* TODO
	- put utilities in their own library if they're useful outside this project
	- circle brush editor
*/

class Main extends luxe.Game {

	var terrainColor : Color;
	var backgroundColor : Color;
	var sceneryColor : Color;

	var curTerrain : Terrain;

	var mode = 0;

	var zoomIncrement = 0.2;
	var panIncrement = 20;

	var prevCursorPos = null;

	var tmpStroke : Array<Vector> = [];
	var scenery : Array<Polystroke> = [];

	override function ready() {
		terrainColor = new Color(1,1,1);
		sceneryColor = new Color(1,0,0);
		backgroundColor = new Color(0,0,0);
		Luxe.renderer.clear_color = backgroundColor;

		curTerrain = new Terrain();
		curTerrain.draw(terrainColor);
	} //ready

	override function onkeydown( e:KeyEvent ) {

		//hack
		if (e.keycode == Key.key_1) mode = 0; //terrain
		if (e.keycode == Key.key_2) mode = 1; //scenery

		//open file
		if (e.keycode == Key.key_o && e.mod.meta ) {
			var path = Luxe.core.app.io.module.dialog_open();
			var fileStr = File.getContent(path);
			var json = Json.parse(fileStr);

			//rehydrate colors
			backgroundColor = (new Color()).fromJson(json.backgroundColor);
			terrainColor = (new Color()).fromJson(json.terrainColor);
			sceneryColor = (new Color()).fromJson(json.sceneryColor);
			Luxe.renderer.clear_color = backgroundColor;

			//rehydrate terrain
			if (curTerrain != null) curTerrain.clear();
			curTerrain = new Terrain();
			curTerrain.fromJson(json.terrain);
			curTerrain.draw(terrainColor);

			//rehydrate scenery
			scenery = [];
			for (s in cast(json.scenery, Array<Dynamic>)) {
				scenery.push( (new Polystroke({color : sceneryColor, batcher : Luxe.renderer.batcher}, [])).fromJson(s) ); //feels hacky
			}
		}

		//save file
		if (e.keycode == Key.key_s && e.mod.meta) {
			//get path & open file
			var path = Luxe.core.app.io.module.dialog_save();
			var output = File.write(path);

			//get data & write it
			var saveJson = {
				backgroundColor : backgroundColor.toJson(),
				terrainColor : terrainColor.toJson(),
				sceneryColor : sceneryColor.toJson(),
				terrain : curTerrain.toJson(),
				scenery : []
			};
			for (s in scenery) {
				saveJson.scenery.push(s.toJson());
			}

			var saveStr = Json.stringify(saveJson, null, "    ");
			output.writeString(saveStr);

			//close file
			output.close();
		}

		//delete hack
		if (e.keycode == Key.key_d && curTerrain.points.length > 2) {
			if (e.mod.meta) {
				curTerrain.removeStartPoint();
			}
			else {
				curTerrain.removeEndPoint();
			}
			curTerrain.redraw(terrainColor);
		}

		panScene(e);
		zoomScene(e);

	}

	/*
	override function onwindowresized(e) {
		trace(Luxe.camera.size);
	}
	*/

	function panScene(e : KeyEvent) {
		if (e.keycode == Key.left) {
			Luxe.camera.pos.add(new Vector(-panIncrement, 0));
		}
		else if (e.keycode == Key.right) {
			Luxe.camera.pos.add(new Vector(panIncrement, 0));
		}

		if (e.keycode == Key.up) {
			Luxe.camera.pos.add(new Vector(0, -panIncrement));
		}
		else if (e.keycode == Key.down) {
			Luxe.camera.pos.add(new Vector(0, panIncrement));
		}
	}

	function zoomScene(e : KeyEvent) {
		if (e.keycode == Key.minus) {
			Luxe.camera.zoom -= zoomIncrement;
		}
		else if (e.keycode == Key.equals) {
			Luxe.camera.zoom += zoomIncrement;
		}
	}

	override function onkeyup( e:KeyEvent ) {

	    if (e.keycode == Key.escape) {
	        Luxe.shutdown();
	    }

	} //onkeyup

	override function onmousedown( e:MouseEvent ) {

		var screen_point = e.pos;
		var world_point = Luxe.camera.screen_point_to_world( screen_point );

		if (mode == 0) {
			var prevSize = curTerrain.points.length;
			curTerrain.buildTerrainToPoint(world_point);
			if (prevSize != curTerrain.points.length) curTerrain.redraw(terrainColor);

			prevCursorPos = screen_point;
		}
		else if (mode == 1) {
			tmpStroke = [];
			tmpStroke.push(world_point);
		}		
	}

	override function onmousemove(e:MouseEvent) {
		//TODO move stuff here
		if (Luxe.input.mousedown(1)) {

			var screen_point = Luxe.screen.cursor.pos;
			var world_point = Luxe.camera.screen_point_to_world( screen_point );

			if (mode == 0) {
				var prevSize = curTerrain.points.length;
				var prev_world_point = Luxe.camera.screen_point_to_world( prevCursorPos );

				curTerrain.buildTerrainAlongLine(prev_world_point, world_point);
				if (prevSize != curTerrain.points.length) curTerrain.redraw(terrainColor);

				prevCursorPos = screen_point;
			}
			else if (mode == 1) {
				tmpStroke.push(world_point);
			}
		}
	}

	override function onmouseup( e:MouseEvent ) {
		prevCursorPos = null;

		if (tmpStroke.length > 0) {
			var p = new Polystroke({color : sceneryColor, batcher : Luxe.renderer.batcher}, tmpStroke.clone());
			scenery.push(p);
		}
		tmpStroke = [];
	}

	override function update(dt:Float) {

		//draw tmp drawing
		for (i in 1 ... tmpStroke.length) {
			var p0 = tmpStroke[i-1];
			var p1 = tmpStroke[i];
			Luxe.draw.line({
				p0 : p0,
				p1 : p1,
				color : sceneryColor,
				immediate : true
			});
		}

	} //update


} //Main
