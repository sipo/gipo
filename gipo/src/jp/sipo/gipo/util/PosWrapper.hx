package jp.sipo.gipo.util;
/**
 * 対象インスタンスに、宣言箇所を付与する
 * 遅延処理の予約などに使っておくと、原因箇所がわかりやすくなる
 * 
 * @auther sipo
 */
import haxe.PosInfos;
class PosWrapper<T>
{
	/** 対象の値 */
	public var value:T;
	/** 使用箇所 */
	public var pos:PosInfos;
	
	/** オプションで追加されるコード位置 */
	public var keyPos:Map<String, PosInfos>;
	
	/** コンストラクタ */
	public function new(value:T, ?pos:PosInfos) 
	{
		this.value = value;
		this.pos = pos;
	}
	
	/**
	 * さらに位置情報を追加
	 */
	public function addPos(key:String, pos:PosInfos):Void
	{
		if (keyPos == null) keyPos = new Map();
		keyPos.set(key, pos);
	}
}
