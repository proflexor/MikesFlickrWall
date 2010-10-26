package mma.data.flickr
{
	import com.adobe.webapis.flickr.*;
	import com.adobe.webapis.flickr.events.FlickrResultEvent;
	import com.adobe.webapis.flickr.methodgroups.Photos;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	public class PhotoData extends EventDispatcher
	{
		private var _photo:Photo; 
		private var _square:PhotoSize; 
		private var _small:PhotoSize; 
		private var _medium:PhotoSize; 
		private var _large:PhotoSize; 
		private var _thumb:PhotoSize; 
		private var _index:int; 
		private var _ypos:int; 
		private var _xpos:int; 
		private var _showThumb:Boolean = true; 
		
		public function PhotoData()
		{
			
		}
		public function get showThumb():Boolean
		{
			return _showThumb;	
		}
		public function set showThumb(value:Boolean):void
		{
			_showThumb = value; 
			var e:Event = new Event("ShowThumb"); 
			dispatchEvent(e); 
		}
		public function getSize(key:String, token:String, perm:String, secret:String):void
		{
			var service:FlickrService = new FlickrService(key); 
			service.token = token; 
			service.permission = perm; 
			service.secret = secret; 
			
			var photos:Photos = new Photos(service); 
			service.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, onGetPhotoInfoHandler); 
			service.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			photos.getSizes(_photo.id); 
		}
		private function onGetPhotoInfoHandler(event:FlickrResultEvent):void
		{
			
			event.stopImmediatePropagation(); 
			var ary:Array = event.data.photoSizes; 
			var photosize:PhotoSize = ary[0]; 	
			photoSizes = event.data.photoSizes; 
		}
		private function onIOError(event:IOErrorEvent):void
		{
			trace("PhotoData.onIOError", event.text);
		}
		
		public function set photoSizes(value:Array):void
		{
			var i:int; 
			var len:int = value.length; 
			for(i = 0; i < len; i++)
			{
				var p:PhotoSize = value[i]; 
				
				switch(p.label)
				{
					case "Square":
						_square = p; 
						break; 
					case "Small":
						_small = p; 
						break; 
					case "Medium":
						_medium = p; 
						break; 
					case "Large":			//s"Original"
						_large = p; 
						break; 
					case "Thumbnail":
						_thumb = p; 
						break; 
				}
			}
		
			var e:Event = new Event("SizeLoaded"); 
			dispatchEvent(e); 
		}
		public function get photo():Photo
		{
			return _photo; 
		}
		public function set photo(value:Photo):void
		{
			_photo = value; 
		}
		public function get photo_id():String
		{
			return _photo.id; 
		}
		public function get square():PhotoSize
		{
			return _square; 
		}
		public function get medium():PhotoSize
		{
			return _medium; 
		}
		public function get small():PhotoSize
		{
			return _small; 
		}
		public function get large():PhotoSize
		{
			return _large; 
		}
		public function set large(value:PhotoSize):void
		{
			_large = value; 
		}
		public function get thumb():PhotoSize
		{
			return _thumb; 
		}
		public function set thumb(value:PhotoSize):void
		{
			_thumb = value; 
		}
		public function get index():int
		{
			return _index; 
		}
		public function set index(value:int):void
		{
			_index = value; 
		}
		public function get xpos():int
		{
			return _xpos; 
		}
		public function set xpos(value:int):void
		{
			_xpos = value; 
		}
		public function get ypos():int
		{
			return _ypos; 
		}
		public function set ypos(value:int):void
		{
			_ypos = value; 
		}
	}
}