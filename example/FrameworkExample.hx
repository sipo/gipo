package ;
/**
 * ゲームの基本設計などの例
 * 
 * @auther sipo
 */
import flash.events.Event;
import jp.sipo.gipo.core.config.GearNoteTag;
import jp.sipo.util.Note;
import frameworkExample.config.DevConfig;
import frameworkExample.core.Top;
import flash.Lib;
class FrameworkExample
{

	/* メインインスタンス */
	private static var _main:FrameworkExample;
	
	/**
	 * 起動関数
	 */
	public static function main():Void
	{
		var test = Lib.current;
		if (Lib.current.stage != null) afterAddToStage();
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, function (event:Event) afterAddToStage());
	}
	
	/* 停止時のファイルのロックなどを防ぐため、stage追加を待つ */
	private static function afterAddToStage():Void
	{
		_main = new FrameworkExample();
	}
	
	/* 最上位GearHolder */
	private var top:Top;
	
	/** コンストラクタ */
	public function new() 
	{
		top = new Top(Lib.current, new DevConfig());
		top.getGear().initializeTop(null);
	}
}
