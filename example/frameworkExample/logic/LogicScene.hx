package frameworkExample.logic;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import frameworkExample.core.View;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene extends StateGearHolderImpl
{
	/* 共通インスタンス */
	private var view:View;
	private var logic:Logic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(sceneRun);
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		view = gear.absorb(View);
		logic = gear.absorb(Logic);
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		
	}
}
