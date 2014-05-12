package frameworkExample.context;
/**
 * 中央管理クラス
 * MVCのMにあたる
 * Modelという名称は不適切だと思われるので、より実態を示すLogicと呼ぶ。
 * 処理を管理し、Stateを持ち、フレームの速度を調節する。
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearHandlerKind;
import frameworkExample.scene.mock1.Mock1;
import frameworkExample.context.Hook.LogicToHook;
import frameworkExample.etc.Snapshot;
import jp.sipo.gipo.core.GearDiffuseTool;
import frameworkExample.etc.LogicInitialize;
import jp.sipo.ds.Point;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
class Logic extends StateSwitcherGearHolderImpl<LogicScene> implements HookToLogic
{
	@:absorb
	private var hook:LogicToHook;
	
	/* Logic内部の全体データ */
	private var logicStatus:LogicStatus;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	@:handler(GearHandlerKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		logicStatus = new LogicStatus();
		
		tool.diffuse(this, Logic);
		tool.diffuse(logicStatus, LogicStatus);
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
		state.sceneUpdate();
	}
	
	/**
	 * スナップショットを使用するイベントを起動する
	 * Stateの切り替わりがある場合、このsnapshotEventで自動的に発動する
	 */
	public function snapshotEvent(kind:SnapshotKind):Void
	{
		hook.logicSnapshot(new Snapshot(kind, logicStatus));
	}
	
	/* ================================================================
	 * hookに対する定義
	 * ===============================================================*/
	
	public function noticeEvent(command:EnumValue):Void
	{
		if (Std.is(command, LogicCommonEvent)){
			throw "未設定";	// TODO:stb
		}else{
			state.noticeEvent(command);
		}
	}
	
	public function setSnapshot(snapshot:Snapshot):Void
	{
		// logicStatusの反映
		logicStatus.setAll(snapshot.logicStatus);
		// 種類に応じる処理
		switch(snapshot.kind)
		{
			case SnapshotKind.Initialize : stateSwitcherGear.changeState(new LogicInitialize());
			case SnapshotKind.Mock1 :  stateSwitcherGear.changeState(new Mock1());
		}
		
	}
}
/**
 * hookに対する定義
 */
interface HookToLogic
{
	/** イベントの発生 */
	public function noticeEvent(command:EnumValue):Void;
	/** スナップショットの適用 */
	public function setSnapshot(snapshot:Snapshot):Void;
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
	/**
	 * 再現時にマウスの位置を表示するためのガイド。
	 * MouseOver時に1秒に１回ほど更新される。
	 * PCでのみ意味があり、スマホ端末では使用しないはず。
	 * 最もデータが重くなるので、場合によってはもっと間引く
	 */
	MouseGuide(point:Point<Int>);
}
