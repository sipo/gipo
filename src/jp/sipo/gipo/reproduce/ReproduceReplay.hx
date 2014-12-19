package jp.sipo.gipo.reproduce;
/**
 * 再生を行うState
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.LogPart;
import Type;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import flash.Vector;
import jp.sipo.util.Note;
import jp.sipo.gipo.reproduce.Reproduce;
class ReproduceReplay<TUpdateKind> extends StateGearHolderImpl implements ReproduceReplayState<TUpdateKind>
{
	/* 再生ログ */
	private var replayLog:ReplayLog<TUpdateKind>;
	/* 実行関数 */
	private var executeEvent:LogPart<TUpdateKind> -> Void;
	/* 終了通知関数 */
	private var endCallback:Void -> Void;
	
	/* 現在フレームで再現実行されるPart */
	private var nextLogPartList:Vector<LogPart<TUpdateKind>> = new Vector<LogPart<TUpdateKind>>();
	/* 準備処理のうち通知が来たが、フレーム処理がまだであるもののリスト */
	private var aheadReadyList:Vector<LogPart<TUpdateKind>> = new Vector<LogPart<TUpdateKind>>();
	/* 準備処理のうちフレーム処理が先に来たが、通知がまだであるもののリスト */
	private var yetReadyList:Vector<LogPart<TUpdateKind>> = new Vector<LogPart<TUpdateKind>>();
	
	@:absorb
	private var note:Note;
	
	/** コンストラクタ */
	public function new(replayLog:ReplayLog<TUpdateKind>, executeEvent:LogPart<TUpdateKind> -> Void, endCallback:Void -> Void) 
	{
		super();
		this.replayLog = replayLog;
		this.executeEvent = executeEvent;
		this.endCallback = endCallback;
	}
	
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		note.log('再現の開始');
		replayLog.setPosition(0);
		update(0);
	}
	
	/**
	 * 進行可能かどうかチェックする
	 */
	public function checkCanProgress():Bool
	{
		return yetReadyList.length == 0;
	}
	
	
	/**
	 * 更新処理
	 */
	public function update(frame:Int):Void
	{
		// ここに来た時は前フレームのリストは全て解消されているはず
		if (nextLogPartList.length != 0) throw '解消されていないLogPartが残っています $nextLogPartList';
		// 発生するイベントをリストアップする
		// このフレームで実行されるパートを取り出す
		while(replayLog.hasNext() && replayLog.nextPartFrame == frame)
		{
			var part:LogPart<TUpdateKind> = replayLog.next();
			// フレームで発生するモノリストに追加
			nextLogPartList.push(part);
			// 非同期イベントなら
			if (part.isReadyLogway())
			{
				// 相殺を確認
				var setoff:Bool = compensate(part, aheadReadyList);
				// 相殺できなければ待機リストへ追加
				if (!setoff)
				{
					note.log('準備イベントが、実際の発生より先に再現が到達しました。動作を待機して実際の準備イベントを待ちます。 $part');
					yetReadyList.push(part);
				}
			} 
		}
	}
	/* 対象の再生Partがリスト内と同じものがあるか確認し、あれば相殺してtrueを返す */
	private function compensate(logPart:LogPart<TUpdateKind>, list:Vector<LogPart<TUpdateKind>>):Bool
	{
		var index:Int = sameLogIndex(logPart, list);
		if (index != -1)
		{
			note.log('準備イベントが待機リストと相殺して解決しました ${list[index]}');
			list.splice(index, 1);	// リストから削除
			return true;
		}
		// 対象が無ければfalse
		return false;
	}
	/* 同じイベントがあるかどうか */
	private function sameLogIndex(logPart:LogPart<TUpdateKind>, list:Vector<LogPart<TUpdateKind>>):Int
	{
		for (i in 0...list.length)
		{
			var target:LogPart<TUpdateKind> = list[i];
			if (target.isSame(logPart)) return i;
		}
		return -1;
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(logPart:LogPart<TUpdateKind>, canProgress:Bool):Void
	{
		// 非同期でなければ何もしない
		if (!logPart.isReadyLogway()) return;
		// 停止中なら、yetListが存在するはずなので相殺をチェックする。実行中は相殺対象は無いはず。
		if (!canProgress)
		{
			// 相殺を確認
			var setoff:Bool = compensate(logPart, yetReadyList);
			// 相殺したなら追加しないでいい
			if (setoff) return;
		}
		// 相殺出来なかった場合は、aheadリストへ追加
		// 同一Logは、誤動作を起こすため警告
		if (sameLogIndex(logPart, aheadReadyList) != -1)
		{
			note.warning('準備イベントの実際の発生が２重に発生しました。２つ以上の同じ準備イベントは、処理が前後してしまう可能性があるため回避するようにしてください。最も簡単な回避方法は、イベントEnumにid引数を持たせることです。 $logPart');
		}
		// 追加
		note.log('準備イベントの実際の発生が再現タイミングより先に到達しました。再現タイミングを待ちます。 $logPart');
		aheadReadyList.push(logPart);
	}
	
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<TUpdateKind>, canProgress:Bool):Void
	{
		if (!canProgress) return;
		// 再生予定リストを再生
		while (nextLogPartList.length != 0)
		{
			var part:LogPart<TUpdateKind> = nextLogPartList[0];
			// phaseが一致しているもののでなければ終了
			if (!part.equalPhase(phaseValue)) break;
			// 削除
			nextLogPartList.shift();
			// 実行
			executeEvent(part);
			// 終了のチェック
			if (nextLogPartList.length == 0 && !replayLog.hasNext())
			{
				note.log('再現が終了しました');
				endCallback();
			}
		}
	}
	
}
