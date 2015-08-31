package com.bit101.components;

extern class WheelMenu extends Component {
	var borderColor : UInt;
	var color : UInt;
	var highlightColor : UInt;
	var selectedIndex(default,never) : Int;
	var selectedItem(default,never) : Dynamic;
	function new(p1 : flash.display.DisplayObjectContainer, p2 : Int, p3 : Float = 80, p4 : Float = 60, p5 : Float = 10, ?p6 : Dynamic) : Void;
	function hide() : Void;
	function setItem(p1 : Int, p2 : flash.utils.Object, ?p3 : flash.utils.Object) : Void;
	function show() : Void;
}
