package jp.sipo.gipo.core;
/**
 * Gipoの基礎となるクラス
 * 処理の最小単位を担当し、ツリー構造を形成する
 * 
 * @author sipo
 */
import jp.sipo.util.SipoError;
import jp.sipo.gipo.util.PosWrapper;
import jp.sipo.gipo.util.TaskList;
import jp.sipo.gipo.core.config.StackAddBehavior;
import haxe.PosInfos;
enum GearPhase
{
	/* 生成時（初期値） */
	Create;
	/* 初期化中 */
	Initialize;
	/* 初期化で予約されたものの実行 */
	Fulfill;
	/* メイン処理中 */
	Middle;
	/* 消去中 */
	Dispose;
	/* 消去が終了し、無効化された状態 */
	Invalid;
	
}
@:final
class Gear implements GearOut
{
	/* 保持クラス */
	private var holder:GearHolder;
	/** 子 */
	private var childGearList:Array<Gear>;
	/** 親 */
	private var parent:Gear;
	/** インスタンス保持機能 */
	private var diffuser:Diffuser;
	
	/* --------------------------------
	 * 処理順序整理
	 * -------------------------------*/
	
	/* 状況変数 */
	private var phase:GearPhase;
	/* 各種実行関数の登録 */
	private var diffusibleHandlerList:TaskList;
	private var runHandlerList:TaskList;
	private var disposeTaskStack:TaskList;
	/* 子の追加処理の遅延保持 */
	private var bookChildList:Array<PosWrapper<GearHolder>>;
	
	/* 初期化完了に必要なタスク。このタスクリストが全て解除された時に、runが呼び出される。*/
	private var needTasks:Array<EnumValue>;
	
	/* ================================================================
	 * 基礎処理
	 * ===============================================================*/
	
	/**
	 * コンストラクタ
	 */
	public function new(holder:GearHolder)
	{
		this.holder = holder;
		// 初期状態の設定
		phase = GearPhase.Create;
		// 変数初期化
		childGearList = new Array();
		bookChildList = new Array();
		diffuser = new Diffuser();
		needTasks = new Array();
		// HandlerListの初期化
		diffusibleHandlerList = new TaskList(StackAddBehavior.addTail);
		runHandlerList = new TaskList(StackAddBehavior.addTail);
		disposeTaskStack = new TaskList(StackAddBehavior.addHead);
		// タスク数の設定
		addNeedTask(GearNeedTask.Core);
	}
	
	/* ================================================================
	 * フェーズチェック共有
	 * ===============================================================*/
	
	/* Create時チェック */
	private function checkPhaseCreate(message:String):Void
	{
		switch(phase)
		{
			case GearPhase.Create: 
			case GearPhase.Initialize, GearPhase.Fulfill, GearPhase.Middle, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError(message);
		}
	}
	
	/* Initialize時チェック */
	private function checkPhaseInitialize(message:String):Void
	{
		switch(phase)
		{
			case GearPhase.Initialize: 
			case GearPhase.Create, GearPhase.Fulfill, GearPhase.Middle, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError(message);
		}
	}
	
	/* Initialize時チェック */
	private function checkPhaseBeforeDispose(message:String):Void
	{
		switch(phase)
		{
			case GearPhase.Create, GearPhase.Initialize, GearPhase.Fulfill, GearPhase.Middle: 
			case GearPhase.Dispose, GearPhase.Invalid: throw new SipoError(message);
		}
	}
	
	/* ================================================================
	 * ハンドラ登録
	 * ===============================================================*/
	
	/**
	 * 追加された直後の初期化の動作を登録
	 */
	public function addDiffusibleHandler(diffusible:GearDiffuseTool -> Void, ?pos:PosInfos):Void
	{
		checkPhaseCreate('このメソッドはコンストラクタのみで使用可能です');
		diffusibleHandlerList.addTask(function (){
			var diffuseTool:GearDiffuseTool = new GearDiffuseTool(this);
			diffusible(diffuseTool);
			diffuseTool.dispose();
		}, pos);
	}
	
	/**
	 * 初期動作が全て終わった場合の動作を登録
	 */
	public function addRunHandler(run:Void -> Void, ?pos:PosInfos):Void
	{
		checkPhaseCreate('このメソッドはコンストラクタのみで使用可能です');
		runHandlerList.addTask(run, pos);
	}
	
	/**
	 * 消去処理の追加。実行は追加の逆順で行われる
	 */
	public function disposeTask(func:Void -> Void, ?pos:PosInfos):Void
	{
		checkPhaseBeforeDispose('既に消去処理が開始されているため、消去時のハンドラを登録できません phase=$phase');
		// 消去処理リストに保持しておく
		disposeTaskStack.addTask(func, pos);
	}
	
	/* ================================================================
	 * 初期化処理
	 * ===============================================================*/
	
	/**
	 * 最上位Gearとして設定する
	 * 通常のGearが親に追加された時の処理を代わりにしてしまう
	 * 消去する時は、disposeTop
	 * 
	 * @param parentDiffuser diffuserだけ他から親子関係を持つ場合に、親として設定されるdiffuser。nullの場合は親を持たない
	 */
	public function initializeTop(parentDiffuser:Diffuser):Void
	{
		checkPhaseCreate('既に親子関係が生成されたインスタンス(${this})をtopに設定しようとしました');
		// 初期化
		initializeCommon(parentDiffuser);
	}
	
	/* 子として追加された場合の動作 */
	private function setParent(parent:Gear):Void
	{
		checkPhaseCreate('既に親子関係が生成されたインスタンス(${this})を${parent}の子に設定しようとしました');
		// 親を保持
		this.parent = parent;
		// 初期化
		initializeCommon(parent.diffuser);
	}
	
	/* 初期化の共通処理 */
	private function initializeCommon(parentDiffuser:Diffuser):Void
	{
		// 上位Diffuserがあれば設定
		if (parentDiffuser != null) diffuser.setParent(parentDiffuser);
		// 初期動作を呼び出し
		phase = GearPhase.Initialize;	// 初期化状態
		// 登録された初期化関数の呼び出し
		diffusibleHandlerList.execute();
		diffusibleHandlerList = null;
		// 予約履行フェーズ
		phase = GearPhase.Fulfill;	
		fulfill();
		// 処理中フェーズ
		phase = GearPhase.Middle;
		endNeedTask(GearNeedTask.Core);
	}
	/* 予約の履行 */
	private function fulfill():Void
	{
		for (childWrapper in bookChildList) addChild(childWrapper.value);
		bookChildList = null;
	}
	
	/* --------------------------------
	 * initialize必要動作設定
	 * -------------------------------*/
	
	/**
	 * 初期化処理の必要要素を登録し、全てクリアした時に初期化終了時処理を呼び出す。
	 */
	public function addNeedTask(key:EnumValue, ?pos:PosInfos):Void
	{
		if (Lambda.has(needTasks, key)) throw new SipoError('${key}が初期化タスクに２重登録されました');
		checkPhaseCreate('initializeTaskの追加はコンストラクタで行なって下さい${key}');
		needTasks.push(key);
	}
	
	/**
	 * 初期化処理の必要要素
	 */
	public function endNeedTask(key:EnumValue, ?pos:PosInfos):Void
	{
		needTasks.remove(key);
		if (needTasks.length == 0){	// タスクが無くなったら、runへ進む
			runHandlerList.execute();
			runHandlerList = null;
		}
	}
	
	/* --------------------------------
	 * initialize取得補助
	 * -------------------------------*/
	
	/**
	 * diffuseインスタンスを取得する
	 */
	public function absorb(clazz:Class<Dynamic>):Dynamic
	{
		return diffuser.get(clazz);
	}
	
	/**
	 * diffuseインスタンスをキーで取得する
	 */
	public function absorbWithEnum(enumKey:EnumValue):Dynamic
	{
		return diffuser.getWithEnum(enumKey);
	}
	
	/* --------------------------------
	 * initialize設定補助
	 * -------------------------------*/
	
	/**
	 * diffuseインスタンスを追加する
	 * @gearDispose
	 */
	@:allow(jp.sipo.gipo.core.GearDiffuseTool)
	private function diffuse(diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void
	{
		checkPhaseInitialize("処理の順序が間違っています。diffuseは、initializeメソッドの中で追加されなければいけません");
		diffuser.add(diffuseInstance, clazz);	// 追加処理
	}
	
	/**
	 * diffuseインスタンスをキーによって追加する
	 * @gearDispose
	 */
	@:allow(jp.sipo.gipo.core.GearDiffuseTool)
	private function diffuseWithKey(diffuseInstance:Dynamic, enumKey:EnumValue):Void
	{
		checkPhaseInitialize("処理の順序が間違っています。diffuseは、initializeメソッドの中で追加されなければいけません");
		diffuser.addWithEnum(diffuseInstance, enumKey);	// 追加処理
	}
	
	/**
	 * 子の追加を遅延予約する
	 * 
	 * @gearDispose
	 */
	@:allow(jp.sipo.gipo.core.GearDiffuseTool)
	private function bookChild(child:GearHolder, ?pos:PosInfos):Void
	{
		checkPhaseInitialize("処理の順序が間違っています。addChildDelayは、initializeメソッドの中で追加されなければいけません");
		// 後で追加するリストに入れる
		bookChildList.push(new PosWrapper(child, pos)); // posを引き継いで、追加された箇所がわかるように
	}
	
	/* ================================================================
	 * 処理中
	 * ===============================================================*/
	
	/**
	 * 子を追加する
	 * 
	 * @gearDispose
	 */
	public function addChild(child:GearHolder):Void
	{
		addChildGear(getGear(child));
	}
	inline private function addChildGear(childGear:Gear):Void
	{
		switch(phase)
		{
			case GearPhase.Create, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError("Gearは処理中にしか子を登録することはできません。(" + phase + ")");
			case GearPhase.Initialize : throw new SipoError("initialize時のaddChildは、明示的にaddChildDelayを使用してください。(" + phase + ")");
			case GearPhase.Fulfill, GearPhase.Middle : 
		}
		// 追加
		childGearList.push(childGear);
		// 追加後の初期化処理
		childGear.setParent(this);
	}
	
	/**
	 * 子を削除する
	 * 削除した子は再利用できない
	 */
	public function removeChild(child:GearHolder):Void
	{
		removeChildGear(getGear(child));
	}
	inline private function removeChildGear(childGear:Gear):Void
	{
		// 削除前の処理
		childGear.enterRemove();
		// 削除
		childGearList.remove(childGear);
	}
	
	/* Gear内部専用の特殊処理。IGearOutをGearに戻す */
	inline private function getGear(gearHolder:GearHolder):Gear
	{
		return gearHolder.getGear().getImplement();
	}
	/* 実装を返す */
	private function getImplement():Gear
	{
		return this;
	}
	
	/* ================================================================
	 * 削除時
	 * ===============================================================*/
	
	/* 消去された時の動作 */
	private function enterRemove():Void
	{
		// 必要な消去処理を実行
		disposeTaskStack.execute();// 逆順で実行する
		disposeTaskStack = null;
		// 切断処理
		for (childGear in childGearList) removeChild(childGear.holder);	// 下位層をすべて切断
		parent = null;	// 上位層を切断
		// diffuserを消去
		diffuser.dispose();
		diffuser = null;
	}
	
	/**
	 * 親がなくとも動作するGearHolderを消去する
	 */
	public function disposeTop():Void
	{
		enterRemove();
	}
	
	/* ================================================================
	 * 他のGearへの処理
	 * ===============================================================*/
	
	/**
	 * 対象Gearに限定してdiffuseを行う
	 * @gearDispose
	 */
	public function otherDiffuse(target:GearHolder, diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void
	{
		var targetGear:Gear = getGear(target);
		targetGear.otherDiffuse_(diffuseInstance, clazz);
	}
	/* 内部処理 */
	inline private function otherDiffuse_(diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void
	{
		checkPhaseCreate('別Gearにdiffuseする場合はそれがaddChildされる前に行わなければなりません');
		diffuser.add(diffuseInstance, clazz);	// 追加処理
	}
	
	/**
	 * 対象Gearに限定してキーによるdiffuseを行う
	 * @gearDispose
	 */
	public function otherDiffuseWithKey(target:GearHolder, diffuseInstance:Dynamic, key:EnumValue):Void
	{
		target.getGear().getImplement();
		var targetGear:Gear = getGear(target);
		targetGear.otherDiffuseWithKey_(diffuseInstance, key);
	}
	/* 内部処理 */
	inline private function otherDiffuseWithKey_(diffuseInstance:Dynamic, key:EnumValue):Void
	{
		checkPhaseCreate('別Gearにdiffuseする場合はそれがaddChildされる前に行わなければなりません');
		diffuser.addWithEnum(diffuseInstance, key);	// 追加処理
	}
	
	/**
	 * 対象GearのDisposeタイミングに関数の登録を行う
	 * @gearDispose
	 */
	public function otherEntryDispose(target:GearHolder, func:Void -> Void, ?pos:PosInfos):Void
	{
		var targetGear:Gear = getGear(target);
		targetGear.disposeTask(func, pos);
	}
}
enum GearNeedTask
{
	Core;
}
