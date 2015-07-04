package augmentedReality.ar
{
	import ar_sepehr.BitmapEffect;
	
	import contents.LinkData;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.ConvolutionFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	[Event(name="MATCH", type="augmentedReality.ar.CompairEvent")]
	public class ARManager extends Sprite
	{
		public static const debug:Boolean = false ;
		
		public static var debug_tested_index:uint = 23 ;
		
		//private var cameraMC:MovieClip ;
		
		//private var W:Number,H:Number;
		
		private var patterns:Vector.<ARPattern>,
					patternsLink:Vector.<LinkData>;
		
		private var colorFilterCamera:ColorMatrixFilter,
					colorFilter:ColorMatrixFilter,
					cameraSmoothFilter:ConvolutionFilter,
					histoDelta:Number = -40,
					histoMax:int,
					histoMin:int,
					histoMaxIndex:int;
					
		//private var maxAcceptableDifrence:Number = Infinity ;

		private var histo:Vector.<Vector.<Number>>;

					//private var currentRect:Rectangle;
					
		/**Patterns W and H, use to capture from camera here.*/
		/*public var pW:Number,pH:Number,
					cW_pW:Number=1,cH_pH:Number=1;*/
					
		private var imagedRectangle:Rectangle ;
		
		
		/**Iremoved the dibugger to increase performance*/
		private var difrenceDebugger:Bitmap,
					compairableImage:BitmapData,
					difrencesBitmapData:BitmapData ;
		
		private const compairOnTimeDefault:uint = 4 ;
					
					
		private var compairOnOneTime:uint = compairOnTimeDefault ,
					compairedItemIndex:uint = 0 ;
		
		private var cW:Number,cH:Number;
		
		public function ARManager(w:Number,h:Number)
		{
			super();
			
			cW = w ;
			cH = h ;
			
			//maxAcceptableDifrence = w*h ;
			
			difrencesBitmapData = new BitmapData(w,h);
			if(debug)
			{
				difrenceDebugger = new Bitmap(difrencesBitmapData);
				this.addChild(difrenceDebugger);
				difrenceDebugger.y = h ;
				difrenceDebugger.x = 400 ;
			}
			
			imagedRectangle = new Rectangle(0,0,w,h);
			
			var rLum : Number = 0.6;//0.2225;
			var gLum : Number = 0.6;//0.7169;
			var bLum : Number = 0.6;//0.0606;
			
			var rLum2 : Number = 0.25;//0.2225;
			var gLum2 : Number = 0.25;//0.7169;
			var bLum2 : Number = 0.25;//0.0606;
			
			var matrix:Array = [ 	rLum, 	gLum, 	bLum, 	0, 0,
									rLum, 	gLum, 	bLum, 	0, 0,
									rLum, 	gLum, 	bLum, 	0, 0,
									0, 		0, 		0, 		1, 0 ];
			
			var matrix2:Array = [ 	rLum2, 	gLum2, 	bLum2, 	0, 0,
									rLum2, 	gLum2, 	bLum2, 	0, 0,
									rLum2, 	gLum2, 	bLum2, 	0, 0,
									0, 		0, 		0, 		1, 0 ];
			
			colorFilterCamera = new ColorMatrixFilter( matrix );
			colorFilter = new ColorMatrixFilter( matrix2 );
			
			
			cameraSmoothFilter = new ConvolutionFilter(3,3,[ 1,2,1,
				2,4,2,
				1,2,1], 16);
			
			
			
			patterns = new Vector.<ARPattern>();
			patternsLink = new Vector.<LinkData>();
			
			//pW = W = w ;
			//pH = H = h ;
			
			/*cameraMC = new MovieClip();
			cameraMC.graphics.beginFill(0,1);
			cameraMC.graphics.drawRect(0,0,w,h);
			
			this.addChild(cameraMC);*/
		}
		
		public function addPatterns(links1:Vector.<LinkData>):void
		{
			//It is better to manage linke patterns
			//patternsLink = patternsLink.concat(links1);
			// TODO Auto Generated method stub
			for(var i = 0 ; i<links1.length ; i++)
			{
				var newPattern:ARPattern = new ARPattern(links1[i].iconURL,cW,cH);
				newPattern.addEventListener(Event.COMPLETE,applyMyFilter);
				//Add it when its image loaded
				patterns.push(newPattern);
				patternsLink.push(links1[i]);
			}
			
			trace("Ready patterns are : "+patterns.length);
		}
		
		private function applyMyFilter(e:Event)
		{
			
			var bit:Bitmap = e.currentTarget as Bitmap ;
			//Removed from here and moved newt the patternsLink
			//patterns.push(bit as ARPattern);
			if(debug && patterns.indexOf(bit) == debug_tested_index)
			{
				bit.x = 400 ;
				this.addChild(bit);
			}
			//applyBWFilter(bit.bitmapData);
			bit.bitmapData = BitmapEffect.clearBlackWhitheImage(BitmapEffect.blackAndWhite(bit.bitmapData),1,false);
		}
		
		
		
		
		
		
		
		
		
	///////////////////////////////
		/*public function applyBWFilter(bitmapData:BitmapData):void
		{
			bitmapData.lock();
				var transparetnItem:BitmapData = bitmapData.clone();
				//currentRect = bitmapData.rect ;
				bitmapData.applyFilter(bitmapData, imagedRectangle, new Point(0,0), colorFilter );
				//Bellow line is new
					//bitmapData.applyFilter(bitmapData, imagedRectangle, new Point(0,0), cameraSmoothFilter );
				histo = bitmapData.histogram();
				histoMax = -1;
				histoMin = 1000 ;
				histoMaxIndex = -1 ;
				histo[0].forEach(histoCalc);
				//Old methode
					//histoMaxIndex = Math.max(0,Math.min(histoMaxIndex+histoDelta,255));
				histoMaxIndex = betweenColor();
				//trace("histoMaxIndex : "+histoMaxIndex.toString(10)+' > '+histoMax,histoMin);
				var betweenNumber:uint = histoMaxIndex+(histoMaxIndex<<8)+(histoMaxIndex<<16);
				//trace("betweenNumber : "+betweenNumber.toString(16)+' vs '+currentRect);
				bitmapData.threshold(bitmapData,imagedRectangle,new Point(),'<=',betweenNumber,0xff000000,0x00ffffff,false);
				bitmapData.threshold(bitmapData,imagedRectangle,new Point(),'>',betweenNumber,0xffffffff,0x00ffffff,false);
				//Make output image transparent
				bitmapData.threshold(transparetnItem,imagedRectangle,new Point(),'==',0x00000000,0x00000000,0xff000000,false);
			bitmapData.unlock();
			//return bitmapData ;
		}*/
		
		/**This is same as applyBWfilter but has camera smooth and it is copied for better performance.
		public function applyBWFilterForCamera(bitmapData:BitmapData):void
		{
			bitmapData.lock();
				//currentRect = bitmapData.rect ;
				bitmapData.applyFilter(bitmapData, imagedRectangle, new Point(0,0), colorFilterCamera );
				bitmapData.applyFilter(bitmapData, imagedRectangle, new Point(0,0), cameraSmoothFilter );
				histo = bitmapData.histogram();
				histoMax = -1;
				histoMin = 1000 ;
				histoMaxIndex = -1 ;
				histo[0].forEach(histoCalc);
				//Old methode
					//histoMaxIndex = Math.max(0,Math.min(histoMaxIndex+histoDelta,255));
				//trace("histoMax : "+histoMax+' histoMin: '+histoMin);
				histoMaxIndex = betweenColor();
				var betweenNumber:uint = histoMaxIndex+(histoMaxIndex<<8)+(histoMaxIndex<<16);
				//trace("betweenNumber : "+betweenNumber.toString(16)+' vs '+currentRect);
				bitmapData.threshold(bitmapData,imagedRectangle,new Point(),'<=',betweenNumber,0xff000000,0x00ffffff,false);
				bitmapData.threshold(bitmapData,imagedRectangle,new Point(),'>',betweenNumber,0xffffffff,0x00ffffff,false);
			bitmapData.unlock();
			//return bitmapData ;
		}*/
		
		private function betweenColor():uint
		{
			//---++
			return (histoMax+histoMax+histoMin)/3 ;
			//Old Method
			//return Math.max(0,Math.min(histoMaxIndex+histoDelta,255));
		}
		
		private function histoCalc(val:Number,index:uint,nothing:*=null)
		{
			if(val>20)
			{
				histoMax = Math.max(index,histoMax);
				histoMin = Math.min(index,histoMin);
			}
		}
		
		private function histoCalcOld(val:Number,index:uint,nothing:*=null)
		{
			if(histoMax<val)
			{
				histoMax = val;
				histoMaxIndex = index
			}
		}
		
		public function compair(camBitData:BitmapData,comairItems:uint=0):void
		{
			// TODO Auto Generated method stub
			if( comairItems == 0 )
			{
				compairOnOneTime = compairOnTimeDefault ;
			}
			else
			{
				compairOnOneTime = comairItems ;
			}
			//return;
			//applyBWFilterForCamera(camBitData);
			compairableImage = camBitData ;
			var i:uint,l:uint = patterns.length,index:uint=0;
			compairOnOneTime = Math.min(l,compairOnOneTime);
			
			//Debug lines 
			/*if(patterns.length>0)
			{
				compairWithCamera(patterns[1],1);
			}
			return;*/
			
			
			
			for(i = 0 ; i<compairOnOneTime ; i++)
			{
				index = (i+compairedItemIndex)%l;
				//trace("index : " +index);
				compairWithCamera(patterns[index],index);
			}
			compairedItemIndex = (index+1)%l ;
			//patterns.forEach(compairWithCamera);
		}
		
		private function compairWithCamera(item:ARPattern,index:uint=0,arr:*=null)
		{
			//trace("item.stage : "+item.stage);
			//var compairTime:Number = getTimer();
			difrencesBitmapData = item.bitmapData.compare(compairableImage) as BitmapData;
			//I have to remove pixels under alpha<1 under the item bitmapData
			var difrences:uint = 0;
			if(difrencesBitmapData!=null)
			{
				difrencesBitmapData.threshold(item.bitmapData,imagedRectangle,new Point(),'==',0x00000000,0x00000000,0xff000000,false);
				difrences = difrencesBitmapData.threshold(difrencesBitmapData,imagedRectangle,new Point(),'>',0x00000000,0xffff0000,0xff000000);
			}
			if(debug && debug_tested_index == index)
			{
				difrenceDebugger.bitmapData = difrencesBitmapData ;
			}
			//trace("compair time : "+(getTimer()-compairTime));
			//trace("difrences : "+difrences);
			//I can test numbers below 7000 but i sow 5000 and 4000 difrences for one image.
			/*if(maxAcceptableDifrence>difrences)
			{*/
				this.dispatchEvent(new CompairEvent(CompairEvent.MATCH,patternsLink[index],difrences/item.visiblePrecent));
			/*}*/
		}
	}
}