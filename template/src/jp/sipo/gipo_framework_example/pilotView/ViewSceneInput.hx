package jp.sipo.gipo_framework_example.pilotView;
/**
 * View以下に提供するinput動作
 */
import jp.sipo.gipo.core.GearHolderImpl;
import jp.sipo.util.Note;
import jp.sipo.gipo_framework_example.context.Hook.HookForView;
import haxe.PosInfos;
class ViewSceneInput extends GearHolderImpl
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
		super();
		this.hook = hook;
	}
	
	/**
	 * 即時発生の入力を通知する
	 */
	public function instant(command:EnumValue, ?pos:PosInfos):Void
	{
		if (check(command, pos))
		{
			hook.viewInstantInput(command, pos);
		}
	}
	
	/**
	 * 即時発生の入力を通知する
	 */
	public function ready(command:EnumValue, ?pos:PosInfos):Void
	{
		if (check(command, pos))
		{
			hook.viewReadyInput(command, pos);
		}
	}
	
	/* 許可されたEnumか判別する */
	inline private function check(command:EnumValue, pos:PosInfos):Bool
	{
		if (gear.checkPhaseBeforeDispose()) return true;
		note.log('input(${command})がありましたが、該当Gearが既に破棄されているためキャンセルしました。pos=${pos}');
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



