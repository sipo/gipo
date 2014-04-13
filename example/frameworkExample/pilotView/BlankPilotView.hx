package frameworkExample.pilotView;
/**
 * 特に表示のない場合
 * 
 * @auther sipo
 */
import frameworkExample.scene.mock0.Mock0.Mock0Input;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import frameworkExample.pilotView.PilotViewScene;
/* ================================================================
 * 動作
 * ===============================================================*/
class BlankPilotView extends PilotViewScene implements BlankViewOrder
{
	/* 表示レイヤー */
	private var bgLayer:Sprite;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// UIの配置準備
		bgLayer = new Sprite();
		layer.addChild(bgLayer);
		gear.disposeTask(function () layer.removeChild(bgLayer));
		
	}
}
interface BlankViewOrder
{
}
