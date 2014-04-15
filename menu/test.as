package  {
	// Flash Libraries
	import flash.display.MovieClip;

    // Valve Libaries
    import ValveLib.Globals;
    import ValveLib.ResizeManager;
    import scaleform.clik.events.ButtonEvent;

    // Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

    // For chrome browser
    import flash.utils.getDefinitionByName;

    import flash.net.Socket;

	public class test extends MovieClip {
		// Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        // Play area stuff
        public var playClip:MovieClip;
        public var playMain:MovieClip;
        public var customTabNum:int = 1337;

        // These vars determain how much of the stage we can use
        // They are updated as the stage size changes
        public var maxStageWidth:Number = 1366;
        public var maxStageHeight:Number = 768;

        // Stores a page
        public var chrome_html:MovieClip;

		// For testing only
		public function test() : void {
			trace("injected by ash47!\n\n\n");
		}

		public function onLoaded() : void {
			trace("injected by ash47!\n\n\n");

			this.gameAPI.OnReady();
         	Globals.instance.resizeManager.AddListener(this);

         	// Create timer to inject
         	var injectTimer:Timer = new Timer(1000, 1);
            injectTimer.addEventListener(TimerEvent.TIMER, logTest);
            injectTimer.start();
		}

		public function onResize(re:ResizeManager) : * {
			trace("Injected by Ash47!\n\n\n");
			x = 0;
			y = 0;
			visible = true;

			this.scaleX = re.ScreenWidth/maxStageWidth;
            this.scaleY = re.ScreenHeight/maxStageHeight;
		}

		public function logTest(e:TimerEvent) {
			trace("Injected by Ash47!\n\n\n");

			trace("Keys:");
			for(var key in globals) {
				trace(key);

				if(globals[key].gameAPI) {
					for(var k2 in globals[key].gameAPI) {
						trace(k2);
					}
				}

			}

			// Hook vars
			playClip = globals.Loader_play.movieClip;
			playMain = playClip.PlayWindow.PlayMain;

			var ymax = 0;
			var xmin = 1000;

			for(var i=0; i<playClip.numNavTabs; i++) {
				var clip = playMain.Nav["tab"+i];
				if(clip.y > ymax) {
					ymax = clip.y;
				}

				if(clip.x < xmin) {
					xmin = clip.x;
				}
			}

			var customLobby = new test_class();
			playMain.addChild(customLobby);
			customLobby.x = xmin+16;
			customLobby.y = ymax;

			customLobby.addEventListener(ButtonEvent.CLICK, onCustomLobbyClicked);

			// Fix issue with tab not existing
			playMain.Nav["tab"+customTabNum] = {
				selected: false
			};

			// Create chrome window
			//InitChromeHTMLRenderTarget();
		}

		public function onCustomLobbyClicked(obj:Object) {
			// Change to correct tab
			playClip.setCurrentTab(1);
			playClip.setCurrentTab(customTabNum);
		}

		public function InitChromeHTMLRenderTarget() : * {
			var rtClass:Class = null;
			var i:* = 0;
			if(this.chrome_html == null)
			{
				rtClass = getDefinitionByName("ChromeHTML") as Class;
				this.chrome_html = new rtClass() as MovieClip;
				this.chrome_html.name = "chrome_html";
				this.addChild(this.chrome_html);
				/*this.chrome_html.FocusInCallback = this.onHTMLFocusIn;
				this.chrome_html.FocusOutCallback = this.onHTMLFocusOut;
				this.chrome_html.KeyDownCallback = this.onHTMLKeyDown;
				this.chrome_html.KeyUpCallback = this.onHTMLKeyUp;
				this.chrome_html.MouseMoveCallback = this.onHTMLMouseMove;
				this.chrome_html.MouseDownCallback = this.onHTMLMouseDown;
				this.chrome_html.MouseUpCallback = this.onHTMLMouseUp;
				this.Today.sbv.addEventListener(Event.SCROLL,this.onHTMLVertScrollBarChanged);
				this.Today.sbh.addEventListener(Event.SCROLL,this.onHTMLHorzScrollBarChanged);
				this.Today.setChildIndex(this.Today.innerShadow,this.Today.numChildren-1);
				this.chrome_html.addEventListener(TextEvent.TEXT_INPUT,this.onHTMLTextInput);*/
			}
			//this.chrome_html.y = this.Today.sbv.y;
			this.chrome_html.visible = true;
			this.chrome_html["lastScreenWidth"] = Globals.instance.resizeManager.ScreenWidth;
			this.chrome_html["lastScreenHeight"] = Globals.instance.resizeManager.ScreenHeight;
			//this.gameAPI.SetHTMLBrowserSize(this.chrome_html.width,this.chrome_html.height,Globals.instance.resizeManager.ScreenWidth,Globals.instance.resizeManager.ScreenHeight);

			trace("\n\n\nKeys:");
			for(var key in this.chrome_html) {
				trace(key);
			}
		}
	}

}
