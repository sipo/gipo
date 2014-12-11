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
class ReproduceReplay<TUpdateKind> extends StateGearHolderImpl implements ReproduceState<TUpdateKind>
{
	@:absorb
	private var hook:HookForReproduce;
	/* 再生ログ */
	private var replayLog:ReplayLog<TUpdateKind>;
	
	/* 現在フレームで再現実行されるPart */
	private var nextLogPartList:Vector<LogPart<TUpdateKind>> = new Vector<LogPart<TUpdateKind>>();
	/* 非同期処理のうち通知が来たが、フレーム処理がまだであるもののリスト */
	private var aheadAsyncList:Vector<LogPart<TUpdateKind>> = new Vector<LogPart<TUpdateKind>>();
	/* 非同期処理のうちフレーム処理が先に来たが、通知がまだであるもののリスト */
	private var yetAsyncList:Vector<LogPart<TUpdateKind>> = new Vector<LogPart<TUpdateKind>>();
	
	@:absorb
	private var note:Note;
	
	/* comment */
	private var isEnd:Bool = false;
	
	/** コンストラクタ */
	public function new(replayLog:ReplayLog<TUpdateKind>) 
	{
		super();
		this.replayLog = replayLog;
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
		return yetAsyncList.length == 0;
	}
	
	
	/**
	 * 更新処理
	 */
	public function update(frame:Int):Void
	{
		if (isEnd) return;	// TODO:<<尾野>>いらなくなる
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
			if (LogPart.isAsyncLogway(part.logway))
			{
				// 相殺を確認
				var setoff:Bool = compensate(part.phase, part.logway, aheadAsyncList);
				// 相殺できなければ待機リストへ追加
				if (!setoff)
				{
					note.log('非同期イベントの再現が実際の発生より先に到達しました。動作を待機して非同期イベントを待ちます。 $part');
					yetAsyncList.push(part);
				}
			} 
		}
	}
	/* 対象の再生Partがリスト内と同じものがあるか確認し、あれば相殺してtrueを返す */
	private function compensate(phaseValue:ReproducePhase<TUpdateKind>, logway:LogwayKind, list:Vector<LogPart<TUpdateKind>>):Bool
	{
		for (i in 0...list.length)
		{
			var target:LogPart<TUpdateKind> = list[i];
			if (target.isSameParam(phaseValue, logway))
			{
				note.log('非同期イベントが待機リストと相殺して解決しました $target');
				list.splice(i, 1);	// リストから削除
				return true;
			}
		}
		// 対象が無ければfalse
		return false;
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(logPart:LogPart<TUpdateKind>, canProgress:Bool):Void
	{
		// 非同期でなければ何もしない
		if (!LogPart.isAsyncLogway(logPart.logway)) return;	// TODO:<<尾野>>LogPart化の検証
		// 停止中なら、yetListが存在するはずなので相殺をチェックする。実行中は相殺対象は無いはず。
		if (!canProgress)
		{
			// 相殺を確認
			var setoff:Bool = compensate(logPart.phase, logPart.logway, yetAsyncList);	// TODO:<<尾野>>LogPart化の検証
			// 相殺したなら追加しないでいい
			if (setoff) return;
		}
		// 相殺出来なかった場合は、aheadリストへ追加
		note.log('非同期イベントの発生が再現イベントタイミングより先に到達しました $logPart');
		aheadAsyncList.push(logPart);
		// TODO:<<尾野>>余計なイベントが発生した場合、aheadに溜め込まれてしまう問題があるので、対策を検討→複数の同じイベントがAheadに入ったら警告
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
		if (!canProgress) return;
		// 再生予定リストを再生
		while (nextLogPartList.length != 0)
		{
			var part:LogPart<TUpdateKind> = nextLogPartList[0];
			// phaseが一致しているもののでなければ終了
			if (!Type.enumEq(part.phase, phaseValue)) break;
			// 実行
			hook.executeEvent(part.logway, part.factorPos);
			// 削除
			nextLogPartList.shift();
			// 終了のチェック
			if (nextLogPartList.length == 0 && !replayLog.hasNext())
			{
				isEnd = true;
				note.log('再現が終了しました');
			}
		}
	}
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<TUpdateKind>
	{
		throw '記録状態の時のみ';
	}
}
