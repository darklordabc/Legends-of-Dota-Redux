package  {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class VotingHint extends MovieClip {
		public var info;

		public function VotingHint() {
			// Hook events
			this.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
            this.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);

			// Hide the hint
			info.visible = false;
		}

		public function updateHint(txt:String):void {
			info.text = txt;
			info.height = info.textHeight+4;
		}

		private function onRollOver(e:MouseEvent):void {
			// Show the hint
			info.visible = true;
		}

		private function onRollOut(e:MouseEvent):void {
			// Hide the hint
			info.visible = false;
		}
	}

}
