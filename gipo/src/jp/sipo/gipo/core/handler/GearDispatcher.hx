package jp.sipo.gipo.core.handler;
import jp.sipo.gipo.core.handler.GenericGearDispatcher;
import haxe.PosInfos;
/**
 * 関数処理を保持し、実行する
 * Gearと組み合わさることで、メタデータによる自動追加機能を持つ。
 * 実行関数は登録時に決定され、主に同一クラス内での遅延処理や待機処理、処理順序の入れ替えなどに使用する
 * コード上、実行される関数が隠蔽されやすいのでクラスをまたいだ使用は非推奨
 * 
 * @author sipo
 */
private typedef TFunc = Void -> Void;
class GearDispatcher
{
	/* 移譲先 */
	private var genericGearDispatcher:GenericGearDispatcher<TFunc>;
	
	public function new(addBehavior:GearDispatcherAddBehavior<TFunc>, once:Bool, ?pos:PosInfos)
	{
		genericGearDispatcher = new GenericGearDispatcher<TFunc>(addBehavior, once, pos);
	}
	
	/**
	 * ハンドラを登録する
	 */
	public function add(func:TFunc, ?addPos:PosInfos):CancelKey
	{
		return genericGearDispatcher.add(func, addPos);
	}
	
	/**
	 * ハンドラを削除する
	 */
	public function remove(key:CancelKey):Void
	{
		genericGearDispatcher.remove(key);
	}
	
	/**
	 * 登録されたハンドラを実行する
	 */
	public function execute(?executePos:PosInfos):Void
	{
		genericGearDispatcher.execute(trat, executePos);
	}
	/* 実行処理関数 */
	inline private function trat(handler:GearDispatcherHandler<TFunc>):Void
	{
		handler.func();
	}
}
