package ;

import haxe.macro.Context;
import haxe.macro.Expr.ComplexType;
import haxe.macro.Expr.Constant;
import haxe.macro.Expr.ExprDef;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.FieldType;

@:autoBuild(AutoAbsorber.Absorber.build())
interface AutoAbsorber{ }

class Absorber {
	
	macro private static function build():Array<Field> {
		/* AST */
		var fields = Context.getBuildFields();
		
		/* 対象の構造体を回収するためのリスト */
		var absorbKeyList:List<{ mpcn:String, mpf:String, fn:String}> = new List();
		var absorbList:List<{ vtn:String, fn:String }> = new List();
		
		// すべてのフィールドを走査して
		for (field in fields) {
			switch (field) {
				// kind が 'FieldType.FVar' のフィールドに関して
				case { kind : FieldType.FVar(ComplexType.TPath( { name : var_tpath_name } ), _), meta : field_meta, name: field_name } : 
					// メンバ変数のメタデータすべてを走査して
					for (meta in field_meta) {
						switch (meta) {
							// 対象のメタデータが '@:absorbKey' ならば
							case { name : _ => ":absorbKey", pos: pos_infos } :
								// メタデータのすべてのパラメータが
								switch (meta.params) {
									// パラメータの構文解析 : <meta_param_cident_name:Enum>.<meta_param_field:EnumValue>
									case [ { expr : ExprDef.EField( { expr : ExprDef.EConst(Constant.CIdent(meta_param_cident_name)) }, meta_param_field) } ] :
										absorbKeyList.add( { mpcn : meta_param_cident_name, mpf : meta_param_field, fn : field_name } );
									// パラメータに値が渡されていない
									case [] :
										// FIXME : 文字化けが起きる
										Context.error("キーが必要です。", pos_infos);
									case _ :
										// FIXME : 文字化けが起きる
										Context.error("複数のキーを指定することはできません。", pos_infos);
								}
							// 対象のメタデータが '@:absorb' ならば
							case { name : _ => ":absorb" } :
								/* trace(meta_name, var_tpath_name, field_name); */
								absorbList.add( { vtn : var_tpath_name, fn : field_name, });
						}
					}
				case _ :
					
			}
		}
		
		var absorber = Context.parse('gear.addAutoAbsorbHandler(function () {})', Context.currentPos());
		/* absorberの構築 */
		switch (absorber) {
			case { expr : ExprDef.ECall(_, [ { expr : ExprDef.EFunction(_, { expr : { expr : ExprDef.EBlock(efbexpr)  } } ) } ]) } :
				absorbKeyList.map(function (ak) {
					efbexpr.push( Context.parse('this.${ak.fn} = gear.absorbWithEnum(${ak.mpcn}.${ak.mpf})', Context.currentPos()) );
				});
				absorbList.map(function (ak) {
					efbexpr.push( Context.parse('this.${ak.fn} = gear.absorb(${ak.vtn})', Context.currentPos()) );
				});
			case _ :
				Context.warning("#", Context.currentPos());
		}
		
		/* absorberをASTに挿入する */
		for (field in fields) {
			switch (field) {
				case { kind : FieldType.FFun( { expr : { expr : ExprDef.EBlock(ffun_exprs) } } ), name: _ => "new" } : 
					// FIXME : 何も考えずにASTをコンストラクタの2コンテキスト目に挿入しているので処理としては不適切
					ffun_exprs.insert(1, absorber);
				case _ :
			}
		}
		
		return fields;
	}
}
