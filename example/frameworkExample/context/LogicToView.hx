package frameworkExample.context;
/**
 * LogicからViewに対する命令定義
 * 
 * @author sipo
 */
import frameworkExample.scene.mock1.Mock1.Mock1ViewPeek;
interface LogicToView
{
	/**
	 * シーンの変更を依頼する
	 * 値ズレの事故を防ぐため、Viewのシーンインスタンスは必ず更新される
	 * 速度上の問題などで表示を引き継ぐ場合は、View側で意図的にキャッシュ処理をすること
	 * （特に頻出するロード表示などは、常にGPUメモリ上に確保するなどする）
	 */
	public function changeScene(kind:ViewSceneKind):LogicToViewScene;
//	/** データの準備を依頼する。準備終了はViewLogicNoticeで通知される */
//	Prepare(prepareKind:LogicViewOrderPrepare);
}
/**
 * logicに対するScene定義
 * （個別Sceneの定義はLogicSceneのほうに）
 */
interface LogicToViewScene
{}
/** シーン変更命令 */
enum ViewSceneKind
{
	/** 表示なし。あるいは、BG用1毎絵を表示する */
	Blank;
	
	// --------------------------------
	// 各シーンに対応したシーンへの切り替え指定
	// --------------------------------
	
	Mock0;
	Mock1(peek:Mock1ViewPeek);
}
