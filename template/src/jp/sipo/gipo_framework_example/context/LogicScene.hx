package jp.sipo.gipo_framework_example.context;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.core.handler.GearRoleDispatcher;
import jp.sipo.gipo.core.handler.GearDispatcher;
import jp.sipo.gipo_framework_example.context.ViewForLogic;
import jp.sipo.gipo.core.handler.AddBehaviorPreset;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene extends StateGearHolderImpl
{
	@:absorb
	private var logic:Logic;
	/* シーンごとのviewInputの受け取り処理 */
	private var inputRole:GearRoleDispatcher;
	/* updateイベント受け取り */
	private var updateDispatcher:GearDispatcher;
	/* ViewSceneが切り替えられたかどうか */
	private var isChangeViewScene:Bool = false;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		inputRole = new GearRoleDispatcher();
		updateDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, false);
		// ハンドラの登録
		gear.addBubbleHandler(bubble);
	}
	
	/* 表示ViewSceneを変更をする。返ってきた値は、ViewSceneであり、各ScenOrderにcastして使う */
	private function changeViewScene(viewSceneKind:ViewSceneKind, ?pos:PosInfos):Dynamic
	{
		isChangeViewScene = true;
		var view:ViewForLogic = gear.absorb(ViewForLogic);
		return view.changeScene(viewSceneKind, pos);
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
		inputRole.execute(command);
	}
	
	/**
	 * 更新処理
	 */
	public function sceneUpdate():Void
	{
		updateDispatcher.execute();
	}
}
/**
 * 入力が無い場合に使用するEnum
 */
enum BlamnkViewInput
{
	
}
