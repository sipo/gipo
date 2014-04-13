package frameworkExample.context;
/**
 * 全体処理変数
 * 
 * @auther sipo
 */
import haxe.ds.Option;
class GlobalStatus
{
	/** 画面基本サイズ */
	inline public static var stageWidth:Int = 480;
	inline public static var stageHEIGHT:Int = 720;
	
	/** 再生状態 */
	public var reproduseMode:ReproduceMode = ReproduceMode.Record;
	/** 可変画面サイズ */
	public var screenSize:Option<{width:Int, height:Int}> = Option.None;
	
	/** コンストラクタ */
	public function new() 
	{
	}
}
enum ReproduceMode
{
	/* 記録中 */
	Record;
	/* 再生中 */
	Replay;
}
