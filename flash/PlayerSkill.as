package  {
	// Flash stuff
	import flash.display.MovieClip;

	public class PlayerSkill extends MovieClip {
		// This holds the image of our current skill
		public var abilityClip:MovieClip;

		public function PlayerSkill() {
		}

		// Updates the the current skill
		public function setSkillName(skillName:String):Boolean {
			return this.abilityClip.setSkillName(skillName);
		}

		// Returns our skill name
		public function getSkillName():String {
			return this.abilityClip.getSkillName();
		}
	}

}
