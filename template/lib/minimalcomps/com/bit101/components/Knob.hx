package com.bit101.components;

extern class Knob extends Component {
	var label : String;
	var labelPrecision : Int;
	var maximum : Float;
	var minimum : Float;
	var mode : String;
	var mouseRange : Float;
	var radius : Float;
	var showValue : Bool;
	var value : Float;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String, ?p5 : Dynamic) : Void;
	static var HORIZONTAL : String;
	static var ROTATE : String;
	static var VERTICAL : String;
}
