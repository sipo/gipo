package jp.sipo.gipo.core.state;
class StateSwitcherGearHolderLowLevelImpl extends GearHolderImpl implements StateSwitcherGearHolder
{
	private var stateSwitcherGear:StateSwitcherGear;
	
	public function new()
	{
		super();
		stateSwitcherGear = new StateSwitcherGear(this, gear);
	}
	
}
