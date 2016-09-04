package lego.pages
{
	import contents.PageData;
	import contents.interFace.DisplayPageInterface;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import videoPlayer.myVideoPlayer;
	
	public class videoPage extends MovieClip implements DisplayPageInterface
	{
		public function videoPage()
		{
			super();
			this.addEventListener(Event.REMOVED_FROM_STAGE,unLoad);
		}
		
		protected function unLoad(event:Event):void
		{
			// TODO Auto-generated method stub
			myVideoPlayer.close();
		}
		
		public function setUp(pageData:PageData):void
		{
			myVideoPlayer.playeMyVideo(pageData.imageTarget);
		}
	}
}