package frameworkExample.pilotView;
/**
 * ゲームの表示を簡易実装するView
 * 基本的にViewは、簡易実装と本番実装の２種類を用意することを強く推奨する
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import frameworkExample.scene.mock1.Mock1PilotView;
import frameworkExample.scene.mock0.Mock0PilotView;
import frameworkExample.context.LogicToView;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearDiffuseTool;
import flash.display.Sprite;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import frameworkExample.scene.mock0.Mock0;
import frameworkExample.scene.mock1.Mock1;
import frameworkExample.context.View;
class PilotView extends StateSwitcherGearHolderImpl<PilotViewScene> implements View
{
	/* 基本レイヤー */
	private var viewLayer:Sprite;
	/* ゲーム用レイヤー */
	private var gameLayer:Sprite;
	
	/** コンストラクタ */
	public function new() { super(); }
	
	/**
	 * 必要設定
	 * すべてのViewで必要な要素を取得し、使わない場合は無視する
	 */
	public function setContext(viewLayer:Sprite):Void
	{
		this.viewLayer = viewLayer;
	}
	
	/**
	 * 必要素材をdiffuse
	 */
	@:handler(GearDispatcherKind.Diffusible)
	public function diffusible(tool:GearDiffuseTool):Void
	{
		gameLayer = new Sprite();
		viewLayer.addChild(gameLayer);
		gear.disposeTask(function () viewLayer.removeChild(gameLayer));
		tool.diffuseWithKey(gameLayer, PilotViewDiffuseKey.GameLayer);
	}
	
	/* ================================================================
	 * Logicからの命令
	 * ===============================================================*/
	
	/** シーンの変更を依頼する */
	public function changeScene(sceneKind:ViewSceneKind):ViewSceneOrder
	{
		var scene:PilotViewScene = getScene(sceneKind);
		stateSwitcherGear.changeState(scene);
		return scene;
	}
	private function getScene(sceneKind:ViewSceneKind):PilotViewScene
	{
		switch(sceneKind)
		{
			case ViewSceneKind.Mock0 : return new Mock0PilotView();
			case ViewSceneKind.Mock1(peek) : return new Mock1PilotView(peek);
			case ViewSceneKind.Blank : return new BlankPilotView();
		}
	}
	
	/* ================================================================
	 * Topからの更新指定
	 * ===============================================================*/
	
	/**
	 * ドラッグなどの入力状態の更新
	 */
	public function inputUpdate():Void
	{
		state.inputUpdateDispatcher.execute();
	}
	
	/**
	 * 情報やカウンタの更新
	 */
	public function update():Void
	{
		state.updateDispatcher.execute();
	}
	
	/**
	 * 表示の更新
	 */
	public function draw():Void
	{
		state.drawDispatcher.execute();
	}
}
/**
 * PilotViewで使用する、Diffuse用のキー
 */
enum PilotViewDiffuseKey
{
	GameLayer;
}
