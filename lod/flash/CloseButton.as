package  {
	import flash.display.MovieClip;
	import flash.events.MouseEvent;

	public class CloseButton extends MovieClip {
		public function CloseButton() {
			// Hook the press
			this.addEventListener(MouseEvent.CLICK, onPressed);
		}

		// Removes the parent from it's parent
		private function onPressed():void {
			this.parent.parent.removeChild(this.parent);
		}
	}
}
