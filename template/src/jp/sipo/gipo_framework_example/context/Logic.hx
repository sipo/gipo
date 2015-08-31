package jp.sipo.gipo_framework_example.context;
/**
 * 中央管理クラス
 * MVCのMにあたる
 * Modelという名称は不適切だと思われるので、より実態を示すLogicと呼ぶ。
 * 処理を管理し、Stateを持ち、フレームの速度を調節する。
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.state.StateGearHolder;
import jp.sipo.gipo_framework_example.context.reproduce.SnapshotImpl;
import jp.sipo.gipo_framework_example.context.reproduce.SnapshotKind;
import haxe.PosInfos;
import jp.sipo.gipo_framework_example.context.reproduce.LogicStatus;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.scene.mock1.Mock1;
import jp.sipo.gipo_framework_example.context.Hook.HookForLogic;
import jp.sipo.gipo.reproduce.Snapshot;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo_framework_example.scene.initialize.LogicInitialize;
import jp.sipo.ds.Point;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
class Logic extends StateSwitcherGearHolderImpl<LogicScene> implements LogicForHook
{
	@:absorb
	private var hook:HookForLogic;
	
	/* Logic内部の全体データ */
	private var logicStatus:LogicStatus;
	/* シーン変更直後の入力ロックフラグ */
	private var afterChangeInputBlock:Bool = false;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		logicStatus = new LogicStatus();
		
		tool.diffuse(this, Logic);
		tool.diffuse(logicStatus, LogicStatus);
		
		stateSwitcherGear.addEnterStateChangeHandler(enterStateChangeHandler);
	}
	
	/**
	 * ゲーム開始
	 */
	public function start():Void
	{
		// hookに初期化用のsnapshotを渡す
		snapshotEvent(SnapshotKind.Initialize);
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		// 更新されたらロックは解除される（フレーム間イベントの場合、これはそのフレームの頭となる）
		afterChangeInputBlock = false;
		// シーンに更新処理を伝える
		state.sceneUpdate();
	}
	
	/**
	 * スナップショットを使用するイベントを起動する
	 * Stateの切り替わりがある場合、このsnapshotEventで自動的に発動する
	 */
	public function snapshotEvent(kind:SnapshotKind, ?pos:PosInfos):Void
	{
		hook.logicSnapshot(new SnapshotImpl(kind, logicStatus), pos);
	}
	
	/* state切り替わり時イベント */
	private function enterStateChangeHandler(nextHolder:StateGearHolder):Void
	{
		afterChangeInputBlock = true;
	}
	
	/* ================================================================
	 * hookに対する定義
	 * ===============================================================*/
	
	public function noticeEvent(command:EnumValue, factorPos:PosInfos):Void
	{
		// MEMO:<<尾野>>ここにisがあるのが非常に残念なので、何とかしたくはあるが、さらにenumで包むと呼び出しが煩雑になるので悩ましい。
		if (Std.is(command, LogicCommonEvent)){
		
			throw "未設定";	// TODO:LogicCommonを用意する
			return;
		}
		// changeScene直後の入力をロック。
		// MEMO:<<尾野>>本来はcommandごとに入力をロックするかどうか決まっている必要がありそう
		if (state.needAfterChangeBlockInput && afterChangeInputBlock) return;
		// その他のイベントの場合、下位へ渡す
		state.noticeEvent(command);
	}
	
	/**
	 * SnapShoptに対する動作を定義する
	 */
	public function setSnapshot(snapshot:Snapshot, factorPos:PosInfos):Void
	{
		var snapshotImpl:SnapshotImpl = cast(snapshot, SnapshotImpl);
		// logicStatusの反映
		logicStatus.setAll(snapshotImpl.logicStatus);
		// 種類に応じる処理
		switch(snapshotImpl.kind)
		{
			case SnapshotKind.Initialize : stateSwitcherGear.changeState(new LogicInitialize());
			case SnapshotKind.Mock1 :  stateSwitcherGear.changeState(new Mock1());
		}
		
	}
}
/**
 * hookに対する定義
 */
interface LogicForHook
{
	/** イベントの発生 */
	public function noticeEvent(command:EnumValue, factorPos:PosInfos):Void;
	/** スナップショットの適用 */
	public function setSnapshot(snapshot:Snapshot, factorPos:PosInfos):Void;
}
/**
 * 全体で共通のViewの入力種類
 * 
 * @auther sipo
 */
enum LogicCommonEvent
{
	/** マウスの共通演出用。ボタンの入力はこれとは別に個別に飛ぶ */
	MouseDown(point:Point<Int>);
	MouseDrag(point:Point<Int>);
	MouseUp(point:Point<Int>);
	// TODO:<<尾野>>未実装
}
