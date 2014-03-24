package frameworkExample.pilotView;
/**
 * 
 * 
 * @auther sipo
 */
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
	private var hook:Hook;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(sceneRun);
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		// 基礎インスタンスの取得
		layer = gear.absorbWithEnum(PilotViewDiffuseKey.ViewLayer);
		hook = gear.absorb(Hook);
	}
	
	/**
	 * ドラッグなどの入力状態の更新
	 */
	public function inputUpdate():Void
	{
		// template
	}
	
	/**
	 * 情報やカウンタの更新
	 */
	public function update():Void
	{
		// template
	}
	
	/**
	 * 表示の更新（特に、必須ではない重い処理に使用する）
	 */
	public function draw():Void
	{
		// template
	}
	
	
	/**
	 * 表示依頼（この関数は継承せず、setOrderHandlerで対応する）
	 */
	inline public function sceneOrder(command:EnumValue):Void
	{
		orderHandlerContainer.call(command);
	}
	
	
}
