package  {
	// Flash stuff
	import flash.display.MovieClip;

	public class PlayerSkill extends MovieClip {
		// The name of our current skill
		private var skillName:String;

		// This holds the image of our current skill
		public var ability:MovieClip;

		// How to scale the skill image
		private var skillScale = 0.125;

		public function PlayerSkill() {
		}

		// Updates the the current skill
		public function setSkillName(skillName:String) {
			// Should we change?
			if(this.skillName != skillName) {
				// Store the change
				this.skillName = skillName;

				// Load the new image
				if(this.skillName != '') {
					ability.setSkillName(skillName);
				}
			}
		}

		// Returns our skill name
		public function getSkillName():String {
			return this.skillName;
		}
	}

}
