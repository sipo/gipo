package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import com.bit101.components.Label;
import com.bit101.components.ComboBox;
import frameworkExample.operation.OperationHook.OperationHookEvent;
import flash.display.Sprite;
import jp.sipo.wrapper.MinimalcompsGipoContainer;
import jp.sipo.gipo.core.GearHolderImpl;
class OperationOverView extends GearHolderImpl implements OperationView
{
	
	@:absorb
	private var hook:OperationHook;
	/* 表示Sprite */
	private var minimalizeUiLayer:Sprite;
	private var openUiLayer:Sprite;
	/* UI表示 */
	private var minimalizeUiContainer:MinimalcompsGipoContainer;
	private var openUiContainer:MinimalcompsGipoContainer;
	/* 記録数表示 */
	private var logCounter:Label;
	/* 再生位置指定 */
	private var comboBox:ComboBox;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
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
	
	@:handler(GearDispatcherKind.Run)
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
		logCounter = openUiContainer.addLabel("none");
		openUiContainer.addPushButton("SaveLog", saveLogButton_click);
		openUiContainer.addPushButton("LoadLog", loadLogButton_click);
		comboBox = openUiContainer.addComboBox([], comboBox_select);
		openUiContainer.addBackground(0x888888, 0.5);
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
	
	
	/** 再現ログの更新 */
	public function updateLog(logcount:Int):Void
	{
		logCounter.text = Std.string(logcount);
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
	/* 読み込みファイルを選択 */
	private function comboBox_select(index:Int):Void
	{
		trace(index);
	}
}
private enum Mode
{
	Minimize;
	Open;
}
