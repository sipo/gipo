package jp.sipo.gipo.core.handler;
import jp.sipo.gipo.core.handler.GenericGearDispatcher;
import haxe.PosInfos;
/**
 * 関数処理を保持し、実行する
 * 実行関数は登録時に決定され、主に同一クラス内での遅延処理や待機処理、処理順序の入れ替えなどに使用する
 * コード上、実行される関数が隠蔽されやすいのでクラスをまたいだ使用は非推奨
 * 
 * @author sipo
 */
private typedef TFunc = Void -> Void;
class GearDispatcher extends GenericGearDispatcher<TFunc> implements AutoHandlerDispatcher
{
	public function new(addBehavior:GearDispatcherAddBehavior<TFunc>, once:Bool, ?pos:PosInfos)
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
	public function execute(?executePos:PosInfos):Void
	{
		genericExecute(trat, executePos);
	}
	/* 実行処理関数 */
	inline private function trat(handler:GearDispatcherHandler<TFunc>):Void
	{
		handler.func();
	}
}
