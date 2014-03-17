package jp.sipo.gipo.mockUi;
/**
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolderImpl;
import flash.display.Sprite;
class MockUiChild extends GearHolderImpl
{
	
	/* 表示 */
	private var view:Sprite;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		view = new Sprite();
	}
	
	/**
	 * 表示を返す
	 */
	public function getView():Sprite
	{
		return view;
	}
}
/**
 * 子用の設定
 */
class ChildConfig
{
	/** 横方向のマージン */
	public var marginX:Int = 10;
	/** 縦方向のマージン */
	public var marginY:Int = 10;
	
	/** コンストラクタ */
	public function new() 
	{
		
	}
}
