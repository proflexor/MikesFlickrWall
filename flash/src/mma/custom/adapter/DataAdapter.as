package mma.custom.adapter
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.events.CollectionEventKind;
	
	public class DataAdapter extends EventDispatcher
	{
		
	 	private var _items:ArrayCollection; 
		
		public function DataAdapter(ac:ArrayCollection)
		{
			this._items = ac;
			this._items.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);  
		}
		private function onCollectionChanged(event:CollectionEvent):void
		{
			switch(event.kind)
			{
				case CollectionEventKind.ADD:
					var addEvent:Event = new Event("AddedImage"); 
					dispatchEvent(addEvent); 
					break; 
				case CollectionEventKind.REFRESH:
					var refreshEvent:Event = new Event("RefreshItems"); 
					dispatchEvent(refreshEvent); 
					break; 
				
			}
		}
		public function get items():ArrayCollection
		{
			return _items; 
		}
		public function set items(value:ArrayCollection):void
		{
			_items = value; 
			this._items.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChanged);  	
		} 
	}
}