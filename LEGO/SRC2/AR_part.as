package
{
	import augmentedReality.ARPage;
	
	import contents.Contents;
	
	import flash.display.Sprite;
	
	public class AR_part extends Sprite
	{
		
		public function AR_part()
		{
			super();
			Contents.setUp();
			
			var arPage:ARPage = Obj.findThisClass(ARPage,this);
			arPage.setUp(Contents.getPage("ar_page"));
		}
	}
}