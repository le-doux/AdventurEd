import luxe.Input;
import luxe.Color;
import luxe.Vector;

import sys.io.File;
import sys.io.FileOutput;
import sys.io.FileInput;

import haxe.Json;

using TerrainEditor;

/* TODO
	- put utilities in their own library if they're useful outside this project
	- basic editor
	- circle brush editor
	- save / open
	- edit
	- json extenders (color?)
*/

class Main extends luxe.Game {

	var curTerrain : Terrain;
	var zoomIncrement = 0.2;
	var panIncrement = 20;

	var prevCursorPos = null;

	override function ready() {
		curTerrain = new Terrain();
		curTerrain.draw(new Color(1,1,1));
	} //ready

	override function onkeydown( e:KeyEvent ) {

		//open file
		if (e.keycode == Key.key_o && e.mod.meta ) {
			var path = Luxe.core.app.io.module.dialog_open();
			var fileStr = File.getContent(path);
			var json = Json.parse(fileStr);

			if (curTerrain != null) curTerrain.clear();
			curTerrain = new Terrain();
			curTerrain.setFromJson(json);
			curTerrain.draw(new Color(1,1,1));
		}

		//save file
		if (e.keycode == Key.key_s && e.mod.meta) {
			//get path & open file
			var path = Luxe.core.app.io.module.dialog_save();
			var output = File.write(path);

			//get data & write it
			var saveJson = curTerrain.getJson();
			var saveStr = Json.stringify(saveJson);
			//trace(saveStr);
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
			curTerrain.redraw(new Color(1,1,1));
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

		var prevSize = curTerrain.points.length;

		var screen_point = e.pos;
		var world_point = Luxe.camera.screen_point_to_world( screen_point );

		curTerrain.buildTerrainToPoint(world_point);
		if (prevSize != curTerrain.points.length) curTerrain.redraw(new Color(1,1,1));

		prevCursorPos = screen_point;		
	}

	override function onmousemove(e:MouseEvent) {
		//TODO move stuff here
	}

	override function onmouseup( e:MouseEvent ) {
		prevCursorPos = null;
	}

	override function update(dt:Float) {

		if (Luxe.input.mousedown(1)) {

			var prevSize = curTerrain.points.length;

			var screen_point = Luxe.screen.cursor.pos;
			var world_point = Luxe.camera.screen_point_to_world( screen_point );
			var prev_world_point = Luxe.camera.screen_point_to_world( prevCursorPos );

			curTerrain.buildTerrainAlongLine(prev_world_point, world_point);
			if (prevSize != curTerrain.points.length) curTerrain.redraw(new Color(1,1,1));

			prevCursorPos = screen_point;
		}

	} //update


} //Main
