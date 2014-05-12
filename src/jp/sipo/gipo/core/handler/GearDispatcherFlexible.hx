package jp.sipo.gipo.core.handler;
/**
 * ハンドラの登録と実行を管理する
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.handler.GearDispatcher;
import EnumValue;
import haxe.PosInfos;
class GearDispatcherFlexible<ArgumentsHandler> extends GearDispatcherImpl
{
	/* 関数起動時に使用する特殊処理 */
	private var wrapFunc:ArgumentsHandler -> Void;
	
	/** コンストラクタ */
	public function new(addBehavior:AddBehavior, once:Bool, wrapFunc:ArgumentsHandler -> Void, pos:PosInfos) 
	{
		super(addBehavior, once, pos);
		this.wrapFunc = wrapFunc;
	}
	
	/**
	 * 引数ありのハンドラの追加
	 */
	public function addWithArguments(func:ArgumentsHandler, ?pos:PosInfos):Void
	{
		super.add(function () wrapFunc(func), pos);
	}
	
	
	/**
	 * 外部からのハンドラ追加を禁止
	 */
	override public function add(func:Void -> Void, ?pos:PosInfos):Void
	{
		throw 'GearDispatcherFlexibleへのaddは出来ません。addWithArgumentsを使用してください';
	}
}
