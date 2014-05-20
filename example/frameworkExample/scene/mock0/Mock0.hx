package frameworkExample.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import frameworkExample.context.LogicStatus;
import frameworkExample.etc.Snapshot;
import frameworkExample.context.Hook.LogicToHook;
import frameworkExample.context.LogicScene;
import frameworkExample.context.LogicToView;
import frameworkExample.scene.mock1.Mock1;
import frameworkExample.context.LogicScene;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
enum Mock0Input
{
	DemoDisplayButton;
	DemoChangeSceneButton;
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
		viewSceneOrder = changeViewScene(ViewSceneKind.Mock0);
	}
	
	/* Viewからの入力 */
	@:redTapeHandler(LogicSceneDispatcherKind.ViewInput)
	private function viewInput(command:Mock0Input):Void
	{
		switch(command)
		{
			case Mock0Input.DemoDisplayButton: input_demoTraceButton();
			case Mock0Input.DemoChangeSceneButton: input_demoChangeSceneButton();
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
}
