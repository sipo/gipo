package jp.sipo.gipo_framework_example.pilotView;
/**
 * 特に表示のない場合
 * 
 * @auther sipo
 */
import flash.display.Sprite;
import jp.sipo.gipo_framework_example.pilotView.PilotViewScene;
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
	
	/* gearHandler */
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
