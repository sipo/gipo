package jp.sipo.gipo.core.state;
class StateGearHolderImpl extends GearHolderImpl implements StateGearHolder 
{
	private var gearState:StateGear;
	
	public function new()
	{
		super();
		gearState = new StateGear(this, gear);
	}
	
	public function getGearState():StateGear
	{
		return gearState;
	}
}
