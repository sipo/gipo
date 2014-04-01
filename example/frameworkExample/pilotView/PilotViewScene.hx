package frameworkExample.pilotView;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.config.AddBehaviorPreset;
import jp.sipo.gipo.util.TaskList;
import frameworkExample.core.Hook;
import jp.sipo.gipo.util.EnumKeyHandlerContainer;
import frameworkExample.pilotView.PilotView.PilotViewDiffuseKey;
import flash.display.Sprite;
import jp.sipo.util.SipoError;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class PilotViewScene extends StateGearHolderImpl
{
	/* シーンごとのorderの受け取り処理 */
	private var orderHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/* 共通インスタンス */
	private var layer:Sprite;
	private var hook:ViewHook;
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
		layer = gear.absorbWithEnum(PilotViewDiffuseKey.ViewLayer);
		hook = gear.absorb(ViewHook);
	}
	
	
	/**
	 * 表示依頼（この関数は継承せず、setOrderHandlerで対応する）
	 */
	inline public function sceneOrder(command:EnumValue):Void
	{
		orderHandlerContainer.call(command);
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
