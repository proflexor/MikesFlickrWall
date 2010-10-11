package mma.view.item
{
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	
	import flashx.textLayout.operations.CutOperation;
	
	import gl.events.GestureEvent;
	import gl.events.TouchEvent;
	
	import id.core.TouchSprite;
	
	import mma.custom.event.StringEvent;
	import mma.data.flickr.PhotoData;
	import mma.model.FlickrModel;
	import mma.model.ModelLocator;
	import mma.model.TouchPoint;
	
	import mx.utils.UIDUtil;
	
	
	public class LargePictureItem extends TouchSprite
	{
		private static const GRAD_PI:Number = 180/Math.PI;
		
		private static const NONE:String = "none";
		private static const DRAGGING:String = "dragging";
		private static const ROTATE_SCALE:String = "rotateScale";
		
		private var blobs: Array = [];
		
		private var blob1:Object;
		private var blob2:Object;
		
		private var pointMap:Object = {};
		
		private var state:String;
		
		private var photoData:PhotoData; 
		public var guid:String; 
		private var container:TouchSprite;
		private var loader:Loader; 
		//animation vars.
		private var angle:Number = 0;
		private var speed:Number = 0.2; 
		private var destWidth:Number;
		private var destHeight:Number;   
		
		private var rotateX:Number; 
		private var rotateY:Number; 
		private var startX:Number; 
		private var startY:Number; 
		
		private var startW:Number; 
		private var startH:Number; 
		private var closeXpos:Number; 
		private var closeYpos:Number; 
		
		private var secondTID:String; 
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
		
		private var resizeBtn:Sprite; 
		private var closeBtn:TouchSprite; 
		
		private var resizeButtonTouched:Boolean = false;
		
		[Embed(source="/asset/flash/ImageWallAsset.swf", symbol="CloseBtn")]
		public var CloseBtn:Class; 
		
		[Embed(source="/asset/flash/ImageWallAsset.swf", symbol="ResizeIcon")]
		public var ResizeBtn:Class; 
		
		
		
		public function LargePictureItem(d:PhotoData)
		{
			photoData = d; 	
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStaged); 
			guid = UIDUtil.createUID(); 
			
		}
		private function onAddedToStaged(event:Event):void
		{
			event.stopImmediatePropagation(); 
			
			state = NONE;
			
			container = new Sprite(); 
			addChild(container);
			
			loader = new Loader(); 
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			loader.load(new URLRequest(photoData.large.source)); 
			
			closeBtn = new CloseBtn();
			closeBtn.buttonMode = true;
			
			resizeBtn = new ResizeBtn(); 
			resizeBtn.buttonMode = true;
			//closeBtn.visible = false; 
		}
		
		private function addTouchEvent():void
		{
			photoData.showThumb = false; 
			
			closeBtn.x = loader.content.width - 25; 
			closeBtn.y = - 25;
			container.addChild(closeBtn); 
			
			resizeBtn.x = loader.content.width - 25; 
			resizeBtn.y = loader.content.height - 25;
			container.addChild(resizeBtn); 
			
			this.blobContainerEnabled = true;
			
			closeBtn.addEventListener(TouchEvent.TOUCH_TAP, onCloseHandler);
//			resizeBtn.addEventListener(TouchEvent.TOUCH_BEGIN, onResizeHandler);
//			resizeBtn.addEventListener(TouchEvent.TOUCH_END, onTouchUpHandler);
			
//			loader.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler);
//			loader.addEventListener(TouchEvent.TOUCH_END, onTouchUpHandler);
			
//			addEventListener(TouchEvent.TOUCH_MOVE, onTouchMoveHandler);
			
			loader.addEventListener(TouchEvent.TOUCH_DOWN, startDrag_Press);
			loader.addEventListener(TouchEvent.TOUCH_UP, stopDrag_Release);
			loader.addEventListener(GestureEvent.GESTURE_ROTATE, gestureRotateHandler);
			loader.addEventListener(GestureEvent.GESTURE_SCALE, gestureScaleHandler);
			
			container.transform.matrix  = 
				new Matrix(1, 0, 0, 1, -width/2,
					 -height/2);
			
			this.x = this.x + width/2; 
			this.y = this.y + height/2;
			trace("x: " + x);
			trace("y: " + y);
			trace("width: " + width);
			trace("height: " + height);
		}		
		
		private function addBlob(id:int, originX:Number, originY:Number):void
		{
			for(var i:int = 0; i < blobs.length; i++)
			{
				if(blobs[i].id == id)
				{
					if(blobs.length == 1)
					{
						blob1 = blobs[i];
						delete pointMap[blob2.id];
						blob2 = null;
					}
					else(blobs. length == 2)
					{
						blob1 = blobs[0];
						blob2 = blobs[1];
					}
					return;
				}
				
			}
			
			blobs.push({id:id, originX:originX, originY:originY, myOriginX:this.x, myOriginY:this.y});
			
			if(blobs.length == 1)
			{
				state = DRAGGING;
				blob1 = blobs[0];
			}
				
			else if(blobs.length == 2)
			{
				state = ROTATE_SCALE;
				blob1 = blobs[0];
				blob2 = blobs[1];
				
				var tObject1:Object = pointMap[blob1.id];
				var tObject2:Object = pointMap[blob2.id];
				
				
				if(tObject1)
				{
					var curP1:Point = (new Point(tObject1.x, tObject1.y));
					blob1.originX = curP1.x;
					blob1.originY = curP1.y;
				}
			}
		}
		
		private function removeBlob(id:int):void
		{
			trace("removeBlob");
			for(var i:int=0; i<blobs.length; i++)
			{
				if(blobs[i].id == id)
				{
					blobs.splice(i, 1);
					
					if(blobs.length == 0)
					{
						state = NONE;
						showBorder();
					}
						
						
					if(blobs.length == 1)
					{
						state = DRAGGING;                    
						blob1 = blobs[0];
						delete pointMap[blob2.id];
						blob2 = null;
						
					}
					if(blobs.length >= 2) {
						state = ROTATE_SCALE;
						
						blob1 = blobs[0];                                
						blob2 = blobs[1];        
						
					}
					return;                    
				}
			}            
		}

		
		private function onCloseHandler(event:TouchEvent):void
		{
			var flickrModel:FlickrModel = ModelLocator.getInstance().flickrModel;
			flickrModel.isClosing = true;
			event.stopImmediatePropagation();
			
			closeBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, onCloseHandler);
			
//			resizeBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, onResizeHandler);
//			loader.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler); 
//			loader.removeEventListener(TouchEvent.TOUCH_END, onTouchUpHandler); 
			
			trace("close LargePictureItem");
			photoData.showThumb = true; 
			var e:StringEvent = new StringEvent("RemoveLargeImage", this.guid); 
			dispatchEvent(e);
			trace(e);	
		}

		private function onTouchMoveHandler(event:TouchEvent):void
		{
			var p:Point = new Point(event.stageX, event.stageY);
			var cntr:Point = new Point(this.x, this.y);
			var radius:Number = Math.sqrt((this.height*this.height + this.width*this.width))/4;
			//trace(radius + "," + Point.distance(p, cntr));
			//trace("MoveTest: " + (Point.distance(p, cntr) > (radius + 20)));
			if(Point.distance(p, cntr) > (radius + 20))
			{
				removeBlob(event.touchPointID);
				return;
			}
			else
			{
				if(event.stageX == 0 && event.stageY == 0)
				{
					p = new Point(event.localX, event.localY);
				}
				else
				{
					p = new Point(event.stageX, event.stageY);
	
				}
				if ( pointMap[ event.touchPointID.toString() ] )
				{
					pointMap[ event.touchPointID.toString() ].x = p.x;
					pointMap[ event.touchPointID.toString() ].y = p.y;
				}
			}
			
			


		}
		
		private function onTouchDownHandler(event:TouchEvent):void
		{
			var p:Point;
			if(event.stageX == 0 && event.stageY == 0)
			{
				p = new Point(event.localX, event.localY);
			}
			else
			{
				p = new Point(event.stageX, event.stageY);
			}
			trace(p);
			pointMap[event.touchPointID.toString()] = p;
			addBlob(event.touchPointID, p.x, p.y);
			trace("TouchDown State: " + state + " with " + blobs.length);
			resizeButtonTouched = false;
			if(state == DRAGGING)
			{
				trace("touchDown : 1, ID: " + event.touchPointID);
				trace(blobs[0].id);
				removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame); 				
				removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler); 				
				addEventListener(Event.ENTER_FRAME, onEnterFrameHandler); 				
				var pt:Point = p;
				startX = pt.x;				
				startY = pt.y;				
				closeBtn.visible = false;
			}
			if(state == ROTATE_SCALE)
			{
				
				trace("touchDown : 2, ID: " + blobs[0].id + blobs[1].id);
				removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler); 
				removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame); 
				addEventListener(Event.ENTER_FRAME, onRotateEnterFrame);
				
				if(!blob1)
				{
					removeBlob(blob1.id);
					return;
				}
				
				var curPt:Point = (new Point(blob1.x, blob1.y));
				
				if(!blob2)
				{
					removeBlob(blob2.id);
					return;				
				}
				
				var curPt2:Point = (new Point(blob2.x, blob2.y));
				
				startD = Point.distance(curPt, curPt2); 
				startCenter = Point.interpolate(curPt, curPt2, 0.5);
				//var dx:Number = touchPoint1.x - touchPoint2.x;
				//var dy:Number = touchPoint1.y - touchPoint2.y;
				
				var dx:Number ,dy:Number;
				
				bW = loader.content.width; 
				bH = loader.content.height; 
				
				var origAngle:Point = curPt.subtract(curPt2);
				firstAngle = getAngleTrig(origAngle.x, origAngle.y);
				
			}
			
			
		}
		
		
		private function onRotateEnterFrame(event:Event):void
		{
			if(state != ROTATE_SCALE)
			{
				return;
			}
			

			if(!blob1|| !blob2)
			{
				removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame);
				return;
			}
			var ptn:Point = (new Point(blob1.x, blob1.y));
			
			
			var ptn2:Point = (new Point(blob2.x, blob2.y));
			
			var ctr:Point = Point.interpolate(ptn, ptn2, 0.5);
			
			if(Point.distance(ctr, startCenter) > 0 )
			{
				this.x += ctr.x - startCenter.x;
				this.y += ctr.y - startCenter.y;
				startCenter = ctr;
			}

			var curAngle:Point = ptn.subtract(ptn2);
			var dis:Number = Point.distance(ptn, ptn2); 
			var ratio:Number = dis / startD;
			
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
				
				resizeBtn.x = loader.content.width - 25; 
				resizeBtn.y = loader.content.height - 25;
				
				
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
				trace(ptn);
				trace(ptn2);
			}
			this.rotation = tempR + angle - firstAngle;
			firstAngle = angle;
 		}
		
		private function onEnterFrameHandler(event:Event):void
		{
			var r:Rectangle = new Rectangle(0, 0, 2560, 1460); 
			var ptn:Point = (new Point(blob1.x, blob1.y));
			/*trace(ptn);
			trace(this.x);
			trace(this.y);*/
			//trace(r.contains(touchPoint1.x, touchPoint1.y));
			if(r.contains(ptn.x, ptn.y))
			{
				this.x += (ptn.x  - startX); 
				this.y += (ptn.y  - startY); 
			}
			startX = ptn.x; 
			startY = ptn.y;
		
		}
		private function onTouchUpHandler(event:TouchEvent):void
		{
			removeBlob(event.touchPointID);
			delete pointMap[event.touchPointID.toString()];
			
			loader.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler);
			loader.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchDownHandler); 
			
			removeEventListener(Event.ENTER_FRAME, onRotateEnterFrame);
//			removeEventListener(Event.ENTER_FRAME, onResizeEnterFrame);
			removeEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			
			
//			resizeBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, onResizeHandler);
//			resizeBtn.addEventListener(TouchEvent.TOUCH_BEGIN, onResizeHandler);
			//addEventListener(TouchEvent.TOUCH_END, onTouchUpHandler);
			
			
			if(state == NONE)
			{
				showBorder();
			}
			if(state == DRAGGING && blobs.length == 1)
			{
				var pt:Point = new Point(blob1.originX, blob1.originY);
				//trace("ptpt:"+pt);
				//trace(blob1.originX, blob1.originY);
				trace("before taking finger off: " + x +", " + y); 
				startX = pt.x;				
				startY = pt.y;
				addEventListener(Event.ENTER_FRAME, onEnterFrameHandler);
			}
			trace("TouchUp State: " + state + " with " + blobs.length);
		}
	
		private function onLoaderComplete(event:Event):void
		{
			event.stopImmediatePropagation(); 
			container.addChild(loader); 
			loader.visible = false; 
			
			maxW = loader.content.width; 
			maxH = loader.content.height;
			trace("maximum dimension: "+ maxW + ", "+ maxH);

			widthRatio = loader.content.width/loader.content.height; 
			
			loader.content.width = loader.content.width/2; 
			loader.content.height = loader.content.height/2;
			
			minW = loader.content.width; 
			minH = loader.content.height; 
			
			destWidth = loader.content.width; 
			destHeight = loader.content.height; 
			loader.content.width = 75; 
			loader.content.height = 75; 
		
			var drop:DropShadowFilter = new DropShadowFilter(15, 0, 0xefefef, 1, 0, 0, 7.0); 
			var drop2:DropShadowFilter = new DropShadowFilter(15, 90, 0xefefef, 1, 0, 0, 7.0); 
			var drop3:DropShadowFilter = new DropShadowFilter(15, 180, 0xefefef, 1, 0, 0, 7.0); 
			var drop4:DropShadowFilter = new DropShadowFilter(15, 270, 0xefefef, 1, 0, 0, 7.0); 
			var ary:Array = []; 
			ary.push(drop); 
			ary.push(drop2); 
			ary.push(drop3); 
			ary.push(drop4); 
			loader.filters = ary; 
			removeEventListener(Event.ENTER_FRAME, onShowImageEnterFrame)
			addEventListener(Event.ENTER_FRAME, onShowImageEnterFrame)
			
			loader.visible = true;
		}

		private function showBorder():void
		{
			closeBtn.visible = true; 
		}

		private function hideBorder():void
		{
			closeBtn.visible = false;
			
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
				
				removeEventListener(Event.ENTER_FRAME, onShowImageEnterFrame)
				addTouchEvent(); 
			}
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
	}
	
}