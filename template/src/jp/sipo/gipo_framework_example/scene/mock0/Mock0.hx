package jp.sipo.gipo_framework_example.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.scene.mock2.Mock2Ready;
import jp.sipo.gipo_framework_example.scene.mock2.Mock2;
import jp.sipo.gipo_framework_example.context.reproduce.SnapshotKind;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.reproduce.Snapshot;
import jp.sipo.gipo_framework_example.context.LogicScene;
import jp.sipo.gipo_framework_example.context.ViewForLogic;
import jp.sipo.gipo_framework_example.scene.mock1.Mock1;
import jp.sipo.gipo_framework_example.context.LogicScene;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
enum Mock0Input
{
	DemoDisplayButton;
	DemoChangeSceneButton;
	DemoReadySceneButton;
}
/** 命令 */
interface Mock0ViewOrder
{
	/** デモ用表示をする */
	public function demoDisplay():Void;
}
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock0 extends LogicScene
{
	/* Viewの対応シーンへの命令を行なうための参照 */
	private var viewSceneOrder:Mock0ViewOrder;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	/* 開始処理 */
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// Viewの表示を切り替え、そこに対する命令の参照を得る
		viewSceneOrder = changeViewScene(ViewSceneKind.Mock0Scene);
	}
	
	/* Viewからの入力 */
	@:redTapeHandler(LogicSceneDispatcherKind.ViewInput)
	private function viewInput(command:Mock0Input):Void
	{
		switch(command)
		{
			case Mock0Input.DemoDisplayButton: input_demoTraceButton();
			case Mock0Input.DemoChangeSceneButton: input_demoChangeSceneButton();
			case Mock0Input.DemoReadySceneButton: input_demoReadySceneButton();
		}
	}
	
	/* デモボタンのクリック */
	private function input_demoTraceButton():Void
	{
		viewSceneOrder.demoDisplay();
	}
	
	/* デモシーン変更ボタンのクリック */
	private function input_demoChangeSceneButton():Void
	{
		// スナップショットを取りつつ移動
		logic.snapshotEvent(SnapshotKind.Mock1);
	}
	
	/* 準備イベントテストボタンのクリック */
	private function input_demoReadySceneButton():Void
	{
		logic.changeState(new Mock2Ready());
	}
}
