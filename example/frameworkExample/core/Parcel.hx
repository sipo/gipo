package frameworkExample.core;
/**
 * Reproduce記録の最小単位
 * Gipoへ移動することも想定する
 * 
 * @auther sipo
 */
class Parcel<TSnapshot, TEvent>
{
	/** 発生フレーム */
	public var frame:Int;
	
	
	/* --------------------------------
	 * 以下の変数は、排他で１つ持つ。Enumにしないのは、容量節約
	 * -------------------------------*/
	
	/** スナップショット */
	private var snapshot:TSnapshot;
	/** イベント */
	private var event:TEvent;
	
	/** コンストラクタ */
	public function new(frame:Int, parcelValue:ParcelValue<TSnapshot, TEvent>) 
	{
		this.frame = frame;
		switch(parcelValue)
		{
			case ParcelValue.Snapshot(value) : this.snapshot = value;
			case ParcelValue.Event(value) : this.event = value;
		}
	}
	
	/**
	 * 排他変数をEnumで取得する
	 */
	public function getValue():ParcelValue<TSnapshot, TEvent>
	{
		if (snapshot != null) return ParcelValue.Snapshot(snapshot);
		return ParcelValue.Event(event);
	}
}
enum ParcelValue<TSnapshot, TEvent>
{
	Snapshot(value:TSnapshot);
	Event(value:TEvent);
}
// MEMO:マウスガイドの容量が大きくなるなら、個別に配列にまとめてしまう。ただし、最適化の一種なので後でいい
