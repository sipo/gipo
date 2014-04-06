package frameworkExample.core;
/**
 * Hookのデータを保持し、再現を管理する
 * 
 * @auther sipo
 */
import frameworkExample.core.Hook.HookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
interface HookToReproduse
{
	/**
	 * 発生イベントの登録
	 */
	public function event(hookEvent:HookEvent):Void;
}
interface LogicToReproduse
{
	/**
	 * スナップショットの登録
	 */
	public function snapshot():Void;
}
class Reproduse extends GearHolderImpl implements HookToReproduse implements LogicToReproduse
{
	/** コンストラクタ */
	public function new() 
	{
		super();
		
	}
	
	/**
	 * フレーム前後の入力再現タイミング
	 */
	public function inputUpdate():Void
	{
		
	}
	
	/**
	 * 更新
	 */
	public function update():Void
	{
		
	}
	
	/* ================================================================
	 * Hook向けのメソッド
	 * ===============================================================*/
	
	public function event(hookEvent:HookEvent):Void
	{
		// TODO:stb
		trace("データ保存" + hookEvent);
	}
	
	/* ================================================================
	 * Logic向けのメソッド
	 * ===============================================================*/
	
	public function snapshot():Void
	{
		
	}
}
// MEMO:snapshotの適用は、その素材準備などのために非同期で待機する必要があり、その間Hook入力もあり得る
