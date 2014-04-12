package frameworkExample.operation;
/**
 * Logicのうち、再現性周りの操作など、メタ的な要素を担当する。
 * 再現性時に、再現されない要素なため、扱いには注意
 * 
 * @auther sipo
 */
import frameworkExample.core.ReproduceIo;
import frameworkExample.core.ViewToLogicInput.ViewToLogicOperationInput;
import frameworkExample.logic.LogicToViewOrder;
import frameworkExample.core.View;
import jp.sipo.gipo.core.GearHolderImpl;
class Operation extends GearHolderImpl
{
	/* Operationの表示状態 */
	private var display:Bool;
	/* absorb */
	private var view:View;
	private var reproduceIo:ReproduceIo;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		view = gear.absorb(View);
		reproduceIo = gear.absorb(ReproduceIo);
		// 表示の依頼
		changeModeOrder(OperationViewMode.SmallButton);
	}
	
	/**
	 * Viewからの準備完了通知
	 */
	public function viewOperationInput(command:ViewToLogicOperationInput):Void
	{
		switch(command)
		{
			case ViewToLogicOperationInput.OperationOpen : changeModeOrder(OperationViewMode.NormalPanel);
			case ViewToLogicOperationInput.OperationMinimize : changeModeOrder(OperationViewMode.SmallButton);
			case ViewToLogicOperationInput.Save : save();
			case ViewToLogicOperationInput.Load : load();
		}
	}
	
	/* Operationの表示切り替え */
	private function changeModeOrder(mode:OperationViewMode):Void
	{
		view.order(LogicToViewOrder.Operation(OperationToViewOrder.ChangeMode(mode)));
	}
	
	/* 保存 */
	private function save():Void
	{
		var tmp:String = "test";	// FIXME:でーたを保存
		reproduceIo.save(tmp);
	}
	
	/* 読み込み */
	private function load():Void
	{
		reproduceIo.load();
	}
}
/** Viewの命令種類 */
enum OperationToViewOrder
{
	/** 表示状態の切り替え */
	ChangeMode(mode:OperationViewMode);
	/** 再現ログの追加 */
	AddReproduseLog(parcelString:String);
}
enum OperationViewMode
{
	/** 表示なし */
	None;
	/** 表示切り替えボタンを表示 */
	SmallButton;
	/** 通常オペレーションを表示 */
	NormalPanel;
}
/** IO周りからのイベント */
enum OperationServiceEvent
{
	/** データの読み込み完了 */
	Load(value:String);
}
