package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ar_sepehr.Smoother;
	
	import eyeTrack.camera.LightCamera;

	[SWF(width = "500", height = "500", frameRate = "60", backgroundColor = "#000000")]
	public class EyeTrack extends Sprite
	{
		private var camera:LightCamera ;
		
		private var debugBitmap:Bitmap,
					debugBitmapData:BitmapData ;
					
		private var W:Number = 500,
					H:Number = 500 ;
		
		private var cameraSmoother:Smoother ;
		
		public function EyeTrack()
		{
			super();
			
			
			//Create camera area
			camera = new LightCamera(W,H);
			
			//Create debug bitmap
			debugBitmapData = new BitmapData(W,H);
			debugBitmap = new Bitmap(debugBitmapData);
			this.addChild(debugBitmap);
			
			//Set the filter 1, smoother
			cameraSmoother = new Smoother(W,H);
			
			//Activate camera rendering
			this.addEventListener(Event.ENTER_FRAME,updateImage);
		}
		
		protected function updateImage(event:Event):void
		{
			debugBitmapData.lock();
			
			camera.getBitmap(debugBitmapData);
			debugBitmapData.draw(cameraSmoother.smooth(debugBitmapData));
				
			debugBitmapData.unlock();
		}
	}
}