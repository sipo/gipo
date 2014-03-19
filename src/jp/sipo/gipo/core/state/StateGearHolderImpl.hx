package jp.sipo.gipo.core.state;
class StateGearHolderImpl extends GearHolderImpl implements StateGearHolder 
{
	private var stateGear:StateGear;
	
	public function new()
	{
		super();
		stateGear = new StateGear(this, gear);
	}
	
	public function getGearState():StateGear
	{
		return stateGear;
	}
}
