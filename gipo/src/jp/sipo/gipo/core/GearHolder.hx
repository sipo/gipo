package jp.sipo.gipo.core;
interface GearHolder extends AutoAbsorb
{
	/**
	 * 外部からのGear機能の呼び出し
	 */
	public function gearOutside():GearOutside;
}
