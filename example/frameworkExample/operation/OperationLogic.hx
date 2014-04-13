package frameworkExample.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import frameworkExample.context.Hook.HookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
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
		// TODO:stb
	}
	
	/**
	 * OperationLogicそのものに対するイベント発生
	 */
	public function noticeEvent(event:HookEvent):Void
	{
		// TODO:stb
	}
}
