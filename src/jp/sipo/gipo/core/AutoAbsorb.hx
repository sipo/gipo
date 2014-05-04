package jp.sipo.gipo.core;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Constant;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;

using haxe.macro.TypeTools;

typedef MacroType = haxe.macro.Type;
#end

@:autoBuild(jp.sipo.gipo.core._AutoAbsorb.Impl.build())
interface AutoAbsorb { }

class AutoAbsorbTag {
	public static inline var ABSORB_TAG:String = "absorb";
	public static inline var ABSORB_WITH_KEY_TAG:String = "absorbWithKey";
	
	public static inline var ABSORB_TAG_HOOK:String = ":" + ABSORB_TAG;
	public static inline var ABSORB_WITH_KEY_TAG_HOOK:String = ":" + ABSORB_WITH_KEY_TAG;
}

private class Impl {
	
	macro private static function build():Array<Field> {
		var fields = Context.getBuildFields();
		
		// すべてのフィールドを走査して
		for (field in fields) {
			switch (field) {
				// 型指定のないメンバ変数
				case { kind: FieldType.FVar(null, _) } :
					Context.warning("#5", field.pos);
				// kind が 'FieldType.FVar' のフィールドに関して
				case { kind: FieldType.FVar(ComplexType.TPath({ name: tpath_name }), _), meta: field_meta } : 
					// メンバ変数のメタデータすべてを走査して
					for (meta in field_meta) {
						switch (meta.name) {
							// 対象のメタデータが ABSORB_WITH_KEY_TAG_HOOK('@:absorbWithKey') ならば
							case AutoAbsorbTag.ABSORB_WITH_KEY_TAG_HOOK :
								// メタデータのパラメータ全てについて
								switch (meta.params) {
									case
										// パラメータが (foo.bar.baz.Hoge.Fuga) のとき
										[ { expr: ExprDef.EField({ expr: ExprDef.EField(_, key_enum) }, key_enum_value)} ]
										// パラメータが (Hoge.Fuga) のとき
									|	[ { expr: ExprDef.EField({ expr: ExprDef.EConst(Constant.CIdent(key_enum)) }, key_enum_value)} ]
										if (Context.getType(key_enum).match(MacroType.TEnum)) :
										// メタデータの名前を '@absorbWithKey' に書き換え
										meta.name = AutoAbsorbTag.ABSORB_WITH_KEY_TAG;
										meta.params = [
											// キーの列挙（Enum)の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(Context.getType(key_enum).toString())), pos: Context.currentPos() },
											// キー（EnumValue）の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(key_enum_value)), pos: Context.currentPos() }
										];
									// パラメータに値が渡されていない
									case params if (params.length == 0) :
										Context.error("#1 : メタデータ '@:absorbWithKey' には、1つのパラメータが必要です。", meta.pos);
									case params if (params.length >= 2) :
										Context.error("#2 : メタデータ '@:absorbWithKey' に対して複数のキーが指定されました。", meta.pos);
									case _ :
										Context.error("#3 : メタデータのパラメータが対応していない形式です。", meta.pos);
								}
							// 対象のメタデータが ABSORB_TAG_HOOK('@:absorb') ならば
							case AutoAbsorbTag.ABSORB_TAG_HOOK :
								switch (meta.params) {
									case [] :
										meta.name = AutoAbsorbTag.ABSORB_TAG;
										meta.params = [
											{ expr: ExprDef.EConst(Constant.CString(Context.getType(tpath_name).toString())), pos: Context.currentPos() }
										];
									case _ :
										Context.error("#4 : メタデータ '@:absorb' にパラメータが指定されました。", meta.pos);
								}
						}
					}
				case _ :
					
			}
		}
		
		return fields;
	}
	
}
