package mma.view.item
{
	import com.adobe.cairngorm.model.ModelLocator;
	
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import mma.custom.event.StringEvent;
	import mma.data.flickr.PhotoData;
	import mma.model.FlickrModel;
	import mma.model.ModelLocator;
	import mma.model.TouchPoint;
	
	import mx.utils.UIDUtil;

	public class RotatableScalable extends Sprite
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
		private var container:Sprite;
		private var imgContainer:Sprite;
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
		
		private var widthRatio:Number; 
		
		private var closeBtn:Sprite; 
		
		[Embed(source="/asset/flash/ImageWallAsset.swf", symbol="CloseBtn")]
		public var CloseBtn:Class; 
		
		// ------- Public properties -------
		
		// ------- Private methods -------
		
		private function addTouchPoint(touchPoint:TouchPoint):void
		{
			for(var i:int = 0; i < touchPoints.length; i++)
			{
				if(touchPoints[i].ID == touchPoint.ID)
				{
					return;
				}
			}
			
			touchPoints.push(touchPoint);
			
			if(touchPoints.length == 1)
			{
				state = DRAGGING;
				touchPoint1 = touchPoints[0];
			}
			
			else if(touchPoints.length > 1)
			{
				state = ROTATE_SCALE;
				touchPoint1 = touchPoints[0];
				touchPoint2 = touchPoints[1];
			}
		}
			
		private function removeTouchPoint(id:int):void
		{
			for(var i:int =0; i < touchPoints.length; i++)
			{
				if(touchPoints[i].ID == id)
				{
					touchPoints.splice(i,1);
					if(touchPoints.length == 0)
					{
						touchPoint1 = null;
						touchPoint2 = null;
						state = NONE;
					}
					
					if(touchPoints.length == 1)
					{
						state = DRAGGING;
						touchPoint1 = touchPoints[0];
						touchPoint2 = null;
						trace(touchPoints);
					}
					
					if(touchPoints.length >= 2)
					{
						state = ROTATE_SCALE;
						touchPoint1 = touchPoints[0];
						touchPoint2 = touchPoints[1];
						
						trace("AFTER REMOVE:");
						trace("touch1: " + touchPoints[0]);
						trace("touch2: " + touchPoints[1]);
						
					}
					return;
				}
			}
			return;
		}
		
		private function addTouchEvents():void
		{
			photoData.showThumb = false; 
			
			closeBtn.x = loader.content.width + 25; 
			closeBtn.y = - 25;
			container.addChild(closeBtn); 
			
			closeBtn.addEventListener(TouchEvent.TOUCH_BEGIN, onCloseHandler);
			
			loader.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin, false, 0, true);
			loader.addEventListener(TouchEvent.TOUCH_END, onTouchEnd, false, 0, true);
			loader.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove, false, 0, true);
			
			container.transform.matrix  = 
				new Matrix(1, 0, 0, 1, -width/2,
					-height/2);
			
			this.x = this.x + width/2; 
			this.y = this.y + height/2; 
		}
		
		protected function getAngleTrig(X:Number, Y:Number):Number
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
			event.stopImmediatePropagation();
			
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			
			container = new Sprite(); 
			addChild(container);
			
			loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load(new URLRequest(photoData.large.source)); 
			
			closeBtn = new CloseBtn();
			closeBtn.buttonMode = true;
		}

		private function onCloseHandler(event:TouchEvent):void
		{
			var model:mma.model.ModelLocator = mma.model.ModelLocator.getInstance();
			model.flickrModel.isClosing = true;
			event.stopImmediatePropagation();
			
			closeBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, onCloseHandler);
			
			loader.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); 
			loader.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd); 
			
			trace("close LargePictureItem");
			photoData.showThumb = true; 
			var e:StringEvent = new StringEvent("RemoveLargeImage", this.guid); 
			dispatchEvent(e);
			trace(e);	
		}
		
		private function onLoaderComplete(event:Event):void
		{
			event.stopImmediatePropagation(); 
			
			loader.visible = false; 
			
			maxW = loader.content.width; 
			maxH = loader.content.height;
			
			widthRatio = loader.content.width/loader.content.height;
			
			loader.content.width = loader.content.width/2; 
			loader.content.height = loader.content.height/2;
			
			minW = loader.content.width; 
			minH = loader.content.height; 
			
			destWidth = loader.content.width; 
			destHeight = loader.content.height; 

			imgContainer = new Sprite();
			imgContainer.graphics.beginFill(0xefefef, 1);
			imgContainer.graphics.drawRect(0, 0, loader.content.width + 30, loader.content.height + 30);
			imgContainer.graphics.endFill();
			
			imgContainer.addChild(loader);
			loader.transform.matrix = new Matrix(1, 0, 0, 1, imgContainer.width/2 - loader.content.width/2, imgContainer.height/2 - loader.content.height/2);
			
			container.addChild(imgContainer);
			
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
				this.x += (touchPoint1.x  - startX); 
				this.y += (touchPoint1.y  - startY); 
			}
			startX = touchPoint1.x; 
			startY = touchPoint1.y;
			
		}
		
		private function onRotateEnterFrame(event:Event):void
		{
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
			trace(ratio);
			
			var tempR:Number = this.rotation; 
			this.rotation = 0; 
			
			var newW:Number = bW * ratio; 
			var newH:Number = bH * ratio;
			
			if(newW < maxW && newW > minW)
			{
				loader.content.width = newW; 
				loader.content.height = newH;
				
				closeBtn.x = loader.content.width - 25; 
				closeBtn.y = - 25;
				
				this.container.width = loader.content.width; 
				this.width = loader.content.width; 
				
				this.container.height = loader.content.height; 
				this.height = loader.content.height; 
				
				container.transform.matrix  = 
					new Matrix(1, 0, 0, 1, -width/2,
						-height/2); 
				
			}
			
			var angle:Number = getAngleTrig(curAngle.x, curAngle.y);
			if(Math.abs(angle - firstAngle) > 2)
			{
				trace("rotation displacement: "  + (angle - firstAngle));
			}
			this.rotation = tempR + angle - firstAngle;
			firstAngle = angle;
		}
		
		// ------- Touch event handlers -------
		
		private function onTouchBegin(event:TouchEvent):void
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
			
			loader.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			loader.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); 
			
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

		}
		// ------- Overriden methods -------
	}
}