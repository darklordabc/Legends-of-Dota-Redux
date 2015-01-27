package  {
	// Flash stuff
	import flash.display.MovieClip;
	import flash.text.TextField;

	public class YourSkill extends MovieClip {
		// The text field
		public var skillType:TextField;

		// This holds the image of our current skill
		public var abilityClip:MovieClip;

		// The hot key
		public var hotKey:TextField;

		// Our skill slot
		private var skillSlot:Number;

		// The slot type
		private var slotType:String

		// The interace we are on (your, bear, tower)
		private var ourInterface:Number;

		public function YourSkill() {
		}

		// Sets our interface and slot number
		public function setSkillSlot(newInterface:Number, skillSlot:Number):void {
			// Store the skill slot
			this.ourInterface = newInterface;
			this.skillSlot = skillSlot;
		}

		// Returns our interface
		public function getInterface():Number {
			return this.ourInterface;
		}

		// Returns our skill slot
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

		// Gets the type of slot
		public function getSlotType():String {
			return this.slotType;
		}

		// Updates the slot type
		public function setSlotType(newSlotType:String):void {
			this.slotType = newSlotType;

			switch(newSlotType) {
				case lod.SLOT_TYPE_ABILITY:
					skillType.text = '#skill';
					break;

				case lod.SLOT_TYPE_ULT:
					skillType.text = '#ult';
					break;

				case lod.SLOT_TYPE_EITHER:
					skillType.text = '#either';
					break;

				case lod.SLOT_TYPE_NEITHER:
					skillType.text = '#nothing';
					break;
			}
		}
	}
}
