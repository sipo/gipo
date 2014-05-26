package jp.sipo.gipo.util;
/**
 * イベント登録と解除を持ち、それを管理する
 * Gearにmixinして使用
 * 
 * @author sipo
 */
import jp.sipo.gipo.core.GearOutside;
import flash.events.ProgressEvent;
import flash.display.LoaderInfo;
import jp.sipo.gipo.core.GearHolderLow;
import flash.events.SecurityErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.ErrorEvent;
import jp.sipo.gipo.core.Gear;
import haxe.PosInfos;
import flash.display.Loader;
import flash.events.Event;
import flash.events.IEventDispatcher;
class EventManager
{
	
	/**
	 * Loaderのイベント登録をする
	 * 消去安全
	 * 
	 * @gearDispose
	 */
	static inline public function addLoaderEvent(gearHolder:GearHolderLow, loader:Loader, handlerContext:LoaderHandlerContext, ?pos:PosInfos):Void
	{
		var gear:GearOutside = gearHolder.gearOutside();
		var contentLoaderInfo:LoaderInfo = loader.contentLoaderInfo;
		// 
		if (handlerContext.completeHandler != null){
			contentLoaderInfo.addEventListener(Event.COMPLETE, handlerContext.completeHandler);
			gear.disposeTask(function () contentLoaderInfo.removeEventListener(Event.COMPLETE, handlerContext.completeHandler));
		}
		//
		if (handlerContext.progressHandler != null){
			contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, handlerContext.progressHandler);
			gear.disposeTask(function () contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, handlerContext.progressHandler));
		}
		//
		var errorHandler:ErrorEvent -> Void = handlerContext.errorHandler;
		if(handlerContext.errorHandler == null){
			errorHandler = function (event:ErrorEvent){ defaultErrorHandler(event, gearHolder, loader, pos);};
		}
		contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
		gear.disposeTask(function () contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler));
		contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
		gear.disposeTask(function () contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler));
		// 消去登録
		gear.disposeTask(function (){
			try{
				loader.close();
			}catch(error:Dynamic){
				// closeが失敗しても無視する
			}
			loader.unload();
		}, pos);
	}
	
	
	/*
	 * とりあえず、Flashのハンドリングなしイベントが発生しないようにする
	 */
	static inline public function defaultErrorHandler(event:ErrorEvent, gearHolder:GearHolderLow, loader:Loader, ?pos:PosInfos):Void
	{
		throw 'event=$event gearHolder=$gearHolder loader=$loader pos=$pos';
	}
	
	/**
	 * Flashの一般イベント登録と消去をする。
	 * イベント登録はミスが多い（removeの代わりにaddしちゃったりとかね）ので、このメソッドを使用する
	 * 消去安全
	 * 
	 * @gearDispose
	 */
	static inline public function addEvent(gearHolder:GearHolderLow, dispatcher:IEventDispatcher, kind:String, handler:Dynamic -> Void, ?pos:PosInfos):Void
	{
		dispatcher.addEventListener(kind, handler);
		// 消去登録
		var gear:GearOutside = gearHolder.gearOutside();
		gear.disposeTask(function (){
			dispatcher.removeEventListener(kind, handler);
		}, pos);
	}
}
typedef LoaderHandlerContext = 
{
	var completeHandler:Event -> Void;
	@:optional var progressHandler:Event -> Void;
	var errorHandler:ErrorEvent -> Void;
}
