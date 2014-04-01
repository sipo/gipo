package frameworkExample.core;
/**
 * 最上位GearHolder
 * 各種セクションの設定などをする
 * 
 * @auther sipo
 */
import frameworkExample.core.Hook.ViewHook;
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
	
	/* ビューのレイヤーとなるSprite。DisplayObjectを使用するLayerのみ使用し、Starlingを使用するViewでは無視されるかデバッグ表示のみに使用される */
	private var viewLayer:Sprite;
	
	/* 基本インスタンス */
	private var logic:Logic;
	private var hook:Hook;
	private var view:View;
	private var viewHook:ViewHook;
	
	/* 全体イベントの発行 */
	private var globalDispatcher:GlobalDispatcher;
	
	/** コンストラクタ */
	public function new(current:Sprite, devConfig:DevConfig) 
	{
		super();
		this.current = current;
		this.devConfig = devConfig;
		//
		gear.addDiffusibleHandler(diffusible);
		gear.addRunHandler(run);
	}
	
	/* 初期化とDiffuse */
	private function diffusible(tool:GearDiffuseTool):Void
	{
		// configの拡散
		tool.diffuse(devConfig, DevConfig);
		// hookの用意
		var hookClass = devConfig.hook;
		hook = Type.createInstance(hookClass, []);
		tool.bookChild(hook);
		// viewの用意
		var viewClass = devConfig.view;
		view = Type.createInstance(viewClass, []);
		viewLayer = new Sprite();
		current.addChild(viewLayer);
		view.setContext(viewLayer);
		gear.otherEntryDispose(view, function (){	// layerの削除処理
			current.removeChild(viewLayer);
		});
		tool.diffuse(view, View);
		tool.bookChild(view);
		// viewHookの用意
		viewHook = new ViewHook(hook);
		gear.otherDiffuse(view, viewHook, ViewHook);
		// logicの用意
		logic = new Logic();
		tool.diffuse(logic, Logic);
		tool.bookChild(logic);
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
		logic.update();
		view.update();
		view.draw();
	}
}
