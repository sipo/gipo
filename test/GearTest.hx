package;

import jp.sipo.gipo.core.Gear;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

//src/jp/sipo/gipo/core/Gear.hxのテストプログラム
//haxelib run munit test -as3でテストした

@:access(jp.sipo.gipo.core.Gear)
@:access(jp.sipo.gipo.core.GearHolderImpl)
class GearTest
{
	public function new()
	{}

	/**
	* 正しい初期状態かをテスト
	* とりあえずGearを生成し、その要素のchildGearListの長さが0であることをテスト
	**/

	@Test("GearにinitializeTopをしたとき、そのGearのchildGearListの長さが0である")
	public function test_initializeTop():Void
	{
		var parent:GearHolderImpl = new GearHolderImpl();
		parent.gearOutside().initializeTop(null);
		Assert.areEqual(0, parent.gear.childGearList.length);
	}

	/**
	* addChildの確認のため、最も単純に親と子を1つずつ作成し、
	* addChildしたときの親の持つ子の配列childGearListの長さを取得する
	* 初期状態では0,addChild後は1であるはず
	**/

	@Test("最初にaddChildしたとき、親GearのchildGearListの長さが1である")
	public function test_addChild():Void
	{
		/*最上位GearHolder*/
		var parent:GearHolderImpl = new GearHolderImpl();
		var child:GearHolderImpl = new GearHolderImpl();
		//根を初期化。動き出す
		parent.gearOutside().initializeTop(null);

		var pgear = parent.gear;

		pgear.addChild(child);
		//addChildしたので、parentのchildGearListにある要素数を見る
		Assert.areEqual(1, pgear.childGearList.length);
	}

	/**
	* 正しくGearをchildGearListからremoveChildできているか
	* まずはtestaddChild()と同じように要素をaddChildし、そこからremoveChildを適用する
	* childGearListの長さを取得しテストしている
	* removeChild後は0のはずである
	**/

	@Test("最初にremoveChildしたとき、親GearのchildGearListの長さが0である")
	public function test_removeChild():Void
	{
		var parent:GearHolderImpl = new GearHolderImpl();
		var child:GearHolderImpl = new GearHolderImpl();
		//根を初期化。動き出す
		parent.gearOutside().initializeTop(null);

		var pgear = parent.gear;
		pgear.addChild(child);

		//removeChildして、parentのchildGearListにある要素数が0であることをテスト
		pgear.removeChild(child);
		Assert.areEqual(0, pgear.childGearList.length);
	}
}
