package jp.sipo.gipo_framework_example.scene.mock2;
/**
 * 
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo_framework_example.scene.mock2.Mock2Ready;
import jp.sipo.gipo_framework_example.scene.mock2.Mock2;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo_framework_example.pilotView.PilotViewScene;
class Mock2ReadyPilotView extends PilotViewScene implements Mock2ReadyViewOrder
{
	/* 表示レイヤー */
	private var uiLayer:Sprite;
	private var bgLayer:Sprite;
	/* デモUIコンテナ */
	private var uiContainer:MinimalcompsGipoContainer;
	
	/* フレーム進行を表示するラベル */
	private var syncLabel:com.bit101.components.Label;
	/* フレーム進に依存しないアップデートを表示するラベル */
	private var asyncLabel:com.bit101.components.Label;
	
	/* フレームカウント */
	private var syncCount:Int = 0;
	/* 仮想準備カウント */
	private var asyncCount:Int = 0;
	/* 仮想準備に必要な最大数 */
	private var asyncCountMax:Int = 0;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
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
		uiContainer.addLabel("開発テスト画面2準備...");
		// カウンターの表示
		syncLabel = uiContainer.addLabel("syncLabel");
		asyncLabel = uiContainer.addLabel("asyncLabel");
		
		// 仮想的なViewの準備をするために、ランダムで待ちフレームを決める
		asyncCountMax = 30 + Math.floor(Math.random() * 30 * 5);
		
		drawSyncLabel();
		drawAsyncLabel();
	}
	
	@:handler(PilotViewSceneDispatcherKind.AsyncUpdate)
	private function asyncUpdate():Void
	{
		asyncCount++;
		drawAsyncLabel();
		if (asyncCountMax == asyncCount)
		{
			// 仮想的なロードが終わったらそれを通知する。
			// イベントの要因Posについては、このシーンに切り替わったことが要因になるため、シーン変更の要因位置をそのまま流用する。
			hook.viewReadyInput(Mock2ReadyInput.CompleteReady, factorPos);
		}
	}
	
	@:handler(PilotViewSceneDispatcherKind.Update)
	private function update():Void
	{
		syncCount++;
		drawSyncLabel();
	}
	
	/* フレーム数を表示 */
	private function drawSyncLabel():Void
	{
		syncLabel.text = 'sync $syncCount';
	}
	
	/* 読み込み率を表示 */
	private function drawAsyncLabel():Void
	{
		asyncLabel.text = 'async $asyncCount / $asyncCountMax = ${Math.floor(asyncCount / asyncCountMax * 100)}%';
	}
	
	
}
