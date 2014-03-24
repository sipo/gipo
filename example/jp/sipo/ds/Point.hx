package jp.sipo.ds;
@:generic
class Point<T:(Float)>
{
	public var x:T;
	public var y:T;
	
	public function new(x:T, y:T)
	{
		this.x = x;
		this.y = y;
	}
	
	public function clone():Point<T>
	{
		return new Point<T>(x, y);
	}
	
	public function equal(point:Point<T>):Bool
	{
		return point.x == x && point.y == y;
	}
}
