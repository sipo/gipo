package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolderImpl;
class OperationHook extends GearHolderImpl
{	
	@:absorb
	private var logic:OperationLogic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	
	/**
	 * 入力処理の発生
	 */
	public function input(event:OperationHookEvent):Void
	{
		logic.noticeEvent(event);
	}
}
/**
 * OperationLogic向けのイベント定義
 */
enum OperationHookEvent
{
	LocalSave;
	LocalLoad;
}
