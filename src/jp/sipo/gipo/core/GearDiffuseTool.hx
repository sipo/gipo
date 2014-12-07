package jp.sipo.gipo.core;
/**
 * Gearの初期化時に使える関数
 * 
 * @auther sipo
 */
import haxe.PosInfos;
class GearDiffuseTool
{
	private var gear:Gear;
	
	/** コンストラクタ */
	public function new(gear:Gear) 
	{
		this.gear = gear;
	}
	
	/**
	 * diffuseインスタンスを追加する
	 * @gearDispose
	 */
	public function diffuse(diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void
	{
		gear.diffuse(diffuseInstance, clazz);
	}
	
	/**
	 * diffuseインスタンスをキーによって追加する
	 * @gearDispose
	 */
	public function diffuseWithKey(diffuseInstance:Dynamic, enumKey:EnumValue):Void
	{
		gear.diffuseWithKey(diffuseInstance, enumKey);
	}
	
	/**
	 * 子の追加を遅延予約する
	 * 
	 * @gearDispose
	 */
	public function bookChild<T:(GearHolderLow)>(child:T, ?pos:PosInfos):T
	{
		return gear.bookChild(child, pos);
	}
	
	
//	/**
//	 * 対象Gearに限定してdiffuseを行う
//	 * @gearDispose
//	 */
//	public function childDiffuse(target:IGearHolder, diffuseInstance:Dynamic, clazz:Class<Dynamic>, ?overwrite:Bool = false):Void
//	{
//		gear.childDiffuse(target, diffuseInstance, clazz, overwrite);
//	}
//	
//	/**
//	 * 対象Gearに限定してキーによるdiffuseを行う
//	 * 
//	 * @gearDispose
//	 */
//	public function childDiffuseWithKey(target:IGearHolder, diffuseInstance:Dynamic, key:EnumValue, ?overwrite:Bool = false):Void
//	{
//		gear.childDiffuseWithKey(target, diffuseInstance, key, overwrite);
//	}
	
	/* 消去処理 */
	@:allow(jp.sipo.gipo.core.Gear)
	private function dispose():Void
	{
		gear = null;
	}
}
