package com.bit101.charts;

extern class Chart extends com.bit101.components.Component {
	var autoScale : Bool;
	var data : Array<Dynamic>;
	var gridColor : UInt;
	var gridSize : Int;
	var labelPrecision : Int;
	var maximum : Float;
	var minimum : Float;
	var showGrid : Bool;
	var showScaleLabels : Bool;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : Array<Dynamic>) : Void;
}
