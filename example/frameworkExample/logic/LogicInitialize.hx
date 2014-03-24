package frameworkExample.logic;
/**
 * 初期化用に使われるシーン
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicViewOrder.ViewChangeScene;
import frameworkExample.mock0.Mock0;
class LogicInitialize extends LogicScene
{
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// 画面表示を初期化
		view.order(LogicViewOrder.ChangeScene(ViewChangeScene.None));
		// すぐにシーン移動
		logic.changeState(new Mock0());
	}
}
