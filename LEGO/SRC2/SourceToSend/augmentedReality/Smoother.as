package augmentedReality
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;

	public class Smoother
	{
		private var max:uint,
					bitQue:Vector.<BitmapData> ,
					L:uint;
					
		private var filter:ConvolutionFilter,
					final:BitmapData,
					W:Number,H:Number,
					point:Point;
		
		public function Smoother(width:Number,height:Number,resolution:uint=5)
		{
			bitQue = new Vector.<BitmapData>();
			max = resolution ;
			W = width ;
			H = height ;
			
			point = new Point();
			
			filter = new ConvolutionFilter(1,1,[1],max);
		}
		
		public function smooth(bitmap:BitmapData):BitmapData
		{
			var bitmap2:BitmapData = bitmap.clone();
			filter = new ConvolutionFilter(1,1,[1],max);
			bitmap2.applyFilter(bitmap,bitmap.rect,point,filter);
			bitQue.push(bitmap2);
			L++;
			if(L>max)
			{
				bitQue.shift();
				L--;
			}
			//trace(bitQue.length+' vs '+L);
			filter = new ConvolutionFilter(1,1,[1],1/L);
			final = new BitmapData(W,H,false,0);
			bitQue.forEach(drawOnFinal);
			
			return final ;
		}
		
		private function drawOnFinal(item:BitmapData,index:uint,blabla:*)
		{
			final.draw(item,null,null,BlendMode.ADD); 
		}
	}
}