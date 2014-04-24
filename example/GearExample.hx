package ;
/**
 * Gearそのもののサンプルケース
 * 
 * ・階層構造を作るサンプル
 * ・消去処理を行なうサンプル
 * ・重要クラスをDiffuseするサンプル
 * 
 * 用語解説
 * ・Gear
 * 　Gipoライブラリの基本機能を持つインスタンス。階層構造を生成する。
 * 　正確にはGearを持つGearHolderが階層構造を生成し、Gearはその手助けをするイメージになる
 * ・diffuse
 * 　特定のインスタンスを階層構造の下位全てから取得することが出来るようにする
 * 　その階層構造が消去されると自動的に消去されるため、安全に末端のインスタンスまで引き渡しができる
 * ・absorb
 * 　diffuseしたインスタンスを下位レイヤーで取得すること。
 * 
 * @auther sipo
 */
import jp.sipo.gipo.core.GearHolderImpl;
import haxe.Timer;
import GearExample.ChildExample;
import jp.sipo.gipo.core.GearDiffuseTool;
class GearExample
{
	/* メインインスタンス */
	private static var _main:GearExample;
	/**
	 * 起動関数
	 */
	public static function main():Void
	{
		_main = new GearExample();
	}
	
	/* 最上位のGear */
	private var top:Top;
	
	/** コンストラクタ */
	public function new() 
	{
		top = new Top();
		// 一番上は最初に、initializeTopを呼び出すことで動き出す。
		// 引数は基本的にはnull
		top.gearOutside().initializeTop(null);
	}
}
/**
 * ギア構造の一番上を担当する。（内部構造は通常のGearHolderと変わらない）
 * GearHolderを継承する必要があるが、GearHolderImplに実装済みクラスが用意されているので、extendsが使える場合はこれを使える
 * 
 * @auther sipo
 */
class Top extends GearHolderImpl
{
	/* システム全体で使う重要なインスタンス（という想定） */
	private var importInstance:ImportantClass;
	/* 階層構造の子の例 */
	private var child:ChildExample;
	
	/**
	 * コンストラクタ
	 * コンストラクタでは引数の受付と、各種ハンドラ関数を登録する役割になる。初期化処理をなるべくしない。
	 */
	public function new() 
	{
		super();
		// 各種ハンドラ関数を登録する
		gear.addDiffusibleHandler(diffusible);
		gear.addRunHandler(run);
	}
	
	/*
	 * 初期化処理
	 * 
	 * 初期化処理内では、diffuseが使用可能になる。
	 * 必ず初期化タイミングで使用し、以後は使用不可能。
	 * diffuseする対象はGearHolderであってもなくても構わない
	 * 対象のクラスをキーにして登録する。同一クラスが複数必要な場合、diffuseWithKeyを使う
	 * 
	 * このメソッド内で、gear.addChildは使用できないが、代わりにtool.bookChildが使用可能である。
	 * これは、このメソッドが終了した後に、登録した対象を自動的にgear.addChildしてくれる機能である。
	 * 
	 * 各種インスタンスは基本的に、初期化→（必要なら）diffuse→（必要なら）addChild→消去処理と登録する。
	 * 消去処理を関数登録するのは、消去処理忘れを防ぎ、メモリーリークを起こさないようにするためである。
	 * 消去処理はGearHolderが階層構造から外れる際に自動的に、登録の逆順で呼び出される。
	 * 
	 */
	private function diffusible(tool:GearDiffuseTool):Void
	{
		trace("TopGearの初期化処理");
		// 重要クラスの定義
		importInstance = new ImportantClass();	// 作成する
		tool.diffuse(importInstance, ImportantClass);	// diffuse（下位Gearで自由に取得できるようになる）する
		gear.disposeTask(function (){	// 消去処理を登録する
			importInstance.dispose();
			importInstance = null;
		});
		// 子クラスの定義
		child = new ChildExample();
		tool.bookChild(child);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		trace("TopGearの処理が開始");
		// ここでgear.addChildすることも出来る。順番などを厳密にしたい場合はこちらで。
		// ただし、diffuseと同時に処理する場合や、初期化処理をまとめたい場合initialize関数でtool.bookChildを使用すること。
		// 同じインスタンスへの処理をなるべく近くに書き、抜けをなくすのがGipoの設計思想の１つなので。
		
		// 消去処理をタイマーで登録する（これはテストのため）
		Timer.delay(delay, 5000);
	}
	
	/* 時間差で消去処理をする */
	private function delay():Void
	{
		trace("TopGearの消去");
		gear.disposeTop();	// 最上位Gearとして消去する
		// どこかのGearHolderがremoveChildされるか、最上位のdisposeTopが呼び出されると
		// それ以下の階層構造の全てのGearが切り離されることになり、全ての消去処理が実行される。
	}
}
/**
 * 重要なデータを想定したクラス
 * このようなクラスのインスタンスを、staticを使用せずに、限定範囲から取得可能にすることで、staticの問題や引数のバケツリレーを回避する
 * 
 * @auther sipo
 */
class ImportantClass
{
	/** コンストラクタ */
	public function new() {  }
	
	/** 消去処理 */
	public function dispose() {  }
}

/**
 * 子の例
 * 
 * @auther sipo
 */
class ChildExample extends GearHolderImpl
{
	/* システム全体で使う重要なインスタンス（という想定） */
	@:absorb
	private var importInstance:ImportantClass;
	
	/**
	 * コンストラクタ
	 * コンストラクタでは引数の受付と、各種ハンドラ関数を登録する役割になる。初期化処理をなるべくしない。
	 */
	public function new() 
	{
		super();
		// 各種ハンドラ関数を登録する
		gear.addDiffusibleHandler(diffusible);
		gear.addRunHandler(run);
		// 消去処理を追加
		gear.disposeTask(function () trace("ChildExampleの消去処理"));
	}
	
	/*
	 * 初期化処理
	 * 
	 * absorb（diffuseしたインスタンスの取得）は、initialize関数、run関数のどちらでも取得可能
	 */
	private function diffusible(tool:GearDiffuseTool):Void
	{
		trace("ChildExampleの初期化処理");
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// 色々処理を登録する
		trace("ChildExampleの処理が開始");
		// 重要クラスを取得
//		importInstance = gear.absorb(ImportantClass);	// @:absorbメタデータを使用せずに取得する場合はこのようにする
		trace('importInstance = $importInstance');	// 対象のクラスをキーにして取得する。
	}
}
