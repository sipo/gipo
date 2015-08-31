package com.bit101.components;

extern class Accordion extends Component {
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0) : Void;
	function addWindow(p1 : String) : Void;
	function addWindowAt(p1 : String, p2 : Int) : Void;
	function getWindowAt(p1 : Int) : Window;
}
