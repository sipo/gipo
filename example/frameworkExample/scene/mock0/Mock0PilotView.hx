package frameworkExample.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import frameworkExample.scene.mock0.Mock0;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import frameworkExample.pilotView.PilotViewScene;
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock0PilotView extends PilotViewScene implements Mock0ViewOrder
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Run)
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
		hook.viewInput(Mock0Input.DemoDisplayButton);
	}
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInput(Mock0Input.DemoChangeSceneButton);
	}
	
	/* ================================================================
	 * Order by Logic 
	 * ===============================================================*/
	
	/**
	 * デモ用表示命令
	 */
	public function demoDisplay():Void
	{
		uiContainer.addLabel("ボタン入力がありました");
	}
}
