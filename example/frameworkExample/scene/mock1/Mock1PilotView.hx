package frameworkExample.scene.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearHandlerKind;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import frameworkExample.pilotView.PilotViewScene;
import frameworkExample.scene.mock1.Mock1;
/* ================================================================
 * 設定
 * ===============================================================*/
/** 使用する入力定義 */
private typedef SceneInput = Mock1Input;
/** 使用する依頼定義 */
private typedef SceneOrder = Mock1ViewOrder;
/** 参照定義 */
private typedef ScenePeek = Mock1ViewPeek;
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock1PilotView extends PilotViewScene implements SceneOrder
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
		sceneHandler.draw.add(draw);
	}
	
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
		uiContainer.addLabel("開発テスト画面1");
		// ボタンの設置
		uiContainer.addPushButton("遷移テスト", demoChangeSceneButton_click);
		// カウンターの表示
		countLabel = uiContainer.addLabel("count");
		// 表示カウンターの表示
		uiContainer.addLabel('この画面は${peek.mock1Count}回表示されました');
		// 初回描画
		countDraw();
	}
	
	
	/* 遷移テスト */
	private function demoChangeSceneButton_click():Void
	{
		hook.viewInput(SceneInput.DemoChangeSceneButton);
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
