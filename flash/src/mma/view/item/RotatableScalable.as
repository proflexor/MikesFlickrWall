package mma.view.item
{
	import com.adobe.cairngorm.model.ModelLocator;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.TouchEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	
	import id.core.TouchSprite;
	
	import mma.custom.event.StringEvent;
	import mma.data.flickr.PhotoData;
	import mma.model.FlickrModel;
	import mma.model.ModelLocator;
	import mma.model.TouchPoint;
	
	import mx.utils.UIDUtil;

	public class RotatableScalable extends TouchSprite
	{
		// ------- Child elements -------
		
		// ------- Constructor -------
		public function RotatableScalable(d: PhotoData)
		{
			photoData = d; 	
			guid = UIDUtil.createUID(); 
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		// ------- Private vars -------
		
		private var photoData:PhotoData; 
		public var guid:String; 
		//private var imgContainer:Sprite;
		private var loader:Loader; 
		
		//animation vars.
		private var angle:Number = 0;
		private var speed:Number = 0.3; 
		private var destWidth:Number;
		private var destHeight:Number;
		
		private var startW:Number; 
		private var startH:Number; 
		private var closeXpos:Number; 
		private var closeYpos:Number; 
		
		private var firstAngle:Number; 
		private var maxH:Number; 
		private var maxW:Number; 
		private var minH:Number; 
		private var minW:Number; 
		private var bW:Number; 
		private var bH:Number; 
		public var widthRatio:Number; 
		
		private var closeBtn:Sprite = new Sprite(); 
		
		[Embed(source="/asset/flash/ImageWallAsset.swf", symbol="CloseBtn")]
		public var CloseBtn:Class; 
		
		// ------- Public properties -------
		private var _scaleStatus:int =0;		// 0 for scalable, 1 for at max, 2 for at min.
		public function get scaleStatus():int
		{
			return _scaleStatus;
		}
		
		public function drawBorder(scale:Number):void
		{
			loader.content.width *= (1 + scale);			
			loader.content.height = loader.content.width/widthRatio;			
			graphics.clear();			
			if(loader.content.width >= maxW)			
			{				
				graphics.lineStyle(20,0x121247,1.0,true);
				loader.content.width = maxW;				
				loader.content.height= maxW/widthRatio;				
				_scaleStatus = 1;			
			}			
			else if(loader.content.width <= minW)			
			{				
				graphics.lineStyle(20,0x121247,1.0,true);				
				loader.content.width = minW;				
				loader.content.height = minW/widthRatio;				
				_scaleStatus = 2;			
			}			
			else			
			{				
				graphics.lineStyle(20,0xefefef,1.0,true);				
				_scaleStatus = 0;
			}			
			
			graphics.moveTo(0, 0);			
			graphics.lineTo(loader.width, 0);			
			graphics.lineTo(loader.width, loader.height);			
			graphics.lineTo(0, loader.height);			
			graphics.lineTo(0, 0);			
			
			closeBtn.x = loader.content.width-25;
		}
		
		// ------- Private methods -------
		

		private function addTouchEvents():void
		{
			trace("addTouchEvents()");
			photoData.showThumb = false; 
			
			closeBtn.x = width - 25; 
			closeBtn.y = -25;
			addChild(closeBtn);
			
			closeBtn.addEventListener(flash.events.TouchEvent.TOUCH_BEGIN, onCloseHandler);
	
			this.transform.matrix  = new Matrix(1, 0, 0, 1, -width/2, -height/2);
			
			this.x = photoData.xpos; 
			this.y = photoData.ypos;
			trace("recalculate x & y");
			
			graphics.clear();
			graphics.lineStyle(20,0xefefef,1.0,true);
			
			graphics.moveTo(0, 0);
			graphics.lineTo(loader.width, 0);
			graphics.lineTo(loader.width, loader.height);
			graphics.lineTo(0, loader.height);
			graphics.lineTo(0, 0);
			
		}
		
		
		private function showBorder():void
		{
			closeBtn.visible = true; 
		}
		private function hideBorder():void
		{
			closeBtn.visible = false;
		}		
		
		
		// ------- Public functions -------
		
		// ------- Event handling -------
		
		private function _onAddedToStage(event:Event):void
		{
			trace("onAddedToStage()");
			event.stopImmediatePropagation();
			
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			//container = new Sprite(); 
			//addChild(container);
			
			loader = new Loader(); 
			loader.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			if(photoData.large != null)
				loader.load(new URLRequest(photoData.large.source));
			else if(photoData.medium != null)
				loader.load(new URLRequest(photoData.medium.source));
			else if(photoData.small != null)
				loader.load(new URLRequest(photoData.small.source));
			else
				loader.load(new URLRequest(photoData.thumb.source));
			
			closeBtn.addChild(new CloseBtn());
			closeBtn.buttonMode = true;
			trace("components added to screen");
		}

		private function onCloseHandler(event:flash.events.TouchEvent):void
		{
			event.stopImmediatePropagation();
			
			var model:mma.model.ModelLocator = mma.model.ModelLocator.getInstance();
			model.flickrModel.isClosing = true;
			event.stopImmediatePropagation();
			
			closeBtn.removeEventListener(flash.events.TouchEvent.TOUCH_BEGIN, onCloseHandler);
			
			photoData.showThumb = true; 
			var e:StringEvent = new StringEvent("RemoveLargeImage", this.guid); 
			dispatchEvent(e);
			trace(e.toString(), this.guid);
		}
		
		private function onLoaderComplete(event:Event):void
		{
			event.stopImmediatePropagation(); 
			
			loader.visible = false; 
			
			maxW = loader.content.width; 
			
			widthRatio = loader.content.width/loader.content.height;
			
			loader.content.width = loader.content.width/2; 
			loader.content.height = loader.content.height/2;
			
			minW = loader.content.width; 
			
			destWidth = loader.content.width; 
			destHeight = loader.content.height; 
			
			addChild(loader);
			
			loader.content.width = 75; 
			loader.content.height = 75; 
			
			var drop:DropShadowFilter = new DropShadowFilter(15, 45, 0x000000, .7, 15, 15); 
			var drop2:DropShadowFilter = new DropShadowFilter(15, -135, 0x000000, .7, 15, 15); 

			var ary:Array = []; 
			ary.push(drop); 
			ary.push(drop2); 
			this.filters = ary; 
			removeEventListener(Event.ENTER_FRAME, onShowImageEnterFrame);
			addEventListener(Event.ENTER_FRAME, onShowImageEnterFrame);
			
			loader.visible = true;
		}
		
		private function onShowImageEnterFrame(event:Event):void
		{
			
			var v:Number = Math.sin(angle); 
			angle += speed; 
			var w:Number = v * destWidth + 75; 
			var h:Number = v * destHeight + 75; 
			var a:Number = v * .5; 
			
			loader.content.width = w; 
			loader.content.height = h;
				
			loader.content.alpha = a + .5; 
			var degree:Number = angle * (180/Math.PI); 
			if(degree  >= 90)
			{
				addTouchEvents();
				removeEventListener(Event.ENTER_FRAME, onShowImageEnterFrame)
			}
	 	}
		
		private function onIOError(event:IOErrorEvent):void
		{
			trace("IOERROR on Loader");
		}
		

	}
}