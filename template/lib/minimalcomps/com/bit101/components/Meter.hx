package com.bit101.components;

extern class Meter extends Component {
	var damp : Float;
	var label : String;
	var maximum : Float;
	var minimum : Float;
	var showValues : Bool;
	var value : Float;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String) : Void;
}
