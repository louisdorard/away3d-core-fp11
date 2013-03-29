package away3d.materials.utils
{
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.NetConnection;
	import flash.net.NetStream;

	public class NetStreamManager extends EventDispatcher
	{
		private var _nc:NetConnection;
		private var _nsClient:Object;
		private var _serverAddress:String;
		
		// Opens one connection to a server, and makes it possible to create streams attached to this connection.
		public function NetStreamManager(serverAddress:String)
		{
			// client object that'll redirect various calls from the video stream
			_nsClient = {};
			_nsClient["onCuePoint"] = metaDataHandler;
			_nsClient["onMetaData"] = metaDataHandler;
			_nsClient["onBWDone"] = onBWDone;
			_nsClient["close"] = streamClose;
			
			// init _nc
			_nc = new NetConnection();
			_nc.client = _nsClient;
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler, false, 0, true);
			_nc.addEventListener(IOErrorEvent.IO_ERROR, 			ioErrorHandler, false, 0, true);
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, 		asyncErrorHandler, false, 0, true);
			
			_serverAddress = serverAddress; 
			_nc.connect(_serverAddress);
			if (_nc.connected)
				dispatchEvent(new Event("connected"));
			else
				_nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
		}
		
		private function netStatusHandler(event:NetStatusEvent):void
		{
			trace(event.info.code);
			switch (event.info.code) {
				case "NetConnection.Connect.Success":
					trace("NetConnection established");
					dispatchEvent(new Event("connected"));
					break;
				case "NetConnection.Connect.Closed":
					trace("NetConnection closed");
					// TODO: reconnect
					break;
				case "NetConnection.Connect.Failed":
					trace("Failed to connect");
					// TODO: reconnect 
					break;
			}
		}
		
		// only possible when connected
		public function createNetStream():NetStream
		{
			var ns:NetStream = new NetStream(_nc);
			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler, false, 0, true);
			ns.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler, false, 0, true);
			ns.checkPolicyFile = true;
			ns.client = _nsClient;
			return ns;
		}
		
		public function dispose():void
		{
			_nc.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
			_nc.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler );
			_nc.removeEventListener( AsyncErrorEvent.ASYNC_ERROR, asyncErrorHandler );
			_nc = null;
			
			// TODO: dispose all netstreams that have been opened (set them to null)
			
			_nsClient["onCuePoint"] = null;
			_nsClient["onMetaData"]	= null;
			_nsClient["onBWDone"] 	= null;
			_nsClient["close"]		= null;
			_nsClient = null;
		}
		
		
		private function onBWDone():void
		{
			// Must be present to prevent errors for RTMP, but won't do anything
			// trace("BWDone");
		}
		
		private function streamClose():void
		{
			trace("The stream was closed. Incorrect URL?");
		}
		
		private function metaDataHandler(oData:Object = null):void
		{
			// Offers info such as oData.duration, oData.width, oData.height, oData.framerate and more (if encoded into the FLV)
			//this.dispatchEvent( new VideoEvent(VideoEvent.METADATA,_netStream,file,oData) );
			// trace("Metadata: " + oData.toString());
		}
		
		private function asyncErrorHandler(event:AsyncErrorEvent): void
		{
			// Must be present to prevent errors, but won't do anything
			trace("An async error occured: " + event.text);
		}
		
		private function ioErrorHandler(e:IOErrorEvent):void
		{
			trace("An IOerror occured: "+e.text);
		}
		
		private function securityErrorHandler(e:SecurityErrorEvent):void
		{
			trace("A security error occured: "+e.text+" Remember that the FLV must be in the same security sandbox as your SWF.");
		}

		public function get nc():NetConnection
		{
			return _nc;
		}

		public function get serverAddress():String
		{
			return _serverAddress;
		}


	}
}