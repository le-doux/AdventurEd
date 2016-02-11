import luxe.Input;
import luxe.Color;
import luxe.Vector;

import sys.io.File;
import sys.io.FileOutput;
import sys.io.FileInput;

import haxe.Json;

class Main extends luxe.Game {

	var curTerrain : Terrain;
	var zoomIncrement = 0.2;
	var panIncrement = 20;

	override function ready() {
		/*
		var t : Terrain = new Terrain({
				x : 30,
				y : 100,
				segmentLen : 50,
				heights : [0, -10, 20, 50, 5, 30, 15, 20]
			});

		t.draw(new Color(1,0,1));
		*/

		//Luxe.renderer.clear_color = new Color(0,1,1);

		//trace(Luxe.camera.size.w);
		/*
		trace(Luxe.screen.width);
		trace(Luxe.core.app.window.width);
		Luxe.core.app.window.fullscreen = true;
		trace("---");
		//trace(Luxe.camera.size.w);
		trace(Luxe.screen.width);
		trace(Luxe.core.app.window.width);
		*/

		curTerrain = new Terrain({
				x : 30,
				y : Luxe.screen.height - 30,
				segmentLen : 20,
				heights : [0, -10, 20, 50, 5, 30, 15, 20]
			});
		curTerrain.draw(new Color(1,1,1));

	} //ready

	override function onkeydown( e:KeyEvent ) {

		//open file
		if (e.keycode == Key.key_o && e.mod.meta ) {
			var path = Luxe.core.app.io.module.dialog_open();
			var fileStr = File.getContent(path);
			var json = Json.parse(fileStr);

			if (curTerrain != null) curTerrain.clear();
			curTerrain = new Terrain(json);
			curTerrain.draw(new Color(1,0,1));
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
		var terrain_point = curTerrain.worldPosToTerrainPos( world_point );
		trace( terrain_point );
		if (terrain_point.x > 0 && terrain_point.x < curTerrain.length) {
			//TODO
			curTerrain.data.heights[ curTerrain.closestIndexToTerrainPos(terrain_point.x) ] = terrain_point.y;
			//TODO
			curTerrain.redraw(new Color(1,1,1));
		}
	}

	override function update(dt:Float) {

		

	} //update


} //Main
