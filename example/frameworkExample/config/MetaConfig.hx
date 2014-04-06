package frameworkExample.config;
/**
 * 
 * 
 * @auther sipo
 */
class MetaConfig
{
	/** 再生状態 */
	public var reproduseMode:ReproduceMode = ReproduceMode.Record;
	
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
