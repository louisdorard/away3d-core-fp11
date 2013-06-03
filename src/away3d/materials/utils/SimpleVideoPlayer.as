package away3d.materials.utils
{
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.getTimer;
	
	/**
	 * Plays a video locally or from a streaming server. When connection has been established, a "ready" event is dispatched. 
	 * @author Louis Dorard (louis@dorard.me)
	 * 
	 */
	public class SimpleVideoPlayer implements IVideoPlayer
	{
		
		private var _src:String;
		private var _video:Video;
		private var _fps:int;
		private var _nsm:NetStreamManager;
		private var _ns:NetStream;
		private var _nc:NetConnection; // used to create a netstream, if needed
		private var _netStreamProvided:Boolean = false;
		private var _netConnectionProvided:Boolean = false;
		private var _soundTransform:SoundTransform;
		private var _loop:Boolean;
		private var _playing:Boolean;
		private var _paused:Boolean;
		private var _lastVolume:Number;
		private var _container:Sprite;
		protected var _ready:Boolean = false;
		protected var _eventDispatcher:EventDispatcher = new EventDispatcher();
		
		public var verbose:Boolean = false;
		
		public function SimpleVideoPlayer(source:String = null, ns:NetStream = null , nsm:NetStreamManager = null)
		{
			_src = source;
			
			// default values
			_soundTransform = new SoundTransform();
			_loop = false;
			_playing = false;
			_paused = false;
			_lastVolume = 1;
			
			_video = new Video();
			
			// NetStream
			_nsm = nsm;
			_ns = ns;
			if (_ns != null)
			{
				_netStreamProvided = true;
				attach();
			} else {
				// NetConnection
				if (_nsm != null)
				{
					_netConnectionProvided = true;
				} else {
					_nsm = new NetStreamManager(null);
				}
				_nc = _nsm.nc;
				if (_nc.connected)
				{
					attach();
				} else {
					_nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
					_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
				}
			}
		}
		
		
		//////////////////////////////////////////////////////
		// public methods
		//////////////////////////////////////////////////////
		
		public function play():void
		{
			if(!_src)
			{
				trace("Video source not set.");
				return;
			}
			
			if(_paused)
			{
				_ns.resume();
				_paused = false;
				_playing = true;
			}
			else if(!_playing)
			{
				_ns.play(_src);
				_playing = true;
				_paused = false;
			}
		}
		
		public function pause():void
		{
			if(!_paused)
			{
				_ns.pause();
				_paused = true;
			}
		}
		
		public function seek(val:Number):void
		{
			pause();
			_ns.seek( val );
			_ns.resume();
		}
		
		public function stop():void
		{
			_ns.close();
			_playing = false;
			_paused = false;
		}
		
		public function dispose():void
		{
			if (!_netStreamProvided) _ns.close();
			
			_video.attachNetStream( null );
			
			_nc.removeEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			_nc.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			
			_container.removeChild( _video );
			_container = null;
			
			_src =  null;
			if (!_netStreamProvided) _ns = null;
			if (!_netConnectionProvided) _nsm.dispose();
			
			_video = null;
			_soundTransform = null;
			
			_playing = false;
			_paused = false;
		}
		
		public function resetStream():void
		{
			if (!_netStreamProvided)
			{
				_ns.close();
				_ns = null;
				_video.attachNetStream(null);
				_ns = _nsm.createNetStream();
				_ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
				_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
				_video.attachNetStream(_ns);
			}
		}
		
		
		//////////////////////////////////////////////////////
		// event handlers
		//////////////////////////////////////////////////////
		
		// Handles error messages.  
		private function securityErrorHandler(event:SecurityErrorEvent):void {
			// TODO: log these events
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent):void {
			// TODO: log these events
		}
		
		protected function netStatusHandler(e:NetStatusEvent):void
		{
			// log event
			if (verbose)
			{
				var traceMsg:String = "[" + getTimer()/1000 + "s - NetStatusEvent] ";
				if (e.currentTarget==_ns)
					traceMsg += "[" + _src + "] ";
				traceMsg += e.info["code"] + " (" + e.info["description"] + ")";
				trace(traceMsg);
			}
			
			// take action according to event
			if (e.currentTarget==_ns)
			{
				traceMsg = _src + " player:";
				switch (e.info["code"]) {
					case "NetStream.Play.Stop": 
						//this.dispatchEvent( new VideoEvent(VideoEvent.STOP,_netStream, file) ); 
						if(loop)
							_ns.play(_src);
						break;
					case "NetStream.Play.Play":
						//this.dispatchEvent( new VideoEvent(VideoEvent.PLAY,_netStream, file) );
						break;
					case "NetStream.Play.StreamNotFound":
						trace("   -> The file "+ _src +" was not found", e);
						break;
					case "NetConnection.Connect.Success":
						attach();
						break;
					case "NetStream.Buffer.Full":
						if (!_ready)
							markAsReady();
						break;
				}	
			}
		}
		
		// attach netconnection to netstream, netstream to video, and video to container
		private function attach():void
		{
			if (_ns == null)
			{
				_ns = _nsm.createNetStream();
			}
			_ns.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler, false, 0, true);
			_ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler);
			
			// video
			_video.attachNetStream( _ns );
			
			// container
			_container = new Sprite();
			_container.addChild( _video );
			
			// if playing video locally, then player is ready now
			if (_nsm != null && _nsm.serverAddress == null)
				markAsReady();
		}
		
		protected function markAsReady():void // also serves as a "onReady" method
		{
			pause();
			_ready = true;
			this.dispatchEvent(new Event("ready", true));
			trace("Player ready");
		}
		
		
		//////////////////////////////////////////////////////
		// get / set functions
		//////////////////////////////////////////////////////
		
		
		public function get source():String
		{
			return _src;
		}
		
		public function set source(src:String):void
		{
			if (_src != src)
			{
				_src = src;
				if(_playing) _ns.play(_src);
			}
		}
		
		public function get loop():Boolean
		{
			return _loop;
		}
		
		public function set loop(val:Boolean):void
		{
			_loop = val;
		}
		
		public function get volume():Number
		{
			return _ns.soundTransform.volume;
		}
		
		public function set volume(val:Number):void
		{
			_soundTransform.volume = val;
			_ns.soundTransform = _soundTransform;
			_lastVolume = val;
		}
		
		public function get pan():Number
		{
			return _ns.soundTransform.pan;
		}
		
		public function set pan(val:Number):void
		{
			_soundTransform.pan = pan;
			_ns.soundTransform = _soundTransform;
		}
		
		public function get mute():Boolean
		{
			return _ns.soundTransform.volume == 0;
		}
		
		public function set mute(val:Boolean):void
		{
			_soundTransform.volume = (val)? 0 : _lastVolume;
			_ns.soundTransform = _soundTransform;
		}
		
		public function get soundTransform():SoundTransform
		{
			return _ns.soundTransform;
		}
		
		public function set soundTransform(val:SoundTransform):void
		{
			_ns.soundTransform = val;
		}
		
		public function get width():int
		{
			return _video.width;
		}
		
		public function set width(val:int):void
		{
			_video.width = val;
		}
		
		public function get height():int
		{
			return _video.height;
		}
		
		public function set height(val:int):void
		{
			_video.height = val;
		}
		
		public function get fps():int
		{
			return _fps;
		}
		
		public function set fps(val:int):void
		{
			_fps = val;
		}
		
		public function get ns():NetStream
		{
			return _ns;
		}
		
		//////////////////////////////////////////////////////
		// read-only vars
		//////////////////////////////////////////////////////
		
		public function get container():Sprite
		{
			return _container;
		}
		
		public function get time():Number
		{
			return _ns.time;
		}
		
		public function get playing():Boolean
		{
			return _playing;
		}
		
		public function get paused():Boolean
		{
			return _paused;
		}
		
		public function get ready():Boolean
		{
			return _ready;
		}
		
		public function get nsm():NetStreamManager
		{
			return _nsm;
		}
		
		public function get currentFPS():Number
		{
			return _ns.currentFPS;
		}
		
		public function get currentPosition():int
		{
			return int(time * fps); // note that the time method is not very accurate
		}
		
		//////////////////////////////////////////////////////
		// event dispatcher methods
		//////////////////////////////////////////////////////
		
		public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			_eventDispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function dispatchEvent(event:Event):Boolean
		{
			return _eventDispatcher.dispatchEvent(event);
		}
		
		public function hasEventListener(type:String):Boolean
		{
			return _eventDispatcher.hasEventListener(type);
		}
		
		public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			_eventDispatcher.removeEventListener(type, listener, useCapture);
		}
		
		public function willTrigger(type:String):Boolean
		{
			return _eventDispatcher.willTrigger(type);
		}


	}
}