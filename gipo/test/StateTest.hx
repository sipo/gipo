package ;

import jp.sipo.gipo.core.handler.GenericGearDispatcher;
import jp.sipo.gipo.core.state.StateGearHolder;
import jp.sipo.gipo.core.state.StateSwitcherGear;
import jp.sipo.gipo.core.GearPreparationTool;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import jp.sipo.gipo.core.Gear;
import massive.munit.Assert;

@:access(jp.sipo.gipo.core.state.StateSwitcherGear)
@:access(jp.sipo.gipo.core.handler.GenericGearDispatcher)
@:access(jp.sipo.gipo.core.Gear)
class StateTest
{
	var top:TopSwitcher;
	var childA:ChildStateA;
	var childB:ChildStateB;
	var stateSwitcherGear:StateSwitcherGear;
	var topSwitcherGear:Gear;

	public function new()
	{
	}

	@Before
	public function setup():Void
	{
		top = new TopSwitcher();
		childA = new ChildStateA();
		childB = new ChildStateB();
		stateSwitcherGear = top.getStateSwicherGear();
		topSwitcherGear = top.getStateSwicherGear().gear;
	}

	@After
	public function tearDown():Void
	{
	}

	/**
	* StateSwitcherGearHolderImplクラスのテスト
	* changeStateメソッドをテストすることになるだろう
	* また、stateSwitcherGearを介して、StateSwitcherGearクラスのテストでもよいのかもしれない
	**/
	@Test
	public function changeStateTest():Void
	{
		top.gearOutside().initializeTop(null);
		Assert.areEqual(null, top.state);

		top.changeState(childA);
		Assert.areEqual(childA, top.state);

		top.changeState(childB);
		Assert.areEqual(childB, top.state);
	}

	//何もしないメソッド
	function setEmpty(a:StateGearHolder):Void
	{
	}

	//traceするメソッド
	function traceGear(a:StateGearHolder):Void
	{
		trace(a);
	}

	/**
	* StateSwitcherGearクラスのテスト
	* StateSwitcherGearHolderImplを追うと、changeState内ではStateSwitcherGearクラスが利用されいる
	* よって、StateSwitcherクラスのpublicなものについても全てテストを行う
	* topから
	**/

	@Test
	public function setLastTreatmentHandlerTest():Void
	{
		top.gearOutside().initializeTop(null);
		Assert.isNull(stateSwitcherGear.lastStateTreatment);
		Assert.areEqual(0, topSwitcherGear.childGearList.length);

		//通常通りにchangeStateを行う
		top.changeState(childA);
		Assert.areEqual(1, topSwitcherGear.childGearList.length);

		//lastStateTreatmentをremoveするデフォルトから何もしないものへと変更する
		top.getStateSwicherGear().setLastStateTreatmentHandler(setEmpty);

		/**
		* changeStateを行う。変更していなければ前のstateは削除されるはずだが、何もしないメソッドに変更したので確認をする
		* changeState時、リストにaddChildされているのでchangeStateしたstateは末尾に追加されるはずである
		**/
		top.changeState(childB);
		//削除を行わないので2になるはずである
		Assert.areEqual(2, topSwitcherGear.childGearList.length);
		Assert.areEqual(childA.gearOutside(), topSwitcherGear.childGearList[0]);
		Assert.areEqual(childB.gearOutside(), topSwitcherGear.childGearList[1]);
	}

	/**
	* addEnterStateChangeHandlerをテスト
	* 適用した際にはtopの内部にあるenterStateChangeDispatcher.listに保持される
	* これを利用してaddされているかをテスト
**/
	@Test
	public function addEnterStateChangeHandlerTest():Void
	{
		top.gearOutside().initializeTop(null);

		var funcList = stateSwitcherGear.enterStateChangeDispatcher.list;

		//stateChangeしたときのハンドラは何も設定していないので0
		Assert.areEqual(0, funcList.length);

		//ハンドラを追加
		top.getStateSwicherGear().addEnterStateChangeHandler(setEmpty);
		//ハンドラリストの長さは1になっているはず
		Assert.areEqual(1, funcList.length);

		//もう一度追加してテスト
		top.getStateSwicherGear().addEnterStateChangeHandler(traceGear);
		Assert.areEqual(2, funcList.length);
	}
	/**
	* addStateAssignmentHandlerをテスト
	* addする関数は上で作成したsetEmptyとtraceGear
	**/
	@Test
	public function addStateAssignmentHandlerTest():Void
	{
		top.gearOutside().initializeTop(null);

		var assignmentList = stateSwitcherGear.stateAssignmentList;

		// 初期状態をテスト
		// TopをStateSwitcherGearHolderImplを継承して作成しているので
		// assignmentListに処理がひとつあるので1が初期状態になる
		Assert.areEqual(1, assignmentList.length);

		//ハンドラを追加
		top.getStateSwicherGear().addStateAssignmentHandler(setEmpty);
		Assert.areEqual(2, assignmentList.length);

		//もういちど追加
		top.getStateSwicherGear().addStateAssignmentHandler(traceGear);
		Assert.areEqual(3, assignmentList.length);
	}
}

class TopSwitcher extends StateSwitcherGearHolderImpl<ChildState>
{
	/** コンストラクタ */
	public function new()
	{
		super();
	}

	public function getStateSwicherGear():StateSwitcherGear
	{
		return this.stateSwitcherGear;
	}

	/* 初期化処理 */
	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearPreparationTool):Void
	{
		tool.diffuse(this, TopSwitcher); // この階層以下で、このインスタンスを取得できるようにする
	}
}

class ChildState extends StateGearHolderImpl
{
	@:absorb // 自動的にTopSwitcherを取得する（diffusibleの直前）
	private var switcher:TopSwitcher;
	/** コンストラクタ */
	public function new()
	{
		super();
	}

	/* 初期化後処理（Haxeの仕様上、継承先と名前が被らないようにしないといけない） */
	@:handler(GearDispatcherKind.Run)
	private function stateRun():Void
	{
	}
}

class ChildStateA extends ChildState
{
	/** コンストラクタ */
	public function new()
	{
		super();
	}
}

class ChildStateB extends ChildState
{
	/** コンストラクタ */
	public function new()
	{
		super();
	}
}
