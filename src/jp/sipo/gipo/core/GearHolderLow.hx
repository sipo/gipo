package jp.sipo.gipo.core;
/**
 * GearHolderとして機能するための要件設定
 * 
 * @author sipo
 */
interface GearHolderLow
{
	/**
	 * 外部からのGear機能の呼び出し
	 */
	public function gearOutside():GearOutside;
}
