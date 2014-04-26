package frameworkExample.context;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import frameworkExample.context.LogicToView;
import jp.sipo.gipo.core.config.AddBehaviorPreset;
import jp.sipo.gipo.util.TaskList;
import jp.sipo.gipo.util.EnumKeyHandlerContainer;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene extends StateGearHolderImpl
{
	@:absorb
	private var logic:Logic;
	/* シーンごとのviewInputの受け取り処理 */
	private var viewInputHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/** updateイベント受け取り */
	public var updateHandlerList(default, null):TaskList = new TaskList(AddBehaviorPreset.addTail, false);
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/* 表示ViewSceneを変更をする。返ってきた値は、ViewSceneであり、各ScenOrderにcastして使う */
	private function changeViewScene(viewSceneKind:ViewSceneKind):ViewSceneOrder
	{
		var view:LogicToView = gear.absorb(LogicToView);
		return view.changeScene(viewSceneKind);
	}
	
	/**
	 * 入力などのイベント
	 */
	inline public function noticeEvent(command:EnumValue):Void
	{
		viewInputHandlerContainer.call(command);
	}
	
	/**
	 * 更新処理
	 */
	public function sceneUpdate():Void
	{
		updateHandlerList.execute();
	}
}
