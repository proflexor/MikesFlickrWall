package mma.custom.event
{
	import flash.events.Event;
	
	public class StringEvent extends Event
	{
		public var str:String; 
		
		public function StringEvent(type:String, str:String)
		{
			super(type); 
			this.str = str; 
		}
	}
}