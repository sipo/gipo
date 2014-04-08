package com.bit101.components;

extern class UISlider extends Component {
	var label : String;
	var labelPrecision : Int;
	var maximum : Float;
	var minimum : Float;
	var tick : Float;
	var value : Float;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String, ?p5 : Dynamic) : Void;
	function setSliderParams(p1 : Float, p2 : Float, p3 : Float) : Void;
}
