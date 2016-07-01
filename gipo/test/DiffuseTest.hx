package;

import haxe.ds.Option;
import jp.sipo.gipo.core.GearPreparationTool;
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
	 * top diffuses DiffuseData.
	 * nodeA and nodeAA can absorb that.
	 */
	@Test
	public function testDiffuseStraight():Void
	{
		var data = new DiffuseData();
		
		var top = new DiffuseTreeInfo();
		top.diffuseData = data;
		
		var nodeA = new DiffuseTreeInfo();
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);
		
		// build gear tree
		var topGear = new DiffuseTop(top);
		topGear.gearOutside().initializeTop(Option.None);
		
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
	 * top diffuses DiffuseData.
	 * nodeA, nodeAA, nodeB and nodeBB can absorb that.
	 */
	@Test
	public function testDiffuseFork():Void
	{
		var data = new DiffuseData();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new DiffuseTreeInfo();
		top.children.push(nodeB);

		var nodeBB = new DiffuseTreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var topGear = new DiffuseTop(top);
		topGear.gearOutside().initializeTop(Option.None);

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
	 * top diffuses DiffuseData.
	 * nodeB and nodeBB can absorb that.
	 * nodeA can absorb that before diffuse self.
	 *
	 * nodeA diffuses another DiffuseData.
	 * nodeAA can absorb that.
	 * nodeA can absorb that after diffuse self.
	 */
	@Test
	public function testDiffusePartial():Void
	{
		var data = new DiffuseData();
		var dataA = new DiffuseData();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		nodeA.diffuseData = dataA;
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new DiffuseTreeInfo();
		top.children.push(nodeB);

		var nodeBB = new DiffuseTreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var topGear = new DiffuseTop(top);
		topGear.gearOutside().initializeTop(Option.None);

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
	 * top diffuses DiffuseDataSub.
	 * nodeA and nodeAA can absorb that.
	 */
	@Test
	public function testDiffuseSubclass():Void
	{
		var data = new DiffuseDataSub();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		// build gear tree
		var topGear = new DiffuseTop(top);
		topGear.gearOutside().initializeTop(Option.None);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
	}

	/*
	 * top -- nodeA -- nodeAA
	 *
	 * top diffuses DiffuseData with key.
	 * nodeA and nodeAA can absorb that.
	 */
	@Test
	public function testDiffuseStraightWithKey():Void
	{
		var data = new DiffuseData();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		// build gear tree
		var topGear = new DiffuseWithKeyTop(top);
		topGear.gearOutside().initializeTop(Option.None);

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
	 * top diffuses DiffuseData with key.
	 * nodeA, nodeAA, nodeB and nodeBB can absorb that.
	 */
	@Test
	public function testDiffuseForkWithKey():Void
	{
		var data = new DiffuseData();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new DiffuseTreeInfo();
		top.children.push(nodeB);

		var nodeBB = new DiffuseTreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var topGear = new DiffuseWithKeyTop(top);
		topGear.gearOutside().initializeTop(Option.None);

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
	 * top diffuses DiffuseData.
	 * nodeB and nodeBB can absorb that.
	 * nodeA can absorb that before diffuse self.
	 *
	 * nodeA diffuses another DiffuseData with key.
	 * nodeAA can absorb that.
	 * nodeA can absorb that after diffuse self.
	 */
	@Test
	public function testDiffusePartialWithKey():Void
	{
		var data = new DiffuseData();
		var dataA = new DiffuseData();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		nodeA.diffuseData = dataA;
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		var nodeB = new DiffuseTreeInfo();
		top.children.push(nodeB);

		var nodeBB = new DiffuseTreeInfo();
		nodeB.children.push(nodeBB);

		// build gear tree
		var topGear = new DiffuseWithKeyTop(top);
		topGear.gearOutside().initializeTop(Option.None);

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
	 * top diffuses DiffuseDataSub with key.
	 * nodeA and nodeAA can absorb that.
	 */
	@Test
	public function testDiffuseSubclassWithKey():Void
	{
		var data = new DiffuseDataSub();

		var top = new DiffuseTreeInfo();
		top.diffuseData = data;

		var nodeA = new DiffuseTreeInfo();
		top.children.push(nodeA);

		var nodeAA = new DiffuseTreeInfo();
		nodeA.children.push(nodeAA);

		// build gear tree
		var topGear = new DiffuseWithKeyTop(top);
		topGear.gearOutside().initializeTop(Option.None);

		// verify
		Assert.areEqual(data, nodeA.autoData);
		Assert.areEqual(data, nodeA.manualData);
		Assert.areEqual(data, nodeAA.autoData);
		Assert.areEqual(data, nodeAA.manualData);
	}
}

class DiffuseTop extends GearHolderImpl
{
	var info:DiffuseTreeInfo;

	public function new(info:DiffuseTreeInfo)
	{
		super();
		this.info = info;
		// ハンドラの登録
		gear.addPreparationHandler(preparation);
	}

	/* 準備処理*/
	function preparation(tool:GearPreparationTool):Void
	{
		if(info.diffuseData != null) {
			tool.diffuse(info.diffuseData, DiffuseData);
		}

		for(child in info.children) {
			tool.bookChild(new DiffuseNode(child));
		}
	}
}

class DiffuseNode extends DiffuseTop
{
	@:absorb
	public var autoData:DiffuseData;
	
	public function new(info:DiffuseTreeInfo)
	{
		super(info);
		gear.addRunHandler(run);
	}

	function run():Void
	{
		info.autoData = autoData;
		info.manualData = gear.absorb(DiffuseData);
	}
}

class DiffuseWithKeyTop extends GearHolderImpl
{
	var info:DiffuseTreeInfo;

	public function new(info:DiffuseTreeInfo)
	{
		super();
		this.info = info;
		gear.addPreparationHandler(preparation);
	}

	function preparation(tool:GearPreparationTool):Void
	{
		if(info.diffuseData != null) {
			tool.diffuseWithKey(info.diffuseData, DiffuseDataKey.Key1);
			tool.diffuseWithKey(info.diffuseData, DiffuseDataKey2.Key1);
		}

		for(child in info.children) {
			tool.bookChild(new DiffuseWithKeyNode(child));
		}
	}
}

class DiffuseWithKeyNode extends DiffuseWithKeyTop
{
	@:absorbWithKey(DiffuseTest.DiffuseDataKey.Key1)
	public var autoData:DiffuseData;

	public function new(info:DiffuseTreeInfo)
	{
		super(info);
		gear.addRunHandler(run);
	}

	function run():Void
	{
		info.autoData = autoData;
		info.manualData = gear.absorbWithKey(DiffuseDataKey.Key1);
	}
}

class DiffuseTreeInfo
{
	public var children:Array<DiffuseTreeInfo>;
	public var diffuseData:DiffuseData;

	public var autoData:DiffuseData;
	public var manualData:DiffuseData;

	public function new()
	{
		children = [];
	}
}

class DiffuseData
{
	public function new() {}
}

class DiffuseDataSub extends DiffuseData
{
	public function new() { super(); }
}

enum DiffuseDataKey
{
	Key1;
	Key2;
}

enum DiffuseDataKey2
{
	Key1;
	Key2;
}