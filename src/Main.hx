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
		/*
		if (e.keycode == Key.key_o && e.mod.meta ) {
			var path = Luxe.core.app.io.module.dialog_open();
			var fileStr = File.getContent(path);
			var json = Json.parse(fileStr);

			if (curTerrain != null) curTerrain.clear();
			curTerrain = new Terrain(json);
			curTerrain.draw(new Color(1,0,1));
		}
		*/

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
		/*
		var screen_point = e.pos;
		var world_point = Luxe.camera.screen_point_to_world( screen_point );
		var terrain_point = curTerrain.worldPosToTerrainPos( world_point );
		trace( terrain_point );
		if (terrain_point.x > 0 && terrain_point.x < curTerrain.length) {
			//TODO
			curTerrain.data.heights[ curTerrain.closestIndexToTerrainPos(terrain_point.x) ] = terrain_point.y;
			//TODO
			curTerrain.redraw(new Color(1,1,1));
		}
		*/

		
	}

	override function onmouseup( e:MouseEvent ) {
		prevCursorPos = null;
	}

	override function update(dt:Float) {

		if (Luxe.input.mousedown(1)) {

			var prevSize = curTerrain.points.length;

			var screen_point = Luxe.screen.cursor.pos;
			var world_point = Luxe.camera.screen_point_to_world( screen_point );

			//TODO: onmousedown if you're over the edge of the terrain, make sure that the connection you get fills it in with a bunch of points
			if (prevCursorPos == null) prevCursorPos = Luxe.screen.cursor.pos;
			var prev_world_point = Luxe.camera.screen_point_to_world( prevCursorPos );

			//curTerrain.buildTerrain(world_point);
			curTerrain.buildTerrainAlongLine(prev_world_point, world_point);

			if (prevSize != curTerrain.points.length) curTerrain.redraw(new Color(1,1,1));

			prevCursorPos = Luxe.screen.cursor.pos;
		}

	} //update


} //Main
