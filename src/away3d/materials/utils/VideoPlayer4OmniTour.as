package away3d.materials.utils
{
	import flash.events.Event;
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
		private var fps:int = 15;
		private var loaded:Boolean = false;
		
		private var onVideoLoaded:Function;
		
		public function VideoPlayer4OmniTour(source:String, serverAddress:String = null, nc:NetConnection = null, onEnterFrame:Function = null, onVideoLoaded:Function = null)
		{
			super(source, serverAddress, nc);
			this.onVideoLoaded = onVideoLoaded;
			// TODO listen for events on netstream and launch methods specified to constructor
			_video.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		}
		
		override protected function onNetConnectionSuccess():void
		{
			super.onNetConnectionSuccess();
			mute = true;
			_ns.inBufferSeek = true; // required for smart seeking and using the step() method
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
		
		public function get nc():NetConnection{
			return _nc;
		}
		
		public function getCurrentFrameNumber():int
		{
			return int(time * fps);
		}
		
	}
}