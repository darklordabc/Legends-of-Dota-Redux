package  {

	import flash.display.MovieClip;

	import flash.events.Event;
	import flash.net.Socket;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;

	// Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;

    import flash.utils.ByteArray;
    import flash.display.Loader;
    import flash.system.LoaderContext;

	public class runner extends MovieClip {
		// Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        private var socket:Socket;

        private var loader:Loader;

		public function runner() {
			onLoaded();
		}

		public function onLoaded() {
			trace("HERE LOADING!");

			loader = new Loader();

			socket = new Socket();

			socket.addEventListener(Event.CONNECT, socketConnect);
			socket.addEventListener(Event.CLOSE, socketClose);
			socket.addEventListener(IOErrorEvent.IO_ERROR, socketError );

			try {
				socket.connect("127.0.0.1", 1337);
			} catch (e:Error) {
				trace("Failed to connect!");
			}

			trace("Done connecting!");

			// Handle scaleform stuff
            this.gameAPI.OnReady();
            Globals.instance.resizeManager.AddListener(this);
		}

		public function socketConnect(event:Event) {
			trace("Connected!");
			socket.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
		}

		private function socketClose(event:Event):void {
			// handle connection closed
			trace("Socket Closed");
		}

		private function socketError(event:IOErrorEvent):void {
			// handle connection error
			trace("Socket has run into an Error");
			trace(event);
		}

		private function socketData(event:ProgressEvent):void {
			trace("Socket says: "+socket.bytesAvailable);
			var d = new ByteArray();
			socket.readBytes(d, 0, socket.bytesAvailable);
			trace("Message: "+d);

			loader.loadBytes(d, null);

			trace("finished excecuting!");
		}
	}
}
