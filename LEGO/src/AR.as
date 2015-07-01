package
{
	import com.mteamapp.camera.MTeamCamera;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	
	public class AR extends Sprite
	{
		private var camMC:MovieClip,
					histoMC:MovieClip;
		
		private var hW:Number,
					hH:Number;
					
		private var cW:Number,
					cH:Number;
					
		/**black and wight image*/
		private var cop1:Bitmap ;
		/**2 collor image*/
		private var cop2:Bitmap ;
		/**last saved image*/
		private var cop3:Bitmap ;
		
		/**difrences*/
		private var cop4:Bitmap ;
		/**difrence sub*/
		private var cop5:Bitmap ;

		private var graySclaeFilter:ColorMatrixFilter;
		
		private var lastImage:SharedObject = SharedObject.getLocal('savedImage','/'),
					s_image:String = "image";
		
		public function AR()
		{
			super();
			
			
			histoMC = Obj.get("histo_mc",this);
			hW = histoMC.width ;
			hH = histoMC.height ;
			histoMC.removeChildren();
			
			var rLum : Number = 0.2225;
			var gLum : Number = 0.7169;
			var bLum : Number = 0.0606;
			
			var matrix:Array = [ 	rLum, 	gLum, 	bLum, 	0, 0,
									rLum, 	gLum, 	bLum, 	0, 0,
									rLum, 	gLum, 	bLum, 	0, 0,
									0, 		0, 		0, 		1, 0 ];
			
			graySclaeFilter = new ColorMatrixFilter( matrix );
			
			
			camMC = Obj.get("camera_mc",this);
			cW = camMC.width ;
			cH = camMC.height ;
			var mteamCam:MTeamCamera = new MTeamCamera(camMC);
			
			var sampleBD:BitmapData = new BitmapData(cW,cH,false,0);
			cop1 = new Bitmap(sampleBD);
			this.addChild(cop1);
			cop1.x = camMC.x+cW;
			cop1.y = camMC.y;
			
			cop2 = new Bitmap(sampleBD.clone());
			this.addChild(cop2);
			cop2.x = camMC.x+cW*2;
			cop2.y = camMC.y;
				//cop2.smoothing = true ;
			
			cop3 = new Bitmap();
				//cop3.smoothing = true ;
			if(lastImage.data[s_image]!=undefined)
			{
				cop3.bitmapData = BitmapSaveLoad.ByteArrayToBitmapData(lastImage.data[s_image],false);
			}
			this.addChild(cop3);
			cop3.x = camMC.x+cW*3;
			cop3.y = camMC.y;
			
			cop4 = new Bitmap();
				//cop4.smoothing = true ;
			this.addChild(cop4);
			cop4.x = camMC.x+cW*4;
			cop4.y = camMC.y;
			
			cop5 = new Bitmap(sampleBD.clone());
				//cop5.smoothing = true ;
			this.addChild(cop5);
			cop5.x = camMC.x;
			cop5.y = camMC.y+cH;
			
			createCopy();
			
			this.addEventListener(Event.ENTER_FRAME,createCopy);
			(Obj.get("save_mc",this) as MovieClip).addEventListener(MouseEvent.CLICK,saveCurrentImage);
		}
		
		protected function saveCurrentImage(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			trace("Capture current image");
			lastImage.data[s_image] = BitmapSaveLoad.BitmapDataToByteArray(cop2.bitmapData);
			lastImage.flush();
			cop3.bitmapData = cop2.bitmapData.clone();
		}
		
		protected function createCopy(event:Event=null):void
		{
			// TODO Auto-generated method stub
			
			var rLum : Number = Number(r.text);
			var gLum : Number = Number(g.text);
			var bLum : Number = Number(b.text);
			
			var matrix:Array = [ 	rLum, 	gLum, 	bLum, 	0, 0,
				rLum, 	gLum, 	bLum, 	0, 0,
				rLum, 	gLum, 	bLum, 	0, 0];
			
			graySclaeFilter = new ColorMatrixFilter( matrix );
			
			cop1.bitmapData.lock();
			cop2.bitmapData.lock();
			
			cop1.bitmapData.draw(camMC);
			cop1.bitmapData.applyFilter(cop1.bitmapData, new Rectangle( 0,0,cW,cH ), new Point(0,0), graySclaeFilter );
			
			var histo:Vector.<Vector.<Number>> = cop1.bitmapData.histogram();
			max = -1;
			maxIndex = -1 ;
			//trace("histo  length : "+histo[0].length);
			drawHisto(histo[0])
			histo[0].forEach(histoCalc);
			maxIndex = Math.min(maxIndex+Number(ad.text),255);
			//trace("maxIndex : "+maxIndex);
			
			var betweenNumber:uint = maxIndex+(maxIndex<<8)+(maxIndex<<16);
			c.text = '0x'+betweenNumber.toString(16);
			cop2.bitmapData.threshold(cop1.bitmapData,new Rectangle(0,0,cW,cH),new Point(),'<=',betweenNumber,0xff000000,0x00ffffff,false);
			cop2.bitmapData.threshold(cop1.bitmapData,new Rectangle(0,0,cW,cH),new Point(),'>',betweenNumber,0xffffffff,0x00ffffff,false);
			
			if(cop3.bitmapData!=null)
			{
				cop4.bitmapData = cop3.bitmapData.compare(cop2.bitmapData) as BitmapData;
			}
			
			if(cop4.bitmapData != null)
			{
				cop5.bitmapData = cop4.bitmapData.clone();
				difrences = cop5.bitmapData.threshold(cop4.bitmapData,new Rectangle(0,0,cW,cH),new Point(),'>',0x00000000,0xffff0000,0xff000000);
			}
			else
			{
				difrences = 0;
			}
			
			
			if(difrences<Number(ac.text))
			{
				stage.color = 0x00aa00;
			}
			else
			{
				stage.color = 0xaa3300;
			}
			di.text = difrences.toString();
			
			cop1.bitmapData.unlock();
			cop2.bitmapData.unlock();
		}
		
		private function drawHisto(vals:Vector.<Number>)
		{
			histoMC.graphics.clear();
			histoMC.graphics.beginFill(0);
			for(var i = 0 ; i<vals.length ; i++)
			{
				histoMC.graphics.lineTo(i,vals[i]*-1/10);
			}
			histoMC.graphics.lineTo(i,0);
		}
		
		private var max:int ;
		private var maxIndex:int ;

		private var difrences:uint;
		
		private function histoCalc(val:Number,index:uint,nothing:*=null)
		{
			if(max<val)
			{
				max = val;
				maxIndex = index
			}
		}
	}
}