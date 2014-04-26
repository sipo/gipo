package frameworkExample.etc;
/**
 * 初期化用に使われるシーン
 * 
 * @auther sipo
 */
import frameworkExample.context.LogicToView.ViewSceneKind;
import frameworkExample.context.LogicScene;
import frameworkExample.scene.mock0.Mock0;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
private typedef SceneInput = Void;	// 特になし
/** 命令 */
private typedef ViewSceneOrder = Void;	// 特になし
/* ================================================================
 * 動作
 * ===============================================================*/
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
		changeViewScene(ViewSceneKind.Blank);
		// すぐにシーン移動
		logic.changeState(new Mock0());
	}
}
