package ;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Constant;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;
import haxe.macro.Type;
import haxe.Serializer;

@:autoBuild(AutoAbsorber.Absorber.build())
interface AutoAbsorber{ }

class Absorber {
	
	public static inline var ABSORB_TAG:String = "absorb";
	public static inline var ABSORB_KEY_TAG:String = "absorbKey";
	
	macro private static function build():Array<Field> {
		/* AST */
		var fields = Context.getBuildFields();
		
		// すべてのフィールドを走査して
		for (field in fields) {
			switch (field) {
				// kind が 'FieldType.FVar' のフィールドに関して
				case { kind : FieldType.FVar(ComplexType.TPath( { name: var_tpath_name, pack: var_tpath_packs } ), _), meta : field_meta, name: field_name } : 
					// メンバ変数のメタデータすべてを走査して
					for (meta in field_meta) {
						switch (meta) {
							// 対象のメタデータが '@:absorbKey' ならば
							case { name : _ => ":absorbKey", pos: pos_infos } :
								// メタデータのすべてのパラメータが
								switch (meta.params) {
									case
										[ { expr: ExprDef.EField( { expr: ExprDef.EField(_, meta_param_field_enum) }, meta_param_field_enum_value) } ]
									|	[ { expr: ExprDef.EField( { expr: ExprDef.EConst(Constant.CIdent(meta_param_field_enum)) }, meta_param_field_enum_value) } ] :
										var vxk = switch (Context.getType('${meta_param_field_enum}')) {
											case Type.TEnum(eRef, _) :
												eRef.toString();
											case _ :
												Context.error("#4", Context.currentPos());
										};
										meta.name = "absorbKey";
										meta.params = [
											{ expr : ExprDef.EConst(Constant.CString(vxk)), pos: Context.currentPos() },
											{ expr : ExprDef.EConst(Constant.CString(meta_param_field_enum_value)), pos: Context.currentPos() }
										];
									// パラメータに値が渡されていない
									case [] :
										// FIXME : 文字化けが起きる
										Context.error("#1", pos_infos);
									case _ :
										// FIXME : 文字化けが起きる
										Context.error("#2", pos_infos);
								}
							// 対象のメタデータが '@:absorb' ならば
							case { name : _ => ":absorb" } :
								meta.name = "absorb";
								meta.params = [];
								var tpath_name_v_i = switch (Context.getType(var_tpath_name)) {
									case Type.TInst(tRef, _) :
										tRef.toString();
									case _ :
										Context.error("#3", Context.currentPos());
								}
								meta.params.push( { expr : ExprDef.EConst(Constant.CString(tpath_name_v_i)), pos: Context.currentPos() } );
						}
					}
				case _ :
					
			}
		}
		
		
		return fields;
	}
}
