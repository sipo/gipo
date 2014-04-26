package frameworkExample.scene.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.context.LogicStatus;
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
	public var mock1Count(default, null):Int;
}
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock1 extends LogicScene implements ScenePeek
{
	@:absorb
	private var logicStatus:LogicStatus;
	/** 毎フレーム変化する値の例としてカウントアップ変数 */
	public var count:Int = 0;
	/** Mock1が表示された回数の表示 */
	public var mock1Count:Int = 0;
	/* Viewの対応シーンへの命令を行なうための参照 */
	private var viewSceneOrder:ViewSceneOrder;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
		updateHandlerList.add(update);
		// 入力処理の登録
		viewInputHandlerContainer.set(SceneInput, viewInput);
	}
	
	/* 開始処理 */
	private function run():Void
	{
		// 表示回数のカウントアップ
		logicStatus.mock1Count++;
		mock1Count = logicStatus.mock1Count;
		// Viewの表示を切り替え、そこに対する命令の参照を得る
		viewSceneOrder = cast(changeViewScene(ViewSceneKind.Mock1(this)), ViewSceneOrder);
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		// テストのために適当な変数をカウントアップする
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
