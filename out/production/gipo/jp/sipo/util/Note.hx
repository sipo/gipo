package jp.sipo.util;

/**
 * ...
 * @author sipo
 */
import haxe.macro.Expr;
import haxe.macro.Context;
import Std;
import haxe.PosInfos;
using Lambda;
class Note
{
	/* ================================================================
	 * 定数
	 */
	
	// 各種色
	public static inline var LOG_COLOR:Int = 0x000000;
	public static inline var DEBUG_COLOR:Int = 0x663300;
	
	// エラー文言
	public static inline var WAIT_ERROR_MESSAGE:String = "タグ設定の待機中にNoteが呼ばれました。";
	public static inline var HIDE_DEBUG_WARNING:String = "デバッグ表示が残っています。";
	public static inline var NO_ALLOW_TEMPORAL:String = "staticな一時的表示は現在許可されていません。";
	
	/* ================================================================
	 * 全体タグ設定処理
	 */	
	
	/* タグがすでに設定されているかどうか */
	private static var isSetTags:Bool = false;
	/* 表示タグ */
	private static var displayTags:Array<EnumValue>;
	/* 消去タグ */
	private static var hideTags:Array<EnumValue>;
	/* タグ設定の待機インスタンス */
	private static var waitInstances:Array<Note> = [];
	/* staticデバッグ表示の許可 */
	private static var allowTemporal:Bool = true;
	/* trace表示用関数 */
	private static var logFunction:String -> PosInfos -> Void = defaultLog;
	/* trace表示用関数 */
	private static var debugFunction:String -> PosInfos -> Void = defaultDebug;
	
	/**
	 * 表示用タグの設定
	 */
	// MEMO:引数がStringでなければならない理由がよく分からなくなっている。判定に関わる？
	public static function setTags(displayTags:Array<EnumValue>, hideTags:Array<EnumValue>):Void
	{
		if (isSetTags) throw new SipoError("タグの設定を変更することは想定されていません");	
		// MEMO:もし設定を途中で変える仕様にする場合、すでに設定されてしまっているNoteへの通知が必要になる。その場合全てのインスタンスの保持と、disposeが必要
		// 値の設定
		isSetTags = true;
		Note.displayTags = displayTags;
		Note.hideTags = hideTags;
		// 待機状態にあったインスタンスのタグチェックを実行する
		for (i in 0...waitInstances.length) {
			var instance:Note = waitInstances[i];
			instance.checkTags();
		}
	}
	
	/**
	 * staticな一時表示を許可するかどうかの切り替え。
	 * リリース前には非許可にするのを推奨
	 */
	public static function setAllowTemporal(allow:Bool):Void
	{
		allowTemporal = allow;
	}
	
	/**
	 * 表示用関数を設定する
	 */
	public static function setDisplayFunction(logFunction:String -> PosInfos -> Void, debugFunction:String -> PosInfos -> Void):Void
	{
		Note.logFunction = logFunction;
		Note.debugFunction = debugFunction;
	}
	
	/**
	 * デフォルトの表示関数
	 */
	public static function defaultLog(message:Dynamic, ?posInfos:PosInfos):Void
	{
		//Log.trace(message, posInfos);
		flashTrace(message, posInfos);
	}
	
	/**
	 * デフォルトのデバッグ関数
	 */
	public static function defaultDebug(message:Dynamic, ?posInfos:PosInfos):Void
	{
		//Log.trace("d\t" + message, posInfos);
		flashTrace("d\t" + message, posInfos);
	}
	
	/*
	 * Flash用のTraceカスタム関数
	 */
	private static inline function flashTrace(message:Dynamic, posInfos:PosInfos):Void
	{
		#if flash
		flash.Lib.trace(message + '  ${posInfos.fileName}:${posInfos.methodName}(${posInfos.lineNumber})');
		#end
	}
	
	/* ================================================================
	 * 個別処理
	 */
	 
	/* 待機状態（logを出そうとするとエラー） */
	private var waitTagsSet:Bool = false;
	/* 表示状態 */
	private var display:Bool = false;
	/* このインスタンスのタグ状態 */
	private var localTags:Array<EnumValue>;
	/* タグの文字列表記 */
	private var tagsString:String;
	/* 初回デバッグの表示 */
	private var isFirstDebug:Bool = true;
	
	/**
	 * コンストラクタ
	 */
	public function new(tags:Array<EnumValue>) 
	{
		localTags = tags;
		tagsString = " <" + tags.join(",") + ">";	// 表示の最後につけるやつ
		if (!isSetTags){
			// まだタグ設定がされていない場合、待機リストへ追加
			waitTagsSet = true;
			waitInstances.push(this);
			return;
		}
		// すでにタグ設定があるなら、タグによってこのNoteのフラグを変更する
		checkTags();
	}
	
	/*
	 * タグの状態で表示非表示を判断
	 */
	private function checkTags():Void
	{
		waitTagsSet = false;
		// タグをチェック。表示タグがゼロの場合すべて表示扱いになる。hideTagでマスクもする
		display =  (displayTags.length == 0 || isTag(localTags, displayTags)) && !isTag(localTags, hideTags);
	}
	/* タグの出現チェック*/
	private function isTag(target:Array<EnumValue>, checker:Array<EnumValue>):Bool
	{
		for (tag in target) if (checker.has(tag)) return true;
		return false;
	}
	
	/**
	 * システム出力
	 */
	public function log(message:Dynamic, ?posInfos:PosInfos):Void
	{
		if (waitTagsSet) throw new SipoError(WAIT_ERROR_MESSAGE);	// 必要ならエラーを起こさないlogを用意する
		if (!display) return;
		logFunction(message + tagsString, posInfos);
	}
	
	/**
	 * デバッグ表示
	 */
	public function debug(message:Dynamic, ?posInfos:PosInfos):Void
	{
		if (waitTagsSet) throw new SipoError(WAIT_ERROR_MESSAGE);
		if (!display){	// デバッグ表示は、非表示時も、初回のみ存在について通知する
			checkDebugFirst(posInfos);
			return;
		}
		debugFunction(Std.string(message) + tagsString, posInfos);
	}
	
	
	/*
	 * 非表示状態でも、デバッグ関係の出力は１度だけ警告表示を出す
	 */
	private inline function checkDebugFirst(posInfos:PosInfos):Void
	{
		if (isFirstDebug){
			isFirstDebug = false;
			debugFunction(HIDE_DEBUG_WARNING + tagsString, posInfos);
		}
	}
	
	
	/* ================================================================
	 * static処理
	 */
	
	/**
	 * 特定値をMacroで表示。一時的なテスト用
	 */
	macro public static function valueDisplay(valueExpr:Expr):Expr
	{
		var pos:Position = Context.currentPos();
		var paramNameEReg:EReg = ~/(.*\()|\)/g;
		var paramName = paramNameEReg.replace(Std.string(valueExpr.expr), "");

		return macro {
			var fileName = ($v{pos}.fileName).split("/").pop();
			var posInfo = {
					fileName : fileName,
					lineNumber : $v{pos}.lineNumber,
					className : $v{pos}.className,
					methodName : "inMacro",
				};
			Note.valueDisplay_($v{paramName} + " = " + $e{valueExpr} + " " + $v{valueExpr.pos}, posInfo);
		}
	}
	/**
	 * 値の一時表示
	 */
	public static function valueDisplay_(message:Dynamic, ?posInfos:PosInfos):Void
	{
		if (!allowTemporal) throw new SipoError(NO_ALLOW_TEMPORAL + posInfos);
		debugFunction(Std.string(message), posInfos);
	}
	
	/**
	 * 一時的なデバッグ表示
	 */
	public static function temporal(message:Dynamic, ?posInfos:PosInfos):Void
	{
		if (!allowTemporal) throw new SipoError(NO_ALLOW_TEMPORAL + posInfos);
		debugFunction(Std.string(message) + "<NoteStatic>", posInfos);
	}
	
	/**
	 * マークを付けるだけ。テスト用
	 */
	macro public static function mark():Expr
	{
		var pos:Position = Context.currentPos();
		return macro {
			var fileName = ($v{pos}.fileName).split("/").pop();
			var posInfo = {
					fileName : fileName,
					lineNumber : $v{pos}.lineNumber,
					className : $v{pos}.className,
					methodName : "inMacro",
				};
			Note.valueDisplay_("---mark--- " , posInfo);
		}
	}
}
enum CommonTag
{
	common;
//	notice;
//	warning;
}
