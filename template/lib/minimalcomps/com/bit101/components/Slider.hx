package com.bit101.components;

extern class Slider extends Component {
	var backClick : Bool;
	var maximum : Float;
	var minimum : Float;
	var rawValue(default,never) : Float;
	var tick : Float;
	var value : Float;
	function new(?p1 : String, ?p2 : flash.display.DisplayObjectContainer, p3 : Float = 0, p4 : Float = 0, ?p5 : Dynamic) : Void;
	function setSliderParams(p1 : Float, p2 : Float, p3 : Float) : Void;
	static var HORIZONTAL : String;
	static var VERTICAL : String;
}
