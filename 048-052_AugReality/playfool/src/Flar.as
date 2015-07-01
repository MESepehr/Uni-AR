package {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.utils.ByteArray;
	
	import org.libspark.flartoolkit.core.FLARCode;
	import org.libspark.flartoolkit.core.param.FLARParam;
	import org.libspark.flartoolkit.core.raster.rgb.FLARRgbRaster_BitmapData;
	import org.libspark.flartoolkit.core.transmat.FLARTransMatResult;
	import org.libspark.flartoolkit.detector.FLARSingleMarkerDetector;
	import org.libspark.flartoolkit.pv3d.FLARBaseNode;
	import org.libspark.flartoolkit.pv3d.FLARCamera3D;
	import org.papervision3d.lights.PointLight3D;
	import org.papervision3d.materials.BitmapMaterial;
	import org.papervision3d.materials.utils.MaterialsList;
	import org.papervision3d.objects.primitives.Cube;
	import org.papervision3d.render.BasicRenderEngine;
	import org.papervision3d.scenes.Scene3D;
	import org.papervision3d.view.Viewport3D;
	
	
	//1
	[SWF(width="640", height="480", framerate="30", backgroundColor="#FFFFFF")]
	
	public class Flar extends Sprite
	{
	
	
	[Embed(source="material2.jpg")]
	private var Matt:Class;
	
	[Embed(source="pat1.pat", mimeType="application/octet-stream")]
	private var pattern:Class;
	[Embed(source="camera_para.dat", mimeType="application/octet-stream")]
	private var params:Class;
	
	//2
	// Flar toolkit	
	private var fparams:FLARParam;
	private var mpattern:FLARCode;
	// Camera
	private var vid:Video;
	private var cam:Camera;	
	
	//3
	// bitmap data 	
	private var bmd:BitmapData;
	// mappers
	private var raster:FLARRgbRaster_BitmapData;
	private var detector:FLARSingleMarkerDetector;
	
	//4
	// PV3D
	private var scene:Scene3D;
	private var camera:FLARCamera3D;
	private var container:FLARBaseNode;
	private var vp:Viewport3D;
	private var bre:BasicRenderEngine;
	// Transfermation results // holds the new 3d data
	private var trans:FLARTransMatResult;

//5	
		public function Flar()
		{
			setupFLAR();
			setupCamera();
			setupBitmap();
			setupPV3D();
			addEventListener(Event.ENTER_FRAME, loop);
		}
	
	//6	
		private function setupFLAR():void
		{
			fparams = new FLARParam();
			fparams.loadARParam(new params() as ByteArray);
			mpattern = new FLARCode(16, 16);
			mpattern.loadARPatt(new pattern());
						
		}
		//7
		private function setupCamera():void
		{
			vid = new Video(640, 480);	
			cam = Camera.getCamera();
			cam.setMode(640, 480, 15);
			vid.attachCamera(cam);
			addChild(vid);			
		}
		//8
		private function setupBitmap():void
		{
			bmd = new BitmapData(640, 480);
			bmd.draw(vid);
			//mappers
			raster = new FLARRgbRaster_BitmapData(bmd);
			detector = new FLARSingleMarkerDetector(fparams, mpattern, 80);
		}
		//9
		private function setupPV3D():void
		{
			scene = new Scene3D();
			camera = new FLARCamera3D(fparams);
			container = new FLARBaseNode();
			scene.addChild(container);
		//10	
			var pl:PointLight3D = new PointLight3D();
			pl.x = pl.y = 1000;
			pl.z = -1000;
			
			var matt:BitmapMaterial = new BitmapMaterial(((new Matt()) as Bitmap).bitmapData);
			var ml:MaterialsList = new MaterialsList({all:matt});
		
			
		
			var cube:Cube = new Cube(ml, 50,50,50);
			
			cube.z = 100;
			container.addChild(cube);
		
			
			/*
			// Adding a 3D model
			var model:DAE = new DAE();
			model.load("cow/models/model.dae");
			model.scale= 70;
			model.z = 10;
			model.rotationX = 90;
			
			
			 
			var modelHolder:DisplayObject3D = new DisplayObject3D();
			
			modelHolder.addChild(model); 
			
			container.addChild(modelHolder)
			
			
			*/
			//12
			bre = new BasicRenderEngine();
			
			trans = new FLARTransMatResult();
			
			vp = new Viewport3D();
			addChild(vp);
			
	
				
		}
		//13
		private function loop(evt:Event):void
		{
			bmd.draw(vid);
			// check to see if match the pattern
		try
		{
			if(detector.detectMarkerLite(raster, 80) && detector.getConfidence()> 0.5)
			{
				// get transfor matrix
				detector.getTransformMatrix(trans);
				// set transformation matrix
				container.setTransformMatrix(trans);
				// render 3D
				bre.renderScene(scene, camera, vp);
				
			}
			
		} catch(e:Error){}	
		}	
		
	}
}
