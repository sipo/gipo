package frameworkExample.context;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.handler.GearDispatcher.GearDispatcherImpl;
import frameworkExample.context.LogicToView;
import jp.sipo.gipo.core.handler.AddBehaviorPreset;
import jp.sipo.gipo.util.EnumKeyHandlerContainer;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene extends StateGearHolderImpl
{
	@:absorb
	private var logic:Logic;
	/* シーンごとのviewInputの受け取り処理 */
	private var viewInputHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/** updateイベント受け取り */
	public var updateHandlerList(default, null):GearDispatcherImpl = new GearDispatcherImpl(AddBehaviorPreset.addTail, false);
	/* ViewSceneが切り替えられたかどうか */
	private var isChangeViewScene:Bool = false;
	
	/** コンストラクタ */
	public function new() { super();}
	
	/* 表示ViewSceneを変更をする。返ってきた値は、ViewSceneであり、各ScenOrderにcastして使う */
	private function changeViewScene(viewSceneKind:ViewSceneKind, type:Class<Dynamic>):Dynamic
	{
		isChangeViewScene = true;
		var view:LogicToView = gear.absorb(LogicToView);
		var viewScene:ViewSceneOrder = view.changeScene(viewSceneKind);
		if (!Std.is(viewScene, type)) throw 'Viewのシーン変更時に指定された型（${type}}）と、返ってきたインスタンス（${viewScene}）の型が合いません。imprementsの忘れや、引数の間違いが無いか確認して下さい。';
		return viewScene;
	}
	
	/* run後チェック処理 */
	@:handler(GearDispatcherKind.Bubble)
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
