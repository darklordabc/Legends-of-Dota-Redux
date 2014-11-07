package  {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	// Timer
    import flash.utils.Timer;

    // Events
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;

    // Used to make nice buttons / doto themed stuff
    import flash.utils.getDefinitionByName;

	public class lobby extends MovieClip
	{
		// element details filled out by game engine
		public var gameAPI:Object;
		public var globals:Object;
		public var elementName:String;

		// The placeholder
		public var buttonHolder:MovieClip;

		// Size of the custom hud
		private var ourWidth:Number = 1024;
		private var ourHeight:Number = 768;

		// Our timer
		private var timer:Timer;

		public function lobby() { }

		// called by the game engine when this .swf has finished loading
		public function onLoaded():void {
            // Create the button
            var btn:MovieClip = smallButton(buttonHolder, "Connect");
            btn.addEventListener(MouseEvent.CLICK, onConnectPressed);
            btn.x = -btn.width/2;
            btn.y = 0;

            // Create the timer
            timer = new Timer(1000);
            timer.addEventListener(TimerEvent.TIMER, updateLoop);
            timer.start();

            // Allow conecting outside
            globals.GameInterface.SetConvar("dota_workshoptools_limited_ui", "0");
		}

		// called by the game engine after onLoaded and whenever the screen size is changed
		public function onScreenSizeChanged():void
		{
			// By default, your 1024x768 swf is scaled to fit the vertical resolution of the game
			//   and centered in the middle of the screen.
			// You can override the scaling and positioning here if you need to.
			// stage.stageWidth and stage.stageHeight will contain the full screen size.

			// Workout the scale
			var scale:Number = stage.stageHeight / ourHeight;

			// Apply the new scale
			this.scaleX = scale;
			this.scaleY = scale;

			// Workout how much of the screensize we can actually use
			var useableWidth = stage.stageHeight*ourWidth/ourHeight;

			// Update the position of this hud (we want the 4:3 section centered)
			x = (stage.stageWidth - useableWidth) / 2;
			y = 0;
		}

        // Runs once every second to ensure everything is good
        private function updateLoop(e:TimerEvent):void {
            // Send the command out to register ourselves as the hoster
            gameAPI.SendServerCommand("register_host");

            // Check if this should be visible
            if(globals.Game.GetState() <= 1) {
                // Make ourselves nice and visible
                this.visible = true;
            } else {
                // Kill the timer
                timer.removeEventListener(TimerEvent.TIMER, updateLoop);
                timer.stop();

                // Make invisible
                this.visible = false;
            }
        }

		// Make a small button
        public static function smallButton(container:MovieClip, txt:String):MovieClip {
            // Grab the class for a small button
            var dotoButtonClass:Class = getDefinitionByName("ChannelTab") as Class;

            // Create the button
            var btn:MovieClip = new dotoButtonClass();
            btn.label = txt;
            container.addChild(btn);

            // Return the button
            return btn;
        }

        // When the toggle button is pressed
        private function onConnectPressed(e:MouseEvent):void {
        	// Send the command to the server
        	globals.GameInterface.SetConvar("dota_auto_connect", "lod.ash47.net");
        }
	}
}
