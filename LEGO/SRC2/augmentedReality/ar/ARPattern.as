package augmentedReality.ar
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	
	
	[Event(name="COMPLETE", type="flash.events.Event")]
	internal class ARPattern extends Bitmap
	{
		private var patternLoader:Loader = new Loader(),
					orginalPattern:BitmapData ;
		
		public var visiblePrecent:Number ;
		
		/**Flags*/
		private var f_fileLoaded:Boolean;
		
		private var cW:Number,cH:Number;
		
		private var myURL:String;
		
		public function ARPattern(patternURL:String,W:Number,H:Number)
		{
			super(new BitmapData(W,H,true,0x00ffaa33));
			
			cW = W ;
			cH = H ;
			
			myURL = patternURL ;
			
			visiblePrecent = cW*cH ;
			
			patternLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,patternLoaded);
			patternLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR ,urlIsWrong_f);
			patternLoader.load(new URLRequest(patternURL),new LoaderContext(false,ApplicationDomain.currentDomain));
		}
		
		protected function urlIsWrong_f(event:IOErrorEvent):void
		{
			// TODO Auto-generated method stub
			trace("This url is not here: "+myURL);
		}		
		
		/**This will apply color filter and make the image looks black and white
		 * I whant to move filtering on the last class to handle all of them to gather*/
		/*public function applyFilter(bitmapData:BitmapData=null):BitmapData
		{
			if(f_fileLoaded)
			{
				apply();
			}
			else
			{
				cashedFilter = colorFilter ;
			}
		}*/
		
		/*private function apply():void
		{
			// TODO Auto Generated method stub
			
		}*/		
		
		protected function patternLoaded(event:Event):void
		{
			// TODO Auto-generated method stub
			f_fileLoaded = new Boolean();
			
			var loadedObject:DisplayObject = patternLoader.content ;
			
			var capturedBitmap:BitmapData = new BitmapData(cW,cH,true,0x00000000);
			capturedBitmap.draw(loadedObject,new Matrix(cW/loadedObject.width,0,0,cH/loadedObject.height),null,null,null,true);
			orginalPattern = capturedBitmap ;
			patternLoader.unloadAndStop();
			
			var visibleBitmap:BitmapData = capturedBitmap.clone();
			var visiblePixels:uint = visibleBitmap.threshold(visibleBitmap,new Rectangle(0,0,cW,cH),new Point(),'>',0x00000000,0xffffffff,0xff000000);
			
			visiblePrecent = visiblePixels/visiblePrecent;
			
			this.bitmapData = orginalPattern.clone();
			
			this.dispatchEvent(new Event(Event.COMPLETE));
		}
	}
}