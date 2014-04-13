package frameworkExample.pilotView;
/**
 * PilotViewのシーンごとの定義
 * 
 * @auther sipo
 */
import frameworkExample.context.LogicToView.LogicToViewScene;
import frameworkExample.pilotView.PilotView.PilotViewDiffuseKey;
import frameworkExample.context.View;
import frameworkExample.context.Hook.ViewToHook;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.config.AddBehaviorPreset;
import jp.sipo.gipo.util.TaskList;
import flash.display.Sprite;
class PilotViewScene extends StateGearHolderImpl implements LogicToViewScene
{
	/* 共通インスタンス */
	private var layer:Sprite;
	private var hook:ViewToHook;
	/** Sceneの共通ハンドラを切り出しする */
	public var sceneHandler(default, null):PilotViewSceneHandlerContainer;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		sceneHandler = new PilotViewSceneHandlerContainer();
		gear.addRunHandler(sceneRun);
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		// 基礎インスタンスの取得
		layer = gear.absorbWithEnum(PilotViewDiffuseKey.GameLayer);
		hook = gear.absorb(ViewToHook);
	}
}
class PilotViewSceneHandlerContainer
{
	/** ドラッグなどの入力状態の更新 */
	public var update(default, null):TaskList;
	/** 情報やカウンタの更新 */
	public var inputUpdate(default, null):TaskList;
	/** 表示の更新（特に、必須ではない重い処理に使用する） */
	public var draw(default, null):TaskList;
	
	
	/** コンストラクタ */
	public function new() 
	{
		update = new TaskList(AddBehaviorPreset.addTail, false);
		inputUpdate = new TaskList(AddBehaviorPreset.addTail, false);
		draw = new TaskList(AddBehaviorPreset.addTail, false);
	}
}

