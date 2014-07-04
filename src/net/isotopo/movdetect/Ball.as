package net.isotopo.movdetect
{
	import flash.display.Sprite;
	
	public class Ball extends Sprite
	{
		public function Ball()
		{
			graphics.beginFill(0x0000FF);
			graphics.drawCircle(20,20,20);
			graphics.endFill();
		}
	}
}