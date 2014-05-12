package frameworkExample.scene.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearHandlerKind;
import frameworkExample.scene.mock0.Mock0;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import frameworkExample.pilotView.PilotViewScene;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 使用する入力定義 */
private typedef SceneInput = Mock0Input;
/** 使用する依頼定義 */
private typedef SceneOrder = Mock0ViewOrder;
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock0PilotView extends PilotViewScene implements SceneOrder
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearHandlerKind.Run)
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
		hook.viewInput(SceneInput.DemoDisplayButton);
	}
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInput(SceneInput.DemoChangeSceneButton);
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
