package com.bit101.components;

extern class IndicatorLight extends Component {
	var color : UInt;
	var isFlashing(default,never) : Bool;
	var isLit : Bool;
	var label : String;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, p4 : UInt = 16711680, ?p5 : String) : Void;
	function flash(p1 : Int = 500) : Void;
}
