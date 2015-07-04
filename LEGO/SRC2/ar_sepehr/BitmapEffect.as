package ar_sepehr
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.dns.AAAARecord;

	public class BitmapEffect
	{
		public static function grayScale(colorBimtap:BitmapData):BitmapData
		{
			throw "Function name changed";
			return colorBalance(colorBimtap);
		}
		
		public static function colorBalance(colorBimtap:BitmapData):BitmapData
		{
			var newBitmap:BitmapData = colorBimtap.clone();
			var histo:Vector.<Vector.<Number>> = newBitmap.histogram();
			
			var Rsum:Number = sumVector(histo[0]);
			var Gsum:Number = sumVector(histo[1]);
			var Bsum:Number = sumVector(histo[2]);
			
			var sum:Number = Rsum+Gsum+Bsum ;
			
			//trace("Rsum ; "+Rsum/Bsum);
			//trace("Rsum ; "+Gsum/Rsum);
			
			
			var filter:ColorMatrixFilter = new ColorMatrixFilter([	1	,Gsum/sum	,Bsum/sum	,0	,1	,
																	Rsum/sum	,1	,Bsum/sum	,0	,1	,
																	Rsum/sum	,Gsum/sum	,1	,0	,1	,
																	0			,0			,0			,1	,1]);
			
			
			
			
			newBitmap.applyFilter(newBitmap,newBitmap.rect,new Point(),filter);
			
			
			/*filter = new ColorMatrixFilter([	1/3	,1/3	,1/3	,0	,1	,
																	1/3	,1	,1/3	,0	,1	,
																	1/3	,1/3	,1	,0	,1	,
																	0			,0			,0			,1	,1]);
			newBitmap.applyFilter(newBitmap,newBitmap.rect,new Point(),filter);*/
			
			return newBitmap ;
		}
		
		public static function colorBalanceGrayScale(colorBimtap:BitmapData):BitmapData
		{
			var newBitmap:BitmapData = colorBimtap.clone();
			var histo:Vector.<Vector.<Number>> = newBitmap.histogram();
			
			var Rsum:Number = sumVector(histo[0]);
			var Gsum:Number = sumVector(histo[1]);
			var Bsum:Number = sumVector(histo[2]);
			
			var sum:Number = Rsum+Gsum+Bsum ;
			//trace("sum : "+sum);
			
			//trace("Rsum ; "+Rsum/Bsum);
			//trace("Rsum ; "+Gsum/Rsum);
			
			
			var filter:ColorMatrixFilter = new ColorMatrixFilter([	1-(Gsum+Bsum)/sum	,Gsum/sum	,Bsum/sum	,0	,1	,
				Rsum/sum	,1-(Rsum+Bsum)/sum	,Bsum/sum	,0	,1	,
				Rsum/sum	,Gsum/sum	,1-(Rsum+Gsum)/sum	,0	,1	,
				0			,0			,0			,1	,1]);
			
			
			
			
			newBitmap.applyFilter(newBitmap,newBitmap.rect,new Point(),filter);
			
			
			/*filter = new ColorMatrixFilter([	1/3	,1/3	,1/3	,0	,1	,
			1/3	,1	,1/3	,0	,1	,
			1/3	,1/3	,1	,0	,1	,
			0			,0			,0			,1	,1]);
			newBitmap.applyFilter(newBitmap,newBitmap.rect,new Point(),filter);*/
			
			return newBitmap ;
		}
		
		
		private static function sumVector(values:Vector.<Number>):Number
		{
			var l:uint = values.length ;
			//trace("l :"+l);
			var sum:Number = 0 ;
			for(var i:int = 0 ; i<l ; i++)
			{
				sum += values[i]*i ;	
			}
			return sum ;
		}
		
		
		public static function blackAndWhite(sourceBitmap:BitmapData):BitmapData
		{
			var newBitmap:BitmapData = sourceBitmap.clone() ;
			
			var histo:Vector.<Vector.<Number>> = newBitmap.histogram();
			
			var midColor:uint = sumVector(histo[0])/(newBitmap.width*newBitmap.height) ;
			//trace(midColor.toString(16));
			
			newBitmap.threshold(newBitmap,newBitmap.rect,new Point(),"<=",midColor,0xff000000,0x000000ff,false);
			newBitmap.threshold(newBitmap,newBitmap.rect,new Point(),">",midColor,0xffffffff,0x000000ff,false);
			newBitmap.threshold(sourceBitmap,newBitmap.rect,new Point(),"<",0xff000000,0x00000000,0xff000000,false);
			
			
				//2 time somoothing
			//newBitmap = clearBlackWhitheImage(newBitmap,0);
			
			return newBitmap ;
		}
		
		public static function clearBlackWhitheImage(sourceBitmap:BitmapData,times:uint,mainIsBlack:Boolean=true,pixels:uint=3):BitmapData
		{
			var i:int,j:int;
			var pixelArray:Array = [] ;
			for(i = 0 ; i<pixels ; i++)
			{
				for(j = 0 ; j<pixels ; j++)
				{
					pixelArray.push(1);
				}
			}
			var filter:ConvolutionFilter = new ConvolutionFilter(pixels,pixels,pixelArray,pixels*pixels) ;
			var newBitmap:BitmapData = sourceBitmap.clone() ;
			for(i = 0 ; i<times ; i++)
			{
				//2 time somoothing
				newBitmap.applyFilter(newBitmap,newBitmap.rect,new Point(),filter);
			}
			if(times>0)
			{
				if(mainIsBlack)
				{
					newBitmap.threshold(newBitmap,newBitmap.rect,new Point(),"<",0x000000ff,0xff000000,0x000000ff,false);
				}
				else
				{
					newBitmap.threshold(newBitmap,newBitmap.rect,new Point(),">",0x00000000,0xffffffff,0x000000ff,false);
				}
			}
			return newBitmap ;
		}
		
		
	/////////////////////////////////////////////////////////////////////
		
		/**This function will search for black rectangle an fit it on SmallRectangle<br>
		 * All rectangles had to be related to the ImageRectangle position<br>
		 * The firstBitmapData has to be black And wight*/
		public static function matchImages(firstBitmapData:BitmapData,ImageRectangle:Rectangle,ObjectArea:Rectangle,ObjectSize:Rectangle,fullImage:BitmapData=null):Vector.<BitmapData>
		{
			floorRect(ImageRectangle);
			floorRect(ObjectArea);
			floorRect(ObjectSize);
			
			var rectFinder:BitmapData = new BitmapData(ObjectArea.width,ObjectArea.height,false,0xffffffff);
			rectFinder.draw(firstBitmapData,new Matrix(1,0,0,1,-ObjectArea.x,-ObjectArea.y));
			
			var blackRect:Rectangle = rectFinder.getColorBoundsRect(0x000001,0x000000);
			
			//trace("black rectangle is : "+blackRect+' vs '+ObjectArea);
			
			if(blackRect.top!=0 && blackRect.right!=ObjectArea.width && blackRect.bottom!=ObjectArea.height && blackRect.left!=0)
			{
				//trace("Small rectangle founded on Object Area");
				//Black are founded in this image
				var zoomRectangle:Rectangle = new Rectangle(blackRect.x+ObjectArea.x,blackRect.y+ObjectArea.y,blackRect.width,blackRect.height);
				
				firstBitmapData = zoomIn(firstBitmapData,zoomRectangle,ObjectSize);
				if(fullImage!=null)
				{
					fullImage = zoomIn(fullImage,zoomRectangle,ObjectSize);
				}
			}
			
			//trace("ImageRectangle : "+ImageRectangle);
			
			//var croppedImage:BitmapData = new BitmapData(ImageRectangle.width,ImageRectangle.height,firstBitmapData.transparent,0x00ffffff);
			//croppedImage.draw(firstBitmapData,new Matrix(1,0,0,1,-ImageRectangle.x,-ImageRectangle.y));
			firstBitmapData.threshold(firstBitmapData,firstBitmapData.rect,new Point(),">",0x00000000,0xffffffff,0x000000ff,false);
			
			
			/*if(fullImage!=null)
			{
				var croppedImage2:BitmapData = new BitmapData(ImageRectangle.width,ImageRectangle.height,fullImage.transparent,0x00ffffff);
				croppedImage2.draw(fullImage,new Matrix(1,0,0,1,-ImageRectangle.x,-ImageRectangle.y));
			}*/
			//Below line will make image to stay two color
			
			var images:Vector.<BitmapData> = new Vector.<BitmapData>();
			
			images.push(crop(firstBitmapData,ImageRectangle));
			if(fullImage!=null)
			{
				images.push(crop(fullImage,ImageRectangle));
			}
			return images ;
		}
		
		
		public static function zoomIn(imageData:BitmapData,zoomRectangle:Rectangle,matchRectangle:Rectangle=null):BitmapData
		{
			///trace("zoomRectangle : "+zoomRectangle);
			//trace("matchRectangle : "+matchRectangle);
			
			var imageRect:Rectangle = new Rectangle(0,0,imageData.width,imageData.height) ;
			if(matchRectangle == null)
			{
				matchRectangle = imageRect ;
			}
			var ScaleX:Number = matchRectangle.width/zoomRectangle.width ;
			var ScaleY:Number = matchRectangle.height/zoomRectangle.height ;
			
			
			var dx:Number = -zoomRectangle.x*ScaleX+matchRectangle.x;
			var dy:Number = -zoomRectangle.y*ScaleY+matchRectangle.y;
			
			//trace("dx : "+(matchRectangle.x-zoomRectangle.x)+' * scaleX : '+ScaleX);
			
			var newImage:BitmapData = new BitmapData(imageRect.width,imageRect.height,imageData.transparent,0x00FFFFFF);
			newImage.draw(imageData,new Matrix(ScaleX,0,0,ScaleY,dx,dy));
			
			return newImage ;
		}
		
		
		public static function crop(imageData:BitmapData,cropRect:Rectangle):BitmapData
		{
			var croppedImage:BitmapData = new BitmapData(cropRect.width,cropRect.height,imageData.transparent,0x00ffffff);
			//by using matrix is 120 miliseconds per 1000 crop
				croppedImage.draw(imageData,new Matrix(1,0,0,1,-cropRect.x,-cropRect.y),null,null,null,true);
			//it is take 120 milisecond per 1000 crop for below line to
				//croppedImage.draw(imageData,null,null,null,cropRect,true);
			return croppedImage ;
		}
		
		/**This function will change the entered rectangle without making copy*/
		public static function floorRect(rect:Rectangle):void
		{
			rect.x = Math.floor(rect.x);
			rect.y = Math.floor(rect.y);
			rect.width = Math.floor(rect.width);
			rect.height = Math.floor(rect.height);
		}
		
	}
}