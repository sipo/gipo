package ;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.state.GenericStateSwitcherGearHolder;
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
	private var top:TopGear;
	
	/** コンストラクタ */
	public function new() 
	{
		top = new TopGear();
		// 一番上は最初に、initializeTopを呼び出すことで動き出す。
		// 引数は基本的にはnull
		top.getGear().initializeTop(null);
	}
	
}

/**
 * ギア構造の一番上を担当する。
 * 同時に、gearSwitcherを担当する。
 * GenericStateSwitcherGearHolder、もしくはStateSwitcherGearHolderImplを使用する。
 * StateSwitcherGearHolderImplのほうが低レベルで、シーン切り替わり時に共通で何かをしたければこっちを使うのがいい
 * 
 * @auther sipo
 */
class TopGear extends GenericStateSwitcherGearHolder<ChildState>	// 子をGenericで指定する
{
	
	/**
	 * コンストラクタ
	 * コンストラクタでは引数の受付と、各種ハンドラ関数を登録する役割になる。初期化処理をなるべくしない。
	 */
	public function new() 
	{
		super();
		// 各種ハンドラ関数を登録する
		gear.addDiffusibleHandler(initialize);
		gear.addRunHandler(run);
	}
	
	/*
	 * 初期化処理
	 * 
	 * 初期化処理内では、diffuseが使用可能になる。
	 * 必ず初期化タイミングで使用し、以後は使用不可能。
	 * diffuseする対象はGearHolderであってもなくても構わない
	 * 対象のクラスをキーにして登録する。同一クラスが複数必要な場合、diffuseWithKeyを使う
	 * 
	 * このメソッド内で、gear.addChildは使用できないが、代わりにtool.bookChildが使用可能である。
	 * これは、このメソッドが終了した後に、登録した対象を自動的にgear.addChildしてくれる機能である。
	 * 
	 * 各種インスタンスは基本的に、初期化→（必要なら）diffuse→（必要なら）addChild→消去処理と登録する。
	 * 消去処理を関数登録するのは、消去処理忘れを防ぎ、メモリーリークを起こさないようにするためである。
	 * 消去処理はGearHolderが階層構造から外れる際に自動的に、登録の逆順で呼び出される。
	 * 
	 */
	private function initialize(tool:GearDiffuseTool):Void
	{
		trace("TopGearの初期化処理");
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		trace("TopGearの処理が開始");
		
		stateSwitcherGear
		
		Timer.delay(delay, 5000);
	}
	
	/* 時間差で消去処理をする */
	private function delay():Void
	{
		trace("TopGearの消去");
		gear.disposeTop();	// 最上位Gearとして消去する
		// どこかのGearHolderがremoveChildされるか、最上位のdisposeTopが呼び出されると
		// それ以下の階層構造の全てのGearが切り離されることになり、全ての消去処理が実行される。
	}
}
/**
 * 子かつStateの基礎クラス
 * 
 * @author sipo
 */
class ChildState exteds 
{
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
}
