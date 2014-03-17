package jp.sipo.gipo.core.state;
/**
 * stateを型変換する機能まで備えたGearStateSwitcherHolder
 * 
 * @auther sipo
 */
class GenericStateSwitcherGearHolder<TState> extends StateSwitcherGearHolderImpl
{
	/** シーン */
	public var scene(default, null):TState;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gearStateSwitcher.entryHandlerStateAssignment(stateAssignment);
	}
	
	/**
	 * Stateの切り替え
	 */
	public function changeState(nextState:TState):Void
	{
		gearStateSwitcher.changeState(cast(nextState, StateGearHolder));
	}
	
	/**
	 * Stateの型変換
	 */
	inline private function stateAssignment(scene:StateGearHolder):Void
	{
		this.scene = cast(scene);
	}
}
