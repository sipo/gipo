package jp.sipo.gipo_framework_example.context.reproduce;
/**
 * 再生を途中で開始するための個別データ
 * 開始される可能性のある箇所を網羅する。
 * 
 * ゲームが非常に長く、再現を実行するデバッグに支障をきたすことが予想される場合に、
 * 適度な物を追加する。
 * 
 * 追加されたSnapShotはLogic側でいつでも再現できるような配慮が必要になる。
 * 
 * @author sipo
 */
enum SnapshotKind
{
	/** 初期化 */
	Initialize;
	/** Mock1表示直前 */
	Mock1;
}
