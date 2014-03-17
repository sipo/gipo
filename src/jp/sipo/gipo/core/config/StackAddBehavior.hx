package jp.sipo.gipo.core.config;
/**
 * OrderStackやTaskStackで、追加時の動作を決定するメソッド群
 * これを使わず、独自で実装してももちろんいい
 * 
 * @author sipo
 */
import jp.sipo.util.SipoError;
class StackAddBehavior 
{
	
	/**
	 * 複数実行時の対処プリセット。最後の１つのみ有効
	 */
	inline public static function lastOnly<T>(list:Array<T>, newTask:T):Void
	{
		list.pop();	// あるものを削除
		list.push(newTask);	// 新しいのを追加
	}
	
	/**
	 * 複数実行時の対処プリセット。全てを順に実行
	 */
	inline public static function addTail<T>(list:Array<T>, newTask:T):Void
	{
		list.push(newTask);	// 新しいのを追加
	}
	/**
	 * 複数実行時の対処プリセット。全てを逆順に実行
	 */
	inline public static function addHead<T>(list:Array<T>, newTask:T):Void
	{
		list.unshift(newTask);	// 新しいのを頭に追加
	}
	
	/**
	 * 複数実行時の対処プリセット。複数の場合エラー
	 */
	inline public static function error<T>(list:Array<T>, newTask:T):Void
	{
		if (list.length == 0) list.push(newTask);
		else throw new SipoError('このタスクは複数登録出来ません${list} ${newTask}');
	}
	
}
