package dataManager
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	/**none encripted sql db*/
	public class SavedDatas2
	{
		private static var  sql:SQLConnection ,
							query:SQLStatement;
							
		private static const tableBaseName:String = "SAVED_DATA";
		
		private static var 	dbFolder:String = "DB",
							dbName:String = "saves2",
							tableName:String = tableBaseName,
							field_id:String = "ID",
							field_value:String = "VALUE",
							field_date:String = "DATE";
		
		//private static var systemCode:String ;
		
		/**it is object of objects with data and time parameters on each of them<br>
		 * {{data:-,time:-},{data:-,time:-}}*/
		//private static var temporaryObject:Object ;
		
		
		
		
		/**return true if the offline date number is not old*/
		private static function maxOfflineDate(offlineDate:Number,lastAcceptableDate:Date):Boolean
		{
			if(lastAcceptableDate == null)
			{
				//set the last acceptable date
				lastAcceptableDate = new Date();
				lastAcceptableDate.hours--;
			}
			if(offlineDate < lastAcceptableDate.time)
			{
				return false ;
			}
			else
			{
				return true ;
			}
		}
		
		/**Change the table name for this special user*/
		public static function setTableName(tableNameTitle:String='')
		{
			tableName = tableBaseName+tableNameTitle;
			trace("new table name is : "+tableName);
			setUp();
		}
		
		
		
		
		
		public static function setUp(checkTable:Boolean = false)
		{
			if(sql == null)
			{
				checkTable = true ;
				//temporaryObject = {};
				var sqlFile:File = File.applicationStorageDirectory.resolvePath(dbFolder);
				if(!sqlFile.exists)
				{
					sqlFile.createDirectory() ;
				}
				sqlFile = sqlFile.resolvePath(dbName);
				
				/*var encrypt:ByteArray = new ByteArray();
				encrypt.writeUTFBytes(setOrGetDeviceCode().substring(0,16));*/
				
				sql = new SQLConnection();
				sql.open(sqlFile,SQLMode.CREATE);
				
				query = new SQLStatement();
				
				
				
				query.sqlConnection = sql ;
				
			}
			if(checkTable)
			{
				try
				{
					query.text = "create table "+tableName+" ("+field_id+" VARCHAR(1) , "+field_value+" BLOB , "+field_date+" INT) ";
					query.execute();
					trace('table is creats');
				}
				catch(e)
				{
					trace('table was created');
				}
				
				try
				{
					query.text = "create index if not EXISTS "+tableName+"_indexes on "+tableName+" ("+field_id+");" ;
					query.execute() ;
					trace('index is creates') ;
				}
				catch(e)
				{
					trace('Create index problem') ;
				}
			}
		}
		
		
		/**save stringifi value for this id on data base*/
		public static function save(id:String,data:*):void
		{
			setUp();
			//trace("save this data : "+data);
			//hint : if data is nul , it will cause to skip this function ,at the bigining of the app job , all temporaryObject variables are null
			var dateNum:Number = new Date().time;
			/*if(data!= null && temporaryObject[id]!=undefined && temporaryObject[id].data == data)
			{
				sql.begin();
				query.text = "update "+tableName+" set "+field_date+" = "+dateNum+" where "+field_id+" == "+id;
				try
				{
					query.execute();
					sql.commit();
					//trace(data+" saved");
				}
				catch(e)
				{
					sql.rollback();
				}
				//trace("temporaryObject[id] is : "+temporaryObject[id]);
				return ;
			}*/
			//trace("save this data2 : "+temporaryObject[id]);
			/*temporaryObject[id] = {} ;
			temporaryObject[id].data = data ;
			temporaryObject[id].time = dateNum ;*/
			sql.begin();
			query.clearParameters();
			query.text = "delete from "+tableName+" where "+field_id+" == '"+id+"'" ;
			try
			{
				query.execute();
			}
			catch(e){}
			//( "+field_id+" , "+field_value+" , "+field_date+" )
			query.text = "insert into "+tableName+"  values( @"+field_id+" , @"+field_value+" , "+dateNum+" )";
			query.parameters["@"+field_id] =  id ;
			query.parameters["@"+field_value] =  data ;
			
			//trace("query.text : "+query.text);
			try
			{
				query.execute();
				sql.commit();
				//trace(data+" saved");
			}
			catch(e)
			{
				sql.rollback();
			}
		}
		
		/**load the value if the value is new on data base*/
		public static function loadIfNewer(id,lastDate:Date=null):*
		{
			return load(id,lastDate);
			
			//setUp();
			//var check:Object = temporaryObject[id];
			/*if(check!=null && maxOfflineDate(check.time,lastDate))
			{
				return check.data;
			}*/
			
			//trace("it have to send query to db to detect the data");
			
			/*var dateTime:uint = lastDate.time ;
			
			query.text = "select "+field_value+" from "+tableName+" where "+field_id+" == @"+field_id;
			query.parameters["@"+field_id] = id ;
			try
			{
				query.execute();
				var result:SQLResult = query.getResult() ;
				if(result.data == null)
				{
					return null ;
				}
				else
				{
					//trace('result on query is : '+(result.data[0][field_value]==null)+' > check string : '+(result.data[0][field_value]=='null'));
					var res:* = result.data[0][field_value] ;
					if(res == 'null')
					{
						res = null ;
					}
					
					if(maxOfflineDate(result.data[0][field_date],lastDate))
					{
						return res ;
					}
					else
					{
						trace('saved Data is too old');
						return null ;
					}
				}
			}
			catch(e){}
			return null ;*/
		}
		
		
		/**load the value with this id if it saved befor<br>
		 * if no value founds , it will return null instead of some Stringifi data*/
		public static function load(id:String,lastAcceptableDate:Date=null):*
		{
			setUp();
			
			var dateControllQuery:String = '' ;
			if(lastAcceptableDate != null)
			{
				var lastDate:Number = lastAcceptableDate.time ;
				trace("requested date : "+lastDate);
				dateControllQuery = ' and '+field_date+" >= "+lastDate ;
			}
			//var check:Object = temporaryObject[id];
			/*if(check!=null)
			{
				return check.data;
			}*/
			
			//trace("it have to send query to db to detect the data");
			query.clearParameters();
			query.text = "select "+field_value+" from "+tableName+" where "+field_id+" == @"+field_id+dateControllQuery;
			query.parameters["@"+field_id] = id ;
			
			//trace("query.text  : "+query.text);
			try
			{
				query.execute();
				var result:SQLResult = query.getResult() ;
				if(result.data == null)
				{
					//trace("didnt found");
					return null ;
				}
				else
				{
					//trace("data founds : "+result.data[0]);
					//trace('result on query is : '+(result.data[0][field_value]==null)+' > check string : '+(result.data[0][field_value]=='null'));
					var res:* = result.data[0][field_value] ;
					return res ;
				}
			}
			catch(e)
			{
				trace("DB error : "+e);
			}
			return null ;
		}
		
		
		
		////////////////////////////////debug function for section id and mac id↓
		
	}
}

