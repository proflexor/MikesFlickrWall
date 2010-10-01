package mma.model
{
	import com.adobe.cairngorm.model.ModelLocator; 
	     
	public class ModelLocator implements com.adobe.cairngorm.model.ModelLocator
	{
		private static var modelLocator : mma.model.ModelLocator;
		
		public static function getInstance():mma.model.ModelLocator
		{
	 		if ( modelLocator == null )
				modelLocator = new mma.model.ModelLocator();
			
			return modelLocator;
	   }  
	   	public function ModelLocator() 
	   	{
	   		if ( mma.model.ModelLocator.modelLocator != null )
					throw new Error( "Only one ModelLocator instance should be instantiated" );	
	   	}
		   	public var flickrModel:FlickrModel = new FlickrModel();   
	}	
}