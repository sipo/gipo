package jp.sipo.gipo.reproduce;
/**
 * 記録を行うState
 * 
 * @auther sipo
 */
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.core.config.GearNoteTag;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.LogPart;
import haxe.PosInfos;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.util.Note;
class ReproduceRecord<TUpdateKind> extends StateGearHolderImpl
{
	@:absorb
	private var operationHook:OperationHookForReproduce;
	@:absorb
	private var hook:HookForReproduce;
	/* 記録ログ */
	private var recordLog:RecordLog<TUpdateKind> = new RecordLog<TUpdateKind>();
	
	private var note:Note;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		note = new Note([GearNoteTag.Reproduce]);
	}
	
	
	/**
	 * 進行可能かどうかチェックする
	 */
	public function checkCanProgress():Bool
	{
		return true;
	}
	
	/**
	 * ログの保存
	 */
	public function saveLog(logPart:LogPart<TUpdateKind>):Void
	{
		// 準備イベントが、updatePhase内で発生したら警告
		if (logPart.isReadyLogway() && !logPart.isOutFramePhase()) throw "準備イベントは、updateタイミングで発生してはいけません。（再現時の待機に問題が出るため）。meantimeUpdate等の関数で発生するようにしてください。";
		// 記録に追加
		recordLog.add(logPart);
		// 記録が更新されたことをOperationの表示へ通知
		operationHook.noticeReproduceEvent(ReproduceEvent.LogUpdate);
	}
	
	
	/**
	 * RecordLogを得る
	 */
	public function getRecordLog():RecordLog<TUpdateKind>
	{
		return recordLog;
	}
}
