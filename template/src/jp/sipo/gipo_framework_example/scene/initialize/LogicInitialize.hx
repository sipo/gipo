package jp.sipo.gipo_framework_example.scene.initialize;
/**
 * 初期化用に使われるシーン
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.context.ViewForLogic;
import jp.sipo.gipo_framework_example.context.LogicScene;
import jp.sipo.gipo_framework_example.scene.mock0.Mock0;
/* ================================================================
 * 設定
 * ===============================================================*/
/* ================================================================
 * 動作
 * ===============================================================*/
class LogicInitialize extends LogicScene
{
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// 仮の表示を用意
		changeViewScene(ViewSceneKind.BlankScene);
		// すぐにシーン移動
		logic.changeState(new Mock0());
	}
}
