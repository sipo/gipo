package jp.sipo.gipo.core;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Constant;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.Metadata;
import haxe.macro.Expr.MetadataEntry;
import haxe.macro.Expr.Position;
import haxe.macro.Type.ClassField;
import haxe.macro.Type.FieldKind;
import haxe.macro.ExprTools;

using haxe.macro.TypeTools;
using Lambda;

private typedef MacroType = haxe.macro.Type;

#end

#if !macro
@:build(jp.sipo.gipo.core._AutoAbsorb.Impl.build())
#end
interface AutoAbsorb { }

class AutoAbsorbTag {
	public static inline var ABSORB_TAG:String = "absorb";
	public static inline var ABSORB_WITH_KEY_TAG:String = "absorbWithKey";
	
	public static inline var ABSORB_TAG_HOOK:String = ":" + ABSORB_TAG;
	public static inline var ABSORB_WITH_KEY_TAG_HOOK:String = ":" + ABSORB_WITH_KEY_TAG;
}


private class Impl {
	
	macro private static function build():Array<Field> {
		Context.onGenerate(onGenerate);
		return Context.getBuildFields();
	}
	
	#if macro
	
	private static function log(message:Dynamic, pos:Position):Void {
		#if debug_auto_absorb
		Context.warning('[AutoAbsorb]' + ' ' + message, pos);
		#end
	}
	
	private static function onGenerate(types:Array<MacroType>):Void {
		// すべての型について
		for (type in types) {
			switch (type) {
				case MacroType.TInst(_.get() => classType, _) : 
					
					var fields:Array<ClassField> = classType.fields.get();
					
					for (field in fields) {
						
						if (field.meta.has(AutoAbsorbTag.ABSORB_TAG_HOOK) &&
						    field.meta.has(AutoAbsorbTag.ABSORB_WITH_KEY_TAG_HOOK))
						{
							// '@:absorb' と '@:absorbWithKey' は同時に指定できない
							Context.fatalError('#0 : 1つのフィールドに対して @:absorb と @:absorbWithKey の両方を指定することはできません', field.pos);
						}
						
						// 以下は '@:absorb' か '@:absorbWithKey' またはどちらでもない
						
						// フィールドに関連付けられたすべてのメタデータ
						var entries:Array<MetadataEntry> = field.meta.get();
						var pos:Position = field.pos;
						
						if (field.meta.has(AutoAbsorbTag.ABSORB_TAG_HOOK)) {
							// フィールド（変数定義かメソッド定義は問わず）に '@:absorb' の指定がある
							// この時点で '@:absorbWithKey' は存在しないことが確定
							
							if (!isUniqueEntry(entries, AutoAbsorbTag.ABSORB_TAG_HOOK)) {
								// '@:absorb' の指定が2つ以上見つかった
								// 2つ以上存在しても本来は問題ないのだが 指定したところで利点等はないため止める
								Context.fatalError('#1 : 1つの変数に対して2つ以上の @:absorb 指定がされています', pos);
							}
							
							// '@:absorb' の指定はただ1つ（メタデータのエントリは2つ以上存在するかもしれない）
							analyzeAbsorbField(field, entries);
						}
						
						if (field.meta.has(AutoAbsorbTag.ABSORB_WITH_KEY_TAG_HOOK)) {
							// フィールド（変数定義かメソッド定義は問わず）に '@:absorbWithKey' の指定がある
							// この時点で '@:absorb' は存在しないことが確定
							
							if (!isUniqueEntry(entries, AutoAbsorbTag.ABSORB_WITH_KEY_TAG_HOOK)) {
								// '@:absorbWithKey' の指定が2つ以上見つかった
								Context.fatalError('#2 : 1つの変数に対して複数のキーが指定されています', pos);
							}
							
							// '@:absorbWithKey' の指定はただ1つ（メタデータのエントリは2つ以上存在するかもしれない）
							analyzeAbsorbWithKeyField(field, entries);
						}
						
					}
					
				case _ : 
			}
		}
		
	}
	
	/**
	 * 指定した名前のエントリがメタデータ内に1つだけ存在するか
	 * @param entries
	 * @param name メタデータエントリの名前
	 * @return ただ1つ存在するときに真
	 */
	private static function isUniqueEntry(entries:Metadata, name:String):Bool {
		// メタデータから指定の名前のエントリを数える
		var count:Int = entries.count(function (entry) { return entry.name == name; } );
		// エントリがただ1つだけ存在（唯一のエントリ）のときに真
		return count == 1;
	}
	
	/**
	 * 指定した名前のエントリを検索
	 * @param entries
	 * @param name メタデータエントリの名前
	 * @return 指定したエントリが存在するときそのエントリ
	 */
	private static function findMetadata(entries:Metadata, name:String):MetadataEntry {
		return entries.find(function (entry) { return entry.name == name; } );
	}
	
	/**
	 * '@:absorb' メタデータが付いたフィールドとして解析
	 * @param field
	 * @param entries
	 */
	private static function analyzeAbsorbField(field:ClassField, entries:Array<MetadataEntry>):Void {
		// フィールドの位置（エラー出力用）
		var pos:Position = field.pos;
		
		// フィールドに関して
		switch (field) {
			// 関数定義のとき
			case { kind : FieldKind.FMethod(_) } :
				Context.fatalError('#3 : メソッド定義に @:absorb は使用できません', pos);
			// 代入禁止(_, never) と定義されている変数のとき
			case { kind : FieldKind.FVar(_, AccNever) } :
				Context.fatalError('#4 : 代入できない変数(never)への @:absorb です', pos);
			// 適切な形式
			case { kind : FieldKind.FVar(_, _), type : type = MacroType.TInst(_, _) } :
				// 変数の型（完全修飾名）
				var tpath:String = TypeTools.toString(type);
				
				log('@:absorb : ' + field.name + ' / ' + tpath, pos);
				
				// メタデータの名前を '@absorb' に書き換え
				
				// '@:absorb' を削除
				field.meta.remove(AutoAbsorbTag.ABSORB_TAG_HOOK);
				// フィールドに '@absorb(tpath)' を追加
				field.meta.add(AutoAbsorbTag.ABSORB_TAG, [
					// 変数の型（完全修飾名）をパラメータとして持つ
					{ expr : ExprDef.EConst(Constant.CString(tpath)), pos: pos }
				], pos);
			// 対応していない形式（型定義が TInst以外のもの）
			case _ : 
				Context.fatalError('#5 : サポートしていない型に対する @:absorb です', pos);
		}
	}
	
	/**
	 * '@:absorbWithKey' メタデータが付いたフィールドとして解析
	 * @param field
	 * @param entries
	 */
	private static function analyzeAbsorbWithKeyField(field:ClassField, entries:Array<MetadataEntry>):Void {
		// メタデータのうち '@:absorbWithKey' のエントリ
		var entry:MetadataEntry = findMetadata(entries, AutoAbsorbTag.ABSORB_WITH_KEY_TAG_HOOK);
		
		if (entry.params.length >= 2) {
			// 1つの定義に複数のキーが指定された
			Context.fatalError('#6 : @:absorbWithKey に対して複数のキーが指定されています', entry.pos);
		}
		
		if (entry.params.length == 0) {
			// キーの指定が存在しない
			Context.fatalError('#7 : @:absorbWithKey には 1つのキーが必要です', entry.pos);
		}
		
		// キーは定義に対して1つだけ存在
		
		// メタデータ '@:absorbWithKey(foobar.baz.Hoge.Fuga)' が定義されているとき
		var tpath:String = null; // 'foobar.baz.Hoge'
		var value:String = null; // 'Fuga'
		
		{
			var strs = ExprTools.toString(entry.params[0]).split('.');
			
			tpath = strs.slice( 0, -1).join('.');
			value = strs.slice(-1    ).join('.');
		}
		
		try {
			// 指定した型Enum を取得
			// 型が存在しな場合はエラーが送出され制御がcatchに移る
			var key:MacroType = Context.getType(tpath);
			
			// 型Enum は存在する
			switch (key) {
				case MacroType.TEnum(_.get() => enumType, _) : 
					if (enumType.names.indexOf(value) == -1) {
						// 型'tpath' には値 'value'が定義されていない
						Context.fatalError('#8 : 値 ${value} は ${tpath} に定義されていません', entry.pos);
					}
					
					log('@:absorbWithKey : ' + field.name + ' / ' + tpath + '.' + value, field.pos);
					
					// メタデータの名前を '@absorbWithKey' に書き換え
					
					// '@:absorbWithKey' を削除
					field.meta.remove(AutoAbsorbTag.ABSORB_WITH_KEY_TAG_HOOK);
					// フィールドに '@absorbWithKey(tpath, value)' を追加
					field.meta.add(AutoAbsorbTag.ABSORB_WITH_KEY_TAG, [
						// キーの列挙(Enum)の完全修飾名
						{ expr : ExprDef.EConst(Constant.CString(tpath)), pos : Context.currentPos() },
						// キー(EnumValue)の完全修飾名
						{ expr : ExprDef.EConst(Constant.CString(value)), pos : Context.currentPos() },
					], Context.currentPos());
					
				case _ : 
					Context.fatalError('#9 : 対応していない形式のキーが指定されています（キーは EnumValueのみ対応しています）', entry.pos);
			}
			
		} catch (error:String) {
			Context.fatalError(error + ' (try using absolute path)', entry.pos);
		}
		
	}
	
	#end
	
}
