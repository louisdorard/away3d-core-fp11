package away3d.textures
{
	import away3d.materials.utils.IVideoPlayer;
	
	public class ChangeableVideoTexture extends VideoTexture
	{
		public function ChangeableVideoTexture(player:IVideoPlayer, materialWidth:Number, materialHeight:Number, autoPlay:Boolean = false)
		{
			super(player.source, materialWidth, materialHeight, false, autoPlay, player, null, 15);
		}
		
		public function set player(p:IVideoPlayer):void
		{
			_player = p;
			update(true);
			// pause?
			// TODO check width & height stay the same, loop = false, and src has been defined
		}
	}
}