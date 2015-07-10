package augmentedReality
{
	import appManager.event.AppEventContent;
	
	import ar_sepehr.BitmapEffect;
	
	import augmentedReality.ar.ARManager;
	import augmentedReality.ar.CompairEvent;
	import augmentedReality.dataManager.LinkCollector;
	
	import com.mteamapp.camera.MTeamCamera;
	
	import contents.Contents;
	import contents.LinkData;
	import contents.PageData;
	import contents.displayPages.DynamicLinks;
	import contents.interFace.DisplayPageInterface;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;


	
	public class ARPage extends MovieClip implements DisplayPageInterface
	{
		private const debug:Boolean = false ;
		
		private var arManager:ARManager ;
		
		private var smoother:Smoother ;
		
		private var myLinkCollector:LinkCollector ;
		
		private var myDynamicLinks:DynamicLinks ;
		
		private var cameraMC:MovieClip,
					cW:Number,
					cH:Number;
					
		private var cam:MTeamCamera ;
					
		private var index:uint = 0;
		private var myPageData:PageData;
		
		/**I removed the camera from stage to increase performance*/
		private var cameraFrame:Bitmap,
					foundedObject:Bitmap,
					camBitData:BitmapData,
					camScalePrecent:Number;
					
		private var buttonMC:MovieClip ;
					
		private var ImagesW:Number,ImagesH:Number;
		
		private var activeFlag:Boolean = false ;
		
		private var allContentButtonMC:MovieClip ;
		
		
		
		private var imageAreaMC:MovieClip,
					ObjectAreaMC:MovieClip,
					ObjectMC:MovieClip;//,
					//movedImageMC:MovieClip;

		private var cameraContainerMC:MovieClip;
		
		private var debugAreaMc:MovieClip ;
		
		public function ARPage()
		{
			super();
			
			debugAreaMc = Obj.get("debug_area_mc",this);
			debugAreaMc.visible = false ;
			
			var bitData:BitmapData = new BitmapData(10,10,false,0xff0000);
			foundedObject = new Bitmap(bitData);
			
			myDynamicLinks = Obj.findThisClass(DynamicLinks,this,true);
			
			myLinkCollector = new LinkCollector();
			myLinkCollector.addEventListener(Event.CHANGE,updateMyLinks);
			updateMyLinks(null);
			
			cameraContainerMC = Obj.get("camera_area_mc",this) ;
			
			cameraMC = Obj.get("camera_area_mc",cameraContainerMC);
			
			
			imageAreaMC = Obj.get("image_area_mc",cameraContainerMC);
				imageAreaMC.visible = false ;
				
				
			ObjectAreaMC = Obj.get("object_area_mc",cameraContainerMC);
				ObjectAreaMC.visible = false ;
			ObjectMC = Obj.get("object_mc",cameraContainerMC);
				ObjectMC.visible = false ;
			//movedImageMC = Obj.get("croped_image_box_mc",cameraContainerMC);
				//movedImageMC.visible = false ;
			
			cW = imageAreaMC.width ;//cameraMC.width ;
			cH = imageAreaMC.height ;//cameraMC.height ;
			
			//debug line
				//cam = new MTeamCamera(cameraMC);
				//return;
			
			/*(care_txt as TextField).addEventListener(Event.CHANGE,function(e){
				ARManager.debug_tested_index = Number(care_txt.text);
			});
			ARManager.debug_tested_index = Number(care_txt.text);*/
			
			buttonMC = Obj.get("touch_mc",this);
			buttonMC.stop();
			//cameraMC.removeChildren();
			
			allContentButtonMC = Obj.get("all_contents_mc",this);
			allContentButtonMC.buttonMode = true ;
			allContentButtonMC.addEventListener(MouseEvent.CLICK,openAll);
			
			this.addChild(foundedObject);
			foundedObject.x = debugAreaMc.x ;
			foundedObject.y = debugAreaMc.y ;
			
		}
		
		private function openAll(e:MouseEvent)
		{
			var allPageData:PageData = myPageData.clone();
			allPageData.id = allPageData.id+'_all';
			allPageData.type = "DynamicLinks2";
			Contents.addSinglePageData(allPageData);
			var pageDataLink:LinkData = new LinkData();
			pageDataLink.level = -1 ;
			pageDataLink.id = allPageData.id ;
			
			this.dispatchEvent(new AppEventContent(pageDataLink));
		}
		
		protected function deactiveF(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			activeFlag = false ;
			buttonMC.gotoAndStop(1);
		}
		
		protected function activeF(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			activeFlag = true ;
			buttonMC.gotoAndStop(2);
		}
		
		protected function updateMyLinks(event:Event):void
		{
			// TODO Auto-generated method stub
			//myLinkCollector.deleteOldLinks();
			var pageData:PageData = new PageData();
			pageData.links1 = myLinkCollector.getListsByOrder();
			myDynamicLinks.setUp(pageData);
		}
		
		public function setUp(pageData:PageData):void
		{
			//return ;
			myPageData = pageData ;
			buttonMC.addEventListener(MouseEvent.MOUSE_DOWN,activeF);
			stage.addEventListener(MouseEvent.MOUSE_UP,deactiveF);
			
			ImagesW = pageData.contentW;
			ImagesH = pageData.contentH;
			
			camScalePrecent = ImagesW/cW; 
			
			var camWidth:Number = cameraMC.width*camScalePrecent ;
			var camHeight:Number = cameraMC.height*camScalePrecent ;
			
			//trace("ImagesW : "+ImagesW);
		//	trace("ImagesH : "+ImagesH);
			
			
			smoother = new Smoother(camWidth,camHeight,3);
			
			camBitData = new BitmapData(camWidth,camHeight,false);
			if(debug)
			{
				cameraFrame = new Bitmap(camBitData);
			}
			arManager = new ARManager(ImagesW,ImagesH);
			arManager.addEventListener(CompairEvent.MATCH,matchFounds);
			//this.addChild(arManager);
			if(debug)
			{
				this.addChild(cameraFrame);
				cameraFrame.x = cW*2 ;
			}
			
			arManager.addPatterns(pageData.links1);
			
			cam = new MTeamCamera(cameraMC);
			
			//Dibug listener
			//this.addEventListener(MouseEvent.CLICK,addOne);
			
			this.addEventListener(Event.ENTER_FRAME,compairAll);
		}
		
		private function matchFounds(e:CompairEvent)
		{
			if(e.difrences<12000/*Number(maxdifrence_txt.text)*/)
			{
				myLinkCollector.addLink(e.linkData,e.difrences);
				//trace("Link found : "+e.linkData.name+' > difences are : '+e.difrences);
			}
			//difrences_txt.text = e.difrences.toString();
		}
		
		protected function compairAll(event:Event):void
		{
			if(activeFlag)
			{
				var imageRect:Rectangle = imageAreaMC.getBounds(cameraContainerMC) ;
				imageRect.x = imageRect.x -cameraMC.x ;
				imageRect.y = imageRect.y -cameraMC.y ;
				imageRect = scaleRect(imageRect,camScalePrecent);

				var areaRect:Rectangle = ObjectAreaMC.getBounds(cameraContainerMC) ;
				areaRect.x = areaRect.x -cameraMC.x ;
				areaRect.y = areaRect.y -cameraMC.y ;
				areaRect = scaleRect(areaRect,camScalePrecent);
				
				var objectRect:Rectangle = ObjectMC.getBounds(cameraContainerMC) ;
				objectRect.x = objectRect.x -cameraMC.x ;
				objectRect.y = objectRect.y -cameraMC.y ;
				objectRect = scaleRect(objectRect,camScalePrecent);
				//trace("cjso");
				myLinkCollector.deleteOldLinks();
				// TODO Auto-generated method stub
				camBitData.lock();
				//trace("camScalePrecent : "+camScalePrecent);
				camBitData.draw(cameraMC,new Matrix(camScalePrecent,0,0,camScalePrecent));
				camBitData = smoother.smooth(camBitData);
				
				//trace("camBitData : "+camBitData.width);
				
				
				var correctColorBitmapData:BitmapData = BitmapEffect.colorBalanceGrayScale(camBitData);
				var blackAndWightBitmapData:BitmapData = BitmapEffect.blackAndWhite(correctColorBitmapData);
				
				
				/*var camImageBitmapdata:BitmapData = new BitmapData(cameraMC.width,cameraMC.height,false,0);
				camImageBitmapdata.draw(cameraMC);*/
				//foundedObject.bitmapData = blackAndWightBitmapData.clone() ;
				
				var images:Vector.<BitmapData> = BitmapEffect.matchImages(blackAndWightBitmapData,imageRect,areaRect,objectRect,correctColorBitmapData);
				
				foundedObject.bitmapData = images[0].clone() ;
				
				if(debug)
				{
					cameraFrame.bitmapData = camBitData ;
				}
				arManager.compair(images[0]);
				camBitData.unlock();
			}
		}
		
		private function scaleRect(rect:Rectangle,rectScale:Number=1):Rectangle
		{
			rect.x = rect.x*rectScale ;
			rect.y = rect.y*rectScale ;
			rect.width = rect.width*rectScale ;
			rect.height = rect.height*rectScale ;
			return rect ;
		}
			
		
		//Debug function
		protected function addOne(event:MouseEvent):void
		{
			// TODO Auto-generated method stub
			var ar:Vector.<LinkData> = new Vector.<LinkData>();
			ar.push(myPageData.links1[index]);
			arManager.addPatterns(ar);
			index++
		}
	}
}