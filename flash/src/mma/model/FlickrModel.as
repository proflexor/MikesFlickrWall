package mma.model
{
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	import com.adobe.webapis.flickr.methodgroups.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mma.custom.event.RangeEvent;
	import mma.data.flickr.PhotoData;
	
	import mx.collections.ArrayCollection;
	
	public class FlickrModel extends EventDispatcher
	{
		private var _key:String = "67ea72b59479e528904191d5613ce43b"; 
		private var _secret:String = "cb534653537347cf";  
		private var _token:String = "72157622695588768-4f4e12332f36d7f8"; 
		private var _groupName:String = "MMAFlickr";
		
		/*private var _key:String = "405af49b254ab583814744f04c078bc1";
		private var _secret:String = "db7706291dd8cda8";
		private var _token:String ;
		private var _groupName:String = "MMAFlickr";
		*/private var _service:FlickrService; 
		private var _permission:String = "write"; 
		private var _group:Group; 
		public var photoPerPage:int = 12; 
		private var newPhotosTimer:Timer; 
		private var timer:Timer = new Timer(20000);
		public var photoCounts:int; 
		public var _page:PagedPhotoList;
		//private var _photos:Photos;	
		
		public var isClosing:Boolean = false;
		
		private var _images:ArrayCollection = new ArrayCollection(); 
		
		
		public function FlickrModel()
		{
		//	timer.addEventListener(TimerEvent.TIMER, onRefreshPhotoListHandler); 
		//	timer.start(); 
		}
		private function onRefreshPhotoListHandler(event:TimerEvent):void
		{
			/* var service:FlickrService = new FlickrService(_key); 
			service.secret = _secret; 
			service.token = _token; 
			service.permission = _permission; 
			
			var groups:Groups = new Groups(service); 
			service.removeEventListener(FlickrResultEvent.GROUPS_POOLS_GET_PHOTOS, onGetNewPhotoHandler); 
			service.addEventListener(FlickrResultEvent.GROUPS_POOLS_GET_PHOTOS, onGetNewPhotoHandler); 
			service.pools.getPhotos(_group.nsid, "", "", 500);  */
		}
		private function onGetNewPhotoHandler(event:FlickrResultEvent):void
		{
			/* var page:PagedPhotoList = event.data.photos; 
			
			var i:int; 
			var len:int = page.photos.length; 
			var found:Boolean = false; 
			
			for(i = 0; i < len; i++)
			{
				var j:int; 
				var jLen:int = _images.length;
				var pData:Photo = page.photos[i];  
				
				for(j = 0; j < jLen; j++)
				{
					var saved:PhotoData = _images.getItemAt(j) as PhotoData; 
					if(saved.photo_id == pData.id)
					{
						found = true; 
						break; 
					}
				}
				if(!found)
				{
					var d:PhotoData = new PhotoData(); 
					d.photo = page.photos[i] as Photo; 
					_images.addItem(d); 
					
					d.getSize(_key, _token, _permission, _secret); 
				}
			} */
		}
		
		public function set page(value:PagedPhotoList):void
		{
			_page = value;
			
			var service:FlickrService = new FlickrService(_key); 
			service.secret = _secret; 
			service.token = _token; 
			service.permission = _permission; 
			
			photoCounts = _page.photos.length; 
			
			var i:int; 
			var len:int = photoCounts; 
			
			trace("P count : " + photoCounts); 
			var count:int = Math.floor(_page.photos.length/photoPerPage) + 1;
			
			var e:Event = new Event("ImagesDataLoaded"); 
			dispatchEvent(e);  
			
			newPhotosTimer = new Timer(100, count);
			newPhotosTimer.addEventListener(TimerEvent.TIMER, onNewPhotoTimerHandler);  
			newPhotosTimer.start();
		}
		
		public function set group(value:Group):void
		{
			_group = value;
			
			var service:FlickrService = new FlickrService(_key); 
			service.secret = _secret; 
			service.token = _token; 
			service.permission = _permission; 
			
			var photos:Photos = new Photos(service); 
			service.removeEventListener(FlickrResultEvent.PHOTOS_SEARCH, onPhotosSearchHandler); 
			service.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, onPhotosSearchHandler); 
			
			//service.photos.search("53381288@N06");
			service.pools.getPhotos(_group.nsid, "", "", 375, 1);
			
		//	groups.pools.getGroups();  
		}

		
		public function setPhotos(pg:PagedPhotoList):void
		{
			_page = pg;			
			photoCounts = _page.photos.length; 
			
			trace("P count : " + photoCounts); 
			var count:int = Math.floor(_page.photos.length/photoPerPage) + 1;
			
			var e:Event = new Event("ImagesDataLoaded"); 
			dispatchEvent(e);  
			
			newPhotosTimer = new Timer(100, count);
			newPhotosTimer.addEventListener(TimerEvent.TIMER, onNewPhotoTimerHandler);  
			newPhotosTimer.start();
		}
		
		private function onPhotosSearchHandler(event:FlickrResultEvent):void
		{
			
			
		}
		private function onNewPhotoTimerHandler(event:TimerEvent):void
		{
			
			
			var i:int = (newPhotosTimer.currentCount - 1) * photoPerPage; 
			var t:int = photoPerPage; 
			var len:int = i + photoPerPage; 
			
			if(len > (this.photoCounts))
			{
				len = (this.photoCounts); 
				
				t = photoCounts - i; 
				
				trace("new len : " + len); 
			}
					
			for(i; i < len; i++)
			{
				if((i - 1) < photoCounts && (i >= 0))
				{
					var pData:PhotoData = new PhotoData(); 
					pData.photo = _page.photos[i] as Photo; 
					_images.addItem(pData); 
					pData.getSize(_key, _token, _permission, _secret); 
				}
			}
			var e:RangeEvent = new RangeEvent("NewPhotoPageAdded", 
				newPhotosTimer.currentCount - 1, i - t, len); 
			dispatchEvent(e); 
		}
		private function onGetSecondPageHandler(event:FlickrResultEvent):void
		{
			var page2:PagedPhotoList = event.data.photos; 
			
			var i:int; 
			var len:int = page2.photos.length; 
			
			for(i = 0; i < len; i++)
			{
				var photo:Photo = page2.photos[i] as Photo; 
				_page.photos.push(photo); 
			}
			
			
			
			
			photoCounts = _page.photos.length; 
			// 
			
		//	trace("Count : " + count); 
			
			/*  */
			/* 
						
			for(i = 0; i < len; i++)
			{
				var pData:PhotoData = new PhotoData(); 
				pData.photo = page.photos[i] as Photo; 
				_images.addItem(pData); 
				
				pData.getSize(_key, _token, _permission, _secret); 
		//		GetSizePhoto(pData); 
			}
			
			*/
			
			trace("P count : " + photoCounts); 
			var count:int = Math.floor(_page.photos.length/photoPerPage) + 1;
			
			var e:Event = new Event("ImagesDataLoaded"); 
			dispatchEvent(e);  
			
			newPhotosTimer = new Timer(100, count);
			newPhotosTimer.addEventListener(TimerEvent.TIMER, onNewPhotoTimerHandler);  
			newPhotosTimer.start();
			
			
			
		}
		
		public function GetSizePhoto(pData:PhotoData):void
		{
			var service:FlickrService = new FlickrService(_key); 
			service.secret = _secret; 
			service.permission = this._permission; 
			service.token = _token; 
			
			var photos:Photos = new Photos(service); 
			service.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, onGetPhotoInfoHandler); 
			photos.getSizes(pData.photo_id);
		}
		private function onGetPhotoInfoHandler(event:FlickrResultEvent):void
		{
				
			
			
			
		}
		public function get group():Group
		{
			return _group; 
		}
		public function get images():ArrayCollection
		{
			return _images; 
		}
		public function set images(value:ArrayCollection):void
		{
			_images = value; 
		}
		public function imageCount():int
		{
			return _images.length; 
		}
		public function get groupName():String
		{
			return _groupName; 
		}
		public function set groupName(value:String):void
		{
			_groupName = value; 
		}
		public function get key():String
		{
			return _key; 
		}
		public function set key(value:String):void
		{
			_key = value; 
		}
		public function get secret():String
		{
			return _secret; 
		}
		public function set secret(value:String):void
		{
			_secret = value; 
		}
		public function get permission():String
		{
			return _permission; 
		}
		public function set permission(value:String):void
		{
			_permission = value; 
		}
		public function get token():String
		{
			return _token; 
		}
		public function set token(value:String):void
		{
			_token = value; 
		}
		


/* <?xml version="1.0" encoding="utf-8" ?>
<rsp stat="ok">
<sizes canblog="1" canprint="1" candownload="1">
	<size label="Square" width="75" height="75" source="http://farm4.static.flickr.com/3277/4063080054_cbcca678d0_s.jpg" url="http://www.flickr.com/photos/44139271@N04/4063080054/sizes/sq/" media="photo" />
	<size label="Thumbnail" width="100" height="86" source="http://farm4.static.flickr.com/3277/4063080054_cbcca678d0_t.jpg" url="http://www.flickr.com/photos/44139271@N04/4063080054/sizes/t/" media="photo" />
	<size label="Small" width="240" height="206" source="http://farm4.static.flickr.com/3277/4063080054_cbcca678d0_m.jpg" url="http://www.flickr.com/photos/44139271@N04/4063080054/sizes/s/" media="photo" />
	<size label="Medium" width="351" height="301" source="http://farm4.static.flickr.com/3277/4063080054_cbcca678d0.jpg" url="http://www.flickr.com/photos/44139271@N04/4063080054/sizes/m/" media="photo" />
	<size label="Large" width="351" height="301" source="http://farm4.static.flickr.com/3277/4063080054_2d609d2570_o.png" url="http://www.flickr.com/photos/44139271@N04/4063080054/sizes/o/" media="photo" />
</sizes>
</rsp>
		
		 */
		
		
		
		
	}
}