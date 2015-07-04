package
{
	import ar_sepehr.BitmapEffect;
	import ar_sepehr.MyCamera;
	import ar_sepehr.Smoother;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	public class ar_camera extends Sprite
	{
		private var cameraMC:MovieClip;
		
		private var myCam:MyCamera ;
		
		private var smooth:Smoother ;
		
		private var lastSmoothedBitmapData:BitmapData ;
		
		private var smootehdBitmap:Bitmap ;
		
		
		
		private var correctColorBitmapData:BitmapData,
					correctedColorBitmap:Bitmap; 
					
		private var blackAndWightBitmap:Bitmap,
					blackAndWightBitmapData:BitmapData ;
					
					
		private var smoothedBW:Bitmap,
					smoothedBWdata:BitmapData;
					
					
		private var imageAreaMC:MovieClip,
					ObjectAreaMC:MovieClip,
					ObjectMC:MovieClip;
					
		private var foundedObjectData:BitmapData,
					foundedObject:Bitmap;
					
		private var movedImageData:BitmapData,
					movedImage:Bitmap,
					movedImageMC:MovieClip;
					
					
		
		public function ar_camera()
		{
			imageAreaMC = Obj.get("image_area_mc",this);
			ObjectAreaMC = Obj.get("object_area_mc",this);
			ObjectMC = Obj.get("object_mc",this);
			movedImageMC = Obj.get("croped_image_box_mc",this);
			
			
			cameraMC = Obj.get("camera_mc",this);
			smooth = new Smoother(cameraMC.width,cameraMC.height,3);
			
			myCam = new MyCamera(cameraMC);
			cameraMC.addEventListener(MyCamera.CAM_UPDATED,smoothCam);
			
			lastSmoothedBitmapData = new BitmapData(1,1);
			smootehdBitmap = new Bitmap();
			this.addChild(smootehdBitmap);
			smootehdBitmap.y = 200 ;
			
			correctColorBitmapData = new BitmapData(200,200,false);
			correctedColorBitmap = new Bitmap(correctColorBitmapData);
			this.addChild(correctedColorBitmap);
			correctedColorBitmap.y = 0 ;
			correctedColorBitmap.x = 200 ;
			
			blackAndWightBitmapData = new BitmapData(1,1);
			blackAndWightBitmap = new Bitmap(blackAndWightBitmapData);
			this.addChild(blackAndWightBitmap);
			blackAndWightBitmap.y = 200 ;
			blackAndWightBitmap.x = 200;
			
			smoothedBWdata = new BitmapData(1,1);
			smoothedBW = new Bitmap(smoothedBWdata);
			this.addChild(smoothedBW);
			smoothedBW.x = 400 ;
			smoothedBW.y = 0 ;
			
			foundedObjectData = new BitmapData(1,1);
			foundedObject = new Bitmap(foundedObjectData);
			this.addChild(foundedObject);
			foundedObject.x = 400 ;
			foundedObject.y = 200;
			
			movedImageData = new BitmapData(1,1);
			movedImage = new Bitmap(movedImageData);
			movedImage.smoothing = true ;
			movedImageMC.addChild(movedImage);
			/*movedImage.x = 200 ;
			movedImage.y = 600;*/
			movedImageMC.x = 600;
			movedImageMC.y = 000 ;
			
			this.addEventListener(Event.ENTER_FRAME,anim);
		}
		
		protected function smoothCam(event:Event):void
		{
			// TODO Auto-generated method stub
			lastSmoothedBitmapData = smooth.smooth(myCam.getBitmapData());
		}
		
		private function anim(e:Event)
		{
			var imageRect:Rectangle = imageAreaMC.getBounds(this) ;
			imageRect.x = imageRect.x -cameraMC.x ;
			imageRect.y = imageRect.y -cameraMC.y ;
			
			
			smootehdBitmap.bitmapData = BitmapEffect.crop(lastSmoothedBitmapData.clone(),imageRect);
			
			
			correctColorBitmapData = BitmapEffect.colorBalanceGrayScale(lastSmoothedBitmapData);
			correctedColorBitmap.bitmapData = BitmapEffect.crop(correctColorBitmapData,imageRect) ;
			
			blackAndWightBitmapData = BitmapEffect.blackAndWhite(correctColorBitmapData);
			blackAndWightBitmap.bitmapData = BitmapEffect.crop(blackAndWightBitmapData,imageRect) ;
			
			smoothedBWdata = BitmapEffect.clearBlackWhitheImage(blackAndWightBitmapData,1,false);
			smoothedBW.bitmapData = BitmapEffect.crop(smoothedBWdata,imageRect) ;
			
			
			
			var areaRect:Rectangle = ObjectAreaMC.getBounds(this) ;
			areaRect.x = areaRect.x -cameraMC.x ;
			areaRect.y = areaRect.y -cameraMC.y ;
			
			var objectRect:Rectangle = ObjectMC.getBounds(this) ;
			objectRect.x = objectRect.x -cameraMC.x ;
			objectRect.y = objectRect.y -cameraMC.y ;
			
			var images:Vector.<BitmapData> = BitmapEffect.matchImages(smoothedBWdata,imageRect,areaRect,objectRect,lastSmoothedBitmapData.clone());
			foundedObject.bitmapData = images[0] ;
			
			movedImageData = images[1];
			movedImage.bitmapData = movedImageData ;
		}
	}
}