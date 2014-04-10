package frameworkExample.operation;
/**
 * Logicのうち、再現性周りの操作など、メタ的な要素を担当する。
 * 再現性時に、再現されない要素なため、扱いには注意
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicToViewOrder;
import frameworkExample.core.View;
import jp.sipo.gipo.core.GearHolderImpl;
class Operation extends GearHolderImpl
{
	/* Operationの表示状態 */
	private var display:Bool;
	/* absorb */
	private var view:View;
	
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
		// 表示の依頼
		view.order(LogicToViewOrder.Operation(OperationToViewOrder.ChangeMode(OperationViewMode.SmallButton)));
	}
}
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
