package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolder;
import flash.display.Sprite;
import frameworkExample.operation.OperationLogic.OperationPeek;
interface OperationView extends GearHolder
{
	/** 必要データの付与 */
	public function setContext(operationViewLayer:Sprite):Void;
	
	/** 再現ログの更新 */
//	public function updateLog();	// TODO:あとで、ログのデータを持たせる
}
