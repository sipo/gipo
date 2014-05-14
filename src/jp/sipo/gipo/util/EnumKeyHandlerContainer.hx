package jp.sipo.gipo.util;
/**
 * 各種ハンドラをEnumで管理して、その後呼び出す仕組み
 * 
 * @auther sipo
 */
import haxe.PosInfos;
import jp.sipo.util.SipoError;
class EnumKeyHandlerContainer
{// FIXME:必要性の検討
	/* 対応するEnumの名前とハンドラ */
	private var map:Map<String/*EnumName*/, EnumValue -> Void> = new Map();
	
	/** コンストラクタ */
	public function new() 
	{
	}

	/**
	 * 登録を登録する
	 */
	public function set(keyEnum:Enum<Dynamic>, func:Dynamic/*EnumValue*/ -> Void):Void
	{
		var enumName:String = Type.getEnumName(keyEnum);
		for (key in map.keys())
		{
			if (key ==enumName){
				throw new SipoError('setOrderHandlerが２重に呼び出されました this=$this keyEnum=$keyEnum');
			}
		}
		map.set(enumName, cast(func));
	}
	
	/**
	 * 登録関数を呼び出す
	 */
	public function call(command:EnumValue, ?pos:PosInfos):Void
	{
		var enumName:String = Type.getEnumName(Type.getEnum(command));
		for (key in map.keys())
		{
			if (key == enumName){
				var func = map.get(key);
				func(command);
				return;
			}
		}
		throw new SipoError('対応していないEnumが呼び出されました command=$command orderEnumList=$map', pos);
	}
}
