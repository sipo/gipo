package jp.sipo.gipo.core.state;
class StateSwitcherGearHolderImpl extends GearHolderImpl implements StateSwitcherGearHolder
{
	private var gearStateSwitcher:StateSwitcherGear;
	
	public function new()
	{
		super();
		gearStateSwitcher = new StateSwitcherGear(this, gear);
	}
	
}
