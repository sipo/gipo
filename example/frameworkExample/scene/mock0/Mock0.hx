package frameworkExample.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
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
private typedef SceneInput = Mock0Input;
enum Mock0Input
{
	DemoDisplayButton;
	DemoChangeSceneButton;
}
/** 命令 */
private typedef ViewSceneOrder = Mock0ViewOrder;
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
	private var viewSceneOrder:ViewSceneOrder;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
		// 入力処理の登録
		viewInputHandlerContainer.set(SceneInput, viewInput);
	}
	
	/* 開始処理 */
	private function run():Void
	{
		// Viewの表示を切り替え、そこに対する命令の参照を得る
		viewSceneOrder = changeViewScene(ViewSceneKind.Mock0, ViewSceneOrder);
	}
	
	/* Viewからの入力 */
	private function viewInput(command:SceneInput):Void
	{
		switch(command)
		{
			case SceneInput.DemoDisplayButton: input_demoTraceButton();
			case SceneInput.DemoChangeSceneButton: input_demoChangeSceneButton();
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
