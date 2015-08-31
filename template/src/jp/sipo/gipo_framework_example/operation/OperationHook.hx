package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.operation.OperationView;
import jp.sipo.gipo_framework_example.operation.OperationLogic;
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.core.GearHolderImpl;
class OperationHook extends GearHolderImpl implements OperationHookForReproduce implements OperationHookForView
{	
	@:absorb
	private var logic:OperationLogic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	
	/**
	 * Reproduceからのイベント処理
	 */
	public function noticeReproduceEvent(event:ReproduceEvent):Void
	{
		logic.noticeReproduceEvent(event);
	}
	
	
	/**
	 * Viewからのイベント処理
	 */
	public function noticeOperationViewEvent(event:OperationViewEvent):Void
	{
		logic.noticeOperationViewEvent(event);
	}
}
