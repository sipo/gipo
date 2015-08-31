package com.bit101.components;

extern class Panel extends Component {
	var color : Int;
	var content : flash.display.Sprite;
	var gridColor : UInt;
	var gridSize : Int;
	var shadow : Bool;
	var showGrid : Bool;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0) : Void;
	function addRawChild(p1 : flash.display.DisplayObject) : flash.display.DisplayObject;
}
