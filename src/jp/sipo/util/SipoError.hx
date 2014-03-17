package jp.sipo.util;
/**
 * 
 * @auther sipo
 */
import haxe.PosInfos;
class SipoError
{
	/* 表示メッセージ */
	private var message:String;
	/* 位置表示 */
	private var pos:PosInfos;
	
	/** コンストラクタ */
	public function new(message:String, ?pos:PosInfos) 
	{
		this.message = message;
		this.pos = pos;
	}
	
	/**
	 * 文字表現
	 */
	public function toString():String
	{
		return '[SipoError $message]';
	}
}
