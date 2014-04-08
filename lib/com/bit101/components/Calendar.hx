package com.bit101.components;

extern class Calendar extends Panel {
	var day(default,never) : Int;
	var month(default,never) : Int;
	var selectedDate(default,never) : Date;
	var year(default,never) : Int;
	function new(?p1 : flash.display.DisplayObjectContainer, p2 : Float = 0, p3 : Float = 0) : Void;
	function setDate(p1 : Date) : Void;
	function setYearMonthDay(p1 : Int, p2 : Int, p3 : Int) : Void;
}
