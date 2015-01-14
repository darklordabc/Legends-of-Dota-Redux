package  {
	import flash.display.MovieClip;

	public class DotaComboBox extends MovieClip {
		// Will contain an actual combo box
		public var comboBox:MovieClip;

		// Container for a combo box
		public var comboBoxContainer:MovieClip;

		public function DotaComboBox() {
			// Create the combo box
			comboBox = Util.comboBox(comboBoxContainer, null);
		}

		// Sets the data in the slots
		public function setComboBoxSlots(slots:Array):void {
			Util.setComboBoxSlots(comboBox, slots);
		}

		// Sets the callback to run
		public function setIndexCallback(callback:Function):void {
			comboBox.setIndexCallback = callback;
		}
	}

}
