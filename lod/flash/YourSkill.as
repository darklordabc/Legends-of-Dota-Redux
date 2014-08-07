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
		private var imageHolder:MovieClip;

		// How to scale the skill image
		private var skillScale = 64/128;

		// Our skill slot
		private var skillSlot;

		public function YourSkill() {
			// Create somewhere to place the image
            imageHolder = new MovieClip();
            imageHolder.scaleX = skillScale;
            imageHolder.scaleY = skillScale;
            this.addChild(imageHolder);
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
			if(this.skillName != '') {
				Globals.instance.LoadAbilityImage(this.skillName, imageHolder);
			}
		}

		// Returns our skill name
		public function getSkillName() {
			return this.skillName;
		}
	}

}
