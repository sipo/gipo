package jp.sipo.gipo.core.handler;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.util.SipoError;
import haxe.PosInfos;
class GenericGearDispatcher<TFunc>
{
	/* 実保存 */
	private var list:Array<GearDispatcherHandler<TFunc>>;
	/* 追加時の挙動挙動 */
	private var addBehavior:GearDispatcherAddBehavior<TFunc>;
	/* 実行が入れ子にならないようにロックする */
	private var executeLock:Bool;
	/* 一度限りで消去するかどうか */
	private var once:Bool;
	/* 実行時の挙動 */
	private var executeFunc:GearDispatcherHandler<TFunc> -> Void;
	/* 定義位置 */
	private var dispatcherPos:PosInfos;
	
	public function new(addBehavior:GearDispatcherAddBehavior<TFunc>, once:Bool, ?dispatcherPos:PosInfos)
	{
		this.addBehavior = addBehavior;
		this.once = once;
		this.dispatcherPos = dispatcherPos;
		
		executeLock = false;
		clear();
	}
	/* 初期化処理 */
	private function clear():Void
	{
		list = new Array<GearDispatcherHandler<TFunc>>();
	}
	
	/**
	 * ハンドラを追加する
	 */
	inline public function add(func:TFunc, ?addPos:PosInfos):CancelKey
	{
		var handler:GearDispatcherHandler<TFunc> = new GearDispatcherHandler<TFunc>(func, addPos);
		addBehavior(list, handler);
		return handler;
	}
	
	/**
	 * ハンドラを削除する
	 */
	public function remove(key:CancelKey):Void
	{
		// 実行ロックのチェック
		if (executeLock) throw new SipoError("実行最中の削除はできません");
		list.remove(cast(key));
	}
	
	/**
	 * 登録されたハンドラを実行する
	 */
	inline public function execute(treat:GearDispatcherHandler<TFunc> -> Void, ?executePos:PosInfos):Void
	{
		// 実行ロックのチェック
		if (executeLock) throw new SipoError("実行関数が入れ子になっています");
		executeLock = true;
		var tmpHandlerList:Array<GearDispatcherHandler<TFunc>> = list;	// 変数を退避
		// 先に初期化
		if (once) clear();
		// 実行
		for (i in 0...tmpHandlerList.length)// 配列の頭から実行
		{
			treat(tmpHandlerList[i]);
		}
		tmpHandlerList = null;
		executeLock = false;
	}
}
