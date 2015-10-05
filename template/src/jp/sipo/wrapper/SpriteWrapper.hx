package jp.sipo.wrapper;
/**
 * Sprite内部への参照を肩代わりする。
 * 下層へのアクセスをドットシンタックスで提供
 * 
 * @auther sipo
 */
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import String;
import flash.display.MovieClip;
import flash.display.Sprite;
class SpriteWrapper
{
	/* 対象 */
	private var sprite:Sprite;
	
	/** コンストラクタ */
	public function new(sprite:Sprite) 
	{
		this.sprite = sprite;
	}
	
	/**
	 * 子を取得
	 */
	public function childSprite(path:String):Sprite
	{
		return cast(getChild(path), Sprite);
	}
	public function childMc(path:String):MovieClip
	{
		return cast(getChild(path), MovieClip);
	}
	private function getChild(path:String):DisplayObject
	{
		var pathArray:Array<String> = path.split(".");
		var currentDisplay:DisplayObject = sprite;
		var currentContainer:DisplayObjectContainer = null;
		for (i in 0...pathArray.length)
		{
			// 下位があるということは、対象がContainerと判断してキャスト
			currentContainer = cast(currentDisplay, DisplayObjectContainer);
			// 取り出し
			currentDisplay = currentContainer.getChildByName(pathArray[i]);
		}
		return currentDisplay;
	}
}
