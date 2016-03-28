package jp.sipo.gipo_framework_example.operation;
/**
 * Logicの操作などを担当し、記録などを処理する。
 * これ自体の動作は記録されない
 * 
 * @auther sipo
 */
import flash.events.Event;
import flash.net.FileReference;
import flash.utils.ByteArray;
import haxe.Serializer;
import haxe.Unserializer;
import haxe.ds.Option;
import jp.sipo.gipo.core.GearHolderImpl;
import jp.sipo.gipo.reproduce.LogWrapper.RecordLog;
import jp.sipo.gipo.reproduce.LogWrapper.ReplayLog;
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo_framework_example.context.Logic;
import jp.sipo.gipo_framework_example.context.Top;
import jp.sipo.gipo_framework_example.context.reproduce.SnapshotKind;
import jp.sipo.gipo_framework_example.context.reproduce.UpdateKind;
import jp.sipo.gipo_framework_example.operation.OperationView;
import jp.sipo.util.HandlerUtil;

class OperationLogic extends GearHolderImpl
{
	@:absorb
	private var operationView:OperationView;
	@:absorbWithKey(jp.sipo.gipo_framework_example.context.Top.TopDiffuseKey.ReproduceKey)
	private var reproduce:Reproduce<UpdateKind>;
	@:absorb
	private var logic:Logic;
	
	/* 最後に読み込んだログ */
	private var loadFile:Option<RecordLog<UpdateKind>> = Option.None;
	
	/** コンストラクタ */
	public function new() 
	{
		super();
	}
	
	/* ================================================================
	 * OperationView
	 * ===============================================================*/
	 
	/**
	 * OperationViewからのイベント処理
	 */
	public function noticeOperationViewEvent(event:OperationViewEvent):Void
	{
		switch (event)
		{
			case OperationViewEvent.LocalSave : localSave();
			case OperationViewEvent.LocalLoad :  localLoad();
			case OperationViewEvent.StartReplay(logIndex) :  startReplay(logIndex);
			case OperationViewEvent.Restart: restart();
		}
	}
	
	/* ローカルデータに保存 */
	private function localSave():Void
	{
		var fileReference:FileReference = new FileReference();
		var recordLog:RecordLog<UpdateKind> = reproduce.getRecordLog();
		var dataString:String = Serializer.run(recordLog);
		var date:Date = Date.now();
		var milliSecond:String = StringTools.lpad(Std.string((date.getTime() % 1000)),"0",3);
		var dateString:String = DateTools.format(date, "%Y_%m_%d_%H_%M_%S_") + milliSecond;
		fileReference.save(dataString, 'log_${dateString}.txt');
	}
	
	/* ローカルデータから呼び出し */
	private function localLoad():Void
	{
		var fileReference:FileReference = new FileReference();
		HandlerUtil.once(fileReference, Event.SELECT, function (event:Event){
			fileReference.load();
		});
		HandlerUtil.once(fileReference, Event.COMPLETE, function (event:Event){
			afterLoadFile(fileReference.data);
		});
		fileReference.browse();
	}
	
	/* ファイルデータ取得後 */
	private function afterLoadFile(fileData:ByteArray):Void
	{
		// バイナリを文字列に変換
		fileData.position = 0;
		var dataString:String = fileData.readUTFBytes(fileData.length);
		// データを解析
		var reproduceFile:RecordLog<UpdateKind> = Unserializer.run(dataString);
		var replayLog:ReplayLog<UpdateKind> = reproduceFile.convertReplay();
		// バイナリデータは消しておく
		fileData.clear();
		// メンバ変数に保持
		loadFile = Option.Some(reproduceFile);
		// コンボボックスに入れるために、snapshotだけを取り出す
		operationView.displayFile(replayLog.createDisplaySnapshotList());
	}
	
	/* リプレイの開始命令 */
	private function startReplay(logIndex:Int):Void
	{
		var reproduceFile:RecordLog<UpdateKind> = switch(loadFile)
		{
			case Option.None : throw '開始するデータがロードされていません';
			case Option.Some(v) : v;
		}
		// リプレイを開始
		reproduce.startReplay(reproduceFile.convertReplay(), logIndex); 
	}
	
	/* リプレイ情報を消去して、初めから */
	private function restart():Void
	{
		// 保存している内容を消去
		reproduce.clear(); 
		
		// hookに初期化用のsnapshotを渡す
		logic.start();
	}
	
	/* ================================================================
	 * Reproduce
	 * ===============================================================*/
	
	/**
	 * Reproduceからのイベント処理
	 */
	public function noticeReproduceEvent(event:ReproduceEvent):Void
	{
		switch (event)
		{
			case ReproduceEvent.LogUpdate : logUpdate();
		}
	}
	
	/* ログの更新への反応 */
	private function logUpdate():Void
	{
		var reproduceLog:RecordLog<Dynamic> = reproduce.getRecordLog();
		operationView.updateLog(reproduceLog.getLength());
	}
	
}
