package jp.sipo.gipo.core.state;
/**
 * stateを型変換する機能まで備えたGearStateSwitcherHolder
 * 
 * @auther sipo
 */
import haxe.PosInfos;
class StateSwitcherGearHolderImpl<TState/*:StateGearHolder*/> extends StateSwitcherGearHolderLowLevelImpl
{
	/** State */
	public var state(default, null):TState;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		stateSwitcherGear.addStateAssignmentHandler(stateAssignment);
	}
	
	/**
	 * Stateの切り替え
	 */
	public function changeState(nextState:TState, ?pos:PosInfos):Void
	{
		stateSwitcherGear.changeState(cast(nextState, StateGearHolder), pos);
	}
	
	/**
	 * Stateの型変換
	 */
	inline private function stateAssignment(state:StateGearHolder):Void
	{
		this.state = cast(state);
	}
}
