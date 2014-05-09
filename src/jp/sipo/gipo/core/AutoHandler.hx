package jp.sipo.gipo.core;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.FieldType;
import haxe.macro.Expr.Field;

using haxe.macro.TypeTools;

private typedef MacroType = haxe.macro.Type;
#end

@:autoBuild(jp.sipo.gipo.core._AutoHandler.Impl.build())
interface AutoHandler { }

class AutoHandlerTag {
	public static inline var HANDLER_TAG:String = "handler";
	public static inline var RED_TAPE_HANDLER_TAG:String = "redTapeHandler";
	
	public static inline var HANDLER_TAG_HOOK:String = ":" + HANDLER_TAG;
	public static inline var RED_TAPE_HANDLER_TAG_HOOK:String = ":" + RED_TAPE_HANDLER_TAG;
}

private class Impl {
	macro private static function build():Array<Field> {
		var fields = Context.getBuildFields();
		
		// 変換規則
		// @:handler(GearHandler.Run)
		// 	=> @handler([GearHandler, Run])
		// @:redTapeHandler(LogicSceneHandler.ViewInput)
		// 	=> @redTapeHandler([LogicSceneHandler, ViewInput, SceneInput])
		
		// すべてのフィールドを走査して
		for (field in fields) {
			switch (field) {
				// kind が 'FieldType.FFun' のフィールドに関して
				case { kind: FieldType.FFun(_), meta: fun_meta } :
					for (meta in fun_meta) {
						switch (meta.name) {
							// 対象のメタデータが HANDLER_TAG_HOOK(':handler')、
							// または RED_TAPE_HANDLER_HOOK('@:redTapeHandler')ならば
							case
								AutoHandlerTag.HANDLER_TAG_HOOK
							|	AutoHandlerTag.RED_TAPE_HANDLER_TAG_HOOK :
								switch (meta.params) {
									case
										// パラメータが (foo.bar.baz.Hoge.Fuga) のとき
										[ { expr: ExprDef.EField({ expr: ExprDef.EField(_, key_enum) }, key_enum_value)} ]
										// パラメータが (Hoge.Fuga) のとき
									|	[ { expr: ExprDef.EField({ expr: ExprDef.EConst(Constant.CIdent(key_enum)) }, key_enum_value)} ]
										if (Context.getType(key_enum).match(MacroType.TEnum)) :
										
										meta.params = [
											// キーの列挙（Enum)の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(Context.getType(key_enum).toString())), pos: Context.currentPos() },
											// キー（EnumValue）の完全修飾名
											{ expr : ExprDef.EConst(Constant.CString(key_enum_value)), pos: Context.currentPos() }
										];
									case _ :
										
								}
						}
						
						switch (meta.name) {
							case AutoHandlerTag.HANDLER_TAG_HOOK :
								// メタデータの名前を '@handler' に書き換え
								meta.name = AutoHandlerTag.HANDLER_TAG;
								
							case AutoHandlerTag.RED_TAPE_HANDLER_TAG_HOOK :
								// メタデータの名前を '@redTapeHandler' に書き換え
								meta.name = AutoHandlerTag.RED_TAPE_HANDLER_TAG;
								
								var arg = switch (field) {
									case
										{ kind: FieldType.FFun({ args: [{ type: ComplexType.TPath(tpath) }] }) }
										if (Context.getType(tpath.name).match(MacroType.TEnum)) :
										Context.getType(tpath.name).toString();
									case _ :
										Context.error("#5", meta.pos);
								};
								meta.params.push({ expr : ExprDef.EConst(Constant.CString(arg)), pos: Context.currentPos() });
						}
					}
				case _ :
					
			}
		}
		
		return fields;
	}
}

