package  {
	// Flash stuff
	import flash.display.MovieClip;

	// Dota 2 interface
	import ValveLib.Globals;

	public class YourSkill extends MovieClip {
		// The text field
		public var skillType;

		// The name of our current skill
		private var skillName:String;

		// This holds the image of our current skill
		public var ability:MovieClip;

		// How to scale the skill image
		private var skillScale = 64/128;

		// Our skill slot
		private var skillSlot;

		public function YourSkill() {
		}

		public function setSkillSlot(skillSlot):void {
			this.skillSlot = skillSlot;
		}

		public function getSkillSlot():Number {
			return this.skillSlot;
		}

		// Updates the the current skill
		public function setSkillName(skillName) {
			// Store the change
			this.skillName = skillName;

			// Load the new image
			ability.setSkillName(skillName);
		}

		// Returns our skill name
		public function getSkillName() {
			return this.skillName;
		}
	}

}
