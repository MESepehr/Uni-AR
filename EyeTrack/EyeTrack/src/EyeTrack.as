package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ar_sepehr.BitmapEffect;
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
			
			debugBitmap.scaleX = stage.stageWidth/W;
			debugBitmap.scaleY = stage.stageHeight/H;
			
			this.addChild(debugBitmap);
			
			//Set the filter 1, smoother
			cameraSmoother = new Smoother(W,H);
			
			//Activate camera rendering
			this.addEventListener(Event.ENTER_FRAME,updateImage);
		}
		
		protected function updateImage(event:Event):void
		{
			debugBitmapData.lock();
			//Draw camera
			camera.getBitmap(debugBitmapData);
			//Smooth the image
			debugBitmapData.draw(cameraSmoother.smooth(debugBitmapData));
			//GrayScale image
			BitmapEffect.colorBalanceGrayScale(debugBitmapData,true);
			//Black and Wight
			BitmapEffect.blackAndWhite(debugBitmapData,true);
			//Clean pixels
			BitmapEffect.clearBlackWhitheImage(debugBitmapData,2,true,3,true);
			BitmapEffect.clearBlackWhitheImage(debugBitmapData,2,true,3,true);
			BitmapEffect.clearBlackWhitheImage(debugBitmapData,2,false,3,true);
				
			debugBitmapData.unlock();
		}
	}
}