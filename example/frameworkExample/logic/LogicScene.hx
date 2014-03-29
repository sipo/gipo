package frameworkExample.logic;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicScene.LogicSceneHandlerContainer;
import jp.sipo.gipo.core.config.AddBehaviorPreset;
import jp.sipo.gipo.util.TaskList;
import jp.sipo.gipo.util.EnumKeyHandlerContainer;
import frameworkExample.core.View;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene extends StateGearHolderImpl
{
	/* シーンごとのviewInputの受け取り処理 */
	private var viewInputHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/* 共通インスタンス */
	private var view:View;
	private var logic:Logic;
	/** Sceneの共通ハンドラを切り出しする */
	public var sceneHandler(default, null):LogicSceneHandlerContainer;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		sceneHandler = new LogicSceneHandlerContainer();
		gear.addRunHandler(sceneRun);
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		view = gear.absorb(View);
		logic = gear.absorb(Logic);
	}
	
	/**
	 * Viewからの入力
	 */
	inline public function sceneViewInput(command:EnumValue):Void
	{
		viewInputHandlerContainer.call(command);
	}
}
class LogicSceneHandlerContainer
{
	public var update(default, null):TaskList;
	
	/** コンストラクタ */
	public function new() 
	{
		update = new TaskList(AddBehaviorPreset.addTail, false);
	}
}
