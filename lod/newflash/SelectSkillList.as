package  {
	// Flash stuff
	import flash.display.MovieClip;

	// Other events
	import flash.events.MouseEvent;

	public class SelectSkillList extends MovieClip {
		// Our skills
		public var skill0:MovieClip;
		public var skill1:MovieClip;
		public var skill2:MovieClip;
		public var skill3:MovieClip;

		// The hero image
		public var heroImage:MovieClip;

		// Is this active?
		private var active:Boolean;

		public function SelectSkillList() {
			// Hide the hero image
            heroImage.visible = false;

            // This isn't active
            active = false;
		}

		// Updates the hero image
		public function setHeroImage(newImage:String):void {
			if(!newImage) {
				// Hide the hero image
            	heroImage.visible = false;
            	return;
			}

			// Update the image
			heroImage.setHeroImage(newImage);

			// Show it
			heroImage.visible = true;

			// Hook once
			if(!active) {
				this.addEventListener(MouseEvent.ROLL_OVER, onSkillRollOver, false, 0, true);
	            this.addEventListener(MouseEvent.ROLL_OUT, onSkillRollOut, false, 0, true);
			}

			// Set it to be active
			active = true;
		}

		private function onSkillRollOver():void {
			this.heroImage.visible = false;
		}

		private function onSkillRollOut():void {
			this.heroImage.visible = active;
		}
	}
}
