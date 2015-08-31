package com.bit101.components;

extern class RotarySelector extends Component {
	var choice : UInt;
	var labelMode : String;
	var numChoices : UInt;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String, ?p5 : Dynamic) : Void;
	static var ALPHABETIC : String;
	static var NONE : String;
	static var NUMERIC : String;
	static var ROMAN : String;
}
