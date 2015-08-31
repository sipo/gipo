package com.bit101.components;

extern class ListItem extends Component {
	var data : Dynamic;
	var defaultColor : UInt;
	var rolloverColor : UInt;
	var selected : Bool;
	var selectedColor : UInt;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : Dynamic) : Void;
}
