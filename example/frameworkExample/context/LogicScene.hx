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
	/* ViewSceneが切り替えられたかどうか */
	private var isChangeViewScene:Bool = false;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addBubbleHandler(bubble);
	}
	
	/* 表示ViewSceneを変更をする。返ってきた値は、ViewSceneであり、各ScenOrderにcastして使う */
	private function changeViewScene(viewSceneKind:ViewSceneKind):ViewSceneOrder
	{
		isChangeViewScene = true;
		var view:LogicToView = gear.absorb(LogicToView);
		return view.changeScene(viewSceneKind);
	}
	
	/* run後チェック処理 */
	private function bubble():Void
	{
		// runのあと、ちゃんとchangeViewSceneが実行されているかチェックする
		// このチェックは規約的な推奨で、絶対ではない。速度などのために、シーンを切り替えてもViewを切り替えたくなければ削除しても良い。
		// ただし、非常に忘れることの多い部分なので、
		if (!isChangeViewScene) throw '${this}でchangeViewSceneが呼び出されていません。LogicSceneが切り替わった際は必ずchangeViewSceneを呼び出すことを推奨しています。';
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
