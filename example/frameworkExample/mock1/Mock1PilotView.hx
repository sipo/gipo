package frameworkExample.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.core.ViewLogicInput;
import frameworkExample.mock1.Mock1;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import frameworkExample.pilotView.PilotViewScene;
private typedef SceneOrder = Mock1Order;
private typedef SceneInput = Mock1Input;
private typedef ScenePeek = Mock1Peek;
class Mock1PilotView extends PilotViewScene
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	/* peek */
	private var peek:ScenePeek;
	/* Countを表示するラベル */
	private var countLabel:com.bit101.components.Label;
	
	/** コンストラクタ */
	public function new(peek:ScenePeek) 
	{
		super();
		this.peek = peek;
		gear.addRunHandler(run);
		sceneHandler.draw.add(draw);
		orderHandlerContainer.set(SceneOrder, order);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// UIの配置準備
		bgLayer = new Sprite();
		layer.addChild(bgLayer);
		gear.disposeTask(function () layer.removeChild(bgLayer));
		uiLayer = new Sprite();
		layer.addChild(uiLayer);
		gear.disposeTask(function () layer.removeChild(uiLayer));
		uiContainer = new MinimalcompsGipoContainer(uiLayer);
		gear.addChild(uiContainer);
		// 表示設置
		// ラベルの設置
		uiContainer.addLabel("開発テスト画面1");
		// ボタンの設置
		uiContainer.addPushButton("遷移テスト", demoChangeSceneButton_click);
		// カウンターの表示
		countLabel = uiContainer.addLabel("count");
		countDraw();
	}
	
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInput(ViewLogicInput.Scene(SceneInput.DemoChangeSceneButton));
	}
	
	/* Logicからの命令 */
	private function order(command:SceneOrder):Void
	{
		// 特になし
	}
	
	/**
	 * 表示の更新
	 */
	public function draw():Void
	{
		countDraw();
	}
	
	/* カウントの表示 */
	private function countDraw():Void
	{
		countLabel.text = "count = " + peek.count;
	}
}
