package  {
	// Flash stuff
	import flash.display.MovieClip;

	public class SelectSkill extends MovieClip {
		// The name of our current skill
		private var skillName:String;

		// This holds the image of our current skill
		public var abilityClip:MovieClip;

		// Is this skill banned?
		public var banned:MovieClip;

		public function SelectSkill() {
            // Set this to not banned
            setBanned(false);
		}

		// Updates the the current skill
		public function setSkillName(skillName):Boolean {
			// Store the skill name
			this.skillName = skillName;

			// Store the change
			return abilityClip.setSkillName(skillName);
		}

		// Returns our skill name
		public function getSkillName():String {
			return this.skillName;
		}

		// Sets this skill to show as banned, or not
		public function setBanned(state:Boolean):void {
			// Getting weirdness here, ensure banned exists?
			if(!this.banned) return;

			// Store state
			this.banned.visible = state;
		}
	}
}
