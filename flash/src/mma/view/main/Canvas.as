package mma.view.main
{
	import com.adobe.webapis.flickr.PagedPhotoList;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.*;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	
	import mma.control.flickrControl.StartFlickrService;
	import mma.custom.adapter.DataAdapter;
	import mma.custom.event.PhotoDataEvent;
	import mma.custom.event.RangeEvent;
	import mma.custom.event.StringEvent;
	import mma.data.flickr.PhotoData;
	import mma.model.*;
	import mma.view.item.LargePictureItem;
	import mma.view.item.PictureItem;
	import mma.view.item.RotatableScalable;
	import mma.view.item.TouchDot;
	
	public class Canvas extends Sprite
	{
		private var images:Array = new Array("image1.png", 
			"image2.png", "image3.png", "image4.png", "image5.png"); 
	
		private var xpos:int; 
		private var ypos:int; 
		private var numHeight:int; 
		private var numWidth:int; 
		private var timer:Timer; 
		private var adapter:DataAdapter; 
		private var largeContainer:Sprite; 
		private var container:Sprite; 
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
			
			container = new Sprite(); 
			addChild(container); 
			largeContainer = new Sprite(); 
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
			
			addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
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
			//var pic:LargePictureItem = new LargePictureItem(event.photoData); 
			var pic:RotatableScalable = new RotatableScalable(event.photoData);
			pic.addEventListener("SetIndexImage", onSetIndexImageHandler); 
			pic.addEventListener("RemoveLargeImage", onRemoveLargeImageHandler); 
			pic.x = event.photoData.xpos; 
			pic.y = event.photoData.ypos; 
			largeContainer.addChild(pic); 
			
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
		
/*		private function onRotateHandler(event:TransformGestureEvent):void
		{
			//if(event.target is LargePictureItem)
			if(event.target is RotatableScalable)
			{
				event.target.rotation += event.rotation;
			}
		}
*/		
		private function onTouchBegin(event:TouchEvent):void
		{
			event.stopImmediatePropagation();
			var dot:TouchDot = new TouchDot();
			dot.ID = event.touchPointID;
			dot.x = event.stageX;
			dot.y = event.stageY;	
			dots[event.touchPointID.toString()] = dot;
			addChild(dot);
		}
		
		private function onTouchEnd(event:TouchEvent):void
		{
			trace("Removed TouchDotID: " + event.touchPointID);
			event.stopImmediatePropagation();
			var dot:TouchDot = dots[event.touchPointID.toString()];
			if(dot)
			{
				if(dot.stage)
				{
					removeChild(dot);
				}
				delete dots[event.touchPointID.toString()];
			}				
			else
				return;
		}
		
		private function onTouchMove(event:TouchEvent):void
		{
			var dot:TouchDot = dots[event.touchPointID.toString()];
			if(dot)
			{
				dot.x = event.stageX;
				dot.y = event.stageY;
			}				
			else
				return;
		}
		
		public function draw():void
		{
			var g:Graphics = this.graphics; 
			g.lineStyle(0, 0x9f9f9f); 
			g.beginFill(0xefefef, 0); 
			g.drawRect(0, 0, 2560, 1460); 
			g.endFill();
		}
		
		
	}
}