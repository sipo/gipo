package jp.sipo.gipo.core.handler;
/**
 * 担当EnumValueを限定したDispatcher
 * 持ち方が違うのでGenericGearDispatcherを継承しない
 * 
 * @auther sipo
 */
import jp.sipo.util.SipoError;
import haxe.PosInfos;
private typedef TFunc = Dynamic/*EnumValue*/ -> Void;
private typedef EnumName = String;
class GearDispatcherRedTape
{
	/* ハンドラの保持 */
	private var roleMap:Map<EnumName, GearDispatcherHandler<TFunc>> = new Map<EnumName, GearDispatcherHandler<TFunc>>();
	
	/* 生成位置 */
	private var dispatcherPos:PosInfos;
	
	/** コンストラクタ */
	public function new(?dispatcherPos:PosInfos) 
	{
		this.dispatcherPos = dispatcherPos;
	}
	
	/** ハンドラの登録 */
	public function set(role:Enum<Dynamic>, handler:TFunc, ?addPos:PosInfos):Void
	{
		setFromName(Type.getEnumName(role), handler, addPos);
	}
	
	/** 自動登録 */
	public function setFromName(roleName:EnumName, handler:TFunc, ?addPos:PosInfos):Void
	{
		if (roleMap.exists(roleName)) throw '既に設定されている担当Enumです $roleName, $addPos';
		roleMap.set(roleName, new GearDispatcherHandler(handler, addPos));
	}
	
	/**
	 * 実行
	 */
	public function execute(command:EnumValue, ?executePos:PosInfos):Void
	{
		var enumName:EnumName = Type.getEnumName(Type.getEnum(command));
		if (!roleMap.exists(enumName)) throw new SipoError('対応していないEnumが呼び出されました command=$command roleMap=$roleMap dispatcherPos=$dispatcherPos', executePos);
		var handler:GearDispatcherHandler<TFunc> = roleMap.get(enumName);
		handler.func(command);
	}
}
