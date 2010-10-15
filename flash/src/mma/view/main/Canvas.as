package mma.view.main
{
	import com.adobe.webapis.flickr.PagedPhotoList;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	
	import id.core.TouchSprite;
	
	import mma.control.flickrControl.StartFlickrService;
	import mma.custom.adapter.DataAdapter;
	import mma.custom.event.PhotoDataEvent;
	import mma.custom.event.RangeEvent;
	import mma.custom.event.StringEvent;
	import mma.data.flickr.PhotoData;
	import mma.model.*;
	import mma.view.item.PictureItem;
	import mma.view.item.RotatableScalable;
	import mma.view.item.TouchDot;
	
	public class Canvas extends TouchSprite
	{
		private var images:Array = new Array("image1.png", 
			"image2.png", "image3.png", "image4.png", "image5.png"); 
	
		private var xpos:int; 
		private var ypos:int; 
		private var numHeight:int; 
		private var numWidth:int; 
		private var timer:Timer; 
		private var adapter:DataAdapter; 
		private var largeContainer:TouchSprite; 
		private var container:TouchSprite; 
		private var dots:Object = {};
		private var rs: RotatableScalable
		
		private var flickrModel:FlickrModel = ModelLocator.getInstance().flickrModel; 
	
		
		public function Canvas()
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStaged); 
		}
		private function onAddedToStaged(event:Event):void
		{
			draw();
			
			var xpos:int = 0; 
			var ypos:int = 0; 
			
			var i:int; 
			var j:int; 
			
			container = new TouchSprite(); 
			addChild(container); 
			
			largeContainer = new TouchSprite(); 
			addChild(largeContainer); 
			
			//numHeight = 15; //Math.floor((this.height - 150)/75) + 2;
			//numWidth = 25; //Math.floor((this.width - 150)/75);
			
			numHeight = 14; //Math.floor((this.height - 150)/75) + 2;
			numWidth = 19; //Math.floor((this.width - 150)/75);
			
			flickrModel.photoPerPage = numHeight; 
			var c:StartFlickrService = new StartFlickrService(); 
			flickrModel.addEventListener("ImagesDataLoaded", 
				onImageDataLoadedHandler); 
			flickrModel.addEventListener("NewPhotoPageAdded", onNewPhotoPageAddedHandler); 
			c.execute();
		}
		private function onNewPhotoPageAddedHandler(event:RangeEvent):void
		{
			var i:int = event.start; 
			var len:int = event.end; 
			xpos = 77 * (event.index); 
			ypos = 0; 
			
			for(i; i < len; i++)
			{
				if(i >= ModelLocator.getInstance().flickrModel.photoCounts && i >= 0)
				{
					return; 
				}	
				var d:PhotoData = adapter.items.getItemAt(i) as PhotoData; 
				d.index = i; 
				d.xpos = xpos; 
				d.ypos = ypos; 
				
				var image:PictureItem = new PictureItem(d);
				image.addEventListener("RemoveThisItem", RemoveItemHandler); 
				image.addEventListener("ShowLargePic", onShowLargePic);
				
				image.x = xpos; 
				image.y = ypos; 
				
				container.addChild(image);
				
				ypos += 77; 
			}
		}
		private function onShowLargePic(event:PhotoDataEvent):void
		{
			event.stopImmediatePropagation();
			
			var pic:RotatableScalable = new RotatableScalable(event.photoData);
			addEventListener("SetIndexImage", onSetIndexImageHandler); 
			pic.addEventListener("RemoveLargeImage", onRemoveLargeImageHandler); 
			
			pic.blobContainerEnabled = true;
			
			pic.x = event.photoData.xpos; 
			pic.y = event.photoData.ypos;  
			
			pic.blobContainer.addEventListener(TouchEvent.TOUCH_DOWN, startDrag_Press);
			pic.blobContainer.addEventListener(TouchEvent.TOUCH_UP, stopDrag_Release);
			pic.blobContainer.addEventListener(GestureEvent.GESTURE_ROTATE, gestureRotateHandler);
			pic.blobContainer.addEventListener(GestureEvent.GESTURE_SCALE, gestureScaleHandler); 
			
			largeContainer.addChild(pic); 
			
		}
		
		private function startDrag_Press(e:TouchEvent):void {
			if(e.currentTarget.guid)
			{
				var event:StringEvent = new StringEvent("SetIndexImage", e.currentTarget.guid); 
				dispatchEvent(event);
			}	
			e.target.startTouchDrag(false);
			trace("draggin");
		}
		private function stopDrag_Release(e:TouchEvent):void {
			e.target.stopTouchDrag(void);
		}
		
		private function gestureRotateHandler(e:GestureEvent):void {
			e.target.rotation += e.value;
		}
		
		private function gestureScaleHandler(e:GestureEvent):void {
			e.stopImmediatePropagation();
			var status:int = e.currentTarget.setScaleStatus();
						
			switch(status)
			{
				case 0:
					break;
				case 1:
					if(e.value >= 0)
					{
						return;
					}
					break;
				case 2: 
					if(e.value <= 0)
					{
						return;
					}
					break;
				default:
					trace("Undefined scalingStatus = " + status);
					break;
					
			}
			e.target.scaleX += e.value;
			e.target.scaleY += e.value;
			e.currentTarget.drawBorder();
				
		}			
		
		private function onRemoveLargeImageHandler(event:StringEvent):void
		{
			event.stopImmediatePropagation(); 
			var i:int; 
			var len:int = largeContainer.numChildren; 
			
			for(i = 0; i < len; i++)
			{
				//var pic:LargePictureItem = largeContainer.getChildAt(i) as LargePictureItem; 
				var pic:RotatableScalable = largeContainer.getChildAt(i) as RotatableScalable;
				if(pic.guid == event.str)
				{
					largeContainer.removeChild(pic);
					break;
				}
			}
			
			flickrModel.isClosing = false;
		}
		private function onSetIndexImageHandler(event:StringEvent):void
		{
			event.stopImmediatePropagation(); 
			var i:int; 
			var len:int = largeContainer.numChildren; 
			
			for(i = 0; i < len; i++)
			{
				//var pic:LargePictureItem = largeContainer.getChildAt(i) as LargePictureItem; 
				var pic:RotatableScalable = largeContainer.getChildAt(i) as RotatableScalable;
				if(pic.guid == event.str)
				{
					largeContainer.setChildIndex(pic, largeContainer.numChildren - 1); 
				}
			}
		}
		private function onImagesUpdatedHandler(event:Event):void
		{
			event.stopImmediatePropagation(); 
		}
		private function onImageDataLoadedHandler(event:Event):void
		{
		 	event.stopImmediatePropagation(); 	 
			adapter = new DataAdapter(flickrModel.images); 
			adapter.addEventListener("AddedImage", onAddImageHandler); 
			adapter.addEventListener("ImagesUpdated", onImagesUpdatedHandler);
			
			var xpos:int = 1;
			var ypos:int = 1; 
			
			var i:int;
			var len:int = adapter.items.length; 
			var count:int = 0; 
			
			for(i = 0; i < len; i ++)
			{
				var d:PhotoData = adapter.items.getItemAt(i) as PhotoData; 
				var image:PictureItem = new PictureItem(d);
				image.addEventListener("RemoveThisItem", RemoveItemHandler); 
				image.x = xpos; 
				image.y = ypos; 
		 		ypos += 77; 
				addChild(image); 
				
	
				if(count == this.numHeight)
				{
					count = 0; 
					ypos += 77; 
				}
				count++; 
			}
		}
		private function RemoveItemHandler(event:Event):void
		{
			
		}
		private function onAddImageHandler(event:Event):void
		{
			
		}
			
		public function draw():void
		{
			var g:Graphics = this.graphics; 
			//g.lineStyle(0, 0x9f9f9f); 
			g.beginFill(0xefefef, 0); 
			g.drawRect(0, 0, 2560, 1460); 
			g.endFill();
		}
		
		
	}
}