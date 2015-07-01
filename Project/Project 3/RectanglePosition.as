package
{
	import ar_sepehr.BitmapEffect;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	public class RectanglePosition extends Sprite
	{
		public var imageMC:MovieClip,
					imageAreaMC:MovieClip,
					bigFrameMC:MovieClip,
					pictureAreaMC:MovieClip,
					smallFrameMC:MovieClip;
					
		
		public function RectanglePosition()
		{
			super();
			
			imageAreaMC = Obj.get("image_area_mc",this);
			imageMC = Obj.get("image_mc",this);
			bigFrameMC = Obj.get("big_rect_mc",this);
			smallFrameMC = Obj.get("small_rect_mc",this);
			pictureAreaMC = Obj.get("image_area2_mc",this);
			
			var cap:BitmapData = new BitmapData(imageMC.width,imageMC.height,false);
			cap.draw(imageMC);
			
			var imgeRect:Rectangle = new Rectangle(imageAreaMC.x-imageMC.x,imageAreaMC.y-imageMC.y,imageAreaMC.width,imageAreaMC.height);
			
			var converted:BitmapData = BitmapEffect.matchImages(cap,imgeRect,bigFrameMC.getBounds(this),smallFrameMC.getBounds(this))[0];
			
			var convertedBitmap:Bitmap = new Bitmap(converted);
			
			this.addChild(convertedBitmap);
			convertedBitmap.x = pictureAreaMC.x;
			convertedBitmap.y = pictureAreaMC.y ;
			
			
			
			
			this.addChild(bigFrameMC);
			this.addChild(smallFrameMC);
			this.addChild(imageAreaMC);
			this.addChild(pictureAreaMC);
		}
	}
}