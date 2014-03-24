package frameworkExample.config;
/**
 * ゲーム全体の設定をする
 * 定数定義ではなく、デバッグ用フラグなどの切り替え
 * 将来的に、ここでの定義はリリースデフォルトとなり、他に複数の設定を切り替えるクラスを用意する
 * 
 * @auther sipo
 */
import frameworkExample.pilotView.PilotView;
import frameworkExample.core.Hook.HookBasic;
class DevConfig
{
	/** Hookクラス */
	public var hook:Class<Dynamic> = HookBasic;
	/** Viewクラス */
	public var view:Class<Dynamic> = PilotView;
	
	
	/** コンストラクタ */
	public function new() 
	{
		
	}
}
