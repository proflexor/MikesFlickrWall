package mma.view.item
{
	import com.adobe.cairngorm.model.ModelLocator;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
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
			state = NONE;
			touchPoints = new Vector.<TouchPoint>();
			
			photoData = d; 	
			guid = UIDUtil.createUID(); 
			
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		// ------- Private vars -------
		
		private var photoData:PhotoData; 
		public var guid:String; 
		//private var container:Sprite;
		//private var imgContainer:Sprite;
		private var loader:Loader; 
		
		//animation vars.
		private var angle:Number = 0;
		private var speed:Number = 0.2; 
		private var destWidth:Number;
		private var destHeight:Number;
		
		//States
		private static const NONE:String = "none";
		private static const DRAGGING:String = "dragging";
		private static const ROTATE_SCALE:String = "rotateScale";
		
		private static const GRAD_PI:Number = 180/Math.PI;
		private static const HALF:Number = 0.5;
		
		private var touchPoints: Vector.<TouchPoint>;
		
		private var touchPoint1:TouchPoint;
		private var touchPoint2:TouchPoint;
		
		private var state:String;
		
		private var rotateX:Number; 
		private var rotateY:Number; 
		private var startX:Number; 
		private var startY:Number; 
		
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
		private var startD:Number;
		private var startCenter:Point;
		
		public var widthRatio:Number; 
		
		private var closeBtn:TouchSprite = new TouchSprite(); 
		
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
			trace("draw background and width is " + loader.content.width + " while the status is " + _scaleStatus);
		}
		
		// ------- Private methods -------
		

		private function addTouchEvents():void
		{
			trace("addTouchEvents()");
			photoData.showThumb = false; 
			
			closeBtn.x = width - 25; 
			closeBtn.y = -25;
			addChild(closeBtn); 
			
			closeBtn.addEventListener(TouchEvent.TOUCH_TAP, onCloseHandler);
	
			this.transform.matrix  = new Matrix(1, 0, 0, 1, -width/2, -height/2);
			
			this.x = photoData.xpos; 
			this.y = photoData.ypos;
			trace("recalculate x & y");
			
			drawBorder(0);			
		}
		
		
		
		/*protected function getAngleTrig(X:Number, Y:Number):Number
		{
			if (X == 0.0)
			{
				if(Y < 0.0)
					return 270;
				else
					return 90;
			} else if (Y == 0)
			{
				if(X < 0)
					return 180;
				else
					return 0;
			}
			
			if ( Y > 0.0)	
			{
				if (X > 0.0)
					return Math.atan(Y/X) * GRAD_PI;
				else
					return 180.0-Math.atan(Y/-X) * GRAD_PI;
			}
			else
				if (X > 0.0)
					return 360.0-Math.atan(-Y/X) * GRAD_PI;
				else
					return 180.0+Math.atan(-Y/-X) * GRAD_PI;
			
		}*/
		
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

		private function onCloseHandler(event:TouchEvent):void
		{
			event.stopImmediatePropagation();
			
			var model:mma.model.ModelLocator = mma.model.ModelLocator.getInstance();
			model.flickrModel.isClosing = true;
			event.stopImmediatePropagation();
			
			closeBtn.removeEventListener(TouchEvent.TOUCH_TAP, onCloseHandler);
			
			/*loader.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); 
			loader.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);*/ 
			
			trace("close LargePictureItem");
			photoData.showThumb = true; 
			var e:StringEvent = new StringEvent("RemoveLargeImage", this.guid); 
			dispatchEvent(e);
			trace(e);	
		}
		
		private function onLoaderComplete(event:Event):void
		{
			trace("onLoaderComplete()");
			event.stopImmediatePropagation(); 
			
			loader.visible = false; 
			
			maxW = loader.content.width; 
			
			widthRatio = loader.content.width/loader.content.height;
			
			loader.content.width = loader.content.width/2; 
			loader.content.height = loader.content.height/2;
			
			minW = loader.content.width; 
			
			destWidth = loader.content.width; 
			destHeight = loader.content.height; 
			trace("loader calculations performed");
			
			addChild(loader);
			
			loader.content.width = 75; 
			loader.content.height = 75; 
			
			var drop:DropShadowFilter = new DropShadowFilter(15, 45, 0x000000, .7, 15, 15); 
			var drop2:DropShadowFilter = new DropShadowFilter(15, -135, 0x000000, .7, 15, 15); 

			var ary:Array = []; 
			ary.push(drop); 
			ary.push(drop2); 
			this.filters = ary; 
			removeEventListener(Event.ENTER_FRAME, onShowImageEnterFrame)
			addEventListener(Event.ENTER_FRAME, onShowImageEnterFrame)
			
			loader.visible = true;
			trace("loader set to visible");		
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
		
		private function onMoveEnterFrame(event:Event):void
		{
			if(touchPoints.length > 1 || touchPoint1 == null)
			{
				removeEventListener(Event.ENTER_FRAME, onMoveEnterFrame);
			}
			var r:Rectangle = new Rectangle(0, 0, 2560, 1460); 
			if(r.contains(touchPoint1.x, touchPoint1.y))
			{
				trace("recalculate image points from touch points");
				this.x += (touchPoint1.x  - startX); 
				this.y += (touchPoint1.y  - startY); 
			}
			startX = touchPoint1.x; 
			startY = touchPoint1.y;
			
		}
		
/*		private function onRotateEnterFrame(event:Event):void
		{
			trace("onRotateEnterFrame()");
			if(state != ROTATE_SCALE)
			{
				return;
			}
			
			var ctr:Point = Point.interpolate(touchPoint1, touchPoint2, 0.5);
			
			if(Point.distance(ctr, startCenter) > 0 )
			{
				this.x += ctr.x - startCenter.x;
				this.y += ctr.y - startCenter.y;
				startCenter = ctr;
			}
			
			var curAngle:Point = touchPoint1.subtract(touchPoint2);
			var dis:Number = Point.distance(touchPoint1, touchPoint2); 
			var ratio:Number = dis / startD;
			trace("Ratio: " + ratio);
			
			var tempR:Number = this.rotation; 
			this.rotation = 0; 
			
			var newW:Number = bW * ratio; 
			var newH:Number = bH * ratio;
			
			var posX:Number = startX - newW/2;
			var posY:Number = startY - newH/2;
			
			if(newW < maxW && newW > minW)
			{
				loader.content.width = newW; 
				loader.content.height = newH;
				
				closeBtn.x = startX - newW/2; 
				closeBtn.y = startY - newH/2 - 25;
				
				loader.width = newW; 
				width = newW+100; 
				
				loader.height = newH; 
				height = newH+100;
				
				this.transform.matrix  = 
					new Matrix(1, 0, 0, 1, posX, posY); 
				
			}
			
			drawBorder();
			
			var angle:Number = getAngleTrig(curAngle.x, curAngle.y);
			if(Math.abs(angle - firstAngle) > 2)
			{
				trace("rotation displacement: "  + (angle - firstAngle));
			}
			this.rotation = tempR + angle - firstAngle;
			firstAngle = angle;
		}*/
		
		// ------- Touch event handlers -------
		
/*		private function onTouchBegin(event:TouchEvent):void
		{
			addTouchPoint(new TouchPoint(event.stageX, event.stageY, event.touchPointID));
			var e:StringEvent = new StringEvent("SetIndexImage", this.guid); 
			dispatchEvent(e);
			if(state == DRAGGING)
			{
				trace("touchDown : 1, ID: " + event.touchPointID);
				trace(touchPoint1.ID == touchPoints[0].ID);
				removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame); 				
				removeEventListener(Event.ENTER_FRAME, onMoveEnterFrame); 				
				addEventListener(Event.ENTER_FRAME, onMoveEnterFrame); 				
				startX = event.stageX;				
				startY = event.stageY;				
				hideBorder();
			}
			else if(state == ROTATE_SCALE)
			{
				trace("touchDown : 2, ID: " + touchPoint1.ID + ", "+ touchPoint2.ID);
				removeEventListener(Event.ENTER_FRAME, onMoveEnterFrame); 
				removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame); 
				addEventListener(Event.ENTER_FRAME, onRotateEnterFrame);
				startX = event.stageX;				
				startY = event.stageY;					
				startD = TouchPoint.distance(touchPoint1, touchPoint2); 
				startCenter = Point.interpolate(touchPoint1, touchPoint2, 0.5);
				//var dx:Number = touchPoint1.x - touchPoint2.x;
				//var dy:Number = touchPoint1.y - touchPoint2.y;
				
				bW = loader.content.width; 
				bH = loader.content.height; 
				
				var origAngle:Point = touchPoint1.subtract(touchPoint2);
				firstAngle = getAngleTrig(origAngle.x, origAngle.y);
			}
		}
		
		private function onTouchEnd(event:TouchEvent):void
		{
			trace("Removed TouchPointID: " + event.touchPointID);
			removeTouchPoint(event.touchPointID);
			
			//loader.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			//loader.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); 
			
			removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame);
			removeEventListener(Event.ENTER_FRAME, onMoveEnterFrame);
			
			if(state == NONE)
			{
				showBorder();
			}
			if(state == DRAGGING && touchPoints.length == 1)
			{
				trace("before taking finger off: " + x +", " + y); 
				startX = touchPoint1.x;				
				startY = touchPoint1.y;
				addEventListener(Event.ENTER_FRAME, onMoveEnterFrame);
			}
			trace("TouchUp State: " + state + " with " + touchPoints.length);
		}
		
		private function onTouchMove(event:TouchEvent):void
		{
			if(state == ROTATE_SCALE)
			{
				trace("MOVE TEST: "+ (touchPoint2 == touchPoints[1]));	
			}
			
			var touchPoint:TouchPoint = new TouchPoint(event.stageX, event.stageY, event.touchPointID);
			if(this.hitTestPoint(touchPoint.x, touchPoint.y))
			{
				trace("Move state: " + state);
				if(touchPoint1 && event.touchPointID == touchPoint1.ID)
				{
					touchPoints[0].x = event.stageX;
					touchPoints[0].y = event.stageY;
					touchPoint1 = touchPoints[0];
				}
				else if(touchPoints.length > 1 && event.touchPointID == touchPoint2.ID)
				{
					touchPoints[1].x = event.stageX;
					touchPoints[1].y = event.stageY;
					touchPoint2 = touchPoints[1];
				}
			}
			else
			{
				removeTouchPoint(touchPoint.ID);
				return;
			}

		}*/
		// ------- Overriden methods -------
	}
}