package net.isotopo.movdetect
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Video;
	
	public class ColorDrawer implements IDrawer
	{
		protected var bData:BitmapData
		protected var newData:BitmapData;		
		protected var tolerance:uint = 0x00000A2;
		protected var bloque:uint = 1;
		protected var _video:Video;
		protected var differences:Array;
		
		protected var _color:uint = 0xFF0000FF;
		public function set color($c:uint):void
		{
			_color = $c;
		}
		public function get color():uint
		{
			return _color;
		}
		
		protected var _bgcolor:uint = 0xFF000000;
		public function set bgcolor($bg:uint):void
		{
			_bgcolor = $bg;
		}
		public function get bgcolor():uint
		{
			return _bgcolor;
		}
		public function ColorDrawer($video:Video)
		{
			_video = $video;
			bData = new BitmapData( _video.width , _video.height , false , _bgcolor );
		}		
		public function getDiffBitmapData():BitmapData
		{			
			bData = new BitmapData(_video.width,_video.height,false,_bgcolor);
			bData.draw(_video,new Matrix(),new ColorTransform(),BlendMode.NORMAL);
			var bdat:BitmapData = getColors();
			return bdat;
		}
		public function getBitmapCoords():Array
		{
			return differences;
		}
		protected function getColors():BitmapData
		{
			var retData:BitmapData = new BitmapData(bData.width,bData.height,true,0x00000000);
			retData.copyPixels( bData , bData.rect , new Point( 0 , 0 ) );
			differences = new Array();
			var clr:uint;
			var d:Number;
			for(var px:uint = 0; px < bData.width; px+=bloque)
			{
				for(var py:uint = 0; py < bData.height; py+=bloque)
				{
					clr = bData.getPixel32(px,py);
					d = getDistance(clr);
					//if(clr <= _color+tolerance && clr > _color-tolerance)
					if(d < tolerance)
					{
						//trace(clr.toString(16));
						retData.setPixel32(px,py,0xFFFFFFFF);
						differences.push( new Point( px , py ) );
					}
				}
			}
			return retData;
		}
		protected function getDistance($pixelColor:uint):Number
		{			
			var pixColor:ColorTransform = new ColorTransform();
			var lookedColor:ColorTransform = new ColorTransform();
			lookedColor.color = _color;
			pixColor.color = $pixelColor;
			var d:Number = Math.sqrt(Math.pow(pixColor.redOffset-lookedColor.redOffset,2) + Math.pow(pixColor.greenOffset-lookedColor.greenOffset,2) + Math.pow(pixColor.blueOffset-lookedColor.blueOffset,2));
			return d;
		}
	}
}