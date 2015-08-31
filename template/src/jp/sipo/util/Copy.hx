package jp.sipo.util;
/**
 * 
 * 
 * @auther sipo
 */
class Copy
{
	/**
	 * 対象オブジェクトをディープコピーする
	 */
	public static function deep(target:Dynamic):Dynamic
	{
		// これは遅い。改善できる
		return haxe.Unserializer.run(haxe.Serializer.run(target));
	}
}
