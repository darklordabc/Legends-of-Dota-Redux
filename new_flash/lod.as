package  {
    // Flash stuff
    import flash.display.MovieClip;

	// Timer
    import flash.utils.Timer;
    import flash.events.TimerEvent;

	public class lod extends MovieClip {
		/*
            DOTA BASED STUFF
        */
		public var gameAPI:Object;
        public static var GameAPI:Object;
		public var globals:Object;
        public static var Globals;
		public var elementName:String;

        // Key bindings
        private var keyBindings:Array;

        // Hud fixing timer
        private static var hudFixingTimer:Timer;

		// called by the game engine when this .swf has finished loading
		public function onLoaded():void {
            // Start her up
            doInit();
		}

        private function doInit() {
            trace('\n\nLoD scaleform hacks are loading...');

            this.gameAPI.SubscribeToGameEvent('dota_player_update_selected_unit', onUnitSelectionUpdated);  // The player changed the unit they had selected

            trace('Finished loading LoD scaleform hacks!\n\n');
        }

        /*
            FIXES
        */

        // When the unit selection is updated
        private function onUnitSelectionUpdated():void {
            if(hudFixingTimer != null) {
                hudFixingTimer.stop();
                hudFixingTimer = null;
            }

            hudFixingTimer = new Timer(100, 1);
            hudFixingTimer.addEventListener(TimerEvent.TIMER, fixHotkeys, false, 0, true);
            hudFixingTimer.start();
        }

        // Fixes the hot keys
        private function fixHotkeys():void {
            if(hudFixingTimer != null) {
                hudFixingTimer.stop();
                hudFixingTimer = null;
            }

            var MAX_SLOTS = 6;

            keyBindings = ['Q', 'W', 'E', 'D', 'F', 'R', 'Q', 'W', 'E', 'D', 'F', 'R'];
            keyBindings[MAX_SLOTS-1] = 'R';

            // Set the text
            try {
                for(var i:Number=0; i<6; i++) {
                    globals.Loader_actionpanel.movieClip.middle.abilities['abilityBind'+i].label.text = keyBindings[i];
                }
            } catch(e) {}


            // Grab the frame number
            var frameNumber:Number = MAX_SLOTS - 3;

            try {
                // Ability layout changer
                if(globals.Loader_actionpanel.movieClip.middle.abilities.currentFrame != frameNumber) {
                    globals.Loader_actionpanel.movieClip.middle.abilities.gotoAndStop(frameNumber);
                }
            } catch(e) {}

            // Fire again
            hudFixingTimer = new Timer(500, 1);
            hudFixingTimer.addEventListener(TimerEvent.TIMER, fixHotkeys, false, 0, true);
            hudFixingTimer.start();
        }
	}
}
