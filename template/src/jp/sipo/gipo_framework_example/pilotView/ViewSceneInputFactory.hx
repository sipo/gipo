package jp.sipo.gipo_framework_example.pilotView;
/**
 * ViewInputを生成する。
 * 実質の役割はhookをViewSceneから隠蔽し、直接inputを呼ぶミスを無くす。
 */
import jp.sipo.gipo_framework_example.context.Hook.HookForView;
import jp.sipo.gipo.core.GearHolderImpl;
class ViewSceneInputFactory extends GearHolderImpl
{
	/* hookを保持する */
	private var hook:HookForView;
	
	/**
	 * コンストラクタ
	 */
	public function new(hook:HookForView)
	{
		super();
		this.hook = hook;
	}
	
	/**
	 * input用インスタンスを返す
	 */
	public function createInput():ViewSceneInput
	{
		return new ViewSceneInput(hook);
	}
}
