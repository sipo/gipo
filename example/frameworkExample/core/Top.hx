package frameworkExample.core;
/**
 * 最上位GearHolder
 * 各種セクションの設定などをする
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicSnapshot;
import frameworkExample.core.Reproduse;
import frameworkExample.config.Status;
import frameworkExample.util.GlobalDispatcher;
import frameworkExample.core.Hook;
import frameworkExample.logic.Logic;
import jp.sipo.gipo.core.GearDiffuseTool;
import frameworkExample.config.DevConfig;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolderImpl;
class Top extends GearHolderImpl
{
	/* 基本表示レイヤ */
	private var current:Sprite;
	/* 開発設定 */
	private var devConfig:DevConfig;
	/* 各セクションを超えた全体状態管理 */
	private var metaConfig:Status;
	
	/* 基本インスタンス */
	private var logic:Logic;
	private var hook:Hook;
	private var reproduce:Reproduse<LogicSnapshot, HookEvent>;
	private var view:View;
	
	/* 全体イベントの発行 */
	private var globalDispatcher:GlobalDispatcher;
	
	/** コンストラクタ */
	public function new(current:Sprite, devConfig:DevConfig) 
	{
		super();
		this.current = current;
		this.devConfig = devConfig;
		// 
		metaConfig = new Status();
		//
		gear.addDiffusibleHandler(diffusible);
		gear.addRunHandler(run);
	}
	
	/* 初期化とDiffuse */
	private function diffusible(tool:GearDiffuseTool):Void
	{
		// configの拡散
		tool.diffuse(devConfig, DevConfig);
		tool.diffuse(metaConfig, Status);
		// reproduceの用意
		reproduce = new Reproduse();
		tool.bookChild(reproduce);
		// hookの用意
		hook = new Hook();
		tool.bookChild(hook);
		// viewの用意
		var viewClass = devConfig.view;
		view = Type.createInstance(viewClass, []);
		tool.bookChild(view);
		// ビューのレイヤーとなるSprite。DisplayObjectを使用するLayerのみ使用し、Starlingを使用するViewでは無視されるかデバッグ表示のみに使用される
		var viewLayer:Sprite = new Sprite();
		current.addChild(viewLayer);
		gear.otherEntryDispose(view, function (){	// layerの削除処理
			current.removeChild(viewLayer);
		});
		// logicの用意
		logic = new Logic();
		tool.bookChild(logic);
		// 関係性の追加
		gear.otherDiffuse(hook, logic, Logic);
		gear.otherDiffuse(view, hook, ViewToHook);
		gear.otherDiffuse(logic, view, View);
		gear.otherDiffuse(hook, reproduce, HookToReproduse);
		gear.otherDiffuse(logic, reproduce, LogicToReproduse);
		gear.otherDiffuse(reproduce, logic, Logic);
		view.setContext(viewLayer);
		
		// イベント準備
		globalDispatcher = new GlobalDispatcher();
		globalDispatcher.setFlashContext(current);
		tool.diffuse(globalDispatcher, GlobalDispatcher);
		tool.bookChild(globalDispatcher);
		globalDispatcher.addFrameHandler(frame);
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
