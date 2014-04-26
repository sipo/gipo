package jp.sipo.gipo.core.state;
/**
 * StateSwitcherで切り替える対象となれるインターフェース
 * ゲームの遷移画面や、ロード状態など、処理の切り替わりに利用する。
 * 
 * @author sipo
 */
interface StateGearHolder extends GearHolder
{
	function getStateGear():StateGear;
}
