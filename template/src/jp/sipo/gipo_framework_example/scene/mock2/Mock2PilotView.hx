package jp.sipo.gipo_framework_example.scene.mock2;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.scene.mock2.Mock2;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo_framework_example.pilotView.PilotViewScene;
class Mock2PilotView extends PilotViewScene implements Mock2ViewOrder
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
		uiContainer = gear.addChild(new MinimalcompsGipoContainer(uiLayer));
		// 表示設置
		// ラベルの設置
		uiContainer.addLabel("開発テスト画面2");
		// ボタンの設置
		uiContainer.addPushButton("遷移テスト", demoChangeSceneButton_click);
		
	}
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInstantInput(Mock2Input.DemoChangeSceneButton);
	}
	
}
