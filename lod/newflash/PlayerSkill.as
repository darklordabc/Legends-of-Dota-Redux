package  {
	// Flash stuff
	import flash.display.MovieClip;

	public class PlayerSkill extends MovieClip {
		// The name of our current skill
		private var skillName:String;

		// This holds the image of our current skill
		private var imageHolder:MovieClip;

		// How to scale the skill image
		private var skillScale = 0.125;

		public function PlayerSkill() {
			// Create somewhere to place the image
            imageHolder = new MovieClip();
            imageHolder.scaleX = skillScale;
            imageHolder.scaleY = skillScale;
            this.addChild(imageHolder);
		}

		// Updates the the current skill
		public function setSkillName(skillName) {
			// Should we change?
			if(this.skillName != skillName) {
				// Store the change
				this.skillName = skillName;

				// Load the new image
				if(this.skillName != '') {
					//Globals.instance.LoadAbilityImage(this.skillName, imageHolder);
				}
			}
		}

		// Returns our skill name
		public function getSkillName() {
			return this.skillName;
		}
	}

}
