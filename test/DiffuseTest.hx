package;

import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

class DiffuseTest
{
	public function new()
	{
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top diffuses Data.
	 */
	@Test
	public function testDiffuseStraight():Void
	{
		var data = new Data();
		
		var top = new TreeInfo();
		top.diffuseData = data;
		
		var nodeA = new TreeInfo();
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);
		
		// build gear tree
		var top = new Top(top);
		top.gearOutside().initializeTop(null);
		
		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * top diffuses Data.
	 */
	@Test
	public function testDiffuseFork():Void
	{
		var data = new Data();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new TreeInfo();
		top.children.push(nodeB);

		var nodeBB = new TreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var top = new Top(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
		Assert.areEqual(data, nodeB.autoData);
		Assert.areEqual(data, nodeB.manualData);
		Assert.areEqual(data, nodeBB.autoData);
		Assert.areEqual(data, nodeBB.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * top diffuses Data.
	 * nodeA diffuses another Data.
	 */
	@Test
	public function testDiffusePartial():Void
	{
		var data = new Data();
		var dataA = new Data();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		nodeA.diffuseData = dataA;
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new TreeInfo();
		top.children.push(nodeB);

		var nodeBB = new TreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var top = new Top(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData); // absorbed before diffuse dataA
		Assert.areEqual(dataA, nodeA.manualData); // absorbed after diffuse dataA
		Assert.areEqual(dataA, nodeAA.autoData);
		Assert.areEqual(dataA, nodeAA.manualData);
		Assert.areEqual(data, nodeB.autoData);
		Assert.areEqual(data, nodeB.manualData);
		Assert.areEqual(data, nodeBB.autoData);
		Assert.areEqual(data, nodeBB.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top diffuses DataSub.
	 */
	@Test
	public function testDiffuseSubclass():Void
	{
		var data = new DataSub();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		// build gear tree
		var top = new Top(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top diffuses Data with key.
	 */
	@Test
	public function testDiffuseStraightWithKey():Void
	{
		var data = new Data();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		// build gear tree
		var top = new TopWithKey(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * top diffuses Data with key.
	 */
	@Test
	public function testDiffuseForkWithKey():Void
	{
		var data = new Data();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new TreeInfo();
		top.children.push(nodeB);

		var nodeBB = new TreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var top = new TopWithKey(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
		Assert.areEqual(data, nodeB.autoData);
		Assert.areEqual(data, nodeB.manualData);
		Assert.areEqual(data, nodeBB.autoData);
		Assert.areEqual(data, nodeBB.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *     `- nodeB -- nodeBB
	 *
	 * top diffuses Data.
	 * nodeA diffuses another Data with key.
	 */
	@Test
	public function testDiffusePartialWithKey():Void
	{
		var data = new Data();
		var dataA = new Data();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		nodeA.diffuseData = dataA;
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new TreeInfo();
		top.children.push(nodeB);

		var nodeBB = new TreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var top = new TopWithKey(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData); // absorbed before diffuse dataA
		Assert.areEqual(dataA, nodeA.manualData); // absorbed after diffuse dataA
		Assert.areEqual(dataA, nodeAA.autoData);
		Assert.areEqual(dataA, nodeAA.manualData);
		Assert.areEqual(data, nodeB.autoData);
		Assert.areEqual(data, nodeB.manualData);
		Assert.areEqual(data, nodeBB.autoData);
		Assert.areEqual(data, nodeBB.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top diffuses DataSub with key.
	 */
	@Test
	public function testDiffuseSubclassWithKey():Void
	{
		var data = new DataSub();

		var top = new TreeInfo();
		top.diffuseData = data;

		var nodeA = new TreeInfo();
		top.children.push(nodeA);

		var nodeAA = new TreeInfo();
		nodeA.children.push(nodeAA);

		// build gear tree
		var top = new TopWithKey(top);
		top.gearOutside().initializeTop(null);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
	}
}

class Top extends GearHolderImpl
{
	var info:TreeInfo;

	public function new(info:TreeInfo)
	{
		super();
		this.info = info;
	}

	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearDiffuseTool):Void
	{
		if(info.diffuseData != null) {
			tool.diffuse(info.diffuseData, Data);
		}

		for(child in info.children) {
			tool.bookChild(new Node(child));
		}
	}
}

class Node extends Top
{
	@:absorb
	public var autoData:Data;
	
	public function new(info:TreeInfo)
	{
		super(info);
	}

	@:handler(GearDispatcherKind.Run)
	function run():Void
	{
		info.autoData = autoData;
		info.manualData = gear.absorb(Data);
	}
}

class TopWithKey extends GearHolderImpl
{
	var info:TreeInfo;

	public function new(info:TreeInfo)
	{
		super();
		this.info = info;
	}

	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearDiffuseTool):Void
	{
		if(info.diffuseData != null) {
			tool.diffuseWithKey(info.diffuseData, DataKey.Key1);
		}

		for(child in info.children) {
			tool.bookChild(new NodeWithKey(child));
		}
	}
}

class NodeWithKey extends TopWithKey
{
	@:absorbWithKey(DataKey.Key1)
	public var autoData:Data;

	public function new(info:TreeInfo)
	{
		super(info);
	}

	@:handler(GearDispatcherKind.Run)
	function run():Void
	{
		info.autoData = autoData;
		info.manualData = gear.absorbWithKey(DataKey.Key1);
	}
}

class TreeInfo
{
	public var children:Array<TreeInfo>;
	public var diffuseData:Data;

	public var autoData:Data;
	public var manualData:Data;

	public function new()
	{
		children = [];
	}
}

class Data
{
	public function new() {}
}

class DataSub extends Data
{
	public function new() { super(); }
}

enum DataKey
{
	Key1;
	Key2;
}