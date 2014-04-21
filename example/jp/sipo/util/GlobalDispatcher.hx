package jp.sipo.util;
/**
 * FlashのenterFrameなど、全体に関わるイベント処理をまとめたもの。
 * 今のところフレームだけ、キーやMouseUpなども予定する
 * 
 * @auther sipo
 */
import flash.events.Event;
import jp.sipo.gipo.core.GearHolderImpl;
import flash.display.Sprite;
class GlobalDispatcher extends GearHolderImpl
{
	/* 基礎Sprite */
	private var current:Sprite;
	/* フレームハンドラ */
	private var frameHandlerList:Array<Void -> Void>;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		frameHandlerList = new Array<Void -> Void>();
	}
	
	/**
	 * Flash用の初期設定
	 */
	public function setFlashContext(current:Sprite):Void
	{
		this.current = current;
		current.addEventListener(Event.ENTER_FRAME, frame);
		gear.disposeTask(function (){
			current.removeEventListener(Event.ENTER_FRAME, frame);
			this.current = null;
		});
	}
	
	/**
	 * フレーム動作用のハンドラを登録
	 */
	public function addFrameHandler(handler:Void -> Void):Void
	{
		frameHandlerList.push(handler);
	}
	
	/*
	 * フレーム動作
	 */
	private function frame(event:Event):Void
	{
		for (handler in frameHandlerList)
		{
			handler();
		}
	}
}
