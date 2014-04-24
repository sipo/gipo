package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import frameworkExample.operation.OperationHook.OperationHookEvent;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo.core.GearHolderImpl;
import jp.sipo.gipo.core.GearHolder;
class OperationOverView extends GearHolderImpl implements OperationView
{
	
	@absorb
	private var hook:OperationHook;
	/* 表示Sprite */
	private var minimalizeUiLayer:Sprite;
	private var openUiLayer:Sprite;
	/* UI表示 */
	private var minimalizeUiContainer:MinimalcompsGipoContainer;
	private var openUiContainer:MinimalcompsGipoContainer;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/** 必要データの付与 */
	public function setContext(operationViewLayer:Sprite)
	{
		minimalizeUiLayer = initializeSprite(operationViewLayer);
		openUiLayer = initializeSprite(operationViewLayer);
	}
	private function initializeSprite(parent:Sprite):Sprite
	{
		var sprite:Sprite = new Sprite();
		parent.addChild(sprite);
		gear.disposeTask(function () parent.removeChild(sprite));
		return sprite;
	}
	
	/* 初期化 */
	private function run():Void
	{
		var uiContainerConfig:Config = MinimalcompsGipoContainer.getDefaultConfig().clone();
		uiContainerConfig.alignH = AlignH.Right;
		minimalizeUiContainer = new MinimalcompsGipoContainer(minimalizeUiLayer, uiContainerConfig);
		openUiContainer = new MinimalcompsGipoContainer(openUiLayer, uiContainerConfig);
		gear.addChild(minimalizeUiContainer);
		gear.addChild(openUiContainer);
		// 表示設置
		// ボタンの設置
		minimalizeUiContainer.addPushButton("Operation", operationButton_click);
		
		openUiContainer.addPushButton("-", minimizeButton_click);
		openUiContainer.addPushButton("SaveLog", saveLogButton_click);
		openUiContainer.addPushButton("LoadLog", loadLogButton_click);
		openUiContainer.addBackground(0x000000, 0.5);
		// 初期モード
		changeMode(Mode.Minimize);
	}
	
	/* モードの変更 */
	private function changeMode(mode:Mode):Void
	{
		switch (mode)
		{
			case Mode.Minimize:
				minimalizeUiLayer.visible = true;
				openUiLayer.visible = false;
			case Mode.Open:
				minimalizeUiLayer.visible = false;
				openUiLayer.visible = true;
		}
	}
	
	/* 最小化ボタンをクリック */
	private function operationButton_click():Void
	{
		changeMode(Mode.Open);
	}
	
	/* 最小化ボタンをクリック */
	private function minimizeButton_click():Void
	{
		changeMode(Mode.Minimize);
	}
	
	/* 保存ボタンをクリック */
	private function saveLogButton_click():Void
	{
		hook.input(OperationHookEvent.LocalSave);
	}
	/* 読み込みボタンをクリック */
	private function loadLogButton_click():Void
	{
		hook.input(OperationHookEvent.LocalLoad);
	}
}
private enum Mode
{
	Minimize;
	Open;
}
