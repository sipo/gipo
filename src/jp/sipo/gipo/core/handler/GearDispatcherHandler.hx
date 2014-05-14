package jp.sipo.gipo.core.handler;
/**
 * GearDispatcher用の関数を呼び出し位置を同時に保持する
 * 
 * @auther sipo
 */
import haxe.PosInfos;
class GearDispatcherHandler<TFunc>
{
	public var func:TFunc;
	public var addPos:PosInfos;
	
	public function new(func:TFunc, addPos:PosInfos)
	{
		this.func = func;
		this.addPos = addPos;
	}
	
	public function toString():String
	{
		return '[Handler ${addPos} ${func}]';
	}
}
