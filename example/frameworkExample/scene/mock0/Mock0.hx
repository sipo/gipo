package frameworkExample.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
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
class Mock0 extends LogicScene<ViewSceneOrder>
{
	/** コンストラクタ */
	public function new() 
	{
		super(ViewSceneKind.Mock0);
		// 入力処理の登録
		viewInputHandlerContainer.set(Mock0Input, viewInput);
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
		viewScene.demoDisplay();
	}
	
	/* デモシーン変更ボタンのクリック */
	private function input_demoChangeSceneButton():Void
	{
		logic.changeState(new Mock1());
	}
}
