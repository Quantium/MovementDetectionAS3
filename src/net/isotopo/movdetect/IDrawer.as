package net.isotopo.movdetect
{
	import flash.display.BitmapData;

	public interface IDrawer
	{
		function getDiffBitmapData():BitmapData;
		function getBitmapCoords():Array;
	}
}