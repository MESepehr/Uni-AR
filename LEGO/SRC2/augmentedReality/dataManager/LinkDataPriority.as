package augmentedReality.dataManager
{
	import contents.LinkData;

	public class LinkDataPriority
	{
		public var linkData:LinkData,
					priority:uint,
					deleteTime:uint;
		
		public function LinkDataPriority(link:LinkData,prior:uint,deleteOn:uint)
		{
			linkData = link;
			priority = prior;
			deleteTime = deleteOn ;
		}
	}
}