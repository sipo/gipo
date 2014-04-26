package jp.sipo.gipo.core.state;
/**
 * StateSwitcherで切り替える対象となるクラス
 * ゲームの遷移画面や、ロード状態など、処理の切り替わりに利用する。
 * 
 * @author sipo
 */
class StateGearHolderImpl extends GearHolderImpl implements StateGearHolder
{
	private var stateGear:StateGear;
	
	public function new()
	{
		super();
		stateGear = new StateGear(this, gear);
	}
	
	public function getStateGear():StateGear
	{
		return stateGear;
	}
}
