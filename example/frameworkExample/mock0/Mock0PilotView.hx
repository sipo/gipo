package frameworkExample.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.mock0.Mock0;
import frameworkExample.core.ViewToLogicInput;
import frameworkExample.core.Hook;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import frameworkExample.pilotView.PilotViewScene;
private typedef SceneOrder = Mock0Order;
private typedef SceneInput = Mock0Input;
class Mock0PilotView extends PilotViewScene
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
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
		uiContainer.addLabel("開発テスト画面0");
		// ボタンの設置
		uiContainer.addPushButton("入力テスト", demoDisplayButton_click);
		uiContainer.addPushButton("遷移テスト", demoChangeSceneButton_click);
		
	}
	
	/* 反応テスト */
	private function demoDisplayButton_click():Void
	{
		hook.viewInput(ViewToLogicInput.Scene(SceneInput.DemoDisplayButton));
	}
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInput(ViewToLogicInput.Scene(SceneInput.DemoChangeSceneButton));
	}
	
	/* Logicからの命令 */
	private function order(command:SceneOrder):Void
	{
		switch(command)
		{
			case SceneOrder.DemoDisplay : uiContainer.addLabel("ボタン入力がありました");
		}
	}
}
