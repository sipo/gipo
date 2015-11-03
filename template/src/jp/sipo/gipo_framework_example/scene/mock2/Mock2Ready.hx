package jp.sipo.gipo_framework_example.scene.mock2;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.context.ViewForLogic;
import jp.sipo.gipo_framework_example.context.LogicScene;
import jp.sipo.gipo_framework_example.scene.mock0.Mock0;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
enum Mock2ReadyViewInput
{
	CompleteReady;
}
/** 命令 */
interface Mock2ReadyViewOrder
{
}
/** 参照定義 */
interface Mock2ReadyViewPeek
{
}
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock2Ready extends LogicScene implements Mock2ReadyViewPeek
{
	/* Viewの対応シーンへの命令を行なうための参照 */
	private var viewSceneOrder:Mock2ReadyViewOrder;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		// ハンドラの登録
		gear.addRunHandler(run);
		inputRedTape.set(viewInput, Mock2ReadyViewInput);
	}
	
	/* 開始処理 */
	private function run():Void
	{
		// Viewの表示を切り替え、そこに対する命令の参照を得る
		viewSceneOrder = changeViewScene(ViewSceneKind.Mock2ReadyScene, Mock2ReadyViewInput);
	}
	
	
	/* Viewからの入力 */
	private function viewInput(command:Mock2ReadyViewInput):Void
	{
		switch(command)
		{
			case Mock2ReadyViewInput.CompleteReady: input_completeReady();
		}
	}
	
	/* デモシーン変更ボタンのクリック */
	private function input_completeReady():Void
	{
		logic.changeState(new Mock2());
	}
}
