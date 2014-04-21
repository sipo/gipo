package frameworkExample.context;
/**
 * 最上位GearHolder
 * 各種セクションの設定などをする
 * 
 * @auther sipo
 */
import frameworkExample.context.Logic.HookToLogic;
import jp.sipo.util.GlobalDispatcher;
import frameworkExample.context.Hook.ViewToHook;
import jp.sipo.gipo.core.GearDiffuseTool;
import frameworkExample.operation.Reproduce;
import frameworkExample.operation.OperationView;
import frameworkExample.operation.OperationHook;
import frameworkExample.operation.OperationLogic;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolderImpl;
class Top extends GearHolderImpl
{
	/* 基本表示レイヤ */
	private var current:Sprite;
	/* 開発設定 */
	private var devConfig:DevConfig;
	/* 各セクションを超えた全体状態管理 */
	private var globalStatus:GlobalStatus;
	
	/* 基本インスタンス */
	private var logic:Logic;
	private var hook:Hook;
	private var view:View;
	private var operationLogic:OperationLogic;
	private var operationHook:OperationHook;
	private var operationView:OperationView;
	private var reproduce:Reproduce;
	
	/* 全体イベントの発行 */
	private var globalDispatcher:GlobalDispatcher;
	
	/** コンストラクタ */
	public function new(current:Sprite, devConfig:DevConfig) 
	{
		super();
		this.current = current;
		this.devConfig = devConfig;
		// 
		globalStatus = new GlobalStatus();
		//
		gear.addDiffusibleHandler(diffusible);
		gear.addRunHandler(run);
	}
	
	/* 初期化とDiffuse */
	private function diffusible(tool:GearDiffuseTool):Void
	{
		// configの拡散
		tool.diffuse(devConfig, DevConfig);
		tool.diffuse(globalStatus, GlobalStatus);
		// operationcの用意
		operationLogic = new OperationLogic();
		tool.bookChild(operationLogic);
		var operationViewClass = devConfig.operationView;
		operationView = Type.createInstance(operationViewClass, []);
		tool.bookChild(operationView);
		operationHook = new OperationHook();
		tool.bookChild(operationHook);
		// reproduceの用意
		reproduce = new Reproduce();
		tool.bookChild(reproduce);
		// hookの用意
		hook = new Hook();
		tool.bookChild(hook);
		// viewの用意
		var viewClass = devConfig.view;
		view = Type.createInstance(viewClass, []);
		tool.bookChild(view);
		// logicの用意
		logic = new Logic();
		tool.bookChild(logic);
		
		// 関係性の追加
		// 	Logic周り
		gear.otherDiffuse(hook, logic, HookToLogic);
		gear.otherDiffuse(view, hook, ViewToHook);
		gear.otherDiffuse(logic, view, LogicToView);
		// 	Operation周り
		gear.otherDiffuse(hook, operationLogic, OperationLogic);
		hook.getGear().otherDiffuse(operationLogic, OperationLogic)
		
		
		gear.otherDiffuse(operationHook, operationLogic, OperationLogic);
		gear.otherDiffuse(operationView, operationHook, OperationHook);
		gear.otherDiffuse(operationLogic, operationView, OperationView);
		
		// ビューのレイヤーとなるSprite。DisplayObjectを使用するViewのみ使用し、Starlingを使用するViewでは無視されるかデバッグ表示のみに使用される
		var viewLayer:Sprite = new Sprite();
		current.addChild(viewLayer);
		view.setContext(viewLayer);
		gear.otherEntryDispose(view, function (){	// layerの削除処理をViewに連動させる
			current.removeChild(viewLayer);
		});
		var operationViewLayer:Sprite = new Sprite();
		current.addChild(operationViewLayer);
		operationView.setContext(operationViewLayer);
		gear.otherEntryDispose(view, function (){	// layerの削除処理をViewに連動させる
			current.removeChild(operationViewLayer);
		});
		
		// イベント準備
		globalDispatcher = new GlobalDispatcher();
		globalDispatcher.setFlashContext(current);
		tool.diffuse(globalDispatcher, GlobalDispatcher);
		tool.bookChild(globalDispatcher);
		globalDispatcher.addFrameHandler(frame);	// フレームイベント
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// 開始
		logic.start();
	}
	
	/* フレーム動作 */
	private function frame():Void
	{
		reproduce.inputUpdate();
		reproduce.update();
		view.inputUpdate();
		logic.update();
		view.update();
		view.draw();
	}
}
