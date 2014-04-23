package ;

import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;

class AutoAbsorbExample {

	public static function main() {
		new AutoAbsorbExample();
	}
	
	public function new() {
		var top = new Top();
		top.gearOutside().initializeTop(null);
	}
	
}

private class Top extends GearHolderImpl {
	
	public function new() {
		super();
		gear.addDiffusibleHandler(diffusible);
	}
	
	private function diffusible(tool:GearDiffuseTool):Void {
		tool.diffuseWithKey("FOO", Key.Foo);
		tool.diffuse(new ImportantClass("HELLO"), ImportantClass);
		tool.bookChild(new ChildExample());
	}
	
}

private enum Key {
	Foo;
}

private class ImportantClass {
	public function new(name:String) {
		this.name = name;
	}
	public var name(default, null):String;
}

private class ChildExample extends GearHolderImpl implements AutoAbsorber {
	
	@:absorbKey(Key.Foo)
	private var foo:String;
	
	@:absorb
	private var importInstance:ImportantClass;
	
	public function new() {
		super();
		trace(haxe.rtti.Meta.getFields(ChildExample));
		/* gear.addRunHandler(run); */
		/* Timer.delay(function () { trace(importInstance.name); }, 1000); */
	}
	
	private function run():Void {
		/*
		trace(this.foo);
		trace(importInstance.name);
		*/
	}
}
