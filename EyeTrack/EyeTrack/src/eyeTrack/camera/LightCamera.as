package eyeTrack.camera
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	
	public class LightCamera extends Sprite
	{
		private var vid:Video ;
		
		private var cam:Camera ;
		
		private var W:Number,H:Number;
		
		public function LightCamera(Width:Number,Height:Number)
		{
			super();
			
			W = Width ;
			H = Height ;
			
			vid = new Video(Width,Height);
			this.addChild(vid);
			
			this.addEventListener(Event.ADDED_TO_STAGE,onAdded);
		}
		
		protected function onAdded(event:Event):void
		{
			cam = Camera.getCamera(null);
			//cam.setMode(Math.floor(W),Math.floor(H),24,true);
			//cam.setQuality(0,100);
			vid.attachCamera(cam);
		}
	}
}