package mma.model
{
	import flash.events.Event;
	import flash.geom.Point;
	
	public class TouchPoint extends Point
	{
		// ------- Child elements -------
		
		// ------- Constructor -------
		public function TouchPoint(x:Number=0, y:Number=0, id:int = 0)
		{
			super(x, y);
			this.ID = id;
		}
		
		// ------- Private vars -------
		
		// ------- Public properties -------

		private var _ID:int;
		public function get ID():int
		{
			var temp:int = _ID;
			return temp;
		}
		public function set ID(value:int):void
		{
			_ID = value;
		}
		
		// ------- Private methods -------
		
		// ------- Public functions -------
		
		public static function distance(point1:TouchPoint, point2:TouchPoint):Number
		{
			return Math.sqrt((point2.y - point1.y)*(point2.y - point1.y) + (point2.x - point1.x)*(point2.x - point1.x));
		}
		
		// ------- Event handling -------
		
		// ------- Overriden methods -------
		
		override public function toString():String
		{
			return "(x=" + this.x + ", y=" + this.y + ", ID=" + this.ID + ")";
		}
	}
}