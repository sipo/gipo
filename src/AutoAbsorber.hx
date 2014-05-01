package ;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Constant;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Type;

using haxe.macro.TypeTools;
#end

@:autoBuild(_AutoAbsorber.Impl.build())
interface AutoAbsorber { }

class Tag {
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
				// kind が 'FieldType.FVar' のフィールドに関して
				case { kind: FieldType.FVar(ComplexType.TPath({ name: tpath_name }), _), meta: field_meta } : 
					// メンバ変数のメタデータすべてを走査して
					for (meta in field_meta) {
						switch (meta) {
							// 対象のメタデータが ABSORB_WITH_KEY_TAG_HOOK('@:absorbWithKey') ならば
							case { name : _ => Tag.ABSORB_WITH_KEY_TAG_HOOK, pos: position } :
								// メタデータのパラメータ全てについて
								switch (meta.params) {
									case
										// パラメータが (foo.bar.baz.Hoge.Fuga) のとき
										[ { expr: ExprDef.EField({ expr: ExprDef.EField(_, key_enum) }, key_enum_value)} ]
										// パラメータが (Hoge.Fuga) のとき
									|	[ { expr: ExprDef.EField({ expr: ExprDef.EConst(Constant.CIdent(key_enum)) }, key_enum_value)} ]
										if (Context.getType(key_enum).match(Type.TEnum)) :
										// メタデータの名前を '@absorbWithKey' に書き換え
										meta.name = Tag.ABSORB_WITH_KEY_TAG;
										meta.params = [
											// キーの列挙（Enum)の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(Context.getType(key_enum).toString())), pos: Context.currentPos() },
											// キー（EnumValue）の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(key_enum_value)), pos: Context.currentPos() }
										];
									// パラメータに値が渡されていない
									case params if (params.length == 0) :
										Context.error("#1 : メタデータ '@:absorbWithKey' には、1つのパラメータが必要です。", position);
									case params if (params.length >= 2) :
										Context.error("#2 : メタデータ '@:absorbWithKey' に対して複数のキーが指定されました。", position);
									case _ :
										Context.error("#3 : メタデータのパラメータが対応していない形式です。", position);
								}
							// 対象のメタデータが ABSORB_TAG_HOOK('@:absorb') ならば
							case { name: _ => Tag.ABSORB_TAG_HOOK, pos: position } :
								switch (meta.params) {
									case [] :
										meta.name = Tag.ABSORB_TAG;
										meta.params = [
											{ expr: ExprDef.EConst(Constant.CString(Context.getType(tpath_name).toString())), pos: Context.currentPos() }
										];
									case _ :
										Context.error("#4 : メタデータ '@:absorb' にパラメータが指定されました。", position);
								}
						}
					}
				case _ :
					
			}
		}
		
		return fields;
	}
	
}
