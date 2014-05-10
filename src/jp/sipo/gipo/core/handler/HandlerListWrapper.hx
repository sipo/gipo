package jp.sipo.gipo.core.handler;
/**
 * ハンドラの登録と実行を管理する
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.core.handler.HandlerList;
class HandlerListWrapper<ArgumentsHandler> extends HandlerList
{
	/* 関数起動時に使用する特殊処理 */
	private var wrapFunc:ArgumentsHandler -> Void;
	
	/** コンストラクタ */
	public function new(addBehavior:AddBehavior, once:Bool, wrapFunc:ArgumentsHandler -> Void) 
	{
		super(addBehavior, once);
		this.wrapFunc = wrapFunc;
	}
	
	/**
	 * 引数ありのハンドラの追加
	 */
	public function addWithArguments(func:ArgumentsHandler, ?pos:PosInfos):Void
	{
		add(function () wrapFunc(func), pos);
	}
}
