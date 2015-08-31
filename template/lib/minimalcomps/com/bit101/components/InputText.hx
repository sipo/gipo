package com.bit101.components;

extern class InputText extends Component {
	var maxChars : Int;
	var password : Bool;
	var restrict : String;
	var text : String;
	var textField(default,never) : flash.text.TextField;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String, ?p5 : Dynamic) : Void;
}
