package
{
	import appManager.mains.AppWithContent;
	
	import flash.display.Sprite;
	
	import myAsCSS.MyAsCSS;
	
	public class LEGO_AR extends AppWithContent
	{
		public function LEGO_AR()
		{
			super();
			
			trace("In the name of God");
			
			MyAsCSS.beginCSSWorks(stage,768,1400);
			MyAsCSS.managePlace("back_mc_css",false,true,false,true);
			MyAsCSS.managePlace("top_menu_css",true);
			MyAsCSS.managePlace("buttom_mc_css",true);
			MyAsCSS.managePlace("titile_css",true);
			MyAsCSS.managePlace("pages_css",true);
		}
	}
}