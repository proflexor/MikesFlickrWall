package mma.control.flickrControl
{
	import com.adobe.webapis.flickr.FlickrService;
	import com.adobe.webapis.flickr.Group;
	import com.adobe.webapis.flickr.PagedPhotoList;
	import com.adobe.webapis.flickr.PhotoCount;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	import com.adobe.webapis.flickr.methodgroups.Groups;
	import com.adobe.webapis.flickr.methodgroups.Photos;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	import mma.model.*;
	
	public class StartFlickrService extends EventDispatcher
	{
		
		private var flickrModel:FlickrModel = ModelLocator.getInstance().flickrModel; 
		
		public function StartFlickrService()
		{
			
		}
		public function execute():void
		{
			var service:FlickrService = new FlickrService(flickrModel.key); 
			service.secret = flickrModel.secret;
			service.token = flickrModel.token;
			service.permission = flickrModel.permission; 
			service.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, onPhotosSearchHandler);
			//service.addEventListener(FlickrResultEvent.GROUPS_POOLS_GET_GROUPS, onGetGroupListHandler); 
			
			//var photos:Photos = new Photos(service);
			//photos.search("53381288@N06");
			
			service.addEventListener(FlickrResultEvent.INTERESTINGNESS_GET_LIST, onGetInterestingListHandler);
			service.interestingness.getList(new Date("09/26/2010"), "", 265, 1);
			
			/*var groups:Groups = new Groups(service); 
			groups.pools.getGroups(); */
		}
		
		public function onPhotosSearchHandler(event:FlickrResultEvent):void
		{
			if(event.success)
			{
				flickrModel.page = event.data.photos;
				
				var service:FlickrService = new FlickrService(flickrModel.key); 
				service.secret = flickrModel.secret; 
				service.token = flickrModel.token; 
				service.permission = flickrModel.permission; 
				service.removeEventListener(FlickrResultEvent.PHOTOS_SEARCH, onPhotosSearchHandler);
				service.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
				service.addEventListener(IOErrorEvent.NETWORK_ERROR, onIOError);
				
				var e:Event = new Event("GroupLoaded");
				dispatchEvent(e);
			}
		}

		public function onGetInterestingListHandler(event:FlickrResultEvent):void
		{
			flickrModel.setPhotos(event.data.photos as PagedPhotoList);
		}
		
		/*public function onGetGroupListHandler(event:FlickrResultEvent):void
		{
			if(event.data.groups == null)
			{
				trace("Error : " + event.data.error.errorMessage); 	
			}
			else
			{
				var ary:Array = event.data.groups; 
				var g:Group = new Group(); 
			
				var i:int; 
				var len:int = ary.length; 
				
				for(i = 0; i < len; i++)
				{
					if(ary[i].name == flickrModel.groupName)
					{
						flickrModel.group = ary[i] as Group; 
						
						var service:FlickrService = new FlickrService(flickrModel.key); 
						service.secret = flickrModel.secret; 
						service.token = flickrModel.token; 
						service.permission = flickrModel.permission; 
						service.removeEventListener(FlickrResultEvent.GROUPS_POOLS_GET_GROUPS, onGetGroupListHandler);
						service.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
						service.addEventListener(IOErrorEvent.NETWORK_ERROR, onIOError);
						
						/* var photos:Photos = new Photos(service);
						service.addEventListener(FlickrResultEvent.PHOTOS_GET_COUNTS, onGetPhotoCountHandler);  
						
						var ary:Array = []; 
						var startDate:Date = new Date("01/01/2009"); 
						var endDate:Date = new Date(); 
						ary.push(startDate);
						ary.push(endDate); 
						
						photos.getCounts(ary);  
						 
						var e:Event = new Event("GroupLoaded");
						dispatchEvent(e); 
						break; 
					}	
				}
			}
		}*/
		
		private function onIOError(event:IOErrorEvent):void					// added because of unhandled IOError
		{
			removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
			trace("IOError" + event);
			//TODO
		}
		
		private function onGetPhotoCountHandler(event:FlickrResultEvent):void
		{
			
	//		trace("Error : " + event.data.error.errorMessage); 	
			
			trace("Event : " + event.data); 
			
			for(var a:Object in event.data)
			{
				trace("A : " + a + " : " + event.data[a]); 
			}
			var ary:Array = event.data.photoCounts; 
			trace("ary :" + ary.length); 
			var count:PhotoCount = ary[0]; 
			trace("Count : " + count.count); 
			
		//	trace("Ar y : " + ary); 
			
		}
	}
}