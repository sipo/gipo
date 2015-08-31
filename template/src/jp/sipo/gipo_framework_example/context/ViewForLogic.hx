package jp.sipo.gipo_framework_example.context;
/**
 * LogicからViewに対する命令定義
 * 
 * @author sipo
 */
import haxe.PosInfos;
import jp.sipo.gipo_framework_example.scene.mock1.Mock1.Mock1ViewPeek;
interface ViewForLogic
{
	/**
	 * シーンの変更を依頼する
	 * 値ズレの事故を防ぐため、Viewのシーンインスタンスは必ず更新される
	 * 速度上の問題などで表示を引き継ぐ場合は、View側で意図的にキャッシュ処理をすること
	 * （特に頻出するロード表示などは、常にGPUメモリ上に確保するなどする）
	 */
	public function changeScene(kind:ViewSceneKind, factorPos:PosInfos):ViewSceneOrder;
//	/** データの準備を依頼する。準備終了はViewLogicNoticeで通知される */
//	Prepare(prepareKind:LogicViewOrderPrepare);
}
/**
 * logicに対するScene定義
 * （個別Sceneの定義はLogicSceneのほうに）
 */
interface ViewSceneOrder
{
	// すべてのViewSceneで共通に持つ必要のあるメソッドはここに。フェード切り替えなど。
}
/** シーン変更命令 */
enum ViewSceneKind
{
	/** 表示なし。あるいは、BG用1毎絵を表示する */
	BlankScene;
	
	// --------------------------------
	// 各シーンに対応したシーンへの切り替え指定
	// --------------------------------
	
	Mock0Scene;
	Mock1Scene(peek:Mock1ViewPeek);
	Mock2ReadyScene;
	Mock2Scene;
}
