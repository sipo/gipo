package ;

import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;

import massive.munit.Assert;

class AutoAbsorbTest
{
	public function new() { }
	
	@Test("ChildGearで@:absorbを指定したSomethingは自動的にabsorbされる")
	private function childGearAbsorbSomething():Void 
	{
		var top:Top = new Top();
		top.gearOutside().initializeTop(null);
		
		var child:Child = top.child;
		
		Assert.isNotNull(child.something);
		Assert.areEqual(child.something.name, "John Doe");
	}
	
}

// //////////////////////////////////////////////////////////////////

/* Diffused Something */
private class Something {
	public var name:String;
	public function new(name:String) {
		this.name = name;
	}
}

/* TopGear */
private class Top extends GearHolderImpl 
{
	public var something:Something;
	public var child:Child;
	
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void 
	{
		this.something = new Something("John Doe");
		tool.diffuse(something, Something);
		
		this.child = new Child();
		tool.bookChild(child);
	}
}

/* ChildGear */
private class Child extends GearHolderImpl 
{
	@:absorb
	public var something:Something;
	
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void 
	{
		
	}
}
