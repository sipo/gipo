package com.bit101.components;

extern class List extends Component {
	var alternateColor : UInt;
	var alternateRows : Bool;
	var autoHideScrollBar : Bool;
	var defaultColor : UInt;
	var items : Array<Dynamic>;
	var listItemClass : Class<Dynamic>;
	var listItemHeight : Float;
	var rolloverColor : UInt;
	var selectedColor : UInt;
	var selectedIndex : Int;
	var selectedItem : Dynamic;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0, ?p4 : Array<Dynamic>) : Void;
	function addItem(p1 : flash.utils.Object) : Void;
	function addItemAt(p1 : flash.utils.Object, p2 : Int) : Void;
	function removeAll() : Void;
	function removeItem(p1 : flash.utils.Object) : Void;
	function removeItemAt(p1 : Int) : Void;
}
