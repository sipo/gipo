package jp.sipo.gipo_framework_example.scene.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.context.reproduce.LogicStatus;
import jp.sipo.gipo_framework_example.context.ViewForLogic;
import jp.sipo.gipo_framework_example.context.LogicScene;
import jp.sipo.gipo_framework_example.scene.mock0.Mock0;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 入力 */
enum Mock1Input
{
	DemoChangeSceneButton;
}
/** 命令 */
interface Mock1ViewOrder
{
	// 今のところ特になし
}
/** 参照定義 */
interface Mock1ViewPeek
{
	public var count(default, null):Int;
	public var mock1Count(default, null):Int;
}
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock1 extends LogicScene implements Mock1ViewPeek
{
	@:absorb
	private var logicStatus:LogicStatus;
	/** 毎フレーム変化する値の例としてカウントアップ変数 */
	public var count:Int = 0;
	/** Mock1が表示された回数の表示 */
	public var mock1Count:Int = 0;
	/* Viewの対応シーンへの命令を行なうための参照 */
	private var viewSceneOrder:Mock1ViewOrder;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// 表示回数のカウントアップ
		logicStatus.mock1Count++;
		mock1Count = logicStatus.mock1Count;
		// Viewの表示を切り替え、そこに対する命令の参照を得る
		viewSceneOrder = changeViewScene(ViewSceneKind.Mock1Scene(this));
	}
	
	/**
	 * 更新処理
	 */
	@:handler(LogicSceneDispatcherKind.Update)
	public function update():Void
	{
		// テストのために適当な変数をカウントアップする
		count++;
	}
	
	/* Viewからの入力 */
	@:redTapeHandler(LogicSceneDispatcherKind.ViewInput)
	private function viewInput(command:Mock1Input):Void
	{
		switch(command)
		{
			case Mock1Input.DemoChangeSceneButton: input_demoChangeSceneButton();
		}
	}
	
	/* デモシーン変更ボタンのクリック */
	private function input_demoChangeSceneButton():Void
	{
		logic.changeState(new Mock0());
	}
}
