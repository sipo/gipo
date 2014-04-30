package frameworkExample.context;
/**
 * Logicのシーンを跨ぐデータを持たせる
 * 
 * @auther sipo
 */
class LogicStatus
{
	/** Mock1が表示された回数をカウントしておく */
	public var mock1Count:Int = 0;
	
	/** コンストラクタ */
	public function new() 
	{
		
	}
	
	/**
	 * 他のインスタンスからデータを反映する
	 */
	public function setAll(target:LogicStatus):Void
	{
		mock1Count = target.mock1Count;
	}
}
