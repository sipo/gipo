package com.bit101.components;

extern class NumericStepper extends Component {
	var labelPrecision : Int;
	var maximum : Float;
	var minimum : Float;
	var repeatTime : Int;
	var step : Float;
	var value : Float;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : Dynamic) : Void;
}
