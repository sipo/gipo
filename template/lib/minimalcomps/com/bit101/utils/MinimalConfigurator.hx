package com.bit101.utils;

extern class MinimalConfigurator extends flash.events.EventDispatcher {
	function new(p1 : flash.display.DisplayObjectContainer) : Void;
	function getCompById(p1 : String) : com.bit101.components.Component;
	function loadXML(p1 : String) : Void;
	function parseXML(p1 : flash.xml.XML) : Void;
	function parseXMLString(p1 : String) : Void;
}
