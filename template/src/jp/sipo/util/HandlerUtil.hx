package jp.sipo.util;
/**
 * 
 * 
 * @auther sipo
 */
import flash.events.IEventDispatcher;
class HandlerUtil
{
	/**
	 * 一度のみのハンドラ実行
	 */
	public static function once(dispatcher:IEventDispatcher, type:String, handler:Dynamic -> Void):Void
	{
		var handlerWrapper:Dynamic -> Void = null;
		handlerWrapper = function (event:Dynamic):Void
		{
			dispatcher.removeEventListener(type, handlerWrapper);
			handlerWrapper = null;
			handler(event);
		}
		dispatcher.addEventListener(type, handlerWrapper);
	}
}
