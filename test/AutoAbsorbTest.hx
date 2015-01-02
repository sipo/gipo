package ;

import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

@:access(jp.sipo.gipo.core.Gear)
@:access(jp.sipo.gipo.core.GearHolderImpl)
class AutoAbsorbTest
{
	public function new() { }
	
	@Test("Childで@:absorbを指定したSomethingはdiffusibleのタイミングで自動的にabsorbされている")
	private function childGearAbsorbSomething():Void 
	{
		var parent = new Parent();
		var child = new Child();
		
		parent.gear.diffusibleHandlerList.add(function (tool:GearDiffuseTool):Void
		{
			// parentでSomethingを拡散
			tool.diffuse(new Something("John Doe"), Something);
			// parentの子にChildを登録
			tool.bookChild(child);
		});
		
		child.gear.diffusibleHandlerList.add(function (tool:GearDiffuseTool):Void 
		{
			// @:absorbを指定したSomethingは、diffusible内で使用することができる
			// （これ以前に自動的にabsorbが行われている）
			Assert.isNotNull(child.something);
			// 名前はparentで拡散したものと一致する
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
	public function new() { super(); }
}

/* ChildGear */
private class Child extends GearHolderImpl 
{
	@:absorb
	public var something:Something;
	public function new() { super(); }
}
