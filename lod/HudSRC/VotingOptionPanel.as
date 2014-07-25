package  {
	import flash.display.MovieClip;

	public class VotingOptionPanel extends MovieClip {
		// The hint box
		public var hint;

		// The description box
		public var des;

		// The dropdown box
		public var dropDown:MovieClip;

		public function VotingOptionPanel(desText:String, hintText:String, slots:Number) {
			// Update info
			updateDes(desText);
			updateHint(hintText);

			// Create the drop down box
			dropDown = lod.comboBox(this, slots);
			dropDown.x = this.width/2-dropDown.width-1;
			dropDown.y = 0.5;

			// Bring hint to the front
			this.setChildIndex(hint, this.numChildren-1);
		}

		// Updates the description text
		public function updateDes(txt:String) {
			// Set the text directly
			des.text = txt;
		}

		// Updates the hint text
		public function updateHint(txt:String):void {
			// Pass the update
			hint.updateHint(txt);
		}
	}

}
