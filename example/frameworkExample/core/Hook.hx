package frameworkExample.core;
/**
 * 各セクションからのイベントをロジックに伝える
 * MVCで言うところのC
 * データの保存と再現も担当する（予定）
 * 
 * Hookイベントの種類
 * 	Input
 * 		ユーザー入力等、基本的なイベント
 * 		入力情報は、再現データから瞬時に復元できるものである必要がある（外部ファイルとかを読む必要が無い）
 * 	Ready
 * 		データの読み込みなど、非同期であったり、終了時間が読めないイベント
 * 		GPUへの非同期な準備や、必要データの非同期な展開などもこれに含む。
 * 		再現時には、Logicのほうがセクションに合わせて停止する必要がある。
 * 		
 * 	※イベントの発生がセクションに依存し、かつそれがフレーム進行を必要とするものは、対応できない。
 * 	　例えば、表示演出などは、仮にその演出が途中で、ボタンが画面に無くともボタンの入力イベントに対応しなければいけない。
 * 	　
 * 
 * @auther sipo
 */
import frameworkExample.logic.Logic;
import jp.sipo.gipo.core.GearHolder;
import jp.sipo.gipo.core.GearDiffuseTool;
import jp.sipo.gipo.core.GearHolderImpl;
interface Hook extends GearHolder
{

	/**
	 * Viewからの入力
	 */
	public function viewInput(command:ViewLogicInput):Void;
	
	/**
	 * Viewからの準備完了通知
	 */
	public function viewReady(command:ViewLogicReady):Void;
}
class HookBasic extends GearHolderImpl implements Hook
{
	/* absorb */
	private var logic:Logic;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
		gear.addRunHandler(run);
	}
	
	/* 初期化後処理 */
	private function run():Void
	{
		// インスタンスの取得
		logic = gear.absorb(Logic);
	}

	/**
	 * Viewからの入力
	 */
	public function viewInput(command:ViewLogicInput):Void
	{
		logic.viewInput(command);
	}
	
	/**
	 * Viewからの準備完了通知
	 */
	public function viewReady(command:ViewLogicReady):Void
	{
		logic.viewReady(command);
	}
}
// MEMO:再生時の挙動
//	イベント予定のフレームが発生（同一フレームに複数ある場合は順序を守る）
//		if (Input){
//			データを再現してLogicに通知
//		else if (Ready){
//			if (待機リストにある) Logicに通知
// 			else Logicを停止
// 		}
//	イベントが発生
//		if (Input){
//			自動再現のはずなので無視
//		}else if (Ready){
//			if (既に発生フレーム) Logicに通知
//			else 待機リストへ
//		}
