package appManager.event
{
	import contents.Contents;
	import contents.LinkData;
	import contents.PageData;

	/**This event is using when application has contents*/
	public class AppEventContent extends AppEvent
	{
		public static var currentLink:LinkData;
		
		public static var history:Vector.<LinkData> ;
		
		public var linkData:LinkData;
		
		public var pageData:PageData ;
		
		//public var myID:String ;
		
		public function AppEventContent(pageLink:LinkData,skipHistory:Boolean = false)
		{
			
			linkData = currentLink = pageLink ;
			
			resetHistory();
			
			if(pageLink.id == home)
			{
				pageLink.level = 0 ;
			}
			
			//trace('currentLink.level : '+currentLink.level+' - '+currentLink.id);
			if(!skipHistory)
			{
				if(currentLink.level==-1)
				{
					history.push(currentLink);
				}
				else
				{
					//trace("♠ split : "+currentLink.level+' , '+history.length+' - '+currentLink.level);
					history.splice(currentLink.level/*-1*/,Math.max(history.length-currentLink.level/*+1*/,0));
					history.push(currentLink);
				}
			}
			//trace('find page data for : '+pageLink.id);
			pageData = Contents.getPage(pageLink.id);
			
			//trace("what is the id : "+pageLink.id);
			
			//trace('finded pageData : '+pageData);
			
			super(pageData.type, PAGE_CHANGES,pageLink.id);
			
			/*for(var i = 0 ; i<history.length ; i++)
			{
				trace('history['+i+'] : '+history[i].id);
			}*/
		}
		
		private static function resetHistory():void
		{
			// TODO Auto Generated method stub
			
			if(history==null)
			{
				history = new Vector.<LinkData>();
				
				history.push(Contents.homeLink);
			}
		}
		
		/**return current page*/
		public static function get currentPage():String
		{
			if(currentLink!=null)
			{
				return currentLink.id;
			}
			else
			{
				return Contents.homeID;
			}
		}
		
		/**You can predect if back is availabe*/
		public static function backAvailable():Boolean
		{
			//trace("history : "+JSON.stringify(history));
			//This situation will not ocure on any pages but home
			if(history!=null && ( history.length>1 /*|| (history.length>0 && history[0].id == home)*/))
			{
				return true ;
			}
			else
			{
				return false ;
			}
		}
		
		/**returns lastPageEvent*/
		public static function lastPage():AppEventContent
		{
			//trace("dispatch last page");
			/*for(var i = 0 ; i<history.length ; i++)
			{
				trace('history['+i+'] : '+history[i].id);
			}*/
			resetHistory()
			
			if(history.length>1)
			{
				history.pop();
				return new AppEventContent(history[history.length-1],true);
			}
			else
			{
				return new AppEventContent(Contents.homeLink,true);
			}
		}
	}
}