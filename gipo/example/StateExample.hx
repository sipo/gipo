package ;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.util.Note;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import haxe.Timer;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import jp.sipo.gipo.core.GearHolderImpl;
class StateExample
{

	/* メインインスタンス */
	private static var _main:StateExample;
	/**
	 * 起動関数
	 */
	public static function main():Void
	{
		_main = new StateExample();
	}
	
	/* 最上位のGear */
	private var top:TopSwitcher;
	
	/** コンストラクタ */
	public function new() 
	{
		top = new TopSwitcher();
		// 一番上は最初に、initializeTopを呼び出すことで動き出す。
		// 引数は基本的にはnull
		top.gearOutside().initializeTop(null);
	}
	
}

/**
 * ギア構造の一番上を担当する。
 * 同時に、gearSwitcherを担当する。
 * 
 * @auther sipo
 */
class TopSwitcher extends StateSwitcherGearHolderImpl<ChildState>	// 子をGenericで指定する
{
	/** コンストラクタ */
	public function new() { super(); }
	
	/* 初期化処理 */
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		trace("TopGearの初期化処理");
		tool.diffuse(this, TopSwitcher);	// この階層以下で、このインスタンスを取得できるようにする
	}
	
	/* 初期化後処理 */
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		trace("TopGearの処理が開始");
		// 初期Stateの登録
		stateSwitcherGear.changeState(new ChildStateA());
	}
}
/**
 * 子かつStateの基礎クラス
 * 
 * @author sipo
 */
class ChildState extends StateGearHolderImpl
{
	@:absorb	// 自動的にTopSwitcherを取得する（diffusibleの直前）
	private var switcher:TopSwitcher;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	/* 初期化後処理（Haxeの仕様上、継承先と名前が被らないようにしないといけない） */
	@:handler(GearDispatcherKind.Run)
	private function stateRun():Void
	{
		// stateの共通処理は、それぞれがchangeStateされた時に最初に呼び出されることになる。
		trace('${this}のChildState共通処理');
	}
}
/**
 * 仮想StateA
 * 
 * @author sipo
 */
class ChildStateA extends ChildState
{
	/** コンストラクタ */
	public function new() { super(); }
	
	/* 初期化後処理 */
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		trace("ChildStateAの処理が開始");
		// 時間差で切り替え処理
		Timer.delay(changeState, 2000);
	}
	
	/* Bに切り替える */
	private function changeState():Void
	{
		// 次のStateに切り替え
		switcher.changeState(new ChildStateB());	// 基本的にはStateは毎回作りなおされる
		// Stateを毎回破棄したくない場合は、stateSwitcherGear.setHandlerLastStateTreatmentを使用して、破棄処理を上書きする
		// ただし、どちらにせよ一度stateに使ったものは、２度使うことは出来ない。
	}
}
/**
 * 仮想StateB
 * 
 * @author sipo
 */
class ChildStateB extends ChildState
{
	/** コンストラクタ */
	public function new() { super(); }
	
	/* 初期化後処理 */
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		trace("ChildStateBの処理が開始");
		// 時間差で切り替え処理
		Timer.delay(changeState, 2000);
	}
	
	/* Bに切り替える */
	private function changeState():Void
	{
		// 次のStateに切り替え
		switcher.changeState(new ChildStateA());
	}
}
