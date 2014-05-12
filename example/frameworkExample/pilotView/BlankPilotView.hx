package frameworkExample.pilotView;
/**
 * 特に表示のない場合
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearHandlerKind;
import flash.display.Sprite;
import frameworkExample.pilotView.PilotViewScene;
/* ================================================================
 * 動作
 * ===============================================================*/
class BlankPilotView extends PilotViewScene implements BlankViewOrder
{
	/* 表示レイヤー */
	private var bgLayer:Sprite;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearHandlerKind.Run)
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
