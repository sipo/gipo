package ;

import haxe.rtti.Meta;
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
		tool.diffuseWithKey("BAR", Key.Bar);
		tool.diffuse(new ImportantClass("HELLO"), ImportantClass);
		tool.bookChild(new ChildExample());
		tool.bookChild(new ChildExample2());
	}
	
}

private enum Key {
	Foo;
	Bar;
}

private class ImportantClass {
	public function new(name:String) {
		this.name = name;
	}
	public var name(default, null):String;
}

private class ChildExample extends GearHolderImpl {
	
	@:absorbKey(Key.Foo)
	private var foo:String;
	
	@:absorb
	private var importInstance:ImportantClass;
	
	public function new() {
		super();
		// この段階ではabsorb変数は使用できない
		gear.addRunHandler(run);
	}
	
	private function run():Void 
	{
		// 親にaddChildされた後、diffusibleもしくはrun関数以降で使用可能
		trace(this.foo);
		trace(this.importInstance);
	}
}

private class ChildExample2 extends ChildExample 
{
	@:absorbKey(Key.Bar)
	private var bar:String;
	
	@:absorb
	private var importInstance2:ImportantClass;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run2);
	}
	
	private function run2():Void 
	{
		trace(this.foo);
		trace(this.importInstance);
		trace(this.bar);
		trace(this.importInstance2);
	}
}
