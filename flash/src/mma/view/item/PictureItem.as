//TODO:onLoaderComplete needs performance improvement

package mma.view.item
{
	import flash.display.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Timer;
	
	import mma.custom.effect.Ripple;
	import mma.custom.event.PhotoDataEvent;
	import mma.data.flickr.PhotoData;
	import mma.model.FlickrModel;
	import mma.model.ModelLocator;
	
	import tuio.flash.events.*;

	public class PictureItem extends Sprite implements IPictureItem
	{
	
		[Embed(source="/asset/flash/Preloader.swf", symbol="PreloaderMC")]
		public var Preloader:Class; 
		
		public static const itemW:int = 75; 
		public static const itemH:int = 75; 
		
		private var loader:Loader; 
		private var app:ApplicationDomain; 
		//private var tuioObj:Object; 
		private var startX:Number; 
		private var startY:Number; 
		private var rotateX:Number; 
		private var rotateY:Number; 
		//move
		private var padding:int = 5; 
		private var yDest:Number;  
		private var angle:Number = 0;
		private var speed:Number = 0.05;
		private var yStart:Number; 
		private var url:String; 
		
		private var previousY:Number; 
		private var previousX:Number; 

		private var touchCount:int = 0; 
		private var container:Sprite; 
		
		private var preloader:Sprite; 
		private var photoData:PhotoData; 
		private var timer:Timer; 
		private var ypos:int; 
		private var xpos:int; 
		private var noThumbMC:Sprite; 
		
		private var loadingLarge:Boolean; 
		
		public function PictureItem(p:PhotoData)
		{
			draw();
			this.photoData = p; 
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage); 	
			
		}
		protected function onAddedToStage(event:Event):void
		{			
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			container = new Sprite(); 
			addChild(container); 
			
			preloader = new Preloader();
			container.addChild(preloader); 
			container.x = 1; 
			container.y = 1; 
			//container.transform.matrix  = new Matrix(1, 0, 0, 1, -37.5, -37.5); 
			preloader.y = this.height/2 - 10; 
			preloader.x = this.width/2 - preloader.width/2; 
			
			container.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler); 
			
			
			
			event.stopImmediatePropagation(); 
			loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete); 
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError); 
			
			photoData.addEventListener("SizeLoaded", onSizeLoadedHandler); 
			//addEventListener(MouseEvent.MOUSE_DOWN, onTouchDownHandler); 
			//container.addEventListener(MouseEvent.MOUSE_DOWN, onTouchDownHandler); 
			
			noThumbMC = new Sprite(); 
			
			this.previousX = this.x;
			this.previousY = this.y; 
			
			
			
		}
		private function onShowThumbHandler(event:Event):void
		{
			if(photoData.showThumb)
			{
				if(noThumbMC.stage)
				{
					removeChild(noThumbMC); 
				}
				loadingLarge = false; 
			}
			else
			{
				loadingLarge = false; 
				addChild(noThumbMC);
				
				var g:Graphics = noThumbMC.graphics; 
				/* */
				
			/* 	g.beginFill(0x000000, .4); 
				g.drawRect(0, 0, itemW, itemH);
				
				
				 */
				g.lineStyle(0, 0x000000, 0); 
				g.beginFill(0x000000, .2); 
				g.drawRect(1, 1, itemW - 2, itemH - 2); 
				 
				g.lineStyle(10, 0x000000, .5, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER); 
				g.beginFill(0x000000, 0); 
				g.drawRect(15, 15, itemW - 29, itemH - 29); 
				
				g.lineStyle(10, 0x000000, .8, false, LineScaleMode.NORMAL, CapsStyle.SQUARE, JointStyle.MITER); 
				g.drawRect(6, 6, itemW - 10, itemH - 10);
				
				
				
			/* 	
				g.beginFill(0x000000, .9); 
				g.drawRect(0, 0, itemW, itemH);
				g.beginFill(0x000000, .7); 
				g.drawRect(5, 5, itemW - 10, itemH - 10);
				
				
				 */
				
				
				
				
			}
		}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace(event);
		}
		
		private function onSizeLoadedHandler(event:Event):void
		{
			event.stopImmediatePropagation(); 
			loader.load(new URLRequest(photoData.square.source)); 
			
			trace("photoData.square.source  : " + photoData.square.source); 
			
			photoData.addEventListener("ShowThumb", onShowThumbHandler); 
		}
		private function onLoaderComplete(event:Event):void
		{
			event.stopImmediatePropagation(); 
			
			container.removeChild(preloader); 
			//container = new Sprite(); 
			
			loader.content.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler);
			loader.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler); 
			container.addChild(loader); 
			container.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler); 
			
			this.cacheAsBitmap = true; 
			container.cacheAsBitmap = true; 
			loader.cacheAsBitmap = true; 
			loader.content.cacheAsBitmap = true; 
			
			
			
			addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler); 

			//addEventListener(MouseEvent.CLICK, onMouseClickHandler); 
			
			//GetPixels(); 
		}
		
		private function onTouchDownHandler(event:TouchEvent):void
		{
			var flickrModel:FlickrModel = ModelLocator.getInstance().flickrModel;
			
			if(flickrModel.isClosing)
				return;
			
			event.stopImmediatePropagation();
			if(!photoData.showThumb || loadingLarge)
				return; 
			
			loadingLarge = true; 
			
			var e:Ripple = new Ripple(this); 
			e.addEventListener("RippleCompleted", onRippleCompletedHandler);
			e.radius = 80; 
			e.durationInFrames = 60; 
			e.amplitude = 40; 
			
			e.rippleIt(new Point(event.localX, event.localY));  
			xpos = event.localX; 
			ypos = event.localY; 
			
			var b:BitmapData = new BitmapData(loader.content.width, loader.content.height); 
			
			b.draw(loader.content, new Matrix()); 
			
			
			
			var aaa:uint = b.getPixel(35,35); 
			
			trace("AAA : " + aaa); 
			var photoEvent:Event = new PhotoDataEvent("ShowLargePic", photoData);
			dispatchEvent(photoEvent);
			trace(photoEvent);
		
		}
		private function onRippleCompletedHandler(event:Event):void
		{
//			var e:PhotoDataEvent = new PhotoDataEvent("ShowLargePic", this.photoData); 
//			dispatchEvent(e); 
			photoData.showThumb = false; 
			
		}
/*		private function onMouseClickHandler(event:MouseEvent):void
		{
			var e:Ripple = new Ripple(this); 
			e.radius = 80; 
			e.durationInFrames = 60; 
			e.amplitude = 40; 
			e.rippleIt(new Point(xpos, ypos));  
			
			timer = new Timer(100, 1); 
			timer.addEventListener(TimerEvent.TIMER, onRippleAgainHandler); 
			timer.start();
		}*/
		private function onRippleAgainHandler(event:TimerEvent):void
		{
			var rippleObject:Ripple = new Ripple(this)
			rippleObject.radius = 80; 
			rippleObject.durationInFrames = 60 + timer.currentCount * 5; 
			rippleObject.amplitude = 40 - timer.currentCount * 5; 
			rippleObject.rippleIt(new Point(this.mouseX, this.mouseY))
		}
		private function GetSmallToGetThumb():void
		{
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderSamllImageComplete);
			loader.load(new URLRequest(photoData.small.source));
		}
		private function onLoaderSamllImageComplete(event:Event):void
		{
			var w:Number = loader.content.width; 
			var h:Number = loader.content.height; 
			
		}
		private function GetPixels():void
		{
			var data:BitmapData = new BitmapData(itemW, itemH); 
			data.draw(loader, new Matrix(1, 0, 0, 1, itemW/2 - loader.width/2, itemH/2 - loader.height/2)); 
			var bitmap:Bitmap = new Bitmap(data); 
			container.addChild(bitmap); 
			bitmap.x = 1; 
			bitmap.y = 1; 
		}
		public function draw():void
		{
			var g:Graphics = this.graphics; 
			g.lineStyle(.5, 0xffffff, .15); 
			g.beginFill(0xffffff, 0); 
			g.drawRect(0, 0, itemW + 2, itemH + 2); 
			
		}
	}
}