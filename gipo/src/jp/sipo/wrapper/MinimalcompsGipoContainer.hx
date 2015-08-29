package jp.sipo.wrapper;
/**
 * MinimalCompsをGearとして取り込むためのラッパー
 * 関数などの型をつけたり、削除処理に対応したり、配置を自動化したりする
 * 
 * @auther sipo
 */
import com.bit101.components.ComboBox;
import flash.geom.Rectangle;
import haxe.macro.Expr.Case;
import haxe.Unserializer;
import haxe.Serializer;
import haxe.ds.Option;
import com.bit101.components.Component;
import com.bit101.components.Label;
import com.bit101.components.Style;
import flash.events.MouseEvent;
import flash.ui.Mouse;
import flash.events.Event;
import com.bit101.components.PushButton;
import jp.sipo.gipo.core.GearHolderImpl;
import flash.display.Sprite;
import jp.sipo.gipo.core.Gear;
class MinimalcompsGipoContainer extends GearHolderImpl
{
	/* デフォルト設定 */
	private static var defaultConfig:Config;
	
	/**
	 * 初期設定
	 */
	public static function setDefaultConfig(config:Config):Void
	{
		defaultConfig = config;
	}
	
	/**
	 * 初期設定を得る
	 */
	public static function getDefaultConfig():Config
	{
		if (defaultConfig == null){
			defaultConfig = new Config();
		}
		return defaultConfig;
	}
	
	/* 表示レイヤー */
	private var parentLayer:Sprite;
	/* 設定 */
	private var config:Config;
	/* UI表示 */
	private var uiLayer:Sprite;
	/* 背景表示 */
	private var backgroundLayer:Sprite;
	/* 表示エリア。Noneで未定 */
	private var size:Option<Size> = Option.None;
	
	/* 次配置位置 */
	private var putX:Int = 0;
	private var putY:Int = 0;
	
	/** コンストラクタ */
	public function new(parentLayer:Sprite, ?config:Config) 
	{
		super();
		this.parentLayer = parentLayer;
		if (config == null) config = getDefaultConfig();
		this.config = config;
		Style.embedFonts = false;
		Style.fontSize = 13;
		// 初期配置
		switch(config.alignH)
		{
			case AlignH.Left :
			{
				putX = config.padding;
			}
			case AlignH.Right : 
			{
				var sizeValue:Size = getSize();
				putX = sizeValue.width - config.padding;
			}
		}
		putY = config.padding;
		
		// spriteの配置
		backgroundLayer = new Sprite();
		parentLayer.addChild(backgroundLayer);
		gear.disposeTask(function () parentLayer.removeChild(backgroundLayer));
		uiLayer = new Sprite();
		parentLayer.addChild(uiLayer);
		gear.disposeTask(function () parentLayer.removeChild(uiLayer));
		
	}
	
	/* サイズがあれば返し、無ければステージから取得 */
	private function getSize():Size
	{
		switch(size)
		{
			case Option.Some(value) : return value;
			case Option.None : 
			{
				var sizeValue:Size = {width:parentLayer.stage.stageWidth, height:parentLayer.stage.stageWidth};
				size = Option.Some(sizeValue);
				return sizeValue;
			}
		}
	}
	
	
	/**
	 * ラベルを追加
	 */
	public function addLabel(message:String):Label
	{
		var label:Label = new Label(uiLayer, putX, putY, message);
		gear.disposeTask(function (){
			uiLayer.removeChild(label);
		});
		addComponent(label);
		return label;
	}
	
	/**
	 * pushButtonを追加
	 */
	public function addPushButton(label:String, clickHandler:Void -> Void):PushButton
	{
		var handler = function (event:Event):Void{
			clickHandler();
		}
		var pushButton:PushButton = new PushButton(uiLayer, putX, putY, label, handler);
		gear.disposeTask(function (){
			pushButton.removeEventListener(MouseEvent.CLICK, handler);
			uiLayer.removeChild(pushButton);
		});
		addComponent(pushButton);
		return pushButton;
	}
	
	/**
	 * プルダウンメニューを追加
	 */
	public function addComboBox(labelList:Array<String>, selectHandler:Int -> Void):ComboBox
	{
		var comboBox:ComboBox = new ComboBox(uiLayer, putX, putY, if (labelList.length == 0) null else labelList[0], labelList);
		var handler = function (event:Event):Void
		{
			selectHandler(comboBox.selectedIndex);
		}
		comboBox.addEventListener(Event.SELECT, handler);
		gear.disposeTask(function (){
			comboBox.removeEventListener(MouseEvent.CLICK, handler);
			uiLayer.removeChild(comboBox);
		});
		addComponent(comboBox);
		return comboBox;
	}
	
	/* 要素追加の共通処理 */
	private function addComponent(component:Component):Void
	{
		// サイズ反映
		component.scaleX = component.scaleY = config.scale;
		// 右寄せ左寄せ
		switch (config.alignH){
			case AlignH.Right : 
			{
				component.x = putX - component.width * component.scaleX;
			}
			case AlignH.Left:
		}
		// 上の要素の次に並べる
		putY += Math.round(component.height * component.scaleY + config.childMargin);
	}
	
	/**
	 * 背景の追加
	 */
	public function addBackground(color:Int, alpha:Float):Void
	{
		var bounds:Rectangle = uiLayer.getBounds(backgroundLayer);
		backgroundLayer.graphics.clear();
		backgroundLayer.graphics.beginFill(color, alpha);
		var padding:Float = config.padding;
		backgroundLayer.graphics.drawRect(bounds.x - padding, bounds.y - padding, bounds.width + padding*2, bounds.height + padding*2);
	}
}
class Config
{
	public var padding:Int = 10;
	public var childMargin:Int = 5;
	/** 表示エリア。Noneで未定 */
	public var size:Option<{width:Int, height:Int}> = Option.None;
	/** 左右文字寄せ */
	public var alignH:AlignH = AlignH.Left;
	/** サイズ比 */
	public var scale:Float = 1.0;
	
	/** コンストラクタ */
	public function new() { }
	
	/** クローン */
	public function clone():Config
	{
		return Unserializer.run(Serializer.run(this));
	}
}
enum AlignH
{
	Left;
	Right;
}
private typedef Size =
{
	var width:Int;
	var height:Int;
}
