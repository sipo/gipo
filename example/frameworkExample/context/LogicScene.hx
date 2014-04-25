package frameworkExample.context;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import jp.sipo.util.Once;
import haxe.ds.Option;
import frameworkExample.context.LogicToView.ViewSceneKind;
import jp.sipo.gipo.core.config.AddBehaviorPreset;
import jp.sipo.gipo.util.TaskList;
import frameworkExample.context.Hook.HookEvent;
import jp.sipo.gipo.util.EnumKeyHandlerContainer;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene<TypeViewSceneOrder> extends StateGearHolderImpl
{
	@:absorb
	private var logic:Logic;
	@:absorb
	private var view:LogicToView;
	/* シーンの種類を示すenum */
	private var viewSceneKind:ViewSceneKind;
	/* シーンごとのviewInputの受け取り処理 */
	private var viewInputHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/* viewSceneへの参照 */
	private var viewScene:TypeViewSceneOrder;
	/** updateイベント受け取り */
	public var updateHandlerList(default, null):TaskList = new TaskList(AddBehaviorPreset.addTail, false);
	
	/** コンストラクタ */
	public function new(viewSceneKind:ViewSceneKind) 
	{
		super();
		gear.addRunHandler(sceneRun);
		// 表示ViewSceneの設定
		this.viewSceneKind = viewSceneKind;
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		viewScene = cast(view.changeScene(viewSceneKind));
	}
	
	/**
	 * 入力
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
