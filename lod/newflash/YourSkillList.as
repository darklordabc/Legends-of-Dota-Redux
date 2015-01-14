package  {
	import flash.display.MovieClip;

	public class YourSkillList extends MovieClip {
		// Our skills
		public var skill0:MovieClip;
		public var skill1:MovieClip;
		public var skill2:MovieClip;
		public var skill3:MovieClip;
		public var skill4:MovieClip;
		public var skill5:MovieClip;

		public function YourSkillList() {
			this.gotoAndStop(1);
		}

		public function setup(totalSlots:Number, slotInfo:String):void {
			// Ensure valid values
			if(totalSlots < 4) {
				totalSlots = 4;
				trace('WARNING: Total slots was < 4');
			} else if(totalSlots > 6) {
				totalSlots = 6;
				trace('WARNING: total slots was > 6');
			}

			// Change the number of skills
			if(totalSlots <= 4) {
				this.gotoAndStop(1);
			} else if(totalSlots == 5) {
				this.gotoAndStop(2);
			} else {
				this.gotoAndStop(3);
			}

			// Set the sorts of slots they are
			for(var i=0; i<totalSlots; i++) {
				// Grab the character for this slot
				var char:String = slotInfo.charAt(i);

				// Grab the slot
				var s:MovieClip = this['skill'+i];

				switch(char) {
					case lod.SLOT_TYPE_ABILITY:
						s.skillType.text = '#skill';
						break;

					case lod.SLOT_TYPE_ULT:
						s.skillType.text = '#ult';
						break;

					case lod.SLOT_TYPE_EITHER:
						s.skillType.text = '#either';
						break;

					case lod.SLOT_TYPE_NEITHER:
						s.skillType.text = '#nothing';
						break;
				}
			}
		}

		// Puts a skill into a slot
		public function skillIntoSlot(slotNumber:Number, skillName:String):Boolean {
			// Grab the slot
			var s:MovieClip = this['skill'+slotNumber];

			// Ensure it exists
			if(s != null) {
				// Set the skill in the slot
				return s.setSkillName(skillName);
			}

			return false;
		}
	}
}
