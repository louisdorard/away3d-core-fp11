package away3d.textures
{
	import away3d.materials.utils.SimpleVideoPlayer;
	
	public class ChangeableVideoTexture extends VideoTexture
	{	
		public function ChangeableVideoTexture(player:SimpleVideoPlayer, materialWidth:Number, materialHeight:Number)
		{
			super(player.source, materialWidth, materialHeight, false, false, player, null, 15);
		}
		
		public function set player(p:SimpleVideoPlayer):void
		{
			_player = p;
			_player.width = materialWidth;
			_player.height = materialHeight;
			// update(true);
			// pause?
			// TODO check width & height stay the same, loop = false, and src has been defined
		}
	}
}