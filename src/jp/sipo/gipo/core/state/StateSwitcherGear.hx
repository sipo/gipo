package jp.sipo.gipo.core.state;
import jp.sipo.util.SipoError;
import flash.Vector;
import jp.sipo.gipo.util.ListCall;
import jp.sipo.gipo.core.config.GearNoteTag;
import jp.sipo.util.Note;
@:final
class StateSwitcherGear	
{
	// 関連インスタンス
	private var gear:Gear;
	
	private var stateHolder:StateGearHolder;
	private var changeLock:Bool = false;
	/* 表示インスタンス */
	private var changeNote:Note;
	
	/* --------------------------------
	 * HandlerList
	 * -------------------------------*/
	
	/* 代入が確定した際にstateを引数に取って呼び出される関数 */
	private var stateAssignmentList:Vector<StateGearHolder -> Void>;
	/* 前回シーンの扱いに関する関数（単体） */
	private var lastStateTreatment:StateGearHolder -> Void;
	
	public function new(holder:StateSwitcherGearHolder, gear:Gear)
	{
		this.gear = gear;
		changeNote = new Note([GearNoteTag.gearSystem, GearNoteTag.stateChange]);
		// HandlerListの初期化
		stateAssignmentList = new Vector<StateGearHolder -> Void>();
		gear.disposeTask(function (){
			stateAssignmentList = null;
		});
		// 前回Sceneの扱い
		gear.disposeTask(function (){
			lastStateTreatment = null;
		});
	}
	
	/**
	 * Stateの切り替え
	 * contextは予め実行しておく
	 * // MEMO:Functionを第２引数に持たせてその内部で処理するという手もあるが、とりあえず今は構造をシンプルにしたい
	 */
	public function changeState(nextStateHolder:StateGearHolder):Void
	{
		if (changeLock) throw new SipoError("changeStateが２重に呼び出されました。");
		// ログ
		changeNote.log('changeState ${nextStateHolder} switcher=${this} ');	
		// ２重呼び出しをロック
		changeLock = true;
		// １つ前のStateをremove処理
		var lastStateHolder:StateGearHolder = stateHolder;
		if (lastStateHolder != null){
			if (lastStateTreatment == null) default_lastStateTreatment(stateHolder);	// 設定が特になければデフォルト動作（削除）
			else lastStateTreatment(stateHolder);	// 設定されていれば渡す
		}
		// 入れ替え
		stateHolder = nextStateHolder;
		// 内部変数に伝える（ここで処理は行わない）
		ListCall.withArgument(stateAssignmentList, [nextStateHolder]);
		// 子に追加
		gear.addChild(nextStateHolder);
		// ２重追加ロックを解除
		changeLock = false; 
		// GearStateを有効化する
		stateHolder.getStateGear().activationState(this);
	}
	
	/**
	 * 前回のstateの取り扱い
	 * デフォルトではremove、継承して扱いを変えることができる。// FIXME:修正
	 */
	private function default_lastStateTreatment(lastStateHolder:StateGearHolder):Void
	{
		gear.removeChild(stateHolder);
	}
	
	/* ================================================================
	 * ハンドラ登録
	 * ===============================================================*/
	
	/**
	 * 代入が確定した際にstateを引数に取って呼び出される関数
	 * stateを変数に入れておきたい場合に使う。
	 * 「AfterChangeState」ではないので注意。changeStateの処理の最中に呼び出されている。
	 * FlashだとstateがDynamicになっているので高速化の意味合いもある
	 */
	public function entryHandlerStateAssignment(stateAssignment:StateGearHolder -> Void):Void
	{
		stateAssignmentList.push(stateAssignment);
	}
	
	/**
	 * 切り替えた場合の前回Stateの処遇を設定。
	 * 上書きはエラー
	 */
	public function setHandlerLastStateTreatment(lastStateTreatment:StateGearHolder -> Void):Void
	{
		if (this.lastStateTreatment != null) throw new SipoError('既にlastStateTreatmentが登録されています ${lastStateTreatment}');
		this.lastStateTreatment = lastStateTreatment;
	}
}
