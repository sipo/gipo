package frameworkExample.logic;
/**
 * 中央管理クラス
 * MVCのMにあたる
 * Modelという名称は不適切だと思われるので、より実態を示すLogicと呼ぶ。
 * 処理を管理し、Stateを持ち、フレームの速度を調節する。
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicInitialize;
import frameworkExample.logic.LogicScene;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
class Logic extends StateSwitcherGearHolderImpl<LogicScene>
{
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * ゲーム開始
	 */
	public function start():Void
	{
		// 初期シーン
		stateSwitcherGear.changeState(new LogicInitialize());
	}

	/**
	 * Viewからの入力
	 */
	public function viewInput(command:ViewLogicInput):Void
	{
	}
	
	/**
	 * Viewからの準備完了通知
	 */
	public function viewReady(command:ViewLogicReady):Void
	{
	}
}
