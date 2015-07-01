package augmentedReality.dataManager
{
	import contents.LinkData;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	[Event(name="change", type="flash.events.Event")]
	
	public class LinkCollector extends EventDispatcher
	{
		private var collectedLinks:Vector.<LinkDataPriority>;
					
		private var removeAfter:uint ;
					
		private var linksUpdated:Boolean ;
		
		public function LinkCollector(RemoveAfter:uint = 10000)
		{
			collectedLinks = new Vector.<LinkDataPriority>();
			removeAfter = RemoveAfter ;
		}
		
		
		public function addLink(linkData:LinkData,order:Number):void
		{
			linksUpdated = true ;
			var index:uint = collectedLinks.length ;
			for(var i = 0 ; i<collectedLinks.length ; i++)
			{
				if(collectedLinks[i].linkData.id == linkData.id)
				{
					//This is duplicated link
					linksUpdated = false;
					index = i ;
					break ;
				}
			}
			collectedLinks[index] = new LinkDataPriority(linkData,order,getTimer()+removeAfter);
			
			collectedLinks.sort(sort);
			
			if(linksUpdated)
			{
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		
		private function sort(A:LinkDataPriority,B:LinkDataPriority):int
		{
			if(Math.abs(A.priority-B.priority)<100)
			{
				return 0;
			}
			else if(A.priority<B.priority)
			{
				linksUpdated = true ;
				return -1 ;
			}
			else
			{
				linksUpdated = true ;
				return 1 ;
			}
		}
		
		public function deleteOldLinks()
		{
			var currentTime:uint = getTimer();
			var UpdateNeeded:Boolean = false ;
			for(var i = 0 ; i<collectedLinks.length ; i++)
			{
				if(collectedLinks[i].deleteTime < currentTime)
				{
					UpdateNeeded = true ;
					collectedLinks.splice(i,1);
					i--;
				}
			}
			if(UpdateNeeded)
			{
				this.dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		
		public function getListsByOrder():Vector.<LinkData>
		{
			var links:Vector.<LinkData> = new Vector.<LinkData>();
			for(var i = 0 ; i<collectedLinks.length ; i++)
			{
				links.push(collectedLinks[i].linkData);
			}
			return links;
		}
	}
}