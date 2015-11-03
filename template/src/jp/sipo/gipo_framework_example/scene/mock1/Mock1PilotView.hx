package jp.sipo.gipo_framework_example.scene.mock1;
/**
 * 
 * 
 * @auther sipo
 */
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo_framework_example.pilotView.PilotViewScene;
import jp.sipo.gipo_framework_example.scene.mock1.Mock1;
/* ================================================================
 * 動作
 * ===============================================================*/
class Mock1PilotView extends PilotViewScene implements Mock1ViewOrder
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	/* peek */
	private var peek:Mock1ViewPeek;
	/* Countを表示するラベル */
	private var countLabel:com.bit101.components.Label;
	
	/** コンストラクタ */
	public function new(peek:Mock1ViewPeek) 
	{
		super();
		this.peek = peek;
		// ハンドラの登録
		gear.addRunHandler(run);
		drawDispatcher.add(draw);
	}
	
	/* 開始処理 */
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
		input.instant(Mock1ViewInput.DemoChangeSceneButton);
	}
	
	/* 表示の更新 */
	private function draw():Void
	{
		countDraw();
	}
	
	/* カウントの表示 */
	private function countDraw():Void
	{
		countLabel.text = "count = " + peek.count;
	}
}
