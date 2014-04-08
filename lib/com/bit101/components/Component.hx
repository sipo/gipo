package com.bit101.components;

extern class Component extends flash.display.Sprite {
	var enabled : Bool;
	var tag : Int;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0) : Void;
	function draw() : Void;
	function move(p1 : Float, p2 : Float) : Void;
	function setSize(p1 : Float, p2 : Float) : Void;
	static var DRAW : String;
	static function initStage(p1 : flash.display.Stage) : Void;
}
