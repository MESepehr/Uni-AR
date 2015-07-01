package augmentedReality.ar
{
	import contents.LinkData;
	
	import flash.events.Event;
	
	
	public class CompairEvent extends Event
	{
		public static const MATCH:String = "MATCH" ;
		
		
		public var linkData:LinkData ;
		public var difrences:uint ;
		
		public function CompairEvent(type:String,link:LinkData,dif:uint)
		{
			linkData = link ;
			difrences = dif ;
			super(type);
		}
	}
}