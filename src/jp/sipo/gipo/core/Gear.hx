package jp.sipo.gipo.core;
/**
 * Gipoの基礎となるクラス
 * 処理の最小単位を担当し、ツリー構造を形成する
 * 
 * @author sipo
 */
import Type;
import AutoAbsorber.Absorber;
import Reflect;
import haxe.rtti.Meta;
import jp.sipo.util.SipoError;
import jp.sipo.gipo.util.PosWrapper;
import jp.sipo.gipo.util.TaskList;
import jp.sipo.gipo.core.config.AddBehaviorPreset;
import haxe.PosInfos;
enum GearPhase
{
	/* 生成時（初期値） */
	Create;
	/* 初期化中 */
	Diffusible;
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
class Gear implements GearOutside
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
		diffuser = new Diffuser(holder);
		needTasks = new Array();
		// HandlerListの初期化
		diffusibleHandlerList = new TaskList(AddBehaviorPreset.addTail, true);
		runHandlerList = new TaskList(AddBehaviorPreset.addTail, true);
		disposeTaskStack = new TaskList(AddBehaviorPreset.addHead, true);
		// タスク数の設定
		addNeedTask(GearNeedTask.Core);
	}
	
	/* ================================================================
	 * フェーズチェック共有
	 * ===============================================================*/
	
	/* Create時チェック */
	inline private function checkPhaseCreate(messageFunc:Void -> String):Void
	{
		switch(phase)
		{
			case GearPhase.Create: 
			case GearPhase.Diffusible, GearPhase.Fulfill, GearPhase.Middle, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError(messageFunc());
		}
	}
	
	/* Initialize時チェック */
	inline private function checkPhaseDiffusible(messageFunc:Void -> String):Void
	{
		switch(phase)
		{
			case GearPhase.Diffusible: 
			case GearPhase.Create, GearPhase.Fulfill, GearPhase.Middle, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError(messageFunc());
		}
	}
	
	/* Initialize時チェック */
	inline private function checkPhaseBeforeDispose(messageFunc:Void -> String):Void
	{
		switch(phase)
		{
			case GearPhase.Create, GearPhase.Diffusible, GearPhase.Fulfill, GearPhase.Middle: 
			case GearPhase.Dispose, GearPhase.Invalid: throw new SipoError(messageFunc());
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
		checkPhaseCreate(function () return 'このメソッドはコンストラクタのみで使用可能です');
		diffusibleHandlerList.add(function (){
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
		checkPhaseCreate(function () return 'このメソッドはコンストラクタのみで使用可能です');
		runHandlerList.add(run, pos);
	}
	
	/**
	 * 消去処理の追加。実行は追加の逆順で行われる
	 */
	public function disposeTask(func:Void -> Void, ?pos:PosInfos):Void
	{
		checkPhaseBeforeDispose(function () return '既に消去処理が開始されているため、消去時のハンドラを登録できません phase=$phase');
		// 消去処理リストに保持しておく
		disposeTaskStack.add(func, pos);
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
		checkPhaseCreate(function () return '既に親子関係が生成されたインスタンス(${this})をtopに設定しようとしました');
		// 初期化
		initializeCommon(parentDiffuser);
	}
	
	/* 子として追加された場合の動作 */
	private function setParent(parent:Gear):Void
	{
		checkPhaseCreate(function () return '既に親子関係が生成されたインスタンス(${this})を${parent}の子に設定しようとしました');
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
		phase = GearPhase.Diffusible;	// 初期化状態
		// Absorbの自動化
		autoAbsorb();
		// 登録されたdiffusible関数の呼び出し
		diffusibleHandlerList.execute();
		diffusibleHandlerList = null;
		// 予約履行フェーズ
		phase = GearPhase.Fulfill;	
		fulfill();
		// 処理中フェーズ
		phase = GearPhase.Middle;
		endNeedTask(GearNeedTask.Core);
	}
	/* Absorbの自動化 */
	private function autoAbsorb():Void
	{
		if (!Std.is(holder, AutoAbsorber)) return;	// autoAbsorberの時だけ対応する
		var holderClass:Class<Dynamic> = Type.getClass(holder);
		while(holderClass != null)
		{
			var metaData = Meta.getFields(holderClass);
			for (name in Reflect.fields(metaData))
			{
				var metaTags = Reflect.field(metaData, name);
				var classKeyTypeData = Reflect.field(metaTags, Absorber.ABSORB_TAG);
				if (classKeyTypeData != null)
				{
					Reflect.setField(holder, name, absorb(Type.resolveClass(classKeyTypeData[0])));	// ２重変換になっているが、意味的に仕方ない
				}
				var enumKeyTypeData = Reflect.field(metaTags, Absorber.ABSORB_WITH_KEY_TAG);
				if (enumKeyTypeData != null)
				{
					if (classKeyTypeData != null) throw '$holder の $name に２重にabsorbメタデータが存在します。';
					var enumKey:EnumValue = Type.createEnum(Type.resolveEnum(enumKeyTypeData[0]), enumKeyTypeData[1]);
					Reflect.setField(holder, name, absorbWithEnum(enumKey));
				}
			}
			holderClass = Type.getSuperClass(holderClass);	// 継承元もチェック
		}
	}
	/* 予約の履行 */
	private function fulfill():Void
	{
		for (childWrapper in bookChildList) addChild(childWrapper.value, childWrapper.pos);
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
		checkPhaseCreate(function () return 'initializeTaskの追加はコンストラクタで行なって下さい${key}');
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
	public function absorb(clazz:Class<Dynamic>, ?pos:PosInfos):Dynamic
	{
		return diffuser.get(clazz, pos);
	}
	
	/**
	 * diffuseインスタンスをキーで取得する
	 */
	public function absorbWithEnum(enumKey:EnumValue, ?pos:PosInfos):Dynamic
	{
		return diffuser.getWithEnum(enumKey, pos);
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
		diffuserAdd(diffuseInstance, clazz, false);	// 追加処理
	}
	/* 内部処理 */
	inline private function diffuserAdd(diffuseInstance:Dynamic, clazz:Class<Dynamic>, fromOther:Bool):Void
	{
		diffuseBeforeCheck(diffuseInstance, fromOther);
		if (!Std.is(diffuseInstance, clazz)) throw '型の違うインスタンスがdiffuseされています $diffuseInstance $clazz';
		diffuser.add(diffuseInstance, clazz);	// 追加処理
	}
	inline private function diffuseBeforeCheck(diffuseInstance:Dynamic, fromOther:Bool):Void
	{
		if (fromOther) checkPhaseCreate(function () return '別Gearにdiffuseする場合はそれがaddChildされる前に行わなければなりません');
		else checkPhaseDiffusible(function () return '処理の順序が間違っています。diffuseは、diffusibleメソッドの中で追加されなければいけません');
		if (diffuseInstance == null) throw 'diffuseされるインスタンスがありません $diffuseInstance';
	}
	
	/**
	 * diffuseインスタンスをキーによって追加する
	 * @gearDispose
	 */
	@:allow(jp.sipo.gipo.core.GearDiffuseTool)
	private function diffuseWithEnum(diffuseInstance:Dynamic, enumKey:EnumValue):Void
	{
		diffuserAddWithEnum(diffuseInstance, enumKey, false);	// 追加処理
	}
	/* 内部処理 */
	inline private function diffuserAddWithEnum(diffuseInstance:Dynamic, enumKey:EnumValue, fromOther:Bool):Void
	{
		diffuseBeforeCheck(diffuseInstance, fromOther);
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
		checkPhaseDiffusible(function () return "処理の順序が間違っています。addChildDelayは、initializeメソッドの中で追加されなければいけません");
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
	public function addChild(child:GearHolder, ?pos:PosInfos):Void
	{
		addChildGear(getGear(child), pos);
	}
	inline private function addChildGear(childGear:Gear, pos:PosInfos):Void
	{
		switch(phase)
		{
			case GearPhase.Create, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError("Gearは処理中にしか子を登録することはできません。(" + phase + ") $pos");
			case GearPhase.Diffusible : throw new SipoError("initialize時のaddChildは、明示的にaddChildDelayを使用してください。(" + phase + ") $pos");
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
		return gearHolder.gearOutside().getImplement();
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
	 * 外部からDiffuseを行なう
	 * @gearDispose
	 */
	public function otherDiffuse(diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void
	{
		diffuserAdd(diffuseInstance, clazz, true);	// 追加処理
	}
	
	/**
	 * 外部からキーによるDiffuseを行なう
	 * @gearDispose
	 */
	public function otherDiffuseWithEnum(diffuseInstance:Dynamic, key:EnumValue):Void
	{
		diffuserAddWithEnum(diffuseInstance, key, true);	// 追加処理
	}
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[Gear holder=$holder phase=$phase childList=${childGearList.length} needTasks=$needTasks]';
	}
}
enum GearNeedTask
{
	Core;
}
