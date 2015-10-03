package jp.sipo.gipo.reproduce;
/**
 * 動作コマンドの記録と再生を担当する。
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.state.StateSwitcherGearHolderLowLevelImpl;
import jp.sipo.gipo.core.config.GearNoteTag;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.LogPart;
import haxe.PosInfos;
import jp.sipo.gipo.core.GearPreparationTool;
import jp.sipo.gipo.core.state.StateGearHolder;
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
class Reproduce<TUpdateKind> extends StateSwitcherGearHolderLowLevelImpl
{
	@:absorb
	private var operationHook:OperationHookForReproduce;
	@:absorb
	private var hook:HookForReproduce;
	/* 再生担当（切り替わる） */
	private var replayer:ReproduceReplayState<TUpdateKind>;
	/* 記録担当 */
	private var recorder:ReproduceRecord<TUpdateKind>;
	/* 再生フェーズ */
	private var phase:Option<ReproducePhase<TUpdateKind>> = Option.None;
	/* 再生可能かどうかの判定 */
	private var canProgress:Bool = true;
	/* フレームカウント */
	private var frame:Int = 0;
	/* 再生予約 */
	private var bookReplay:BookReplay<TUpdateKind> = BookReplay.None;
	
	
	private var note:Note;
	
	/* ================================================================
	 * StateSwitcherの実装
	 * ===============================================================*/
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		stateSwitcherGear.addStateAssignmentHandler(stateAssignment);
		// ハンドラの登録
		gear.addPreparationHandler(preparation);
		gear.addRunHandler(run);
	}
	
	/**
	 * Stateの切り替え
	 */
	public function changeState(nextState:ReproduceReplayState<TUpdateKind>, ?pos:PosInfos):Void
	{
		stateSwitcherGear.changeState(nextState, pos);
	}
	
	/**
	 * Stateの型変換
	 */
	inline private function stateAssignment(state:StateGearHolder):Void
	{
		this.replayer = cast(state);
	}
	
	/* ================================================================
	 * 本処理
	 * ===============================================================*/
	
	/* gearHandler */
	private function preparation(tool:GearPreparationTool):Void
	{
		// 下位層にNoteを渡す
		note = new Note([GearNoteTag.Reproduce]);
		tool.diffuse(note, Note);
	}
	
	/* gearHandler */
	private function run():Void
	{
		// 記録開始
		startRecord();
		// 再生は待機状態へ
		stateSwitcherGear.changeState(new ReproduceReplayWait<TUpdateKind>(executeEvent));
	}
	
	/* 記録の開始 */
	private function startRecord():Void
	{
		recorder = gear.addChild(new ReproduceRecordImpl<TUpdateKind>());
	}
	
	/**
	 * 再生可能かどうかを確認して状態を切り替える
	 */
	public function checkCanProgress():Bool
	{
		canProgress = replayer.checkCanProgress();
		return canProgress;
	}
	
	/**
	 * 更新
	 */
	public function update():Void
	{
		if (!canProgress) return;
		// フレームの進行
		frame++;
		// replayerの進行
		replayer.update(frame);
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
		var logPart:LogPart<TUpdateKind> = new LogPart<TUpdateKind>(phaseValue, frame, logway, factorPos);
		replayer.noticeLog(logPart, canProgress);
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
		
		// ここから再生モードに移行する可能性を調べる
		if (Type.enumEq(phaseValue, ReproducePhase.OutFrame))
		{
			switch(bookReplay)
			{
				case BookReplay.None:
				case BookReplay.Book(log): startReplay_(log);
			}
		}
		// メイン処理
		replayer.endPhase(phaseValue, canProgress);
		// フェーズを無しに
		phase = Option.None;
	}
	/* 再生を開始 */
	private function startReplay_(log:ReplayLog<TUpdateKind>):Void
	{
		// 予約を消す
		bookReplay = BookReplay.None;
		// 記録ログをリセットして記録しなおし
		startRecord();
		// 再生を開始
		stateSwitcherGear.changeState(new ReproduceReplay(log, executeEvent, replayEnd));
	}
	/* イベントを実際に実行する処理 */
	private function executeEvent(part:LogPart<TUpdateKind>):Void
	{
		// 保存
		recorder.saveLog(part);
		// 実行
		hook.executeEvent(part.logway, part.factorPos);
	}
	/* 終了処理 */
	private function replayEnd():Void
	{
		stateSwitcherGear.changeState(new ReproduceReplayWait(executeEvent));
	}
	
	
	
	/**
	 * ログを返す
	 */
	public function getRecordLog():RecordLog<TUpdateKind>
	{
		return recorder.getRecordLog();
	}
	
	/**
	 * 再生状態に切り替える
	 */
	public function startReplay(log:ReplayLog<TUpdateKind>, logIndex:Int):Void
	{
		frame = 0;
		log.setPosition(logIndex);
		bookReplay = BookReplay.Book(log);
	}
}
interface ReproduceReplayState<TUpdateKind> extends StateGearHolder
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
	public function noticeLog(logPart:LogPart<TUpdateKind>, canProgress:Bool):Void;
	
	/**
	 * フェーズ終了
	 */
	public function endPhase(phaseValue:ReproducePhase<TUpdateKind>, canProgress:Bool):Void;
}
enum BookReplay<TUpdateKind>
{
	None;
	Book(replayLog:ReplayLog<TUpdateKind>);
}
interface ReproduceRecord<TUpdateKind>
{
	/**
	 * ログの保存
	 */
	public function saveLog(logPart:LogPart<TUpdateKind>):Void;
	
	/**
	 * RecordLogを得る
	 */
	public function getRecordLog():RecordLog<TUpdateKind>;
}
