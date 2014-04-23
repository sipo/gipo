package frameworkExample.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import frameworkExample.operation.OperationHook.OperationHookEvent;
import frameworkExample.context.Hook.HookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
interface OperationPeek
{
	
}
class OperationLogic extends GearHolderImpl
{
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
		trace('stb OperationLogic record($event)');
		// TODO:stb
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
