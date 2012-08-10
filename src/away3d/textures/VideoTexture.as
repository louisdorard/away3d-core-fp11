package away3d.textures
{
	import away3d.materials.utils.SimpleVideoPlayer;
	import away3d.tools.utils.TextureUtils;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	public class VideoTexture extends BitmapTexture
	{
		private var _broadcaster : Sprite;
		private var _autoPlay : Boolean;
		private var _autoUpdate : Boolean;
		private var _materialWidth : uint;
		private var _materialHeight : uint;
		protected var _player : SimpleVideoPlayer;
		private var _clippingRect : Rectangle;
		
		private var _currentTime:int;
		private var _lastTime:int = -100;
		private var _frameInterval:int;

		public function VideoTexture(source : String, materialWidth : uint = 256, materialHeight : uint = 256, loop : Boolean = true, autoPlay : Boolean = false, player : SimpleVideoPlayer = null, serverAddress : String = null, fps : int = 15)
		{
			_broadcaster = new Sprite();

			// validates the size of the video
			_materialWidth = materialWidth;
			_materialHeight = materialHeight;

			// this clipping ensures the bimapdata size is valid.
			_clippingRect = new Rectangle(0, 0, _materialWidth, _materialHeight);

			// assigns the provided player or creates a simple player if null.
			_player = player || new SimpleVideoPlayer(serverAddress);
			_player.loop = loop;
			_player.source = source;
			_player.width = _materialWidth;
			_player.height = _materialHeight;

			// sets autplay
			_autoPlay = autoPlay;
			
			// computes the time interval between consecutive frames, given the number of frames per second
			_frameInterval = int(1/fps * 10000);

			// Sets up the bitmap material
			super(new BitmapData(_materialWidth, _materialHeight, false, 0x00ffffff));

			// if autoplay, start video as soon as it's ready
			if (autoPlay)
				_player.addEventListener("ready", onPlayerReady);

			// auto update is true by default
			autoUpdate = true;
		}
		
		private function onPlayerReady(e:Event):void
		{
			_player.play();
		}

		/**
		 * Draws the video and updates the bitmap texture
		 * - If autoUpdate is false and this function is not called the bitmap texture will not update!
		 * - If the time measured by the player since the last update is smaller than the interframe time interval, then there is no new frame to be shown and therefore no update to be done.
		 * - We can force the update (when using the step method on the video for instance).
		 */
		public function update(force:Boolean = false) : void
		{
			
			if (_player.playing && !_player.paused || force) {
				_currentTime = int(_player.time*10000);
				if (Math.abs(_currentTime - _lastTime) >= _frameInterval || force) {
					_lastTime = _currentTime;
					bitmapData.lock();
					bitmapData.draw(_player.container, null, null, null, _clippingRect);
					bitmapData.unlock();
					invalidateContent();
				}
			}
			
		}
		
		override public function dispose() : void
		{
			super.dispose();
			autoUpdate = false;
			bitmapData.dispose();
			_player.dispose();
			_player = null;
			_broadcaster = null;
			_clippingRect = null;
		}

		private function autoUpdateHandler(event : Event) : void
		{
			update();
		}

		/**
		 * Indicates whether the video will start playing on initialisation.
		 * If false, only the first frame is displayed.
		 */
		public function set autoPlay(b : Boolean) : void
		{
			_autoPlay = b;
		}

		public function get autoPlay() : Boolean
		{
			return _autoPlay;
		}

		public function get materialWidth():uint
		{
			return _materialWidth;
		}

		public function set materialWidth(value:uint):void
		{
			_materialWidth = validateMaterialSize( value );
			_player.width = _materialWidth;
			_clippingRect.width = _materialWidth;
		}

		public function get materialHeight() : uint
		{
			return _materialHeight;
		}

		public function set materialHeight(value : uint) : void
		{
			_materialHeight = validateMaterialSize( value );
			_player.width = _materialHeight;
			_clippingRect.width = _materialHeight;
		}

		private function validateMaterialSize( size:uint ):int
		{
			if (!TextureUtils.isDimensionValid(size)) {
				var oldSize : uint = size;
				size = TextureUtils.getBestPowerOf2(size);
				trace("Warning: "+ oldSize + " is not a valid material size. Updating to the closest supported resolution: " + size);
			}

			return size;
		}

		/**
		 * Indicates whether the material will redraw onEnterFrame
		 */
		public function get autoUpdate():Boolean
		{
			return _autoUpdate;
		}

		public function set autoUpdate(value:Boolean):void
		{
			if (value == _autoUpdate) return;

			_autoUpdate = value;

			if(value)
				_broadcaster.addEventListener(Event.ENTER_FRAME, autoUpdateHandler, false, 0, true);
			else
				_broadcaster.removeEventListener(Event.ENTER_FRAME, autoUpdateHandler);
		}

		public function get player():SimpleVideoPlayer
		{
			return _player;
		}
	}
}
