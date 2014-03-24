package ;
/**
 * ゲームの基本設計などの例
 * 
 * @auther sipo
 */
import frameworkExample.core.Top;
class FrameworkExample
{

	/* メインインスタンス */
	private static var _main:FrameworkExample;
	
	/**
	 * 起動関数
	 */
	public static function main():Void
	{
		_main = new FrameworkExample();
	}
	
	/* 最上位GearHolder */
	private var top:Top;
	
	/** コンストラクタ */
	public function new() 
	{
		top = new Top();
		
	}
}
