package;

import Type;
import jp.sipo.gipo.core.GearHolder;
import jp.sipo.gipo.core.Gear;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

//src/jp/sipo/gipo/core/Gear.hxのテストプログラム
//haxelib run munit test -as3でテストした

@:access(jp.sipo.gipo.core.Gear)
@:access(jp.sipo.gipo.core.GearHolderImpl)
class GearStructureTest
{
	public function new()
	{}
	
	/**
	*テストに共通するparentとchildをフィールド変数にした
	**/
	
	var parent:GearHolderImpl;
	var child: GearHolderImpl;
	
	/**
	*parent,childを作成するsetup
	**/
	
	@Before
	public function setup():Void{
		parent = new GearHolderImpl();
		child = new GearHolderImpl();
		//根を初期化
		parent.gearOutside().initializeTop(null);
	}
	
	@Test("setupが正しく行われている")
	public function testSetup():Void{
		//型チェック
		Assert.areEqual(GearHolderImpl,Type.getClass(parent));
		Assert.areEqual(GearHolderImpl,Type.getClass(parent));
		Assert.areEqual(Gear,Type.getClass(parent.gear));
		Assert.areEqual(Gear,Type.getClass(child.gear));
		
		//正しく生成されているかどうかをGearのchildGearListの長さが0であることで確認
		Assert.areEqual(0, parent.gear.childGearList.length);
		Assert.areEqual(0, child.gear.childGearList.length);
	}
	
	///////////////////////////////////////////////////////////////////////
	/**
	* initializeTopメソッドのテスト
	* 正しい初期状態かをテスト
	* とりあえずGearを生成し、その要素のchildGearListの長さが0であることをテスト
	**/

	@Test("GearにinitializeTopをしたとき、そのGearのchildGearListの長さが0である")
	public function testInitializeTop():Void
	{
		//TODO initializeTop特有のものでチェックするようにする
		Assert.areEqual(0, parent.gear.childGearList.length);
	}

	///////////////////////////////////////////////////////////////////////
	/**
	* addChildメソッドのテスト
	* addChildの確認のため、最も単純に親と子を1つずつ作成し、
	* addChildしたときの親の持つ子の配列childGearListの長さを取得する
	* 初期状態では0,addChild後は1であるはず
	**/

	@Test("最初にaddChildしたとき、正しく構造が生成されている")
	public function testAddChild():Void
	{
		var pgear = parent.gear;
		
		//addChildを実行する
		pgear.addChild(child);
		
		//addChildしたので、parentのchildGearListにある要素数を見る
		Assert.areEqual(1, pgear.childGearList.length);
		
		/*
		配列の最初の1つがchildと同一であることをテスト
		childGearListはGear型配型で、childはGearHolderImpl型だが
		GearHolderImplクラスは内部ではGearを生成しているので、gearOutside()メソッドで
		実際に使用されているGear型のchildを取得できる
		 */
		Assert.areEqual(child.gearOutside(), pgear.childGearList[0]);
		
		/*
		子の親が意図したものであることをテスト
		parent.gearOutside()は上記の理由と同じで、Gear型のparentを取得している
		pgear.childGearList[0].parentで、子の親を取得している
		 */
		 Assert.areEqual(parent.gearOutside(), pgear.childGearList[0].parent);
	}
	
	///////////////////////////////////////////////////////////////////////
	/**
	* removeChildメソッドのテスト
	* 正しくGearをchildGearListからremoveChildできているか
	* まずはtestaddChild()と同じように要素をaddChildし、そこからremoveChildを適用する
	* childGearListの長さを取得しテストしている
	* removeChild後は0のはずである
	**/

	@Test("addChild後にremoveChildしたとき、親GearのchildGearListの長さが0である")
	public function testRemoveChild():Void
	{
		var pgear = parent.gear;
		pgear.addChild(child);

		//removeChildして、parentのchildGearListにある要素数が0であることをテスト
		pgear.removeChild(child);
		Assert.areEqual(0, pgear.childGearList.length);
	}
}
