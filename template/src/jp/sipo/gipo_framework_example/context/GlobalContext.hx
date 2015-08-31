package jp.sipo.gipo_framework_example.context;
/**
 * 全体設定
 * 
 * Sectionをどうしても跨ぐ必要のあるデータのみを管理する。
 * 基本的にその起動状態で固定の値を使用する。
 * Diffuseで代用できないか検討するべき。
 * 
 * @auther sipo
 */
import haxe.ds.Option;
class GlobalContext
{
	/** 画面基本サイズ */
	inline public static var stageWidth:Int = 480;
	inline public static var stageHEIGHT:Int = 720;
	
	/** 可変画面サイズ */
	public var screenSize:Option<{width:Int, height:Int}> = Option.None;
	
	/** コンストラクタ */
	public function new() 
	{
	}
}
