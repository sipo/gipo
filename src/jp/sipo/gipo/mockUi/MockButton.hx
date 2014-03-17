package jp.sipo.gipo.mockUi;
/**
 * 仮のボタンを追加する
 * 
 * @auther sipo
 */
import flash.text.TextField;
import flash.display.Sprite;
import flash.display.DisplayObjectContainer;
class MockButton extends MockUiChild
{
	/* 表示ラベル */
	private var message:String;
	/* 背景表示 */
	private var bg:Sprite;
	/* 文字表示 */
	private var tf:TextField;
	
	/** コンストラクタ */
	public function new(message:String) 
	{
		super();
		this.message = message;
		gear.addRunHandler(run);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		bg = new Sprite();
		view.addChild(bg);
		gear.disposeTask(function (){
			view.removeChild(bg);
		});
		tf = new TextField();
		view.addChild(tf);
		gear.disposeTask(function (){
			view.removeChild(tf);
		});
	}
}
