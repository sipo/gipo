package frameworkExample.pilotView;
/**
 * PilotViewのシーンごとの定義
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.handler.GearDispatcher;
import frameworkExample.context.LogicToView.ViewSceneOrder;
import frameworkExample.pilotView.PilotView.PilotViewDiffuseKey;
import frameworkExample.context.View;
import frameworkExample.context.Hook.ViewToHook;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.handler.AddBehaviorPreset;
import flash.display.Sprite;
class PilotViewScene extends StateGearHolderImpl implements ViewSceneOrder
{
	@:absorbWithKey(PilotViewDiffuseKey.GameLayer)
	private var layer:Sprite;
	@:absorb
	private var hook:ViewToHook;
	/** Sceneの共通ハンドラを切り出しする */
	public var sceneHandler(default, null):PilotViewSceneHandlerContainer = new PilotViewSceneHandlerContainer();
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
}
class PilotViewSceneHandlerContainer
{
	/** ドラッグなどの入力状態の更新 */
	public var update(default, null):GearDispatcherImpl;
	/** 情報やカウンタの更新 */
	public var inputUpdate(default, null):GearDispatcherImpl;
	/** 表示の更新（特に、必須ではない重い処理に使用する） */
	public var draw(default, null):GearDispatcherImpl;
	
	
	/** コンストラクタ */
	public function new() 
	{
		update = new GearDispatcherImpl(AddBehaviorPreset.addTail, false);
		inputUpdate = new GearDispatcherImpl(AddBehaviorPreset.addTail, false);
		draw = new GearDispatcherImpl(AddBehaviorPreset.addTail, false);
	}
}

