package ;

import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

@:access(jp.sipo.gipo.core.Gear)
@:access(jp.sipo.gipo.core.GearHolderImpl)
class AutoAbsorbTest
{
	public function new() { }
	
	@Test("ChildGearで@:absorbを指定したSomethingは自動的にabsorbされる")
	private function childGearAbsorbSomething():Void 
	{
		var parent = new Parent();
		var child = new Child();
		
		parent.gear.diffusibleHandlerList.add(function (tool:GearDiffuseTool):Void
		{
			parent.something = new Something("John Doe");
			tool.diffuse(parent.something, Something);
			tool.bookChild(child);
		});
		
		child.gear.runHandlerList.add(function ():Void 
		{
			Assert.isNotNull(child.something);
			Assert.areEqual(child.something.name, "John Doe");
		});
		
		parent.gearOutside().initializeTop(null);
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

/* ParentGear */
private class Parent extends GearHolderImpl 
{
	public var something:Something;
	public function new() { super(); }
}

/* ChildGear */
private class Child extends GearHolderImpl 
{
	@:absorb
	public var something:Something;
	public function new() { super(); }
}
