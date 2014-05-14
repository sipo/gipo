package jp.sipo.gipo.core.handler;
/**
 * 自動登録可能なDispatcher
 * 
 * @auther sipo
 */
import haxe.PosInfos;
interface AutoHandlerDispatcher
{
	public function autoAdd(func:Dynamic, ?pos:PosInfos):Void;
}
