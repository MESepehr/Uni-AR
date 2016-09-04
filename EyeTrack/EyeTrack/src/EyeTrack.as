package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import ar_sepehr.BitmapEffect;
	import ar_sepehr.DifrencFinder;
	import ar_sepehr.Smoother;
	
	import eyeTrack.camera.LightCamera;

	[SWF(width = "500", height = "500", frameRate = "60", backgroundColor = "#000000")]
	public class EyeTrack extends Sprite
	{
		private var camera:LightCamera ;
		
		private var debugBitmap:Bitmap,
					debugBitmapData:BitmapData ;
					
		//private var secondBitmap:Bitmap ;
					
		private var W:Number = 500,
					H:Number = 500 ;
		
		private var cameraSmoother:Smoother ;
		private var cameraSmoother2:Smoother ;
		
		private var difrenceTracker:DifrencFinder ;
		
		public function EyeTrack()
		{
			super();
			
			
			//Create camera area
			camera = new LightCamera(W,H);
			
			//Create debug bitmap
			debugBitmapData = new BitmapData(W,H,false,0xffffff);
			debugBitmap = new Bitmap(debugBitmapData);
			
			debugBitmap.scaleX = stage.stageWidth/W;
			debugBitmap.scaleY = stage.stageHeight/H;
			
			this.addChild(debugBitmap);
			
			//Set the filter 1, smoother
			cameraSmoother = new Smoother(W,H);
			cameraSmoother2 = new Smoother(W,H);
			
			//Image difrences
			difrenceTracker = new DifrencFinder(W,H);
			
			//The second bitmap 
			/*secondBitmap = new  Bitmap();
			this.addChild(secondBitmap);
			secondBitmap.scaleX = secondBitmap.scaleY = 0.5 ;
			secondBitmap.alpha = 0.5 ;
			secondBitmap.x = 500*/
			
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
			/*secondBitmap.bitmapData = difrenceTracker.lastBitmap ;*/
			BitmapEffect.clearBlackWhitheImage(debugBitmapData,1,false,3,true);
			BitmapEffect.clearBlackWhitheImage(debugBitmapData,1,false,3,true);
			BitmapEffect.clearBlackWhitheImage(debugBitmapData,1,false,3,true);
			//Check the difrences
					difrenceTracker.getDifrence(debugBitmapData);
					
					debugBitmapData.draw(cameraSmoother2.smooth(debugBitmapData));
			//BitmapEffect.clearBlackWhitheImage(debugBitmapData,1,false,3,true);
		//BitmapEffect.clearBlackWhitheImage(debugBitmapData,2,false,3,true);
			
			
			//Clear the difrence to
			//BitmapEffect.clearBlackWhitheImage(debugBitmapData,2,false,3,true);
			
				
			debugBitmapData.unlock();
		}
	}
}