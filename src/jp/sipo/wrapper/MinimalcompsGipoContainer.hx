package jp.sipo.wrapper;
/**
 * MinimalCompsをGearとして取り込むためのラッパー
 * 関数などの型をつけたり、削除処理に対応したり、配置を自動化したりする
 * 
 * @auther sipo
 */
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
	
	/* 配置位置 */
	private var putX:Int = 0;
	private var putY:Int = 0;
	
	/** コンストラクタ */
	public function new(layer:Sprite, ?config:Config) 
	{
		super();
		this.layer = layer;
		if (config == null) config = getDefaultConfig();
		this.config = config;
		gear.addRunHandler(run);
		Style.embedFonts = false;
		Style.fontSize = 13;
	}
	
	
	/* 初期化後処理 */
	private function run():Void
	{
		view = new Sprite();
		layer.addChild(view);
		gear.disposeTask(function (){
			layer.removeChild(view);
		});
		
		putX = config.padding;
		putY = config.padding;
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
		putY += Math.round(component.height + config.childMargin);
	}
}
class Config
{
	public var padding:Int = 10;
	public var childMargin:Int = 5;
	
	/** コンストラクタ */
	public function new() { }
}
