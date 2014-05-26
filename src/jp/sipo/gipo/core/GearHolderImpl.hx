package jp.sipo.gipo.core;

/**
 * Gar利用クラスの最小構成
 * 基本的にはこれを利用しておけば問題ない
 * 
 * @author sipo
 */
class GearHolderImpl implements GearHolder
{
	/* ギア。構造制御インスタンス */
	private var gear:Gear;
	
	/** コンストラクタでギアを生成する */
	public function new() 
	{
		gear = new Gear(this);
	}
	
	/**
	 * 外部からのGear機能の呼び出し
	 */
	public function gearOutside():GearOutside
	{
		return gear;
	}
}
