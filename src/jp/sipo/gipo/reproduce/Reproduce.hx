package jp.sipo.gipo.reproduce;
/**
 * 動作コマンドの記録と再生を担当する。
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.config.GearNoteTag;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.LogPart;
import haxe.PosInfos;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.state.StateGearHolder;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.util.Note;
import haxe.ds.Option;
/* ================================================================
 * Hookに要求する機能
 * ===============================================================*/
interface HookForReproduce
{
	/** イベントの実行 */
	public function executeEvent(logWay:LogwayKind, factorPos:PosInfos):Void;
}
/* ================================================================
 * OperationHookに要求する機能
 * ===============================================================*/
interface OperationHookForReproduce
{
	/**
	 * Reproduceからのイベント処理
	 */
	public function noticeReproduceEvent(event:ReproduceEvent):Void;
}
/**
 * OperationLogic向けのイベント定義
 */
enum ReproduceEvent
{
	/** ログの更新あり */
	LogUpdate;
}
/* ================================================================
 * 実装
 * ===============================================================*/
class Reproduce<TUpdateKind> extends StateSwitcherGearHolderImpl<ReproduceState<TUpdateKind>>
{
	@:absorb
	private var operationHook:OperationHookForReproduce;
	@:absorb
	private var hook:HookForReproduce;
	/* 記録フェーズ */
	private var phase:Option<ReproducePhase<TUpdateKind>> = Option.None;
	/* 再生可能かどうかの判定 */
	private var canProgress:Bool = true;
	/* フレームカウント */
	private var frame:Int = 0;
	
	
	private var note:Note;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		note = new Note([GearNoteTag.Reproduce]);
		tool.diffuse(note, Note);
	}
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		stateSwitcherGear.changeState(new ReproduceRecord<TUpdateKind>());
	}
	
	/**
	 * 再生可能かどうかを確認して状態を切り替える
	 */
	public function checkCanProgress():Bool
	{
		canProgress = state.checkCanProgress();
		return canProgress;
	}
	
	/**
	 * 更新
	 */
	public function update():Void
	{
		if (!canProgress) return;
		// TODO:<<尾野>>ここに、bookを確認して、切り替える処理を入れるので、frameを-1にしなくてよくなる
		frame++;
		state.update(frame);
	}
	
	/**
	 * フレーム間のフェーズ切り替え
	 */
	public function startOutFramePhase():Void
	{
		startPhase(ReproducePhase.OutFrame);
	}
	/**
	 * フレーム内のフェーズ切り替え
	 */
	public function startInFramePhase(TUpdateKind:TUpdateKind):Void
	{
		startPhase(ReproducePhase.InFrame(TUpdateKind));
	}
	/* フェーズ切り替え共通動作 */
	private function startPhase(nextPhase:ReproducePhase<TUpdateKind>):Void
	{
		switch(phase)
		{
			case Option.None : this.phase = Option.Some(nextPhase);	// 新しいPhaseに切り替える
			case Option.Some(v) : throw '前回のフェーズが終了していません $v->$nextPhase';
		}
	}
	
	
	
	/**
	 * イベントの発生を受け取る
	 */
	public function noticeLog(logway:LogwayKind, factorPos:PosInfos):Void
	{
		var phaseValue:ReproducePhase<TUpdateKind> = switch(phase)
		{
			case Option.None : throw 'フェーズ中でなければ記録できません $phase';
			case Option.Some(v) : v;
		}
		// メイン処理
		Note.temporal('replay update $frame $canProgress');
		state.noticeLog(phaseValue, frame, logway, factorPos, canProgress);
	}
	
	// MEMO:フェーズ終了で実行されるのはリプレイの時のみで、通常動作時は、即実行される
	/*
	理由
	確かに、両方共endにしておくことで、統一性が担保されるが、
	・コマンドに起因して更にコマンドが発生する場合に問題になる。
	・コマンドを受け取ったLogicがViewにボタンの無効命令を出しても間に合わない
	・スタックトレースが悪化する
	といったデメリットがある。
	それに対して、通常時にendでないタイミングで発生する場合でも、少し不安な程度で、
	順序は確保され、ViewからのLogicへのデータはロックされているはずなので明確なデメリットは無いはず
	 */
	
	/**
	 * フェーズ終了
	 */
	public function endPhase():Void
	{
		var phaseValue:ReproducePhase<TUpdateKind> =switch(phase)
		{
			case Option.None : throw '開始していないフェーズを終了しようとしました $phase';
			case Option.Some(value) : value;
		}
		// meanTimeの時は、ここから再生モードに移行する可能性を調べる
		var phaseIsOutFrame:Bool = switch (phaseValue)
		{
			case ReproducePhase.OutFrame : true;
			case ReproducePhase.InFrame : false;
		}
		if (phaseIsOutFrame)
		{
			// 必要ならReplayへ以降
			var stateSwitchWay:ReproduceSwitchWay<TUpdateKind> = state.getChangeWay();
			switch (stateSwitchWay)
			{
				case ReproduceSwitchWay.None :
				case ReproduceSwitchWay.ToReplay(log) : stateSwitcherGear.changeState(new ReproduceReplay(log));
			}
		}
		// メイン処理
		state.endPhase(phaseValue, canProgress);
		// フェーズを無しに
		phase = Option.None;
	}
	
	
	/**
	 * ログを返す
	 */
	public function getRecordLog():RecordLog<TUpdateKind>
	{
		return state.getRecordLog();
	}
	
	/**
	 * 再生状態に切り替える
	 */
	public function startReplay(log:ReplayLog<TUpdateKind>, logIndex:Int):Void
	{
		note.log('replayStart($logIndex) $log');
		log.setPosition(logIndex);
		frame = -1;
		stateSwitcherGear.changeState(new ReproduceReplay(log));
	}
}
interface ReproduceState<TUpdateKind> extends StateGearHolder
{
	/**
	 * 進行可能かどうかチェックする
	 */
	public function checkCanProgress():Bool;
	
	/**
	 * 更新処理
	 */
	public function update(frame:Int):Void;
	
	/**
	 * ログ発生の通知
	 */
	public function noticeLog(phaseValue:ReproducePhase<TUpdateKind>, frame:Int, logway:LogwayKind, factorPos:PosInfos, canProgress:Bool):Void;
	
	/**
	 * 切り替えの問い合わせ
	 */
	public function getChangeWay():ReproduceSwitchWay<TUpdateKind>;
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<TUpdateKind>, canProgress:Bool):Void;
	
	/**
	 * RecordLogを得る（記録状態の時のみ）
	 */
	public function getRecordLog():RecordLog<TUpdateKind>;
}
enum ReproduceSwitchWay<TUpdateKind>
{
	None;
	ToReplay(replayLog:ReplayLog<TUpdateKind>);
}
