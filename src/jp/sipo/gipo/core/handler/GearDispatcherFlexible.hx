package jp.sipo.gipo.core.handler;
/**
 * 実行時に自由な動作を選べるDispatcher
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.core.handler.GenericGearDispatcher;
class GearDispatcherFlexible<TFunc> extends GenericGearDispatcher<TFunc> implements AutoHandlerDispatcher
{
	public function new(addBehavior:AddBehavior<TFunc>, once:Bool, ?pos:PosInfos)
	{
		super(addBehavior, once, pos);
	}
	
	/**
	 * ハンドラを登録する
	 */
	public function add(func:TFunc, ?addPos:PosInfos):Void
	{
		genericAdd(func, addPos);
	}
	
	/**
	 * 自動登録用
	 */
	public function autoAdd(func:Dynamic, ?addPos:PosInfos):Void
	{
		add(cast(func), addPos);
	}
	
	/**
	 * 登録されたハンドラを実行する
	 */
	public function execute(trat:GearDispatcherHandler<TFunc> -> Void):Void
	{
		genericExecute(trat);
	}
}
