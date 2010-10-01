package mma.custom.event
{
	import flash.events.Event;
	
	public class IntEvent extends Event
	{
		public var index:int; 
		
		public function IntEvent(type:String, index:int)
		{
			super(type); 
			this.index = index; 
		}

	}
}