package jp.sipo.gipo.core;
/**
 * 渡すべきインスタンスを管理する
 * 階層構造を取り、現在以下の階層全てに対象インスタンスを提供する
 * 
 * @author sipo
 */
import Map.IMap;
import haxe.EnumTools.EnumValueTools;
import haxe.PosInfos;
import jp.sipo.util.SipoError;
class Diffuser
{
	/* 親Diffuser */
	private var parent : Diffuser;
	/* クラスを使った辞書 */
	private var instanceClassDictionary:Map<String, Dynamic>;	// MEMO:本来は、Class<Dynamic>などをキーにしたいが、Mapが対応していない
	/* Enumキーを使った辞書 */
	private var instanceEnumDictionary:Map<String, Map<EnumValue, Dynamic>>;
	/* 関連クラス（デバッグ表示のみに使用される） */
	private var holder:Dynamic;
	
	/**
	 * コンストラクタ
	 */
	public function new(holder:Dynamic) 
	{
		this.holder = holder;
		// 変数初期化
		parent = null;
		instanceClassDictionary = new Map<String, Dynamic>();
		instanceEnumDictionary = new Map<String, Map<EnumValue, Dynamic>>();
	}
	
	/* ================================================================
	 * 機能
	 */
	
	/**
	 * 親を設定。
	 * @param parent 親Diffuser
	 */
	public function setParent(parent:Diffuser):Void
	{
		this.parent = parent;
	}
	
	/**
	 * Diffuseインスタンスを新規登録する
	 * @param diffuseInstance 対象インスタンス
	 * @param clazz インスタンスをどのクラスに関連付けて登録するか。
	 * @param overwrite 上書きを許可するかどうか
	 */
	public function add(diffuseInstance:Dynamic, clazz:Class<Dynamic>):Void
	{
		var className:String = Type.getClassName(clazz);
		if (instanceClassDictionary.exists(className)) throw new SipoError("既に登録されているクラスを登録しようとしました" + instanceClassDictionary.get(className));
		instanceClassDictionary.set(className, diffuseInstance);
	}
	
	/**
	 * 明示的に消去
	 */
	public function remove(clazz:Class<Dynamic>):Void
	{
		var className:String = Type.getClassName(clazz);
		instanceClassDictionary.remove(className);
	}
	
	/**
	 * Diffuseインスタンスをキー持ちで新規登録する
	 */ 
	public function addWithKey(diffuseInstance:Dynamic, enumKey:EnumValue):Void
	{
		var targetDictionary = getTargetEnumDictionary(enumKey);
		if (targetDictionary.exists(enumKey)) throw new SipoError("既に登録されているEnumを登録しようとしました" + targetDictionary.get(enumKey));
		targetDictionary.set(enumKey, diffuseInstance);
	}
	
	/**
	 * 明示的に消去
	 */
	public function removeWithKey(enumKey:EnumValue):Void
	{
		var targetDictionary = getTargetEnumDictionary(enumKey);
		targetDictionary.remove(enumKey);
	}
	
	/**
	 * Diffuseインスタンスを取得する
	 * @param clazz 関連付けられたクラス
	 */
	public function get(clazz : Class<Dynamic>, ?pos:PosInfos):Dynamic
	{
		var className:String = Type.getClassName(clazz);
		return getWithClassName(className, this, pos);
	}
	/* 計算省力化のため、既に文字列になっているキーから取得 */
	private function getWithClassName(className:String, startDiffuser:Diffuser, pos:PosInfos) : Dynamic
	{
		var answer:Dynamic = instanceClassDictionary.get(className);
		if (answer == null) {
			// 対象インスタンスが、辞書になく、これ以上親もない場合はエラー
			if (parent == null) throw new SipoError('指定されたクラス${className}は${startDiffuser.holder}のDiffuserに登録されていません。;取得可能なリスト=${getDictionaryCondition(startDiffuser)} ;pos=$pos');
			// 親がある場合は親に問い合わせ
			answer = parent.getWithClassName(className, startDiffuser, pos);
		}
		return answer;
	}
	
	/**
	 * Diffuseインスタンスをキー持ちで取得する
	 */
	public function getWithKey(enumKey:EnumValue, pos:PosInfos):Dynamic
	{
		return getWithKey_(enumKey, this, pos);
	}
	private function getWithKey_(enumKey:EnumValue, startDiffuser:Diffuser, pos:PosInfos):Dynamic
	{
		var targetDictionary = getTargetEnumDictionary(enumKey);
		var answer:Dynamic = targetDictionary.get(enumKey);
		if (answer == null) {
			// 対象インスタンスが、辞書になく、これ以上親もない場合はエラー
			if (parent == null)
			{
				var dictionaryCondition:String = getDictionaryCondition(startDiffuser);
				throw new SipoError('指定されたキー${enumKey}は${startDiffuser.holder}のDiffuserに登録されていません。;取得可能なリスト=${dictionaryCondition} ;pos=$pos');
			}
			// 親がある場合は親に問い合わせ
			answer = parent.getWithKey_(enumKey, startDiffuser, pos);
		}
		return answer;
	}
	private function getTargetEnumDictionary(enumKey:EnumValue):Map<EnumValue, Dynamic>
	{
		var enumName = Type.getEnumName(Type.getEnum(enumKey));
		if (instanceEnumDictionary.exists(enumName))
		{
			return instanceEnumDictionary.get(enumName);
		}
		else
		{
			return instanceEnumDictionary[enumName] = new Map();
		}
	}
	
	/**
	 * 消去処理。親との関連を切り離す
	 */
	public function dispose():Void
	{
		for (key in instanceClassDictionary.keys()) {
			instanceClassDictionary.remove(key);
		}
		for (key in instanceEnumDictionary.keys()) {
			instanceEnumDictionary.remove(key);
		}
		parent = null;
	}
	
	
	/**
	 * 文字列表現
	 */
	public function toString():String
	{
		return '[Diffuser holder=$holder]';
	}
	
	/**
	 * エラー表示のために現在のDiffuserに登録されているリストを返す
	 */
	public function getDictionaryCondition(startDiffuser:Diffuser):String
	{
		var listString:String = "";
		var targetDiffuser:Diffuser = startDiffuser;
		while(true)
		{
			listString += getMapCondition(targetDiffuser.instanceClassDictionary);
			listString += getMapCondition(targetDiffuser.instanceEnumDictionary);
			if (targetDiffuser.parent == null) return listString;
			targetDiffuser = targetDiffuser.parent;
		}
	}
	inline private function getMapCondition(target:IMap<Dynamic, Dynamic>):String
	{
		var listString:String = "";
		for (key in target.keys())
		{
			var value:Dynamic = target.get(key);
			listString += 'key:${key} =>value:${value}, ';
		}
		return listString;
	}
	
}
