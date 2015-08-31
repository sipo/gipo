package jp.sipo.gipo_framework_example.context.reproduce;

/**
 * 再生を途中で開始するためのデータ
 * Logicでは重要な切り替わり部分は、このデータのみで全て同じように再現されるようにする。
 * 
 * 基本的にはスナップショットの種類と、その時のLogicStatusを保持するクラスである
 * 
 * @author sipo
 */
import jp.sipo.gipo.reproduce.Snapshot;
class SnapshotImpl implements Snapshot
{
	/** 種類 */
	public var kind:SnapshotKind;
	/** 固有データ */
	public var logicStatus:LogicStatus;
	
	/** コンストラクタ */
	public function new(kind:SnapshotKind, logicStatus:LogicStatus) 
	{
		this.kind = kind;
		this.logicStatus = logicStatus;
	}
	
	/**
	 * 表示する場合の文字列を返す
	 * 形式は自由だが最初のほうで、どういったsnapShotか分かるのが望ましい
	 */
	public function getDisplayName():String
	{
		return Std.string(kind);
	}
}
