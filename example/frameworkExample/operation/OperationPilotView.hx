package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import haxe.ds.Option;
import frameworkExample.pilotView.PilotView.PilotViewDiffuseKey;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import frameworkExample.operation.Operation.OperationToViewOrder;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolderImpl;
class OperationPilotView extends StateSwitcherGearHolderImpl<OperationPilotViewScene>
{
	/* 表示レイヤー */
	private var layer:Sprite;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * 命令処理
	 */
	public function order(command:OperationToViewOrder):Void
	{
		changeState(new SmallButtonScene());
	}
}
/** シーン状態の基本 */
private class OperationPilotViewScene extends StateGearHolderImpl
{
	/* 表示レイヤー */
	private var layer:Sprite;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(sceneRun);
	}
	
	/* 初期化 */
	private function sceneRun():Void
	{
		var parentLayer:Sprite = gear.absorbWithEnum(PilotViewDiffuseKey.OperationLayer);
		layer = new Sprite();
		parentLayer.addChild(layer);
		gear.disposeTask(function () parentLayer.removeChild(layer));
	}
}
/** ミニボタンの表示 */
private class SmallButtonScene extends OperationPilotViewScene
{
	/* UI表示 */
	private var uiContainer:MinimalcompsGipoContainer;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/* 初期化 */
	private function run():Void
	{
		var uiContainerConfig:Config = MinimalcompsGipoContainer.getDefaultConfig().clone();
		uiContainerConfig.alignH = AlignH.Right;
		uiContainer = new MinimalcompsGipoContainer(layer, uiContainerConfig);
		gear.addChild(uiContainer);
		// 表示設置
		// ボタンの設置
		uiContainer.addPushButton("Operation", operationButton_click);
	}
	
	/* Operation表示ボタンをクリック */
	private function operationButton_click():Void
	{
		trace("ok");
	}
}
