package ;
/**
 * ゲームの基本設計などの例
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.pilotView.ViewSceneInput.ViewSceneInputNote;
import jp.sipo.gipo.core.config.GearNoteTag;
import jp.sipo.util.Note;
import flash.events.Event;
import jp.sipo.gipo_framework_example.context.DevConfig;
import jp.sipo.gipo_framework_example.context.Top;
import flash.Lib;
class GipoTemplate
{

	/* メインインスタンス */
	private static var _main:GipoTemplate;
	
	/**
	 * 起動関数
	 */
	public static function main():Void
	{
		// stageに追加されるのを待つ処理。一部のバグの回避のために行なう
		if (Lib.current.stage != null) afterAddToStage();
		else Lib.current.addEventListener(Event.ADDED_TO_STAGE, function (event:Event) afterAddToStage());
	}
	
	/* 停止時のファイルのロックなどを防ぐため、stage追加を待つ */
	private static function afterAddToStage():Void
	{
		_main = new GipoTemplate();
	}
	
	/* 最上位GearHolder */
	private var top:Top;
	
	/** コンストラクタ */
	public function new() 
	{
		Note.setTags([GearNoteTag.StateChange, GearNoteTag.Reproduce, ViewSceneInputNote.CancelInput], []);
		// ここから本処理の開始
		top = new Top(Lib.current, new DevConfig());
		top.gearOutside().initializeTop(null);
	}
}
