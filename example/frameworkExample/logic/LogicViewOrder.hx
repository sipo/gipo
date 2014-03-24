package frameworkExample.logic;
/**
 * LogicからViewに対する命令。
 * 表示の切替のほか、データの準備の指示など
 * 
 * @auther sipo
 */
import frameworkExample.mock1.Mock1.Mock1Peek;
enum LogicViewOrder
{
	/** シーンの変更を依頼する */
	ChangeScene(sceneKind:ViewChangeScene);
	/** データの準備を依頼する。準備終了はViewLogicNoticeで通知される */
//	Prepare(prepareKind:LogicViewOrderPrepare);
	/** シーン固有の描画依頼。主にタイミングを伝えるなど */
	Scene(command:EnumValue);
}
enum ViewChangeScene
{
	/** 表示なし。あるいは、BG用1毎絵を表示する */
	None;
	
	// --------------------------------
	// 各シーンに対応したシーンへの切り替え指定
	// --------------------------------
	
	Mock0;
	Mock1(peek:Mock1Peek);
}
