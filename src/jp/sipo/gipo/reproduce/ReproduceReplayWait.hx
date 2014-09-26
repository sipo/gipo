package jp.sipo.gipo.reproduce;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.LogPart;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class ReproduceReplayWait<UpdateKind> extends StateGearHolderImpl implements ReproduceState<UpdateKind>
{
	
	/* フレームカウント */
	public var frame:Int = 0;
	/* フレーム処理実行可能かどうかの判定 */
	public var canProgress:Bool = true;
	/* 再生ログ */
	private var replayLog:ReplayLog<UpdateKind>;
	
	/** コンストラクタ */
	public function new(replayLog:ReplayLog<UpdateKind>) 
	{
		super();
		this.replayLog = replayLog;
	}
	
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		// 特になし
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(phaseValue:ReproducePhase<UpdateKind>, logway:LogwayKind):Void
	{
		// 特になし
	}
	
	/**
	 * 切り替えの問い合わせ
	 */
	public function getChangeWay():ReproduceSwitchWay<UpdateKind>
	{
		return ReproduceSwitchWay.ToReplay(replayLog);
	}
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<UpdateKind>):Void
	{
		// 特になし
	}
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<UpdateKind>
	{
		// 特になし
	}
}
