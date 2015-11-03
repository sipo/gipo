package jp.sipo.gipo_framework_example.pilotView;
/**
 * PilotViewのシーンごとの定義
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.core.handler.GearDispatcher;
import jp.sipo.gipo_framework_example.context.ViewForLogic.ViewSceneOrder;
import jp.sipo.gipo_framework_example.pilotView.PilotView.PilotViewDiffuseKey;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.handler.AddBehaviorPreset;
import flash.display.Sprite;
class PilotViewScene extends StateGearHolderImpl implements ViewSceneOrder
{
	@:absorbWithKey(PilotViewDiffuseKey.GameLayer)
	private var layer:Sprite;
	@:absorb
	private var input:ViewSceneInput;
	/** フレーム間の更新 */
	public var asyncUpdateDispatcher(default, null):GearDispatcher;
	/** ドラッグなどの入力状態の更新 */
	public var updateDispatcher(default, null):GearDispatcher;
	/** 情報やカウンタの更新 */
	public var inputUpdateDispatcher(default, null):GearDispatcher;
	/** 表示の更新（特に、必須ではない重い処理に使用する） */
	public var drawDispatcher(default, null):GearDispatcher;
	
	/** 呼び出したLogic側のコード位置 */
	public var factorPos(default, null):PosInfos;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		asyncUpdateDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, false);
		updateDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, false);
		inputUpdateDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, false);
		drawDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, false);
	}
	
	/**
	 * 呼び出し原因のコード位置を保存
	 */
	public function setFactorPos(factorPos:PosInfos):Void
	{
		this.factorPos = factorPos;
	}
	
}
