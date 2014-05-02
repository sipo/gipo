package jp.sipo.gipo.core;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.Field;

using haxe.macro.TypeTools;

typedef MacroType = haxe.macro.Type;
#end

@:autoBuild(jp.sipo.gipo.core._AutoHandler.Impl.build())
interface AutoHandler { }

class AutoHandlerTag {
	public static inline var HANDLER_TAG:String = "handler";
	public static inline var RED_TAPE_HANDLER:String = "redTapeHandler";
	
	public static inline var HANDLER_TAG_HOOK:String = ":" + HANDLER_TAG;
	public static inline var RED_TAPE_HANDLER_HOOK:String = ":" + RED_TAPE_HANDLER;
}

private class Impl {
	macro private static function build():Array<Field> {
		var fields = Context.getBuildFields();
		
		// すべてのフィールドを走査して
		for (field in fields) {
			switch (field) {
				// kind が 'FieldType.FFun' のフィールドに関して
				case { kind: FieldType.FFun(_), meta: fun_meta } :
					for (meta in fun_meta) {
						// @:handler(GearHandler.Run)
						// => @handler([GearHandler, Run])
						
						// @:redTapeHandler(LogicSceneHandler.ViewInput)
						// => @redTapeHandler([LogicSceneHandler, ViewInput, SceneInput])
						switch (meta.name) {
							// 対象のメタデータが HANDLER_TAG_HOOK(':handler')ならば
							case AutoHandlerTag.HANDLER_TAG_HOOK :
								switch (meta.params) {
									case
										// パラメータが (foo.bar.baz.Hoge.Fuga) のとき
										[ { expr: ExprDef.EField({ expr: ExprDef.EField(_, key_enum) }, key_enum_value)} ]
										// パラメータが (Hoge.Fuga) のとき
									|	[ { expr: ExprDef.EField({ expr: ExprDef.EConst(Constant.CIdent(key_enum)) }, key_enum_value)} ]
										if (Context.getType(key_enum).match(MacroType.TEnum)) :
										// メタデータの名前を '@handler' に書き換え
										meta.name = AutoHandlerTag.HANDLER_TAG;
										meta.params = [
											// キーの列挙（Enum)の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(Context.getType(key_enum).toString())), pos: Context.currentPos() },
											// キー（EnumValue）の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(key_enum_value)), pos: Context.currentPos() }
										];
									case _ :
										
								}
							// 対象のメタデータが RED_TAPE_HANDLER_HOOK(':redTapeHandler')ならば
							case AutoHandlerTag.RED_TAPE_HANDLER_HOOK :
								switch (meta.params) {
									case
										// パラメータが (foo.bar.baz.Hoge.Fuga) のとき
										[ { expr: ExprDef.EField({ expr: ExprDef.EField(_, key_enum) }, key_enum_value)} ]
										// パラメータが (Hoge.Fuga) のとき
									|	[ { expr: ExprDef.EField({ expr: ExprDef.EConst(Constant.CIdent(key_enum)) }, key_enum_value)} ]
										if (Context.getType(key_enum).match(MacroType.TEnum)) :
										// メタデータの名前を '@redTapeHandler' に書き換え
										meta.name = AutoHandlerTag.RED_TAPE_HANDLER;
										meta.params = [
											// キーの列挙（Enum)の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(Context.getType(key_enum).toString())), pos: Context.currentPos() },
											// キー（EnumValue）の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(key_enum_value)), pos: Context.currentPos() },
											{ expr : ExprDef.EConst(Constant.CString(
												switch (field) {
													case { kind: FieldType.FFun( { args: [{ type: ComplexType.TPath(tpath) }] } ) } :
														Context.getType(tpath.name).toString();
													case _ :
														Context.error("#5", meta.pos);
												}
											)), pos: Context.currentPos() },
										];
									case _ :
										
								}
						}
					}
				case _ :
					
			}
		}
		
		return fields;
	}
}

