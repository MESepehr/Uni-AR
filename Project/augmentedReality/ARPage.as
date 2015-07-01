package augmentedReality
{
	import appManager.event.AppEventContent;
	
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
					camBitData:BitmapData,
					camScalePrecent:Number;
					
		private var buttonMC:MovieClip ;
					
		private var ImagesW:Number,ImagesH:Number;
		
		private var activeFlag:Boolean = false ;
		
		private var allContentButtonMC:MovieClip ;
		
		public function ARPage()
		{
			super();
			
			myDynamicLinks = Obj.findThisClass(DynamicLinks,this,true);
			
			myLinkCollector = new LinkCollector();
			myLinkCollector.addEventListener(Event.CHANGE,updateMyLinks);
			updateMyLinks(null);
			cameraMC = Obj.get("camera_area_mc",Obj.get("camera_area_mc",this));
			cW = cameraMC.width ;
			cH = cameraMC.height ;
			
			(care_txt as TextField).addEventListener(Event.CHANGE,function(e){
				ARManager.debug_tested_index = Number(care_txt.text);
			});
			ARManager.debug_tested_index = Number(care_txt.text);
			
			buttonMC = Obj.get("touch_mc",this);
			buttonMC.stop();
			//cameraMC.removeChildren();
			
			allContentButtonMC = Obj.get("all_contents_mc",this);
			allContentButtonMC.buttonMode = true ;
			allContentButtonMC.addEventListener(MouseEvent.CLICK,openAll);
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
			trace("linkd updated");
			var pageData:PageData = new PageData();
			pageData.links1 = myLinkCollector.getListsByOrder();
			myDynamicLinks.setUp(pageData);
		}
		
		public function setUp(pageData:PageData):void
		{
			myPageData = pageData ;
			buttonMC.addEventListener(MouseEvent.MOUSE_DOWN,activeF);
			stage.addEventListener(MouseEvent.MOUSE_UP,deactiveF);
			
			ImagesW = pageData.contentW;
			ImagesH = pageData.contentH;
			
			trace("ImagesW : "+ImagesW);
			trace("ImagesH : "+ImagesH);
			
			camScalePrecent = ImagesW/cW; 
			
			smoother = new Smoother(ImagesW,ImagesH,5);
			
			camBitData = new BitmapData(ImagesW,ImagesH,false);
			if(debug)
			{
				cameraFrame = new Bitmap(camBitData);
			}
			
			arManager = new ARManager(ImagesW,ImagesH);
			arManager.addEventListener(CompairEvent.MATCH,matchFounds);
			this.addChild(arManager);
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
			if(e.difrences<Number(maxdifrence_txt.text))
			{
				myLinkCollector.addLink(e.linkData,e.difrences);
				trace("Link found : "+e.linkData.name+' > difences are : '+e.difrences);
			}
			difrences_txt.text = e.difrences.toString();
		}
		
		protected function compairAll(event:Event):void
		{
			if(activeFlag)
			{
				//trace("cjso");
				myLinkCollector.deleteOldLinks();
				// TODO Auto-generated method stub
				camBitData.lock();
				camBitData.draw(cameraMC,new Matrix(camScalePrecent,0,0,camScalePrecent));
				camBitData = smoother.smooth(camBitData);
				if(debug)
				{
					cameraFrame.bitmapData = camBitData ;
				}
				arManager.compair(camBitData);
				camBitData.unlock();
			}
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