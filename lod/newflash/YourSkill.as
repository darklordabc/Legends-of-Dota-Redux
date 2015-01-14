package  {
	// Flash stuff
	import flash.display.MovieClip;

	public class YourSkill extends MovieClip {
		// The text field
		public var skillType;

		// This holds the image of our current skill
		public var abilityClip:MovieClip;

		// Our skill slot
		private var skillSlot;

		public function YourSkill() {
		}

		public function setSkillSlot(skillSlot):void {
			// Store the skill slot
			this.skillSlot = skillSlot;
		}

		public function getSkillSlot():Number {
			return this.skillSlot;
		}

		// Updates the the current skill
		public function setSkillName(skillName):Boolean {
			// Store the change
			return this.abilityClip.setSkillName(skillName);
		}

		// Returns our skill name
		public function getSkillName():String {
			return this.abilityClip.getSkillName();
		}
	}

}
