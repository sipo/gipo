package frameworkExample.core;
/**
 * Hookのデータを保持し、再現を管理する
 * 
 * @auther sipo
 */
import haxe.ds.Option;
import frameworkExample.core.Parcel.ParcelValue;
import frameworkExample.core.Hook.HookEvent;
import jp.sipo.gipo.core.GearHolderImpl;
interface LogicToReproduse<TSnapshot>
{
	/**
	 * スナップショットの登録
	 */
	public function addSnapshot(snapshotValue:TSnapshot):Void;
}
interface HookToReproduse<TEvent>
{
	/**
	 * 発生イベントの登録
	 */
	public function addEvent(hookEvent:TEvent):Void;
}
class Reproduce<TSnapshot, TEvent> extends GearHolderImpl implements LogicToReproduse<TSnapshot> implements HookToReproduse<TEvent>
{
	/* 記録データ */
	private var parcelList:Array<Parcel<TSnapshot, TEvent>> = [];
	
	/* フレームカウント */
	private var frame:Int;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		frame = 0;
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
		frame++;
	}
	
	/* ================================================================
	 * Logic向けのメソッド
	 * ===============================================================*/
	
	public function addSnapshot(snapshotValue:TSnapshot):Void
	{
		var value:ParcelValue<TSnapshot, TEvent> = ParcelValue.Snapshot(snapshotValue);
		parcelList.push(new Parcel<TSnapshot, TEvent>(frame, value));
	}
	
	/* ================================================================
	 * Hook向けのメソッド
	 * ===============================================================*/
	
	public function addEvent(hookEvent:TEvent):Void
	{
		var value:ParcelValue<TSnapshot, TEvent> = ParcelValue.Event(hookEvent);
		parcelList.push(new Parcel<TSnapshot, TEvent>(frame, value));
	}
}
// MEMO:snapshotの適用は、その素材準備などのために非同期で待機する必要があり、その間Hook入力もあり得る
