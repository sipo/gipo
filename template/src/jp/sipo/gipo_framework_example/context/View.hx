package jp.sipo.gipo_framework_example.context;
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
import flash.display.Sprite;
import jp.sipo.gipo.core.GearHolderLow;
interface View extends GearHolderLow extends ViewForLogic
{
	/**
	 * 必要設定
	 * すべてのViewで必要な要素を取得し、使わない場合は無視する
	 */
	public function setContext(viewLayer:Sprite):Void;
	
	/**
	 * フレーム間の更新。
	 * 処理停止中でも動作するので、この関数の回数に依存した処理をしてはいけない。
	 * 表示の準備など、フレームに非同期的な処理に利用する。
	 */
	public function asyncUpdate():Void;
	
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
	 * 動作が重くなった時に停止されるので、ここでカウントなどをしてはいけない
	 */
	public function draw():Void;
}
