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
	@absorb
	private var logic:Logic;
	@absorb
	private var view:LogicToView;
	/* シーンごとのviewInputの受け取り処理 */
	private var viewInputHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/* Sceneのハンドラを登録可能にする */
	private var sceneGear(default, null):LogicSceneGear;
	/* viewSceneへの参照 */
	private var viewScene:TypeViewSceneOrder;
	
	/** コンストラクタ */
	public function new(sceneKind:ViewSceneKind) 
	{
		super();
		sceneGear = new LogicSceneGear();
		gear.addRunHandler(sceneRun);
		// 表示ViewSceneの設定
		sceneGear.setGetViewKindHandler(sceneKind);
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		viewScene = cast(view.changeScene(sceneGear.getViewKind()));
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
		sceneGear.updateTaskList.execute();
	}
}
/**
 * Sceneの共通処理の管理
 * 
 * @auther sipo
 */
class LogicSceneGear
{
	/* --------------------------------
	 * イベントの登録受付
	 * -------------------------------*/
	
	/** updateイベント受け取り */
	public var updateTaskList(default, null):TaskList = new TaskList(AddBehaviorPreset.addTail, false);
	
	/* --------------------------------
	 * Sceneへ値を渡す関数
	 * -------------------------------*/
	
	/** 使用するViewSceneの指定 */
	private var sceneKind:Once<ViewSceneKind> = Once.Before;
	
	/** コンストラクタ */
	public function new() 
	{
	}
	
	/**
	 * 使用するViewSceneの指定
	 */
	public function setGetViewKindHandler(sceneKind:ViewSceneKind):Void
	{
		this.sceneKind = Once.Some(sceneKind);
	}
	
	/**
	 * ViewSceneの受け取り
	 */
	public function getViewKind():ViewSceneKind
	{
		switch (sceneKind)
		{
			case Once.Before : 
				throw 'ViewKindが設定されていません';
			case Once.Some(value) : 
				sceneKind = Once.After;
				return value; 
			case Once.After : 
				throw 'ViewKindが既に使用されています。';
		}
	}
	
	
}
