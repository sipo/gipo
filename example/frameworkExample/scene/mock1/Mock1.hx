package frameworkExample.scene.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.context.LogicToView;
import frameworkExample.context.LogicScene;
import frameworkExample.scene.mock0.Mock0;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
private typedef SceneInput = Mock1Input;
enum Mock1Input
{
	DemoChangeSceneButton;
}
/** 命令 */
private typedef ViewSceneOrder = Mock1ViewOrder;
interface Mock1ViewOrder
{
	// 今のところ特になし
}
/** 参照定義 */
private typedef ScenePeek = Mock1ViewPeek;
interface Mock1ViewPeek
{
	public var count(default, null):Int;
}
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock1 extends LogicScene<ViewSceneOrder> implements ScenePeek
{
	/** 毎フレーム変化する値の例としてカウントアップ変数 */
	public var count:Int = 0;
	
	/** コンストラクタ */
	public function new() 
	{
		super(ViewSceneKind.Mock1(this));
		updateHandlerList.add(update);
		// 入力処理の登録
		viewInputHandlerContainer.set(SceneInput, viewInput);
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
