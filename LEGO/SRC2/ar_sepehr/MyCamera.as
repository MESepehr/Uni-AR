package  ar_sepehr
	//ar_sepehr.MyCamera
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.media.Camera;
	import flash.media.Video;
	
	public class MyCamera extends EventDispatcher
	{
		public static const CAM_UPDATED:String = "CAM_UPDATED" ;
		
		/**its looks like you can not have boteh cameras to gather */
		private var camera:Camera;
		
		private var vid:Video;
		
		private var currentCamera:String;
		
		public static var firstCamID:String = '0',
			secondCamID:String = '1';
		
		private var targ:MovieClip,
		targWidth:Number,
		targHeight:Number,
		targMask:MovieClip;
		
		/**this will cause to mask the camera under the target area*/
		private var enableMask:Boolean = true;
		
		private var camWidth:Number,
		camHeight:Number;
		
		private var landScape:Boolean = true ;
		
		public static var dont_controll_portrate_screen:Boolean = false ;
		
		public function MyCamera(target:MovieClip,selctedCameraID:String='')
		{
			if(selctedCameraID=='')
			{
				currentCamera = firstCamID ;
			}
			else
			{
				currentCamera = selctedCameraID ;
			}
			
			
			targ = target ;
			targWidth = targ.width ;
			targHeight = targ.height;
			
			if(DevicePrefrence.isItPC || dont_controll_portrate_screen || target.stage.stageWidth > target.stage.stageHeight)
			{
				landScape = true ;
			}
			else
			{
				landScape = false ;
			}
			
			if(landScape)
			{
				camWidth = targ.getBounds(target.stage).width*2;
				camHeight = targ.getBounds(target.stage).height*2;
			}
			else
			{
				camHeight = targ.getBounds(target.stage).width*2;
				camWidth = targ.getBounds(target.stage).height*2;
			}
			
			//remove every thing↓
			targ.removeChildren();
			
			//add video ↓
			vid = new Video();
			if(!landScape)
			{
				vid.rotation = 90 ;
			}
			targ.addChild(vid);
			
			targMask = new MovieClip();
			if(enableMask)
			{
				targMask.graphics.beginFill(0);
			}
			else
			{
				targMask.graphics.lineStyle(0,0);
			}
			targMask.graphics.lineTo(targWidth,0);
			targMask.graphics.lineTo(targWidth,targHeight);
			targMask.graphics.lineTo(0,targHeight);
			targMask.graphics.lineTo(0,0);
			targMask.graphics.endFill();
			
			//add mask ↓
			targ.addChild(targMask);
			
			
			//set mask ↓
			if(enableMask)
			{
				vid.mask = targMask;
			}
			
			setCurrentCam();
			
			targ.addEventListener(MouseEvent.CLICK,switchCameras);
		}
		
		/**set up camera*/
		private function setCurrentCam()
		{
			camera = Camera.getCamera(currentCamera);
			
			if(camera!=null){
				camera.setQuality(0,100);
				camera.addEventListener(Event.VIDEO_FRAME,telUpdate);
				var camScale:Number = Math.max((camWidth/camera.width),(camHeight/camera.height));
				
				camera.setMode(Math.floor(camera.width*camScale),Math.floor(camera.height*camScale),24,true);
				vid.attachCamera(camera);
				
				if(landScape)
				{
					vid.width = targWidth ;
					vid.height = targHeight ;
				}
				else
				{
					vid.height = targWidth ;
					vid.width = targHeight ;
				}
				
				//debug line
				//vid.height = 1000;
				
				vid.scaleX = vid.scaleY = Math.max(vid.scaleX,vid.scaleY);
				if(landScape)
				{
					vid.x = (targWidth-vid.width)/2;
					vid.y = (targHeight-vid.height)/2;
				}
				else
				{
					vid.x = targWidth-(targWidth-vid.width)/2;
					vid.y = (targHeight-vid.height)/2;
				}
			}
			else
			{
				trace("camera 1 is not ready");
			}
		}
		
		protected function telUpdate(event:Event):void
		{
			// TODO Auto-generated method stub
			//trace("cameras Updated");
			this.dispatchEvent(new Event(CAM_UPDATED));
			targ.dispatchEvent(new Event(CAM_UPDATED));
		}
		
		////////////////////////////////////public functions ↓
		
		/**switch cameras*/
		public function switchCameras(e:MouseEvent=null)
		{
			trace("switch cameras")
			if(currentCamera == firstCamID)
			{
				currentCamera = secondCamID ;
			}
			else
			{
				currentCamera = firstCamID ;
			}
			setCurrentCam();
		}
		
		/**returns current bitmap data*/
		public function getBitmapData():BitmapData
		{
			var bd:BitmapData = new BitmapData(targWidth,targHeight,false,0);
			bd.draw(targ);
			return bd;
		}
		
		/**tells if camera supported on this device*/
		public static function get isSupported():Boolean
		{
			var testCamera:Camera = Camera.getCamera(firstCamID);
			
			return Camera.isSupported && (testCamera!=null) ;
		}
		
	}
}