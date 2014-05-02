package frameworkExample.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import jp.sipo.util.Copy;
import frameworkExample.operation.OperationHook.OperationHookEvent;
import frameworkExample.context.Hook.HookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
interface OperationPeek
{
	
}
class OperationLogic extends GearHolderImpl
{
	@:absorb
	private var operationView:OperationView;
	
	/* 再生ログ */
	private var reproduceLog:Array<HookEvent> = new Array<HookEvent>();
	
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * イベントを記録する
	 */
	public function record(event:HookEvent):Void
	{
		reproduceLog.push(Copy.deep(event));	// 速度を上げるためには場合分けしてもいい
		operationView.updateLog(reproduceLog.length);
	}
	
	/**
	 * OperationLogicそのものに対するイベント発生
	 */
	public function noticeEvent(event:OperationHookEvent):Void
	{
		trace('stb OperationLogic noticeEvent($event)');
		switch (event)
		{
			case OperationHookEvent.LocalSave : // TODO:ローカル保存処理
			case OperationHookEvent.LocalLoad :  // TODO:ローカル読み込み処理
		}
	}
}
