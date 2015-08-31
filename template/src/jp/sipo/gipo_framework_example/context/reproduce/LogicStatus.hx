package jp.sipo.gipo_framework_example.context.reproduce;
/**
 * Logicのシーンを跨ぐデータと再現時の定義
 * 
 * @auther sipo
 */
class LogicStatus
{
	/** Mock1が表示された回数をカウントしておく */
	public var mock1Count:Int = 0;
	
	/** コンストラクタ */
	public function new() {}
	
	/** データを全て書き換える。*/
	public function setAll(target:LogicStatus):Void
	{
		mock1Count = target.mock1Count;
	}
}

	
