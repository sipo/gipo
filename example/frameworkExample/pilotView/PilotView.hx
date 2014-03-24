package frameworkExample.pilotView;
/**
 * ゲームの表示を簡易実装するView
 * 基本的にViewは、簡易実装と本番実装の２種類を用意することを強く推奨する
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearDiffuseTool;
import frameworkExample.mock1.Mock1PilotView;
import frameworkExample.mock0.Mock0PilotView;
import frameworkExample.core.View;
import frameworkExample.logic.LogicViewOrder;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import flash.display.Sprite;
class PilotView extends StateSwitcherGearHolderImpl<PilotViewScene> implements View
{
	/* 基本レイヤー */
	private var viewLayer:Sprite;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addDiffusibleHandler(diffusible);
	}
	
	/**
	 * 必要設定
	 * すべてのViewで必要な要素を取得し、使わない場合は無視する
	 */
	public function setContext(viewLayer:Sprite):Void
	{
		this.viewLayer = viewLayer;
	}
	
	/**
	 * 必要設定
	 * すべてのViewで必要な要素を取得し、使わない場合は無視する
	 */
	public function diffusible(tool:GearDiffuseTool):Void
	{
		tool.diffuseWithKey(viewLayer, PilotViewDiffuseKey.ViewLayer);
	}
	
	/**
	 * 表示切り替え依頼
	 */
	public function order(command:LogicViewOrder):Void
	{
		switch(command)
		{
			case LogicViewOrder.ChangeScene(sceneKind): order_ChangeScene(sceneKind);
			case LogicViewOrder.Scene(sceneCommand): order_Scene(sceneCommand);
		}
	}
	/* シーンの切り替え処理をここに書く */
	private function order_ChangeScene(command:ViewChangeScene):Void
	{
		switch(command)
		{
			case ViewChangeScene.None: stateSwitcherGear.changeState(new NonePilotView());
			case ViewChangeScene.Mock0: stateSwitcherGear.changeState(new Mock0PilotView());
			case ViewChangeScene.Mock1(peek): stateSwitcherGear.changeState(new Mock1PilotView(peek));
		}
	}
	/* シーンごとの命令処理 */
	private function order_Scene(command:EnumValue):Void
	{
		state.sceneOrder(command);
	}
	
	/**
	 * ドラッグなどの入力状態の更新
	 */
	public function inputUpdate():Void
	{
		state.inputUpdate();
	}
	
	/**
	 * 情報やカウンタの更新
	 */
	public function update():Void
	{
		state.update();
	}
	
	/**
	 * 表示の更新
	 */
	public function draw():Void
	{
		state.draw();
	}
}
enum PilotViewDiffuseKey
{
	ViewLayer;
}
