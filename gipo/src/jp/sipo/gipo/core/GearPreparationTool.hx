package jp.sipo.gipo.core;
/**
 * Gearの初期化時に使える関数
 * 
 * @auther sipo
 */
import haxe.PosInfos;
class GearPreparationTool
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
	public function bookChild<T:(GearHolder)>(child:T, ?pos:PosInfos):T
	{
		return gear.bookChild(child, pos);
	}
	
	/* 消去処理 */
	@:allow(jp.sipo.gipo.core.Gear)
	private function dispose():Void
	{
		gear = null;
	}
}
