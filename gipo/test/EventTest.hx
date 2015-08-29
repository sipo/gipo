package;

import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

using Lambda;

@:access(jp.sipo.gipo.core.Gear)
@:access(jp.sipo.gipo.core.GearHolderImpl)
class EventTest
{
	var top:EventTreeInfo;
	var nodeA:EventTreeInfo;
	var nodeAA:EventTreeInfo;
	var nodeB:EventTreeInfo;
	var nodeBB:EventTreeInfo;

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
		
		top = new EventTreeInfo();
		nodeA = new EventTreeInfo();
		nodeAA = new EventTreeInfo();
		nodeB = new EventTreeInfo();
		nodeBB = new EventTreeInfo();
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
	 * single node (top only)
	 *
	 * event handlers will be called in following order.
	 *  - diffusible
	 *  - run
	 *  - bubble
	 */
	@Test
	public function testEventOrderSingle():Void
	{
		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.areEqual(-1, top.diffusibleTimeCode);
		Assert.areEqual(-1, top.runTimeCode);
		Assert.areEqual(-1, top.bubbleTimeCode);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called in order
		Assert.areEqual(0, top.diffusibleTimeCode);
		Assert.areEqual(1, top.runTimeCode);
		Assert.areEqual(2, top.bubbleTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * event handlers will be called in following order.
	 *  - top's diffusible
	 *  - nodeA's diffusible
	 *  - nodeAA's diffusible
	 *  - nodeAA's run
	 *  - nodeAA's bubble
	 *  - nodeA's run
	 *  - nodeA's bubble
	 *  - top's run
	 *  - top's bubble
	 */
	@Test
	public function testEventOrderStraight():Void
	{
		prepareStraightTree();

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.areEqual(-1, top.diffusibleTimeCode);
		Assert.areEqual(-1, top.runTimeCode);
		Assert.areEqual(-1, top.bubbleTimeCode);
		Assert.areEqual(-1, nodeA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeA.runTimeCode);
		Assert.areEqual(-1, nodeA.bubbleTimeCode);
		Assert.areEqual(-1, nodeAA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeAA.runTimeCode);
		Assert.areEqual(-1, nodeAA.bubbleTimeCode);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called in order
		Assert.areEqual(0, top.diffusibleTimeCode);
		Assert.areEqual(1, nodeA.diffusibleTimeCode);
		Assert.areEqual(2, nodeAA.diffusibleTimeCode);
		Assert.areEqual(3, nodeAA.runTimeCode);
		Assert.areEqual(4, nodeAA.bubbleTimeCode);
		Assert.areEqual(5, nodeA.runTimeCode);
		Assert.areEqual(6, nodeA.bubbleTimeCode);
		Assert.areEqual(7, top.runTimeCode);
		Assert.areEqual(8, top.bubbleTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * event handlers will be called in following order.
	 *  - top's diffusible
	 *  - nodeA's diffusible
	 *  - nodeAA's diffusible
	 *  - nodeAA's run
	 *  - nodeAA's bubble
	 *  - nodeA's run
	 *  - nodeA's bubble
	 *  - nodeB's diffusible
	 *  - nodeBB's diffusible
	 *  - nodeBB's run
	 *  - nodeBB's bubble
	 *  - nodeB's run
	 *  - nodeB's bubble
	 *  - top's run
	 *  - top's bubble
	 */
	@Test
	public function testEventOrderFork1():Void
	{
		prepareForkTree1();

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.areEqual(-1, top.diffusibleTimeCode);
		Assert.areEqual(-1, top.runTimeCode);
		Assert.areEqual(-1, top.bubbleTimeCode);
		Assert.areEqual(-1, nodeA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeA.runTimeCode);
		Assert.areEqual(-1, nodeA.bubbleTimeCode);
		Assert.areEqual(-1, nodeAA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeAA.runTimeCode);
		Assert.areEqual(-1, nodeAA.bubbleTimeCode);
		Assert.areEqual(-1, nodeB.diffusibleTimeCode);
		Assert.areEqual(-1, nodeB.runTimeCode);
		Assert.areEqual(-1, nodeB.bubbleTimeCode);
		Assert.areEqual(-1, nodeBB.diffusibleTimeCode);
		Assert.areEqual(-1, nodeBB.runTimeCode);
		Assert.areEqual(-1, nodeBB.bubbleTimeCode);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called in order
		Assert.areEqual(0, top.diffusibleTimeCode);
		Assert.areEqual(1, nodeA.diffusibleTimeCode);
		Assert.areEqual(2, nodeAA.diffusibleTimeCode);
		Assert.areEqual(3, nodeAA.runTimeCode);
		Assert.areEqual(4, nodeAA.bubbleTimeCode);
		Assert.areEqual(5, nodeA.runTimeCode);
		Assert.areEqual(6, nodeA.bubbleTimeCode);
		Assert.areEqual(7, nodeB.diffusibleTimeCode);
		Assert.areEqual(8, nodeBB.diffusibleTimeCode);
		Assert.areEqual(9, nodeBB.runTimeCode);
		Assert.areEqual(10, nodeBB.bubbleTimeCode);
		Assert.areEqual(11, nodeB.runTimeCode);
		Assert.areEqual(12, nodeB.bubbleTimeCode);
		Assert.areEqual(13, top.runTimeCode);
		Assert.areEqual(14, top.bubbleTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *              `- nodeBB
	 *
	 * event handlers will be called in following order.
	 *  - top's diffusible
	 *  - nodeA's diffusible
	 *  - nodeAA's diffusible
	 *  - nodeAA's run
	 *  - nodeAA's bubble
	 *  - nodeBB's diffusible
	 *  - nodeBB's run
	 *  - nodeBB's bubble
	 *  - nodeA's run
	 *  - nodeA's bubble
	 *  - top's run
	 *  - top's bubble
	 */
	@Test
	public function testEventOrderFork2():Void
	{
		prepareForkTree2();

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.areEqual(-1, top.diffusibleTimeCode);
		Assert.areEqual(-1, top.runTimeCode);
		Assert.areEqual(-1, top.bubbleTimeCode);
		Assert.areEqual(-1, nodeA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeA.runTimeCode);
		Assert.areEqual(-1, nodeA.bubbleTimeCode);
		Assert.areEqual(-1, nodeAA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeAA.runTimeCode);
		Assert.areEqual(-1, nodeAA.bubbleTimeCode);
		Assert.areEqual(-1, nodeBB.diffusibleTimeCode);
		Assert.areEqual(-1, nodeBB.runTimeCode);
		Assert.areEqual(-1, nodeBB.bubbleTimeCode);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called in order
		Assert.areEqual(0, top.diffusibleTimeCode);
		Assert.areEqual(1, nodeA.diffusibleTimeCode);
		Assert.areEqual(2, nodeAA.diffusibleTimeCode);
		Assert.areEqual(3, nodeAA.runTimeCode);
		Assert.areEqual(4, nodeAA.bubbleTimeCode);
		Assert.areEqual(5, nodeBB.diffusibleTimeCode);
		Assert.areEqual(6, nodeBB.runTimeCode);
		Assert.areEqual(7, nodeBB.bubbleTimeCode);
		Assert.areEqual(8, nodeA.runTimeCode);
		Assert.areEqual(9, nodeA.bubbleTimeCode);
		Assert.areEqual(10, top.runTimeCode);
		Assert.areEqual(11, top.bubbleTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *              `- nodeBB (add after initializeTop)
	 *
	 * event handlers will be called in following order when initializeTop.
	 *  - top's diffusible
	 *  - nodeA's diffusible
	 *  - nodeAA's diffusible
	 *  - nodeAA's run
	 *  - nodeAA's bubble
	 *  - nodeA's run
	 *  - nodeA's bubble
	 *  - top's run
	 *  - top's bubble
	 *
	 * event handlers will be called in following order when addChild.
	 *  - nodeBB's diffusible
	 *  - nodeBB's run
	 *  - nodeBB's bubble
	 */
	@Test
	public function testEventOrderWithAddingChildAfterInitialized():Void
	{
		prepareStraightTree();

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.areEqual(-1, top.diffusibleTimeCode);
		Assert.areEqual(-1, top.runTimeCode);
		Assert.areEqual(-1, top.bubbleTimeCode);
		Assert.areEqual(-1, nodeA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeA.runTimeCode);
		Assert.areEqual(-1, nodeA.bubbleTimeCode);
		Assert.areEqual(-1, nodeAA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeAA.runTimeCode);
		Assert.areEqual(-1, nodeAA.bubbleTimeCode);
		Assert.areEqual(-1, nodeBB.diffusibleTimeCode);
		Assert.areEqual(-1, nodeBB.runTimeCode);
		Assert.areEqual(-1, nodeBB.bubbleTimeCode);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called in order before addChild
		Assert.areEqual(0, top.diffusibleTimeCode);
		Assert.areEqual(1, nodeA.diffusibleTimeCode);
		Assert.areEqual(2, nodeAA.diffusibleTimeCode);
		Assert.areEqual(3, nodeAA.runTimeCode);
		Assert.areEqual(4, nodeAA.bubbleTimeCode);
		Assert.areEqual(5, nodeA.runTimeCode);
		Assert.areEqual(6, nodeA.bubbleTimeCode);
		Assert.areEqual(7, top.runTimeCode);
		Assert.areEqual(8, top.bubbleTimeCode);
		Assert.areEqual(-1, nodeBB.diffusibleTimeCode);
		Assert.areEqual(-1, nodeBB.runTimeCode);
		Assert.areEqual(-1, nodeBB.bubbleTimeCode);
		
		// add child
		nodeA.node.gear.addChild(new EventNode(nodeBB));

		// verify: handlers are called in order after addChild
		Assert.areEqual(9, nodeBB.diffusibleTimeCode);
		Assert.areEqual(10, nodeBB.runTimeCode);
		Assert.areEqual(11, nodeBB.bubbleTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *              `- nodeBB (add in nodeA's run handler)
	 *
	 * event handlers will be called in following order.
	 *  - top's diffusible
	 *  - nodeA's diffusible
	 *  - nodeAA's diffusible
	 *  - nodeAA's run
	 *  - nodeAA's bubble
	 *  - nodeA's run
	 *  - nodeBB's diffusible
	 *  - nodeBB's run
	 *  - nodeBB's bubble
	 *  - nodeA's bubble
	 *  - top's run
	 *  - top's bubble
	 */
	@Test
	public function testEventOrderWithAddingChildInRunHandler():Void
	{
		prepareStraightTree();
		
		nodeA.runProc = function() {
			nodeA.node.gear.addChild(new EventNode(nodeBB));
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.areEqual(-1, top.diffusibleTimeCode);
		Assert.areEqual(-1, top.runTimeCode);
		Assert.areEqual(-1, top.bubbleTimeCode);
		Assert.areEqual(-1, nodeA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeA.runTimeCode);
		Assert.areEqual(-1, nodeA.bubbleTimeCode);
		Assert.areEqual(-1, nodeAA.diffusibleTimeCode);
		Assert.areEqual(-1, nodeAA.runTimeCode);
		Assert.areEqual(-1, nodeAA.bubbleTimeCode);
		Assert.areEqual(-1, nodeBB.diffusibleTimeCode);
		Assert.areEqual(-1, nodeBB.runTimeCode);
		Assert.areEqual(-1, nodeBB.bubbleTimeCode);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called in order before addChild
		Assert.areEqual(0, top.diffusibleTimeCode);
		Assert.areEqual(1, nodeA.diffusibleTimeCode);
		Assert.areEqual(2, nodeAA.diffusibleTimeCode);
		Assert.areEqual(3, nodeAA.runTimeCode);
		Assert.areEqual(4, nodeAA.bubbleTimeCode);
		Assert.areEqual(5, nodeA.runTimeCode);
		Assert.areEqual(6, nodeBB.diffusibleTimeCode);
		Assert.areEqual(7, nodeBB.runTimeCode);
		Assert.areEqual(8, nodeBB.bubbleTimeCode);
		Assert.areEqual(9, nodeA.bubbleTimeCode);
		Assert.areEqual(10, top.runTimeCode);
		Assert.areEqual(11, top.bubbleTimeCode);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB (bookChild in top's diffusible handler)
	 *
	 * bookChild can be called from diffusible handler.
	 */
	@Test
	public function testEventDiffusibleCall_bookChild():Void
	{
		prepareStraightTree();

		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.bookChild(new EventNode(nodeB));
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(nodeB.node);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called and API called successfully
		Assert.isNotNull(nodeB.node);
		Assert.isTrue(top.node.gear.childGearList.has(nodeB.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB (addChild in top's run handler)
	 *
	 * addChild can be called from run handler.
	 */
	@Test
	public function testEventRunCall_addChild():Void
	{
		prepareStraightTree();

		top.runProc = function() {
			top.node.gear.addChild(new EventNode(nodeB));
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(nodeB.node);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called and API called successfully
		Assert.isNotNull(nodeB.node);
		Assert.isTrue(top.node.gear.childGearList.has(nodeB.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB (addChild in top's bubble handler)
	 *
	 * addChild can be called from bubble handler.
	 */
	@Test
	public function testEventBubbleCall_addChild():Void
	{
		prepareStraightTree();

		top.bubbleProc = function() {
			top.node.gear.addChild(new EventNode(nodeB));
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(nodeB.node);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called and API called successfully
		Assert.isNotNull(nodeB.node);
		Assert.isTrue(top.node.gear.childGearList.has(nodeB.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB (addChild after initialized)
	 *
	 * addChild can be called after initialized.
	 */
	@Test
	public function testEventMiddleCall_addChild():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// verify: before call
		Assert.isNull(nodeB.node);
		
		// call
		top.node.gear.addChild(new EventNode(nodeB));

		// verify: API called successfully
		Assert.isNotNull(nodeB.node);
		Assert.isTrue(top.node.gear.childGearList.has(nodeB.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (removeChild in nodeA's run handler)
	 *
	 * removeChild can be called from run handler.
	 */
	@Test
	public function testEventRunCall_removeChild():Void
	{
		prepareStraightTree();

		nodeA.runProc = function() {
			nodeA.node.gear.removeChild(nodeAA.node);
		}

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// verify: handler is called and API called successfully
		Assert.isFalse(nodeA.node.gear.childGearList.has(nodeAA.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (removeChild in nodeA's bubble handler)
	 *
	 * removeChild can be called from bubble handler.
	 */
	@Test
	public function testEventBubbleCall_removeChild():Void
	{
		prepareStraightTree();

		nodeA.bubbleProc = function() {
			nodeA.node.gear.removeChild(nodeAA.node);
		}

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// verify: handler is called and API called successfully
		Assert.isFalse(nodeA.node.gear.childGearList.has(nodeAA.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (removeChild after initialized)
	 *
	 * removeChild can be called after initialized.
	 */
	@Test
	public function testEventMiddleCall_removeChild():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// verify: before call
		Assert.isTrue(nodeA.node.gear.childGearList.has(nodeAA.node.gear));

		// call
		nodeA.node.gear.removeChild(nodeAA.node);

		// verify: API called successfully
		Assert.isFalse(nodeA.node.gear.childGearList.has(nodeAA.node.gear));
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuse in top's diffusible handler, absorb in nodeAA's diffusible handler)
	 *
	 * diffuse can be called from diffusible handler.
	 * absorb can be called from diffusible handler.
	 */
	@Test
	public function testEventDiffusibleCall_diffuse_absorb():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuse(data, Array);
		}

		var absorbedData:Array<Int> = null;
		nodeAA.diffusibleProc = function(tool:GearDiffuseTool) {
			absorbedData = nodeAA.node.gear.absorb(Array);
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(absorbedData);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called and API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuse in top's diffusible handler, absorb in nodeAA's run handler)
	 *
	 * absorb can be called from run handler.
	 */
	@Test
	public function testEventRunCalll_absorb():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuse(data, Array);
		}

		var absorbedData:Array<Int> = null;
		nodeAA.runProc = function() {
			absorbedData = nodeAA.node.gear.absorb(Array);
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(absorbedData);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler is called and API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuse in top's diffusible handler, absorb in nodeAA's bubble handler)
	 *
	 * absorb can be called from bubble handler.
	 */
	@Test
	public function testEventBubbleCalll_absorb():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuse(data, Array);
		}

		var absorbedData:Array<Int> = null;
		nodeAA.bubbleProc = function() {
			absorbedData = nodeAA.node.gear.absorb(Array);
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(absorbedData);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler is called and API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuse in top's diffusible handler, absorb by nodeAA after initialized)
	 *
	 * absorb can be called after initialized.
	 */
	@Test
	public function testEventMiddleCalll_absorb():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuse(data, Array);
		}

		var absorbedData:Array<Int> = null;

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// verify: before call
		Assert.isNull(absorbedData);
		
		// call
		absorbedData = nodeAA.node.gear.absorb(Array);

		// verify: API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuseWithKey in top's diffusible handler, absorbWithKey in nodeAA's diffusible handler)
	 *
	 * diffuseWithKey can be called from diffusible handler.
	 * absorbWithKey can be called from diffusible handler.
	 */
	@Test
	public function testEventDiffusibleCall_diffuseWithKey_absorbWithKey():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuseWithKey(data, EventDataKey.Key1);
		}

		var absorbedData:Array<Int> = null;
		nodeAA.diffusibleProc = function(tool:GearDiffuseTool) {
			absorbedData = nodeAA.node.gear.absorbWithKey(EventDataKey.Key1);
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(absorbedData);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handlers are called and API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuseWithKey in top's diffusible handler, absorbWithKey in nodeAA's run handler)
	 *
	 * absorbWithKey can be called from run handler.
	 */
	@Test
	public function testEventRunCalll_absorbWithKey():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuseWithKey(data, EventDataKey.Key1);
		}

		var absorbedData:Array<Int> = null;
		nodeAA.runProc = function() {
			absorbedData = nodeAA.node.gear.absorbWithKey(EventDataKey.Key1);
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(absorbedData);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler is called and API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuseWithKey in top's diffusible handler, absorbWithKey in nodeAA's bubble handler)
	 *
	 * absorbWithKey can be called from bubble handler.
	 */
	@Test
	public function testEventBubbleCalll_absorbWithKey():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuseWithKey(data, EventDataKey.Key1);
		}

		var absorbedData:Array<Int> = null;
		nodeAA.bubbleProc = function() {
			absorbedData = nodeAA.node.gear.absorbWithKey(EventDataKey.Key1);
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handlers does not called yet
		Assert.isNull(absorbedData);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler is called and API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (diffuseWithKey in top's diffusible handler, absorbWithKey by nodeAA after initialized)
	 *
	 * absorbWithKey can be called after initialized.
	 */
	@Test
	public function testEventMiddleCalll_absorbWithKey():Void
	{
		prepareStraightTree();

		var data = [ 1, 2, 3 ];
		top.diffusibleProc = function(tool:GearDiffuseTool) {
			tool.diffuseWithKey(data, EventDataKey.Key1);
		}

		var absorbedData:Array<Int> = null;

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// verify: before call
		Assert.isNull(absorbedData);

		// call
		absorbedData = nodeAA.node.gear.absorbWithKey(EventDataKey.Key1);

		// verify: API called successfully
		Assert.isNotNull(absorbedData);
		Assert.areEqual(data, absorbedData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (disposeTask in nodeA's constructor)
	 *
	 * disposeTask can be called from constructor.
	 */
	@Test
	public function testEventConstructorCall_disposeTask():Void
	{
		prepareStraightTree();
		
		var isCalled = false;
		nodeA.constructorProc = function() {
			nodeA.node.gear.disposeTask(function() { isCalled = true; });
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);
		
		// remove
		top.node.gear.removeChild(nodeA.node);

		// verify: handler is called
		Assert.isTrue(isCalled);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (disposeTask in nodeA's diffusible handler)
	 *
	 * disposeTask can be called from diffusible handler.
	 */
	@Test
	public function testEventDiffusibleCall_disposeTask():Void
	{
		prepareStraightTree();

		var isCalled = false;
		nodeA.diffusibleProc = function(tool:GearDiffuseTool) {
			nodeA.node.gear.disposeTask(function() { isCalled = true; });
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// remove
		top.node.gear.removeChild(nodeA.node);

		// verify: handler is called
		Assert.isTrue(isCalled);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (disposeTask in nodeA's run handler)
	 *
	 * disposeTask can be called from run handler.
	 */
	@Test
	public function testEventRunCall_disposeTask():Void
	{
		prepareStraightTree();

		var isCalled = false;
		nodeA.runProc = function() {
			nodeA.node.gear.disposeTask(function() { isCalled = true; });
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// remove
		top.node.gear.removeChild(nodeA.node);

		// verify: handler is called
		Assert.isTrue(isCalled);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (disposeTask in nodeA's bubble handler)
	 *
	 * disposeTask can be called from bubble handler.
	 */
	@Test
	public function testEventBubbleCall_disposeTask():Void
	{
		prepareStraightTree();

		var isCalled = false;
		nodeA.bubbleProc = function() {
			nodeA.node.gear.disposeTask(function() { isCalled = true; });
		}

		// constructor
		var topGear = new EventNode(top);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// build gear tree
		topGear.gearOutside().initializeTop(null);

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// remove
		top.node.gear.removeChild(nodeA.node);

		// verify: handler is called
		Assert.isTrue(isCalled);
	}

	/*
	 * top -- nodeA -- nodeAA
	 * (disposeTask after initialized)
	 *
	 * disposeTask can be called after initialized.
	 */
	@Test
	public function testEventMiddleCall_disposeTask():Void
	{
		prepareStraightTree();

		// build gear tree
		var topGear = new EventNode(top);
		topGear.gearOutside().initializeTop(null);

		// call
		var isCalled = false;
		nodeA.node.gear.disposeTask(function() { isCalled = true; });

		// verify: handler does not called yet
		Assert.isFalse(isCalled);

		// remove
		top.node.gear.removeChild(nodeA.node);

		// verify: handler is called
		Assert.isTrue(isCalled);
	}
}

class EventNode extends GearHolderImpl
{
	var info:EventTreeInfo;

	public function new(info:EventTreeInfo)
	{
		super();
		this.info = info;
		info.node = this;
		
		if(info.constructorProc != null) {
			info.constructorProc();
		}
	}

	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearDiffuseTool):Void
	{
		info.diffusibleTimeCode = EventTest.currentTimeCode();
		if(info.diffusibleProc != null) {
			info.diffusibleProc(tool);
		}

		for(child in info.children) {
			tool.bookChild(new EventNode(child));
		}
	}

	@:handler(GearDispatcherKind.Run)
	function run():Void
	{
		info.runTimeCode = EventTest.currentTimeCode();
		if(info.runProc != null) {
			info.runProc();
		}
	}

	@:handler(GearDispatcherKind.Bubble)
	function bubble():Void
	{
		info.bubbleTimeCode = EventTest.currentTimeCode();
		if(info.bubbleProc != null) {
			info.bubbleProc();
		}
	}
}

class EventTreeInfo
{
	public var children:Array<EventTreeInfo>;

	public var constructorProc:Void->Void = null;
	public var diffusibleProc:GearDiffuseTool->Void = null;
	public var runProc:Void->Void = null;
	public var bubbleProc:Void->Void = null;

	public var node:GearHolderImpl;
	
	public var diffusibleTimeCode:Int = -1;
	public var runTimeCode:Int = -1;
	public var bubbleTimeCode:Int = -1;

	public function new()
	{
		children = [];
	}
}

enum EventDataKey
{
	Key1;
	Key2;
}