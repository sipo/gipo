package frameworkExample.context;
/**
 * 各セクションからのイベントをロジックに伝える
 * MVCで言うところのC
 * データの保存と再現も担当する（予定）
 * 
 * Hookイベントの種類
 * 	Input
 * 		ユーザー入力等、基本的なイベント
 * 		入力情報は、再現データから瞬時に復元できるものである必要がある（外部ファイルとかを読む必要が無い）
 * 	Ready
 * 		データの読み込みなど、非同期であったり、終了時間が読めないイベント
 * 		GPUへの非同期な準備や、必要データの非同期な展開などもこれに含む。
 * 		再現時には、Logicのほうがセクションに合わせて停止する必要がある。
 * 		
 * 	※イベントの発生がセクションに依存し、かつそれがフレーム進行を必要とするものは、対応できない。
 * 	例えば、表示演出などは、仮にその演出が途中で、ボタンが画面に無くともボタンの入力イベントに対応しなければいけない。
 * 	
 * 
 * @auther sipo
 */

import frameworkExample.context.Logic.HookToLogic;
import frameworkExample.context.Hook.HookEvent;
import frameworkExample.operation.OperationLogic;
import jp.sipo.gipo.core.GearHolderImpl;
/* ================================================================
 * インターフェース
 * ===============================================================*/
interface ViewToHook
{
	/** Viewからの即時発行できる入力イベント */
	public function viewInput(command:EnumValue):Void;
	/** Viewからの非同期に発生するイベント */
	public function viewReady(command:EnumValue):Void;
}
/* ================================================================
 * 実装
 * ===============================================================*/
class Hook extends GearHolderImpl implements ViewToHook
{
	/* absorb */
	private var logic:HookToLogic;
	private var operation:OperationLogic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/** 初期処理 */
	public function run():Void
	{
		logic = gear.absorb(HookToLogic);
		operation = gear.absorb(OperationLogic);
	}
	
	/* ================================================================
	 * View向けのメソッド
	 * ===============================================================*/
	
	public function viewInput(command:EnumValue):Void
	{
		executeEvent(LogWay.Input, command);
	}
	
	public function viewReady(command:EnumValue):Void
	{
		executeEvent(LogWay.Ready, command);
	}
	
	/* ================================================================
	 * 内部処理
	 * ===============================================================*/
	 
	/**
	 * イベントの実行を処理
	 */
	private function executeEvent(logway:LogWay, command:EnumValue):Void
	{
		var hookEvent:HookEvent = new HookEvent(logway, command);
		switch (hookEvent.logWay)
		{
			case LogWay.Input :
				// 発生イベントの登録
				operation.record(hookEvent);
				// イベントの実行
				logic.noticeEvent(hookEvent);
			case LogWay.Ready : 
				// TODO:readyを待つ処理
				// 発生イベントの登録
				operation.record(hookEvent);
				// イベントの実行
				logic.noticeEvent(hookEvent);
			case LogWay.Operation : 
				operation.noticeEvent(hookEvent);
		}
	}
}

/**
 * イベント種類全ての定義を保持する
 */
class HookEvent
{
	public var logWay:LogWay;
//	public var frame:Int;// 発生フレーム
	public var command:EnumValue;/* 各LogicのLogicEvent定義になる */
	
	/** コンストラクタ */
	public function new(logWay:LogWay, command:EnumValue) 
	{
		this.logWay = logWay;
		this.command = command;
	}
}
/**
 * Logの記録と再生方法の種類
 */
enum LogWay
{
	/** 保存され、対象タイミングで実行 */
	Input;
	/** 保存され、対象タイミングで準備が整うまで全体を待たせる（処理時間が不明瞭な動作） */
	Ready;
	/** 保存されないOperation用のイベント */
	Operation;
}














