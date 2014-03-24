package frameworkExample.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.mock1.Mock1;
import frameworkExample.logic.LogicViewOrder;
import frameworkExample.logic.LogicScene;
private typedef SceneInput = Mock0Input;
class Mock0 extends LogicScene
{
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
		// 入力処理の登録
		viewInputHandlerContainer.set(Mock0Input, viewInput);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// 表示の依頼
		view.order(LogicViewOrder.ChangeScene(ViewChangeScene.Mock0));
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
		view.order(LogicViewOrder.Scene(Mock0Order.DemoDisplay));
	}
	
	/* デモシーン変更ボタンのクリック */
	private function input_demoChangeSceneButton():Void
	{
		logic.changeState(new Mock1());
	}
}
enum Mock0Input
{
	DemoDisplayButton;
	DemoChangeSceneButton;
}
enum Mock0Order
{
	DemoDisplay;
}
