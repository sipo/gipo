package jp.sipo.gipo.core;
/**
 * Gipoの基礎となるクラス
 * 処理の最小単位を担当し、ツリー構造を形成する
 * 
 * @author sipo
 */
import jp.sipo.gipo.core.handler.CancelKey;
import Type;
import jp.sipo.util.SipoError;
import jp.sipo.util.SipoError;
import jp.sipo.gipo.core.handler.GearDispatcherHandler;
import jp.sipo.gipo.core.handler.GearDispatcherFlexible;
import jp.sipo.gipo.core.handler.GearDispatcher;
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
	/* 削除キャンセルキー */
	private var removeCancelKey:CancelKey;
	
	/* --------------------------------
	 * 処理順序整理
	 * -------------------------------*/
	
	/* absorbとhandlerの自動化が無効かされているか */
	private var autoInitializerDisabled:Bool = false;
	/* 状況変数 */
	private var phase:GearPhase;
	/* 各種実行関数の登録 */
	private var diffusibleHandlerList:GearDispatcherFlexible<GearDiffuseTool -> Void>;
	private var runDispatcher:GearDispatcher;
	private var bubbleHandlerList:GearDispatcher;
	private var disposeTaskStack:GearDispatcher;
	
	/* --------------------------------
	 * 処理リスト
	 * -------------------------------*/
	
	/* 子の追加処理の遅延保持 */
	private var bookChildList:Array<PosWrapper<GearHolder>>;
	
	/* 初期化完了に必要なタスク。このタスクリストが全て解除された時に、runが呼び出される。*/
	private var needTasks:Array<EnumValue>;
	
	/* --------------------------------
	 * デバッグデータ
	 * -------------------------------*/
	 
	/* absorbした変数などの情報 */
	private var absorbLogList:Array<AbsorbLog>;
	/* absorbした変数などの情報 */
	private var absorbWithKeyLogList:Array<AbsorbLog>;
	
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
		// HandlerListの初期化
		diffusibleHandlerList = new GearDispatcherFlexible(AddBehaviorPreset.addTail, true);
		runDispatcher = new GearDispatcher(AddBehaviorPreset.addTail, true);
		bubbleHandlerList = new GearDispatcher(AddBehaviorPreset.addHead, true);
		disposeTaskStack = new GearDispatcher(AddBehaviorPreset.addHead, true);
		// 変数初期化
		childGearList = new Array();
		bookChildList = new Array();
		diffuser = new Diffuser(holder);
		needTasks = new Array();
		
		absorbLogList = new Array();
		disposeTask(function () absorbLogList = null);
		absorbWithKeyLogList = new Array();
		disposeTask(function () absorbWithKeyLogList = null);
		
		// タスク数の設定
		addNeedTask(GearNeedTask.Core);
	}
	
	
	/* ================================================================
	 * フェーズチェック共有
	 * ===============================================================*/
	
	/* Create時チェック */
	inline private function checkPhaseCreate():Bool
	{
		return switch(phase)
		{
			case GearPhase.Create: true;
			case GearPhase.Diffusible, GearPhase.Fulfill, GearPhase.Middle, GearPhase.Dispose, GearPhase.Invalid: false;
		}
	}
	
	/* DiffuseTool可能時チェック */
	inline private function checkPhaseCanDiffuseTool():Bool
	{
		return switch(phase)
		{
			case GearPhase.Diffusible: true;
			case GearPhase.Create, GearPhase.Fulfill, GearPhase.Middle, GearPhase.Dispose, GearPhase.Invalid: false;
		}
	}
	
	/* Absorb可能かのチェック（DiffuseTool+MiddleTool） */
	inline private function checkPhaseCanAbsorb():Bool
	{
		return switch(phase)
		{
			case GearPhase.Diffusible, GearPhase.Fulfill, GearPhase.Middle: true;
			case GearPhase.Create, GearPhase.Dispose, GearPhase.Invalid: false;
		}
	}
	
	/* MiddleTool可能かのチェック */
	inline private function checkPhaseCanMiddleTool():Bool
	{
		return switch(phase)
		{
			case GearPhase.Fulfill, GearPhase.Middle: true;
			case GearPhase.Create, GearPhase.Diffusible, GearPhase.Dispose, GearPhase.Invalid: false;
		}
	}
	
	/* 無効前かどうか（まだGearHolderが生きているか）のチェック */
	inline private function checkPhaseBeforeDispose():Bool
	{
		return switch(phase)
		{
			case GearPhase.Create, GearPhase.Diffusible, GearPhase.Fulfill, GearPhase.Middle: true;
			case GearPhase.Dispose, GearPhase.Invalid: false;
		}
	}
	
	/* ================================================================
	 * 削除タスク
	 * ===============================================================*/
	
	/**
	 * 消去処理の追加。実行は追加の逆順で行われる
	 */
	public function disposeTask(func:Void -> Void, ?pos:PosInfos):CancelKey
	{
		if (!checkPhaseBeforeDispose()) throw new SipoError('既に消去処理が開始されているため、消去時のハンドラを登録できません phase=$phase');
		// 消去処理リストに保持しておく
		return disposeTaskStack.add(func, pos);
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
		if (!checkPhaseCreate()) throw new SipoError('既に親子関係が生成されたインスタンス(${this})をtopに設定しようとしました');
		// 初期化
		initializeCommon(parentDiffuser);
	}
	
	/* 削除キャンセルのキーを登録 */
	private function setRemoveCancelKey(key:CancelKey):Void
	{
		this.removeCancelKey = key;
	}
	
	/* 子として追加された場合の動作 */
	private function setParent(parent:Gear):Void
	{
		if (!checkPhaseCreate()) throw new SipoError('既に親子関係が生成されたインスタンス(${this})を${parent}の子に設定しようとしました');
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
	
	/* AbsorbとHandlerの自動化を禁止する */
	private function disableAutoInitialize():Void
	{
		autoInitializerDisabled = true;
	}
	/* Absorbとハンドラの自動化 */
	private function autoInitialize():Void
	{
		// 自動化が無効化されていたら中断する
		if (autoInitializerDisabled) { return; }
		// 各フラグ用インターフェースを実装しているかチェックする
		var isAutoAbsorb:Bool = Std.is(holder, AutoAbsorb);
		// 実装していなければ対応しない
		if (!isAutoAbsorb) return;
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
				// Absorbのチェック
				if (isAutoAbsorb){
					// @:absorbへの対応
					trim(AutoAbsorb.AutoAbsorbTag.ABSORB_TAG, metaTags, name, lastGearTag, holderClass);
					// @:absorbWithKeyへの対応
					trim(AutoAbsorb.AutoAbsorbTag.ABSORB_WITH_KEY_TAG, metaTags, name, lastGearTag, holderClass);
				}
			}
			holderClass = Type.getSuperClass(holderClass);	// 継承元もチェック
		}
	}
	
	private function trim(tag:String, metaTags:Dynamic, name:String, lastGearTag:String, holderClass:Class<Dynamic>):Void {
		// キーを取り出し
		var keyArguments:Array<Dynamic> = Reflect.field(metaTags, tag);
		if (keyArguments != null){	// キーがあるなら
			// ２重に無いかチェック
			if (lastGearTag != null) throw '$holder の $name に２重にGearメタデータタグが存在します。 [${lastGearTag}, ${tag}]';
			lastGearTag = tag;
			// 下に記載されている個別チェックを起動する
			switch (tag) {
				case AutoAbsorb.AutoAbsorbTag.ABSORB_TAG :
					initializeAbsorbTag(keyArguments, name);
				case AutoAbsorb.AutoAbsorbTag.ABSORB_WITH_KEY_TAG :
					initializeAbsorbWithKeyTag(keyArguments, name);
				default :
					throw '予期していないタグ ${tag} が検出されました。';
			}
		}
	}
	
	private function initializeAbsorbTag(keyArguments:Array<Dynamic>, name:String)
	{
		var className:String = keyArguments[0];
		var target:Dynamic = absorb(Type.resolveClass(className));
		Reflect.setField(holder, name, target);	// ２重変換になっているが、意味的に仕方ない
		absorbLogList.push(new AbsorbLog(name, className, target));
	}
	
	private function initializeAbsorbWithKeyTag(keyArguments:Array<Dynamic>, name:String)
	{
		var enumName:String = keyArguments[0];
		var enumConstractorName:String = keyArguments[1];
		var enumKey:EnumValue = Type.createEnum(Type.resolveEnum(enumName), enumConstractorName);
		var target:Dynamic = absorbWithKey(enumKey);
		Reflect.setField(holder, name, target);
		absorbWithKeyLogList.push(new AbsorbLog(name, '$enumName # $enumConstractorName', target));
	}
	
	/**
	 * Diffusibleハンドラの追加
	 */
	public function addDiffusibleHandler(func:GearDiffuseTool -> Void, ?pos:PosInfos):Void
	{
		diffusibleHandlerList.add(func, pos);
	}
	// TODO:<<尾野>>diffusible→preparation
	
	/**
	 * Runハンドラの追加
	 */
	public function addRunHandler(func:Void->Void, ?pos:PosInfos):Void
	{
		runDispatcher.autoAdd(func, pos);
	}
	
	/**
	 * Bubbleハンドラの追加
	 */
	public function addBubbleHandler(func:Void->Void, ?pos:PosInfos):Void
	{
		bubbleHandlerList.autoAdd(func, pos);
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
		// Lambda.has(needTasks, key) と同じ。最適化のために展開してある。
		for (needTask in needTasks) {
			if (needTask == key) { throw new SipoError('${key}が初期化タスクに２重登録されました'); }
		}
		if (!checkPhaseCreate()) throw new SipoError('initializeTaskの追加はコンストラクタで行なって下さい${key}');
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
		runDispatcher.execute();
		runDispatcher = null;
		bubbleHandlerList.execute();
		bubbleHandlerList = null;
	}
	
	/* --------------------------------
	 * initialize取得補助
	 * -------------------------------*/
	
	/**
	 * diffuseインスタンスを取得する
	 */
	public function absorb<T>(clazz:Class<T>, ?pos:PosInfos):T
	{
		if (!checkPhaseCanAbsorb()) throw new SipoError('absorbは、親のGearHolderにaddChildされた後でなければ使用できません。run以降の関数で使用してください。${this}');
		var ans:T = diffuser.get(clazz, pos);
		if (ans == null) throw new SipoError('absorbに失敗しました。対象class=${clazz} 現在diffuse可能なリスト=\n${diffuser.getDictionaryCondition(diffuser)}');
		return ans;
	}
	
	/**
	 * diffuseインスタンスをキーで取得する
	 */
	public function absorbWithKey(enumKey:EnumValue, ?pos:PosInfos):Dynamic
	{
		if (!checkPhaseCanAbsorb()) throw new SipoError('absorbWithKeyは、親のGearHolderにaddChildされた後でなければ使用できません。run以降の関数で使用してください。${this}');
		var ans:Dynamic = diffuser.getWithKey(enumKey, pos);
		return ans;
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
		if (fromOther)
		{
			if (!checkPhaseCreate()) throw new SipoError('別Gearにdiffuseする場合はそれがaddChildされる前に行わなければなりません');
		}else{
			if (!checkPhaseCanDiffuseTool()) throw new SipoError('処理の順序が間違っています。diffuseは、diffusibleメソッドの中で追加されなければいけません');
		}
		if (diffuseInstance == null) throw 'diffuseされるインスタンスがありません $diffuseInstance';
	}
	
	/**
	 * diffuseインスタンスをキーによって追加する
	 * @gearDispose
	 */
	@:allow(jp.sipo.gipo.core.GearDiffuseTool)
	private function diffuseWithKey(diffuseInstance:Dynamic, enumKey:EnumValue):Void
	{
		diffuserAddWithKey(diffuseInstance, enumKey, false);	// 追加処理
	}
	/* 内部処理 */
	inline private function diffuserAddWithKey(diffuseInstance:Dynamic, enumKey:EnumValue, fromOther:Bool):Void
	{
		diffuseBeforeCheck(diffuseInstance, fromOther);
		diffuser.addWithKey(diffuseInstance, enumKey);	// 追加処理
	}
	
	/**
	 * 子の追加を遅延予約する
	 * 
	 * @gearDispose
	 */
	@:allow(jp.sipo.gipo.core.GearDiffuseTool)
	private function bookChild<T:(GearHolder)>(child:T, ?pos:PosInfos):T
	{
		if (!checkPhaseCanDiffuseTool()) throw new SipoError('処理の順序が間違っています。addChildDelayは、initializeメソッドの中で追加されなければいけません');
		// 後で追加するリストに入れる
		bookChildList.push(new PosWrapper<GearHolder>(child, pos)); // posを引き継いで、追加された箇所がわかるように
		return child;
	}
	
	/* ================================================================
	 * 処理中
	 * ===============================================================*/
	
	/**
	 * 子を追加する
	 * 
	 * @gearDispose
	 */
	public function addChild<T:(GearHolder)>(child:T, ?pos:PosInfos):T
	{
		addChildGear(getGear(child), pos);
		return child;
	}
	inline private function addChildGear(childGear:Gear, pos:PosInfos):Void
	{
		switch(phase)
		{
			case GearPhase.Create, GearPhase.Dispose, GearPhase.Invalid: throw new SipoError('Gearは処理中にしか子を登録することはできません。($phase) $pos');
			case GearPhase.Diffusible : throw new SipoError('phase=${phase}の時のaddChildは、明示的にaddChildDelayを使用してください。($phase) $pos');
			case GearPhase.Fulfill, GearPhase.Middle : 
		}
		// 追加
		childGearList.push(childGear);
		// 削除処理
		var key:CancelKey = disposeTask(function (){
			removeChildGear(childGear);
		});
		// 追加後の初期化処理
		childGear.setRemoveCancelKey(key);
		childGear.setParent(this);
	}
	
	/**
	 * 子を削除する
	 * 削除した子は再利用できない
	 */
	public function removeChild(child:GearHolder):Void
	{
		var childGear:Gear = getGear(child);
		// 登録されている削除のキャンセル
		disposeTaskStack.remove(childGear.removeCancelKey);
		// 削除の本処理
		removeChildGear(childGear);
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
		while(childGearList.length != 0) removeChild(childGearList[0].holder);	// 下位層をすべて切断
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
	public function otherDiffuseWithKey(diffuseInstance:Dynamic, key:EnumValue):Void
	{
		diffuserAddWithKey(diffuseInstance, key, true);	// 追加処理
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
class AbsorbLog
{
	public var variable:String;
	public var key:Dynamic;
	public var target:Dynamic;
	
	/** コンストラクタ */
	public function new(variable:String, key:Dynamic, target:Dynamic) 
	{
		this.variable = variable;
		this.key = key;
		this.target = target;
	}
}
