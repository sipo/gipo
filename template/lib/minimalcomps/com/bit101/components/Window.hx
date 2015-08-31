package com.bit101.components;

extern class Window extends Component {
	var color : Int;
	var content(default,never) : flash.display.DisplayObjectContainer;
	var draggable : Bool;
	var grips(default,never) : flash.display.Shape;
	var hasCloseButton : Bool;
	var hasMinimizeButton : Bool;
	var minimized : Bool;
	var shadow : Bool;
	var title : String;
	var titleBar : Panel;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String) : Void;
	function addRawChild(p1 : flash.display.DisplayObject) : flash.display.DisplayObject;
}
