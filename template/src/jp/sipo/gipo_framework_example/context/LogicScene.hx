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
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		inputRole = new GearRoleDispatcher();
		updateDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, false);
	}
	
	/* 表示ViewSceneを変更をする。返ってきた値は、ViewSceneであり、各ScenOrderにcastして使う */
	private function changeViewScene(viewSceneKind:ViewSceneKind, ?pos:PosInfos):Dynamic
	{
		var view:ViewForLogic = gear.absorb(ViewForLogic);
		return view.changeScene(viewSceneKind, pos);
	}
	
	/**
	 * 入力などのイベント
	 */
	inline public function noticeInput(command:EnumValue):Void
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
