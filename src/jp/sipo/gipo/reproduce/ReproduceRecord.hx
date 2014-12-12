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
class ReproduceRecord<TUpdateKind> extends StateGearHolderImpl implements ReproduceState<TUpdateKind>
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
	 * 更新処理
	 */
	public function update(frame:Int):Void
	{
	}
	
	/**
	 * 進行可能かどうかチェックする
	 */
	public function checkCanProgress():Bool
	{
		return true;
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(logPart:LogPart<TUpdateKind>, canProgress:Bool):Void
	{
		// 準備イベントが、updatePhase内で発生したら警告
		if (logPart.isReadyLogway() && !logPart.isOutFramePhase()) throw "準備イベントは、updateタイミングで発生してはいけません。（再現時の待機に問題が出るため）。meantimeUpdate等の関数で発生するようにしてください。";
		// 記録に追加
		recordLog.add(logPart);
		// 記録が更新されたことをOperationの表示へ通知
		operationHook.noticeReproduceEvent(ReproduceEvent.LogUpdate);
		// 実行する
		hook.executeEvent(logPart.logway, logPart.factorPos);
	}
	
	/**
	 * 切り替えの問い合わせ
	 */
	public function getChangeWay():ReproduceSwitchWay<TUpdateKind>
	{
		return ReproduceSwitchWay.None;
	}
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<TUpdateKind>, canProgress:Bool):Void
	{
		// 特になし
	}
	
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<TUpdateKind>
	{
		return recordLog;
	}
}
