package jp.sipo.gipo.core.state;
/**
 * stateを型変換する機能まで備えたGearStateSwitcherHolder
 * 
 * @auther sipo
 */
class StateSwitcherGearHolderImpl<TState> extends StateSwitcherGearHolderLowLevelImpl
{
	/** シーン */
	public var scene(default, null):TState;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		stateSwitcherGear.addStateAssignmentHandler(stateAssignment);
	}
	
	/**
	 * Stateの切り替え
	 */
	public function changeState(nextState:TState):Void
	{
		stateSwitcherGear.changeState(cast(nextState, StateGearHolder));
	}
	
	/**
	 * Stateの型変換
	 */
	inline private function stateAssignment(scene:StateGearHolder):Void
	{
		this.scene = cast(scene);
	}
}
