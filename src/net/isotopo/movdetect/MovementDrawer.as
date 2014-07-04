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

	public class MovementDrawer implements IDrawer
	{
		protected var oldData:BitmapData;
		protected var newData:BitmapData;		
		protected var sens:uint = 700000;
		protected var bloque:uint = 2;
		protected var _video:Video;
		protected var differences:Array;
		public function MovementDrawer($video:Video)
		{
			_video = $video;
			oldData = new BitmapData( _video.width , _video.height , false , 0 );
			newData = new BitmapData( _video.width , _video.height , false , 0 ); 
		}	
		public function getDiffBitmapData():BitmapData
		{
			oldData = new BitmapData(_video.width,_video.height,false,0x000000);
			oldData.draw(_video,new Matrix(),new ColorTransform(),BlendMode.NORMAL);
			var bdat:BitmapData = getDifferences(oldData,newData);
			newData.copyPixels( oldData , newData.rect , new Point( 0 , 0 ) );
			return bdat;
		}
		public function getBitmapCoords():Array
		{
			return differences;
		}
		protected function getDifferences(bdata1:BitmapData, bdata2:BitmapData):BitmapData
		{
			
			var pix1:uint;
			var pix2:uint;
			var retData:BitmapData = new BitmapData(bdata1.width,bdata1.height,true);
			
			retData.draw(bdata1);
			retData.draw(bdata2,null,null,BlendMode.DIFFERENCE);
			
			retData.applyFilter(retData, retData.rect,new Point(),new ColorMatrixFilter(new ColorMatrix()));
			retData.applyFilter(retData, retData.rect,new Point(),new BlurFilter(15,15));
			
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
		protected function getDifferences2(bdata1:BitmapData, bdata2:BitmapData, f:Function):BitmapData
		{			
			var pix1:uint;
			var pix2:uint;
			var retData:BitmapData = new BitmapData(bdata1.width,bdata1.height,true);
			retData.copyPixels( bdata1 , bdata1.rect , new Point() );
			differences = new Array();
			for(var px:uint = 0; px < bdata1.width; px+=bloque)
			{
				for(var py:uint = 0; py < bdata1.height; py+=bloque)
				{
					pix1 = bdata1.getPixel(px,py);
					pix2 = bdata2.getPixel(px,py);
					if ( Math.abs( pix1 - pix2 ) > sens )
					{
						f(retData,px,py,bdata1);
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