package jp.sipo.wrapper;
/**
 * MinimalCompsをGearとして取り込むためのラッパー
 * 関数などの型をつけたり、削除処理に対応したり、配置を自動化したりする
 * 
 * @auther sipo
 */
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
	private var layer:Sprite;
	/* 設定 */
	private var config:Config;
	/* 表示 */
	private var view:Sprite;
	/* 表示エリア。Noneで未定 */
	private var size:Option<Size> = Option.None;
	
	/* 次配置位置 */
	private var putX:Int = 0;
	private var putY:Int = 0;
	
	/** コンストラクタ */
	public function new(layer:Sprite, ?config:Config) 
	{
		super();
		this.layer = layer;
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
		view = new Sprite();
		layer.addChild(view);
		gear.disposeTask(function (){
			layer.removeChild(view);
		});
	}
	
	/* サイズがあれば返し、無ければステージから取得 */
	private function getSize():Size
	{
		switch(size)
		{
			case Option.Some(value) : return value;
			case Option.None : 
			{
				var sizeValue:Size = {width:layer.stage.stageWidth, height:layer.stage.stageWidth};
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
		var label:Label = new Label(layer, putX, putY, message);
		gear.disposeTask(function (){
			layer.removeChild(label);
		});
		addComponent(label);
		return label;
	}
	
	/**
	 * pushButtonを追加
	 */
	public function addPushButton(label:String, clickHandler:Void -> Void):Void
	{
		var handler = function (event:Event):Void{
			clickHandler();
		}
		var pushButton:PushButton = new PushButton(layer, putX, putY, label, handler);
		gear.disposeTask(function (){
			pushButton.removeEventListener(MouseEvent.CLICK, handler);
			layer.removeChild(pushButton);
		});
		addComponent(pushButton);
	}
	
	/* 要素追加の共通処理 */
	private function addComponent(component:Component):Void
	{
		switch (config.alignH){
			case AlignH.Right : 
			{
				component.x = putX - component.width;
			}
			case AlignH.Left:
		}
		putY += Math.round(component.height + config.childMargin);
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
