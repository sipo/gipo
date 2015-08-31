package com.bit101.components;

extern class Text extends Component {
	var editable : Bool;
	var html : Bool;
	var selectable : Bool;
	var text : String;
	var textField(default,never) : flash.text.TextField;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : String) : Void;
}
