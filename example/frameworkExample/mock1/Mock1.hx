package frameworkExample.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicViewOrder;
import frameworkExample.mock0.Mock0;
import frameworkExample.logic.LogicScene;
private typedef SceneInput = Mock1Input;
class Mock1 extends LogicScene implements Mock1Peek
{
	/** 毎フレーム変化する値の例としてカウントアップ変数 */
	public var count:Int = 0;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
		sceneHandler.update.add(update);
		// 入力処理の登録
		viewInputHandlerContainer.set(Mock1Input, viewInput);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// 表示の依頼
		view.order(LogicViewOrder.ChangeScene(ViewChangeScene.Mock1(this)));
	}
	
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		count++;
	}
	
	/* Viewからの入力 */
	private function viewInput(command:SceneInput):Void
	{
		switch(command)
		{
			case SceneInput.DemoChangeSceneButton: input_demoChangeSceneButton();
		}
	}
	
	/* デモシーン変更ボタンのクリック */
	private function input_demoChangeSceneButton():Void
	{
		logic.changeState(new Mock0());
	}
}
/** 毎フレーム変化する値はpeekで渡す */
interface Mock1Peek
{
	public var count(default, null):Int;
}
enum Mock1Input
{
	DemoChangeSceneButton;
}
enum Mock1Order
{
}
