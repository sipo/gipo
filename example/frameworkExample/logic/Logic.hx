package frameworkExample.logic;
/**
 * 中央管理クラス
 * MVCのMにあたる
 * Modelという名称は不適切だと思われるので、より実態を示すLogicと呼ぶ。
 * 処理を管理し、Stateを持ち、フレームの速度を調節する。
 * 
 * @auther sipo
 */
import frameworkExample.operation.Operation;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.util.SipoError;
import frameworkExample.core.ViewToLogicReady;
import frameworkExample.core.ViewToLogicInput;
import frameworkExample.logic.LogicInitialize;
import frameworkExample.logic.LogicScene;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
class Logic extends StateSwitcherGearHolderImpl<LogicScene>
{
	/* 再現性などのメタ操作を行なうパーツ */
	private var operation:Operation;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addDiffusibleHandler(diffusible);
		// runを使用せずにstartで起動する
	}
	
	/* 自身を以下に伝えておく */
	private function diffusible(tool:GearDiffuseTool):Void
	{
		tool.diffuse(this, Logic);
	}
	
	
	/**
	 * ゲーム開始
	 */
	public function start():Void
	{
		// オペレーション
		operation = new Operation();
		gear.addChild(operation);
		// 初期シーン
		stateSwitcherGear.changeState(new LogicInitialize());
	}

	/**
	 * Viewからの入力
	 */
	public function viewInput(command:ViewToLogicInput):Void
	{
		switch(command)
		{
			case ViewToLogicInput.Common(commonInput) : viewInputCommon(commonInput);
			case ViewToLogicInput.Scene(sceneInput) : state.sceneViewInput(sceneInput);
		}
	}
	/* Viewからの入力のうち共通処理 */
	private function viewInputCommon(commonInput:ViewLogicInputCommon):Void
	{
		throw new SipoError('未実装');
	}
	
	/**
	 * Viewからの準備完了通知
	 */
	public function viewReady(command:ViewToLogicReady):Void
	{
		throw new SipoError('未実装');
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		state.sceneHandler.update.execute();
	}
}
