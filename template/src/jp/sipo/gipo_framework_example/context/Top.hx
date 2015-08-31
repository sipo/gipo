package jp.sipo.gipo_framework_example.context;
/**
 * 最上位GearHolder
 * 各種セクションの設定などをする
 * 
 * @auther sipo
 */
import jp.sipo.gipo_framework_example.context.reproduce.UpdateKind;
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.core.GearHolderLow;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo_framework_example.context.Logic;
import jp.sipo.util.GlobalDispatcher;
import jp.sipo.gipo_framework_example.context.Hook;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo_framework_example.operation.OperationView;
import jp.sipo.gipo_framework_example.operation.OperationHook;
import jp.sipo.gipo_framework_example.operation.OperationLogic;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolderImpl;
class Top extends GearHolderImpl
{
	/* 基本表示レイヤ */
	private var current:Sprite;
	/* 開発設定 */
	private var devConfig:DevConfig;
	/* 各セクションを超えた全体状態管理 */
	private var globalStatus:GlobalContext;
	
	/* 基本インスタンス */
	private var logic:Logic;
	private var hook:Hook;
	private var view:View;
	private var operationLogic:OperationLogic;
	private var operationHook:OperationHook;
	private var operationView:OperationView;
	private var reproduce:Reproduce<UpdateKind>;
	
	/* 全体イベントの発行 */
	private var globalDispatcher:GlobalDispatcher;
	
	/** コンストラクタ */
	public function new(current:Sprite, devConfig:DevConfig) 
	{
		super();
		this.current = current;
		this.devConfig = devConfig;
	}
	
	@:handler(GearDispatcherKind.Diffusible)
	private function diffusible(tool:GearDiffuseTool):Void
	{
		globalStatus = new GlobalContext();
		
		// configの拡散
		tool.diffuse(devConfig, DevConfig);
		tool.diffuse(globalStatus, GlobalContext);
		// operationcの用意
		operationLogic = tool.bookChild(new OperationLogic());
		var operationViewClass = devConfig.operationView;
		operationView = tool.bookChild(Type.createInstance(operationViewClass, []));
		operationHook = tool.bookChild(new OperationHook());
		// reproduceの用意
		reproduce = tool.bookChild(new Reproduce<UpdateKind>());
		// hookの用意
		hook = tool.bookChild(new Hook());
		// viewの用意
		var viewClass = devConfig.view;
		view = tool.bookChild(Type.createInstance(viewClass, []));
		// logicの用意
		logic = tool.bookChild(new Logic());
		
		// 関係性の追加
		// 	Logic周り
		childDiffuse(hook , logic, LogicForHook);
		childDiffuse(view , hook , HookForView);
		childDiffuse(logic, view , ViewForLogic);
		childDiffuse(logic, hook , HookForLogic);
		// 	Operation周り
		childDiffuseWithKey(hook , reproduce, TopDiffuseKey.ReproduceKey);
		childDiffuse(reproduce , hook, HookForReproduce);
		childDiffuse(operationHook , operationLogic, OperationLogic);
		childDiffuse(operationView , operationHook , OperationHookForView);
		childDiffuse(operationLogic, operationView , OperationView);
		childDiffuseWithKey(operationLogic , reproduce, TopDiffuseKey.ReproduceKey);
		childDiffuse(reproduce, operationHook, OperationHookForReproduce);
		
		// ビューのレイヤーとなるSprite。DisplayObjectを使用するViewのみ使用し、Starlingを使用するViewでは無視されるかデバッグ表示のみに使用される
		var viewLayer:Sprite = new Sprite();
		current.addChild(viewLayer);
		view.setContext(viewLayer);
		view.gearOutside().disposeTask(function () current.removeChild(viewLayer));	// layerの削除処理をViewに連動させる
		var operationViewLayer:Sprite = new Sprite();
		current.addChild(operationViewLayer);
		operationView.setContext(operationViewLayer);
		view.gearOutside().disposeTask(function () current.removeChild(operationViewLayer));	// layerの削除処理をViewに連動させる
		
		
		// イベント準備
		globalDispatcher = tool.bookChild(new GlobalDispatcher());
		globalDispatcher.setFlashContext(current);
		tool.diffuse(globalDispatcher, GlobalDispatcher);
		globalDispatcher.addFrameHandler(frame);	// フレームイベント
	}
	/* child以下にtargetをdiffuseする */
	inline private function childDiffuse(child:GearHolderLow, target:GearHolderLow, clazz:Class<Dynamic>):Void
	{
		child.gearOutside().otherDiffuse(target, clazz);
	}
	/* child以下にtargetをenumでdiffuseする */
	inline private function childDiffuseWithKey(child:GearHolderLow, target:GearHolderLow, key:TopDiffuseKey):Void
	{
		child.gearOutside().otherDiffuseWithKey(target, key);
	}
	
	@:handler(GearDispatcherKind.Run)
	private function run():Void
	{
		// reproduseの準備（このrun自体も非同期である）
		reproduce.startOutFramePhase();
		// 開始
		logic.start();
	}
	
	/* フレーム動作 */
	private function frame():Void
	{
		// 非同期でもフレーム処理が欲しい場合の呼び出し
		view.asyncUpdate();
		// フレーム内状態を終了
		reproduce.endPhase();
		
		// 再現状態の更新処理
		reproduce.update();
		
		if (reproduce.checkCanProgress())	// フレームの進行が可能かどうか
		{
			
			// inputUpdate（マウスドラッグなどの入力）
			reproduce.startInFramePhase(UpdateKind.ViewInput);
			view.inputUpdate();
			reproduce.endPhase();
			
			// Logicのメイン処理
			logic.update();
			
			// 描画処理
			view.update();
			view.draw();
		}
		
		
		// 再現状態をフレーム外へ切り替え
		reproduce.startOutFramePhase();
	}
}
enum TopDiffuseKey
{
	ReproduceKey;
}
