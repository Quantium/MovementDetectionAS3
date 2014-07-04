package net.isotopo.movdetect
{
	import com.gskinner.geom.ColorMatrix;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.media.Video;
	
	public class DifferenceDrawer implements IDrawer
	{
		
		protected var vData:BitmapData;		
		protected var sens:uint = 700000;
		protected var bloque:uint = 5;
		protected var _video:Video;
		protected var differences:Array;
		public function DifferenceDrawer($video:Video)
		{
			_video = $video;
			vData = new BitmapData( _video.width , _video.height , false , 0 );
		}	
		public function getDiffBitmapData():BitmapData
		{
			vData = new BitmapData(_video.width,_video.height,false,0x000000);
			vData.draw(_video,new Matrix(),new ColorTransform(),BlendMode.NORMAL);
			var bdat:BitmapData = getDifferences(vData);
			return bdat;
		}
		public function getBitmapCoords():Array
		{
			return differences;
		}
		protected function getDifferences(bdata1:BitmapData):BitmapData
		{			
			var pix1:uint;
			var pix2:uint;
			var retData:BitmapData = new BitmapData(bdata1.width,bdata1.height,true);
			
			retData.draw(bdata1);
			
			retData.applyFilter(retData, retData.rect,new Point(),new ColorMatrixFilter(new ColorMatrix()));
			retData.applyFilter(retData, retData.rect,new Point(),new BlurFilter(15,15));
			retData.draw(bdata1,null,null,BlendMode.DIFFERENCE);
			
			retData.threshold(retData,retData.rect,new Point(),">", 0xFF333333, 0xFFFFFFFF);
			
			const rc:Number = 1/3, gc:Number = 1/3, bc:Number = 1/3;
			retData.applyFilter(retData, retData.rect, new Point(), new ColorMatrixFilter([rc, gc, bc, 0, 0,rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));
			
			
			differences = new Array();
			for(var px:uint = 0; px < retData.width; px+=bloque)
			{
				for(var py:uint = 0; py < retData.height; py+=bloque)
				{
					pix1 = retData.getPixel32(px,py);
					if ( pix1 < 0xFFDDDDDD)
					{
						retData.setPixel32(px,py,0xFF000000);
						differences.push( new Point( px , py ) );
					}
				}
			}
			return retData;
		}
		protected function pixelFull(retD:BitmapData,px:uint,py:uint,bdat:BitmapData):void
		{
			retD.setPixel(px,py,bdat.getPixel32(px,py));
		}
		protected function pixelBlack(retD:BitmapData,px:uint,py:uint,bdat:BitmapData):void
		{
			retD.setPixel(px,py,0xFF000000);
		}
		protected function pixelRed(retD:BitmapData,px:uint,py:uint,bdat:BitmapData):void
		{
			retD.setPixel(px,py,0xD91807);
		}
	}
}