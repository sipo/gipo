package frameworkExample.core;
/**
 * Viewセクション
 * MVCのVにあたる。
 * Gipoフレームワークでは、Viewだけでなく、Service（通信）なども１セクションになる
 * 
 * セクションは必ずインターフェースを持ち、Logicからは切り替えて使えるようにする
 * これはデバッグ表示、デバッグ通信などを実装するため
 * 
 * Pilotは動作の保証される最低実装バージョン
 * Viewなどがエラーで停止する場合にこれに切り替えてテストを続行することができる
 * 
 * @auther sipo
 */
import frameworkExample.logic.LogicToViewOrder;
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolder;
interface View extends GearHolder
{
	/**
	 * 必要設定
	 * すべてのViewで必要な要素を取得し、使わない場合は無視する
	 */
	public function setContext(viewLayer:Sprite):Void;
	
	/**
	 * 表示切り替え依頼
	 */
	public function order(command:LogicToViewOrder):Void;
	
	/**
	 * ドラッグなどの入力状態の更新
	 */
	public function inputUpdate():Void;
	
	/**
	 * 情報やカウンタの更新
	 */
	public function update():Void;
	
	/**
	 * 表示の更新
	 */
	public function draw():Void;
}
