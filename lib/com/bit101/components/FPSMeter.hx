package com.bit101.components;

extern class FPSMeter extends Component {
	var fps(default,never) : Int;
	var prefix : String;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String) : Void;
	function start() : Void;
	function stop() : Void;
}
