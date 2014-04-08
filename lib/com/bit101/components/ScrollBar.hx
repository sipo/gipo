package com.bit101.components;

extern class ScrollBar extends Component {
	var autoHide : Bool;
	var lineSize : Int;
	var maximum : Float;
	var minimum : Float;
	var pageSize : Int;
	var value : Float;
	function new(p1 : String, ?p2 : flash.display.DisplayObjectContainer, p3 : Float = 0, p4 : Float = 0, ?p5 : Dynamic) : Void;
	function setSliderParams(p1 : Float, p2 : Float, p3 : Float) : Void;
	function setThumbPercent(p1 : Float) : Void;
}
