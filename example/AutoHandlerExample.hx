package ;

import jp.sipo.gipo.core.AutoHandler;

class AutoHandlerExample {

	public static function main() {
		new AutoHandlerExample();
	}
	
	public function new() {
		new Top();
	}
	
}

private class Top implements AutoHandler {
	
	public function new() {
		
	}
	
	@:handler(MyHandler.Baz)
	private function handlerTest():Void {
	}
	
	@:redTapeHandler(MyHandler.Bar)
	private function redTapeTest(myFoo:MyInput):Void {
	}
	
}

enum MyHandler {
	Foo;
	Bar;
	Baz;
}

private enum MyInput {
	Xyz;
}

