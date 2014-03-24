package frameworkExample.pilotView;
/**
 * ゲームの表示を簡易実装するView
 * 基本的にViewは、簡易実装と本番実装の２種類を用意することを強く推奨する
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicViewOrder;
import jp.sipo.gipo.core.state.StateSwitcherGearHolderImpl;
import flash.display.Sprite;
class PilotView extends StateSwitcherGearHolderImpl
{
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/**
	 * 必要設定
	 * すべてのViewで必要な要素を取得し、使わない場合は無視する
	 */
	public function setContext(viewLayer:Sprite):Void
	{
		
	}
	
	/**
	 * 表示切り替え依頼
	 */
	public function order(command:LogicViewOrder):Void
	{
		
	}
	
	/**
	 * ドラッグなどの入力状態の更新
	 */
	public function inputUpdate():Void
	{
		
	}
	
	/**
	 * 情報やカウンタの更新
	 */
	public function update():Void
	{
		
	}
	
	/**
	 * 表示の更新
	 */
	public function draw():Void
	{
		
	}
}
