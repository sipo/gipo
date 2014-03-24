package frameworkExample.logic;
/**
 * Logicの１遷移ごとの基本クラス
 * 
 * @auther sipo
 */
import jp.sipo.gipo.util.EnumKeyHandlerContainer;
import frameworkExample.core.View;
import jp.sipo.gipo.core.state.StateGearHolderImpl;
class LogicScene extends StateGearHolderImpl
{
	/* シーンごとのviewInputの受け取り処理 */
	private var viewInputHandlerContainer:EnumKeyHandlerContainer = new EnumKeyHandlerContainer();
	/* 共通インスタンス */
	private var view:View;
	private var logic:Logic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(sceneRun);
	}
	
	/* 初期動作 */
	inline private function sceneRun():Void
	{
		view = gear.absorb(View);
		logic = gear.absorb(Logic);
	}
	
	/**
	 * 更新処理
	 */
	public function update():Void
	{
		// template
		// TODO:templateを全て登録型に書き換えるか検討する。頻出なのでgearのライブラリ化出来るかも（gearの内部の登録系も）
	}
	
	/**
	 * Viewからの入力
	 */
	inline public function sceneViewInput(command:EnumValue):Void
	{
		viewInputHandlerContainer.call(command);
	}
}
