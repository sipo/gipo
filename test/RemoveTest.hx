package;

import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

using Lambda;

@:access(jp.sipo.gipo.core.Gear)
@:access(jp.sipo.gipo.core.GearHolderImpl)
class RemoveTest
{
	var top:RemoveTreeInfo;
	var nodeA:RemoveTreeInfo;
	var nodeAA:RemoveTreeInfo;
	var nodeB:RemoveTreeInfo;
	var nodeBB:RemoveTreeInfo;

	public function new()
	{
	}

	static var timeCode:Int;
	public static function currentTimeCode():Int
	{
		return timeCode++;
	}

	@Before
	public function setup():Void
	{
		timeCode = 0;
		
		top = new RemoveTreeInfo();
		nodeA = new RemoveTreeInfo();
		nodeAA = new RemoveTreeInfo();
		nodeB = new RemoveTreeInfo();
		nodeBB = new RemoveTreeInfo();
	}
	
	@After
	public function tearDown():Void
	{
	}

	/*
	 * top -- nodeA -- nodeAA
	 */
	function prepareStraightTree():Void
	{
		top.children.push(nodeA);
		nodeA.children.push(nodeAA);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 */
	function prepareForkTree1():Void
	{
		top.children.push(nodeA);
		nodeA.children.push(nodeAA);
		
		top.children.push(nodeB);
		nodeB.children.push(nodeBB);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *              `- nodeBB
	 */
	function prepareForkTree2():Void
	{
		top.children.push(nodeA);
		nodeA.children.push(nodeAA);
		nodeA.children.push(nodeBB);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * nodeAA will be removed.
	 */
	@Test
	public function testRemoveSingleNode():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);
		
		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		
		// remove node
		nodeA.self.gear.removeChild(nodeAA.self);

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isFalse(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);

		// verify: detached from tree
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * nodeA will be removed.
	 */
	@Test
	public function testRemoveWithGrandchild():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));

		// remove node
		top.self.gear.removeChild(nodeA.self);

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
		Assert.areEqual(1, nodeA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top will be removed.
	 */
	@Test
	public function testRemoveTop():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));

		// remove node
		topGear.gearOutside().disposeTop();

		// verify: removed or not
		Assert.isTrue(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
		Assert.areEqual(1, nodeA.removedTimeCode);
		Assert.areEqual(2, top.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * nodeAA will be removed.
	 */
	@Test
	public function testRemoveForkSingleNode():Void
	{
		prepareForkTree1();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));

		// remove node
		nodeA.self.gear.removeChild(nodeAA.self);

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isFalse(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isFalse(nodeB.isRemoved);
		Assert.isFalse(nodeBB.isRemoved);
		
		// verify: detached from tree
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));
		
		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * nodeA will be removed.
	 */
	@Test
	public function testRemoveForkWithGrandchild():Void
	{
		prepareForkTree1();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));

		// remove node
		top.self.gear.removeChild(nodeA.self);

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isFalse(nodeB.isRemoved);
		Assert.isFalse(nodeBB.isRemoved);

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
		Assert.areEqual(1, nodeA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * top will be removed.
	 */
	@Test
	public function testRemoveForkTop():Void
	{
		prepareForkTree1();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));

		// remove node
		topGear.gearOutside().disposeTop();

		// verify: removed or not
		Assert.isTrue(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isTrue(nodeB.isRemoved);
		Assert.isTrue(nodeBB.isRemoved);

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isFalse(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isFalse(nodeB.self.gear.childGearList.has(nodeBB.self.gear));

		// verify: removed in order
		Assert.areEqual(0, nodeBB.removedTimeCode);
		Assert.areEqual(1, nodeB.removedTimeCode);
		Assert.areEqual(2, nodeAA.removedTimeCode);
		Assert.areEqual(3, nodeA.removedTimeCode);
		Assert.areEqual(4, top.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *              `- nodeBB
	 *
	 * nodeA will be removed.
	 */
	@Test
	public function testRemoveForkMiddle():Void
	{
		prepareForkTree2();

		// build gear tree
		var topGear = new RemoveNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeBB.self.gear));

		// remove node
		top.self.gear.removeChild(nodeA.self);

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isTrue(nodeBB.isRemoved);

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeBB.self.gear));

		// verify: removed in order
		Assert.areEqual(0, nodeBB.removedTimeCode);
		Assert.areEqual(1, nodeAA.removedTimeCode);
		Assert.areEqual(2, nodeA.removedTimeCode);
	}
}

class RemoveNode extends GearHolderImpl
{
	var info:RemoveTreeInfo;

	public function new(info:RemoveTreeInfo)
	{
		super();
		this.info = info;
		info.self = this;
		gear.disposeTask(function() {
			info.removedTimeCode = RemoveTest.currentTimeCode();
			info.isRemoved = true;
		});
	}

	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearDiffuseTool):Void
	{
		for(child in info.children) {
			tool.bookChild(new RemoveNode(child));
		}
	}
}

class RemoveTreeInfo
{
	public var children:Array<RemoveTreeInfo>;

	public var self:RemoveNode;
	public var isRemoved:Bool = false;
	public var removedTimeCode:Int = -1;

	public function new()
	{
		children = [];
	}
}
