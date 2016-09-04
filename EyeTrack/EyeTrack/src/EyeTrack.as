package
{
	import com.mteamapp.camera.MTeamCamera;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	import eyeTrack.camera.LightCamera;

	[SWF(width = "500", height = "500", frameRate = "60", backgroundColor = "#000000")]
	public class EyeTrack extends Sprite
	{
		private var camera:LightCamera ;
		
		public function EyeTrack()
		{
			super();
			
			//Create camera area
			camera = new LightCamera(500,500);
			this.addChild(camera);
			trace("Hi");
		}
	}
}