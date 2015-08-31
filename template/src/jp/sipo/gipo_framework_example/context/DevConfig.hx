package jp.sipo.gipo_framework_example.context;
/**
 * ゲーム全体の設定をする
 * 定数定義ではなく、デバッグ用フラグなどの切り替え
 * 将来的に、ここでの定義はリリースデフォルトとなり、他に複数の設定を切り替えるクラスを用意する
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.OperationOverView;
import jp.sipo.gipo_framework_example.pilotView.PilotView;
class DevConfig
{
	/** Viewクラス */
	public var view:Class<Dynamic> = PilotView;
	/** Viewクラス */
	public var operationView:Class<Dynamic> = OperationOverView;
	
	/** コンストラクタ */
	public function new() 
	{
		
	}
}
