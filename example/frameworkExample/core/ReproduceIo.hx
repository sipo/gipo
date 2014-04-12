package frameworkExample.core;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolder;
import jp.sipo.gipo.core.GearHolderImpl;
interface ReproduceIo extends GearHolder
{
	/** 保存 */
	public function save(value:String):Void;
	/** 読み込み */
	public function load():Void;
}
class ReproduceIo_File extends GearHolderImpl implements ReproduceIo
{
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/** 保存 */
	public function save(value:String):Void
	{
		throw "未対応";
	}
	
	/** 読み込み */
	public function load():Void
	{
		throw "未対応";
	}
}
