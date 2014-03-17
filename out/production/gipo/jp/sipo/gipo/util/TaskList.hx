package jp.sipo.gipo.util;
import haxe.PosInfos;
/**
 * 関数処理を保持し、実行する
 * 実行関数は登録時に決定され、主に同一クラス内での遅延処理や待機処理、処理順序の入れ替えなどに使用する
 * コード上、実行される関数が隠蔽されやすいのでクラスをまたいだ使用は非推奨
 * 
 * @author sipo
 */
typedef TaskListAddBehavior = Array<Task> -> Task -> Void;
class TaskList
{
	/* 実保存 */
	private var tasks:Array<Task>;
	/* 追加時の挙動挙動 */
	private var addBehavior:TaskListAddBehavior;
	/* 実行が入れ子にならないようにロックする */
	private var executeLock:Bool;
	
	public function new(addBehavior:TaskListAddBehavior)
	{
		this.addBehavior = addBehavior;
		executeLock = false;
		clear();
	}
	/* 初期化処理 */
	private function clear():Void
	{
		tasks = new Array<Task>();
	}
	
	/**
	 * タスクを追加する
	 */
	public function addTask(func:Void -> Void, ?pos:PosInfos):Void
	{
		var task:Task = new Task(func, pos);
		addBehavior(tasks, task);
	}
	
	/**
	 * タスクを実行する
	 */
	public function execute():Void
	{
		// 実行ロックのチェック
		if (executeLock) throw new SipoError("実行関数が入れ子になっています");
		executeLock = true;
		var tmpTasks = tasks;	// 変数を退避
		// 先に初期化
		clear();
		// 実行
		for (i in 0...tmpTasks.length)// 配列の頭から実行
		{
//			if (i == tmpTasks.length - 1) executeLock = false;	// 最後の項目なら実行前にロックを解除
// MEMO:最終項目から、再度executeすることに備えていたが、そもそもそれも入れ子じゃね？みたいな気がして、今のところコメントアウトしている
			tmpTasks[i].func();
		}
		tmpTasks = null;
		executeLock = false;
	}
}

class Task
{
	public var func:Void -> Void;
	public var pos:PosInfos;
	
	public function new(func:Void -> Void, pos:PosInfos)
	{
		this.func = func;
		this.pos = pos;
	}
	
	public function toString():String
	{
		return '[TASK ${pos} ${func}]';
	}
}

