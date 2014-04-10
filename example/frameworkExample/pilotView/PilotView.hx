package frameworkExample.pilotView;
/**
 * ゲームの表示を簡易実装するView
 * 基本的にViewは、簡易実装と本番実装の２種類を用意することを強く推奨する
 * 
 * @auther sipo
 */
import frameworkExample.operation.OperationPilotView;
import frameworkExample.operation.Operation;
import jp.sipo.gipo.core.GearDiffuseTool;
import frameworkExample.mock1.Mock1PilotView;
import frameworkExample.mock0.Mock0PilotView;
import frameworkExample.core.View;
import frameworkExample.logic.LogicToViewOrder;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import flash.display.Sprite;
class PilotView extends StateSwitcherGearHolderImpl<PilotViewScene> implements View
{
	/* 基本レイヤー */
	private var viewLayer:Sprite;
	/* ゲーム用レイヤー */
	private var gameLayer:Sprite;
	
	/* メタ表示パーツ */
	private var operationView:OperationPilotView;
	private var operationLayer:Sprite;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addDiffusibleHandler(diffusible);
		gear.addRunHandler(run);
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
	 * 必要素材をdiffuse
	 */
	public function diffusible(tool:GearDiffuseTool):Void
	{
		gameLayer = new Sprite();
		operationLayer = new Sprite();
		viewLayer.addChild(gameLayer);
		viewLayer.addChild(operationLayer);
		gear.disposeTask(function () viewLayer.removeChild(gameLayer));
		gear.disposeTask(function () viewLayer.removeChild(operationLayer));
		tool.diffuseWithKey(gameLayer, PilotViewDiffuseKey.GameLayer);
		tool.diffuseWithKey(operationLayer, PilotViewDiffuseKey.OperationLayer);
	}
	
	/**
	 * 初期処理
	 */
	public function run():Void
	{
		operationView = new OperationPilotView();
		gear.addChild(operationView);
	}
	
	/**
	 * 表示切り替え依頼
	 */
	public function order(command:LogicToViewOrder):Void
	{
		switch(command)
		{
			case LogicToViewOrder.ChangeScene(sceneKind): order_ChangeScene(sceneKind);
			case LogicToViewOrder.Scene(sceneCommand): order_Scene(sceneCommand);
			case LogicToViewOrder.Operation(operationCommand) : order_Operation(operationCommand);
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
	/* Operation表示への命令処理 */
	private function order_Operation(command:OperationToViewOrder):Void
	{
		operationView.order(command);
	}
	
	/**
	 * ドラッグなどの入力状態の更新
	 */
	public function inputUpdate():Void
	{
		state.sceneHandler.inputUpdate.execute();
	}
	
	/**
	 * 情報やカウンタの更新
	 */
	public function update():Void
	{
		state.sceneHandler.update.execute();
	}
	
	/**
	 * 表示の更新
	 */
	public function draw():Void
	{
		state.sceneHandler.draw.execute();
	}
}
enum PilotViewDiffuseKey
{
	GameLayer;
	OperationLayer;
}
