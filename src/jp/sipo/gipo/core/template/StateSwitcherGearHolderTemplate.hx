package jp.sipo.gipo.core.template;
import jp.sipo.gipo.core.state.StateGearHolder;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderLowLevelImpl;
class TmpState extends StateGearHolderImpl
{
	/** コンストラクタ */
	public function new() { super(); }
}
class StateSwitcherGearHolderTemplate extends StateSwitcherGearHolderLowLevelImpl
{
	/* 初期state */
	private var firstState:TmpState;
	/* 現在のstate */
	private var state:TmpState;
	
	/* ================================================================
	 * 初期化
	 * ===============================================================*/
	
	/** コンストラクタ */
	public function new(firstState:TmpState)
	{
		super();
		this.firstState = firstState;
		// 処理登録
		gear.addDiffusibleHandler(initialize);
		gear.addRunHandler(run);
		stateSwitcherGear.addStateAssignmentHandler(stateAssignment);
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
		stateSwitcherGear.changeState(firstState);
	}
	
	/* ================================================================
	 * State切り替え初期化
	 * ===============================================================*/
	
	private function stateAssignment(nextState:StateGearHolder):Void
	{
		state = cast(nextState);
	}
	
	/* ================================================================
	 * 固有処理
	 * ===============================================================*/
}
