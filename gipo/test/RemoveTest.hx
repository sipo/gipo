package;

import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.GearPreparationTool;
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
	function doRemoveSingleNode():Void
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
	}

	@Test
	public function testRemoveSingleNode_disposeTask():Void
	{
		doRemoveSingleNode();

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isFalse(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
	}

	@Test
	public function testRemoveSingleNode_detach():Void
	{
		doRemoveSingleNode();

		// verify: detached from tree
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
	}

	@Test
	public function testRemoveSingleNode_removingOrder():Void
	{
		doRemoveSingleNode();

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * nodeA will be removed.
	 */
	function doRemoveWithGrandchild():Void
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
	}

	@Test
	public function testRemoveWithGrandchild_disposeTask():Void
	{
		doRemoveWithGrandchild();

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
	}

	@Test
	public function testRemoveWithGrandchild_detach():Void
	{
		doRemoveWithGrandchild();

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
	}

	@Test
	public function testRemoveWithGrandchild_removingOrder():Void
	{
		doRemoveWithGrandchild();

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
		Assert.areEqual(1, nodeA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top will be removed.
	 */
	function doRemoveTop():Void
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
	}

	@Test
	public function testRemoveTop_disposeTask():Void
	{
		doRemoveTop();

		// verify: removed or not
		Assert.isTrue(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
	}

	@Test
	public function testRemoveTop_detach():Void
	{
		doRemoveTop();

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
	}

	@Test
	public function testRemoveTop_removingOrder():Void
	{
		doRemoveTop();

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
	function doRemoveForkSingleNode():Void
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
	}

	@Test
	public function testRemoveForkSingleNode_disposeTask():Void
	{
		doRemoveForkSingleNode();

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isFalse(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isFalse(nodeB.isRemoved);
		Assert.isFalse(nodeBB.isRemoved);
	}

	@Test
	public function testRemoveForkSingleNode_detach():Void
	{
		doRemoveForkSingleNode();

		// verify: detached from tree
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));
	}

	@Test
	public function testRemoveForkSingleNode_removingOrder():Void
	{
		doRemoveForkSingleNode();

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * nodeA will be removed.
	 */
	function doRemoveForkWithGrandchild():Void
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
	}

	@Test
	public function testRemoveForkWithGrandchild_disposeTask():Void
	{
		doRemoveForkWithGrandchild();

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isFalse(nodeB.isRemoved);
		Assert.isFalse(nodeBB.isRemoved);
	}

	@Test
	public function testRemoveForkWithGrandchild_detach():Void
	{
		doRemoveForkWithGrandchild();

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isTrue(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isTrue(nodeB.self.gear.childGearList.has(nodeBB.self.gear));
	}

	@Test
	public function testRemoveForkWithGrandchild_removingOrder():Void
	{
		doRemoveForkWithGrandchild();

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
	function doRemoveForkTop():Void
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
	}

	@Test
	public function testRemoveForkTop_disposeTask():Void
	{
		doRemoveForkTop();

		// verify: removed or not
		Assert.isTrue(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isTrue(nodeB.isRemoved);
		Assert.isTrue(nodeBB.isRemoved);
	}

	@Test
	public function testRemoveForkTop_detach():Void
	{
		doRemoveForkTop();

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isFalse(top.self.gear.childGearList.has(nodeB.self.gear));
		Assert.isFalse(nodeB.self.gear.childGearList.has(nodeBB.self.gear));
	}

	@Test
	public function testRemoveForkTop_removingOrder():Void
	{
		doRemoveForkTop();

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
	function doRemoveForkMiddle():Void
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
	}

	@Test
	public function testRemoveForkMiddle_disposeTask():Void
	{
		doRemoveForkMiddle();

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isTrue(nodeBB.isRemoved);
	}

	@Test
	public function testRemoveForkMiddle_detach():Void
	{
		doRemoveForkMiddle();

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeBB.self.gear));
	}

	@Test
	public function testRemoveForkMiddle_removingOrder():Void
	{
		doRemoveForkMiddle();

		// verify: removed in order
		Assert.areEqual(0, nodeBB.removedTimeCode);
		Assert.areEqual(1, nodeAA.removedTimeCode);
		Assert.areEqual(2, nodeA.removedTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * nodeA will be removed.
	 * Each nodes has multiple disposeTasks.
	 */
	function doRemoveDisposeTaskTwice():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new DisposeTaskTwiceNode(top);
		topGear.gearOutside().initializeTop(null);

		// check before removing
		Assert.isTrue(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isTrue(nodeA.self.gear.childGearList.has(nodeAA.self.gear));

		// remove node
		top.self.gear.removeChild(nodeA.self);
	}

	@Test
	public function testRemoveDisposeTaskTwice_disposeTask():Void
	{
		doRemoveDisposeTaskTwice();

		// verify: removed or not
		Assert.isFalse(top.isRemoved);
		Assert.isFalse(top.isRemoved2nd);
		Assert.isTrue(nodeA.isRemoved);
		Assert.isTrue(nodeA.isRemoved2nd);
		Assert.isTrue(nodeAA.isRemoved);
		Assert.isTrue(nodeAA.isRemoved2nd);
	}

	@Test
	public function testRemoveDisposeTaskTwice_detach():Void
	{
		doRemoveDisposeTaskTwice();

		// verify: detached from tree
		Assert.isFalse(top.self.gear.childGearList.has(nodeA.self.gear));
		Assert.isFalse(nodeA.self.gear.childGearList.has(nodeAA.self.gear));
	}

	@Test
	public function testRemoveDisposeTaskTwice_removingOrder():Void
	{
		doRemoveDisposeTaskTwice();

		// verify: removed in order
		Assert.areEqual(0, nodeAA.removedTimeCode2nd);
		Assert.areEqual(1, nodeAA.removedTimeCode);
		Assert.areEqual(2, nodeA.removedTimeCode2nd);
		Assert.areEqual(3, nodeA.removedTimeCode);
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
	function diffusible(tool:GearPreparationTool):Void
	{
		for(child in info.children) {
			tool.bookChild(new RemoveNode(child));
		}
	}
}

class DisposeTaskTwiceNode extends GearHolderImpl
{
	var info:RemoveTreeInfo;

	public function new(info:RemoveTreeInfo)
	{
		super();
		this.info = info;
		info.self = this;
		gear.disposeTask(function() { // first disposeTask
			info.removedTimeCode = RemoveTest.currentTimeCode();
			info.isRemoved = true;
		});
		gear.disposeTask(function() { // second disposeTask
			info.removedTimeCode2nd = RemoveTest.currentTimeCode();
			info.isRemoved2nd = true;
		});
	}

	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearPreparationTool):Void
	{
		for(child in info.children) {
			tool.bookChild(new DisposeTaskTwiceNode(child));
		}
	}
}

class RemoveTreeInfo
{
	public var children:Array<RemoveTreeInfo>;

	public var self:GearHolderImpl;
	public var isRemoved:Bool = false;
	public var isRemoved2nd:Bool = false;
	public var removedTimeCode:Int = -1;
	public var removedTimeCode2nd:Int = -1;

	public function new()
	{
		children = [];
	}
}
