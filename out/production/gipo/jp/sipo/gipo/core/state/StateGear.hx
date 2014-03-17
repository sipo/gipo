package jp.sipo.gipo.core.state;
/**
 * Gearと共に、状態遷移を管理するクラス
 * 
 * @author sipo
 */
@:final
class StateGear
{
	// 関連インスタンス
	private var gear:Gear;
	private var switcher:StateSwitcherGear;
	
	private var changeStateLock:Bool = true;
	/** 初期化タスク名称 */
	public static inline var STATE_GEAR_INITIALIZE:String = "stateGearInitialize";
	
	public function new(holder:StateGearHolder, gear:Gear)
	{
		this.gear = gear;
		gear.addNeedTask(GearStateNeedTask.Core);
	}
	
	
	/**
	 * Stateとして有効化
	 * Stateが切り替わった直後に呼び出される
	 * この後に処理を挟みたい場合は、runを使用する
	 */
	public inline function activationState(switcher:StateSwitcherGear):Void
	{
		this.switcher = switcher;
		changeStateLock = false;
		gear.endNeedTask(GearStateNeedTask.Core);
	}
	
	/**
	 * Stateの切り替えをswitcherに渡す
	 */
	public inline function changeState(nextStateHolder:StateGearHolder):Void
	{
		if (changeStateLock) throw new SipoError("changeStateがロックされています。run以降でなければなりません。");
		changeStateLock = true;
		switcher.changeState(nextStateHolder);
	}
	
}
enum GearStateNeedTask
{
	Core;
}
