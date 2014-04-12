package frameworkExample.config;
/**
 * ゲーム全体の設定をする
 * 定数定義ではなく、デバッグ用フラグなどの切り替え
 * 将来的に、ここでの定義はリリースデフォルトとなり、他に複数の設定を切り替えるクラスを用意する
 * 
 * @auther sipo
 */
import frameworkExample.core.ReproduceIo;
import frameworkExample.pilotView.PilotView;
class DevConfig
{
	/** Viewクラス */
	public var view:Class<Dynamic> = PilotView;
	/** 記録データの保存方法指定 */
	public var reproduceIo:Class<Dynamic> = ReproduceIo_File;
	
	
	
	/** コンストラクタ */
	public function new() 
	{
		
	}
}
