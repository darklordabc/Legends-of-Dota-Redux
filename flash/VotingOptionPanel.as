package  {
	import flash.display.MovieClip;

	public class VotingOptionPanel extends MovieClip {
		// The hint box
		public var hint;

		// The description box
		public var des;

		// The slave response
		public var slaveText;

		// The dropdown box
		public var dropDown:MovieClip;

		public function VotingOptionPanel(slave:Boolean, desText:String, hintText:String, slots:Array) {
			// Update info
			updateDes(desText);
			updateHint(hintText);

			// Create correct GUI
			if(slave) {
				// Show the slave text
				slaveText.visible = true;
			} else {
				// Hide the slave text
				slaveText.visible = false;

				// Create the drop down box
				var realWidth:Number = 335;
				var dropDownBoxWidth:Number = 140;
				dropDown = Util.comboBox(this, slots);
				dropDown.x = realWidth/2-dropDownBoxWidth-2;
				dropDown.y = 0.5;

				// Bring hint to the front
				this.setChildIndex(hint, this.numChildren-1);
			}
		}

		// Updates the description text
		public function updateDes(txt:String):void {
			// Set the text directly
			des.text = txt;
		}

		// Updates the hint text
		public function updateHint(txt:String):void {
			// Pass the update
			hint.updateHint(txt);
		}

		// Updates the slave text
		public function updateSlave(txt:String, newIndex:Number):void {
			// Store the change
			this.slaveText.text = txt;

			if(dropDown != null) {
				dropDown.setSelectedIndex(newIndex);
			}
		}
	}

}
