package jp.sipo.gipo.core;
/**
 * Gipoの基礎となるクラス
 * 処理の最小単位を担当し、ツリー構造を形成する
 * 
 * @author sipo
 */
import jp.sipo.gipo.core.handler.GearDispatcherAddBehavior;
import jp.sipo.gipo.core.handler.GearDispatcherHandler;
import jp.sipo.gipo.core.handler.AutoHandlerDispatcher;
import jp.sipo.gipo.core.handler.GearDispatcherFlexible;
import jp.sipo.gipo.core.handler.GenericGearDispatcher;
import jp.sipo.gipo.core.handler.GearDispatcher;
import jp.sipo.gipo.core.handler.GearDispatcherRedTape;
import haxe.rtti.Meta;
import jp.sipo.util.SipoError;
import jp.sipo.gipo.util.PosWrapper;
import jp.sipo.gipo.core.handler.AddBehaviorPreset;
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
private typedef EnumValueName = String;
private typedef EnumName = String;
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
	private var diffusibleHandlerList:GearDispatcherFlexible<GearDiffuseTool -> Void>;
	private var runHandlerList:GearDispatcher;
	private var bubbleHandlerList:GearDispatcher;
	private var disposeTaskStack:GearDispatcher;
	
	
	
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
		diffusibleHandlerList = dispatcherFlexible(AddBehaviorPreset.addTail, true, GearDispatcherKind.Diffusible);
		runHandlerList = dispatcher(AddBehaviorPreset.addTail, true, GearDispatcherKind.Run);
		bubbleHandlerList = dispatcher(AddBehaviorPreset.addHead, true, GearDispatcherKind.Bubble);
		disposeTaskStack = new GearDispatcher(AddBehaviorPreset.addHead, true);
		// タスク数の設定
		addNeedTask(GearNeedTask.Core);
	}
	
	/* ================================================================
	 * 自動登録可能なイベントハンドラのリストを生成する
	 * ===============================================================*/
	
	// TODO:移動の検討
	/**
	 * 通常の、引数なし関数を呼び出す
	 */
	public function dispatcher(addBehavior:GearDispatcherAddBehavior<Void -> Void>, once:Bool, key:EnumValue, ?pos:PosInfos):GearDispatcher
	{
		var dispatcher:GearDispatcher = new GearDispatcher(addBehavior, once, pos);
		setDispatcher(key, dispatcher);
		return dispatcher;
	}
	public function dispatcherFlexible<ArgumentsHandler>(addBehavior:GearDispatcherAddBehavior<ArgumentsHandler>, once:Bool, key:EnumValue, ?pos:PosInfos):GearDispatcherFlexible<ArgumentsHandler>
	{
		var dispatcher:GearDispatcherFlexible<ArgumentsHandler> = new GearDispatcherFlexible<ArgumentsHandler>(addBehavior, once, pos);
		setDispatcher(key, dispatcher);
		return dispatcher; 
	}
	public function dispatcherRedTape(key:EnumValue, ?pos:PosInfos):GearDispatcherRedTape
	{
		var dispatcher:GearDispatcherRedTape = new GearDispatcherRedTape(pos);
		setRedTapeDispatcher(key, dispatcher);
		return dispatcher;
	}
	
	/* 自動登録対象のHandler登録を保持する */
	private var dispatcherMap:Map<EnumValueName, AutoHandlerDispatcher> = new Map<EnumValueName, AutoHandlerDispatcher>();
	/* 自動登録対象のRedTapeHandler登録を保持する */
	private var dispatcherRedTapeMap:Map<EnumValueName, GearDispatcherRedTape> = new Map<EnumValueName, GearDispatcherRedTape>();
	
	/* 自動登録するDispatcherとそのキーを登録 */
	private function setDispatcher(key:EnumValue, dispatcher:AutoHandlerDispatcher):Void
	{
		var keyName:EnumValueName = createEnumValueName(key);
		if (dispatcherMap.exists(keyName)) throw 'Dispatcherが２重登録されました。$key';
		dispatcherMap.set(keyName, dispatcher);
	}
	/* EnumValueを指示するユニークな文字列 */
	inline private function createEnumValueName(enumValue:EnumValue):EnumValueName
	{
		return createEnumValueName_(Type.getEnumName(Type.getEnum(enumValue)), Type.enumConstructor(enumValue));
	}
	inline private function createEnumValueName_(enumName:EnumName, enumConstractor:String):EnumValueName
	{
		return enumName + "#" + enumConstractor;
	}
	
	/* 自動登録するRedTapeDispatcherとそのキー、ロールを登録 */
	private function setRedTapeDispatcher(key:EnumValue, dispatcher:GearDispatcherRedTape):Void
	{
		var keyName:EnumValueName = createEnumValueName(key);
		if (dispatcherRedTapeMap.exists(keyName)) throw 'RedTapeDispatcherが２重登録されました。$key';
		dispatcherRedTapeMap.set(keyName, dispatcher);
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
		// 初期登録のの自動化
		autoInitialize();
		// 登録されたdiffusible関数の呼び出し
		var diffuseTool:GearDiffuseTool = new GearDiffuseTool(this);
		diffusibleHandlerList.execute(function (handler:GearDispatcherHandler<GearDiffuseTool -> Void>){
			handler.func(diffuseTool);
		});
		diffuseTool.dispose();
		diffusibleHandlerList = null;
		// 予約履行フェーズ
		phase = GearPhase.Fulfill;	
		fulfill();
		// 処理中フェーズ
		phase = GearPhase.Middle;
		endNeedTask(GearNeedTask.Core);
	}
	/* Absorbとハンドラの自動化 */
	private function autoInitialize():Void
	{
		// 各フラグ用インターフェースを実装しているかチェックする
		var isAutoAbsorb:Bool = Std.is(holder, AutoAbsorb);
		var isAutoHandler:Bool = Std.is(holder, AutoHandler);
		// どちらもなければ対応しない
		if (!isAutoAbsorb && !isAutoHandler) return;
		// 設定の開始
		var holderClass:Class<Dynamic> = Type.getClass(holder);
		while(holderClass != null)	// 継承元もチェックするためループが必要
		{
			var metaData = Meta.getFields(holderClass);
			for (name in Reflect.fields(metaData))	// 全フィールドをチェック
			{
				var metaTags = Reflect.field(metaData, name);
				// メタデータの取り出し共通処理
				var lastGearTag:String = null;
				var trim = function (tag:String, chew:Array<Dynamic> -> Void):Void
				{
					// キーを取り出し
					var keyArguments:Array<Dynamic> = Reflect.field(metaTags, tag);
					if (keyArguments != null){	// キーがあるなら
						// ２重に無いかチェック
						if (lastGearTag != null) throw '$holder の $name に２重にGearメタデータタグが存在します。 [${lastGearTag}, ${tag}]';
						lastGearTag = tag;
						// 下に記載されている個別チェックを起動する
						chew(keyArguments);
					}
				};
				// Absorbのチェック
				if (isAutoAbsorb){
					// @:absorbへの対応
					trim(AutoAbsorb.AutoAbsorbTag.ABSORB_TAG, function (keyArguments:Array<Dynamic>)
					{
						Reflect.setField(holder, name, absorb(Type.resolveClass(keyArguments[0])));	// ２重変換になっているが、意味的に仕方ない
					});
					// @:absorbWithKeyへの対応
					trim(AutoAbsorb.AutoAbsorbTag.ABSORB_WITH_KEY_TAG, function (keyArguments:Array<Dynamic>)
					{
						var enumKey:EnumValue = Type.createEnum(Type.resolveEnum(keyArguments[0]), keyArguments[1]);
						Reflect.setField(holder, name, absorbWithEnum(enumKey));
					});
				}
				// Handlerのチェック
				if (isAutoHandler){
					// @:handlerへの対応
					trim(AutoHandler.AutoHandlerTag.HANDLER_TAG, function (keyArguments:Array<Dynamic>)
					{
						var enumValueName:EnumValueName = createEnumValueName_(keyArguments[0], keyArguments[1]);
						var dispatcher:AutoHandlerDispatcher = dispatcherMap.get(enumValueName);
						dispatcher.autoAdd(Reflect.field(holder, name), createDummyPosInfos(holderClass, name));
					});
					// @:redTapeHandlerへの対応
					trim(AutoHandler.AutoHandlerTag.RED_TAPE_HANDLER_TAG, function (keyArguments:Array<Dynamic>)
					{
						var enumValueName:EnumValueName = createEnumValueName_(keyArguments[0], keyArguments[1]);
						var roleName:EnumName = keyArguments[2];
						var dispatcher:GearDispatcherRedTape = dispatcherRedTapeMap.get(enumValueName);
						dispatcher.setFromName(roleName, Reflect.field(holder, name), createDummyPosInfos(holderClass, name));
					});
				}
			}
			holderClass = Type.getSuperClass(holderClass);	// 継承元もチェック
		}
	}
	private function createDummyPosInfos(holderClass:Class<Dynamic>, methodName:String):PosInfos
	{
		return {
			fileName:"",
			lineNumber:0,
			className:Type.getClassName(holderClass),
			methodName:methodName
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
		if (needTasks.length != 0) return;	
		// タスクが無くなったら、runへ進む
		runHandlerList.execute();
		runHandlerList = null;
		bubbleHandlerList.execute();
		bubbleHandlerList = null;
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
			case GearPhase.Diffusible : throw new SipoError("phase=${phase}の時のaddChildは、明示的にaddChildDelayを使用してください。(" + phase + ") $pos");
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
		if (phase == GearPhase.Dispose) throw '既に削除されているGear（${this}）をさらに削除しようとしました。Gearは上位層のGearが削除されると自動的に削除されるため、手動での消去には気をつけてください';
		phase = GearPhase.Dispose;
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
enum GearDispatcherKind
{
	Run;
	Diffusible;
	Bubble;
}
//private enum DispatcherWraper	// FIXME:必要性についてチェック
//{
//	Normal(value:GearDispatcher);
//	Flexible(value:GearDispatcherFlexible<Dynamic>);
//}
