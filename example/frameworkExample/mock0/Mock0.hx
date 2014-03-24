package frameworkExample.mock0;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicViewOrder;
import jp.sipo.gipo.core.GearDiffuseTool;
import frameworkExample.logic.LogicScene;
class Mock0 extends LogicScene
{
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addDiffusibleHandler(initialize);
		gear.addRunHandler(run);
	}
	
	/* 初期化処理 */
	private function initialize(tool:GearDiffuseTool):Void
	{
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		view.order(LogicViewOrder.ChangeScene(LogicViewOrderScene.Mock0));
	}
}
