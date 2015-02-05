package  {

	import flash.display.MovieClip;
	import ValveLib.Controls.VideoController;


	public class test extends MovieClip {
		// Game API related stuff
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;

        // Timer
		import flash.utils.Timer;
		import flash.events.TimerEvent;

		public function test() {
		}

		public function onLoaded() : void {
			trace("Running injection...\n\n\n");

			this.gameAPI.OnReady();

			var injectTimer:Timer = new Timer(1000, 1);
            injectTimer.addEventListener(TimerEvent.TIMER, inject);
            injectTimer.start();
		}

		public function inject(e:TimerEvent) {
			trace(globals.Loader_shared_heroselectorandloadout);
			var mc = globals.Loader_shared_heroselectorandloadout.movieClip;

			trace(mc);
			trace('Doing it...');
			var vc = new VideoController(mc.NUM_SELECTOR_CARDS + 1);
			trace(vc);
			mc.cardVideoController = vc;
			trace('Done!');
		}
	}
}

