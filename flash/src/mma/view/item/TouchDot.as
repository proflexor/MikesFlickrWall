package mma.view.item
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TouchDot extends Sprite
	{
		// ------- Child elements -------
		private var _touchPointIDField:TextField;
		private var _textFormat:TextFormat;
		
		// ------- Constructor -------
		public function TouchDot()
		{
			super();
			addEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
		}
		
		// ------- Private vars -------
		
		// ------- Public properties -------
		private var _id:int;
		public function get ID():int
		{
			return _id;
		}
		
		public function set ID(value:int):void
		{
			_id = value;
			if (_touchPointIDField != null)
				_touchPointIDField.text = _id.toString();
		}
		
		// ------- Private methods -------
		
		// ------- Public functions -------
		
		// ------- Event handling -------
		
		private function _onAddedToStage(event:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _onAddedToStage);
			_textFormat = new TextFormat();
			_textFormat.font = "_sans";
			_textFormat.size = 14;
			_textFormat.bold = true;
			
			
			_touchPointIDField = new TextField();
			_touchPointIDField.height = 22;
			_touchPointIDField.autoSize = TextFieldAutoSize.CENTER;
			_touchPointIDField.text = _id.toString();
			_touchPointIDField.setTextFormat(_textFormat);
			_touchPointIDField.selectable = false;
			
			graphics.beginFill(0xAAAAAA, 0.9);
			graphics.drawCircle(0,0,20);
			graphics.endFill();
			addChild(_touchPointIDField);
			_touchPointIDField.x = (0 - _touchPointIDField.width) / 2;
			_touchPointIDField.y = (0 - _touchPointIDField.height) / 2;
			
			mouseEnabled = false;
			mouseChildren = false;

		}
		
		// ------- Overriden methods -------
	}
}