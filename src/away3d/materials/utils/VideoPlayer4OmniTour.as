package away3d.materials.utils
{
	import flash.net.NetConnection;

	/**
	 * Video player adapted for use in OmniTour:
	 * - listens for events on netstream: video loaded, reaching start/end of video
	 * - mutes video and no autoplay
	 * - enables smart seeking for stepping through frames
	 * @author louis
	 * 
	 */
	public class VideoPlayer4OmniTour extends SimpleVideoPlayer
	{
		private var loaded:Boolean = false;
		public function VideoPlayer4OmniTour(source:String, serverAddress:String = null, nc:NetConnection = null, onVideoStart:Function = null, onVideoEnd:Function = null, onVideoLoaded:Function = null)
		{
			super(source, serverAddress, nc);
			// TODO listen for events on netstream and launch methods specified to constructor
			if (onVideoStart != null) addEventListener("", onVideoStart);
			if (onVideoEnd != null) addEventListener("", onVideoEnd);
			if (onVideoLoaded != null) addEventListener("", onVideoLoaded);
		}
		
		override protected function onNetConnectionSuccess():void
		{
			super.onNetConnectionSuccess();
			mute = true;
			_ns.inBufferSeek = true; // required for smart seeking and using the step() method
			pause();
		}
		
		
		public function resumeLoading():void{
			if (!loaded)
			{
				// start loading if we have never started before
				// do something
			}
		}
		
		public function stopLoading():void{
			
		}
		
		/**
		 * Steps forward or back the specified number of frames. 
		 */
		public function step(frames:int):void
		{
			_ns.step(frames);
		}
		
		
		/**
		 * Indicates whether displayed data is cached for smart seeking (TRUE), or not (FALSE)
		 */
		public function get inBufferSeek():Boolean{
			return _ns.inBufferSeek;
		}
		
	}
}