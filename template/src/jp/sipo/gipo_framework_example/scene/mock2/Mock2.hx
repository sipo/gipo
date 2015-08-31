package jp.sipo.gipo_framework_example.scene.mock2;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.scene.mock0.Mock0;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.context.LogicScene;
import jp.sipo.gipo_framework_example.context.ViewForLogic;
import jp.sipo.gipo_framework_example.context.LogicScene;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
enum Mock2Input
{
	DemoChangeSceneButton;
}
/** 命令 */
interface Mock2ViewOrder
{
}
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock2 extends LogicScene
{
	/* Viewの対応シーンへの命令を行なうための参照 */
	private var viewSceneOrder:Mock2ViewOrder;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	/* 開始処理 */
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// Viewの表示を切り替え、そこに対する命令の参照を得る
		viewSceneOrder = changeViewScene(ViewSceneKind.Mock2Scene);
	}
	
	/* Viewからの入力 */
	@:redTapeHandler(LogicSceneDispatcherKind.ViewInput)
	private function viewInput(command:Mock2Input):Void
	{
		switch(command)
		{
			case Mock2Input.DemoChangeSceneButton: input_demoChangeSceneButton();
		}
	}
	
	
	/* デモシーン変更ボタンのクリック */
	private function input_demoChangeSceneButton():Void
	{
		logic.changeState(new Mock0());
	}
}
