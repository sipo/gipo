package jp.sipo.gipo.reproduce;
/**
 * Logの配列のWrapper。基本的には配列のみもつ
 * 
 * @auther sipo
 */
import jp.sipo.gipo.reproduce.Snapshot;
import haxe.PosInfos;
import Type;
import jp.sipo.gipo.reproduce.LogPart;
import flash.Vector;
class LogWrapper<TUpdateKind>
{
	private var list = new Array<LogPart<TUpdateKind>>();
	
	/** コンストラクタ */
	public function new() {  }
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[LogWrapper(${Type.getClassName(Type.getClass(this))}) ${list}]';
	}
}
/**
 * 記録用のWrapper
 * 保存ファイルも担当する
 * 
 * @auther sipo
 */
class RecordLog<TUpdateKind> extends LogWrapper<TUpdateKind>
{
	/** コンストラクタ */
	public function new() { super(); }
	
	/**
	 * 追加する
	 */
	public function add(phase:ReproducePhase<TUpdateKind>, frame:Int, logway:LogwayKind, factorPos:PosInfos):Void
	{
		var logPart:LogPart<TUpdateKind> = new LogPart<TUpdateKind>(phase, frame, logway, factorPos);
		logPart.setId(list.length);
		list.push(logPart);
	}
	
	/**
	 * 長さを返す
	 */
	public function getLength():Int
	{
		return list.length;
	}
	
	/**
	 * 再生用データに変換する
	 */
	public function convertReplay():ReplayLog<TUpdateKind>
	{
		return new ReplayLog<TUpdateKind>(list);
	}
}

/**
 * 再生用のWrapper
 * 
 * @auther sipo
 */
class ReplayLog<TUpdateKind> extends LogWrapper<TUpdateKind>
{
	/* 再生インデックス */
	private var position:Int = 0;
	/* 次の再生パートのフレーム */
	public var nextPartFrame(default, null):Int = 0;
	/* 配列サイズ（固定のはずなので） */
	private var length:Int = 0;
	
	/** コンストラクタ */
	public function new(list:Array<LogPart<TUpdateKind>>) 
	{
		super();
		this.list = list;
		// 長さをキャッシュ
		length = list.length;
		// 次のフレームをキャッシュ
		checkNextFrame();
	}
	
	/**
	 * スナップショット表示用の配列データを返す
	 */
	public function createDisplaySnapshotList():Vector<DisplaySnapshot>
	{
		var displaySnapshotList = new Vector<DisplaySnapshot>();
		for (i in 0...list.length)
		{
			var part:LogPart<Dynamic> = list[i];
			// snapshotだけを配列へ
			switch (part.logway)
			{
				case LogwayKind.Instant(_), LogwayKind.Async(_) : continue;
				case LogwayKind.Snapshot(value) : 
				{
					var snapshot:Snapshot = value;
					displaySnapshotList.push(new DisplaySnapshot(snapshot.getDisplayName(), i));
				}
			}
		}
		return displaySnapshotList;
	}
	
	/**
	 * 再生ヘッドの設定
	 */
	public function setPosition(position:Int):Void
	{
		this.position = position;
		checkNextFrame();
	}
	
	/**
	 * 再生位置のLogが存在するかどうか
	 */
	public function hasNext():Bool
	{
		return position < length;
	}
	
	/**
	 * 現在の位置のデータを返す
	 */
	public function next():LogPart<TUpdateKind>
	{
		var ans = list[position++];
		checkNextFrame();
		return ans;
	}
	/* 次のパートのフレームを保存しておく */
	private function checkNextFrame():Void
	{
		if (!hasNext()) return;
		var nextPart:LogPart<TUpdateKind> = list[position];
		nextPartFrame = nextPart.frame;
	}
}

/**
 * 表示用のSnapshot
 * 
 * @auther sipo
 */
class DisplaySnapshot
{
	/** 表示名称 */
	public var display:String;
	/** 元のLogの番号 */
	public var logIndex:Int;
	
	/** コンストラクタ */
	public function new(display:String, logIndex:Int) 
	{
		this.display = display;
		this.logIndex = logIndex;
	}
	
}
