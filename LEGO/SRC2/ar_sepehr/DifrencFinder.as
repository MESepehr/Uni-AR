package ar_sepehr
{
	import flash.display.BitmapData;

	public class DifrencFinder
	{
		public var lastBitmap:BitmapData ;
		
		private var W:Number,H:Number;
		
		public function DifrencFinder(Width:Number,Height:Number)
		{
			W = Width ;
			H = Height ;
		}
		
		public function getDifrence(newBitmap:BitmapData):void
		{
			if(lastBitmap==null)
			{
				lastBitmap = newBitmap.clone();
				newBitmap.draw( new BitmapData(W,H,false,0xffffff)) ;
			}
			else
			{
				var difrence:Object = newBitmap.compare(lastBitmap);
				lastBitmap = newBitmap.clone();
				if(difrence is BitmapData)
				{
					newBitmap.draw( new BitmapData(W,H,false,0xffffff)) ;
					newBitmap.draw(difrence as BitmapData);
				}
				else
				{
					newBitmap.draw( new BitmapData(W,H,false,0xffffff)) ;
				}
			}
		}
	}
}