package jp.sipo.gipo.core;
/**
 * 外部からGearを呼び出した場合に使用できるメソッド一覧
 * 
 * @auther sipo
 */
import haxe.ds.Option;
import jp.sipo.gipo.core.handler.CancelKey;
import haxe.PosInfos;
interface GearOutside
{
	/**
	 * 親がなくとも動作するGearHolderとして設定する
	 * 
	 * @param parentDiffuser Diffuserのみをどこからか引き継ぎたい場合に設定する。不必要ならnull
	 */
	public function initializeTop(parentDiffuser:Option<Diffuser>):Void;
	
	/**
	 * 親がなくとも動作するGearHolderを消去する
	 */
	public function disposeTop():Void;
	
	/**
	 * 消去処理の追加。実行は追加の逆順で行われる
	 */
	public function disposeTask(func:Void -> Void, ?pos:PosInfos):CancelKey;
	
	/**
	 * 外部からDiffuseを行なう
	 * @gearDispose
	 */
	public function otherDiffuse(diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void;
	
	/**
	 * 外部からキーによるDiffuseを行なう
	 * @gearDispose
	 */
	public function otherDiffuseWithKey(diffuseInstance:Dynamic, key:EnumValue):Void;
	
	/**
	 * Gearの実態を取得する。
	 * Gear内部での処理にしか使わない
	 */
	@:allow(Gear)
	private function getImplement():Gear;
}
