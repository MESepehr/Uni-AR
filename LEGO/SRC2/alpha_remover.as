package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class alpha_remover extends Sprite
	{
		public function alpha_remover()
		{
			super();
			
			var bit1:BitmapData = new BitmapData(200,200,true,0);
			var bit2:BitmapData = new BitmapData(200,200,true,0);
			
			bit1.draw(bit1_mc);
			bit2.draw(bit2_mc);
			
			var bit3:BitmapData = bit1.clone();
			applyBWFilter(bit3)
			//bit3.threshold(bit1,new Rectangle(0,0,200,200),new Point(),'==',0x00000000,0x00000000,0xff000000,false);
			
			var bit:Bitmap = new Bitmap(bit3);
			this.addChild(bit);
			bit.x = 173;
			bit.y = 258;
		}
		
		private var histo:Vector.<Vector.<Number>>,
					cameraSmoothFilter:ConvolutionFilter,
					histoDelta:Number = -40,
					histoMax:int,
					histoMin:int,
					histoMaxIndex:int;
		public function applyBWFilter(bitmapData:BitmapData):void
		{
			bitmapData.lock();
			var matrix:Array = [ 	0.5, 	0.5, 	0.5, 	0, 0,
				0.5, 	0.5, 	0.5, 	0, 0,
				0.5, 	0.5, 	0.5, 	0, 0,
				0, 		0, 		0, 		1, 0 ];
			
			var colorFilter:ColorMatrixFilter = new ColorMatrixFilter( matrix );
			bitmapData.applyFilter(bitmapData, new Rectangle(0,0,200,200), new Point(0,0), colorFilter );
			histo = bitmapData.histogram();
			histoMax = -1;
			histoMin = 1000 ;
			histoMaxIndex = -1 ;
			histo[0].forEach(histoCalc);
			histoMaxIndex = (histoMax+histoMax+histoMin)/3;
			var betweenNumber:uint = histoMaxIndex+(histoMaxIndex<<8)+(histoMaxIndex<<16)+(0xff<<24);
			trace("betweenNumber : "+betweenNumber.toString(16));
			bitmapData.threshold(bitmapData,new Rectangle(0,0,200,200),new Point(),'<=',betweenNumber,0xff000000,0xffffffff,false);
			bitmapData.threshold(bitmapData,new Rectangle(0,0,200,200),new Point(),'>',betweenNumber,0xffffffff,0xffffffff,false);
			bitmapData.unlock();
		}
		
		private function histoCalc(val:Number,index:uint,nothing:*=null)
		{
			if(val>20)
			{
				histoMax = Math.max(index,histoMax);
				histoMin = Math.min(index,histoMin);
			}
		}
	}
}