package jp.sipo.gipo_framework_example.pilotView;
/**
 * View以下に提供するinput動作
 */
import jp.sipo.util.Note;
import haxe.EnumTools;
import jp.sipo.gipo_framework_example.context.Hook.HookForView;
import haxe.PosInfos;
class ViewSceneInput
{
	
	/* inputの通知先 */
	private var hook:HookForView;
	/* 許可されたEnum */
	private var allowEnum:Enum<Dynamic>;
	/* 警告表示用 */
	private var note:Note = new Note([ViewSceneInputNote.CancelInput]);
	
	/** コンストラクタ */
	public function new(hook:HookForView) 
	{
		this.hook = hook;
	}
	
	/**
	 * Sceneに対するEnumを変更する
	 */
	public function setAllowEnum(allowEnum:Enum<Dynamic>):Void
	{
		this.allowEnum = allowEnum;
	}
	
	/**
	 * 即時発生の入力を通知する
	 */
	public function instant(command:EnumValue, ?pos:PosInfos):Void
	{
		if (checkEnum(command, pos))
		{
			hook.viewInstantInput(command, pos);
		}
	}
	
	/**
	 * 即時発生の入力を通知する
	 */
	public function ready(command:EnumValue, ?pos:PosInfos):Void
	{
		if (checkEnum(command, pos))
		{
			hook.viewReadyInput(command, pos);
		}
	}
	
	/* 許可されたEnumか判別する */
	inline private function checkEnum(command:EnumValue, pos:PosInfos):Bool
	{
		if (Type.getEnum(command) == allowEnum) return true;
		note.log('input(${command})が受け付けEnum(${allowEnum})と異なるためキャンセルされました。pos=${pos}');
		return false;
	}
}
/**
 * 警告用Enum
 */
enum ViewSceneInputNote
{
	CancelInput;
}



