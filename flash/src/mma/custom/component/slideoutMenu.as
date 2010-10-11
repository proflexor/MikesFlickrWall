package mma.custom.component
{
	import flash.display.Graphics;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.Timer;
	
	public class slideoutMenu extends MovieClip
	{
		private var _title:String;
		private var slideClosed:Boolean = true;
		private var slideButton:Sprite;
		
		private var slideoutTimer:Timer;
		private var slideoutLength:Number = 360;
		private var slideoutDist:Number = 0;

		private var elements:Sprite;
		
		[Embed(source="/asset/flash/ImageWallAsset.swf", symbol="ResizeIcon")]
		private var ResizeBtn:Class; 	
		
		public function slideoutMenu()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage); 
		}
		
		public function get title():String
		{
			return _title;
		}
		
		public function set title(val:String):void
		{
			_title = val;
		}
		
		private function onAddedToStage(event:Event):void
		{
			graphics.lineStyle(2, 0xefefef, 1);
			graphics.beginFill(0x333333, 1); 
			graphics.drawRect(0, 0, 40, 300); 
			graphics.endFill();
			
			slideButton = new ResizeBtn();
			slideButton.buttonMode = true;
			slideButton.addEventListener(TouchEvent.TOUCH_TAP, slideOut);
			slideButton.transform.matrix = new Matrix(1, 0, 0, 1, 0, 150 - slideButton.height/2);
			this.addChild(slideButton);
			
			elements = new Sprite();
			this.addChild(elements);
		}
		
		private function slideOut(event:TouchEvent):void
		{
			slideoutTimer = new Timer(10);
			slideoutTimer.addEventListener(TimerEvent.TIMER, adjustSize);
			slideoutTimer.start();
		}	
	
		private function adjustSize(event:TimerEvent):void
		{
			if(slideoutDist < slideoutLength){
				slideoutDist+=10;
				graphics.lineStyle(2, 0xefefef, 1);
				graphics.beginFill(0x333333, 1); 
				graphics.drawRect(0, 0, 40 + slideoutDist, 300); 
				graphics.endFill();
			}else{
				slideoutTimer.stop();
				slideoutTimer = null;
				
				showElements();
			}
		}

		private function showElements():void
		{
			var ss:StyleSheet = new StyleSheet();
			var styleObj:Object = new Object();
			styleObj.fontWeight = "bold";
			styleObj.color = "#efefef";
			styleObj.fontSize = "20";
			styleObj.fontFamily = "Arial";
			
			ss.setStyle(".defStyle", styleObj);
			
			var intxt:TextField  = new TextField();
			intxt.width = 200;
			intxt.height = 24;
			intxt.border = true;
			intxt.type = TextFieldType.INPUT;
			
			var lbl:TextField = new TextField();
			lbl.text = "Search";
			lbl.styleSheet = ss;
			
			addChild(lbl);
			addChild(intxt);
			
			lbl.x = 40;
			lbl.y = 10;
			
			intxt.x = 45 + lbl.width;
			intxt.y = 10;
		}
	}
}