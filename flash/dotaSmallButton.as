package  {

	import flash.display.MovieClip;


	public class dotaSmallButton extends MovieClip {
		// Container for button
		public var container:MovieClip;

		// The button itself
		public var btn:MovieClip;

		public function dotaSmallButton() {
			btn = Util.smallButton(container, '');
		}

		public function setText(newStr:String):void {
			btn.label = newStr;
		}
	}

}
