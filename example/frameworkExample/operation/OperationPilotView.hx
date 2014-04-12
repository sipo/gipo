package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.core.ViewToLogicInput.ViewToLogicOperationInput;
import frameworkExample.core.Hook.ViewToHook;
import haxe.ds.Option;
import frameworkExample.pilotView.PilotView.PilotViewDiffuseKey;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import frameworkExample.operation.Operation;
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
		switch(command)
		{
			case OperationToViewOrder.ChangeMode(mode) : changeMode(mode);
			case OperationToViewOrder.AddReproduseLog(parcelString) : throw "未対応";
		}
		
	}
	private function changeMode(mode:OperationViewMode):Void
	{
		switch(mode)
		{
			case OperationViewMode.SmallButton : changeState(new SmallButtonScene());
			case OperationViewMode.NormalPanel : changeState(new NormalPanelScene());
			case OperationViewMode.None : throw "未対応";
		}
	}
}
/** シーン状態の基本 */
private class OperationPilotViewScene extends StateGearHolderImpl
{
	private var layer:Sprite;
	/* 共通インスタンス */
	private var hook:ViewToHook;
	
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
		//
		hook = gear.absorb(ViewToHook);
	}
}
/** ミニボタンの表示画面 */
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
		hook.viewOperationInput(ViewToLogicOperationInput.OperationOpen);
	}
}
/** メニュー表示画面 */
private class NormalPanelScene extends OperationPilotViewScene
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
		uiContainer.addPushButton("Minimize", minimizeButton_click);
		uiContainer.addPushButton("SaveLog", saveLogButton_click);
		uiContainer.addPushButton("LoadLog", loadLogButton_click);
		uiContainer.addBackground(0x000000, 0.5);
	}
	
	/* 最小化ボタンをクリック */
	private function minimizeButton_click():Void
	{
		hook.viewOperationInput(ViewToLogicOperationInput.OperationMinimize);
	}
	/* 保存ボタンをクリック */
	private function saveLogButton_click():Void
	{
		hook.viewOperationInput(ViewToLogicOperationInput.Save);
	}
	/* 読み込みボタンをクリック */
	private function loadLogButton_click():Void
	{
		hook.viewOperationInput(ViewToLogicOperationInput.Load);
	}
}
