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

		// Is this fully active?
		private var fullyActive:Boolean;

		// Is this active?
		private var active:Boolean;

		public function SelectSkillList() {
			// Hide the hero image
            heroImage.visible = false;

            // This isn't active
            fullyActive = false;
            active = false;
		}

		// Resets the number of active children we have
		public function resetActiveChildren():void {
			active = false;
			heroImage.visible = false;

			heroImage.filters = Util.greyFilter;
		}

		// Adds an active child
		public function addActiveChild(fully:Boolean):void {
			active = true;
			heroImage.visible = fullyActive;

			if(fully) {
				heroImage.filters = null;
			}
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
			fullyActive = true;
		}

		private function onSkillRollOver():void {
			this.heroImage.visible = false;
		}

		private function onSkillRollOut():void {
			this.heroImage.visible = active && fullyActive;
		}
	}
}
