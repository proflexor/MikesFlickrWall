package {
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.ui.Keyboard;
	import flash.utils.Timer;4
	import mma.custom.effect.Ripple;
	import mma.view.main.Canvas;
	
	import tuio.flash.events.*;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	public class FlickrWall extends Sprite
	{
		private var timer:Timer; 
		
		public function FlickrWall()
		{
			//TUIO.init(this,"localhost",3000,"",true);
			draw(); 
			Multitouch.inputMode=MultitouchInputMode.TOUCH_POINT;
			stage.nativeWindow.visible = true;
			stage.align = StageAlign.TOP_LEFT;
			stage.displayState = StageDisplayState.FULL_SCREEN; 
			stage.scaleMode = StageScaleMode.NO_SCALE; 
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
			
		}
		private function handleKeyDown(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ESCAPE)
			{
				this.stage.nativeWindow.close();
			}
		}
		private function onAddedToStage(event:Event):void
		{
			var canvas:Canvas = new Canvas(); 
			addChild(canvas);
			//addEventListener(MouseEvent.MOUSE_DOWN, onMDHandler);
		}
		private function onMDHandler(event:MouseEvent):void
		{
			event.stopImmediatePropagation(); 
			
			var e:Ripple = new Ripple(this); 
			e.radius = 80; 
			e.durationInFrames = 60; 
			e.amplitude = 40; 
			e.rippleIt(new Point(this.mouseX, this.mouseY));  
			
			timer = new Timer(100, 2); 
			timer.addEventListener(TimerEvent.TIMER, onRippleAgainHandler); 
			timer.start();
		}
		private function onRippleAgainHandler(event:TimerEvent):void
		{
			var rippleObject:Ripple = new Ripple(this)
			rippleObject.radius = 80; 
			rippleObject.durationInFrames = 60 + timer.currentCount * 5; 
			rippleObject.amplitude = 40 - timer.currentCount * 5; 
			rippleObject.rippleIt(new Point(this.mouseX, this.mouseY))
		}
		public function draw():void
		{
			var g:Graphics = this.graphics; 
			g.lineStyle(0, 0x9f9f9f,0); 
			g.beginFill(0x000000, 1); 
			g.drawRect(0, 0, 1920, 1080);
			//g.drawRect(0, 0, 2560, 1440); 
			g.endFill();
		}
	}
}
/* function doRipple(event:MouseEvent) 
{
//	if (event.buttonDown)
	//{
		trace("M coic?"); 
		var rippleObject = new Ripple(this)
		
		rippleObject.radius = 80; 
		rippleObject.durationInFrames = 60; 
		rippleObject.amplitude = 40; 
		
		rippleObject.rippleIt(new Point(this.mouseX, this.mouseY))
		
		timer = new Timer(100, 2); 
		timer.addEventListener(TimerEvent.TIMER, onRippleAgainHandler); 
		timer.start();
//	}
}
function onRippleAgainHandler(event:TimerEvent):void
{
	var rippleObject = new Ripple(this)
	rippleObject.radius = 80; 
	rippleObject.durationInFrames = 60 + timer.currentCount * 5; 
	rippleObject.amplitude = 40 - timer.currentCount * 5; 
	rippleObject.rippleIt(new Point(this.mouseX, this.mouseY))
} */


