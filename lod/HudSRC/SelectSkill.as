package  {
	// Flash stuff
	import flash.display.MovieClip;

	// Dota 2 interface
	import ValveLib.Globals;

	public class SelectSkill extends MovieClip {
		// The name of our current skill
		private var skillName:String;

		// This holds the image of our current skill
		private var imageHolder:MovieClip;

		// How to scale the skill image
		private var skillScale:Number = 40/256;

		// Is this skill banned?
		public var banned:MovieClip;

		public function SelectSkill() {
			// Create somewhere to place the image
            imageHolder = new MovieClip();
            imageHolder.scaleX = skillScale;
            imageHolder.scaleY = skillScale;
            this.addChild(imageHolder);

            // Bring banned to the front
            this.setChildIndex(this.banned, this.numChildren-1);

            // Set this to not banned
            setBanned(false);
		}

		// Updates the the current skill
		public function setSkillName(skillName):void {
			// Store the change
			this.skillName = skillName;

			// Load the new image
			Globals.instance.LoadAbilityImage(this.skillName, imageHolder);
		}

		// Returns our skill name
		public function getSkillName():String {
			return this.skillName;
		}

		// Sets this skill to show as banned, or not
		public function setBanned(state:Boolean):void {
			// Store state
			this.banned.visible = state;
		}
	}

}
