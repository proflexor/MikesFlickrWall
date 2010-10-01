package mma.custom.event
{
	import flash.events.Event;
	
	import mma.data.flickr.PhotoData;
	
	public class PhotoDataEvent extends Event
	{
		public var photoData:PhotoData; 
		
		public function PhotoDataEvent(type:String, d:PhotoData)
		{
			super(type); 
			this.photoData = d; 
		}
	}
}