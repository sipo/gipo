package jp.sipo.gipo.mockUi;
/**
 * 
 * @auther sipo
 */
import jp.sipo.gipo.mockUi.MockUiChild.ChildConfig;
import jp.sipo.gipo.mockUi.MockUiContainer.ContainerConfig;
import flash.display.DisplayObjectContainer;
import jp.sipo.gipo.core.GearHolderImpl;
class MockUiContainer extends GearHolderImpl
{
	/* ================================================================
	 * 全体レベルの基本設定
	 * ===============================================================*/
	
	/* 基本設定の保持 */
	private static var _defaultConfig:ContainerConfig = null;
	/* 全体高さの初期値 */
	private static inline var DEFAULT_HEIGTH:Int = 400;
	
	/**
	 * 初期設定をする
	 */
	public static function setDefaultConfig(defaultConfig:ContainerConfig):Void
	{
		_defaultConfig = defaultConfig;
	}
	
	/**
	 * 初期設定を取得する
	 */
	public static function getDefaultConfig():ContainerConfig
	{
		// 無ければ生成
		if (_defaultConfig == null) _defaultConfig = new ContainerConfig(DEFAULT_HEIGTH);
		return _defaultConfig;
	}
	
	/* ================================================================
	 * メイン処理
	 * ===============================================================*/
	
	/* 表示レイヤー */
	private var layer:DisplayObjectContainer;
	/* 子のリスト */
	private var childlen:Array<MockUiChild>;
	/* 基本設定 */
	private var config:ContainerConfig;
	
	/** コンストラクタ */
	public function new(layer:DisplayObjectContainer, ?config:ContainerConfig = null) 
	{
		super();
		// 
		this.layer = layer;
		if (config == null) config = getDefaultConfig();
		this.config = config;
		// 子を保持するリスト
		childlen = new Array<MockUiChild>();
	}
	
	/**
	 * 子の追加
	 */
	public function addChild(child:MockUiChild):Void
	{
		childlen.push(child);
		gear.addChild(child);
		layer.addChild(child.getView());
		gear.otherEntryDispose(child, function (){
			layer.removeChild(child.getView());
		});
	}
}
/**
 * コンテナレベルの設定
 */
class ContainerConfig
{
	/** 最大高さ */
	public var maxHeight:Int;
	/** 最大高さ */
	public var childConfig:ChildConfig;
	
	/** コンストラクタ */
	public function new(maxHeight:Int) 
	{
		this.maxHeight = maxHeight;
		// 子の設定
		// MEMO:子の設定でコンストラクタで欲しいものがある場合は、childConfigを受け取らず、直接設定をもらう
		this.childConfig = new ChildConfig();
	}
}
