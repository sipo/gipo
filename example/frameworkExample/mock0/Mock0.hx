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
		// インスタンスの取得
		gear.absorb;
		
		// インスタンスの拡散
		tool.diffuse;
		
		// 子の追加
		tool.bookChild;
		
		// 解除処理
		gear.disposeTask(function (){
			
		});
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		view.order(LogicViewOrder.ChangeScene(LogicViewOrderScene.Mock0));
	}
}
