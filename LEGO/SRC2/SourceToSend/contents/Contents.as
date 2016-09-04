/***Version
 * 1.1 : Instant data.xml laoded
 * 
 */
package contents 
{
	import appManager.event.AppEvent;
	
	import contents.multiLanguage.Language;
	import contents.soundControll.ContentSoundManager;
	
	import flash.display.Stage;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;

	
	public class Contents
	{
		public static var eventDispatcher:ContentEventDispatcher = new ContentEventDispatcher();
		
		
		public static var homeID:String = AppEvent.home ;
		
		/**The only cause that these values are staing here is the old applications that used them from here.*/
		public static var 	id_music:uint = ContentSoundManager.MusicID,
							id_soundEffects:uint=ContentSoundManager.EffectsID;
		
	/////////////////////////////////////////////////////	
	
		public static const dataFile:String = "Data/data.xml";
		
		
		private static var loadedXML:XML,
							loader:URLLoader ;
							
		private static var onLoaded:Function ;
		
	////////////////////////////////////////////Language variables
		
		public static var 	lang:Language,
							langFile:String = "Data/language.xml",
							langEnabled:Boolean = false ;
		
		
	//////////////////////////////////////////////////////↓
					
		/**This will be true if debug tag is created on data.xml and it will be cause to update xml on each request*/
		private static var isDebug:Boolean = false ;
		
		private static var xmlLoadedOnce:Boolean = false ;
		
		private static var pages:Vector.<PageData>;
		private static var myStage:Stage;
		
		
		/**returns true if data is ready*/
		public static function get isReady():Boolean
		{
			if(loadedXML == null)
			{
				return false;
			}
			else
			{
				return true ;
			}
		}
		
		/**From this version, content.xml will load instantly and there is no need to wail till onLoaded function calls.<br>
		 * if your application is supporting multilanguages, you have to use language.xml standart near the content.xml file. and also 
		 * you have to set application stage here for the Language class to help it to find added elements to stage.*/
		public static function setUp(OnLoaded:Function=null,supportsMultiLanguage:Boolean=false,stage:Stage=null)
		{
			onLoaded = OnLoaded ;
			
			lang = new Language();
			
			langEnabled = supportsMultiLanguage ;
			myStage = stage ;
			
			
			loadLang();
			
			
			//Don't need to initialize OnLoaded, because it will controll on call method.
			/*if(OnLoaded==null)
			{
				onLoaded = new Function();
			}*/
			
			
			loadXML();
			
			/*loader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT ;
			loader.addEventListener(Event.COMPLETE,xmlLoaded);
			loader.load(new URLRequest(dataFile));*/
			
		}
		
		/**This function will controll the langEnabled, so be sure that you are calling it after langEnabled set*/
		private static function loadLang()
		{
			if(langEnabled)
			{
				lang.setUp(langFile,myStage);
			}
		}
		
		/**Load the xml file now*/
		private static function loadXML()
		{
			var fileLoader:FileStream = new FileStream();
			var fileTarger:File = File.applicationDirectory.resolvePath(dataFile);
			fileLoader.open(fileTarger,FileMode.READ);
			
			xmlLoaded(null,fileLoader.readUTFBytes(fileLoader.bytesAvailable));
		}
		
		/**xml file loaded*/
		private static function xmlLoaded(e:Event,myInstantData:String='')
		{
			if(myInstantData!='')
			{
				loadedXML = XML(myInstantData);
			}
			else
			{	
				loadedXML = XML(loader.data);
			}
			
			isDebug = loadedXML.hasOwnProperty('debug') ;
			
			pages = new Vector.<PageData>();
			
			for(var i = 0 ; i<loadedXML.page.length() ; i++)
			{
				var pageData:PageData = new PageData(loadedXML.page[i]);
				pages.push(pageData);
			}
			
			//You have to keep ides so you cannot override the names and titles once for all. it will distroy ides. so update it when getPage function calls.
			//controllLanguage();
			
			if(onLoaded!=null)
			{
				onLoaded() ;
			}
			onLoaded = null ;
			if(!xmlLoadedOnce)
			{
				eventDispatcher.dispatchEvent(new ContentsEvent());
			}
			xmlLoadedOnce = true ;
		}
		
		/**add these datas to pageContents*/
		public static function addMoreData(morePageDataOnXML:String)
		{
			//trace("morePageDataOnXML : "+morePageDataOnXML)
			var cashedXML = XMLList(morePageDataOnXML);
			
			//pages = new Vector.<PageData>();
			
			for(var i = 0 ; i<cashedXML.length() ; i++)
			{
				//trace('each page data : '+cashedXML[i]);
				var pageData:PageData = new PageData(cashedXML[i]);
				var pageFounds:Boolean = dropPage(pageData.id);
				//trace('page '+pageData.id+' added to content and it was there befor? '+pageFounds);
				pages.push(pageData);
			}
		}
		
		/**add this page Data*/
		public static function addSinglePageData(pageData:PageData)
		{
			var pageFounds:Boolean = dropPage(pageData.id);
			pages.push(pageData);
		}
		
		
		/**this will returns page data based on input id*/
		public static function getPage(pageID:String):PageData 
		{
			if(isDebug)
			{
				trace("Debug mode");
				loadLang();
				loadXML();
			}
			
			var foundedPage:PageData = new PageData();
			for(var i = 0 ; i<pages.length ;i++)
			{
				if(pages[i].id == pageID )
				{
					foundedPage = pages[i].clone();
				}
			}
			
			//This will update all contents with current language and it will controll for the existing of the language
			if(langEnabled)
			{
				var controller:String ;
				
				controller = lang.t[foundedPage.title];
				if(controller != null)
					foundedPage.title = controller ;
				controller = lang.t[foundedPage.content];
				if(controller != null)
					foundedPage.content = controller ;
				for(i = 0 ; i<foundedPage.links1.length ; i++)
				{
					controller = lang.t[foundedPage.links1[i].name];
					if(controller != null)
						foundedPage.links1[i].name = controller ;
				}
				for(i = 0 ; i<foundedPage.links2.length ; i++)
				{
					controller = lang.t[foundedPage.links2[i].name];
					if(controller != null)
						foundedPage.links2[i].name = controller ;
				}
				for(i = 0 ; i<foundedPage.images.length ; i++)
				{
					controller = lang.t[foundedPage.images[i].text];
					if(controller != null)
						foundedPage.images[i].text = controller ;
				}
			}
			return foundedPage;
		}
		
		/**remove pages with this id from the contents<br>
		 * tells if this page founded on pages conten xml or not*/
		private static function dropPage(pageID:String):Boolean
		{
			for(var i = 0 ; i<pages.length ;i++)
			{
				if(pages[i].id == pageID )
				{
					pages.splice(i,1);
					return true;
				}
			}
			return false;
		}
		
		/**this will returns lind , that will generate home page*/
		public static function get homeLink():LinkData
		{
			var homeLink:LinkData = new LinkData();
			homeLink.id = Contents.homeID ;
			homeLink.level = 0 ;
			return homeLink;
		}
		
		/**This function will returns the homePage data*/
		public static function get homePage():PageData
		{
			return getPage(homeID);
		}
		
		
		public static function exportAll():String
		{
			// TODO Auto Generated method stub
			var exports:String = '';
			for(var i = 0 ; i<pages.length ; i++)
			{
				exports += pages[i].export()+'\n';
			}
			return exports;
		}
		
		
	///////////////////////////////////////////// language functions
		/**This function will tells you if you have this language information or not*/
		public static function hasThisLanguage(languageID:String):Boolean
		{
			if(langEnabled)
			{
				return lang.hasThisLangID(languageID);
			}
			return false ;
		}
		
		
		/**This function will update the current language*/
		public static function changeLanguage(languageID:String):void
		{
			if(langEnabled)
			{
				trace("languageID  : "+languageID);
				lang.changeLanguage(languageID);
			}
			else
			{
				throw "Lanuage is not enabled yet.";
			}
		}
	}
}