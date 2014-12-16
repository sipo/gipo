package jp.sipo.gipo.reproduce;
/**
 * 再生を行う前に、その開始タイミングを揃えるために少し待つためのState
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.LogPart;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class ReproduceReplayWait<TUpdateKind> extends StateGearHolderImpl implements ReproduceReplayState<TUpdateKind>
{
	
	/* フレームカウント */
	public var frame:Int = 0;
	/* フレーム処理実行可能かどうかの判定 */
	public var canProgress:Bool = true;
	/* 実行関数 */
	private var executeEvent:LogPart<TUpdateKind> -> Void;	// TODO:<<尾野>>共通化？
	
	/** コンストラクタ */
	public function new(executeEvent:LogPart<TUpdateKind> -> Void) 
	{
		super();
		this.executeEvent = executeEvent;
	}
	
	/**
	 * 進行可能かどうかチェックする
	 */
	public function checkCanProgress():Bool
	{
		return true;
	}
	
	/**
	 * 更新処理
	 */
	public function update(frame:Int):Void
	{
		// 特になし
	}
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(logPart:LogPart<TUpdateKind>, canProgress:Bool):Void
	{
		// そのまま実行
		executeEvent(logPart);
	}
	
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<TUpdateKind>, canProgress:Bool):Void
	{
		// 特になし
	}
}
