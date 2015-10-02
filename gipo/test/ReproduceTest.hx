package;

import haxe.Serializer;
import haxe.Unserializer;
import Type.ValueType;
import jp.sipo.gipo.reproduce.Snapshot;
import haxe.ds.Option;
import haxe.PosInfos;
import jp.sipo.gipo.reproduce.LogPart;
import jp.sipo.gipo.reproduce.LogPart.LogwayKind;
import jp.sipo.gipo.reproduce.LogPart.ReproducePhase;
import jp.sipo.gipo.reproduce.LogWrapper;
import jp.sipo.gipo.reproduce.Reproduce;
import jp.sipo.gipo.core.Gear.GearDispatcherKind;
import jp.sipo.gipo.core.GearPreparationTool;
import jp.sipo.gipo.core.GearHolderImpl;
import massive.munit.Assert;

using Lambda;

@:access(jp.sipo.gipo.reproduce.Reproduce)
@:access(jp.sipo.gipo.reproduce.LogWrapper)
@:access(jp.sipo.gipo.reproduce.ReplayLog)
@:access(jp.sipo.gipo.reproduce.LogPart)
class ReproduceTest
{
    var topGear:ReproduceTop;
    var reproduce:Reproduce<ReproduceUpdateKind>;
    var hook:ReproduceHook;
    var operationHook:ReproduceOperationHook;

	public function new()
	{
	}

	static var timeCode:Int;
	public static function currentTimeCode():Int
	{
		return timeCode++;
	}

	@Before
	public function setup():Void
	{
		timeCode = 0;

        // build gear tree
        topGear = new ReproduceTop();
        topGear.gearOutside().initializeTop(null);

        reproduce = topGear.reproduce;
        hook = topGear.hook;
        operationHook = topGear.operationHook;
	}
	
	@After
	public function tearDown():Void
	{
	}

	/*
	 * initial state
	 */
	@Test
	public function testReproduce_initialState():Void
	{
        // get record log
        var log = reproduce.getRecordLog();

		// verify
        Assert.areEqual(0, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
	}

    /*
	 * start first out-frame phase
	 */
    @Test
    public function testStartOutFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(0, reproduce.frame);
        Assert.areEqual(Option.Some(ReproducePhase.OutFrame), reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
    }

    /*
	 * end first out-frame phase
	 */
    @Test
    public function testEndOutFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(0, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
    }

    /*
	 * first update
	 */
    @Test
    public function testUpdate():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();
        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(1, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
    }

    /*
	 * start first in-frame phase
	 */
    @Test
    public function testStartInFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();
        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(1, reproduce.frame);
        Assert.areEqual(Option.Some(ReproducePhase.InFrame(ReproduceUpdateKind.Input1)), reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
    }

    /*
	 * end first in-frame phase
	 */
    @Test
    public function testEndInFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();
        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(1, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
    }

    /*
	 * 2-frames with no record log
	 */
    @Test
    public function test2frames():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(0, log.getLength());
    }

    /*
	 * instant input in out-frame
	 */
    @Test
    public function testInstantInput_outFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(1, log.getLength());

        // verify: record log
        var logPart = log.list[0];
        var expectFrame = 1;
        var expectPhase = ReproducePhase.OutFrame;
        var expectLogway = LogwayKind.Instant(ReproduceInput.Event1);
        Assert.areEqual(expectFrame, logPart.frame);
        Assert.areEqual(expectPhase, logPart.phase);
        Assert.isTrue(logPart.equalPhase(expectPhase));
        Assert.isTrue(logPart.isOutFramePhase());
        Assert.areEqual(expectLogway, logPart.logway);
        Assert.isFalse(logPart.isReadyLogway());
        Assert.isTrue(logPart.isSame(new LogPart<ReproduceUpdateKind>(expectPhase, expectFrame, expectLogway, null)));

        // verify: hook
        Assert.areEqual(1, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);

        // verify: operation hook
        Assert.areEqual(1, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
    }

    /*
	 * instant input in in-frame
	 */
    @Test
    public function testInstantInput_inFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(1, log.getLength());

        var logPart = log.list[0];
        var expectFrame = 2;
        var expectPhase = ReproducePhase.InFrame(ReproduceUpdateKind.Input1);
        var expectLogway = LogwayKind.Instant(ReproduceInput.Event1);
        Assert.areEqual(expectFrame, logPart.frame);
        Assert.areEqual(expectPhase, logPart.phase);
        Assert.isTrue(logPart.equalPhase(expectPhase));
        Assert.isFalse(logPart.isOutFramePhase());
        Assert.areEqual(expectLogway, logPart.logway);
        Assert.isFalse(logPart.isReadyLogway());
        Assert.isTrue(logPart.isSame(new LogPart<ReproduceUpdateKind>(expectPhase, expectFrame, expectLogway, null)));

        // verify: hook
        Assert.areEqual(1, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);

        // verify: operation hook
        Assert.areEqual(1, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
    }

    /*
	 * ready input in out-frame
	 */
    @Test
    public function testReadyInput_outFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(1, log.getLength());

        var logPart = log.list[0];
        var expectFrame = 1;
        var expectPhase = ReproducePhase.OutFrame;
        var expectLogway = LogwayKind.Ready(ReproduceInput.Event1);
        Assert.areEqual(expectFrame, logPart.frame);
        Assert.areEqual(expectPhase, logPart.phase);
        Assert.isTrue(logPart.equalPhase(expectPhase));
        Assert.isTrue(logPart.isOutFramePhase());
        Assert.areEqual(expectLogway, logPart.logway);
        Assert.isTrue(logPart.isReadyLogway());
        Assert.isTrue(logPart.isSame(new LogPart<ReproduceUpdateKind>(expectPhase, expectFrame, expectLogway, null)));

        // verify: hook
        Assert.areEqual(1, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);

        // verify: operation hook
        Assert.areEqual(1, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
    }

    /*
	 * snapshot in out-frame
	 */
    @Test
    public function testSnapshot_outFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event2)), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(1, log.getLength());

        var logPart = log.list[0];
        var expectFrame = 1;
        var expectPhase = ReproducePhase.OutFrame;
        var expectLogway = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event2));
        Assert.areEqual(expectFrame, logPart.frame);
        Assert.areEqual(expectPhase, logPart.phase);
        Assert.isTrue(logPart.equalPhase(expectPhase));
        Assert.isTrue(logPart.isOutFramePhase());
        Assert.isTrue(logwayEquals(expectLogway, logPart.logway));
        Assert.isFalse(logPart.isReadyLogway());

        // verify: hook
        Assert.areEqual(1, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway, hook.events[0].data));

        // verify: operation hook
        Assert.areEqual(1, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
    }

    /*
	 * snapshot in in-frame
	 */
    @Test
    public function testSnapshot_inFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event2)), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(1, log.getLength());

        var logPart = log.list[0];
        var expectFrame = 2;
        var expectPhase = ReproducePhase.InFrame(ReproduceUpdateKind.Input1);
        var expectLogway = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event2));
        Assert.areEqual(expectFrame, logPart.frame);
        Assert.areEqual(expectPhase, logPart.phase);
        Assert.isTrue(logPart.equalPhase(expectPhase));
        Assert.isFalse(logPart.isOutFramePhase());
        Assert.isTrue(logwayEquals(expectLogway, logPart.logway));
        Assert.isFalse(logPart.isReadyLogway());

        // verify: hook
        Assert.areEqual(1, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway, hook.events[0].data));

        // verify: operation hook
        Assert.areEqual(1, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
    }

    /*
	 * multiple log
	 */
    @Test
    public function testRecordMultiple():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event2), null); // record log
        var time3 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3)), null); // record log
        var time4 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update();
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time5 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event4), null); // record log
        var time6 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5)), null); // record log
        var time7 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);
        Assert.isNotNull(log);
        Assert.areEqual(5, log.getLength());

        var expectLogway0 = LogwayKind.Instant(ReproduceInput.Event1);
        var expectLogway1 = LogwayKind.Ready(ReproduceInput.Event2);
        var expectLogway2 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3));
        var expectLogway3 = LogwayKind.Instant(ReproduceInput.Event4);
        var expectLogway4 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5));
        Assert.isTrue(logPartEquals(log.list[0], 1, ReproducePhase.OutFrame, expectLogway0));
        Assert.isTrue(logPartEquals(log.list[1], 1, ReproducePhase.OutFrame, expectLogway1));
        Assert.isTrue(logPartEquals(log.list[2], 1, ReproducePhase.OutFrame, expectLogway2));
        Assert.isTrue(logPartEquals(log.list[3], 2, ReproducePhase.InFrame(ReproduceUpdateKind.Input1), expectLogway3));
        Assert.isTrue(logPartEquals(log.list[4], 2, ReproducePhase.InFrame(ReproduceUpdateKind.Input1), expectLogway4));

        // verify: hook
        Assert.areEqual(5, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway0, hook.events[0].data));
        Assert.isTrue(time2 < hook.events[1].timeCode);
        Assert.isTrue(time3 > hook.events[1].timeCode);
        Assert.isTrue(logwayEquals(expectLogway1, hook.events[1].data));
        Assert.isTrue(time3 < hook.events[2].timeCode);
        Assert.isTrue(time4 > hook.events[2].timeCode);
        Assert.isTrue(logwayEquals(expectLogway2, hook.events[2].data));
        Assert.isTrue(time5 < hook.events[3].timeCode);
        Assert.isTrue(time6 > hook.events[3].timeCode);
        Assert.isTrue(logwayEquals(expectLogway3, hook.events[3].data));
        Assert.isTrue(time6 < hook.events[4].timeCode);
        Assert.isTrue(time7 > hook.events[4].timeCode);
        Assert.isTrue(logwayEquals(expectLogway4, hook.events[4].data));

        // verify: operation hook
        Assert.areEqual(5, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time2 < operationHook.events[1].timeCode);
        Assert.isTrue(time3 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
        Assert.isTrue(time3 < operationHook.events[2].timeCode);
        Assert.isTrue(time4 > operationHook.events[2].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[2].data);
        Assert.isTrue(time5 < operationHook.events[3].timeCode);
        Assert.isTrue(time6 > operationHook.events[3].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[3].data);
        Assert.isTrue(time6 < operationHook.events[4].timeCode);
        Assert.isTrue(time7 > operationHook.events[4].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[4].data);
    }

    /*
	 * replay instant input in out-frame
	 */
    @Test
    public function testReplay_instantInput_outFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Instant(ReproduceInput.Event1);
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.areEqual(expectLogway, hook.events[1].data);

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay instant input in in-frame
	 */
    @Test
    public function testReplay_instantInput_inFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Instant(ReproduceInput.Event1);
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.areEqual(expectLogway, hook.events[1].data);

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay ready input in out-frame, same frame
	 */
    @Test
    public function testReplay_readyInput_sameFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isFalse(reproduce.checkCanProgress());

        reproduce.startOutFramePhase();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // re-ready log
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 1 again with replaying
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // re-ready log
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Ready(ReproduceInput.Event1);
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.areEqual(expectLogway, hook.events[1].data);

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay ready input in out-frame, early frame
	 */
    @Test
    public function testReplay_readyInput_earlyFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 3
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(3, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // re-ready log
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        Assert.areEqual(2, reproduce.frame);
        reproduce.update(); // frame 3
        Assert.areEqual(3, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // verify
        Assert.areEqual(3, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Ready(ReproduceInput.Event1);
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.areEqual(expectLogway, hook.events[1].data);

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay ready input in out-frame, late frame
	 */
    @Test
    public function testReplay_readyInput_lateFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isFalse(reproduce.checkCanProgress());

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 1 again waiting for sync
        Assert.areEqual(1, reproduce.frame);
        Assert.isFalse(reproduce.checkCanProgress());

        reproduce.startOutFramePhase();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event1), null); // re-ready log
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 1 again with replaying
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Ready(ReproduceInput.Event1);
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.areEqual(expectLogway, hook.events[0].data);
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.areEqual(expectLogway, hook.events[1].data);

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay snapshot in out-frame
	 */
    @Test
    public function testReplay_snapshot_outFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event1)), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event1));
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway, hook.events[0].data));
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.isTrue(logwayEquals(expectLogway, hook.events[1].data));

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay snapshot in in-frame
	 */
    @Test
    public function testReplay_snapshot_inFrame():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event1)), null); // record log
        var time2 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time3 = currentTimeCode();
        reproduce.endPhase();
        var time4 = currentTimeCode();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event1));
        Assert.areEqual(2, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway, hook.events[0].data));
        Assert.isTrue(time3 < hook.events[1].timeCode);
        Assert.isTrue(time4 > hook.events[1].timeCode);
        Assert.isTrue(logwayEquals(expectLogway, hook.events[1].data));

        // verify: operation hook
        Assert.areEqual(2, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time3 < operationHook.events[1].timeCode);
        Assert.isTrue(time4 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
    }

    /*
	 * replay multiple log
	 */
    @Test
    public function testReplayMultiple():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event2), null); // record log
        var time3 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3)), null); // record log
        var time4 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time5 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event4), null); // record log
        var time6 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5)), null); // record log
        var time7 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 0);
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isFalse(reproduce.checkCanProgress());

        reproduce.startOutFramePhase();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event2), null); // re-ready log
        reproduce.endPhase();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 1 again with replaying
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time8 = currentTimeCode();
        reproduce.endPhase();
        var time9 = currentTimeCode();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time10 = currentTimeCode();
        reproduce.endPhase();
        var time11 = currentTimeCode();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway0 = LogwayKind.Instant(ReproduceInput.Event1);
        var expectLogway1 = LogwayKind.Ready(ReproduceInput.Event2);
        var expectLogway2 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3));
        var expectLogway3 = LogwayKind.Instant(ReproduceInput.Event4);
        var expectLogway4 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5));
        Assert.areEqual(10, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway0, hook.events[0].data));
        Assert.isTrue(time2 < hook.events[1].timeCode);
        Assert.isTrue(time3 > hook.events[1].timeCode);
        Assert.isTrue(logwayEquals(expectLogway1, hook.events[1].data));
        Assert.isTrue(time3 < hook.events[2].timeCode);
        Assert.isTrue(time4 > hook.events[2].timeCode);
        Assert.isTrue(logwayEquals(expectLogway2, hook.events[2].data));
        Assert.isTrue(time5 < hook.events[3].timeCode);
        Assert.isTrue(time6 > hook.events[3].timeCode);
        Assert.isTrue(logwayEquals(expectLogway3, hook.events[3].data));
        Assert.isTrue(time6 < hook.events[4].timeCode);
        Assert.isTrue(time7 > hook.events[4].timeCode);
        Assert.isTrue(logwayEquals(expectLogway4, hook.events[4].data));
        Assert.isTrue(time8 < hook.events[5].timeCode);
        Assert.isTrue(time9 > hook.events[5].timeCode);
        Assert.isTrue(logwayEquals(expectLogway0, hook.events[5].data));
        Assert.isTrue(time8 < hook.events[6].timeCode);
        Assert.isTrue(time9 > hook.events[6].timeCode);
        Assert.isTrue(logwayEquals(expectLogway1, hook.events[6].data));
        Assert.isTrue(time8 < hook.events[7].timeCode);
        Assert.isTrue(time9 > hook.events[7].timeCode);
        Assert.isTrue(logwayEquals(expectLogway2, hook.events[7].data));
        Assert.isTrue(time10 < hook.events[8].timeCode);
        Assert.isTrue(time11 > hook.events[8].timeCode);
        Assert.isTrue(logwayEquals(expectLogway3, hook.events[8].data));
        Assert.isTrue(time10 < hook.events[9].timeCode);
        Assert.isTrue(time11 > hook.events[9].timeCode);
        Assert.isTrue(logwayEquals(expectLogway4, hook.events[9].data));

        // verify: operation hook
        Assert.areEqual(10, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time2 < operationHook.events[1].timeCode);
        Assert.isTrue(time3 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
        Assert.isTrue(time3 < operationHook.events[2].timeCode);
        Assert.isTrue(time4 > operationHook.events[2].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[2].data);
        Assert.isTrue(time5 < operationHook.events[3].timeCode);
        Assert.isTrue(time6 > operationHook.events[3].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[3].data);
        Assert.isTrue(time6 < operationHook.events[4].timeCode);
        Assert.isTrue(time7 > operationHook.events[4].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[4].data);
        Assert.isTrue(time8 < operationHook.events[5].timeCode);
        Assert.isTrue(time9 > operationHook.events[5].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[5].data);
        Assert.isTrue(time8 < operationHook.events[6].timeCode);
        Assert.isTrue(time9 > operationHook.events[6].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[6].data);
        Assert.isTrue(time8 < operationHook.events[7].timeCode);
        Assert.isTrue(time9 > operationHook.events[7].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[7].data);
        Assert.isTrue(time10 < operationHook.events[8].timeCode);
        Assert.isTrue(time11 > operationHook.events[8].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[8].data);
        Assert.isTrue(time10 < operationHook.events[9].timeCode);
        Assert.isTrue(time11 > operationHook.events[9].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[9].data);
    }

    /*
	 * replay multiple log, start with offset
	 */
    @Test
    public function testReplayMultipleOffset():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event2), null); // record log
        var time3 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3)), null); // record log
        var time4 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time5 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event4), null); // record log
        var time6 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5)), null); // record log
        var time7 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var replayLog = reproduce.getRecordLog().convertReplay();
        Assert.isNotNull(replayLog);

        // replay
        reproduce.startOutFramePhase();
        Assert.areEqual(2, reproduce.frame);
        reproduce.startReplay(replayLog, 2); // start from first snapshot
        Assert.areEqual(0, reproduce.frame);
        reproduce.endPhase();

        Assert.areEqual(0, reproduce.frame);
        reproduce.update(); // frame 1
        Assert.areEqual(1, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time8 = currentTimeCode();
        reproduce.endPhase();
        var time9 = currentTimeCode();

        Assert.areEqual(1, reproduce.frame);
        reproduce.update(); // frame 2
        Assert.areEqual(2, reproduce.frame);
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time10 = currentTimeCode();
        reproduce.endPhase();
        var time11 = currentTimeCode();

        // verify
        Assert.areEqual(2, reproduce.frame);
        Assert.areEqual(Option.None, reproduce.phase);

        // verify: hook
        var expectLogway0 = LogwayKind.Instant(ReproduceInput.Event1);
        var expectLogway1 = LogwayKind.Ready(ReproduceInput.Event2);
        var expectLogway2 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3));
        var expectLogway3 = LogwayKind.Instant(ReproduceInput.Event4);
        var expectLogway4 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5));
        Assert.areEqual(8, hook.events.length);
        Assert.isTrue(time1 < hook.events[0].timeCode);
        Assert.isTrue(time2 > hook.events[0].timeCode);
        Assert.isTrue(logwayEquals(expectLogway0, hook.events[0].data));
        Assert.isTrue(time2 < hook.events[1].timeCode);
        Assert.isTrue(time3 > hook.events[1].timeCode);
        Assert.isTrue(logwayEquals(expectLogway1, hook.events[1].data));
        Assert.isTrue(time3 < hook.events[2].timeCode);
        Assert.isTrue(time4 > hook.events[2].timeCode);
        Assert.isTrue(logwayEquals(expectLogway2, hook.events[2].data));
        Assert.isTrue(time5 < hook.events[3].timeCode);
        Assert.isTrue(time6 > hook.events[3].timeCode);
        Assert.isTrue(logwayEquals(expectLogway3, hook.events[3].data));
        Assert.isTrue(time6 < hook.events[4].timeCode);
        Assert.isTrue(time7 > hook.events[4].timeCode);
        Assert.isTrue(logwayEquals(expectLogway4, hook.events[4].data));
        Assert.isTrue(time8 < hook.events[5].timeCode);
        Assert.isTrue(time9 > hook.events[5].timeCode);
        Assert.isTrue(logwayEquals(expectLogway2, hook.events[5].data));
        Assert.isTrue(time10 < hook.events[6].timeCode);
        Assert.isTrue(time11 > hook.events[6].timeCode);
        Assert.isTrue(logwayEquals(expectLogway3, hook.events[6].data));
        Assert.isTrue(time10 < hook.events[7].timeCode);
        Assert.isTrue(time11 > hook.events[7].timeCode);
        Assert.isTrue(logwayEquals(expectLogway4, hook.events[7].data));

        // verify: operation hook
        Assert.areEqual(8, operationHook.events.length);
        Assert.isTrue(time1 < operationHook.events[0].timeCode);
        Assert.isTrue(time2 > operationHook.events[0].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[0].data);
        Assert.isTrue(time2 < operationHook.events[1].timeCode);
        Assert.isTrue(time3 > operationHook.events[1].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[1].data);
        Assert.isTrue(time3 < operationHook.events[2].timeCode);
        Assert.isTrue(time4 > operationHook.events[2].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[2].data);
        Assert.isTrue(time5 < operationHook.events[3].timeCode);
        Assert.isTrue(time6 > operationHook.events[3].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[3].data);
        Assert.isTrue(time6 < operationHook.events[4].timeCode);
        Assert.isTrue(time7 > operationHook.events[4].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[4].data);
        Assert.isTrue(time8 < operationHook.events[5].timeCode);
        Assert.isTrue(time9 > operationHook.events[5].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[5].data);
        Assert.isTrue(time10 < operationHook.events[6].timeCode);
        Assert.isTrue(time11 > operationHook.events[6].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[6].data);
        Assert.isTrue(time10 < operationHook.events[7].timeCode);
        Assert.isTrue(time11 > operationHook.events[7].timeCode);
        Assert.areEqual(ReproduceEvent.LogUpdate, operationHook.events[7].data);
    }

    /*
	 * serialize/unserialize
	 */
    @Test
    public function testSeriarizeLogData():Void
    {
        // operate Reproduce
        reproduce.startOutFramePhase();
        reproduce.endPhase();

        reproduce.update(); // frame 1
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        reproduce.endPhase();

        reproduce.startOutFramePhase();
        var time1 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event1), null); // record log
        var time2 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Ready(ReproduceInput.Event2), null); // record log
        var time3 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3)), null); // record log
        var time4 = currentTimeCode();
        reproduce.endPhase();

        reproduce.update(); // frame 2
        Assert.isTrue(reproduce.checkCanProgress());
        reproduce.startInFramePhase(ReproduceUpdateKind.Input1);
        var time5 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Instant(ReproduceInput.Event4), null); // record log
        var time6 = currentTimeCode();
        reproduce.noticeLog(LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5)), null); // record log
        var time7 = currentTimeCode();
        reproduce.endPhase();

        // get record log
        var log = reproduce.getRecordLog();

        // serialize/unserialize
        var serializedLog = Serializer.run(log);
        var unserializedLog = Unserializer.run(serializedLog);

        // verify
        Assert.isType(unserializedLog, RecordLog);

        var replayLog = unserializedLog.convertReplay();
        Assert.isNotNull(replayLog);
        Assert.areEqual(5, replayLog.length);

        var expectLogway0 = LogwayKind.Instant(ReproduceInput.Event1);
        var expectLogway1 = LogwayKind.Ready(ReproduceInput.Event2);
        var expectLogway2 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event3));
        var expectLogway3 = LogwayKind.Instant(ReproduceInput.Event4);
        var expectLogway4 = LogwayKind.Snapshot(new ReproduceSnapshot(ReproduceInput.Event5));
        Assert.isTrue(logPartEquals(replayLog.list[0], 1, ReproducePhase.OutFrame, expectLogway0));
        Assert.isTrue(logPartEquals(replayLog.list[1], 1, ReproducePhase.OutFrame, expectLogway1));
        Assert.isTrue(logPartEquals(replayLog.list[2], 1, ReproducePhase.OutFrame, expectLogway2));
        Assert.isTrue(logPartEquals(replayLog.list[3], 2, ReproducePhase.InFrame(ReproduceUpdateKind.Input1), expectLogway3));
        Assert.isTrue(logPartEquals(replayLog.list[4], 2, ReproducePhase.InFrame(ReproduceUpdateKind.Input1), expectLogway4));
    }

    public static function logwayEquals(log1:LogwayKind, log2:LogwayKind):Bool
    {
        return switch(log1) {
            case LogwayKind.Snapshot(s1) if (Std.is(s1, ReproduceSnapshot)):
                switch(log2) {
                    case LogwayKind.Snapshot(s2) if (Std.is(s2, ReproduceSnapshot)):
                        Std.instance(s1, ReproduceSnapshot).equals(Std.instance(s2, ReproduceSnapshot));
                    default: Type.enumEq(log1, log2);
                }
            default: Type.enumEq(log1, log2);
        }
    }

    public static function logPartEquals(logPart:LogPart<ReproduceUpdateKind>,
                                         frame:Int, phase:ReproducePhase<ReproduceUpdateKind>, logway:LogwayKind)
    {
        return logPart.frame == frame && logPart.equalPhase(phase) && logwayEquals(logPart.logway, logway);
    }
}

class ReproduceTop extends GearHolderImpl
{
    public var reproduce:Reproduce<ReproduceUpdateKind>;
    public var hook:ReproduceHook;
    public var operationHook:ReproduceOperationHook;

	public function new()
	{
		super();
	}

	@:handler(GearDispatcherKind.Diffusible)
	function diffusible(tool:GearPreparationTool):Void
	{
        reproduce = tool.bookChild(new Reproduce<ReproduceUpdateKind>());
        hook = tool.bookChild(new ReproduceHook());
        operationHook = tool.bookChild(new ReproduceOperationHook());
        
        reproduce.gearOutside().otherDiffuse(hook, HookForReproduce);
        reproduce.gearOutside().otherDiffuse(operationHook, OperationHookForReproduce);
	}

	@:handler(GearDispatcherKind.Run)
	function run():Void
	{
	}
}

class ReproduceHook extends GearHolderImpl implements HookForReproduce
{
    public var events:Array<ReproduceHookEventData<LogwayKind>> = [];

    public function new()
    {
        super();
    }

    public function executeEvent(logWay:LogwayKind, factorPos:PosInfos):Void
    {
        events.push(new ReproduceHookEventData(logWay, ReproduceTest.currentTimeCode()));
    }
}

class ReproduceOperationHook extends GearHolderImpl implements OperationHookForReproduce
{
    public var events:Array<ReproduceHookEventData<ReproduceEvent>> = [];

    public function new()
    {
        super();
    }

    public function noticeReproduceEvent(event:ReproduceEvent):Void
    {
        events.push(new ReproduceHookEventData(event, ReproduceTest.currentTimeCode()));
    }
}

enum ReproduceUpdateKind
{
	Input1;
	Input2;
}

enum ReproduceInput
{
    Event1;
    Event2;
    Event3;
    Event4;
    Event5;
}

class ReproduceSnapshot implements Snapshot
{
    public var data:ReproduceInput;

    public function new(data:ReproduceInput)
    {
        this.data = data;
    }

    public function getDisplayName():String
    {
        return 'ReproduceSnapshot: $data';
    }

    public function equals(target:ReproduceSnapshot):Bool
    {
        return Type.enumEq(data, target.data);
    }
}

class ReproduceHookEventData<TData>
{
    public var data:TData;
    public var timeCode:Int;

    public function new(data:TData, timeCode:Int)
    {
        this.data = data;
        this.timeCode = timeCode;
    }
}
