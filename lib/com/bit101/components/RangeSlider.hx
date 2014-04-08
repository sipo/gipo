package com.bit101.components;

extern class RangeSlider extends Component {
	var highValue : Float;
	var labelMode : String;
	var labelPosition : String;
	var labelPrecision : Int;
	var lowValue : Float;
	var maximum : Float;
	var minimum : Float;
	var tick : Float;
	function new(p1 : String, ?p2 : flash.display.DisplayObjectContainer, p3 : Float = 0, p4 : Float = 0, ?p5 : Dynamic) : Void;
	static var ALWAYS : String;
	static var BOTTOM : String;
	static var HORIZONTAL : String;
	static var LEFT : String;
	static var MOVE : String;
	static var NEVER : String;
	static var RIGHT : String;
	static var TOP : String;
	static var VERTICAL : String;
}
