package  {
	// Flash Libraries
	import flash.display.MovieClip;

    // Events
    import flash.events.MouseEvent;
    import flash.events.Event;

    // Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;

    // Sockets
    //import flash.net.ServerSocket;
    //import flash.net.Socket;
    //import flash.events.ServerSocketConnectEvent;
    //import flash.events.ProgressEvent;

    // Eval stuff
    import com.hurlant.eval.Evaluator;
    import com.hurlant.eval.ByteLoader;
    import flash.utils.ByteArray;
    import flash.display.Loader;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.display.Loader;
    import flash.system.LoaderContext;

	public class console extends MovieClip {
		// Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        // Resizing stuff
        public var maxStageWidth:Number = 1280;
        public var maxStageHeight:Number = 720;

        // Reference to main class
        private static var instance:MovieClip;

        private var cw:MovieClip;
        private var dragging = false;
        private var mx;
        private var my;

        // Sockets
        //private var serverSocket:ServerSocket = new ServerSocket();
        //private var clientSocket:Socket;

        private var evaluator:Evaluator;

		public function console() {
            //onLoaded();

            //evaluator = new Evaluator();

            //if(serverSocket.bound) {
            //    serverSocket.close();
            //    serverSocket = new ServerSocket();
            //}

            //serverSocket.bind(1337, "127.0.0.1");
            //serverSocket.addEventListener(ServerSocketConnectEvent.CONNECT, onConnect);
            //serverSocket.listen();

            //console_window.getInstance().print("listening!");


            //var bytes = ByteLoader.wrapInSWF([evaluator.eval("trace('test');")]);
            //var loader = new Loader();
            //var c = new LoaderContext();
            //c.allowCodeImport = true;
            //trace(bytes);
            //loader.loadBytes(bytes, c);

            //loader.loadBytes(bytes, c);
		}

        /*public function onConnect(event:ServerSocketConnectEvent) {
            clientSocket = event.socket;
            clientSocket.addEventListener(ProgressEvent.SOCKET_DATA, onClientSocketData);
            //trace("Hi Sexy!");
            console_window.getInstance().print("connected");

            var bytes = ByteLoader.wrapInSWF([evaluator.eval("trace('test');")]);
            trace("Writing "+bytes.length);
            trace(bytes);
            clientSocket.writeBytes(bytes, 0, bytes.length);
            clientSocket.flush();

            var loader = new Loader();
            var c = new LoaderContext();
            c.allowCodeImport = true;

            loader.loadBytes(bytes, c);

        }*/

        //private function onClientSocketData(event:ProgressEvent):void {
            //var buffer:ByteArray = new ByteArray();
            //clientSocket.readBytes( buffer, 0, clientSocket.bytesAvailable );
            //log( "Received: " + buffer.toString() );
        //}

        // Returns this class
        public static function getInstance():MovieClip {
            return instance;
        }

        // When loaded by dota
        public function onLoaded() : void {
            // Store reference
            instance = this;

            // Create the console window
            cw = new console_window();
            cw.x = 0;
            cw.y = 0;
            addChild(cw);

            // Hook clicking of it
            cw.addEventListener(MouseEvent.MOUSE_DOWN, startDragging, true);
            cw.addEventListener(MouseEvent.MOUSE_UP, stopDragging, true);

            // Update the drag
            var timer:Timer = new Timer(10, 0);
            timer.addEventListener(TimerEvent.TIMER, updateDrag);
            timer.start();

            // Handle scaleform stuff
            this.gameAPI.OnReady();
            Globals.instance.resizeManager.AddListener(this);
        }

        public function onResize(re:ResizeManager) : * {
            // Align correctly
            x = 0;
            y = 0;
            visible = true;

            this.scaleX = re.ScreenWidth/maxStageWidth;
            this.scaleY = re.ScreenHeight/maxStageHeight;
        }

        public function startDragging(e:MouseEvent) {
            if(e.target == cw.console_bg) {
                dragging = true;
                mx = mouseX;
                my = mouseY;
            }
        }

        public function stopDragging(e:MouseEvent) {
            dragging = false;
        }

        public function updateDrag(e:Event) {
            if(dragging) {
                // Move it
                cw.x += mouseX-mx;
                cw.y += mouseY-my;

                // Store old vals
                mx = mouseX;
                my = mouseY;
            }
        }
	}
}
