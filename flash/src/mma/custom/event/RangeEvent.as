package mma.custom.event
{
	import flash.events.Event;
	
	public class RangeEvent extends Event
	{
		public var start:int; 
		public var end:int; 
		public var index:int; 
		
		public function RangeEvent(type:String, index:int, start:int, end:int)
		{
			super(type); 
			this.start = start; 
			this.index = index; 
			this.end = end; 
		}
	}
}