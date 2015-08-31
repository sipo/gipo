package jp.sipo.gipo_framework_example.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.reproduce.LogWrapper.DisplaySnapshot;
import flash.Vector;
import jp.sipo.gipo.core.GearHolderLow;
import flash.display.Sprite;
/* ================================================================
 * OperationHookに要求する機能
 * ===============================================================*/
interface OperationHookForView
{
	/**
	 * Viewからのイベント処理
	 */
	public function noticeOperationViewEvent(event:OperationViewEvent):Void;
}
/**
 * OperationLogic向けのイベント定義
 */
enum OperationViewEvent
{
	/** ローカル保存の指示 */
	LocalSave;
	/** ローカル読み込みの指示 */
	LocalLoad;
	/** リプレイの開始 */
	StartReplay(logIndex:Int);
}
/* ================================================================
 * インターフェース
 * ===============================================================*/
interface OperationView extends GearHolderLow
{
	/** 必要データの付与 */
	public function setContext(operationViewLayer:Sprite):Void;
	
	/** 再現ログの更新 */
	public function updateLog(logcount:Int):Void;
	
	/** 読み込んだファイルデータの表示 */
	public function displayFile(displaySnapshotList:Vector<DisplaySnapshot>):Void;
}
