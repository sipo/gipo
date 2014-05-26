package frameworkExample.operation;
/**
 * 
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolderLow;
import flash.display.Sprite;
interface OperationView extends GearHolderLow
{
	/** 必要データの付与 */
	public function setContext(operationViewLayer:Sprite):Void;
	
	/** 再現ログの更新 */
	public function updateLog(logcount:Int):Void;
}
