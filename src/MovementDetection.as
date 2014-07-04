package
{
	
	import Flave.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.PixelSnapping;
	import flash.display.Shader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.media.Camera;
	import flash.media.Video;
	
	import net.isotopo.movdetect.*;
	
	[SWF(width="320", height="240", framerate="120", backgroundColor="0xFFFFFF")]
	public class MovementDetection extends Sprite
	{
		public var w:World;
		protected var counter:uint = 0;
		protected var _particles:Array= new Array();
		protected var _polies:Array= new Array();
		protected var _camera:Camera = Camera.getCamera();
		protected var _video:Video = new Video(320,240);
		protected var _difBitmap:Bitmap = new Bitmap();
		protected var _cloneBitmap:Bitmap = new Bitmap();
		//protected var _drawer:IDrawer = new MovementDrawer(_video);
		//protected var _drawer:IDrawer = new DifferenceDrawer(_video);
		protected var _drawer:IDrawer = new ColorDrawer(_video);
		
		public function MovementDetection()
		{
			_cloneBitmap.bitmapData = new BitmapData( _video.width , _video.height , true );
			//_difBitmap.filters = [new BlurFilter()];
			_cloneBitmap.addEventListener(Event.ADDED_TO_STAGE, cloneAdded);
			_difBitmap.addEventListener(Event.ADDED_TO_STAGE, difAdded);
			_camera.addEventListener(Event.ACTIVATE, activateCamera);
			//addChild(_cloneBitmap);
			addChild(_difBitmap);
		}		
		
		protected function difAdded($evt:Event):void
		{
			_difBitmap.removeEventListener(Event.ADDED_TO_STAGE, difAdded);
			_video.attachCamera(_camera);
			loadBall();
		}
		protected function cloneAdded($evt:Event):void
		{			
			_cloneBitmap.removeEventListener(Event.ADDED_TO_STAGE, cloneAdded);
			_video.attachCamera(_camera);
			loadBall();
		}
		protected function activateCamera($evt:Event):void
		{
			//addChild(_difBitmap);
			_camera.removeEventListener(Event.ACTIVATE,activateCamera);
			addEventListener(Event.ENTER_FRAME, bucle);
		}
		protected function bucle($evt:Event):void
		{
			_difBitmap.bitmapData = _drawer.getDiffBitmapData();
			_cloneBitmap.bitmapData.draw(_video);
			if (w != null)
			{
				w.Step();
				w.Draw();
				if(counter++ ==1)
				{
					fixedParticles();
					counter = 0;
				}
			}
			
		}
		
		public function loadBall():void
		{
			if (w != null)
			{
				w.clearEverything();
			}
			w = new World();
			w.clipBounds = new Rectangle(0,0,_video.width,_video.height);
			w.grav = 0.05;
			addChild(w);
			
			// Flash Physics Toy v2
			// http://www.kongregate.com/accounts/luizzak
			//w.loadFromCode("conf,0,-575,5,5|p|3,180,770|4,40,150|c");
			var part1:Particle = w.addParticle(0,0,false,25);
			part1.mass = 10;
		}
		protected function fixedParticles():void
		{
			var coords:Array = _drawer.getBitmapCoords();
			var p:Point;
			var particle:Particle;
			removeFixedParticles();
			
			w.graphics.clear();
			/*
			var area : Rectangle = _difBitmap.bitmapData.getColorBoundsRect(0xFFFFFFFF, 0xFFFFFFFF, true);
			w.graphics.lineStyle(3,0x00FF00);
			w.graphics.drawRect(area.x,area.y,area.width,area.height);
			//w.graphics.drawRect(0,0,20,20);
			trace("area::",area);
			var ptl:Particle = w.addParticle(area.x,area.y,true,10);
			var ptr:Particle = w.addParticle(area.x+area.width,area.y,true,10);
			var pbl:Particle = w.addParticle(area.x,area.y+area.height,true,10);
			var pbr:Particle = w.addParticle(area.x+area.width,area.y+area.height,true,10);
			var poly:Polygon = w.addPoly([ptl,ptr,pbr,pbl],0xFF0000);
			
			_particles.push(ptl);
			_particles.push(ptr);
			_particles.push(pbr);
			_particles.push(pbl);
			_polies.push(poly);
			
			
			return;
			*/
			for(var i:uint = 0; i < coords.length; i++)
			{
				p = coords[i];
				particle = w.addParticle(p.x,p.y,true,1);
				particle.alpha = 1;
				_particles.push(particle);
			}
		}
		protected function removeFixedParticles():void
		{			
			for(var i:uint = 0; i < _particles.length; i++)
			{
				//w.removeParticle(_particles[i]);
				w.removeParticle(_particles[i]);
			}	
			for(var y:uint = 0; y < _polies.length; y++)
			{
				//w.removeParticle(_particles[i]);
				w.removePoly(_polies[i]);
			}
			
		}
	}
}